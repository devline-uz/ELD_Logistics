/// Burchak radiusi tokenlari (tz-mobile §11.0.3, M86 — **Figma bilan tuzatilgan**).
///
/// Manba: `design/figma/tokens.json` → `radius`. 10 ta kanonik ekran freymidagi
/// barcha `cornerRadius` chastotasi: `8`×56, `4`×30, `24`×25, `12`×4, `200`×6.
///
/// **27.25 qiymati ekranlarda umuman uchramaydi** — u `Carts Dropdown`
/// soyasining blur radiusi. tz-mobile §11.0.3 uni burchak radiusi deb talqin
/// qilgan (DIFF #D-01), shuning uchun bu yerda ishlatilmaydi.
library;

import 'package:flutter/widgets.dart';

abstract final class Radii {
  const Radii._();

  static const double sm = 4;

  /// Dominant qiymat — karta, blok, ro'yxat elementi.
  static const double md = 8;

  /// Tugma va kirish maydoni.
  static const double lg = 12;

  /// Bottom sheet, katta modal, avatar bloklari.
  static const double xl = 24;

  /// Stadion (chip, badge, pill tugma). Figma da 200 sifatida yozilgan.
  static const double pill = 200;

  // --- Semantik aliaslar ---

  /// Karta va dropdown.
  static const double card = md;

  static const double button = lg;
  static const double input = lg;
  static const double chip = pill;
  static const double badge = pill;

  /// `AppBottomSheet` yuqori burchaklari.
  static const double sheet = xl;

  /// `TabletModal`.
  static const double modal = xl;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius modalRadius = BorderRadius.all(Radius.circular(modal));
  static const BorderRadius sheetRadius = BorderRadius.vertical(top: Radius.circular(sheet));
}
