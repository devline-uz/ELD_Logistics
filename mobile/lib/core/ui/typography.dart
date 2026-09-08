/// Tipografika tokenlari (tz-mobile §11.0.2, M83/M84/M85).
///
/// Qiymatlar manbai: `design/figma/tokens.json` → `typography` (23 token).
/// Figma faylda TEXT STYLE yo'q — o'lchamlar `Typography` seksiyasidagi namuna
/// matn tugunlaridan o'qilgan.
///
/// **lineHeight** (DIFF #D-28): Figma matn tugunlarining 60.3 % i `AUTO` —
/// ular Plus Jakarta Sans metrikasi bo'yicha `round(fontSize × 1.26)` oladi.
/// Aniq `lh` berilgan tokenlar (39.7 % tugun) o'z qiymatida qoladi:
/// `body5` / `body6` = 120 %, `body7` = 150 % (CR-F01 / M84, DIFF #D-02).
library;

import 'package:flutter/material.dart';

/// Barcha matn uchun kanonik oila (DIFF #D-26 yopildi).
///
/// Plus Jakarta Sans — SIL OFL 1.1,
/// `assets/fonts/PlusJakartaSans-VariableFont_wght.ttf`.
/// Fayl **variable** (`wght` o'qi 200…800), shuning uchun `pubspec.yaml` da
/// oila bir marta e'lon qilinadi va og'irlik [FontVariation] bilan beriladi.
const String kFontFamilyBase = 'Plus Jakarta Sans';

/// M83 yopildi: Product Sans litsenziyasi olinmadi, `display1/display2`
/// Plus Jakarta Sans **ExtraBold (800)** bilan chiziladi — bu oilaning eng
/// og'ir kesimi va maketdagi display'ga eng yaqini.
const String kFontFamilyDisplay = kFontFamilyBase;

/// Plus Jakarta Sans Latin/Latin-Ext qamrab oladi. Yo'q glif (masalan kirill
/// yoki emoji) uchun ro'yxat **atayin bo'sh**: engine platformaning tizim
/// shriftiga o'zi tushadi, aniq oila nomi esa golden'larda determinizmni
/// buzardi (test bundle'ida faqat pubspec shriftlari yuklanadi).
const List<String> kFontFamilyFallback = <String>[];

/// **D-28** — Figma matn tugunlarining 60.3 % i (998/1656) `lineHeight: AUTO`
/// ishlatadi, ya'ni qator balandligini shriftning o'z metrikasi belgilaydi.
/// Plus Jakarta Sans uchun bu nisbat aniq **1.26** (`(1000 + 260) / 1000`).
///
/// Flutter'da `height: null` qoldirish **yetarli emas**: u platforma
/// metrikasiga tayanadi va Figma'dan farq qiladi. Shu sababli har uslubda
/// aniq `height` beriladi: `round(fontSize × 1.26) / fontSize`.
///
/// Piksel jadvali: 10→13 · 12→15 · 14→18 · 16→20 · 18→23 · 20→25 · 24→30 ·
/// 26→33 · 32→40 · 40→50 · 48→60. (DIFF.md matnidagi «20→26 · 24→31» —
/// arifmetik xato: `round(20 × 1.26) = 25`, `round(24 × 1.26) = 30`;
/// o'lchangan qatorlar 10…18 va ular formulaga to'liq mos.)
/// 20 pt daraja (`body5`/`body6`) baribir `AUTO` emas — pastdagi `_lh120`.
const double _autoLineHeightRatio = 1.26;

/// `AUTO` qator balandligini pikselga yaxlitlab, `height` koeffitsiyentiga
/// qaytaradi (Figma butun piksel bilan ishlaydi, shuning uchun avval `round`).
double _autoHeight(double size) => (size * _autoLineHeightRatio).roundToDouble() / size;

