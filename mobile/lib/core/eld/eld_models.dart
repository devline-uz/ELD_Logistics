/// ELD qurilmasi bilan almashinadigan qiymat obyektlari (tz-mobile §10).
///
/// Bu tiplar **vendor-neytral**: `flutter_blue_plus` yoki platform channel
/// tiplari hech qachon bu qatlamdan yuqoriga chiqmaydi (M79).
library;

import 'eld_codes.dart';

/// Banner holatlari (tz-mobile §10.1 jadvali, M68).
enum EldConnectionState {
  /// `ELD · Not connected` — Error.
  notConnected,

  /// `ELD · Connecting…` — Warning.
  connecting,

  /// `ELD · Connected` — Success.
  connected,

  /// `ELD diagnostic event` — Warning.
  diagnostic,

  /// `ELD malfunction (<kod>) — keep paper logs` — Error, dismiss yo'q.
  malfunction;

  bool get isConnected => this == connected || this == diagnostic || this == malfunction;
}

/// Skan natijasidagi qurilma.
class EldDeviceRef {
  const EldDeviceRef({required this.id, required this.name, this.rssi});

  /// Android — MAC, iOS — CoreBluetooth UUID.
  final String id;
  final String name;

  /// dBm. `< -90` bo'lsa UI ogohlantiradi (§10.3 `[MAY]`).
  final int? rssi;

  /// Zaif signal chegarasi (tz-mobile §10.3).
  static const int weakRssiDbm = -90;

  bool get isWeakSignal => rssi != null && rssi! < weakRssiDbm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EldDeviceRef && other.id == id && other.name == name && other.rssi == rssi;

  @override
  int get hashCode => Object.hash(id, name, rssi);

  @override
  String toString() => 'EldDeviceRef($id, $name, $rssi)';
}

/// Handshake natijasi (§10.3): firmware, VIN, RTC, odometer, engine hours.
class EldHandshake {
  const EldHandshake({
    required this.deviceId,
    required this.firmware,
    required this.rtcUtc,
    this.vin,
    this.serial,
    this.odometerM,
    this.engineHours,
  });

  final String deviceId;
  final String firmware;

  /// **M71:** har handshake'da `TimeSource.syncFromEldRtc` ga beriladi.
  final DateTime rtcUtc;

  /// Qurilma o'qigan VIN; unit VIN bilan solishtiriladi.
  final String? vin;
  final String? serial;
  final int? odometerM;
  final double? engineHours;

  @override
  String toString() => 'EldHandshake($deviceId, fw=$firmware, rtc=$rtcUtc)';
}

/// VIN mosligi natijasi — mos kelmasa ulanish **bloklanmaydi**, ogohlantiriladi.
enum VinMatchResult {
  /// Ikkala VIN bor va bir xil.
  match,

  /// Ikkala VIN bor, lekin farq qiladi — ogohlantirish.
  mismatch,

  /// ELD yoki unit VIN si yo'q — tekshirib bo'lmadi.
  unknown;

  bool get isWarning => this == mismatch;
}

/// VIN ni normalizatsiya qilib solishtiradi (probel/registr farqi hisobga olinmaydi).
VinMatchResult matchVin({required String? eldVin, required String? unitVin}) {
  final String a = (eldVin ?? '').replaceAll(RegExp(r'\s'), '').toUpperCase();
  final String b = (unitVin ?? '').replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (a.isEmpty || b.isEmpty) {
    return VinMatchResult.unknown;
  }
  return a == b ? VinMatchResult.match : VinMatchResult.mismatch;
}

/// Qurilmadan keladigan telemetriya kadri.
class EldTelemetryFrame {
  const EldTelemetryFrame({
    required this.at,
    required this.speedKmh,
    this.lat,
    this.lng,
    this.gpsAccuracyM,
    this.odometerM,
    this.engineHours,
    this.ignition,
    this.batteryVoltage,
    this.headingDeg,
    this.faults = const <EldFaultCode>[],
    this.fromEldGps = true,
  });

  /// UTC (`TimeSource` yoki ELD RTC).
  final DateTime at;

  /// ECM/GPS tezligi, km/soat. Auto-DR manbai (M56).
  final double speedKmh;

  final double? lat;
  final double? lng;
  final double? gpsAccuracyM;
  final int? odometerM;
  final double? engineHours;
  final bool? ignition;
  final double? batteryVoltage;
  final double? headingDeg;

  /// Kadrga biriktirilgan aktiv kodlar (`diagnostics[]`).
  final List<EldFaultCode> faults;

  /// `false` — koordinata telefon GPS idan olingan (ELD lat/lng bermadi).
  final bool fromEldGps;

  bool get hasPosition => lat != null && lng != null;

  @override
  String toString() => 'EldTelemetryFrame($at, ${speedKmh}km/h, gps=$hasPosition)';
}

/// ELD buferidagi event turi (M72).
enum EldBufferedEventType {
  powerOn('power_on'),
  powerOff('power_off'),
  motionStart('motion_start'),
  motionStop('motion_stop'),
  malfunction('malfunction'),
  diagnostic('diagnostic');

  const EldBufferedEventType(this.wire);

  /// `duty_events.event_type` / outbox payload qiymati.
  final String wire;
}

/// Qurilma oflayn yozgan event (§10.3 M72).
class EldBufferedEvent {
  const EldBufferedEvent({
    required this.eldSeq,
    required this.type,
    required this.recordedAt,
    this.vendorEventId,
    this.lat,
    this.lng,
    this.odometerM,
    this.engineHours,
    this.speedKmh,
    this.faultCode,
  });

  /// Qurilmaning monoton navbat raqami — `client_event_id` ning bir qismi.
  final int eldSeq;

  final EldBufferedEventType type;

  /// Qurilma RTC si bo'yicha UTC.
  final DateTime recordedAt;

  /// Vendor barqaror ID bersa — o'sha ishlatiladi; aks holda `null`.
  final String? vendorEventId;

  final double? lat;
  final double? lng;
  final int? odometerM;
  final double? engineHours;
  final double? speedKmh;
  final EldFaultCode? faultCode;

  @override
  String toString() => 'EldBufferedEvent(#$eldSeq, ${type.wire}, $recordedAt)';
}

/// Transport darajasidagi xato — UI ga faqat shu tip chiqadi.
class EldTransportException implements Exception {
  const EldTransportException(this.reason, {this.detail});

  final EldTransportFailure reason;
  final String? detail;

  @override
  String toString() => 'EldTransportException(${reason.name}, $detail)';
}

/// Xato sabablari — `core/error` mappingiga o'xshash yopiq ro'yxat.
enum EldTransportFailure {
  bluetoothOff,
  permissionDenied,
  notFound,
  connectTimeout,
  handshakeFailed,
  disconnected,
  unsupported,
}
