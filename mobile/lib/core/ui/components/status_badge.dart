/// `StatusBadge` — holat yorlig'i (tz-mobile §11.0.4).
///
/// Figma parite (#B-17): **to'ldirilgan to'rtburchak** `r4`, **oq matn**
/// (Uncertified = qizil fill, Certified = yashil fill, ON = ko'k, DR = yashil,
/// SB = amber). `body16` Medium. **M81:** ranglar ikkala temada bir xil.
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';
import '../typography.dart';

enum StatusTone {
  success,
  warning,
  error,

  /// Betaraf (`Not certified`, `Draft`) — `surfaceAlt` + `textSecondary`.
  neutral,

  /// Brend urg'usi (`Active`, `Current driver`).
  accent,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.tone,
    this.icon,
    this.dense = false,
    super.key,
  });

  /// Lokalizatsiya qilingan matn.
  final String label;
  final StatusTone tone;
  final IconData? icon;

  /// Ro'yxat ichida ixchamroq variant.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      StatusTone.success => (c.success, c.onPrimary),
      StatusTone.warning => (c.warning, c.onPrimary),
      StatusTone.error => (c.error, c.onPrimary),
      StatusTone.neutral => (c.surfaceAlt, c.textSecondary),
      StatusTone.accent => (c.primary, c.onPrimary),
    };

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: Radii.badgeRadius),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? Spacing.s10 : Spacing.s15,
        vertical: dense ? Spacing.s5 / 2 : Spacing.s5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: Spacing.s15, color: fg),
            const SizedBox(width: Spacing.s5),
          ],
          Text(label, style: context.text.body16.withWeight(FontWeight.w500).copyWith(color: fg)),
        ],
      ),
    );
  }
}
