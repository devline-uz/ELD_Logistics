/// `AppNavBar` — pastki navigatsiya (Figma `BNB-19`, PARITY #B-06).
///
/// Balandlik **94**, fon `surface`, yuqorida 1 px `stroke`. Faol element —
/// `primary` fonli **50×29 r10 chip** + oq ikonka, yorliq **faqat faol**
/// elementda (Bold 14). Nofaol elementlarda yorliq chizilmaydi.
///
/// Matn **parametr** sifatida keladi (`context.l10n.nav*`).
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';
import '../typography.dart';

/// Pastki navigatsiya balandligi — Figma 94 (#B-06).
const double kNavigationBarHeight = 94;

/// Faol chip o'lchami — Figma 50×29 r10.
const Size kNavChipSize = Size(50, 29);

@immutable
class AppNavItem {
  const AppNavItem({required this.icon, required this.label, this.selectedIcon});

  final IconData icon;
  final IconData? selectedIcon;

  /// Lokalizatsiya qilingan yorliq.
  final String label;
}

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      height: kNavigationBarHeight + MediaQuery.paddingOf(context).bottom,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          top: BorderSide(color: c.stroke, width: Strokes.thin),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: _NavCell(
                item: items[i],
                selected: i == currentIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({required this.item, required this.selected, required this.onTap});

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: kNavChipSize.width,
              height: kNavChipSize.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? c.primary : c.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(Radii.navChip)),
              ),
              child: Icon(
                selected ? (item.selectedIcon ?? item.icon) : item.icon,
                size: Spacing.s20 + Spacing.s5 / 2,
                color: selected ? c.onPrimary : c.textSecondary,
              ),
            ),
            if (selected) ...<Widget>[
              const SizedBox(height: Spacing.s5),
              Text(
                item.label,
                style: context.text.body14
                    .withWeight(FontWeight.w700)
                    .copyWith(color: c.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
