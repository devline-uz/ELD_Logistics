/// Rang tokenlari — `design/figma/tokens.json` bilan moslik va M81/M82.
library;

import 'dart:convert';
import 'dart:io';

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPalette — Figma qiymatlari', () {
    test('brend va yuza ranglari tokens.json bilan bir xil', () {
      expect(AppPalette.primary.toARGB32(), 0xFFB7002C);
      expect(AppPalette.primaryLight.toARGB32(), 0xFFEFF4FB);
      expect(AppPalette.bgLight.toARGB32(), 0xFFFCFCFD);
      expect(AppPalette.bgDark.toARGB32(), 0xFF1B222C);
      expect(AppPalette.surfaceDark.toARGB32(), 0xFF303E4B);
      expect(AppPalette.sidebar.toARGB32(), 0xFF233040);
      expect(AppPalette.stroke.toARGB32(), 0xFFE5E7EB);
      expect(AppPalette.strokeDark.toARGB32(), 0xFF52565F);
      expect(AppPalette.greyLight.toARGB32(), 0xFFF5F5F5);
      expect(AppPalette.grey.toARGB32(), 0xFFF2F4F7);
    });

    test('neutral shkalasi 11 pog\'onali va tartibi to\'g\'ri', () {
      expect(AppPalette.neutrals.length, 11);
      expect(AppPalette.neutrals.first.toARGB32(), 0xFFFCFCFD);
      expect(AppPalette.neutrals.last.toARGB32(), 0xFF18191D);
    });

    test('M82: warning kanonik #F6BA47 (#F9B385 emas)', () {
      expect(AppPalette.warning.toARGB32(), 0xFFF6BA47);
      expect(AppPalette.warning.toARGB32(), isNot(0xFFF9B385));
    });

    test('decorative 7 ta', () {
      expect(AppPalette.decoratives.length, 7);
    });
  });

  group('AppColors — ikki tema', () {
    test('light: bg/surface/stroke/text tz-mobile §11.0.1 bo\'yicha', () {
      const AppColors c = AppColors.light;
      expect(c.bg.toARGB32(), 0xFFFCFCFD);
      expect(c.surface.toARGB32(), 0xFFFFFFFF);
      expect(c.surfaceAlt.toARGB32(), 0xFFF2F4F7);
      expect(c.surfaceMuted.toARGB32(), 0xFFF5F5F5);
      expect(c.stroke.toARGB32(), 0xFFE5E7EB);
      expect(c.textPrimary.toARGB32(), 0xFF23262F);
      expect(c.textSecondary.toARGB32(), 0xFF777E90);
      expect(c.isDark, isFalse);
    });

    test('dark: bg #1B222C, surface #303E4B, sidebar #233040', () {
      const AppColors c = AppColors.dark;
      expect(c.bg.toARGB32(), 0xFF1B222C);
      expect(c.surface.toARGB32(), 0xFF303E4B);
      expect(c.sidebar.toARGB32(), 0xFF233040);
      expect(c.stroke.toARGB32(), 0xFF52565F);
      expect(c.textPrimary.toARGB32(), 0xFFFCFCFD);
      expect(c.textSecondary.toARGB32(), 0xFFB1B5C3);
      expect(c.isDark, isTrue);
    });

    test('M81: state, decorative, HOS va primary ikkala temada BIR XIL', () {
      const AppColors l = AppColors.light;
      const AppColors d = AppColors.dark;
      final Map<String, (Color, Color)> pairs = <String, (Color, Color)>{
        'primary': (l.primary, d.primary),
        'success': (l.success, d.success),
        'successBg': (l.successBg, d.successBg),
        'successDark': (l.successDark, d.successDark),
        'warning': (l.warning, d.warning),
        'warningBg': (l.warningBg, d.warningBg),
        'warningDark': (l.warningDark, d.warningDark),
        'successStrong': (l.successStrong, d.successStrong),
        'warningStrong': (l.warningStrong, d.warningStrong),
        'error': (l.error, d.error),
        'errorBg': (l.errorBg, d.errorBg),
        'errorDark': (l.errorDark, d.errorDark),
        'hosBreak': (l.hosBreak, d.hosBreak),
        'hosDrive': (l.hosDrive, d.hosDrive),
        'hosShift': (l.hosShift, d.hosShift),
        'hosCycle': (l.hosCycle, d.hosCycle),
        'gridLine': (l.gridLine, d.gridLine),
        'decoPink': (l.decoPink, d.decoPink),
        'decoBlue': (l.decoBlue, d.decoBlue),
        'scrim': (l.scrim, d.scrim),
      };
      for (final MapEntry<String, (Color, Color)> e in pairs.entries) {
        expect(e.value.$1, e.value.$2, reason: 'M81 buzildi: ${e.key}');
      }
    });

    test('faqat bg/surface/stroke/text almashadi', () {
      expect(AppColors.light.bg, isNot(AppColors.dark.bg));
      expect(AppColors.light.surface, isNot(AppColors.dark.surface));
      expect(AppColors.light.stroke, isNot(AppColors.dark.stroke));
      expect(AppColors.light.textPrimary, isNot(AppColors.dark.textPrimary));
    });

    test('HOS ranglari to\'rt bo\'lim uchun turlicha', () {
      const AppColors c = AppColors.light;
      final Set<Color> unique = <Color>{c.hosBreak, c.hosDrive, c.hosShift, c.hosCycle};
      expect(unique.length, 4);
    });

    test('dutyColor har slot uchun barqaror', () {
      const AppColors c = AppColors.light;
      // #B-17 (Figma): ON=cyan, DR=yashil, SB=amber, OFF=kulrang.
      expect(c.dutyColor(DutySlot.driving), c.hosDrive);
      expect(c.dutyColor(DutySlot.onDuty), c.decoTeal);
      expect(c.dutyColor(DutySlot.sleeper), c.warning);
      expect(c.dutyColor(DutySlot.offDuty), AppPalette.neutral6);
    });

    test('lerp faqat temaga bog\'liq maydonlarni aralashtiradi', () {
      final AppColors mid = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(mid.primary, AppPalette.primary);
      expect(mid.bg, isNot(AppColors.light.bg));
    });

    test('copyWith faqat berilgan maydonni o\'zgartiradi', () {
      final AppColors c = AppColors.light.copyWith(bg: AppPalette.neutral11);
      expect(c.bg, AppPalette.neutral11);
      expect(c.surface, AppColors.light.surface);
    });
  });

  group('tokens.json ↔ tokens.dart sinxronligi (D-29)', () {
    /// `design/figma/tokens.json` — **kanonik** manba; `AppPalette` undan
    /// ko'chirma. Har token uchun: Dart maydoni ↔ JSON yo'li.
    late final Map<String, dynamic> json =
        jsonDecode(File('design/figma/tokens.json').readAsStringSync()) as Map<String, dynamic>;

    String hexAt(List<String> path) {
      Object? node = json;
      for (final String key in path) {
        node = (node! as Map<String, dynamic>)[key];
      }
      if (node is Map<String, dynamic>) {
        node = node['hex'];
      }
      return (node! as String).toUpperCase();
    }

    String dartHex(Color c) =>
        '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

    final Map<String, (Color, List<String>)> mapping = <String, (Color, List<String>)>{
      'primary': (AppPalette.primary, <String>['colors', 'primary']),
      'primaryLight': (AppPalette.primaryLight, <String>['colors', 'light']),
      'bgLight': (AppPalette.bgLight, <String>['colors', 'bgLight']),
      'bgDark': (AppPalette.bgDark, <String>['colors', 'bgDark']),
      'greyLight': (AppPalette.greyLight, <String>['colors', 'surfaceLight']),
      'surfaceDark': (AppPalette.surfaceDark, <String>['colors', 'surfaceDark']),
      'grey': (AppPalette.grey, <String>['colors', 'grey']),
      'sidebar': (AppPalette.sidebar, <String>['colors', 'sidebar']),
      'stroke': (AppPalette.stroke, <String>['colors', 'stroke']),
      'strokeDark': (AppPalette.strokeDark, <String>['colors', 'strokeDark']),
      'white': (AppPalette.white, <String>['colors', 'white']),
      'ink': (AppPalette.ink, <String>['colors', 'ink']),
      'overlay': (AppPalette.overlay, <String>['colors', 'overlay']),
      'successBg': (AppPalette.successBg, <String>['state', 'success', 'bg']),
      'success': (AppPalette.success, <String>['state', 'success', 'base']),
      'successDark': (AppPalette.successDark, <String>['state', 'success', 'dark']),
      'successStrong': (AppPalette.successStrong, <String>['state', 'success', 'strong']),
      'warningBg': (AppPalette.warningBg, <String>['state', 'warning', 'bg']),
      'warning': (AppPalette.warning, <String>['state', 'warning', 'base']),
      'warningDark': (AppPalette.warningDark, <String>['state', 'warning', 'dark']),
      'warningStrong': (AppPalette.warningStrong, <String>['state', 'warning', 'strong']),
      'errorBg': (AppPalette.errorBg, <String>['state', 'error', 'bg']),
      'error': (AppPalette.error, <String>['state', 'error', 'base']),
      'errorDark': (AppPalette.errorDark, <String>['state', 'error', 'dark']),
      'decoPink': (AppPalette.decoPink, <String>['decorative', 'pink']),
      'decoTeal': (AppPalette.decoTeal, <String>['decorative', 'teal']),
      'decoGreen': (AppPalette.decoGreen, <String>['decorative', 'green']),
      'decoPurple': (AppPalette.decoPurple, <String>['decorative', 'purple']),
      'decoOrange': (AppPalette.decoOrange, <String>['decorative', 'orange']),
      'decoYellow': (AppPalette.decoYellow, <String>['decorative', 'yellow']),
      'decoBlue': (AppPalette.decoBlue, <String>['decorative', 'blue']),
    };

    test('har bir AppPalette tokeni tokens.json bilan bit-to-bit mos', () {
      for (final MapEntry<String, (Color, List<String>)> e in mapping.entries) {
        expect(
          dartHex(e.value.$1),
          hexAt(e.value.$2),
          reason: 'AppPalette.${e.key} ≠ tokens.json[${e.value.$2.join('.')}]',
        );
      }
    });

    test('neutral shkalasi 1:1 tokens.json dan', () {
      final Map<String, dynamic> n = json['neutral'] as Map<String, dynamic>;
      expect(n.length, AppPalette.neutrals.length);
      for (int i = 0; i < AppPalette.neutrals.length; i++) {
        expect(dartHex(AppPalette.neutrals[i]), (n['${i + 1}']! as String).toUpperCase());
      }
    });

    test('D-29: ikonka rangi light da #000314, dark da #FCFCFD', () {
      expect(AppColors.light.icon, AppPalette.ink);
      expect(AppColors.dark.icon, AppPalette.neutral1);
      expect(AppTheme.light.iconTheme.color, AppColors.light.icon);
      expect(AppTheme.dark.iconTheme.color, AppColors.dark.icon);
    });

    test('overlaySoft — #C2C1CD @ 20 %', () {
      expect(dartHex(AppColors.light.overlaySoft), '#C2C1CD');
      expect(AppColors.light.overlaySoft.a, closeTo(0.20, 1e-3));
      expect(AppColors.light.overlaySoft, AppColors.dark.overlaySoft);
    });
  });

  group('AppTheme', () {
    test('light/dark ThemeData da AppColors kengaytmasi bor', () {
      expect(AppTheme.light.extension<AppColors>(), AppColors.light);
      expect(AppTheme.dark.extension<AppColors>(), AppColors.dark);
      expect(AppTheme.of(Brightness.dark).brightness, Brightness.dark);
    });

    test('scaffold foni va ColorScheme tokenlardan keladi', () {
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.light.bg);
      expect(AppTheme.dark.colorScheme.primary, AppPalette.primary);
      expect(AppTheme.dark.colorScheme.error, AppPalette.error);
    });

    test('AppShadows: dark opacity light dan 2× kichik', () {
      expect(ShadowSpec.opacityDark, closeTo(ShadowSpec.opacityLight / 2, 1e-9));
      expect(AppShadows.light.card.single.blurRadius, 27.25);
      expect(AppShadows.light.card.single.offset, const Offset(0, 7.79));
      expect(AppShadows.dark.card.single.color.a, lessThan(AppShadows.light.card.single.color.a));
    });
  });
}
