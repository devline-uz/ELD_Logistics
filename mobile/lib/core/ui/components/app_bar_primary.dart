/// `AppBarPrimary` — barcha ekranlar uchun yagona app bar (tz-mobile §11.0.4).
///
/// Telefon: `hamburger · <sarlavha> · qo'ng'iroq · chat · sync`.
/// Planshet: chapda ELD holati, markazda sarlavha, o'ngda amallar + tema.
/// Sarlavha **parametr** sifatida keladi (`context.l10n.appTitle`).
library;

import 'package:flutter/material.dart';

import '../spacing.dart';
import '../theme.dart';

const double kAppBarHeight = 56;

class AppBarPrimary extends StatelessWidget implements PreferredSizeWidget {
  const AppBarPrimary({
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.leadingLabel,
    this.onLeadingPressed,
    this.showDivider = true,
    super.key,
  });

  /// Allaqachon lokalizatsiya qilingan sarlavha.
  final String title;

  /// Chapdagi widget. `null` va [onLeadingPressed] berilgan bo'lsa —
  /// hamburger tugmasi chiziladi.
  final Widget? leading;

  /// Hamburger tugmasining `tooltip`/`semanticsLabel` matni (lokalizatsiyalangan).
  final String? leadingLabel;

  final VoidCallback? onLeadingPressed;

  /// O'ngdagi amallar: `SyncIndicator`, qo'ng'iroq, chat, tema.
  final List<Widget> actions;

  /// Ostidagi 1 px `stroke` chizig'i.
  final bool showDivider;

  @override
  Size get preferredSize => const Size.fromHeight(kAppBarHeight + Strokes.thin);

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedLeading =
        leading ??
        (onLeadingPressed == null
            ? null
            : IconButton(
                onPressed: onLeadingPressed,
                tooltip: leadingLabel,
                icon: const Icon(Icons.menu),
                color: context.colors.textPrimary,
              ));

    return AppBar(
      backgroundColor: context.colors.surface,
      foregroundColor: context.colors.textPrimary,
      surfaceTintColor: context.colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: kAppBarHeight,
      automaticallyImplyLeading: false,
      leading: resolvedLeading,
      title: Text(
        title,
        style: context.text.body8.copyWith(color: context.colors.textPrimary),
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        ...actions,
        const SizedBox(width: Spacing.s5),
      ],
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(Strokes.thin),
              child: Container(height: Strokes.thin, color: context.colors.stroke),
            )
          : null,
    );
  }
}
