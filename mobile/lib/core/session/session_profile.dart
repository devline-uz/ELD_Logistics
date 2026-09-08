/// Joriy sessiya profili — `kv_settings` ustidagi sinxron ko'rinish.
///
/// Manbalar (tz-mobile §4.3, §6.2):
///  * **login / `GET /me`** → `driver_id`, `driver_name`, `driver_email`;
///  * **`GET /sync/pull`** → `home_terminal_tz` (kunlik loglar timezone'i) va
///    kunlik log formasi orqali `carrier_name`, `home_terminal_address`,
///    `unit_id`, `unit_number`, `vehicle_label`.
///
/// Home (`M-09`) va oflayn Inspection Log Form aynan shu kalitlardan o'qiydi;
/// ular yozilmasa ekranda «No unit assigned» / `N/A` chiqadi.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/daos/settings_dao.dart';
import '../db/kv_store.dart';

/// Sessiya profilining o'zgarmas kesimi.
class SessionProfile {
  const SessionProfile({
    this.driverId = '',
    this.driverName,
    this.driverEmail,
    this.driverPhone,
    this.driverLicense,
    this.driverLicenseState,
    this.unitId,
    this.unitNumber,
    this.vehicleLabel,
    this.carrierName,
    this.homeTerminalAddress,
    this.homeTerminalTz,
  });

  /// `kv_settings` xaritasidan o'qiydi (yo'q kalitlar `null` bo'lib qoladi).
  factory SessionProfile.fromKv(Map<String, String> values) => SessionProfile(
    driverId: values[KvKeys.driverId] ?? '',
    driverName: values[KvKeys.driverName],
    driverEmail: values[KvKeys.driverEmail],
    driverPhone: values[KvKeys.driverPhone],
    driverLicense: values[KvKeys.driverLicense],
    driverLicenseState: values[KvKeys.driverLicenseState],
    unitId: values[KvKeys.unitId],
    unitNumber: values[KvKeys.unitNumber],
    vehicleLabel: values[KvKeys.vehicleLabel],
    carrierName: values[KvKeys.carrierName],
    homeTerminalAddress: values[KvKeys.homeTerminalAddress],
    homeTerminalTz: values[KvKeys.homeTerminalTz],
  );

  final String driverId;
  final String? driverName;
  final String? driverEmail;
  final String? driverPhone;
  final String? driverLicense;
  final String? driverLicenseState;
  final String? unitId;
  final String? unitNumber;
  final String? vehicleLabel;
  final String? carrierName;
  final String? homeTerminalAddress;
  final String? homeTerminalTz;

  bool get isEmpty => driverId.isEmpty;

  /// `kv_settings` ga yoziladigan xarita; `null`/bo'sh qiymatlar tashlab
  /// yuboriladi ([KvStore.writeAll] mavjud qiymatni o'chirmaydi).
  Map<String, String?> toKv() => <String, String?>{
    KvKeys.driverId: driverId.isEmpty ? null : driverId,
    KvKeys.driverName: driverName,
    KvKeys.driverEmail: driverEmail,
    KvKeys.driverPhone: driverPhone,
    KvKeys.driverLicense: driverLicense,
    KvKeys.driverLicenseState: driverLicenseState,
    KvKeys.unitId: unitId,
    KvKeys.unitNumber: unitNumber,
    KvKeys.vehicleLabel: vehicleLabel,
    KvKeys.carrierName: carrierName,
    KvKeys.homeTerminalAddress: homeTerminalAddress,
    KvKeys.homeTerminalTz: homeTerminalTz,
  };

