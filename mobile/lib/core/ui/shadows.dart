/// Soya tokenlari (tz-mobile §11.0.3).
///
/// Manba: `design/figma/tokens.json` → `effects.cartsDropdown` — Figma dagi
/// yagona `DROP_SHADOW` uslubi: blur **27.25**, offset **(0, 7.79)**,
/// rang `#485966` @ **10.1 %**.
///
/// Dark temada opacity **2× pasaytiriladi** (yorug' fonda soya, qorong'uda
/// deyarli ko'rinmaydi — aks holda "iflos" halqa hosil bo'ladi).
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Figma `Carts Dropdown` o'lchamlari (o'zgartirish taqiq — M86).
abstract final class ShadowSpec {
  const ShadowSpec._();

  static const double blurRadius = 27.25;
  static const Offset offset = Offset(0, 7.79);
  static const double spreadRadius = 0;
  static const double opacityLight = 0.101;

  /// Dark: 2× pasaytirilgan.
  static const double opacityDark = opacityLight / 2;
}

@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({required this.card});

  factory AppShadows.of(Brightness brightness) => AppShadows(
    card: <BoxShadow>[
      BoxShadow(
        color: AppPalette.shadow.withValues(
          alpha: brightness == Brightness.dark ? ShadowSpec.opacityDark : ShadowSpec.opacityLight,
        ),
        blurRadius: ShadowSpec.blurRadius,
        offset: ShadowSpec.offset,
        spreadRadius: ShadowSpec.spreadRadius,
      ),
    ],
  );

  /// Karta, dropdown, bottom sheet va modal uchun yagona soya.
  final List<BoxShadow> card;

  static final AppShadows light = AppShadows.of(Brightness.light);
  static final AppShadows dark = AppShadows.of(Brightness.dark);

  @override
  AppShadows copyWith({List<BoxShadow>? card}) => AppShadows(card: card ?? this.card);

  @override
  AppShadows lerp(covariant AppShadows? other, double t) {
    if (other == null) {
      return this;
    }
    return AppShadows(card: BoxShadow.lerpList(card, other.card, t) ?? card);
  }
}
