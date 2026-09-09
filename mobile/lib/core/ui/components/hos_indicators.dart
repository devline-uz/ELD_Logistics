/// HOS ko'rsatkichlari (tz-mobile §11.0.4, M87).
///
/// * [HosLinearIndicator] — **telefon** (393 dp da halqa kichik chiqadi).
/// * [HosRingIndicator]  — **planshet**, `CustomPainter`, chiziq 12 dp.
/// * [HosCardGrid]       — **M-09 Home**: 2×2 karta grid (#B-22).
/// * [HosRingRow]        — **M-12**: to'rtta halqa bir qatorda (#B-22).
///
/// Ikkalasi bir xil [HosBucket] modelidan ranglarni oladi (M81: HOS ranglari
/// ikkala temada bir xil). Bo'lim nomi **parametr** sifatida keladi.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../formats.dart';
import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';
import 'app_card.dart';

/// To'rtta HOS hisoblagichi.
enum HosBucket {
  /// 30-daqiqalik tanaffusgacha qolgan vaqt.
  breakTime,

  /// 11 soatlik haydash limiti.
  drive,

  /// 14 soatlik smena oynasi.
  shift,

  /// 60/70 soatlik sikl.
  cycle;

  Color color(AppColors c) => switch (this) {
    HosBucket.breakTime => c.hosBreak,
    HosBucket.drive => c.hosDrive,
    HosBucket.shift => c.hosShift,
    HosBucket.cycle => c.hosCycle,
  };
}

/// Bitta hisoblagichning ko'rinish holati.
@immutable
class HosGaugeData {
  const HosGaugeData({
    required this.bucket,
    required this.label,
    required this.remaining,
    required this.total,
  });

  final HosBucket bucket;

  /// Lokalizatsiya qilingan bo'lim nomi (`BREAK`, `DRIVE`, …).
  final String label;

  final Duration remaining;
  final Duration total;

  /// 0…1 — qolgan ulush.
  double get progress {
    if (total.inSeconds <= 0) {
      return 0;
    }
    return (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }

  /// `HH:mm` (§11.0.7).
  String get formatted => AppFormats.durationHm(remaining);

  /// Limit tugagan — matn `error` rangida ko'rsatiladi.
  bool get exhausted => remaining <= Duration.zero;
}

/// Telefon: nomi · chiziq · o'ngda `HH:mm`.
class HosLinearIndicator extends StatelessWidget {
  const HosLinearIndicator({required this.data, this.trackHeight = 8, super.key});

  final HosGaugeData data;

  /// Chiziq qalinligi (Figma: 8 dp).
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = data.bucket.color(c);

