/// `LogDutyGrid` — `M-23` uchun 24 soatlik grid (tz-mobile §11.4).
///
/// `core/ui` dagi [DutyGrid24h] ustiga logs moduliga xos qatlamlarni qo'yadi:
/// * PC/YM belgilari (M65) — oraliq boshida kichik yorliq;
/// * event ikonkalari (`pti`, `fuel`, `certify`, `malfunction`);
/// * jamilar satri `OFF 03:06 · SB 00:00 · DR 00:00 · ON 00:00` (M98);
/// * sariq `Warning:` va qizil `Violation:` satrlari.
library;

import 'package:flutter/material.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../../../../core/hos/duty_slot.dart';
import '../../../../core/hos/violation_labels.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/day_timeline.dart';
import '../../domain/log_models.dart';

/// Grid ustidagi belgi turi (event ikonkasi).
enum LogGridMarkerKind { pti, fuel, certify, malfunction }

@immutable
class LogGridMarker {
  const LogGridMarker({required this.kind, required this.at});

  final LogGridMarkerKind kind;

  /// Kun boshidan siljish.
  final Duration at;

  IconData get icon => switch (kind) {
    LogGridMarkerKind.pti => Icons.fact_check_outlined,
    LogGridMarkerKind.fuel => Icons.local_gas_station_outlined,
    LogGridMarkerKind.certify => Icons.draw_outlined,
    LogGridMarkerKind.malfunction => Icons.warning_amber_outlined,
  };
}

/// Soat ustunining minimal kengligi — bundan tor bo'lsa grid scroll qilinadi.
const double _kMinHourWidth = 9;

class LogDutyGrid extends StatelessWidget {
  const LogDutyGrid({
    required this.spans,
    required this.totals,
    required this.alerts,
    this.markers = const <LogGridMarker>[],
    this.specialSpans = const <DaySpan>[],
    this.hourWidth = DutyGridMetrics.hourWidth,
    super.key,
  });

  final List<DaySpan> spans;
  final Map<DutyStatus, Duration> totals;
  final List<LogAlert> alerts;
  final List<LogGridMarker> markers;

  /// PC/YM rejimida o'tgan oraliqlar (M65).
  final List<DaySpan> specialSpans;

  final double hourWidth;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Figma: grid + jamilar bitta `r12` kartada (#B-08).
        AppCard(
          padding: const EdgeInsets.all(Spacing.s10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Figma: 24 soat karta kengligiga **sig'adi** (gorizontal
              // overflow yo'q); joy yetmasa scroll qoladi.
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double available =
                      constraints.maxWidth - Spacing.s5 * 2 - DutyGridMetrics.labelWidth;
                  final double fitted = available / 24;
                  final bool fits = fitted >= _kMinHourWidth;
                  final Widget grid = _GridWithMarkers(
                    spans: spans,
                    markers: markers,
                    specialSpans: specialSpans,
                    hourWidth: fits ? fitted : hourWidth,
                  );
                  return fits
                      ? grid
                      : SingleChildScrollView(scrollDirection: Axis.horizontal, child: grid);
                },
              ),
              const SizedBox(height: Spacing.s10),
              _TotalsRow(totals: totals),
            ],
          ),
        ),
        for (final LogAlert alert in alerts) ...<Widget>[
          const SizedBox(height: Spacing.s15),
          BannerStrip(
            message: alert.level == LogAlertLevel.violation
                ? l10n.logsViolationPrefix(violationTypeLabel(l10n, alert.type))
                : l10n.logsWarningPrefix(violationTypeLabel(l10n, alert.type)),
            tone: alert.level == LogAlertLevel.violation
                ? BannerTone.violation
                : BannerTone.warning,
          ),
        ],
      ],
    );
  }
}

class _GridWithMarkers extends StatelessWidget {
  const _GridWithMarkers({
    required this.spans,
    required this.markers,
    required this.specialSpans,
    required this.hourWidth,
  });

  final List<DaySpan> spans;
  final List<LogGridMarker> markers;
  final List<DaySpan> specialSpans;
  final double hourWidth;

  static const double _markerRowHeight = 18;

  double _xOf(Duration at) {
    const double daySeconds = 24 * 3600;
    final double ratio = (at.inSeconds / daySeconds).clamp(0.0, 1.0);
    // `DutyGrid24h` ichidagi padding (Spacing.s5) va qator nomlari ustuni.
    return Spacing.s5 + DutyGridMetrics.labelWidth + ratio * hourWidth * 24;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final double width = Spacing.s5 * 2 + DutyGridMetrics.labelWidth + hourWidth * 24;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: _markerRowHeight,
            child: Stack(
              children: <Widget>[
                for (final DaySpan span in specialSpans)
                  Positioned(
                    left: _xOf(span.start),
                    top: 0,
                    child: _SpecialTag(
                      label: span.status == DutyStatus.dr ? l10n.logsSpecialPc : l10n.logsSpecialYm,
                    ),
                  ),
              ],
            ),
          ),
          DutyGrid24h(
            segments: <DutySegment>[
              for (final DaySpan span in spans)
                DutySegment(slot: dutySlotOf(span.status), start: span.start, end: span.end),
            ],
            rowLabels: <DutySlot, String>{
              DutySlot.offDuty: DutyStatus.off.wire,
              DutySlot.sleeper: DutyStatus.sb.wire,
              DutySlot.driving: DutyStatus.dr.wire,
              DutySlot.onDuty: DutyStatus.on.wire,
            },
            hourWidth: hourWidth,
          ),
          SizedBox(
            height: _markerRowHeight,
            child: Stack(
              children: <Widget>[
                for (final LogGridMarker marker in markers)
                  Positioned(
                    left: _xOf(marker.at) - Spacing.s5,
                    top: 0,
                    child: Icon(marker.icon, size: Spacing.s15, color: c.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialTag extends StatelessWidget {
  const _SpecialTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s5),
      decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: Radii.pillRadius),
      child: Text(label, style: context.text.body17.copyWith(color: c.textSecondary)),
    );
  }
}

/// Jamilar satri — Figma: to'rt ustun teng taqsimlangan, har biri **o'z
/// rangida** (`AppColors.dutyColor`, #B-17: OFF kulrang · SB amber ·
/// DR yashil · ON cyan), M98.
class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.totals});

  final Map<DutyStatus, Duration> totals;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    String hm(DutyStatus code) => AppFormats.durationHm(totals[code] ?? Duration.zero);

    final Map<DutyStatus, String> labels = <DutyStatus, String>{
      DutyStatus.off: l10n.logsTotalOff(hm(DutyStatus.off)),
      DutyStatus.sb: l10n.logsTotalSb(hm(DutyStatus.sb)),
      DutyStatus.dr: l10n.logsTotalDr(hm(DutyStatus.dr)),
      DutyStatus.on: l10n.logsTotalOn(hm(DutyStatus.on)),
    };

    return Row(
      children: <Widget>[
        for (final MapEntry<DutyStatus, String> entry in labels.entries)
          Expanded(
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.body17
                  .withWeight(FontWeight.w500)
                  .copyWith(color: c.dutyColor(dutySlotOf(entry.key))),
            ),
          ),
      ],
    );
  }
}
