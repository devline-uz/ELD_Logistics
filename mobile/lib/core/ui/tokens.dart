/// Dizayn tokenlari — ranglar (tz-mobile §11.0.1, M81/M82).
///
/// **Yagona fayl** bo'lib, unda `Color(0x…)` literali bo'lishi mumkin
/// (`tool/check_forbidden.sh` #3). Boshqa hamma joyda `context.colors.<token>`.
///
/// Qiymatlar manbai: `design/figma/tokens.json` (Figma `ELD Software` fayli,
/// `Branding & Color` sahifasi, 40 ta PAINT STYLE). Matnli tavsif bilan
/// ziddiyatda Figma **kanonik** (DIFF.md).
library;

import 'package:flutter/material.dart';

/// Xom palitra — Figma paint style'lari 1:1. Semantik ma'no yo'q,
/// to'g'ridan-to'g'ri UI da ishlatilmaydi: faqat [AppColors] orqali.
abstract final class AppPalette {
  const AppPalette._();

  // --- Color's/* (brend) ---
  /// `Color's/Primary Color`.
  static const Color primary = Color(0xFFB7002C);

  /// `Color's/Light` — primary ustidagi ochiq fon.
  static const Color primaryLight = Color(0xFFEFF4FB);

  /// `Color's/Bg Light`.
  static const Color bgLight = Color(0xFFFCFCFD);

  /// `Color's/Bg Dark`.
  static const Color bgDark = Color(0xFF1B222C);

  /// Karta foni — light. tz-mobile §11.0.1 `#FFFFFF` (DIFF #D-07).
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// `Color's/Grey Dark` — karta foni, dark.
  static const Color surfaceDark = Color(0xFF303E4B);

  /// `Color's/Grey Light` (#F5F5F5) — Figma dagi karta/blok foni (DIFF #D-07).
  static const Color greyLight = Color(0xFFF5F5F5);

  /// `GREY` — jadval sarlavhasi / ikkilamchi yuza, light.
  static const Color grey = Color(0xFFF2F4F7);

  /// `Color's/Sidebar` — drawer va planshet yon paneli (dark).
  static const Color sidebar = Color(0xFF233040);

  /// `Color's/Stroke`.
  static const Color stroke = Color(0xFFE5E7EB);

  /// `Color's/Dark stroke`.
  static const Color strokeDark = Color(0xFF52565F);

  /// Oq — primary ustidagi matn/ikonka.
  static const Color white = Color(0xFFFFFFFF);

  /// To'liq shaffof (`Colors.transparent` o'rniga — taqiqlar grepi #3).
  static const Color transparent = Color(0x00000000);

  /// `ink` — ekranlarda **eng ko'p** uchraydigan rang (D-29: 1085 marta, shundan
  /// 1036 tasi ikonka `VECTOR` fill/stroke). Light temadagi ikonka siyohi.
  /// `neutral9` (#23262F) emas: Figma ikonkalari aynan shu qiymatda.
  static const Color ink = Color(0xFF000314);

  /// App bar tinti va yupqa ajratgich chiziqlari — `#C2C1CD` @ 20 %
  /// (D-29: 76 marta). Alfa [AppColors.overlaySoft] da qo'llanadi.
  static const Color overlay = Color(0xFFC2C1CD);

  /// Karta to'ldirishi — Figma `#F6F6F6` (#B-08).
  static const Color cardFill = Color(0xFFF6F6F6);

  /// Ikkilamchi CTA to'ldirishi — Figma `#F2F2F5` (#B-14).
  static const Color neutralFill = Color(0xFFF2F2F5);

  /// iOS uslubidagi switch yoqilgan treki — Figma `#22C55E` (#B-18).
  static const Color switchTrackOn = Color(0xFF22C55E);

  /// ELD banneri — Figma `#D70004` (#B-25).
  static const Color alertRed = Color(0xFFD70004);

