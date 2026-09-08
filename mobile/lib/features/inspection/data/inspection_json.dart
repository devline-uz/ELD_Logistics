/// `swagger.json` JSON ↔ inspection domen modellari.
///
/// Bu qatlamdan tashqarida server maydon nomlari ishlatilmaydi (M5).
library;

import 'package:hos_engine/hos_engine.dart';

import '../../../core/time/day_boundary.dart';
import '../domain/inspection_models.dart';

Map<String, dynamic>? _map(Object? value) => value is Map<String, dynamic> ? value : null;

List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList(growable: false)
    : const <Map<String, dynamic>>[];

String? _string(Object? value) => value is String && value.isNotEmpty ? value : null;

int? _int(Object? value) => value is num ? value.toInt() : null;

DateTime? _time(Object? value) {
  final String? raw = _string(value);
  return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
}

/// `yyyy-MM-dd` — kun (UTC yarim tunda, faqat kalendar kun ma'nosida).
DateTime? parseServerLogDate(Object? value) {
  final String? raw = _string(value);
  if (raw == null || raw.length < 10) {
    return null;
  }
  return DateTime.tryParse('${raw.substring(0, 10)}T00:00:00Z')?.toUtc();
}

/// `yyyy-MM-dd` so'rov parametri — yagona manba `core/time/day_boundary.dart`.
String logDateParam(DateTime value) => formatLogDate(value);

List<String> _numbers(Object? value, String field) => <String>[
  for (final Map<String, dynamic> item in _list(value))
    if (_string(item[field]) case final String number) number,
];

InspectionSession? inspectionSessionFromJson(Map<String, dynamic>? json) {
  final Map<String, dynamic>? data = _map(json?['data']) ?? json;
  final String? token = _string(data?['token']);
  final DateTime? expiresAt = _time(data?['expires_at']);
  if (token == null || expiresAt == null) {
    return null;
  }
  return InspectionSession(
    token: token,
    expiresAt: expiresAt,
    driverId: _string(data?['driver_id']),
    driverName: _string(data?['driver_name']),
  );
}

InspectionEvent? inspectionEventFromJson(Map<String, dynamic> json) {
  final DateTime? at = _time(json['event_time']);
  final DutyStatus? status = DutyStatus.tryParse(_string(json['status']));
  if (at == null || status == null) {
    return null;
  }
  return InspectionEvent(
    at: at,
    status: status,
    locationText: _string(json['location_text']),
    odometerMeters: _int(json['odometer_m']),
    note: _string(json['notes']),
  );
}

InspectionLogForm inspectionLogFormFromJson(Map<String, dynamic>? json) => InspectionLogForm(
  driverName: _string(json?['driver_name']),
  coDriverName: _string(json?['co_driver_name']),
  carrierName: _string(json?['carrier_name']),
  homeTerminalAddress: _string(json?['home_terminal_address']),
  unitNumbers: _numbers(json?['units'], 'unit_number'),
  trailerNumbers: _numbers(json?['trailers'], 'number'),
  shippingDocs: _numbers(json?['shipping_docs'], 'number'),
  distanceMeters: _int(json?['distance_m']),
);

InspectionDay? inspectionDayFromJson(Map<String, dynamic> json, {String fallbackTimezone = ''}) {
  final DateTime? date = parseServerLogDate(json['log_date']);
  if (date == null) {
    return null;
  }
  final List<InspectionEvent> events = <InspectionEvent>[
    for (final Map<String, dynamic> item in _list(json['events']))
      if (inspectionEventFromJson(item) case final InspectionEvent event) event,
  ]..sort((InspectionEvent a, InspectionEvent b) => a.at.compareTo(b.at));

  return InspectionDay(
    date: date,
    timezone: _string(json['timezone']) ?? fallbackTimezone,
    certification: InspectionCertification.fromWire(_string(json['certification_status'])),
    distanceMeters: _int(json['distance_m']) ?? 0,
    form: inspectionLogFormFromJson(_map(json['form'])),
    events: events,
    signedAt: _time(json['signed_at']),
  );
}

InspectionReport? inspectionReportFromJson(Map<String, dynamic>? json) {
  final Map<String, dynamic>? data = _map(json?['data']) ?? json;
  if (data == null) {
    return null;
  }
  final String timezone = _string(data['timezone']) ?? '';
  final List<InspectionDay> days = <InspectionDay>[
    for (final Map<String, dynamic> item in _list(data['days']))
      if (inspectionDayFromJson(item, fallbackTimezone: timezone) case final InspectionDay day) day,
  ]..sort((InspectionDay a, InspectionDay b) => a.date.compareTo(b.date));

  final DateTime? from = parseServerLogDate(data['from']);
  final DateTime? to = parseServerLogDate(data['to']);
  if (from == null || to == null) {
    return null;
  }

  return InspectionReport(
    from: from,
    to: to,
    days: days,
    driverId: _string(data['driver_id']),
    driverName: _string(data['driver_name']),
    carrierName: _string(data['carrier_name']),
    homeTerminalAddress: _string(data['home_terminal_address']),
    timezone: _string(data['timezone']),
    regulationProfile: _string(data['regulation_profile']),
    generatedAt: _time(data['generated_at']),
  );
}

InspectionTransferResult inspectionTransferFromJson(Map<String, dynamic>? json) {
  final Map<String, dynamic>? data = _map(json?['data']) ?? json;
  return InspectionTransferResult(
    format: InspectionOutputFormat.fromWire(_string(data?['format'])),
    fileKey: _string(data?['file_key']),
    regulationProfile: _string(data?['regulation_profile']),
    sizeBytes: _int(data?['size_bytes']),
    generatedAt: _time(data?['generated_at']),
  );
}