/// Figma'da **aniq** `lh` berilgan tokenlar `AUTO` nisbatiga bo'ysunmaydi.
///
/// * `_lh120` — 20 pt daraja (`body5`, `body6`): `design/figma/tokens.json` da
///   `lineHeight: "120%"`, va `screens/*.json` dagi **barcha** `fs = 20`
///   tugunida `lh = 24` (24 / 20 = 120 %) — `AUTO` bitta marta ham yo'q.
/// * `_lh150` — `body7` (30 / 20 = 150 %), CR-F01 bo'yicha `body6` dan
///   **faqat** shu bilan farq qiladi.
const double _lh120 = 1.2;
const double _lh150 = 1.5;

const FontWeight _regular = FontWeight.w400;
const FontWeight _medium = FontWeight.w500;
const FontWeight _semiBold = FontWeight.w600;
const FontWeight _bold = FontWeight.w700;
const FontWeight _extraBold = FontWeight.w800;

/// Variable shriftda og'irlik **faqat** `wght` o'qi orqali ishlaydi: bitta
/// `.ttf` uchun `fontWeight` yolg'iz o'zi hech narsani o'zgartirmaydi (Flutter
/// og'irlikni interpolatsiya qilmaydi va hamma matn Regular chiqadi).
/// Shu sababli har uslubda `fontWeight` bilan birga `fontVariations` beriladi.
List<FontVariation> _wght(FontWeight weight) => <FontVariation>[
  FontVariation('wght', weight.value.toDouble()),
];

/// [height] berilmasa `AUTO` (D-28) hisoblanadi; aniq qiymat faqat Figma'da
/// `lh` ko'rsatilgan tokenlar uchun beriladi.
TextStyle _style(double size, FontWeight weight, {double? height, String? family}) => TextStyle(
  fontFamily: family ?? kFontFamilyBase,
  fontFamilyFallback: kFontFamilyFallback,
  fontSize: size,
  fontWeight: weight,
  fontVariations: _wght(weight),
  height: height ?? _autoHeight(size),
  // Rang bermaymiz: `DefaultTextStyle`/`context.colors` beradi.
);

/// Variable shriftda og'irlikni to'g'ri almashtirish uchun yordamchi.
///
/// `style.copyWith(fontWeight: ...)` yolg'iz o'zi **ishlamaydi** — `wght` o'qi
/// eski qiymatda qolib, matn baribir Regular chiziladi. Shu sababli og'irlik
/// har doim shu kengaytma orqali beriladi.
extension AppTextStyleWeight on TextStyle {
  TextStyle withWeight(FontWeight weight) =>
      copyWith(fontWeight: weight, fontVariations: _wght(weight));
}

