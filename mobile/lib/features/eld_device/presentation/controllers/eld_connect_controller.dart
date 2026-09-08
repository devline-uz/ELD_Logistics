/// `M-19 ELD device connect/scan` kontrolleri (tz-mobile §10.3, M71, M72).
///
/// Oqim:
/// ```
/// scan() 20 s  → tanlash → connect() → handshake (RTC → TimeSource, M71)
///              → readBuffer() → EldBufferImporter (M72, deterministik ID)
///              → acknowledgeBuffer()
/// ```
/// Ulanish holat mashinasi `core/eld/EldConnectionManager` da — bu kontroller
/// faqat ekran holatini (skan natijalari, bufer hisoboti, xato) saqlaydi.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/eld/eld_buffer_importer.dart';
import '../../../../core/eld/eld_connection_manager.dart';
import '../../../../core/eld/eld_models.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/eld/eld_transport.dart';

/// M-19 ekran holati.
class EldConnectUiState {
  const EldConnectUiState({
    this.scanning = false,
    this.devices = const <EldDeviceRef>[],
    this.connectingId,
    this.lastImport,
    this.failure,
  });

  final bool scanning;

  /// Skan natijasi — RSSI bo'yicha kuchli signaldan boshlab tartiblangan.
  final List<EldDeviceRef> devices;

  /// Hozir ulanayotgan qurilma ID si (`null` — ulanish ketmayapti).
  final String? connectingId;

  /// **M72:** oxirgi bufer importi hisoboti.
  final EldBufferImportResult? lastImport;

  /// Oxirgi xato (banner/`Retry` uchun).
  final EldTransportFailure? failure;

  bool get busy => scanning || connectingId != null;

  EldConnectUiState copyWith({
    bool? scanning,
    List<EldDeviceRef>? devices,
    String? connectingId,
    EldBufferImportResult? lastImport,
    EldTransportFailure? failure,
    bool clearConnecting = false,
    bool clearFailure = false,
  }) => EldConnectUiState(
    scanning: scanning ?? this.scanning,
    devices: devices ?? this.devices,
    connectingId: clearConnecting ? null : (connectingId ?? this.connectingId),
    lastImport: lastImport ?? this.lastImport,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

class EldConnectController extends Notifier<EldConnectUiState> {
  StreamSubscription<List<EldDeviceRef>>? _scanSub;

  @override
  EldConnectUiState build() {
    ref.onDispose(() => unawaited(_scanSub?.cancel()));
    return const EldConnectUiState();
  }

  EldConnectionManager get _manager => ref.read(eldConnectionManagerProvider);

  /// Skan (20 s timeout). Takroriy chaqiruv avvalgisini bekor qiladi.
  Future<void> scan({Duration timeout = kEldScanTimeout}) async {
    await _scanSub?.cancel();
    state = state.copyWith(scanning: true, devices: const <EldDeviceRef>[], clearFailure: true);
    final Completer<void> done = Completer<void>();
    _scanSub = _manager
        .scan(timeout: timeout)
        .listen(
          (List<EldDeviceRef> found) {
            final List<EldDeviceRef> sorted = List<EldDeviceRef>.of(
              found,
            )..sort((EldDeviceRef a, EldDeviceRef b) => (b.rssi ?? -127).compareTo(a.rssi ?? -127));
            state = state.copyWith(devices: List<EldDeviceRef>.unmodifiable(sorted));
          },
          onError: (Object error) {
            state = state.copyWith(
              scanning: false,
              failure: error is EldTransportException
                  ? error.reason
                  : EldTransportFailure.unsupported,
            );
            if (!done.isCompleted) {
              done.complete();
            }
          },
          onDone: () {
            state = state.copyWith(scanning: false);
            if (!done.isCompleted) {
              done.complete();
            }
          },
        );
    await done.future;
  }

  /// Ulanadi va muvaffaqiyatda **M72** bufer importini bajaradi.
  Future<void> connect(String deviceId) async {
    state = state.copyWith(connectingId: deviceId, clearFailure: true);
    final EldHandshake? handshake = await _manager.connect(deviceId: deviceId);
    if (handshake == null) {
      state = state.copyWith(clearConnecting: true, failure: _manager.state.failure);
      return;
    }
    final EldBufferImportResult result = await importBuffer(handshake.deviceId);
    state = state.copyWith(clearConnecting: true, lastImport: result);
  }

  /// **M72:** buferni o'qib outbox'ga deduplikatsiya bilan yozadi.
  ///
  /// Takroriy chaqiruvda `client_event_id` o'zgarmaydi, shuning uchun barcha
  /// eventlar `skipped` bo'ladi va dublikat paydo bo'lmaydi.
  Future<EldBufferImportResult> importBuffer(String deviceId) async {
    final List<EldBufferedEvent> events = await _manager.readBuffer();
    if (events.isEmpty) {
      return const EldBufferImportResult(imported: 0, skipped: 0, clientEventIds: <String>[]);
    }
    final EldBufferImportResult result = await ref
        .read(eldBufferImporterProvider)
        .import(deviceId: deviceId, events: events);
    await _manager.acknowledgeBuffer(events);
    return result;
  }

  /// Qo'lda uzish — avtomatik qayta ulanish boshlanmaydi.
  Future<void> disconnect({bool forget = false}) async {
    await _manager.disconnect(forget: forget);
    state = state.copyWith(clearConnecting: true, clearFailure: true);
  }
}

final NotifierProvider<EldConnectController, EldConnectUiState> eldConnectControllerProvider =
    NotifierProvider<EldConnectController, EldConnectUiState>(EldConnectController.new);
