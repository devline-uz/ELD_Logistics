/// `M-47 Check network` yarim doira o'lchagichi (Figma `1122:319`).
///
/// Shkala `0 · 1 · 5 · 10 · 20 · 30 · 40 · 50 · 75 · 100`, birlik `mbps`.
/// Yoy pastki chapdan (`0`) soat strelkasi bo'yicha pastki o'ngga (`100`)
/// boradi — jami **270°**. Faol qism `primary`, qolgani `surfaceAlt`.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/diagnostics_models.dart';

/// Yoyning boshlanish burchagi (radian, 3 soat yo'nalishidan hisoblanadi).
const double _startAngle = math.pi * 0.75;

/// Yoyning to'liq uzunligi.
const double _sweepAngle = math.pi * 1.5;

class NetworkGauge extends StatelessWidget {
  const NetworkGauge({required this.value, this.approximate = true, this.size = 260, super.key});

  /// `0…100` mbps. `null` — hali o'lchanmagan (yoy bo'sh).
  final double? value;

  /// M76 — `approx.` yorlig'i.
  final bool approximate;

  final double size;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppLocalizations l10n = context.l10n;
    final double? mbps = value;
    // M92 (#B-70): bo'sh qiymat — `N/A` (`AppFormats.orNa`), tire emas.
    final String text = AppFormats.orNa(mbps?.toStringAsFixed(2));

    return Semantics(
      label: mbps == null ? l10n.checkNetworkIdle : l10n.checkNetworkGaugeSemantics(text),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _GaugePainter(
            fraction: mbps == null ? 0 : gaugeFraction(mbps),
            track: c.surfaceAlt,
            active: c.primary,
            // Shkala raqamlari — `body16` tokeni (12 px Regular); painter
            // ichida `context.text` bo'lmagani uchun tayyor uslub uzatiladi.
            tickStyle: context.text.body16.copyWith(color: c.textSecondary),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  text,
                  style: context.text.display2.copyWith(color: c.textPrimary),
                  textAlign: TextAlign.center,
                ),
                Text(
                  approximate
                      ? '${l10n.checkNetworkUnit} · ${l10n.checkNetworkApprox}'
                      : l10n.checkNetworkUnit,
                  style: context.text.body15.copyWith(color: c.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.fraction,
    required this.track,
    required this.active,
    required this.tickStyle,
  });

  final double fraction;
  final Color track;
  final Color active;
  final TextStyle tickStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.09;
    final Rect rect = Offset.zero & size;
    final Rect arcRect = rect.deflate(stroke / 2 + 2);

    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(arcRect, _startAngle, _sweepAngle, false, base);

    if (fraction > 0) {
      final Paint fill = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = active;
      canvas.drawArc(arcRect, _startAngle, _sweepAngle * fraction.clamp(0, 1), false, fill);
    }

    _paintTicks(canvas, size, stroke);
  }

  void _paintTicks(Canvas canvas, Size size, double stroke) {
    final Offset centre = size.center(Offset.zero);
    final double radius = size.width / 2 - stroke - 12;
    final int last = kNetworkGaugeTicks.length - 1;

    for (int i = 0; i <= last; i++) {
      final double angle = _startAngle + _sweepAngle * (i / last);
      final Offset at = centre + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final TextPainter painter = TextPainter(
        text: TextSpan(text: kNetworkGaugeTicks[i].toInt().toString(), style: tickStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction ||
      old.active != active ||
      old.track != track ||
      old.tickStyle != tickStyle;
}
