import 'dart:async';

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/network/refresh_coordinator.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Xotiradagi soxta secure storage.
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

class _CountingRefreshClient implements TokenRefreshClient {
  _CountingRefreshClient({this.outcome});

  int calls = 0;
  final Completer<void> gate = Completer<void>();
  RefreshOutcome? outcome;

  @override
  Future<RefreshOutcome> refresh({required DriverSlot slot, required String refreshToken}) async {
    calls++;
    await gate.future;
    return outcome ??
        RefreshSucceeded(
          accessToken: 'access-$calls',
          refreshToken: 'refresh-$calls',
          expiresAt: DateTime.utc(2026, 9, 7, 12),
        );
  }
}

void main() {
  late _FakeStorage storage;
  late SecureVault vault;

  setUp(() {
    storage = _FakeStorage();
    vault = SecureVault(storage: storage);
  });

  test('parallel 401 lar bitta refresh chaqiruvini bo\'lishadi (mutex)', () async {
    storage.values[VaultKeys.refreshToken] = 'stored-refresh';
    final _CountingRefreshClient client = _CountingRefreshClient();
    final RefreshCoordinator coordinator = RefreshCoordinator(vault: vault, client: client);

    final List<Future<RefreshOutcome>> waiters = <Future<RefreshOutcome>>[
      coordinator.refresh(DriverSlot.primary),
      coordinator.refresh(DriverSlot.primary),
      coordinator.refresh(DriverSlot.primary),
    ];
    await Future<void>.delayed(Duration.zero);
    expect(coordinator.isRefreshing(DriverSlot.primary), isTrue);

    client.gate.complete();
    final List<RefreshOutcome> results = await Future.wait(waiters);

    expect(client.calls, 1, reason: 'faqat bitta POST /auth/refresh');
    expect(results.every((RefreshOutcome o) => o is RefreshSucceeded), isTrue);
    expect(vault.accessToken(DriverSlot.primary), 'access-1');
    // Rotatsiya: eski refresh token yangisi bilan almashtirilgan.
    expect(storage.values[VaultKeys.refreshToken], 'refresh-1');
    expect(coordinator.isRefreshing(DriverSlot.primary), isFalse);
  });

  test('slotlar mustaqil: co-driver alohida refresh qiladi', () async {
    storage.values[VaultKeys.refreshToken] = 'primary';
    storage.values[VaultKeys.refreshTokenCoDriver] = 'co';
    final _CountingRefreshClient client = _CountingRefreshClient();
    final RefreshCoordinator coordinator = RefreshCoordinator(vault: vault, client: client);

    final Future<RefreshOutcome> a = coordinator.refresh(DriverSlot.primary);
    final Future<RefreshOutcome> b = coordinator.refresh(DriverSlot.coDriver);
    client.gate.complete();
    await Future.wait(<Future<RefreshOutcome>>[a, b]);

    expect(client.calls, 2);
  });

  test('TOKEN_REVOKED sessiyani tozalaydi va outbox tegilmaydi', () async {
    storage.values[VaultKeys.refreshToken] = 'stored-refresh';
    storage.values[VaultKeys.deviceId] = 'device-1';
    final _CountingRefreshClient client = _CountingRefreshClient(
      outcome: const RefreshRejected(ApiError(code: ApiErrorCode.tokenRevoked, message: 'revoked')),
    );
    DriverSlot? terminated;
    final RefreshCoordinator coordinator = RefreshCoordinator(
      vault: vault,
      client: client,
      onSessionTerminated: (DriverSlot slot, ApiError error) async {
        terminated = slot;
      },
    );

    client.gate.complete();
    final RefreshOutcome outcome = await coordinator.refresh(DriverSlot.primary);

    expect(outcome, isA<RefreshRejected>());
    expect(terminated, DriverSlot.primary);
    expect(storage.values.containsKey(VaultKeys.refreshToken), isFalse);
    expect(storage.values['device.id'], 'device-1');
  });

  test('refresh token yo\'q bo\'lsa darhol rad etiladi', () async {
    final _CountingRefreshClient client = _CountingRefreshClient();
    final RefreshCoordinator coordinator = RefreshCoordinator(vault: vault, client: client);

    final RefreshOutcome outcome = await coordinator.refresh(DriverSlot.primary);

    expect(outcome, isA<RefreshRejected>());
    expect(client.calls, 0);
  });

  test('device_id barqaror va faqat bir marta generatsiya qilinadi', () async {
    final String first = await vault.deviceId();
    final String second = await vault.deviceId();

    expect(first, second);
    expect(
      first,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
          r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}
