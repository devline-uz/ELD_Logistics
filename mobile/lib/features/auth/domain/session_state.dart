/// Ikki slotli sessiya holati (tz-mobile §3.3 M9, §4.6, §4.8).
///
/// Kabinada bitta qurilma **ikkita mustaqil sessiya** ushlaydi:
/// `SessionSlot.active → active_driver` (DR shu haydovchiga yoziladi) va
/// `SessionSlot.co → co_driver` (OFF/SB/ON; DR yozilmaydi).
///
/// Slot identifikatori — `core/security/DriverSlot` (token vault kalitlari
/// ham shu bo'yicha ajratilgan). **Qaysi slot faol** ekani alohida maydon:
/// `Switch co-driver` da tokenlar joyida qoladi, faqat `activeSlot` almashadi.
library;

import '../../../core/security/secure_vault.dart';

/// Slotning holati.
enum SessionStatus {
  /// Slotda haydovchi yo'q (hech qachon login qilmagan yoki to'liq chiqqan).
  empty,

  /// Tirik sessiya: tokenlar bor, so'rov yuborish mumkin.
  active,

  /// `Leave Truck` (M18): refresh token **tirik**, qaytish faqat PIN orqali.
  paused;

  static SessionStatus parse(String? value) => switch (value) {
    'active' => SessionStatus.active,
    'paused' => SessionStatus.paused,
    _ => SessionStatus.empty,
  };

  String get wire => name;

  bool get isEmpty => this == SessionStatus.empty;

  bool get isActive => this == SessionStatus.active;

  bool get isPaused => this == SessionStatus.paused;
}

/// Bitta slotning kesimi. Tokenlar bu yerda **yo'q** — ular `SecureVault` da.
class SessionSlotState {
  const SessionSlotState({
    required this.slot,
    this.status = SessionStatus.empty,
    this.driverId = '',
    this.driverName = '',
    this.sessionId,
  });

  /// Bo'sh slot.
  const SessionSlotState.vacant(this.slot)
    : status = SessionStatus.empty,
      driverId = '',
      driverName = '',
      sessionId = null;

  factory SessionSlotState.fromJson(DriverSlot slot, Map<String, Object?> json) => SessionSlotState(
    slot: slot,
    status: SessionStatus.parse(json['status'] as String?),
    driverId: json['driver_id'] as String? ?? '',
    driverName: json['driver_name'] as String? ?? '',
    sessionId: json['session_id'] as String?,
  );

  final DriverSlot slot;
  final SessionStatus status;
  final String driverId;

  /// `ActiveDriverBanner` va `M-03` sarlavhasi uchun (M10).
  final String driverName;

  /// `GET /auth/sessions` dagi `current` yozuvni topish uchun.
  final String? sessionId;

  bool get isEmpty => status.isEmpty;

  bool get isActive => status.isActive;

  bool get isPaused => status.isPaused;

  /// Slotda haydovchi bor (faol yoki pauzada).
  bool get isOccupied => !status.isEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
    'status': status.wire,
    'driver_id': driverId,
    'driver_name': driverName,
    'session_id': sessionId,
  };

  SessionSlotState copyWith({
    SessionStatus? status,
    String? driverId,
    String? driverName,
    String? sessionId,
  }) => SessionSlotState(
    slot: slot,
    status: status ?? this.status,
    driverId: driverId ?? this.driverId,
    driverName: driverName ?? this.driverName,
    sessionId: sessionId ?? this.sessionId,
  );

  @override
  bool operator ==(Object other) =>
      other is SessionSlotState &&
      other.slot == slot &&
      other.status == status &&
      other.driverId == driverId &&
      other.driverName == driverName &&
      other.sessionId == sessionId;

  @override
  int get hashCode => Object.hash(slot, status, driverId, driverName, sessionId);

  /// PII logga chiqmaydi (M159) — ism yozilmaydi.
  @override
  String toString() => 'SessionSlotState(${slot.wire}, ${status.wire}, $driverId)';
}

/// Ikki slotning birlashgan holati.
class DualSessionState {
  const DualSessionState({
    required this.primary,
    required this.coDriver,
    this.activeSlot = DriverSlot.primary,
  });

  /// Ikkala slot ham bo'sh — ilova `M-02 Login` da.
  const DualSessionState.signedOut()
    : primary = const SessionSlotState.vacant(DriverSlot.primary),
      coDriver = const SessionSlotState.vacant(DriverSlot.coDriver),
      activeSlot = DriverSlot.primary;

  factory DualSessionState.fromJson(Map<String, Object?> json) => DualSessionState(
    primary: SessionSlotState.fromJson(
      DriverSlot.primary,
      (json[DriverSlot.primary.wire] as Map<String, Object?>?) ?? const <String, Object?>{},
    ),
    coDriver: SessionSlotState.fromJson(
      DriverSlot.coDriver,
      (json[DriverSlot.coDriver.wire] as Map<String, Object?>?) ?? const <String, Object?>{},
    ),
    activeSlot: DriverSlot.parse(json['active'] as String?),
  );

  final SessionSlotState primary;
  final SessionSlotState coDriver;

  /// Harakat aniqlanganda `DR` **faqat** shu slotga yoziladi (`tz.md` Q45.1).
  final DriverSlot activeSlot;

  SessionSlotState of(DriverSlot slot) => slot == DriverSlot.primary ? primary : coDriver;

  /// Faol haydovchi.
  SessionSlotState get active => of(activeSlot);

  /// Ikkinchi slot (co-driver yoki bo'sh).
  SessionSlotState get passive => of(activeSlot.other);

  /// Ikkinchi haydovchi biriktirilgan — `Switch` tugmasi shunda ko'rinadi (M11).
  bool get hasCoDriver => passive.isOccupied;

  /// Ikkala slot ham bo'sh: Login ekrani, ELD uzilgan, harakat → unidentified.
  bool get isSignedOut => primary.isEmpty && coDriver.isEmpty;

  /// Faol slot pauzada va almashtiriladigan co-driver yo'q — `M-03`.
  bool get isPaused => active.isPaused;

  /// Qurilmada sessiyasi bor haydovchilar (faol yoki pauzada) — **S-M4**
  /// tozalash qaroriga shu ro'yxat kiradi (#B-130): ro'yxatdagi haydovchining
  /// lokal ma'lumoti o'chirilmaydi.
  Set<String> get occupiedDriverIds => <String>{
    for (final SessionSlotState slot in <SessionSlotState>[primary, coDriver])
      if (slot.isOccupied && slot.driverId.isNotEmpty) slot.driverId,
  };

  Map<String, Object?> toJson() => <String, Object?>{
    'active': activeSlot.wire,
    DriverSlot.primary.wire: primary.toJson(),
    DriverSlot.coDriver.wire: coDriver.toJson(),
  };

  DualSessionState withSlot(SessionSlotState slotState) => DualSessionState(
    primary: slotState.slot == DriverSlot.primary ? slotState : primary,
    coDriver: slotState.slot == DriverSlot.coDriver ? slotState : coDriver,
    activeSlot: activeSlot,
  );

  DualSessionState withActive(DriverSlot slot) =>
      DualSessionState(primary: primary, coDriver: coDriver, activeSlot: slot);

  @override
  bool operator ==(Object other) =>
      other is DualSessionState &&
      other.primary == primary &&
      other.coDriver == coDriver &&
      other.activeSlot == activeSlot;

  @override
  int get hashCode => Object.hash(primary, coDriver, activeSlot);

  @override
  String toString() => 'DualSessionState(active: ${activeSlot.wire}, $primary, $coDriver)';
}
