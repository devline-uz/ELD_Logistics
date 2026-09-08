/// Drift ustun konvertorlari: murakkab tuzilmalar `TEXT` da JSON bo'lib yotadi (§5.1).
library;

import 'dart:convert';

import 'package:drift/drift.dart';

/// `List<String>` ↔ JSON massiv (`trailer_ids`, `shipping_doc_ids`, foto yo'llari).
class StringListConverter extends TypeConverter<List<String>, String>
    with JsonTypeConverter2<List<String>, String, Object?> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return const <String>[];
    }
    final Object? decoded = jsonDecode(fromDb);
    if (decoded is! List) {
      return const <String>[];
    }
    return decoded.whereType<Object>().map((Object e) => e.toString()).toList(growable: false);
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);

  @override
  List<String> fromJson(Object? json) => json is List
      ? json.whereType<Object>().map((Object e) => e.toString()).toList(growable: false)
      : const <String>[];

  @override
  Object? toJson(List<String> value) => value;
}

/// Ixtiyoriy JSON obyekt (`totals`, `counters`, `changes`, `diagnostics`).
///
/// Noto'g'ri JSON kelsa bo'sh map qaytariladi — pull qo'llash tranzaksiyasi
/// bitta buzuq maydon sababli yiqilmaydi.
class JsonMapConverter extends TypeConverter<Map<String, Object?>, String>
    with JsonTypeConverter2<Map<String, Object?>, String, Object?> {
  const JsonMapConverter();

  @override
  Map<String, Object?> fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      return const <String, Object?>{};
    }
    try {
      final Object? decoded = jsonDecode(fromDb);
      return decoded is Map<String, Object?> ? decoded : const <String, Object?>{};
    } on FormatException {
      return const <String, Object?>{};
    }
  }

  @override
  String toSql(Map<String, Object?> value) => jsonEncode(value);

  @override
  Map<String, Object?> fromJson(Object? json) =>
      json is Map<String, Object?> ? json : const <String, Object?>{};

  @override
  Object? toJson(Map<String, Object?> value) => value;
}
