/// Regressiya: refresh oqimi DI grafida sikl hosil qilmaydi va 401 → refresh
/// → qayta urinish zanjiri ishlaydi (§4.7, M152).
///
/// Bag: `authDio → refreshCoordinator → tokenRefreshClient → authApi → authDio`
/// sikli `CircularDependencyError` bergan va **har bir** autentifikatsiyalangan
/// so'rovni `DioException [unknown]` bilan yiqitgan edi.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/network/api_client.dart';
import 'package:eld_mobile/core/network/refresh_coordinator.dart';
import 'package:eld_mobile/core/router/auth_state.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/session/session_terminator.dart';
import 'package:eld_mobile/features/auth/data/auth_providers.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import '../../features/auth/session_test_fakes.dart';
import '../helpers/test_clock.dart';

class _FakeStorage implements FlutterSecureStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// Skriptlangan javob beruvchi soxta transport.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, Object?> body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: <String, List<String>>{
    Headers.contentTypeHeader: <String>[Headers.jsonContentType],
  },
);

void main() {
  // Chiqish oqimi platforma kanallariga (GPS) tegadi — binding kerak.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeStorage storage;
  late SecureVault vault;

  setUp(() {
    storage = _FakeStorage();
    vault = SecureVault(storage: storage);
  });

  test('DI grafi siklsiz quriladi: refresh alohida transportda ketadi', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[secureVaultProvider.overrideWithValue(vault)],
    );
    addTearDown(container.dispose);

    // Sikl bo'lsa shu o'qishlarning biri `CircularDependencyError` beradi.
    final Dio appDio = container.read(authDioProvider);
    final Dio refreshDio = container.read(authRefreshDioProvider);
    final RefreshCoordinator coordinator = container.read(refreshCoordinatorProvider);

    expect(identical(appDio, refreshDio), isFalse);
    // Refresh transportida `AuthInterceptor` yo'q — o'ziga qaytmaydi.
    expect(refreshDio.interceptors.length, lessThan(appDio.interceptors.length));

    final _ScriptedAdapter adapter = _ScriptedAdapter(
      (RequestOptions options) => _json(<String, Object?>{
        'data': <String, Object?>{
          'access_token': 'new-access',
          'refresh_token': 'rotated-refresh',
          'expires_in': 900,
        },
      }, 200),
    );
    refreshDio.httpClientAdapter = adapter;
    storage.values[VaultKeys.refreshToken] = 'stored-refresh';

    // Haqiqiy `TokenRefreshClient` chaqiriladi — graf ish vaqtida ham siklsiz.
    final RefreshOutcome outcome = await coordinator.refresh(DriverSlot.primary);

    expect(outcome, isA<RefreshSucceeded>());
    expect(adapter.requests.single.path, '/auth/refresh');
    // Rotatsiya: eski refresh token darhol almashtirilgan.
    expect(storage.values[VaultKeys.refreshToken], 'rotated-refresh');
    expect(vault.accessToken(DriverSlot.primary), 'new-access');
  });

  test('401 → bitta refresh → so\'rov yangi token bilan qayta yuboriladi', () async {
    int refreshCalls = 0;
    final Completer<void> gate = Completer<void>();
    final _StubRefreshClient client = _StubRefreshClient(() async {
      refreshCalls++;
      await gate.future;
      return const RefreshSucceeded(accessToken: 'fresh-access', refreshToken: 'rotated');
    });
    storage.values[VaultKeys.refreshToken] = 'stored-refresh';
    vault.setAccessToken(DriverSlot.primary, 'stale-access');

    final RefreshCoordinator coordinator = RefreshCoordinator(vault: vault, client: client);
    final List<String?> sentTokens = <String?>[];
    final _ScriptedAdapter adapter = _ScriptedAdapter((RequestOptions options) {
      final String? auth = options.headers['Authorization'] as String?;
      sentTokens.add(auth);
      if (auth == 'Bearer stale-access') {
        return _json(<String, Object?>{
          'error': <String, Object?>{'code': 'UNAUTHORIZED', 'message': 'token expired'},
        }, 401);
      }
      return _json(<String, Object?>{
        'data': <String, Object?>{'ok': true},
      }, 200);
    });

    final Dio dio = ApiClient.create(
      vault: vault,
      refreshCoordinator: coordinator,
      appVersion: '1.0.0',
      logger: Logger(level: Level.off),
      baseUrl: 'https://example.test/api/v1',
      adapter: adapter,
    ).dio;

    // Parallel 401 lar — mutex bitta refreshga yig'ishi kerak.
    final Future<List<Response<Object?>>> pending = Future.wait(<Future<Response<Object?>>>[
      dio.get<Object?>('/support-tickets'),
      dio.get<Object?>('/me'),
    ]);
    // Ikkala so'rov ham 401 ni olib, refresh navbatiga tushishi uchun kutiladi.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    gate.complete();
    final List<Response<Object?>> responses = await pending;

    expect(responses.every((Response<Object?> r) => r.statusCode == 200), isTrue);
    expect(refreshCalls, 1, reason: 'parallel 401 lar bitta refreshni bo\'lishadi');
    expect(sentTokens.where((String? t) => t == 'Bearer fresh-access').length, 2);
  });

  test('#B-3: refresh TOKEN_REVOKED → sessiya tugatiladi va `M-56` ga o\'tiladi', () async {
    storage.values[VaultKeys.refreshToken] = 'stored-refresh';
    vault.setAccessToken(DriverSlot.primary, 'stale-access');

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        secureVaultProvider.overrideWithValue(vault),
        sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
        eldTransportProvider.overrideWithValue(
          MockEldTransport(
            time: buildTestTimeSource(DateTime.utc(2025, 5, 28, 19, 40)).time,
            scanDelay: Duration.zero,
            connectDelay: Duration.zero,
          ),
        ),
        eldDeviceStoreProvider.overrideWithValue(InMemoryEldDeviceStore()),
        authTokenRefreshClientProvider.overrideWithValue(
          _StubRefreshClient(
            () async => const RefreshRejected(
              ApiError(code: ApiErrorCode.tokenRevoked, message: 'token revoked'),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final RefreshOutcome outcome = await container
        .read(refreshCoordinatorProvider)
        .refresh(DriverSlot.primary);

    expect(outcome, isA<RefreshRejected>());
    // Bag: ilova tokensiz «login qilingan» holatda qolib ketardi.
    expect(container.read(sessionManagerProvider).isSignedOut, isTrue);
    expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
    expect(container.read(sessionEndReasonProvider), SessionEndReason.revoked);
    expect(storage.values[VaultKeys.refreshToken], isNull);
    expect(vault.accessToken(DriverSlot.primary), isNull);
  });
}

class _StubRefreshClient implements TokenRefreshClient {
  _StubRefreshClient(this._run);

  final Future<RefreshOutcome> Function() _run;

  @override
  Future<RefreshOutcome> refresh({required DriverSlot slot, required String refreshToken}) =>
      _run();
}
