/// `M-44`/`M-45` ro'yxat kartasi va uning qatorlari (Figma `1119:445`, `1131:392`).
///
/// O'lchovlar Figma dan: karta `r=8`, `pad=20`, qatorlar orasidagi gap `10`,
/// qator balandligi `40` (teginish maydoni M8 bo'yicha ≥48 gacha kengaytiriladi),
/// matn 14 Regular, ikonka 20×20, chevron 10×20.
///
/// TODO(D-26): Figma da qator matni `Product Sans Regular 14` — litsenziya yo'q,
/// `typography.body15` (Regular 14) eng yaqin token.
/// TODO(D-29): karta foni Figma da `#F5F5F5` (`Color's/Grey Light`) —
/// `colors.surfaceMuted` aynan shu token.
library;

import 'package:flutter/material.dart';

import '../adaptive_scaffold.dart';
import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

/// Bir nechta [SettingsRow] ni o'rab turadigan karta.
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: Spacing.s10),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Bitta band: matn + o'ngdagi chevron / toggle / qiymat.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.label,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.destructive = false,
    this.enabled = true,
    this.helper,
    this.leadingIcon,
    super.key,
  });

  /// Lokalizatsiya qilingan band nomi.
  final String label;
  final VoidCallback? onTap;

  /// Chevrondan oldingi element (badge, qiymat, toggle).
  final Widget? trailing;
  final bool showChevron;

  /// `Logout` — matn `error` rangida.
  final bool destructive;
  final bool enabled;

  /// Band ostidagi tushuntirish (masalan M143 «Required for compliance»).
  final String? helper;

  /// Chapdagi ikonka (Figma da 20×20, matngacha 10 dp) — #B-62.
  ///
  /// `null` bo'lsa qator ikonkasiz chiziladi (mavjud chaqiruvlar buzilmaydi).
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color labelColor = !enabled
        ? c.textDisabled
        : destructive
        ? c.error
        : c.textPrimary;

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
      child: Row(
        children: <Widget>[
          if (leadingIcon != null) ...<Widget>[
            Icon(leadingIcon, size: Spacing.s20, color: labelColor),
            const SizedBox(width: Spacing.s10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(label, style: context.text.body15.copyWith(color: labelColor)),
                if (helper != null) ...<Widget>[
                  const SizedBox(height: Spacing.s5),
                  Text(helper!, style: context.text.body17.copyWith(color: c.textSecondary)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[const SizedBox(width: Spacing.s10), trailing!],
          if (showChevron) ...<Widget>[
            const SizedBox(width: Spacing.s10),
            Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
          ],
        ],
      ),
    );

    if (onTap == null || !enabled) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: touchTarget(context)),
        child: content,
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.cardRadius,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: touchTarget(context)),
        child: content,
      ),
    );
  }
}

/// Figma dagi `ion:toggle` — yashil (`success`) faol holat.
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Lokalizatsiya qilingan nom (skrinrider uchun).
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Semantics(
      label: semanticLabel,
      toggled: value,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: c.onPrimary,
        activeTrackColor: c.success,
        inactiveTrackColor: c.surfaceAlt,
        inactiveThumbColor: c.textDisabled,
        trackOutlineColor: WidgetStatePropertyAll<Color>(c.stroke),
      ),
    );
  }
}