  /// Bo'sh bo'lmagan maydonlarni [patch] dan olib ustiga qo'yadi.
  SessionProfile merge(SessionProfile patch) => SessionProfile(
    driverId: patch.driverId.isEmpty ? driverId : patch.driverId,
    driverName: _pick(patch.driverName, driverName),
    driverEmail: _pick(patch.driverEmail, driverEmail),
    driverPhone: _pick(patch.driverPhone, driverPhone),
    driverLicense: _pick(patch.driverLicense, driverLicense),
    driverLicenseState: _pick(patch.driverLicenseState, driverLicenseState),
    unitId: _pick(patch.unitId, unitId),
    unitNumber: _pick(patch.unitNumber, unitNumber),
    vehicleLabel: _pick(patch.vehicleLabel, vehicleLabel),
    carrierName: _pick(patch.carrierName, carrierName),
    homeTerminalAddress: _pick(patch.homeTerminalAddress, homeTerminalAddress),
    homeTerminalTz: _pick(patch.homeTerminalTz, homeTerminalTz),
  );

  static String? _pick(String? next, String? current) =>
      next != null && next.isNotEmpty ? next : current;

  @override
  bool operator ==(Object other) =>
      other is SessionProfile &&
      other.driverId == driverId &&
      other.driverName == driverName &&
      other.driverEmail == driverEmail &&
      other.driverPhone == driverPhone &&
      other.driverLicense == driverLicense &&
      other.driverLicenseState == driverLicenseState &&
      other.unitId == unitId &&
      other.unitNumber == unitNumber &&
      other.vehicleLabel == vehicleLabel &&
      other.carrierName == carrierName &&
      other.homeTerminalAddress == homeTerminalAddress &&
      other.homeTerminalTz == homeTerminalTz;

  @override
  int get hashCode => Object.hash(
    driverId,
    driverName,
    driverEmail,
    driverPhone,
    driverLicense,
    driverLicenseState,
    unitId,
    unitNumber,
    vehicleLabel,
    carrierName,
    homeTerminalAddress,
    homeTerminalTz,
  );

  /// PII logga chiqmaydi (M159) — faqat `driver_id`.
  @override
  String toString() => 'SessionProfile($driverId)';
}

/// `kv_settings` ni o'qib/yozib turuvchi kontroller.
///
/// `build()` bo'sh profil qaytaradi va yuklashni fonda boshlaydi — provayder
/// sinxron, DB esa asinxron.
class SessionProfileNotifier extends Notifier<SessionProfile> {
  @override
  SessionProfile build() {
    unawaited(reload());
    return const SessionProfile();
  }

  KvStore get _store => ref.read(kvStoreProvider);

  Future<void> reload() async {
    final Map<String, String> values = await _store.readAll(KvKeys.sessionProfile);
    // `build()` bu ishni fonda boshlaydi: o'qish tugagunicha konteyner
    // tashlangan bo'lishi mumkin (sessiya tugadi, ilova yopildi, test
    // teardown'i). Bunda `state` ga yozish `Bad state` beradi.
    if (!ref.mounted || values.isEmpty) {
      return;
    }
    state = state.merge(SessionProfile.fromKv(values));
  }

  /// Login javobidan / pull dan kelgan bo'laklarni yozadi.
  Future<void> write(SessionProfile patch) async {
    final SessionProfile merged = state.merge(patch);
    if (merged == state) {
      return;
    }
    state = merged;
    await _store.writeAll(patch.toKv());
  }

  /// Chiqishda profil **o'chirilmaydi**: oflayn Inspection Log Form va Home
  /// keyingi loginigacha oxirgi ma'lum qiymatlarni ko'rsatishi kerak.
  void clearInMemory() => state = const SessionProfile();
}

/// `kv_settings` do'koni. Bootstrap `DriftKvStore` bilan override qiladi;
/// standart qiymat — testlar uchun xotiradagi do'kon.
final Provider<KvStore> kvStoreProvider = Provider<KvStore>((Ref ref) => InMemoryKvStore());

final NotifierProvider<SessionProfileNotifier, SessionProfile> sessionProfileProvider =
    NotifierProvider<SessionProfileNotifier, SessionProfile>(SessionProfileNotifier.new);
