/// `DutyGrid24h` — 24 soatlik duty grid (tz-mobile §11.0.4).
///
/// To'rt qator (`OFF` · `SB` · `D` · `ON`), 24 ustun, har ustunda 15 daqiqalik
/// to'rt belgi. Figma parite (#B-23): soat yorliqlari **yuqorida**
/// `M · 1…12 · 1…11 · M`, grid chiziqlari **neytral** (`stroke`), duty chizig'i
/// **status rangida** (`AppColors.dutyColor`), status almashuvida **hodisa
/// nuqtasi**. Gorizontal scroll ichida ishlatiladi — widget o'zi scroll
/// qilmaydi, `minWidth` beradi.
///
/// **Matn parametr:** qator nomlari ([rowLabels]) chaqiruvchidan keladi.
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

/// Kun ichidagi bitta duty oralig'i.
///
/// [start]/[end] — kun boshidan hisoblangan siljish (24 soatgacha).
@immutable
class DutySegment {
  const DutySegment({required this.slot, required this.start, required this.end, this.label});

  final DutySlot slot;
  final Duration start;
  final Duration end;

  /// Segment ustidagi qisqa yorliq — `PC` / `YM` (M65).
  ///
  /// Matn **chaqiruvchidan** keladi (`context.l10n`), komponent ichida
  /// hard-code qilinmaydi. `null` yoki bo'sh bo'lsa hech nima chizilmaydi.
  final String? label;

  Duration get length => end - start;
}

/// Grid geometriyasi — golden testda va ekranlarda bir xil bo'lishi uchun.
abstract final class DutyGridMetrics {
  const DutyGridMetrics._();

  /// Chap ustun (qator nomlari) kengligi.
  static const double labelWidth = 40;

  /// Bir qator balandligi.
  static const double rowHeight = 24;

  /// Bir soatning minimal kengligi (24 × 24 = 576 dp).
  static const double hourWidth = 24;

  /// Tepadagi soat raqamlari zonasi.
  static const double headerHeight = 16;

  /// Hodisa nuqtasining radiusi (#B-23).
  static const double eventDotRadius = 2.5;

  static const double gridWidth = hourWidth * 24;
  static const double gridHeight = rowHeight * 4;
  static const double totalWidth = labelWidth + gridWidth;
  static const double totalHeight = headerHeight + gridHeight;
}

class DutyGrid24h extends StatelessWidget {
  const DutyGrid24h({
    required this.segments,
    required this.rowLabels,
    this.hourWidth = DutyGridMetrics.hourWidth,
    this.showHourAxis = true,
    this.midnightLabel = 'M',
    super.key,
  });

  /// Kun bo'ylab tartiblangan oraliqlar (bo'sh bo'lishi mumkin).
  final List<DutySegment> segments;

  /// `DutySlot` tartibida 4 ta lokalizatsiya qilingan nom.
  final Map<DutySlot, String> rowLabels;

  /// Bir soatning kengligi — planshetda kattaroq beriladi.
  final double hourWidth;

  /// Tepadagi `M · 1…12 · 1…11 · M` shkalasi.
  final bool showHourAxis;

  /// Yarim tun yorlig'i — Figma da `M` (#B-23). Lokalizatsiya qilingan
  /// qisqartma chaqiruvchidan kelishi mumkin.
  final String midnightLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double width = DutyGridMetrics.labelWidth + hourWidth * 24;
    final double height =
        (showHourAxis ? DutyGridMetrics.headerHeight : 0) + DutyGridMetrics.gridHeight;