  // --- Neutral 1…11 ---
  static const Color neutral1 = Color(0xFFFCFCFD);
  static const Color neutral2 = Color(0xFFF4F5F6);
  static const Color neutral3 = Color(0xFFE6E8EC);
  static const Color neutral4 = Color(0xFFD6D8E0);
  static const Color neutral5 = Color(0xFFB1B5C3);
  static const Color neutral6 = Color(0xFF777E90);
  static const Color neutral7 = Color(0xFF3F4352);
  static const Color neutral8 = Color(0xFF353945);
  static const Color neutral9 = Color(0xFF23262F);
  static const Color neutral10 = Color(0xFF1C1E24);
  static const Color neutral11 = Color(0xFF18191D);

  /// 1-dan 11-gacha tartibda (katalog ekrani uchun).
  static const List<Color> neutrals = <Color>[
    neutral1,
    neutral2,
    neutral3,
    neutral4,
    neutral5,
    neutral6,
    neutral7,
    neutral8,
    neutral9,
    neutral10,
    neutral11,
  ];

  // --- State (M81: ikkala temada bir xil) ---
  static const Color successBg = Color(0xFFC5EFD8);
  static const Color success = Color(0xFF2FA766);
  static const Color successDark = Color(0xFF103923);

  /// «Kuchli» yashil — ekranlarda `DRIVE` yorlig'i va HOS diagramma matni
  /// (D-29: 102 marta). [success] ning yuqori kontrastli matn varianti.
  static const Color successStrong = Color(0xFF358D0C);

  /// M82: kanonik warning — `#F6BA47`. Dizayndagi `#F9B385` yozuvi xato.
  static const Color warningBg = Color(0xFFFCEAC8);
  static const Color warning = Color(0xFFF6BA47);
  static const Color warningDark = Color(0xFF7B5D24);

  /// «Kuchli» to'q sariq — ekranlarda `BREAK` yorlig'i (D-29: 47 marta).
  /// [warning] ning yuqori kontrastli matn varianti (M82 buzilmaydi).
  static const Color warningStrong = Color(0xFFD97D28);

  static const Color errorBg = Color(0xFFF9DADB);
  static const Color error = Color(0xFFE2464A);
  static const Color errorDark = Color(0xFF5A1C1E);

  // --- Decorative (7 ta, M81: ikkala temada bir xil) ---
  static const Color decoPink = Color(0xFFEE4E68);
  static const Color decoTeal = Color(0xFF30B0C7);
  static const Color decoGreen = Color(0xFF47BB75);
  static const Color decoPurple = Color(0xFF7E5EF7);
  static const Color decoOrange = Color(0xFFF5693D);
  static const Color decoYellow = Color(0xFFF7CB46);
  static const Color decoBlue = Color(0xFF466FF7);

  /// Katalog ekrani va diagramma seriyalari uchun tartib.
  static const List<Color> decoratives = <Color>[
    decoPink,
    decoTeal,
    decoGreen,
    decoPurple,
    decoOrange,
    decoYellow,
    decoBlue,
  ];

  /// `Carts Dropdown` soyasining rangi (10.1 % shaffoflik bilan).
  static const Color shadow = Color(0xFF485966);
}

