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
    this.trailingIcon,
    this.onTrailingTap,
    this.count,
    this.dense = false,
    super.key,
  });

  /// `Bobtail ×` ko'rinishidagi o'chiriladigan chip (M-29, Figma `1083:10550`):
  /// kulrang `fillSubtle` fon, `r4` (badge) radius, matndan **keyin** `×`.
  /// [onRemove] `null` bo'lsa — o'chirib bo'lmaydigan statik qiymat.
  const AppChip.removable({required String label, required VoidCallback? onRemove, Key? key})
    : this(
        label: label,
        trailingIcon: onRemove == null ? null : Icons.close,
        onTrailingTap: onRemove,
        dense: true,
        key: key,
      );

  /// Lokalizatsiya qilingan matn.
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Matndan **keyin** keladigan ikonka (masalan `Bobtail ×`).
  final IconData? trailingIcon;

  /// [trailingIcon] bosilganda — `null` bo'lsa ikonka statik.
  final VoidCallback? onTrailingTap;

  /// O'ngdagi hisoblagich (masalan filtr natijalari soni).
  final int? count;

  /// Ixcham variant: balandligi [denseHeight], `r4` radius, `body13` matn.
  final bool dense;

  /// Figma dagi ixcham chip balandligi.
  static const double denseHeight = 32;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color fg = selected ? c.onPrimary : (dense ? c.textPrimary : c.textSecondary);
    final TextStyle style = (dense ? context.text.body13 : context.text.body16).copyWith(color: fg);

    // Ko'rinadigan qism — o'lchami o'zgarmaydi (Figma pariteti).
    final Widget pill = Container(
      height: dense ? denseHeight : null,
      alignment: dense ? Alignment.center : null,
      decoration: BoxDecoration(
        color: selected ? c.primary : (dense ? c.fillSubtle : c.surfaceAlt),
        borderRadius: dense ? Radii.badgeRadius : Radii.pillRadius,
      ),
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: Spacing.s10)
          : const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: Spacing.s15, color: fg),
            const SizedBox(width: Spacing.s5),
          ],
          Text(label, style: style),
          if (count != null) ...<Widget>[
            const SizedBox(width: Spacing.s5),
            Text(AppFormats.count(count), style: style),
          ],
          if (trailingIcon != null) ...<Widget>[
            const SizedBox(width: Spacing.s5),
            if (onTrailingTap == null)
              Icon(trailingIcon, size: Spacing.s15, color: selected ? fg : c.primary)
            else
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTrailingTap,
                child: Icon(trailingIcon, size: Spacing.s15, color: selected ? fg : c.primary),
              ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(
        container: true,
        selected: selected,
        button: onTrailingTap != null,
        label: label,
        child: pill,
      );
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