/// Nomlangan matn shkalasi. Widget'da `context.text.body13` orqali olinadi.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography();

  /// Yagona instans — tipografika temaga bog'liq emas (rang alohida beriladi).
  static const AppTypography standard = AppTypography();

  // --- Display (Product Sans o'rniga Plus Jakarta Sans ExtraBold, M83) ---
  static final TextStyle display1Style = _style(48, _extraBold, family: kFontFamilyDisplay);
  static final TextStyle display2Style = _style(40, _extraBold, family: kFontFamilyDisplay);

  // --- Heading ---
  static final TextStyle h1Style = _style(48, _bold);
  static final TextStyle h2Style = _style(40, _bold);
  static final TextStyle h3Style = _style(32, _bold);
  static final TextStyle h4Style = _style(24, _medium);

  // --- Body 1…17 ---
  static final TextStyle body1Style = _style(26, _semiBold);
  static final TextStyle body2Style = _style(26, _medium);
  static final TextStyle body3Style = _style(24, _bold);
  static final TextStyle body4Style = _style(24, _regular);
  static final TextStyle body5Style = _style(20, _bold, height: _lh120);
  static final TextStyle body6Style = _style(20, _regular, height: _lh120);

  /// `body6` dan **faqat** lineHeight bilan farq qiladi (150 %) — DIFF #D-02.
  static final TextStyle body7Style = _style(20, _regular, height: _lh150);

  static final TextStyle body8Style = _style(18, _bold);
  static final TextStyle body9Style = _style(18, _medium);
  static final TextStyle body10Style = _style(18, _regular);
  static final TextStyle body11Style = _style(16, _bold);
  static final TextStyle body12Style = _style(16, _medium);
  static final TextStyle body13Style = _style(16, _regular);
  static final TextStyle body14Style = _style(14, _medium);
  static final TextStyle body15Style = _style(14, _regular);
  static final TextStyle body16Style = _style(12, _regular);
  static final TextStyle body17Style = _style(10, _regular);

  TextStyle get display1 => display1Style;
  TextStyle get display2 => display2Style;
  TextStyle get h1 => h1Style;
  TextStyle get h2 => h2Style;
  TextStyle get h3 => h3Style;
  TextStyle get h4 => h4Style;
  TextStyle get body1 => body1Style;
  TextStyle get body2 => body2Style;
  TextStyle get body3 => body3Style;
  TextStyle get body4 => body4Style;
  TextStyle get body5 => body5Style;
  TextStyle get body6 => body6Style;
  TextStyle get body7 => body7Style;
  TextStyle get body8 => body8Style;
  TextStyle get body9 => body9Style;
  TextStyle get body10 => body10Style;
  TextStyle get body11 => body11Style;
  TextStyle get body12 => body12Style;
  TextStyle get body13 => body13Style;
  TextStyle get body14 => body14Style;
  TextStyle get body15 => body15Style;
  TextStyle get body16 => body16Style;
  TextStyle get body17 => body17Style;

  /// Katalog ekrani uchun `nom → uslub` xaritasi (23 ta).
  static Map<String, TextStyle> get all => <String, TextStyle>{
    'display1': display1Style,
    'display2': display2Style,
    'h1': h1Style,
    'h2': h2Style,
    'h3': h3Style,
    'h4': h4Style,
    'body1': body1Style,
    'body2': body2Style,
    'body3': body3Style,
    'body4': body4Style,
    'body5': body5Style,
    'body6': body6Style,
    'body7': body7Style,
    'body8': body8Style,
    'body9': body9Style,
    'body10': body10Style,
    'body11': body11Style,
    'body12': body12Style,
    'body13': body13Style,
    'body14': body14Style,
    'body15': body15Style,
    'body16': body16Style,
    'body17': body17Style,
  };

  @override
  AppTypography copyWith() => const AppTypography();

  @override
  AppTypography lerp(covariant AppTypography? other, double t) => this;
}

/// **M85 [MUST]** — `textScaler` chegaralari.
const double kMinTextScale = 0.85;
const double kMaxTextScale = 1.3;

/// M94 `Zoom` toggle darajalari (haydovchi uchun yiriklashtirish).
enum ZoomLevel {
  /// Standart — foydalanuvchi tizim sozlamasi qanday bo'lsa shunday.
  normal(1.0),

  /// Yiriklashtirilgan ko'rinish (kabina, quyosh ostida).
  large(1.3);

  const ZoomLevel(this.factor);

  final double factor;

  ZoomLevel get toggled => this == ZoomLevel.normal ? ZoomLevel.large : ZoomLevel.normal;
}

/// Tizim `textScaler` ini [ZoomLevel] bilan birlashtirib 0.85…1.3 ga qisadi.
TextScaler clampedTextScaler(TextScaler system, ZoomLevel zoom) {
  final double scaled = system.scale(100) / 100 * zoom.factor;
  return TextScaler.linear(scaled.clamp(kMinTextScale, kMaxTextScale));
}

/// `MediaQuery.textScaler` ni M85 chegarasida ushlab turadigan o'ram.
///
/// `MaterialApp.builder` da bir marta o'raladi — ekranlarda takrorlanmaydi.
class TextScaleGuard extends StatelessWidget {
  const TextScaleGuard({required this.child, this.zoom = ZoomLevel.normal, super.key});

  final Widget child;
  final ZoomLevel zoom;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaler: clampedTextScaler(data.textScaler, zoom)),
      child: child,
    );
  }
}
