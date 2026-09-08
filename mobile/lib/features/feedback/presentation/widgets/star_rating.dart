/// `M-48` 1–5 yulduzli baho (Figma `1131:1149`).
///
/// To'ldirilgan yulduz `warning` (`#F6BA47`, M82), bo'sh yulduz `textSecondary`
/// (Figma da Neutral 6 — `textDisabled` juda och chiqardi).
/// Har yulduzning teginish maydoni M8 bo'yicha ≥48×48 dp.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

class StarRating extends StatelessWidget {
  const StarRating({required this.value, required this.onChanged, this.enabled = true, super.key});

  /// 1…5 yoki `null` (tanlanmagan).
  final int? value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  static const int maxStars = 5;

  /// Figma: yulduz 20×20.
  static const double starSize = 20;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double target = touchTarget(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        for (int i = 1; i <= maxStars; i++)
          Semantics(
            button: true,
            selected: value != null && i <= value!,
            label: context.l10n.feedbackStars(i),
            child: InkWell(
              onTap: enabled ? () => onChanged(i) : null,
              borderRadius: Radii.pillRadius,
              child: SizedBox(
                width: target,
                height: target,
                child: Icon(
                  Icons.star_rounded,
                  size: starSize,
                  color: value != null && i <= value! ? c.warning : c.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
