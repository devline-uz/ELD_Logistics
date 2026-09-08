/// `EldSessionState` — banner va ekranlar uchun to'liq ELD holati.
library;

import 'eld_codes.dart';
import 'eld_models.dart';

/// Ulanish menejerining kuzatiladigan holati.
class EldSessionState {
  const EldSessionState({
    this.connection = EldConnectionState.notConnected,
    this.device,
    this.handshake,
    this.vinMatch = VinMatchResult.unknown,
    this.faults = const <EldFaultCode, EldFault>{},
    this.lastFrameAt,
    this.lastPositionAt,
    this.disconnectedSince,
    this.reconnectAttempt = 0,
    this.failure,
  });

  final EldConnectionState connection;
  final EldDeviceRef? device;
  final EldHandshake? handshake;
  final VinMatchResult vinMatch;

  /// Aktiv nosozliklar, kod bo'yicha (takror chiqmaydi).
  final Map<EldFaultCode, EldFault> faults;

  /// Oxirgi telemetriya kadri vaqti (`ELD coordinates` diagnostikasi uchun).
  final DateTime? lastFrameAt;

  /// Oxirgi ELD lat/lng kelgan vaqt (M-46: oxirgi 60 s).
  final DateTime? lastPositionAt;

  /// Uzilish boshlangan payt — 30 s dan keyin banner (§10.3).
  final DateTime? disconnectedSince;

  final int reconnectAttempt;

  /// Oxirgi ulanish xatosi (UI da `Retry` bilan ko'rsatiladi).
  final EldTransportFailure? failure;

  /// Faqat malfunction darajasidagi kodlar (doimiy qizil banner, M77).
  List<EldFault> get malfunctions =>
      (faults.values.where((EldFault f) => f.isMalfunction).toList()..sort());

  /// Diagnostic darajasidagi kodlar (sariq banner).
  List<EldFault> get diagnosticFaults =>
      (faults.values.where((EldFault f) => !f.isMalfunction).toList()..sort());

  bool get hasMalfunction => malfunctions.isNotEmpty;

  /// Banner uchun yakuniy holat: malfunction > diagnostic > ulanish holati.
  EldConnectionState get bannerState {
    if (hasMalfunction) {
      return EldConnectionState.malfunction;
    }
    if (diagnosticFaults.isNotEmpty && connection.isConnected) {
      return EldConnectionState.diagnostic;
    }
    return connection;
  }

  /// ELD dan 60 s ichida koordinata keldimi (M-46 `ELD coordinates`).
  bool eldPositionFresh(DateTime now) {
    final DateTime? at = lastPositionAt;
    return at != null && now.difference(at) <= kEldPositionFreshness;
  }

  EldSessionState copyWith({
    EldConnectionState? connection,
    EldDeviceRef? device,
    EldHandshake? handshake,
    VinMatchResult? vinMatch,
    Map<EldFaultCode, EldFault>? faults,
    DateTime? lastFrameAt,
    DateTime? lastPositionAt,
    DateTime? disconnectedSince,
    int? reconnectAttempt,
    EldTransportFailure? failure,
    bool clearDevice = false,
    bool clearDisconnectedSince = false,
    bool clearFailure = false,
  }) => EldSessionState(
    connection: connection ?? this.connection,
    device: clearDevice ? null : (device ?? this.device),
    handshake: clearDevice ? null : (handshake ?? this.handshake),
    vinMatch: vinMatch ?? this.vinMatch,
    faults: faults ?? this.faults,
    lastFrameAt: lastFrameAt ?? this.lastFrameAt,
    lastPositionAt: lastPositionAt ?? this.lastPositionAt,
    disconnectedSince: clearDisconnectedSince
        ? null
        : (disconnectedSince ?? this.disconnectedSince),
    reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  String toString() =>
      'EldSessionState(${bannerState.name}, device=${device?.id}, faults=${faults.keys})';
}

/// ELD koordinatasi «yangi» hisoblanadigan oyna (tz-mobile §10.5).
const Duration kEldPositionFreshness = Duration(seconds: 60);
