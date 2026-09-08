/// Server JSON → DVIR domen modellari (M5: `data` qatlamida, UI ga chiqmaydi).
///
/// Maydon nomlari `contracts/swagger.json` dagi DTO'lardan olingan.
library;

import 'dart:convert';

import '../domain/defect_catalog.dart';
import '../domain/dvir_models.dart';
import '../domain/dvir_repository.dart';

List<DefectType> defectTypesFromJson(Map<String, dynamic>? envelope) {
  final List<dynamic> rows = (envelope?['data'] as List<dynamic>?) ?? const <dynamic>[];
  final List<DefectType> parsed = <DefectType>[];
  for (final dynamic row in rows) {
    if (row is! Map<String, dynamic>) {
      continue;
    }
    final String? id = row['id'] as String?;
    final String? name = row['name'] as String?;
    if (id == null || name == null) {
      continue;
    }
    parsed.add(
      DefectType(
        id: id,
        name: name,
        category: DefectCategory.fromWire(row['category'] as String?),
        isCritical: row['is_critical'] as bool? ?? false,
        sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      ),
    );
  }
  // #B-12: dublikat/`Refresh`/`Accident Photo` server javobida bo'lsa ham tozalanadi.
  return sanitizeDefectCatalog(parsed);
}

List<TrailerRef> trailersFromJson(Map<String, dynamic>? envelope) {
  final List<dynamic> rows = (envelope?['data'] as List<dynamic>?) ?? const <dynamic>[];
  return <TrailerRef>[
    for (final dynamic row in rows)
      if (row is Map<String, dynamic> && row['id'] is String)
        TrailerRef(id: row['id'] as String, number: row['number'] as String? ?? ''),
  ];
}

List<DvirReport> dvirReportsFromJson(Map<String, dynamic>? envelope) {
  final List<dynamic> rows = (envelope?['data'] as List<dynamic>?) ?? const <dynamic>[];
  final List<DvirReport> reports = <DvirReport>[];
  for (final dynamic row in rows) {
    final DvirReport? report = dvirReportFromJson(row as Map<String, dynamic>?);
    if (report != null) {
      reports.add(report);
    }
  }
  return reports;
}

DvirReport? dvirReportFromJson(Map<String, dynamic>? json) {
  if (json == null || json['id'] is! String) {
    return null;
  }
  return DvirReport(
    id: json['id'] as String,
    status: DvirStatus.fromWire(json['status'] as String?),
    kind: DvirKind.fromWire(json['kind'] as String?),
    type: DvirType.fromWire(json['type'] as String?),
    unitId: json['unit_id'] as String? ?? '',
    unitNumber: json['unit_number'] as String?,
    createdAt: _date(json['performed_at']) ?? _date(json['created_at']) ?? DateTime.utc(1970),
    locationText: json['location_text'] as String?,
    odometerMeters: (json['odometer_m'] as num?)?.toInt(),
    trailerIds: <String>[
      for (final dynamic id in (json['trailer_ids'] as List<dynamic>?) ?? const <dynamic>[])
        if (id is String) id,
    ],
    defects: _defects(json['defects']),
    notes: json['notes'] as String?,
    driverSignatureKey: json['driver_signature_key'] as String?,
    mechanicSignatureKey: json['mechanic_signature_key'] as String?,
    mechanicNote: json['mechanic_note'] as String?,
    hasCriticalDefect: json['has_critical_defect'] as bool? ?? false,
    outOfService: json['out_of_service'] as bool? ?? false,
    repairedAt: _date(json['repaired_at']),
    certifiedAt: _date(json['certified_at']),
  );
}

List<DvirReportDefect> _defects(Object? raw) {
  final List<dynamic> rows = (raw as List<dynamic>?) ?? const <dynamic>[];
  return <DvirReportDefect>[
    for (final dynamic row in rows)
      if (row is Map<String, dynamic>)
        DvirReportDefect(
          name: row['name'] as String? ?? '',
          category: DefectCategory.fromWire(row['category'] as String?),
          defectTypeId: row['defect_type_id'] as String?,
          note: row['note'] as String?,
          isCritical: row['is_critical'] as bool? ?? false,
          photoKeys: <String>[
            for (final dynamic key in (row['photo_keys'] as List<dynamic>?) ?? const <dynamic>[])
              if (key is String) key,
          ],
        ),
  ];
}

