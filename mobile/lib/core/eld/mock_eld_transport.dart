/// `MockEldTransport` — **birinchi** implementatsiya (M80, risk R2).
///
/// Barcha ekranlar va integratsiya testlari shu transport bilan to'liq ishlaydi:
/// skan, ulanish, handshake, harakat boshlanishi/to'xtashi, malfunction,
/// uzilish va buferdan o'qish stsenariylari **skript** bilan boshqariladi.
///
/// **Prodda build qilinmaydi** (M168): `Env.mockEldEnabled` faqat dev/stage
/// muhitida `true`.
library;

import 'dart:async';

import '../time/time_source.dart';
import 'eld_codes.dart';
import 'eld_models.dart';
import 'eld_transport.dart';

/// Mock qurilma ta'rifi — skan ro'yxatida ko'rinadi.
class MockEldDevice {
  const MockEldDevice({
    required this.id,
    required this.name,
    this.rssi = -55,
    this.firmware = '1.4.2',
    this.vin = '1FUJGLDR9CLBP8834',
    this.serial = 'MOCK-0001',
    this.odometerM = 812_450_000,
    this.engineHours = 4821.5,
    this.rtcOffset = Duration.zero,
  });

  final String id;
  final String name;
  final int rssi;
  final String firmware;
  final String? vin;
  final String serial;
  final int odometerM;
  final double engineHours;

  /// Qurilma RTC sining `TimeSource` dan farqi — `T` kodini sinash uchun.
  final Duration rtcOffset;
}

/// Standart mock qurilma to'plami.
const List<MockEldDevice> kMockEldDevices = <MockEldDevice>[
  MockEldDevice(id: 'AA:BB:CC:00:00:01', name: 'ONEBOOK-ELD-1021'),
  MockEldDevice(id: 'AA:BB:CC:00:00:02', name: 'ONEBOOK-ELD-2044', rssi: -93),
];

class MockEldTransport implements EldTransport {
  MockEldTransport({
    required this._time,
    List<MockEldDevice> devices = kMockEldDevices,
    List<EldBufferedEvent> buffer = const <EldBufferedEvent>[],
    this.scanDelay = const Duration(milliseconds: 300),
    this.connectDelay = const Duration(milliseconds: 400),
    this.failConnect,
  }) : _devices = List<MockEldDevice>.of(devices),
       _buffer = List<EldBufferedEvent>.of(buffer);

  final TimeSource _time;
  final List<MockEldDevice> _devices;
  final List<EldBufferedEvent> _buffer;

  /// Skan natijalari orasidagi kechikish (testda `Duration.zero`).
  final Duration scanDelay;
  final Duration connectDelay;

  /// `null` bo'lmasa — `connect()` shu sabab bilan yiqiladi.
  final EldTransportFailure? failConnect;

  final StreamController<EldConnectionState> _states =
      StreamController<EldConnectionState>.broadcast();
  final StreamController<EldTelemetryFrame> _telemetry =
      StreamController<EldTelemetryFrame>.broadcast();
  final StreamController<EldFault> _faults = StreamController<EldFault>.broadcast();

  EldConnectionState _state = EldConnectionState.notConnected;
  MockEldDevice? _connected;

  /// `readBuffer()` necha marta chaqirilgani — dedup testlari uchun.
  int readBufferCalls = 0;

  /// `acknowledgeBuffer()` bilan tozalangan eventlar.
  final List<EldBufferedEvent> acknowledged = <EldBufferedEvent>[];

  @override
  Stream<EldConnectionState> get state => _states.stream;

  @override
  EldConnectionState get currentState => _state;

  @override
  Stream<EldTelemetryFrame> get telemetry => _telemetry.stream;

  @override
  Stream<EldFault> get diagnostics => _faults.stream;

  /// Ulangan qurilma (skript uchun).
  MockEldDevice? get connectedDevice => _connected;

  @override
  Stream<List<EldDeviceRef>> scan({Duration timeout = kEldScanTimeout}) async* {
    final List<EldDeviceRef> found = <EldDeviceRef>[];
    for (final MockEldDevice d in _devices) {
      if (scanDelay > Duration.zero) {
        await Future<void>.delayed(scanDelay);
      }
      found.add(EldDeviceRef(id: d.id, name: d.name, rssi: d.rssi));
      yield List<EldDeviceRef>.unmodifiable(found);
    }
  }

