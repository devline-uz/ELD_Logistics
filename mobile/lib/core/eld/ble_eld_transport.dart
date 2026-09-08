/// `BleEldTransport` — `flutter_blue_plus` ustidagi [EldTransport] (M79).
///
/// **Qat'iy:** `flutter_blue_plus` importi **faqat shu faylda**. UI, domen va
/// servis qatlami hech qachon `BluetoothDevice` yoki `Guid` ko'rmaydi.
///
/// iOS state restoration (M74) `FlutterBluePlus.setOptions(restoreState: true)`
/// bilan yoqiladi — `core/background/ios_background.dart` ga qarang.
library;

import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../time/time_source.dart';
import 'eld_codes.dart';
import 'eld_gatt_profile.dart';
import 'eld_models.dart';
import 'eld_transport.dart';

/// Bufer o'qish javobi uchun kutish vaqti.
const Duration kEldBufferReadTimeout = Duration(seconds: 15);

class BleEldTransport implements EldTransport {
  BleEldTransport({required this._time, this.profile = EldGattProfile.provisional});

  final TimeSource _time;
  final EldGattProfile profile;

  final StreamController<EldConnectionState> _states =
      StreamController<EldConnectionState>.broadcast();
  final StreamController<EldTelemetryFrame> _telemetry =
      StreamController<EldTelemetryFrame>.broadcast();
  final StreamController<EldFault> _faults = StreamController<EldFault>.broadcast();

  EldConnectionState _state = EldConnectionState.notConnected;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _command;
  BluetoothCharacteristic? _buffer;
  BluetoothCharacteristic? _handshake;

  StreamSubscription<List<int>>? _telemetrySub;
  StreamSubscription<List<int>>? _bufferSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  /// `readBuffer()` davomida to'planadigan eventlar.
  Completer<List<EldBufferedEvent>>? _bufferCompleter;
  final List<EldBufferedEvent> _bufferAccum = <EldBufferedEvent>[];

  @override
  Stream<EldConnectionState> get state => _states.stream;

  @override
  EldConnectionState get currentState => _state;

  @override
  Stream<EldTelemetryFrame> get telemetry => _telemetry.stream;

  @override
  Stream<EldFault> get diagnostics => _faults.stream;

  @override
  Stream<List<EldDeviceRef>> scan({Duration timeout = kEldScanTimeout}) async* {
    if (!await FlutterBluePlus.isSupported) {
      throw const EldTransportException(EldTransportFailure.unsupported);
    }
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      throw const EldTransportException(EldTransportFailure.bluetoothOff);
    }

    final StreamController<List<EldDeviceRef>> out = StreamController<List<EldDeviceRef>>();
    final StreamSubscription<List<ScanResult>> sub = FlutterBluePlus.onScanResults.listen((
      List<ScanResult> results,
    ) {
      final List<EldDeviceRef> refs = <EldDeviceRef>[];
      for (final ScanResult r in results) {
        final String name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : r.advertisementData.advName;
        if (!profile.matchesName(name)) {
          continue;
        }
        refs.add(EldDeviceRef(id: r.device.remoteId.str, name: name, rssi: r.rssi));
      }
      if (!out.isClosed) {
        out.add(List<EldDeviceRef>.unmodifiable(refs));
      }
    });

