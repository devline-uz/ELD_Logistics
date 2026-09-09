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
    this.strokeWidth = 12,
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

  /// Figma `1170:2684`: halqa treki progress bilan bir xil qalinlikda
  /// (~14 px) — default `12` kichikroq ekranlar uchun saqlanadi.
  final double strokeWidth;

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
                strokeWidth: strokeWidth,
                // Figma: bo'sh trek to'q kulrang (`strokeStrong`), och
                // `surfaceAlt` emas — progress bilan kontrast yetarli bo'lishi
                // uchun.
                backgroundColor: c.strokeStrong,
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
