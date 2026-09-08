/// `AppBarPrimary` — barcha ekranlar uchun yagona app bar (tz-mobile §11.0.4).
///
/// Figma parite (#B-01…#B-04): sarlavha **chapga** tekislangan, balandlik
/// **48** dp, fon `#C2C1CD` @20 %, o'ngda doimiy amal guruhi
/// `bell 24 · mail 24 · refresh 20` (gap 15).
/// Sarlavha **parametr** sifatida keladi (`context.l10n.appTitle`).
library;

import 'package:flutter/material.dart';

import '../../i18n/l10n_extension.dart';
import '../spacing.dart';
import '../theme.dart';

/// App bar balandligi — Figma 48 (#B-02).
const double kAppBarHeight = 48;

/// Home dagi kengaytirilgan variant (logotip lockup uchun).
const double kAppBarHeightHome = 54;

class AppBarPrimary extends StatelessWidget implements PreferredSizeWidget {
  const AppBarPrimary({
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.leadingLabel,
    this.onLeadingPressed,
    this.showDivider = true,
    this.showDefaultActions = true,
    this.onNotifications,
    this.onMessages,
    this.onRefresh,
    this.height = kAppBarHeight,
    this.titleWidget,
    super.key,
  });

  /// Allaqachon lokalizatsiya qilingan sarlavha.
  final String title;

  /// Sarlavha o'rniga maxsus widget (Home dagi logotip lockup).
  final Widget? titleWidget;

  /// Chapdagi widget. `null` va [onLeadingPressed] berilgan bo'lsa —
  /// hamburger tugmasi chiziladi.
  final Widget? leading;

  /// Hamburger tugmasining `tooltip`/`semanticsLabel` matni (lokalizatsiyalangan).
  final String? leadingLabel;

  final VoidCallback? onLeadingPressed;

  /// Qo'shimcha amallar — standart guruhdan **oldin** chiziladi.
  final List<Widget> actions;

  /// `false` — standart `bell · mail · refresh` guruhi chizilmaydi (#B-04).
  final bool showDefaultActions;

  final VoidCallback? onNotifications;
  final VoidCallback? onMessages;
  final VoidCallback? onRefresh;

  /// Ostidagi 1 px `stroke` chizig'i.
  final bool showDivider;

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height + (showDivider ? Strokes.thin : 0));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = context.l10nOrNull;
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
      backgroundColor: context.colors.appBarSurface,
      foregroundColor: context.colors.textPrimary,
      surfaceTintColor: context.colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: resolvedLeading == null ? _kHPad : 0,
      toolbarHeight: height,
      automaticallyImplyLeading: false,
      leading: resolvedLeading,
      title:
          titleWidget ??
          Text(
            title,
            style: context.text.body8.copyWith(color: context.colors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
      actions: <Widget>[
        ...actions,
        if (showDefaultActions) ...<Widget>[
          AppBarAction(
            icon: Icons.notifications_none_outlined,
            label: l10n?.notifTitle ?? '',
            onPressed: onNotifications,
          ),
          const SizedBox(width: Spacing.s15),
          AppBarAction(
            icon: Icons.mail_outline,
            label: l10n?.chatTitle ?? '',
            onPressed: onMessages,
          ),
          const SizedBox(width: Spacing.s15),
          AppBarAction(
            icon: Icons.refresh,
            label: l10n?.homeSync ?? '',
            size: Spacing.s20,
            onPressed: onRefresh,
          ),
        ],
        const SizedBox(width: _kHPad),
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

/// Figma `pad[12,21,12,21]` — gorizontal 21 dp (#B-01).
const double _kHPad = 21;

/// App bar amal ikonkasi — 24 dp (refresh 20), teginish maydoni 48 saqlanadi.
class AppBarAction extends StatelessWidget {
  const AppBarAction({
    required this.icon,
    required this.label,
    this.onPressed,
    this.size = 24,
    super.key,
  });

  final IconData icon;

  /// Lokalizatsiya qilingan `semanticsLabel` / `tooltip`.
  final String label;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: TouchTarget.phone,
        child: Icon(icon, size: size, color: context.colors.textPrimary),
      ),
    ),
  );
}
