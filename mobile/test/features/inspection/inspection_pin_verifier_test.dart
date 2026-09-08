/// S-H1: kiosk (`M-39`) chiqish PIN'i — fail-closed va lockout.
@Timeout(Duration(seconds: 60))
library;

import 'package:eld_mobile/core/db/kv_store.dart';
import 'package:eld_mobile/core/security/pin_hasher.dart';
import 'package:eld_mobile/core/security/secure_vault.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/inspection/data/inspection_pin_verifier.dart';
import 'package:eld_mobile/features/inspection/domain/inspection_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late _MemoryStorage storage;
  late SecureVault vault;
  late TimeSource time;
  late FakeWallClock clock;
  late InMemoryKvStore store;

  setUp(() {
    storage = _MemoryStorage();
    vault = SecureVault(storage: storage);
    final ({FakeWallClock clock, TimeSource time}) built = buildTestTimeSource(t0);
    time = built.time;
    clock = built.clock;
    store = InMemoryKvStore();
  });

  tearDown(() async => time.dispose());

  LocalInspectionPinVerifier build() =>
      LocalInspectionPinVerifier(vault: vault, time: time, store: store);

  Future<void> setPin(String pin) async {
    const String salt = 'a1b2c3d4e5f60718293a4b5c6d7e8f90';
    await vault.writePin(
      hash: PinHasher.hash(pin: pin, salt: salt),
      salt: salt,
    );
  }

  test('S-H1: PIN o\'rnatilmagan bo\'lsa chiqish RAD ETILADI (fail-open emas)', () async {
    final LocalInspectionPinVerifier verifier = build();

    await expectLater(verifier.verify('123456'), throwsA(isA<InspectionPinNotSet>()));
    // Mavjud `on InspectionPinLocked` tutqichlari uni ham qamrab oladi.
    await expectLater(verifier.verify('000000'), throwsA(isA<InspectionPinLocked>()));
  });

  test('to\'g\'ri PIN chiqishga ruxsat beradi, xato PIN — yo\'q', () async {
    await setPin('427193');
    final LocalInspectionPinVerifier verifier = build();

    expect(await verifier.verify('000000'), isFalse);
    expect(await verifier.verify('427193'), isTrue);
    expect(verifier.failures, 0);
  });

  test('5 ta xato urinishdan keyin 60 s blok', () async {
    await setPin('427193');
    final LocalInspectionPinVerifier verifier = build();

    for (int i = 0; i < kInspectionPinMaxAttempts - 1; i++) {
      expect(await verifier.verify('000000'), isFalse);
    }
    await expectLater(verifier.verify('000000'), throwsA(isA<InspectionPinLocked>()));

    // Blok davomida **to'g'ri** PIN ham qabul qilinmaydi.
    await expectLater(verifier.verify('427193'), throwsA(isA<InspectionPinLocked>()));
    expect(verifier.lockedUntil, t0.add(const Duration(seconds: 60)));
  });

  test('blok muddati o\'tgach qayta urinish mumkin', () async {
    await setPin('427193');
    final LocalInspectionPinVerifier verifier = build();

    for (int i = 0; i < kInspectionPinMaxAttempts - 1; i++) {
      await verifier.verify('000000');
    }
    await expectLater(verifier.verify('000000'), throwsA(isA<InspectionPinLocked>()));

    clock.advance(const Duration(seconds: 61));
    expect(await verifier.verify('427193'), isTrue);
  });

  test('ketma-ket bloklar eksponensial uzayadi (60 s -> 5 daq)', () async {
    await setPin('427193');
    final LocalInspectionPinVerifier verifier = build();

    Future<void> failSeries() async {
      for (int i = 0; i < kInspectionPinMaxAttempts - 1; i++) {
        await verifier.verify('000000');
      }
    }

    await failSeries();
    await expectLater(
      verifier.verify('000000'),
      throwsA(
        isA<InspectionPinLocked>().having(
          (InspectionPinLocked e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 60),
        ),
      ),
    );

    clock.advance(const Duration(seconds: 61));
    await failSeries();
    await expectLater(
      verifier.verify('000000'),
      throwsA(
        isA<InspectionPinLocked>().having(
          (InspectionPinLocked e) => e.retryAfter,
          'retryAfter',
          const Duration(minutes: 5),
        ),
      ),
    );
  });

  test('blok ilovani qayta ishga tushirish bilan tiklanmaydi (KvStore)', () async {
    await setPin('427193');
    final LocalInspectionPinVerifier first = build();
    for (int i = 0; i < kInspectionPinMaxAttempts - 1; i++) {
      await first.verify('000000');
    }
    await expectLater(first.verify('000000'), throwsA(isA<InspectionPinLocked>()));

    // Yangi instans = ilova qayta ishga tushdi; holat `kv_settings` dan tiklanadi.
    final LocalInspectionPinVerifier restarted = build();
    await expectLater(restarted.verify('427193'), throwsA(isA<InspectionPinLocked>()));
  });

  test('muvaffaqiyatli tekshiruv blok bosqichini nolga qaytaradi', () async {
    await setPin('427193');
    final LocalInspectionPinVerifier verifier = build();

    await verifier.verify('000000');
    await verifier.verify('000000');
    expect(await verifier.verify('427193'), isTrue);
    expect(verifier.failures, 0);
    expect(verifier.lockedUntil, isNull);

    final LocalInspectionPinVerifier restarted = build();
    expect(await restarted.verify('427193'), isTrue);
  });
}

/// Xotiradagi `FlutterSecureStorage` — Keychain/Keystore ga tegilmaydi.
class _MemoryStorage implements FlutterSecureStorage {
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
