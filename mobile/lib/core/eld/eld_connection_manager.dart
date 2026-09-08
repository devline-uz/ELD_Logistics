/// Ulanish holat mashinasi (tz-mobile §10.3, skill `flutter-ble` §2).
///
/// ```
/// NotConnected ──(ruxsat+BT ok)──► Connecting ──(handshake)──► Connected
///      ▲                              │ 20 s timeout / xato        │
///      └──────────────────────────────┴──(uzilish, 30 s tiklanmasa)┘
/// ```
/// Qayta ulanish: `2 s → 5 s → 15 s → 60 s` (cheksiz). Oxirgi MAC/ID
/// `kv_settings` da saqlanadi va keyingi sessiyada to'g'ridan-to'g'ri
/// tiklanadi.
library;

import 'dart:async';

import '../time/time_source.dart';
import 'eld_codes.dart';
import 'eld_models.dart';
import 'eld_session.dart';
import 'eld_transport.dart';

/// Oxirgi qurilma ID sini saqlaydigan minimal ombor.
///
/// Implementatsiya — `kv_eld_device_store.dart` (`kv_settings` ustida);
/// testlarda [InMemoryEldDeviceStore].
abstract class EldDeviceStore {
  Future<String?> lastDeviceId();

  Future<void> saveLastDeviceId(String id);

  Future<void> forget();
}

/// Xotiradagi ombor — testlar va mock rejim uchun.
class InMemoryEldDeviceStore implements EldDeviceStore {
  InMemoryEldDeviceStore([this._id]);

  String? _id;

  @override
  Future<String?> lastDeviceId() async => _id;

  @override
  Future<void> saveLastDeviceId(String id) async => _id = id;

  @override
  Future<void> forget() async => _id = null;
}

/// Transport ustidagi holat mashinasi. UI faqat [states] ni kuzatadi.
class EldConnectionManager {
  EldConnectionManager({
    required this._transport,
    required this._time,
    required this._store,
    this.autoReconnect = true,
    Future<void> Function(Duration)? sleep,
  }) : _sleep = sleep ?? _defaultSleep;

  static Future<void> _defaultSleep(Duration d) => Future<void>.delayed(d);

  final EldTransport _transport;
  final TimeSource _time;
  final EldDeviceStore _store;
  final Future<void> Function(Duration) _sleep;

  /// `false` — testda qayta ulanish sikli o'chiriladi.
  final bool autoReconnect;

  final StreamController<EldSessionState> _states = StreamController<EldSessionState>.broadcast();

  /// Handshake muvaffaqiyatli bo'lganda chiqadi — `power_on` eventi va
  /// bufer importi shu oqimdan ishga tushadi.
  final StreamController<EldHandshake> _handshakes = StreamController<EldHandshake>.broadcast();

  final EldReconnectBackoff _backoff = EldReconnectBackoff();

  StreamSubscription<EldConnectionState>? _stateSub;
  StreamSubscription<EldTelemetryFrame>? _frameSub;
  StreamSubscription<EldFault>? _faultSub;
  Timer? _reconnectTimer;
  bool _closed = false;

  EldSessionState _state = const EldSessionState();

  /// Unit VIN si — handshake'da solishtiriladi (M-19 ogohlantirishi).
  String? unitVin;

  Stream<EldSessionState> get states => _states.stream;

  Stream<EldHandshake> get handshakes => _handshakes.stream;

  EldSessionState get state => _state;

  /// Oqimlarga obuna bo'ladi va saqlangan qurilma bo'lsa qayta ulanadi.
  Future<void> start() async {
    _stateSub ??= _transport.state.listen(_onTransportState);
    _frameSub ??= _transport.telemetry.listen(_onFrame);
    _faultSub ??= _transport.diagnostics.listen(registerFault);
    final String? last = await _store.lastDeviceId();
    if (last != null) {
      unawaited(connect(deviceId: last));
    }
  }

  /// Skan (§10.3). Saqlangan qurilma bo'lmaganda M-19 ro'yxati shundan to'ladi.
  Stream<List<EldDeviceRef>> scan({Duration timeout = kEldScanTimeout}) =>
      _transport.scan(timeout: timeout);

  /// Ulanadi; muvaffaqiyatda ID saqlanadi va handshake chiqariladi.
  Future<EldHandshake?> connect({String? deviceId}) async {
    _cancelReconnect();
    _emit(
      _state.copyWith(
        connection: EldConnectionState.connecting,
        clearFailure: true,
        clearDisconnectedSince: true,
      ),
    );
    try {
      final EldHandshake handshake = await _transport
          .connect(macOrId: deviceId)
          .timeout(
            kEldConnectTimeout,
            onTimeout: () => throw const EldTransportException(EldTransportFailure.connectTimeout),
          );

      // M71: ELD RTC — vaqt manbalarining eng ustuni.
      _time.syncFromEldRtc(handshake.rtcUtc);
      await _store.saveLastDeviceId(handshake.deviceId);
      _backoff.reset();

      _emit(
        _state.copyWith(
          connection: EldConnectionState.connected,
          device: EldDeviceRef(id: handshake.deviceId, name: handshake.serial ?? ''),
          handshake: handshake,
          vinMatch: matchVin(eldVin: handshake.vin, unitVin: unitVin),
          reconnectAttempt: 0,
          clearFailure: true,
          clearDisconnectedSince: true,
        ),
      );
      if (!_handshakes.isClosed) {
        _handshakes.add(handshake);
      }
      return handshake;
    } on EldTransportException catch (e) {
      _emit(
        _state.copyWith(
          connection: EldConnectionState.notConnected,
          failure: e.reason,
          disconnectedSince: _state.disconnectedSince ?? _time.now(),
        ),
      );
      _scheduleReconnect(deviceId);
      return null;
    }
  }

