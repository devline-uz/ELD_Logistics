/// Malfunction / diagnostic detektori (tz-mobile §10.6, M77, M78).
///
/// **Sof funksiya:** kirish — [EldFaultSnapshot], chiqish — aktiv kodlar
/// to'plami. Vaqt `TimeSource` dan snapshotga solinadi, shuning uchun testlar
/// deterministik.
library;

import 'eld_codes.dart';

/// Detektor chegaralari (tz-mobile §7.2, §10.6, M78).
abstract final class EldFaultThresholds {
  const EldFaultThresholds._();

  /// `T` — soat farqi shu qiymatdan oshsa timing malfunction.
  static const Duration timingSkew = Duration(minutes: 10);

  /// `T` diagnostic darajasi — 1 daqiqadan katta, 10 daqiqadan kichik farq.
  static const Duration timingDiagnostic = Duration(minutes: 1);

  /// `L` — harakatdagi ELD shu vaqt davomida pozitsiya bermasa.
  static const Duration positioningGap = Duration(minutes: 5);

  /// `E` — ulangan ELD shu vaqt davomida ECM kadri bermasa.
  static const Duration engineSyncGap = Duration(minutes: 5);

  /// `S` — muvaffaqiyatli push shu kundan uzoq bo'lmasa (M78).
  static const Duration dataTransferMax = Duration(days: 8);

  /// `S` diagnostic ogohlantirishi — 3 kun.
  static const Duration dataTransferWarning = Duration(days: 3);

  /// `R` — bo'sh joy shu foizdan kam bo'lsa data recording malfunction.
  static const double storageFreeMinFraction = 0.02;

  /// `P` — quvvat kadrlari orasidagi ruxsat etilgan tanaffus.
  static const Duration powerGap = Duration(minutes: 30);
}

/// Detektorga beriladigan holat kesimi.
class EldFaultSnapshot {
  const EldFaultSnapshot({
    required this.now,
    this.connected = false,
    this.moving = false,
    this.clockSkew = Duration.zero,
    this.lastEcmFrameAt,
    this.lastPositionAt,
    this.lastPowerFrameAt,
    this.lastSuccessfulPushAt,
    this.storageFreeFraction = 1,
    this.deviceReported = const <EldFaultCode>{},
    this.ignitionOn,
  });

  /// `TimeSource.now()` (UTC).
  final DateTime now;

  final bool connected;

  /// Harakatda (auto-DR detektori bergan) — `L` va `E` faqat shunda qattiq.
  final bool moving;

  /// `|telefon − ishonchli manba|` (§7.2) — `T` uchun.
  final Duration clockSkew;

  final DateTime? lastEcmFrameAt;
  final DateTime? lastPositionAt;
  final DateTime? lastPowerFrameAt;

  /// Oxirgi muvaffaqiyatli `sync/push` (M78 — `S`).
  final DateTime? lastSuccessfulPushAt;

  /// Bo'sh disk ulushi `0..1` — `R`.
  final double storageFreeFraction;

  /// Qurilma o'zi xabar qilgan kodlar (vendor `diagnostics[]`).
  final Set<EldFaultCode> deviceReported;

  final bool? ignitionOn;
}

/// P/E/T/L/R/S/O detektori.
class EldMalfunctionDetector {
  const EldMalfunctionDetector();

  /// Aktiv nosozliklar (kod → [EldFault]). Bo'sh map — hammasi joyida.
  Map<EldFaultCode, EldFault> evaluate(EldFaultSnapshot s) {
    final Map<EldFaultCode, EldFault> out = <EldFaultCode, EldFault>{};

    void add(EldFaultCode code, EldFaultKind kind, [String? detail]) {
      final EldFault? existing = out[code];
      if (existing != null && existing.kind == EldFaultKind.malfunction) {
        return; // malfunction diagnostic'dan ustun.
      }
      out[code] = EldFault(code: code, kind: kind, detectedAt: s.now, detail: detail);
    }

    // --- Qurilma o'zi xabar qilgan kodlar har doim malfunction darajasida.
    for (final EldFaultCode code in s.deviceReported) {
      add(code, EldFaultKind.malfunction);
    }

    // --- T: timing (§7.2).
    if (s.clockSkew.abs() >= EldFaultThresholds.timingSkew) {
      add(EldFaultCode.timing, EldFaultKind.malfunction, '${s.clockSkew.inMinutes}m');
    } else if (s.clockSkew.abs() >= EldFaultThresholds.timingDiagnostic) {
      add(EldFaultCode.timing, EldFaultKind.diagnostic, '${s.clockSkew.inMinutes}m');
    }

    // --- S: data transfer (M78) — ELD ulanmagan bo'lsa ham hisoblanadi.
    final DateTime? push = s.lastSuccessfulPushAt;
    if (push != null) {
      final Duration age = s.now.difference(push);
      if (age >= EldFaultThresholds.dataTransferMax) {
        add(EldFaultCode.dataTransfer, EldFaultKind.malfunction, '${age.inDays}');
      } else if (age >= EldFaultThresholds.dataTransferWarning) {
        add(EldFaultCode.dataTransfer, EldFaultKind.diagnostic, '${age.inDays}');
      }
    }

    // --- R: data recording.
    if (s.storageFreeFraction < EldFaultThresholds.storageFreeMinFraction) {
      add(EldFaultCode.dataRecording, EldFaultKind.malfunction);
    }

    if (!s.connected) {
      return Map<EldFaultCode, EldFault>.unmodifiable(out);
    }

    // --- E: engine synchronization — ulangan, lekin ECM kadri yo'q.
    if (_stale(s.now, s.lastEcmFrameAt, EldFaultThresholds.engineSyncGap)) {
      add(EldFaultCode.engineSync, EldFaultKind.malfunction);
    }

    // --- L: positioning — harakatda pozitsiya yo'q.
    if (s.moving && _stale(s.now, s.lastPositionAt, EldFaultThresholds.positioningGap)) {
      add(EldFaultCode.positioning, EldFaultKind.malfunction);
    }

    // --- P: power compliance — ignition yoqiq, lekin quvvat kadri yo'q.
    if ((s.ignitionOn ?? false) && _stale(s.now, s.lastPowerFrameAt, EldFaultThresholds.powerGap)) {
      add(EldFaultCode.power, EldFaultKind.malfunction);
    }

    return Map<EldFaultCode, EldFault>.unmodifiable(out);
  }

  static bool _stale(DateTime now, DateTime? at, Duration limit) =>
      at == null || now.difference(at) >= limit;
}