  @override
  Future<EldHandshake> connect({String? macOrId}) async {
    _emit(EldConnectionState.connecting);
    if (connectDelay > Duration.zero) {
      await Future<void>.delayed(connectDelay);
    }
    final EldTransportFailure? failure = failConnect;
    if (failure != null) {
      _emit(EldConnectionState.notConnected);
      throw EldTransportException(failure, detail: macOrId);
    }
    final MockEldDevice device = _devices.firstWhere(
      (MockEldDevice d) => macOrId == null || d.id == macOrId,
      orElse: () => throw const EldTransportException(EldTransportFailure.notFound),
    );
    _connected = device;
    _emit(EldConnectionState.connected);
    return EldHandshake(
      deviceId: device.id,
      firmware: device.firmware,
      rtcUtc: _time.now().add(device.rtcOffset),
      vin: device.vin,
      serial: device.serial,
      odometerM: device.odometerM,
      engineHours: device.engineHours,
    );
  }

  @override
  Future<List<EldBufferedEvent>> readBuffer() async {
    readBufferCalls++;
    if (_connected == null) {
      throw const EldTransportException(EldTransportFailure.disconnected);
    }
    return List<EldBufferedEvent>.unmodifiable(_buffer);
  }

  @override
  Future<void> acknowledgeBuffer(List<EldBufferedEvent> events) async {
    acknowledged.addAll(events);
  }

  @override
  Future<void> disconnect() async {
    _connected = null;
    _emit(EldConnectionState.notConnected);
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await _telemetry.close();
    await _faults.close();
  }

  // --- Skript API si (faqat test va dev menyu) ------------------------------

  /// Qurilma harakat boshladi: [speedKmh] tezlik bilan [frames] ta kadr.
  ///
  /// Har kadr [step] oralig'ida "yozilgan" deb belgilanadi — detektor 3 s
  /// tasdiqlash oynasini shu vaqt bo'yicha hisoblaydi.
  void emitMotion({
    required double speedKmh,
    int frames = 4,
    Duration step = const Duration(seconds: 1),
    DateTime? from,
    double lat = 41.311081,
    double lng = 69.240562,
  }) {
    DateTime at = from ?? _time.now();
    for (int i = 0; i < frames; i++) {
      pushFrame(
        EldTelemetryFrame(
          at: at,
          speedKmh: speedKmh,
          lat: lat,
          lng: lng,
          gpsAccuracyM: 8,
          odometerM: (_connected?.odometerM ?? 0) + i * 20,
          engineHours: (_connected?.engineHours ?? 0) + i * 0.01,
          ignition: true,
        ),
      );
      at = at.add(step);
    }
  }

  /// Bitta kadrni oqimga qo'yadi.
  void pushFrame(EldTelemetryFrame frame) {
    if (!_telemetry.isClosed) {
      _telemetry.add(frame);
    }
  }

  /// Nosozlikni chiqaradi va holatni mos ravishda o'zgartiradi.
  void raiseFault(EldFaultCode code, {EldFaultKind kind = EldFaultKind.malfunction}) {
    final EldFault fault = EldFault(code: code, kind: kind, detectedAt: _time.now());
    if (!_faults.isClosed) {
      _faults.add(fault);
    }
    _emit(
      kind == EldFaultKind.malfunction
          ? EldConnectionState.malfunction
          : EldConnectionState.diagnostic,
    );
  }

  /// Nosozliklar tugadi — `Connected` ga qaytadi.
  void clearFaults() {
    if (_connected != null) {
      _emit(EldConnectionState.connected);
    }
  }

  /// Aloqa uzildi (kabel sug'urib olindi / masofa).
  void dropConnection() {
    _connected = null;
    _emit(EldConnectionState.notConnected);
  }

  /// Bufer mazmunini almashtiradi.
  void setBuffer(List<EldBufferedEvent> events) {
    _buffer
      ..clear()
      ..addAll(events);
  }

  void _emit(EldConnectionState next) {
    _state = next;
    if (!_states.isClosed) {
      _states.add(next);
    }
  }
}