  /// Foydalanuvchi qo'lda uzdi — avtomatik qayta ulanish **boshlanmaydi**.
  Future<void> disconnect({bool forget = false}) async {
    _cancelReconnect();
    await _transport.disconnect();
    if (forget) {
      await _store.forget();
    }
    _time.dropEldAnchor();
    _emit(
      _state.copyWith(
        connection: EldConnectionState.notConnected,
        clearDevice: true,
        clearDisconnectedSince: true,
      ),
    );
  }

  /// **M72:** buferni o'qiydi (importer uni outbox'ga yozadi).
  Future<List<EldBufferedEvent>> readBuffer() => _transport.readBuffer();

  Future<void> acknowledgeBuffer(List<EldBufferedEvent> events) =>
      _transport.acknowledgeBuffer(events);

  /// Detektor yoki transport bergan nosozlikni holatga kiritadi (M77).
  void registerFault(EldFault fault) {
    final Map<EldFaultCode, EldFault> next = Map<EldFaultCode, EldFault>.of(_state.faults);
    final EldFault? existing = next[fault.code];
    if (existing != null && existing.kind == fault.kind && existing.detail == fault.detail) {
      return; // takroriy — banner o'zgarmaydi.
    }
    next[fault.code] = fault;
    _emit(_state.copyWith(faults: Map<EldFaultCode, EldFault>.unmodifiable(next)));
  }

  /// Holat tiklandi — banner faqat shunda yo'qoladi (M77, dismiss yo'q).
  void clearFault(EldFaultCode code) {
    if (!_state.faults.containsKey(code)) {
      return;
    }
    final Map<EldFaultCode, EldFault> next = Map<EldFaultCode, EldFault>.of(_state.faults)
      ..remove(code);
    _emit(_state.copyWith(faults: Map<EldFaultCode, EldFault>.unmodifiable(next)));
  }

  /// Detektor bergan to'liq to'plamni bir marta qo'llaydi.
  void applyFaults(Map<EldFaultCode, EldFault> faults) {
    if (_sameFaults(faults, _state.faults)) {
      return;
    }
    _emit(_state.copyWith(faults: Map<EldFaultCode, EldFault>.unmodifiable(faults)));
  }

  Future<void> dispose() async {
    _closed = true;
    _cancelReconnect();
    await _stateSub?.cancel();
    await _frameSub?.cancel();
    await _faultSub?.cancel();
    await _states.close();
    await _handshakes.close();
  }

  // --- ichki ---------------------------------------------------------------

  void _onTransportState(EldConnectionState next) {
    if (next == EldConnectionState.notConnected && _state.connection.isConnected) {
      // Kutilmagan uzilish: 30 s ichida tiklanmasa banner (§10.3).
      _emit(
        _state.copyWith(
          connection: EldConnectionState.notConnected,
          disconnectedSince: _time.now(),
          failure: EldTransportFailure.disconnected,
        ),
      );
      _time.dropEldAnchor();
      _scheduleReconnect(_state.device?.id);
      return;
    }
    // `malfunction`/`diagnostic` — **ulanish** holati emas, nosozlik holati.
    // Ular `faults` map'idan hosil qilinadi (`EldSessionState.bannerState`),
    // aks holda kod tozalangach banner `malfunction` da qotib qolardi (M77).
    final EldConnectionState connection = next.isConnected ? EldConnectionState.connected : next;
    if (connection != _state.connection) {
      _emit(_state.copyWith(connection: connection));
    }
  }

  void _onFrame(EldTelemetryFrame frame) {
    _emit(
      _state.copyWith(
        lastFrameAt: frame.at,
        lastPositionAt: frame.hasPosition && frame.fromEldGps ? frame.at : null,
      ),
    );
  }

  void _scheduleReconnect(String? deviceId) {
    if (!autoReconnect || _closed || deviceId == null) {
      return;
    }
    _cancelReconnect();
    final Duration delay = _backoff.next();
    _emit(_state.copyWith(reconnectAttempt: _backoff.attempt));
    _reconnectTimer = Timer(delay, () {
      unawaited(_sleep(Duration.zero).then((_) => connect(deviceId: deviceId)));
    });
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _emit(EldSessionState next) {
    _state = next;
    if (!_states.isClosed) {
      _states.add(next);
    }
  }

  static bool _sameFaults(Map<EldFaultCode, EldFault> a, Map<EldFaultCode, EldFault> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final MapEntry<EldFaultCode, EldFault> e in a.entries) {
      if (b[e.key] != e.value) {
        return false;
      }
    }
    return true;
  }
}
