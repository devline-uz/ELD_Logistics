/// `ThemeData` yig'ilishi va `context.colors` / `context.text` kengaytmalari.
///
/// Dark tema uchun **alohida widget nusxasi yozilmaydi** — faqat token
/// almashadi (tz-mobile §11.0 "Qat'iy taqiqlar", 6-band).
library;

import 'package:flutter/material.dart';

import 'components/app_bar_primary.dart';
import 'components/app_nav_bar.dart';
import 'radius.dart';
import 'shadows.dart';
import 'spacing.dart';
import 'tokens.dart';
import 'typography.dart';

abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppColors.light, AppShadows.light);

  static ThemeData get dark => _build(AppColors.dark, AppShadows.dark);

  static ThemeData of(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  static ThemeData _build(AppColors c, AppShadows shadows) {
    final ColorScheme scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryLight,
      onPrimaryContainer: c.textPrimary,
      secondary: c.decoBlue,
      onSecondary: c.onPrimary,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceAlt,
      onSurfaceVariant: c.textSecondary,
      error: c.error,
      onError: c.onPrimary,
      errorContainer: c.errorBg,
      onErrorContainer: c.errorDark,
      outline: c.stroke,
      outlineVariant: c.strokeStrong,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.bg,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: AppTypography.display1Style,
      displayMedium: AppTypography.display2Style,
      headlineLarge: AppTypography.h1Style,
      headlineMedium: AppTypography.h2Style,
      headlineSmall: AppTypography.h3Style,
      titleLarge: AppTypography.h4Style,
      titleMedium: AppTypography.body8Style,
      titleSmall: AppTypography.body11Style,
      bodyLarge: AppTypography.body10Style,
      bodyMedium: AppTypography.body13Style,
      bodySmall: AppTypography.body15Style,
      labelLarge: AppTypography.body12Style,
      labelMedium: AppTypography.body14Style,
      labelSmall: AppTypography.body16Style,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      dividerColor: c.stroke,
      fontFamily: kFontFamilyBase,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.stroke, thickness: Strokes.thin, space: Strokes.thin),
      // #B-01…#B-03: chapga tekislangan sarlavha, 48 dp, `#C2C1CD`@20 % fon.
      appBarTheme: AppBarTheme(
        backgroundColor: c.appBarSurface,
        foregroundColor: c.textPrimary,
        surfaceTintColor: c.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: kAppBarHeight,
        titleSpacing: Spacing.s20 + Strokes.thin,
        titleTextStyle: AppTypography.body8Style.copyWith(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.cardSurface,
        surfaceTintColor: c.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: Radii.cardRadius),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: c.transparent,
        modalBarrierColor: c.scrim,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheetRadius),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: c.transparent,
        barrierColor: c.scrim,
        shape: const RoundedRectangleBorder(borderRadius: Radii.modalRadius),
      ),
      // #B-06: BNB-19 — h 94, faol element `primary` r10 chip, yorliq faqat
      // faol elementda.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: c.transparent,
        indicatorColor: c.primary,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.navChip)),
        ),
        height: kNavigationBarHeight,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => AppTypography.body14Style
              .withWeight(FontWeight.w700)
              .copyWith(
                color: states.contains(WidgetState.selected) ? c.textPrimary : c.textSecondary,
              ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            size: Spacing.s20 + Spacing.s5 / 2,
            color: states.contains(WidgetState.selected) ? c.onPrimary : c.textSecondary,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: c.icon),
      // #B-18: iOS uslubidagi switch — yashil trek + to'liq oq thumb.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.disabled) && !states.contains(WidgetState.selected)
              ? c.surface
              : AppPalette.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? c.switchTrackOn : c.strokeStrong,
        ),
        trackOutlineColor: WidgetStatePropertyAll<Color>(c.transparent),
        trackOutlineWidth: const WidgetStatePropertyAll<double>(0),
        thumbIcon: const WidgetStatePropertyAll<Icon?>(null),
      ),
      // #B-19: tanlanmagan checkbox — qora 1.5 px kontur, r2.
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Spacing.s5 / 2.5)),
        ),
        side: BorderSide(color: c.textPrimary, width: Strokes.emphasis - 0.5),
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? c.neutralStrong : c.transparent,
        ),
        checkColor: WidgetStatePropertyAll<Color>(c.onNeutralStrong),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceAlt,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle: AppTypography.body13Style.copyWith(color: c.bg),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: Radii.buttonRadius),
      ),
      extensions: <ThemeExtension<dynamic>>[c, AppTypography.standard, shadows],
    );
  }
}

/// Widget'lar uchun yagona kirish nuqtasi.
extension AppThemeContext on BuildContext {
  /// Semantik ranglar. Tema kengaytmasi yo'q bo'lsa light ga tushadi
  /// (`showDialog` dan tashqaridagi izolyatsiyalangan testlar uchun).
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;

  /// Nomlangan matn shkalasi (`context.text.body13`).
  AppTypography get text => Theme.of(this).extension<AppTypography>() ?? AppTypography.standard;

  /// Soyalar (`context.shadows.card`).
  AppShadows get shadows => Theme.of(this).extension<AppShadows>() ?? AppShadows.light;
}
