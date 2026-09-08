/// `M-15` ning katta hisoblagichi: halqa + `HH:mm:ss` + status nomi.
library;

import 'package:flutter/material.dart';

import '../../../../core/ui/ui.dart';

class DriveTimerRing extends StatelessWidget {
  const DriveTimerRing({
    required this.elapsed,
    required this.label,
    required this.progress,
    required this.color,
    this.diameter = 240,
    super.key,
  });

  /// Joriy statusda o'tgan vaqt.
  final Duration elapsed;

  /// `DRIVE` — lokalizatsiya qilingan bo'lim nomi.
  final String label;

  /// 0…1 — qolgan haydash vaqtining ulushi.
  final double progress;

  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Semantics(
      label: label,
      value: AppFormats.durationHms(elapsed),
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 12,
                backgroundColor: c.surfaceAlt,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppFormats.durationHms(elapsed),
                  style: context.text.h4.copyWith(
                    color: c.textPrimary,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
                Text(label, style: context.text.body6.copyWith(color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