/// Semantik rang tokenlari.
///
/// **M81 [MUST]** — konstruktor faqat temaga bog'liq maydonlarni oladi
/// (`bg`, `surface*`, `sidebar`, `stroke*`, `text*`, skeleton). State,
/// decorative va HOS ranglari `getter` sifatida qattiq bog'langan: ular ikkala
/// temada **bir xil** va almashtirib bo'lmaydi.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceMuted,
    required this.sidebar,
    required this.stroke,
    required this.strokeStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.icon,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  /// Light tema (tz-mobile §11.0.1).
  static const AppColors light = AppColors(
    brightness: Brightness.light,
    bg: AppPalette.bgLight,
    surface: AppPalette.surfaceLight,
    surfaceAlt: AppPalette.grey,
    surfaceMuted: AppPalette.greyLight,
    sidebar: AppPalette.surfaceLight,
    stroke: AppPalette.stroke,
    strokeStrong: AppPalette.neutral4,
    textPrimary: AppPalette.neutral9,
    textSecondary: AppPalette.neutral6,
    textDisabled: AppPalette.neutral5,
    icon: AppPalette.ink,
    skeletonBase: AppPalette.neutral3,
    skeletonHighlight: AppPalette.neutral2,
  );

  /// Dark tema (tz-mobile §11.0.1).
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    bg: AppPalette.bgDark,
    surface: AppPalette.surfaceDark,
    surfaceAlt: AppPalette.sidebar,
    surfaceMuted: AppPalette.sidebar,
    sidebar: AppPalette.sidebar,
    stroke: AppPalette.strokeDark,
    strokeStrong: AppPalette.neutral6,
    textPrimary: AppPalette.neutral1,
    textSecondary: AppPalette.neutral5,
    textDisabled: AppPalette.neutral6,
    icon: AppPalette.neutral1,
    skeletonBase: AppPalette.neutral7,
    skeletonHighlight: AppPalette.strokeDark,
  );

  final Brightness brightness;

  /// Ekran foni (`Scaffold.backgroundColor`).
  final Color bg;

  /// Karta / panel foni.
  final Color surface;

  /// Jadval sarlavhasi, tanlanmagan chip, ikkilamchi blok.
  final Color surfaceAlt;

  /// Figma `Color's/Grey Light` — kirish maydoni va yumshoq bloklar (DIFF #D-07).
  final Color surfaceMuted;

  /// Drawer va planshet yon paneli.
  final Color sidebar;

  /// 1 px chegara (`Strokes.thin`).
  final Color stroke;

  /// 2 px urg'uli chegara (`Strokes.emphasis`).
  final Color strokeStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  /// Ikonka siyohi — barcha `Icon` uchun `IconTheme` default'i (D-29).
  ///
  /// Light: `#000314` (Figma ekranlaridagi 1036 ta ikonka `VECTOR` fill).
  /// Dark: `#FCFCFD` — dark etalonlarda (`png_ref/*__dark.jpg`) ikonkalar oq.
  final Color icon;

  /// `LoadingSkeleton` asosiy toni.
  final Color skeletonBase;

  /// `LoadingSkeleton` shimmer toni.
  final Color skeletonHighlight;

  bool get isDark => brightness == Brightness.dark;

  // --- M81: temaga bog'liq BO'LMAGAN tokenlar ---

  Color get primary => AppPalette.primary;
  Color get primaryLight => AppPalette.primaryLight;

  /// `primary` ustidagi matn/ikonka.
  Color get onPrimary => AppPalette.white;

  Color get success => AppPalette.success;
  Color get successBg => AppPalette.successBg;
  Color get successDark => AppPalette.successDark;

  /// [success] ning yuqori kontrastli varianti — kichik matn/yorliq uchun
  /// (Figma `DRIVE` yorlig'i, D-29). M81: ikkala temada bir xil.
  Color get successStrong => AppPalette.successStrong;

  Color get warning => AppPalette.warning;
  Color get warningBg => AppPalette.warningBg;
  Color get warningDark => AppPalette.warningDark;

  /// [warning] ning yuqori kontrastli varianti — Figma `BREAK` yorlig'i (D-29).
  /// M81: ikkala temada bir xil; M82 dagi `#F6BA47` o'zgarmaydi.
  Color get warningStrong => AppPalette.warningStrong;

  Color get error => AppPalette.error;
  Color get errorBg => AppPalette.errorBg;
  Color get errorDark => AppPalette.errorDark;

  /// HOS: 30-daqiqalik tanaffus.
  Color get hosBreak => AppPalette.warning;

  /// HOS: 11 soatlik haydash.
  Color get hosDrive => AppPalette.success;

  /// HOS: 14 soatlik smena.
  Color get hosShift => AppPalette.decoBlue;

  /// HOS: 60/70 soatlik sikl.
  Color get hosCycle => AppPalette.primary;

  /// Duty grid chiziqlari.
  Color get gridLine => AppPalette.decoBlue;

  Color get decoPink => AppPalette.decoPink;
  Color get decoTeal => AppPalette.decoTeal;
  Color get decoGreen => AppPalette.decoGreen;
  Color get decoPurple => AppPalette.decoPurple;
  Color get decoOrange => AppPalette.decoOrange;
  Color get decoYellow => AppPalette.decoYellow;
  Color get decoBlue => AppPalette.decoBlue;

  /// Neytral («inverse») to'ldirilgan yuza — M-47 `Check Network` tugmasi
  /// (Figma `1122:319`, fill `#1C1E24`, matn `#FCFCFD`; #B-63).
  ///
  /// M81 istisnosi: dark temada fon `#1B222C` bilan qo'shilib ketmasligi uchun
  /// teskarisiga almashadi — bu **yuza** tokeni, state/HOS rangi emas.
  Color get neutralStrong => isDark ? AppPalette.neutral1 : AppPalette.neutral10;

  /// [neutralStrong] ustidagi matn/ikonka.
  Color get onNeutralStrong => isDark ? AppPalette.neutral10 : AppPalette.neutral1;

  /// App bar foni — `#C2C1CD` @20 % `surface` ustida (#B-03).
  Color get appBarSurface => Color.alphaBlend(overlaySoft, surface);

  /// Karta yuzasi — Figma `#F6F6F6`, chegarasiz (#B-08).
  Color get cardSurface => isDark ? surfaceAlt : AppPalette.cardFill;

  /// Ikkilamchi CTA / segmented konteyner to'ldirishi (#B-14, #B-15).
  Color get fillSubtle => isDark ? surfaceAlt : AppPalette.neutralFill;

  /// `AppSwitch` yoqilgan holatdagi treki (#B-18).
  Color get switchTrackOn => AppPalette.switchTrackOn;

  /// ELD banneri foni (#B-25).
  Color get alert => AppPalette.alertRed;

  /// Modal ortidagi qoraytirish — `#1C1E24` @ 35 %.
  Color get scrim => AppPalette.neutral10.withValues(alpha: 0.35);

  /// App bar tinti va yupqa ajratgichlar — `#C2C1CD` @ 20 % (D-29).
  Color get overlaySoft => AppPalette.overlay.withValues(alpha: 0.20);

  /// Soya rangi (opacity `AppShadows` da qo'llanadi).
  Color get shadow => AppPalette.shadow;

  /// Shaffof — Material'ning `surfaceTint` va ortiqcha fonlarini o'chirish uchun.
  Color get transparent => AppPalette.transparent;

  /// Duty status rangi (`OFF`/`SB`/`D`/`ON`) — grid va badge uchun yagona manba.
  Color dutyColor(DutySlot slot) => switch (slot) {
    DutySlot.offDuty => AppPalette.neutral6,
    DutySlot.sleeper => AppPalette.warning,
    DutySlot.driving => AppPalette.success,
    DutySlot.onDuty => AppPalette.decoTeal,
  };

  @override
  AppColors copyWith({
    Brightness? brightness,
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceMuted,
    Color? sidebar,
    Color? stroke,
    Color? strokeStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? icon,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) => AppColors(
    brightness: brightness ?? this.brightness,
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    sidebar: sidebar ?? this.sidebar,
    stroke: stroke ?? this.stroke,
    strokeStrong: strokeStrong ?? this.strokeStrong,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled: textDisabled ?? this.textDisabled,
    icon: icon ?? this.icon,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      strokeStrong: Color.lerp(strokeStrong, other.strokeStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
    );
  }
}

/// Duty status slotlari — grid va rang mapping uchun (tz-mobile §9).
///
/// Bu **UI darajasidagi** enum: domen modeli `features/duty_status/domain` da.
enum DutySlot { offDuty, sleeper, driving, onDuty }