DateTime? _date(Object? raw) => raw is String ? DateTime.tryParse(raw)?.toUtc() : null;

/// `DvirCreate` tanasi (`POST /dvir-reports`).
///
/// **M164:** `company_id` yuborilmaydi — u kontekstdan olinadi.
Map<String, Object?> dvirCreateBody(DvirDraft draft) => <String, Object?>{
  'unit_id': draft.unitId,
  'type': draft.type.wire,
  'trailer_ids': draft.trailerIds,
  'driver_signature_key': draft.signatureKey ?? '',
  if (draft.notes != null && draft.notes!.trim().isNotEmpty) 'notes': draft.notes!.trim(),
  'defects': <Map<String, Object?>>[
    for (final DvirDefect defect in draft.allDefects)
      <String, Object?>{
        'defect_type_id': defect.type.id,
        if (defect.note != null && defect.note!.trim().isNotEmpty) 'note': defect.note!.trim(),
        if (defect.photoKeys.isNotEmpty) 'photo_keys': defect.photoKeys,
      },
  ],
};

// --- Lokal kesh (kv_settings) serializatsiyasi -----------------------------

/// [DefectType] → kesh JSON (server `DefectType` shakli bilan bir xil).
Map<String, Object?> defectTypeToCache(DefectType type) => <String, Object?>{
  'id': type.id,
  'name': type.name,
  'category': type.category.wire,
  'is_critical': type.isCritical,
  'sort_order': type.sortOrder,
};

/// Kesh JSON → katalog. Buzilgan kesh bo'sh ro'yxat beradi (fallback ishlaydi).
List<DefectType> defectTypesFromCache(String? raw) {
  if (raw == null || raw.isEmpty) {
    return const <DefectType>[];
  }
  try {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      return const <DefectType>[];
    }
    return defectTypesFromJson(<String, dynamic>{'data': decoded});
  } on FormatException {
    return const <DefectType>[];
  }
}

/// [DvirReport] → kesh JSON (`dvir_reports.payload` va KV uchun).
Map<String, Object?> dvirReportToCache(DvirReport report) => <String, Object?>{
  'id': report.id,
  'status': report.status.wire,
  'kind': report.kind?.wire,
  'type': report.type.wire,
  'unit_id': report.unitId,
  'unit_number': report.unitNumber,
  'performed_at': report.createdAt.toIso8601String(),
  'location_text': report.locationText,
  'odometer_m': report.odometerMeters,
  'trailer_ids': report.trailerIds,
  'notes': report.notes,
  'driver_signature_key': report.driverSignatureKey,
  'mechanic_signature_key': report.mechanicSignatureKey,
  'mechanic_note': report.mechanicNote,
  'has_critical_defect': report.hasCriticalDefect,
  'out_of_service': report.outOfService,
  'repaired_at': report.repairedAt?.toIso8601String(),
  'certified_at': report.certifiedAt?.toIso8601String(),
  'defects': <Map<String, Object?>>[
    for (final DvirReportDefect d in report.defects)
      <String, Object?>{
        'name': d.name,
        'category': d.category.wire,
        'defect_type_id': d.defectTypeId,
        'note': d.note,
        'is_critical': d.isCritical,
        'photo_keys': d.photoKeys,
      },
  ],
};

/// Kesh JSON ro'yxati → hisobotlar.
List<DvirReport> dvirReportsFromCache(String? raw) {
  if (raw == null || raw.isEmpty) {
    return const <DvirReport>[];
  }
  try {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      return const <DvirReport>[];
    }
    return dvirReportsFromJson(<String, dynamic>{'data': decoded});
  } on FormatException {
    return const <DvirReport>[];
  }
}
