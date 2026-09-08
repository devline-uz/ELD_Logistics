/// Auth ekranlarining umumiy qobig'i — Figma `958:44 Login` geometriyasi.
///
/// O'lchovlar (393 dp freym, status bar 59 dp):
/// * logotip `119.7×69` @ y=113 → SafeArea ostidan 54 dp;
/// * forma bloki `345` dp keng, x=24 → gorizontal padding **24**;
/// * logotip pastidan formagacha 102 dp;
/// * blok ichidagi vertikal oraliq `Spacing.s25`;
/// * footer `393×72`, ustida 1 px `stroke` chizig'i, matn markazda.
///
/// Telefon va planshet **bitta** kontrollerni ulashadi (M7) — bu yerda faqat
/// ko'rinish farq qiladi: planshetda forma markazlashtiriladi va kengligi
/// [kAuthFormMaxWidthTablet] bilan cheklanadi.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

/// Figma `958:44`: `(393 − 345) / 2 = 24`.
///
/// `Spacing` shkalasi 5 pt bazasida (5·10·15·20·25·30·40) — 24 unda yo'q.
/// TODO(D-31): `Spacing.screenPaddingAuth = 24` tokeni qo'shilsin.
const double kAuthFormPaddingH = 24;

/// Figma: forma bloki 345 dp.
const double kAuthFormWidthPhone = 345;

/// Planshetda forma cho'zilmaydi (M6) — o'qish qulayligi uchun cheklanadi.
const double kAuthFormMaxWidthTablet = 480;

/// Logotip bilan freym tepasi orasidagi masofa (113 − 59 status bar).
const double kAuthLogoTopGap = 54;

/// Logotip pastidan forma tepasigacha (284 − 113 − 69).
const double kAuthLogoToFormGap = 102;

/// Figma `Header` freymi balandligi.
const double kAuthFooterHeight = 72;

/// Auth ekranlari uchun yagona sahifa qobig'i.
class AuthShell extends StatelessWidget {
  const AuthShell({
    required this.children,
    this.banners = const <Widget>[],
    this.showLogo = true,
    this.footer,
    this.header,
    super.key,
  });

  /// Forma bloki elementlari; oraliq [Spacing.s25] avtomatik qo'yiladi.
  final List<Widget> children;

  /// App bar o'rnidagi doimiy qatorlar (offline, sessiya almashtirildi).
  final List<Widget> banners;

  final bool showLogo;

  /// Pastdagi 72 dp li chiziqli qator (M-02 da `Copyright ©`).
  final Widget? footer;

  /// Logotip ostidagi ixtiyoriy sarlavha bloki (M-03 pauza qilingan haydovchi).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final double maxWidth = adaptiveValue<double>(
      context,
      phone: double.infinity,
      tablet: kAuthFormMaxWidthTablet,
    );

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ...banners,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: kAuthFormPaddingH),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (showLogo) ...<Widget>[
                          const SizedBox(height: kAuthLogoTopGap),
                          const Center(child: AuthBrandLogo()),
                          const SizedBox(height: kAuthLogoToFormGap),
                        ] else
                          const SizedBox(height: Spacing.s25),
                        if (header != null) ...<Widget>[
                          header!,
                          const SizedBox(height: Spacing.s25),
                        ],
                        ..._spaced(children),
                        const SizedBox(height: Spacing.s25),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (footer != null) AuthFooter(child: footer!),
          ],
        ),
      ),
    );
  }

  static List<Widget> _spaced(List<Widget> items) {
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) {
        out.add(const SizedBox(height: Spacing.s25));
      }
      out.add(items[i]);
    }
    return out;
  }
}

/// Figma `Header` — 72 dp, ustida 1 px chegara, matn markazda.
class AuthFooter extends StatelessWidget {
  const AuthFooter({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    height: kAuthFooterHeight,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: context.colors.stroke, width: Strokes.thin),
      ),
    ),
    child: DefaultTextStyle(
      style: context.text.body15.copyWith(color: context.colors.textPrimary),
      textAlign: TextAlign.center,
      child: child,
    ),
  );
}

/// OneBook ELD logotipi.
///
/// Figma da bu **rastr rasm** (`WhatsApp Image 2024-08-13…`) — dizayn paketida
/// eksport qilingan SVG/PNG yo'q. TODO(D-30): `assets/images/logo_onebook.svg`
/// so'ralsin; shu paytgacha wordmark tipografiya bilan chiziladi.
class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({this.compact = false, super.key});

  /// Splash (M-01) da logotip kattaroq: Figma `200.39×115.52`.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextStyle accent = (compact ? context.text.h3 : context.text.h2).copyWith(
      color: colors.primary,
    );
    final TextStyle rest = (compact ? context.text.h4 : context.text.h3).copyWith(
      color: colors.textPrimary,
      letterSpacing: Strokes.emphasis,
    );

    return Semantics(
      label: context.l10n.authBrandName,
      image: true,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.authWordmarkAccent, style: accent),
            Text(context.l10n.authWordmarkRest, style: rest),
          ],
        ),
      ),
    );
  }
}

/// Figma `Category / Small` — 345×65, r8, fon `#F5F5F5`, padding 15/10,
/// ikonka 20 dp + 10 dp oraliq, matn 12/18.
///
/// `#F5F5F5` = `AppPalette.greyLight` → semantik token `surfaceMuted`.
class AuthNoticeCard extends StatelessWidget {
  const AuthNoticeCard({required this.message, this.icon = Icons.info_rounded, super.key});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.s10, vertical: Spacing.s15),
    decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: Radii.cardRadius),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: Spacing.s20, color: context.colors.textSecondary),
        const SizedBox(width: Spacing.s10),
        Expanded(
          child: Text(
            message,
            textAlign: TextAlign.justify,
            style: context.text.body16.copyWith(color: context.colors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

/// Forma ostidagi inline xato satri (M-02 «xato» holati).
class AuthErrorText extends StatelessWidget {
  const AuthErrorText({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Icon(Icons.error_outline, size: Spacing.s20, color: context.colors.error),
      const SizedBox(width: Spacing.s10),
      Expanded(
        child: Text(message, style: context.text.body16.copyWith(color: context.colors.error)),
      ),
    ],
  );
}