    try {
      await FlutterBluePlus.startScan(
        withServices: <Guid>[Guid(profile.serviceUuid)],
        timeout: timeout,
      );
      yield* out.stream.timeout(
        timeout + const Duration(seconds: 1),
        onTimeout: (EventSink<List<EldDeviceRef>> sink) => sink.close(),
      );
    } on FlutterBluePlusException catch (e) {
      throw EldTransportException(_mapFailure(e), detail: e.description);
    } finally {
      await sub.cancel();
      await out.close();
      await FlutterBluePlus.stopScan();
    }
  }

  @override
  Future<EldHandshake> connect({String? macOrId}) async {
    if (macOrId == null) {
      throw const EldTransportException(EldTransportFailure.notFound);
    }
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      throw const EldTransportException(EldTransportFailure.bluetoothOff);
    }
    _emit(EldConnectionState.connecting);

    final BluetoothDevice device = BluetoothDevice.fromId(macOrId);
    try {
      // TODO(P12): `flutter_blue_plus` >= 2.0 **BSD-3 emas** — `License.commercial`
      // to'lovli litsenziya talab qiladi (LICENSE, Section 2). ONEBOOK ELD tijorat
      // mahsuloti, shuning uchun litsenziya sotib olinishi yoki paket
      // `flutter_blue_plus` 1.35.x (oxirgi BSD-3) ga tushirilishi kerak.
      await device.connect(license: License.commercial, timeout: kEldConnectTimeout, mtu: null);
      final List<BluetoothService> services = await device.discoverServices();
      final BluetoothService service = services.firstWhere(
        (BluetoothService s) => s.uuid == Guid(profile.serviceUuid),
        orElse: () => throw const EldTransportException(EldTransportFailure.unsupported),
      );

      _device = device;
      _command = _char(service, profile.commandCharUuid);
      _buffer = _char(service, profile.bufferCharUuid);
      _handshake = _char(service, profile.handshakeCharUuid);

      await _subscribeTelemetry(service);
      await _subscribeBuffer();
      _watchConnection(device);

      final EldHandshake handshake = await _readHandshake(macOrId);
      _emit(EldConnectionState.connected);
      return handshake;
    } on EldTransportException {
      await _teardown();
      _emit(EldConnectionState.notConnected);
      rethrow;
    } on TimeoutException {
      await _teardown();
      _emit(EldConnectionState.notConnected);
      throw const EldTransportException(EldTransportFailure.connectTimeout);
    } on FlutterBluePlusException catch (e) {
      await _teardown();
      _emit(EldConnectionState.notConnected);
      throw EldTransportException(_mapFailure(e), detail: e.description);
    }
  }

  @override
  Future<List<EldBufferedEvent>> readBuffer() async {
    final BluetoothCharacteristic? command = _command;
    if (_device == null || command == null) {
      throw const EldTransportException(EldTransportFailure.disconnected);
    }
    final Completer<List<EldBufferedEvent>> completer = Completer<List<EldBufferedEvent>>();
    _bufferAccum.clear();
    _bufferCompleter = completer;

    await command.write(EldFrameCodec.encodeCommand(EldCommand.readBuffer));
    try {
      return await completer.future.timeout(kEldBufferReadTimeout);
    } on TimeoutException {
      // Qisman o'qilgan bufer ham qaytariladi: `client_event_id` deterministik,
      // qolganlari keyingi ulanishda takror o'qiladi va dublikat bermaydi (M72).
      return List<EldBufferedEvent>.unmodifiable(_bufferAccum);
    } finally {
      _bufferCompleter = null;
    }
  }

  @override
  Future<void> acknowledgeBuffer(List<EldBufferedEvent> events) async {
    final BluetoothCharacteristic? command = _command;
    if (command == null || events.isEmpty) {
      return;
    }
    final int maxSeq = events
        .map((EldBufferedEvent e) => e.eldSeq)
        .reduce((int a, int b) => a > b ? a : b);
    await command.write(
      EldFrameCodec.encodeCommand(EldCommand.ackBuffer, <String, Object?>{'through_seq': maxSeq}),
    );
  }

  @override
  Future<void> disconnect() async {
    final BluetoothDevice? device = _device;
    await _teardown();
    if (device != null) {
      await device.disconnect();
    }
    _emit(EldConnectionState.notConnected);
  }

  @override
  Future<void> dispose() async {
    await _teardown();
    await _states.close();
    await _telemetry.close();
    await _faults.close();
  }

  // --- ichki ---------------------------------------------------------------

  BluetoothCharacteristic? _char(BluetoothService service, String uuid) {
    final Guid guid = Guid(uuid);
    for (final BluetoothCharacteristic c in service.characteristics) {
      if (c.uuid == guid) {
        return c;
      }
    }
    return null;
  }

  Future<void> _subscribeTelemetry(BluetoothService service) async {
    final BluetoothCharacteristic? c = _char(service, profile.telemetryCharUuid);
    if (c == null) {
      throw const EldTransportException(EldTransportFailure.unsupported);
    }
    await c.setNotifyValue(true);
    _telemetrySub = c.onValueReceived.listen(_onTelemetryBytes);
  }

  Future<void> _subscribeBuffer() async {
    final BluetoothCharacteristic? c = _buffer;
    if (c == null) {
      return;
    }
    await c.setNotifyValue(true);
    _bufferSub = c.onValueReceived.listen(_onBufferBytes);
  }

  void _watchConnection(BluetoothDevice device) {
    _connSub = device.connectionState.listen((BluetoothConnectionState s) {
      if (s == BluetoothConnectionState.disconnected && _state != EldConnectionState.notConnected) {
        _emit(EldConnectionState.notConnected);
      }
    });
  }

  Future<EldHandshake> _readHandshake(String deviceId) async {
    final BluetoothCharacteristic? c = _handshake;
    if (c == null) {
      throw const EldTransportException(EldTransportFailure.handshakeFailed);
    }
    final Map<String, Object?>? json = EldFrameCodec.decodeJson(await c.read());
    if (json == null) {
      throw const EldTransportException(EldTransportFailure.handshakeFailed);
    }
    final EldHandshake? handshake = EldFrameCodec.handshake(
      json,
      deviceId: deviceId,
      fallbackRtc: _time.now(),
    );
    if (handshake == null) {
      throw const EldTransportException(EldTransportFailure.handshakeFailed);
    }
    return handshake;
  }

  void _onTelemetryBytes(List<int> bytes) {
    final Map<String, Object?>? json = EldFrameCodec.decodeJson(bytes);
    if (json == null) {
      return;
    }
    final EldTelemetryFrame? frame = EldFrameCodec.telemetry(json, fallbackAt: _time.now());
    if (frame == null) {
      return;
    }
    if (!_telemetry.isClosed) {
      _telemetry.add(frame);
    }
    for (final EldFaultCode code in frame.faults) {
      _raise(code);
    }
  }

  void _onBufferBytes(List<int> bytes) {
    final Map<String, Object?>? json = EldFrameCodec.decodeJson(bytes);
    if (json == null) {
      return;
    }
    if (json['type'] == EldFrameCodec.endMarker) {
      final Completer<List<EldBufferedEvent>>? completer = _bufferCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete(List<EldBufferedEvent>.unmodifiable(_bufferAccum));
      }
      return;
    }
    final EldBufferedEvent? event = EldFrameCodec.bufferedEvent(json);
    if (event != null) {
      _bufferAccum.add(event);
    }
  }

  void _raise(EldFaultCode code) {
    if (_faults.isClosed) {
      return;
    }
    _faults.add(EldFault(code: code, kind: EldFaultKind.malfunction, detectedAt: _time.now()));
  }

  Future<void> _teardown() async {
    await _telemetrySub?.cancel();
    await _bufferSub?.cancel();
    await _connSub?.cancel();
    _telemetrySub = null;
    _bufferSub = null;
    _connSub = null;
    _device = null;
    _command = null;
    _buffer = null;
    _handshake = null;
  }

  void _emit(EldConnectionState next) {
    _state = next;
    if (!_states.isClosed) {
      _states.add(next);
    }
  }

  static EldTransportFailure _mapFailure(FlutterBluePlusException e) {
    final String text = '${e.description ?? ''} ${e.function}'.toLowerCase();
    if (text.contains('permission')) {
      return EldTransportFailure.permissionDenied;
    }
    if (text.contains('adapter') || text.contains('bluetooth is off')) {
      return EldTransportFailure.bluetoothOff;
    }
    if (text.contains('timeout')) {
      return EldTransportFailure.connectTimeout;
    }
    return EldTransportFailure.disconnected;
  }
}
