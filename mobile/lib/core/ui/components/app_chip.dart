/// `AppChip` — filtr/tanlov chipi (tz-mobile §11.0.4).
///
/// Radius `pill`, matn `body16`. Tanlanganda fon `primary` + oq matn,
/// aks holda `surfaceAlt`.
///
/// **B-80 (M8):** chipning ko'rinadigan balandligi Figma bo'yicha ~34 dp,
/// lekin teginish maydoni [touchTarget] gacha (telefon 48 / planshet 56)
/// kengaytiriladi: rangli «tabletka» o'z o'lchamida qoladi, uni shaffof
/// `ConstrainedBox` o'raydi va `InkWell` butun shu maydonni qamrab oladi.
/// Chip interaktiv bo'lmasa (`onTap == null`) — bu talab qo'llanmaydi va
/// chip o'zining ixcham o'lchamida qoladi (statik badge ko'rinishi).
library;

import 'package:flutter/material.dart';

import '../adaptive_scaffold.dart';
import '../formats.dart';
import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.count,
    super.key,
  });

  /// Lokalizatsiya qilingan matn.
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// O'ngdagi hisoblagich (masalan filtr natijalari soni).
  final int? count;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color fg = selected ? c.onPrimary : c.textSecondary;

    // Ko'rinadigan qism — o'lchami o'zgarmaydi (Figma pariteti).
    final Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? c.primary : c.surfaceAlt,
        borderRadius: Radii.pillRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: Spacing.s15, color: fg),
              const SizedBox(width: Spacing.s5),
            ],
            Text(label, style: context.text.body16.copyWith(color: fg)),
            if (count != null) ...<Widget>[
              const SizedBox(width: Spacing.s5),
              Text(AppFormats.count(count), style: context.text.body16.copyWith(color: fg)),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) {
      return Semantics(container: true, selected: selected, label: label, child: pill);
    }

    final double target = touchTarget(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      container: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: target, minHeight: target),
            child: Center(widthFactor: 1, heightFactor: 1, child: pill),
          ),
        ),
      ),
    );
  }
}
