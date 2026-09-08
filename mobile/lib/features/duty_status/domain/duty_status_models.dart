/// Duty status domen modellari (tz-mobile §9.1–§9.9).
///
/// `presentation` **faqat** shu modellarni ko'radi: Drift qatorlari va
/// `eld_api` DTO lari bu yerga chiqmaydi (M5).
library;

import 'package:hos_engine/hos_engine.dart';

/// Duty status qiymati. `driving` — **hech qachon qo'lda tanlanmaydi** (M51).
enum DutyStatusValue {
  off('OFF'),
  sleeper('SB'),
  driving('DR'),
  on('ON');

  const DutyStatusValue(this.wire);

  final String wire;

  /// Haydovchi qo'lda tanlashi mumkin bo'lgan uchta status (M52).
  static const List<DutyStatusValue> selectable = <DutyStatusValue>[off, sleeper, on];

  bool get isSelectable => this != DutyStatusValue.driving;

  DutyStatus get hos => switch (this) {
    DutyStatusValue.off => DutyStatus.off,
    DutyStatusValue.sleeper => DutyStatus.sb,
    DutyStatusValue.driving => DutyStatus.dr,
    DutyStatusValue.on => DutyStatus.on,
  };

  static DutyStatusValue? tryParse(String? wire) {
    for (final DutyStatusValue value in DutyStatusValue.values) {
      if (value.wire == wire) {
        return value;
      }
    }
    return null;
  }
}

/// PC/YM maxsus rejimi (tz-mobile §9.8).
enum DutySpecial {
  none('none'),
  personalConveyance('pc'),
  yardMove('ym');

  const DutySpecial(this.wire);

  final String wire;

  Special get hos => switch (this) {
    DutySpecial.none => Special.none,
    DutySpecial.personalConveyance => Special.pc,
    DutySpecial.yardMove => Special.ym,
  };

  static DutySpecial parse(String? wire) {
    for (final DutySpecial value in DutySpecial.values) {
      if (value.wire == wire) {
        return value;
      }
    }
    return DutySpecial.none;
  }

  /// PC faqat `OFF` ostida, YM faqat `ON` ostida (tz-mobile §9.8).
  DutyStatusValue? get host => switch (this) {
    DutySpecial.none => null,
    DutySpecial.personalConveyance => DutyStatusValue.off,
    DutySpecial.yardMove => DutyStatusValue.on,
  };
}

/// Haydovchi va biriktirilgan unit (`kv_settings` keshidan).
class DriverContext {
  const DriverContext({
    this.driverId = '',
    this.driverName = '',
    this.email,
    this.phone,
    this.licenseNumber,
    this.licenseState,
    this.unitId = '',
    this.unitNumber = '',
    this.vehicleLabel = '',
    this.homeTerminalTz = 'UTC',
  });

  final String driverId;
  final String driverName;
  final String? email;
  final String? phone;
  final String? licenseNumber;
  final String? licenseState;

  final String unitId;
  final String unitNumber;

  /// `BMW mi7 2019` — marka/model/yil (dizayn: unit kartasi).
  final String vehicleLabel;

  /// Kun chegarasi uchun IANA zonasi (M42).
  final String homeTerminalTz;

  /// M-09 bo'sh holati: unit biriktirilmagan (tz-mobile 1240).
  bool get hasUnit => unitId.isNotEmpty || unitNumber.isNotEmpty;
}

/// Statusni o'zgartirish formasining holati (`M-12` / `T-04`).
class DutyStatusDraft {
  const DutyStatusDraft({
    required this.status,
    this.special = DutySpecial.none,
    this.locationText = '',
    this.lat,
    this.lng,
    this.accuracyM,
    this.notes = '',
    this.reason = '',
    this.trailerIds = const <String>[],
    this.shippingDocIds = const <String>[],
  });

  final DutyStatusValue status;
  final DutySpecial special;

  /// `"12 km NE of Lahore"` (reverse geocoding, qo'lda tuzatilishi mumkin).
  final String locationText;
  final double? lat;
  final double? lng;
  final double? accuracyM;

  /// ≤60 belgi (tz-mobile §9.2).
  final String notes;

  /// PC uchun majburiy, YM uchun ixtiyoriy sabab (tz-mobile §9.8).
  final String reason;

  final List<String> trailerIds;
  final List<String> shippingDocIds;

  DutyStatusDraft copyWith({
    DutyStatusValue? status,
    DutySpecial? special,
    String? locationText,
    double? lat,
    double? lng,
    double? accuracyM,
    bool clearAccuracy = false,
    String? notes,
    String? reason,
    List<String>? trailerIds,
    List<String>? shippingDocIds,
  }) => DutyStatusDraft(
    status: status ?? this.status,
    special: special ?? this.special,
    locationText: locationText ?? this.locationText,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    accuracyM: clearAccuracy ? null : (accuracyM ?? this.accuracyM),
    notes: notes ?? this.notes,
    reason: reason ?? this.reason,
    trailerIds: trailerIds ?? this.trailerIds,
    shippingDocIds: shippingDocIds ?? this.shippingDocIds,
  );
}

/// Joriy duty holati — Drift'dagi oxirgi `status_change` eventidan.
class DutyStatusContext {
  const DutyStatusContext({
    required this.policy,
    required this.driver,
    this.current,
    this.special = DutySpecial.none,
    this.since,
    this.trailerIds = const <String>[],
    this.shippingDocIds = const <String>[],
    this.notes = '',
    this.locationText = '',
  });

  /// Bo'sh kesim — hech qanday event yo'q (birinchi ishga tushirish).
  factory DutyStatusContext.empty() =>
      DutyStatusContext(policy: defaultPolicy(), driver: const DriverContext());

  final HosPolicy policy;
  final DriverContext driver;

  /// `null` — hali birorta duty event yo'q.
  final DutyStatusValue? current;
  final DutySpecial special;

  /// Joriy statusga o'tilgan payt (UTC) — hisoblagich shundan yuradi.
  final DateTime? since;

  final List<String> trailerIds;
  final List<String> shippingDocIds;
  final String notes;
  final String locationText;

  bool get isDriving => current == DutyStatusValue.driving;

  /// `SB` tugmasi faol bo'ladimi (M52: yashirilmaydi, o'chiriladi).
  bool get sleeperAvailable => policy.sleeperBerthAvailable;

  bool get pcAllowed => policy.allowPc;
  bool get ymAllowed => policy.allowYm;

  /// Formani joriy holatdan boshlash uchun.
  DutyStatusDraft toDraft() => DutyStatusDraft(
    status: current != null && current!.isSelectable ? current! : DutyStatusValue.on,
    special: special,
    locationText: locationText,
    notes: '',
    trailerIds: trailerIds,
    shippingDocIds: shippingDocIds,
  );
}

/// Katalog elementi (`sync/pull → quick_notes[]`, M55).
class QuickNoteOption {
  const QuickNoteOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// Trailer katalogi (`GET /trailers` keshi).
class TrailerOption {
  const TrailerOption({required this.id, required this.number});

  final String id;
  final String number;

  /// `Bobtail` — maxsus qiymat (tz-mobile §9.2).
  static const String bobtailId = 'bobtail';
}

/// Statusni saqlash natijasi.
class DutyChangeResult {
  const DutyChangeResult({
    required this.clientEventId,
    required this.eventTime,
    this.queued = true,
  });

  final String clientEventId;
  final DateTime eventTime;

  /// `true` — outbox'ga tushdi (oflayn ham shu).
  final bool queued;
}
