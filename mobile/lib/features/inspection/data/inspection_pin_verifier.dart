/// `M-39 Exit inspection` PIN tekshiruvi.
///
/// Kiosk rejimi odatda **tarmoqsiz** ishlaydi (inspektor qurilmani ushlab
/// turadi), shuning uchun PIN lokal PBKDF2 hash bilan tekshiriladi (M16/M155).
/// `POST /auth/pin/verify` **ishlatilmaydi**: uning `action` enum'ida
/// (`switch_driver` / `return_to_truck`) inspection uchun qiymat yo'q va
/// `return_to_truck` pauza qilingan sessiyani tiklab yuboradi (nojo'ya ta'sir).
///
/// **S-H1 (fail-closed):** PIN o'rnatilmagan bo'lsa chiqish **rad etiladi**
/// ([InspectionPinNotSet]). Ilgari bunday holatda istalgan PIN qabul qilinardi
/// va inspektor kioskdan chiqib butun ilovaga kira olardi. TZ §4.5 bo'yicha PIN
/// invitation qabul qilishda o'rnatiladi — ya'ni normal oqimda u **doim** bor;
/// yo'qligi anomaliya va bloklash uchun asos (`PIN_NOT_SET` → PIN o'rnatish
/// ekrani, lekin kiosk ichida navigatsiya yo'q, shuning uchun oddiy rad javob).
///
/// **Urinishlar limiti (§4.5, §17.3):** 5 xato → 60 s blok, keyingi bosqichlar
/// eksponensial (5 daq, 25 daq). Blok holati [KvStore] da (shifrlangan Drift
/// bazasi) saqlanadi — ilovani o'chirib yoqish bilan tiklanmaydi.
///
/// TODO(core): PIN hash tekshiruvi `core/security` ga ko'chirilsa, bu adapter
/// o'sha xizmatga yupqa wrapper bo'lib qoladi.
library;

import '../../../core/db/kv_store.dart';
import '../../../core/security/pin_hasher.dart';
import '../../../core/security/secure_vault.dart';
import '../../../core/time/time_source.dart';
import '../domain/inspection_repository.dart';

/// Ketma-ket xato urinishlar chegarasi (§17.4 bilan bir xil).
const int kInspectionPinMaxAttempts = 5;

/// Blok muddatlari: 1-bosqich 60 s, keyin ×5 (5 daq, 25 daq — keyin cheklangan).
const List<Duration> kInspectionPinLockSteps = <Duration>[
  Duration(seconds: 60),
  Duration(minutes: 5),
  Duration(minutes: 25),
];

/// `kv_settings` kalitlari — blok ilovani qayta ishga tushirish bilan yechilmaydi.
abstract final class InspectionPinKeys {
  static const String failures = 'inspection.pin.failures';
  static const String lockLevel = 'inspection.pin.lock_level';
  static const String lockedUntil = 'inspection.pin.locked_until';
}

class LocalInspectionPinVerifier implements InspectionPinVerifier {
  LocalInspectionPinVerifier({
    required SecureVault vault,
    required TimeSource time,
    KvStore? store,
    int maxAttempts = kInspectionPinMaxAttempts,
  }) : this._(vault, time, store, maxAttempts);

  LocalInspectionPinVerifier._(this._vault, this._time, this._store, this.maxAttempts);

  final SecureVault _vault;
  final TimeSource _time;

  /// `null` — faqat xotirada hisoblanadi (test/diagnostika).
  final KvStore? _store;

  final int maxAttempts;

  int _failures = 0;
  int _lockLevel = 0;
  DateTime? _lockedUntil;
  bool _loaded = false;

  /// Test va diagnostika uchun: joriy xato urinishlar soni.
  int get failures => _failures;

  /// Blok tugash vaqti (UTC) yoki `null`.
  DateTime? get lockedUntil => _lockedUntil;

  @override
  Future<bool> verify(String pin) async {
    await _load();
    final DateTime now = _time.now();

    final DateTime? until = _lockedUntil;
    if (until != null) {
      if (until.isAfter(now)) {
        throw InspectionPinLocked(retryAfter: until.difference(now));
      }
      // Blok muddati o'tdi — yangi seriya boshlanadi, lekin bosqich saqlanadi
      // (keyingi blok uzunroq bo'ladi).
      _lockedUntil = null;
      _failures = 0;
      await _persist();
    }

    final ({String hash, String salt})? stored = await _vault.readPin();
    if (stored == null) {
      // S-H1: fail-closed. PIN yo'q ekan, kiosk rejimidan chiqib bo'lmaydi.
      throw const InspectionPinNotSet();
    }

    if (PinHasher.verify(pin: pin, salt: stored.salt, expectedHash: stored.hash)) {
      _failures = 0;
      _lockLevel = 0;
      _lockedUntil = null;
      await _persist();
      return true;
    }

    _failures++;
    if (_failures >= maxAttempts) {
      _failures = 0;
      _lockLevel++;
      final Duration step =
          kInspectionPinLockSteps[(_lockLevel - 1).clamp(0, kInspectionPinLockSteps.length - 1)];
      _lockedUntil = now.add(step);
      await _persist();
      throw InspectionPinLocked(retryAfter: step);
    }
    await _persist();
    return false;
  }

  Future<void> _load() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    final KvStore? store = _store;
    if (store == null) {
      return;
    }
    final Map<String, String> values = await store.readAll(<String>[
      InspectionPinKeys.failures,
      InspectionPinKeys.lockLevel,
      InspectionPinKeys.lockedUntil,
    ]);
    _failures = int.tryParse(values[InspectionPinKeys.failures] ?? '') ?? 0;
    _lockLevel = int.tryParse(values[InspectionPinKeys.lockLevel] ?? '') ?? 0;
    _lockedUntil = DateTime.tryParse(values[InspectionPinKeys.lockedUntil] ?? '')?.toUtc();
  }

  Future<void> _persist() async {
    final KvStore? store = _store;
    if (store == null) {
      return;
    }
    // `writeAll` bo'sh qiymatni yozmaydi, shuning uchun tozalash uchun `'0'`/`''`
    // o'rniga aniq qiymatlar beriladi.
    await store.writeAll(<String, String?>{
      InspectionPinKeys.failures: '$_failures',
      InspectionPinKeys.lockLevel: '$_lockLevel',
      InspectionPinKeys.lockedUntil: _lockedUntil?.toUtc().toIso8601String() ?? '-',
    });
  }
}
