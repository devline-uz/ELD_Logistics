/// BLE GATT profili va kadr kodeki.
///
/// ❓ **M80:** ELD qurilma modeli hali tanlanmagan. Shu sababli UUID lar va
/// kadr formati **vaqtinchalik** — model tanlangach faqat shu fayl
/// almashtiriladi ([EldTransport] shartnomasi o'zgarmaydi, risk R2).
///
/// Kadr formati: UTF-8 JSON obyekt, har notification bitta to'liq obyekt.
/// Vendor binar format bersa — [EldFrameCodec] ning ikkita metodi qayta
/// yoziladi, qolgan kod tegilmaydi.
library;

import 'dart:convert';

import 'eld_codes.dart';
import 'eld_models.dart';

/// Xizmat va xarakteristika UUID lari + skan filtri.
class EldGattProfile {
  const EldGattProfile({
    required this.serviceUuid,
    required this.telemetryCharUuid,
    required this.commandCharUuid,
    required this.bufferCharUuid,
    required this.handshakeCharUuid,
    this.namePrefixes = const <String>['ONEBOOK-ELD'],
  });

  /// TODO(M80): vendor UUID lari bilan almashtiriladi.
  static const EldGattProfile provisional = EldGattProfile(
    serviceUuid: '0000fee0-0000-1000-8000-00805f9b34fb',
    telemetryCharUuid: '0000fee1-0000-1000-8000-00805f9b34fb',
    commandCharUuid: '0000fee2-0000-1000-8000-00805f9b34fb',
    bufferCharUuid: '0000fee3-0000-1000-8000-00805f9b34fb',
    handshakeCharUuid: '0000fee4-0000-1000-8000-00805f9b34fb',
  );

  final String serviceUuid;

  /// Notify — telemetriya kadrlari.
  final String telemetryCharUuid;

  /// Write — buyruqlar (`read_buffer`, `ack`, `sync_time`).
  final String commandCharUuid;

  /// Notify — bufer eventlari (`readBuffer()` javobi).
  final String bufferCharUuid;

  /// Read — handshake (firmware, VIN, RTC, odometer, engine hours).
  final String handshakeCharUuid;

  /// Skan filtri: qurilma nomi shu prefikslardan biri bilan boshlanishi kerak.
  final List<String> namePrefixes;

  bool matchesName(String name) {
    if (namePrefixes.isEmpty) {
      return true;
    }
    final String upper = name.toUpperCase();
    return namePrefixes.any((String p) => upper.startsWith(p.toUpperCase()));
  }
}

/// Buyruq nomlari (write char).
abstract final class EldCommand {
  const EldCommand._();

  static const String readBuffer = 'read_buffer';
  static const String ackBuffer = 'ack_buffer';
}

/// Kadr kodeki — bayt ↔ domen tipi.
///
/// **Xato bardoshlilik:** noto'g'ri kadr `null` qaytaradi (uzilishga sabab
/// bo'lmaydi), chunki BLE da qisman paket kelishi normal.
abstract final class EldFrameCodec {
  const EldFrameCodec._();

  /// Bufer oxiri belgisi (`{"type":"end"}`).
  static const String endMarker = 'end';

  static Map<String, Object?>? decodeJson(List<int> bytes) {
    if (bytes.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static List<int> encodeCommand(String command, [Map<String, Object?>? args]) =>
      utf8.encode(jsonEncode(<String, Object?>{'cmd': command, ...?args}));

  /// Telemetriya kadri. [fallbackAt] — `TimeSource.now()` (kadrda `ts` yo'q bo'lsa).
  static EldTelemetryFrame? telemetry(Map<String, Object?> json, {required DateTime fallbackAt}) {
    final double? speed = _double(json['speed_kmh']);
    if (speed == null) {
      return null;
    }
    final double? lat = _double(json['lat']);
    final double? lng = _double(json['lng']);
    return EldTelemetryFrame(
      at: _time(json['ts']) ?? fallbackAt,
      speedKmh: speed,
      lat: lat,
      lng: lng,
      gpsAccuracyM: _double(json['gps_accuracy_m']),
      odometerM: _int(json['odometer_m']),
      engineHours: _double(json['engine_hours']),
      ignition: json['ignition'] is bool ? json['ignition'] as bool : null,
      batteryVoltage: _double(json['battery_v']),
      headingDeg: _double(json['heading_deg']),
      faults: _faults(json['diagnostics']),
      fromEldGps: lat != null && lng != null,
    );
  }

  static EldHandshake? handshake(
    Map<String, Object?> json, {
    required String deviceId,
    required DateTime fallbackRtc,
  }) {
    final Object? firmware = json['firmware'];
    if (firmware == null) {
      return null;
    }
    return EldHandshake(
      deviceId: deviceId,
      firmware: '$firmware',
      rtcUtc: _time(json['rtc']) ?? fallbackRtc,
      vin: json['vin'] as String?,
      serial: json['serial'] as String?,
      odometerM: _int(json['odometer_m']),
      engineHours: _double(json['engine_hours']),
    );
  }

  static EldBufferedEvent? bufferedEvent(Map<String, Object?> json) {
    final int? seq = _int(json['seq']);
    final DateTime? at = _time(json['ts']);
    final EldBufferedEventType? type = _bufferedType(json['type']);
    if (seq == null || at == null || type == null) {
      return null;
    }
    return EldBufferedEvent(
      eldSeq: seq,
      type: type,
      recordedAt: at,
      vendorEventId: json['event_id'] as String?,
      lat: _double(json['lat']),
      lng: _double(json['lng']),
      odometerM: _int(json['odometer_m']),
      engineHours: _double(json['engine_hours']),
      speedKmh: _double(json['speed_kmh']),
      faultCode: json['code'] is String ? EldFaultCode.fromLetter(json['code']! as String) : null,
    );
  }

  static EldBufferedEventType? _bufferedType(Object? value) {
    for (final EldBufferedEventType t in EldBufferedEventType.values) {
      if (t.wire == value) {
        return t;
      }
    }
    return null;
  }

  static List<EldFaultCode> _faults(Object? value) {
    if (value is! List<Object?>) {
      return const <EldFaultCode>[];
    }
    return value
        .whereType<String>()
        .map(EldFaultCode.fromLetter)
        .whereType<EldFaultCode>()
        .toList(growable: false);
  }

  static double? _double(Object? value) => switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s),
    _ => null,
  };

  static int? _int(Object? value) => switch (value) {
    final int n => n,
    final num n => n.round(),
    final String s => int.tryParse(s),
    _ => null,
  };

  static DateTime? _time(Object? value) => switch (value) {
    final int ms => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
    final String s => DateTime.tryParse(s)?.toUtc(),
    _ => null,
  };
}