    return Semantics(
      label: data.label,
      value: data.formatted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 64,
            child: Text(
              data.label,
              style: context.text.body16.copyWith(color: c.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Spacing.s10),
          Expanded(
            child: ClipRRect(
              borderRadius: Radii.pillRadius,
              child: LinearProgressIndicator(
                value: data.progress,
                minHeight: trackHeight,
                backgroundColor: c.surfaceAlt,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: Spacing.s10),
          Text(
            data.formatted,
            style: context.text.body12.copyWith(
              color: data.exhausted ? c.error : c.textPrimary,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Planshet: halqa, markazda `HH:mm`, ostida bo'lim nomi.
class HosRingIndicator extends StatelessWidget {
  const HosRingIndicator({
    required this.data,
    this.diameter = 120,
    this.strokeWidth = 12,
    super.key,
  });

  final HosGaugeData data;

  /// Tashqi diametr (planshet uchun 120 dp).
  final double diameter;

  /// Chiziq qalinligi — tz-mobile §11.0.4: 12 dp.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = data.bucket.color(c);

    return Semantics(
      label: data.label,
      value: data.formatted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: diameter,
            height: diameter,
            child: CustomPaint(
              painter: _HosRingPainter(
                progress: data.progress,
                color: color,
                trackColor: c.surfaceAlt,
                strokeWidth: strokeWidth,
              ),
              child: Center(
                child: Text(
                  data.formatted,
                  style: context.text.body5.copyWith(
                    color: data.exhausted ? c.error : c.textPrimary,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.s10),
          // Figma: bo'lim yorlig'i **bo'lim rangida** (BREAK amber, DRIVE
          // yashil, SHIFT ko'k, CYCLE qizil) — #B-22.
          Text(data.label, style: context.text.body14.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _HosRingPainter extends CustomPainter {
  const _HosRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  /// 12 soat holatidagi ko'rsatkichdan boshlanadi.
  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) {
      return;
    }
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, _startAngle, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_HosRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}

/// M-09 Home: **2×2 karta grid** — yorliq + qiymat chipi + knobli bar (#B-22).
class HosCardIndicator extends StatelessWidget {
  const HosCardIndicator({required this.data, super.key});

  final HosGaugeData data;

  /// Bar qalinligi (Figma 6) va knob diametri (Figma 12).
  static const double trackHeight = 6;
  static const double knobSize = 12;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = data.bucket.color(c);

    return Semantics(
      label: data.label,
      value: data.formatted,
      child: AppCard(
        padding: const EdgeInsets.all(Spacing.s15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    data.label,
                    // Figma: yorliq **rangli** (#B-22).
                    style: context.text.body16.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.s10,
                    vertical: Spacing.s5 / 2,
                  ),
                  // Figma: chip **kulrang fon + to'q matn** (#B-22).
                  decoration: BoxDecoration(color: c.fillSubtle, borderRadius: Radii.badgeRadius),
                  child: Text(
                    data.formatted,
                    style: context.text.body14.copyWith(
                      color: data.exhausted ? c.error : c.textPrimary,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.s10),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width = constraints.maxWidth;
                final double filled = (width * data.progress).clamp(0.0, width);
                return SizedBox(
                  height: knobSize,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          borderRadius: Radii.pillRadius,
                        ),
                      ),
                      Container(
                        height: trackHeight,
                        width: filled,
                        decoration: BoxDecoration(color: color, borderRadius: Radii.pillRadius),
                      ),
                      Positioned(
                        left: (filled - knobSize / 2).clamp(0.0, width - knobSize),
                        child: Container(
                          width: knobSize,
                          height: knobSize,
                          decoration: BoxDecoration(
                            color: c.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: Strokes.emphasis),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// To'rt hisoblagichning 2×2 grid ko'rinishi (M-09, #B-22).
class HosCardGrid extends StatelessWidget {
  const HosCardGrid({required this.gauges, this.gap = Spacing.s10, super.key});

  final List<HosGaugeData> gauges;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (int row = 0; row * 2 < gauges.length; row++) ...<Widget>[
        if (row > 0) SizedBox(height: gap),
        // `CrossAxisAlignment.stretch` cheklanmagan balandlikda (`ListView`)
        // yiqiladi; kartalar `mainAxisSize.min` bo'lgani uchun `start` yetarli.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int col = 0; col < 2; col++) ...<Widget>[
              if (col > 0) SizedBox(width: gap),
              Expanded(
                child: row * 2 + col < gauges.length
                    ? HosCardIndicator(data: gauges[row * 2 + col])
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ],
    ],
  );
}

/// M-12: to'rtta halqa gauge bir qatorda (#B-22).
class HosRingRow extends StatelessWidget {
  const HosRingRow({required this.gauges, this.diameter = 64, this.strokeWidth = 6, super.key});

  final List<HosGaugeData> gauges;
  final double diameter;

  /// Halqa qalinligi. Qatordagi diametr kichik (64–72 dp) bo'lgani uchun
  /// standart 12 dp markazdagi `HH:mm` ni siqadi — default 6 dp.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (final HosGaugeData gauge in gauges)
        Expanded(
          child: Center(
            child: HosRingIndicator(data: gauge, diameter: diameter, strokeWidth: strokeWidth),
          ),
        ),
    ],
  );
}
