/// Parol kuchi indikatori (M-05 / M-07) — `PasswordPolicy.strength` natijasi.
///
/// Ranglar M81 bo'yicha ikkala temada bir xil: `error` / `warning` / `success`.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/auth_policies.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.strength, super.key});

  final PasswordStrength strength;

  static const double _barHeight = 5;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final (Color color, int filled, String label) = switch (strength) {
      PasswordStrength.weak => (colors.error, 1, context.l10n.authPasswordStrengthWeak),
      PasswordStrength.fair => (colors.warning, 2, context.l10n.authPasswordStrengthFair),
      PasswordStrength.strong => (colors.success, 3, context.l10n.authPasswordStrengthStrong),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 0; i < 3; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : Spacing.s5),
                  child: Container(
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: i < filled ? color : colors.surfaceAlt,
                      borderRadius: Radii.pillRadius,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Spacing.s5),
        Text(
          context.l10n.authPasswordStrength(label),
          style: context.text.body16.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
