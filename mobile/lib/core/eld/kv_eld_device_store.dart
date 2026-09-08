/// Oxirgi ELD qurilma ID sini `kv_settings` da saqlaydigan ombor
/// ([EldDeviceStore] implementatsiyasi, tz-mobile §10.3).
///
/// `core/eld` `core/db` ga bog'lanadi (`eld_buffer_importer.dart` bilan bir
/// xil yo'nalish) — `features/*` ga emas, shuning uchun qatlam qoidasi (M5)
/// buzilmaydi.
library;

import '../db/daos/settings_dao.dart';
import '../time/time_source.dart';
import 'eld_connection_manager.dart';

/// `kv_settings` kaliti. `KvKeys` `core/db` hududida bo'lgani uchun ELD
/// moduli o'z kalitini shu yerda e'lon qiladi.
const String kEldLastDeviceIdKey = 'eld_last_device_id';

class KvEldDeviceStore implements EldDeviceStore {
  const KvEldDeviceStore({required SettingsDao settings, required TimeSource time})
    // ignore: prefer_initializing_formals
    : _settings = settings,
      // ignore: prefer_initializing_formals
      _time = time;

  final SettingsDao _settings;
  final TimeSource _time;

  @override
  Future<String?> lastDeviceId() async {
    final String? value = await _settings.get(kEldLastDeviceIdKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  Future<void> saveLastDeviceId(String id) =>
      _settings.put(key: kEldLastDeviceIdKey, value: id, now: _time.now());

  @override
  Future<void> forget() => _settings.remove(kEldLastDeviceIdKey);
}