    return Semantics(
      label: rowLabels.values.join(' '),
      child: Container(
        decoration: BoxDecoration(color: c.cardSurface, borderRadius: Radii.cardRadius),
        padding: const EdgeInsets.all(Spacing.s5),
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _DutyGridPainter(
              segments: segments,
              labels: <DutySlot, String>{
                for (final DutySlot slot in DutySlot.values) slot: rowLabels[slot] ?? '',
              },
              hourWidth: hourWidth,
              showHourAxis: showHourAxis,
              gridColor: c.stroke,
              gridStrongColor: c.strokeStrong,
              slotColors: <DutySlot, Color>{
                for (final DutySlot slot in DutySlot.values) slot: c.dutyColor(slot),
              },
              midnightLabel: midnightLabel,
              labelColor: c.textSecondary,
              textDirection: Directionality.of(context),
              labelStyle: context.text.body17.copyWith(color: c.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _DutyGridPainter extends CustomPainter {
  _DutyGridPainter({
    required this.segments,
    required this.labels,
    required this.hourWidth,
    required this.showHourAxis,
    required this.gridColor,
    required this.gridStrongColor,
    required this.slotColors,
    required this.midnightLabel,
    required this.labelColor,
    required this.labelStyle,
    required this.textDirection,
  });

  final List<DutySegment> segments;
  final Map<DutySlot, String> labels;
  final double hourWidth;
  final bool showHourAxis;
  final Color gridColor;
  final Color gridStrongColor;
  final Map<DutySlot, Color> slotColors;
  final String midnightLabel;
  final Color labelColor;
  final TextStyle labelStyle;
  final TextDirection textDirection;

  static const double _quarterTick = 4;

  /// `PC`/`YM` yorlig'i chizilishi uchun segmentning minimal kengligi (dp).
  static const double _minLabelWidth = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final double top = showHourAxis ? DutyGridMetrics.headerHeight : 0;
    const double left = DutyGridMetrics.labelWidth;
    const double rowH = DutyGridMetrics.rowHeight;

    final Paint grid = Paint()
      ..color = gridColor
      ..strokeWidth = Strokes.thin
      ..style = PaintingStyle.stroke;
    final Paint gridStrong = Paint()
      ..color = gridStrongColor
      ..strokeWidth = Strokes.thin
      ..style = PaintingStyle.stroke;

    // Gorizontal chiziqlar (5 ta: 4 qator chegarasi).
    for (int r = 0; r <= 4; r++) {
      final double y = top + r * rowH;
      canvas.drawLine(Offset(left, y), Offset(left + hourWidth * 24, y), gridStrong);
    }

    // Vertikal soat chiziqlari + 15 daqiqalik belgilar.
    for (int h = 0; h <= 24; h++) {
      final double x = left + h * hourWidth;
      canvas.drawLine(Offset(x, top), Offset(x, top + rowH * 4), gridStrong);
      if (showHourAxis) {
        _paintText(
          canvas,
          _hourLabel(h),
          Offset(x, 0),
          align: _TextAlignX.center,
          style: labelStyle.copyWith(fontSize: 8, height: 1, color: labelColor),
        );
      }
      if (h == 24) {
        continue;
      }
      for (int q = 1; q < 4; q++) {
        final double qx = x + hourWidth * q / 4;
        for (int r = 0; r < 4; r++) {
          final double rowTop = top + r * rowH;
          // Yuqoridan va pastdan qisqa belgilar (FMCSA grid ko'rinishi).
          canvas.drawLine(Offset(qx, rowTop), Offset(qx, rowTop + _quarterTick), grid);
          canvas.drawLine(
            Offset(qx, rowTop + rowH - _quarterTick),
            Offset(qx, rowTop + rowH),
            grid,
          );
        }
      }
    }

    // Qator nomlari.
    for (int r = 0; r < 4; r++) {
      final DutySlot slot = DutySlot.values[r];
      _paintText(
        canvas,
        labels[slot] ?? '',
        Offset(left - Spacing.s5, top + r * rowH + rowH / 2),
        align: _TextAlignX.right,
        centerY: true,
      );
    }

    _paintSegments(canvas, left: left, top: top, rowH: rowH);
  }

  /// `M · 1…12 · 1…11 · M` (#B-23).
  String _hourLabel(int h) {
    if (h == 0 || h == 24) {
      return midnightLabel;
    }
    return '${h <= 12 ? h : h - 12}';
  }

  void _paintSegments(
    Canvas canvas, {
    required double left,
    required double top,
    required double rowH,
  }) {
    if (segments.isEmpty) {
      return;
    }
    const double dayS = 24 * 3600;
    double xOf(Duration d) => left + (d.inSeconds.clamp(0, dayS.toInt()) / dayS) * hourWidth * 24;
    double yOf(DutySlot s) => top + DutySlot.values.indexOf(s) * rowH + rowH / 2;

    double? prevY;
    for (final DutySegment seg in segments) {
      final Color color = slotColors[seg.slot] ?? gridStrongColor;
      final Paint line = Paint()
        ..color = color
        ..strokeWidth = Strokes.emphasis
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke;
      final double x1 = xOf(seg.start);
      final double x2 = xOf(seg.end);
      final double y = yOf(seg.slot);
      if (prevY != null && prevY != y) {
        // Status almashuvi — vertikal ko'tarilish + hodisa nuqtasi (#B-23).
        canvas.drawLine(Offset(x1, prevY), Offset(x1, y), line);
        canvas.drawCircle(Offset(x1, y), DutyGridMetrics.eventDotRadius, Paint()..color = color);
      }
      canvas.drawLine(Offset(x1, y), Offset(x2, y), line);
      _paintSegmentLabel(canvas, seg, x1: x1, x2: x2, y: y, rowH: rowH, color: color);
      prevY = y;
    }
  }

  /// M65: `PC`/`YM` — segment chizig'i ustidagi kichik yorliq.
  ///
  /// Tor segmentda (masalan bir necha daqiqa) yorliq **chizilmaydi**: u
  /// qo'shni segmentlar ustiga tushib, gridni o'qib bo'lmaydigan qilardi.
  void _paintSegmentLabel(
    Canvas canvas,
    DutySegment seg, {
    required double x1,
    required double x2,
    required double y,
    required double rowH,
    required Color color,
  }) {
    final String? text = seg.label;
    if (text == null || text.isEmpty || x2 - x1 < _minLabelWidth) {
      return;
    }
    _paintText(
      canvas,
      text,
      Offset((x1 + x2) / 2, y - rowH / 2 + Strokes.emphasis),
      align: _TextAlignX.center,
      style: labelStyle.copyWith(fontSize: 9, height: 1, color: color),
    );
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset at, {
    required _TextAlignX align,
    bool centerY = false,
    TextStyle? style,
  }) {
    if (text.isEmpty) {
      return;
    }
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: style ?? labelStyle.copyWith(color: labelColor),
      ),
      textDirection: textDirection,
    )..layout();
    final double dx = switch (align) {
      _TextAlignX.left => at.dx,
      _TextAlignX.center => at.dx - tp.width / 2,
      _TextAlignX.right => at.dx - tp.width,
    };
    tp.paint(canvas, Offset(dx, centerY ? at.dy - tp.height / 2 : at.dy));
  }

  @override
  bool shouldRepaint(_DutyGridPainter old) =>
      old.segments != segments ||
      old.labels != labels ||
      old.hourWidth != hourWidth ||
      old.showHourAxis != showHourAxis ||
      old.gridColor != gridColor ||
      old.gridStrongColor != gridStrongColor ||
      old.midnightLabel != midnightLabel;
}

enum _TextAlignX { left, center, right }
