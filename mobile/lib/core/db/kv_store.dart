/// `kv_settings` ustidagi yupqa, DB'ga bog'liq bo'lmagan abstraksiya.
///
/// Nega kerak: tema/zoom (M94) va sessiya profili (`driver_id`, `unit_number`, …)
/// **sinxron** provayderlardan o'qiladi, lekin manba — asinxron Drift jadvali.
/// [KvStore] shu ikki dunyoni ajratadi va testlarda (Drift ochilmagan holatda)
/// `InMemoryKvStore` bilan almashtiriladi — provayder daraxti yiqilmaydi.
library;

import 'daos/settings_dao.dart';

abstract interface class KvStore {
  Future<String?> read(String key);

  Future<Map<String, String>> readAll(Iterable<String> keys);

  Future<void> write(String key, String value);

  /// Bo'sh qiymatlar **yozilmaydi** — mavjud qiymat tasodifan o'chib ketmasin.
  Future<void> writeAll(Map<String, String?> values);
}

/// Drift `kv_settings` ustidagi implementatsiya (bootstrap'da ulanadi).
class DriftKvStore implements KvStore {
  const DriftKvStore({required SettingsDao settings, required DateTime Function() now})
    : this._(settings, now);

  const DriftKvStore._(this._settings, this._now);

  final SettingsDao _settings;
  final DateTime Function() _now;

  @override
  Future<String?> read(String key) => _settings.get(key);

  @override
  Future<Map<String, String>> readAll(Iterable<String> keys) async {
    final Map<String, String> out = <String, String>{};
    for (final String key in keys) {
      final String? value = await _settings.get(key);
      if (value != null && value.isNotEmpty) {
        out[key] = value;
      }
    }
    return out;
  }

  @override
  Future<void> write(String key, String value) =>
      _settings.put(key: key, value: value, now: _now());

  @override
  Future<void> writeAll(Map<String, String?> values) async {
    final DateTime now = _now();
    for (final MapEntry<String, String?> entry in values.entries) {
      final String? value = entry.value;
      if (value == null || value.isEmpty) {
        continue;
      }
      await _settings.put(key: entry.key, value: value, now: now);
    }
  }
}

/// Testlar va bootstrap'gacha bo'lgan oraliq uchun xotiradagi do'kon.
class InMemoryKvStore implements KvStore {
  InMemoryKvStore([Map<String, String>? seed]) : _values = <String, String>{...?seed};

  final Map<String, String> _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<Map<String, String>> readAll(Iterable<String> keys) async => <String, String>{
    for (final String key in keys)
      if (_values[key] case final String value when value.isNotEmpty) key: value,
  };

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> writeAll(Map<String, String?> values) async {
    for (final MapEntry<String, String?> entry in values.entries) {
      final String? value = entry.value;
      if (value != null && value.isNotEmpty) {
        _values[entry.key] = value;
      }
    }
  }
}
