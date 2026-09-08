/// `kv_settings` va `sync_cursor` DAO'si — `device_seq` atomikligi (M20, M28, M35).
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

part 'settings_dao.g.dart';

/// `kv_settings` kalitlari — string literal tarqatish taqiq.
abstract final class KvKeys {
  const KvKeys._();

  /// Barqaror qurilma identifikatori (UUID v4). Qayta o'rnatishda yangilanadi.
  static const String deviceId = 'device_id';

  /// Monoton o'suvchi navbat raqami (M20).
  static const String deviceSeq = 'device_seq';

  /// Home Terminal IANA TZ — kun chegarasi uchun (M42).
  static const String homeTerminalTz = 'home_terminal_tz';

  /// Oxirgi ishonchli server vaqti (ISO-8601 UTC) — `TimeSource` uchun.
  static const String lastServerTime = 'last_server_time';

  /// Oxirgi ishonchli server vaqtidagi monoton soat qiymati (mikrosekund).
  static const String lastServerMonotonic = 'last_server_monotonic';

  static const String themeMode = 'theme_mode';
  static const String textScale = 'text_scale';
  static const String locale = 'locale';
  static const String lastTrailerIds = 'last_trailer_ids';

  // --- Sessiya profili (login javobi + `sync/pull` yozadi) -------------------
  //
  // Qiymatlar `features/duty_status/data/DutyKvKeys` bilan **bir xil**; core
  // features'ga import qila olmaydi (M5), shuning uchun kalitlar shu yerda
  // takrorlanadi. Ikkala ro'yxat ham bir xil satrlarni ishlatadi.

  static const String driverId = 'driver_id';
  static const String driverName = 'driver_name';
  static const String driverEmail = 'driver_email';
  static const String driverPhone = 'driver_phone';
  static const String driverLicense = 'driver_license';
  static const String driverLicenseState = 'driver_license_state';
  static const String unitId = 'unit_id';
  static const String unitNumber = 'unit_number';
  static const String vehicleLabel = 'vehicle_label';
  static const String carrierName = 'carrier_name';
  static const String homeTerminalAddress = 'home_terminal_address';

  /// Sessiya profiliga tegishli barcha kalitlar (bir marta o'qish uchun).
  static const List<String> sessionProfile = <String>[
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
  ];
}

/// `sync_cursor` yagona qatorining id si.
const int kSyncCursorId = 1;

@DriftAccessor(tables: <Type>[KvSettings, SyncCursorTable])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  // --- kv_settings --------------------------------------------------------

  Future<String?> get(String key) async {
    final KvSettingRow? row = await (select(
      kvSettings,
    )..where((KvSettings t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watch(String key) =>
      (select(kvSettings)..where((KvSettings t) => t.key.equals(key))).watchSingleOrNull().map(
        (KvSettingRow? row) => row?.value,
      );

  Future<void> put({required String key, required String value, required DateTime now}) => into(
    kvSettings,
  ).insertOnConflictUpdate(KvSettingsCompanion.insert(key: key, value: value, updatedAt: now));

  Future<void> remove(String key) =>
      (delete(kvSettings)..where((KvSettings t) => t.key.equals(key))).go();

  /// **M20:** `device_seq` ni **bitta atomik statement** bilan oshiradi.
  ///
  /// Alohida `SELECT` + `UPDATE` taqiqlanadi: parallel yozuvchilar bir xil
  /// raqamni olishi mumkin edi. `INSERT … ON CONFLICT DO UPDATE … RETURNING`
  /// birinchi chaqiruvda 1 dan boshlaydi va keyin monoton o'sadi.
  Future<int> nextDeviceSeq(DateTime now) async {
    final List<QueryRow> rows = await customWriteReturning(
      'INSERT INTO kv_settings (key, value, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(key) DO UPDATE SET '
      'value = CAST(CAST(kv_settings.value AS INTEGER) + 1 AS TEXT), '
      'updated_at = excluded.updated_at '
      'RETURNING value',
      variables: <Variable<Object>>[
        const Variable<String>(KvKeys.deviceSeq),
        const Variable<String>('1'),
        Variable<DateTime>(now),
      ],
      updates: <TableInfo<Table, Object>>{kvSettings},
      updateKind: UpdateKind.insert,
    );
    final String raw = rows.single.read<String>('value');
    final int? parsed = int.tryParse(raw);
    if (parsed == null) {
      throw StateError('kv_settings.device_seq buzilgan: "$raw"');
    }
    return parsed;
  }

  /// Joriy `device_seq` (hech qachon oshirmaydi) — diagnostika uchun.
  Future<int> currentDeviceSeq() async => int.tryParse(await get(KvKeys.deviceSeq) ?? '0') ?? 0;

  // --- sync_cursor --------------------------------------------------------

  Stream<SyncCursorRow?> watchCursor() => (select(
    syncCursorTable,
  )..where((SyncCursorTable t) => t.id.equals(kSyncCursorId))).watchSingleOrNull();

  Future<SyncCursorRow?> cursor() => (select(
    syncCursorTable,
  )..where((SyncCursorTable t) => t.id.equals(kSyncCursorId))).getSingleOrNull();

  /// M35: kursor **faqat** pull tranzaksiyasi to'liq yozilgandan keyin yangilanadi.
  Future<void> setNextSince(String nextSince) =>
      _updateCursor(SyncCursorTableCompanion(nextSince: Value<String>(nextSince)));

  Future<void> markPush(DateTime at) =>
      _updateCursor(SyncCursorTableCompanion(lastPushAt: Value<DateTime>(at)));

  Future<void> markPull(DateTime at) =>
      _updateCursor(SyncCursorTableCompanion(lastPullAt: Value<DateTime>(at)));

  Future<void> markError({required String code, required DateTime at}) => _updateCursor(
    SyncCursorTableCompanion(lastError: Value<String>(code), lastErrorAt: Value<DateTime>(at)),
  );

  /// Sessiya almashganda kursor nolga qaytadi: yangi haydovchi o'z oynasini
  /// boshidan tortadi (S-M4 + M35).
  Future<void> resetCursor() => _updateCursor(
    const SyncCursorTableCompanion(
      nextSince: Value<String?>(null),
      lastPushAt: Value<DateTime?>(null),
      lastPullAt: Value<DateTime?>(null),
      lastError: Value<String?>(null),
      lastErrorAt: Value<DateTime?>(null),
    ),
  );

  Future<void> clearError() => _updateCursor(
    const SyncCursorTableCompanion(
      lastError: Value<String?>(null),
      lastErrorAt: Value<DateTime?>(null),
    ),
  );

  Future<void> _updateCursor(SyncCursorTableCompanion patch) async {
    final int changed = await (update(
      syncCursorTable,
    )..where((SyncCursorTable t) => t.id.equals(kSyncCursorId))).write(patch);
    if (changed == 0) {
      await into(syncCursorTable).insert(
        patch.copyWith(id: const Value<int>(kSyncCursorId)),
        mode: InsertMode.insertOrReplace,
      );
    }
  }
}
