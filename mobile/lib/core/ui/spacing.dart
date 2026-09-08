/// Spacing shkalasi (tz-mobile §11.0.3, M86 — **Figma bilan tuzatilgan**).
///
/// Manba: `design/figma/tokens.json` → `spacing`. Dizayn **5 pt bazasida**
/// (gap chastotasi: 10×193, 5×113, 15×53, 20, 25) — tz-mobile dagi 4 pt
/// taxmini xato, DIFF #D-04.
///
/// Sehrli raqam yozish taqiq: har spacing shu yerdan olinadi.
library;

abstract final class Spacing {
  const Spacing._();

  /// Baza qadami — 5 dp.
  static const double base = 5;

  static const double s5 = 5;
  static const double s10 = 10;
  static const double s15 = 15;
  static const double s20 = 20;
  static const double s25 = 25;
  static const double s30 = 30;
  static const double s40 = 40;

  /// Ruxsat etilgan shkala (lint/test uchun).
  static const List<double> scale = <double>[s5, s10, s15, s20, s25, s30, s40];

  /// Ekranning gorizontal padding'i — Figma da o'lchangan 16 dp.
  static const double screenPaddingPhone = 16;

  /// Planshetda kengroq maydon (tz-mobile §3).
  static const double screenPaddingTablet = 24;

  /// Kartalar orasidagi vertikal oraliq.
  static const double cardGap = s10;

  /// Karta ichidagi padding.
  static const double cardPadding = s15;
}

/// Chegara qalinligi (`tokens.json` → `stroke`).
abstract final class Strokes {
  const Strokes._();

  /// Standart 1 dp (histogram: 164 ta).
  static const double thin = 1;

  /// Urg'u 2 dp (fokus, tanlangan holat; histogram: 22 ta).
  static const double emphasis = 2;
}

/// Minimal teginish maydoni (tz-mobile M8).
abstract final class TouchTarget {
  const TouchTarget._();

  static const double phone = 48;
  static const double tablet = 56;

  /// Haydash rejimi — barmoq bilan qarashsiz bosish.
  static const double driving = 64;
}
