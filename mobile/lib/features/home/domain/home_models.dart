/// `M-09 Home` domen modellari (tz-mobile 1216–1243).
library;

import '../../duty_status/domain/duty_status_models.dart';
import '../../duty_status/domain/hos_snapshot.dart';

/// `Trip Details` kartasi (`M-11` shu ma'lumotni tahrirlaydi).
class TripDetails {
  const TripDetails({
    this.shippingDocs = const <String>[],
    this.trailers = const <String>[],
    this.notes = '',
  });

  final List<String> shippingDocs;
  final List<String> trailers;
  final String notes;
}

/// `Certify (Last 8 days)` nuqtalari.
class CertifyDay {
  const CertifyDay({required this.date, required this.certified, this.hasViolation = false});

  /// Home Terminal TZ dagi kun (`YYYY-MM-DD` dan tiklangan lokal sana).
  final DateTime date;
  final bool certified;
  final bool hasViolation;
}

/// ELD banneri holati.
enum HomeEldBanner { connected, notConnected, malfunction }

/// Ekranning yagona kesimi — barcha kartalar shundan chiziladi.
class HomeState {
  const HomeState({
    required this.duty,
    required this.hos,
    this.loading = true,
    this.eld = HomeEldBanner.notConnected,
    this.malfunctionCode,
    this.queuedRecords = 0,
    this.pendingEdits = 0,
    this.unidentified = 0,
    this.certifyDays = const <CertifyDay>[],
    this.trip = const TripDetails(),
    this.segments = const <DutyDaySegment>[],
  });

  /// Boshlang'ich (yuklanish) holati.
  factory HomeState.loading() =>
      HomeState(duty: DutyStatusContext.empty(), hos: HosSnapshot.empty(DateTime.utc(2000)));

  final DutyStatusContext duty;
  final HosSnapshot hos;
  final bool loading;

  final HomeEldBanner eld;

  /// Malfunction harfi (`T`, `P`, …) — banner matnida ko'rsatiladi.
  final String? malfunctionCode;

  /// Outbox'dagi yuborilmagan yozuvlar soni (offline banner).
  final int queuedRecords;

  final int pendingEdits;
  final int unidentified;
  final List<CertifyDay> certifyDays;
  final TripDetails trip;
  final List<DutyDaySegment> segments;

  DriverContext get driver => duty.driver;

  /// Bo'sh holat: unit biriktirilmagan (tz-mobile 1240).
  bool get hasUnit => driver.hasUnit;

  /// Sertifikatlanmagan kunlar bor (`Not Signed` qizil ramka).
  bool get hasUncertifiedDays => certifyDays.any((CertifyDay day) => !day.certified);

  bool get offline => queuedRecords > 0;

  HomeState copyWith({
    DutyStatusContext? duty,
    HosSnapshot? hos,
    bool? loading,
    HomeEldBanner? eld,
    String? malfunctionCode,
    int? queuedRecords,
    int? pendingEdits,
    int? unidentified,
    List<CertifyDay>? certifyDays,
    TripDetails? trip,
    List<DutyDaySegment>? segments,
  }) => HomeState(
    duty: duty ?? this.duty,
    hos: hos ?? this.hos,
    loading: loading ?? this.loading,
    eld: eld ?? this.eld,
    malfunctionCode: malfunctionCode ?? this.malfunctionCode,
    queuedRecords: queuedRecords ?? this.queuedRecords,
    pendingEdits: pendingEdits ?? this.pendingEdits,
    unidentified: unidentified ?? this.unidentified,
    certifyDays: certifyDays ?? this.certifyDays,
    trip: trip ?? this.trip,
    segments: segments ?? this.segments,
  );
}
