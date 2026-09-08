/// Tipografika — 23 token, M84 (body6 ≠ body7), M85 (textScaler clamp).
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_test_harness.dart';

void main() {
  group('AppTypography — tokens.json qiymatlari', () {
    test('23 ta nomlangan token', () {
      expect(AppTypography.all.length, 23);
    });

    test('o\'lchamlar va og\'irliklar aynan mos', () {
      final Map<String, (double, FontWeight)> expected = <String, (double, FontWeight)>{
        'display1': (48, FontWeight.w800),
        'display2': (40, FontWeight.w800),
        'h1': (48, FontWeight.w700),
        'h2': (40, FontWeight.w700),
        'h3': (32, FontWeight.w700),
        'h4': (24, FontWeight.w500),
        'body1': (26, FontWeight.w600),
        'body2': (26, FontWeight.w500),
        'body3': (24, FontWeight.w700),
        'body4': (24, FontWeight.w400),
        'body5': (20, FontWeight.w700),
        'body6': (20, FontWeight.w400),
        'body7': (20, FontWeight.w400),
        'body8': (18, FontWeight.w700),
        'body9': (18, FontWeight.w500),
        'body10': (18, FontWeight.w400),
        'body11': (16, FontWeight.w700),
        'body12': (16, FontWeight.w500),
        'body13': (16, FontWeight.w400),
        'body14': (14, FontWeight.w500),
        'body15': (14, FontWeight.w400),
        'body16': (12, FontWeight.w400),
        'body17': (10, FontWeight.w400),
      };
      for (final MapEntry<String, (double, FontWeight)> e in expected.entries) {
        final TextStyle? s = AppTypography.all[e.key];
        expect(s, isNotNull, reason: '${e.key} yo\'q');
        expect(s!.fontSize, e.value.$1, reason: '${e.key} fontSize');
        expect(s.fontWeight, e.value.$2, reason: '${e.key} fontWeight');
      }
    });

    // --- D-28 regressiya: har tokenda aniq `height` ---------------------
    //
    // Figma'da `AUTO` bo'lgan tugunlar Plus Jakarta Sans metrikasini oladi
    // (nisbat 1.26 → `round(fontSize x 1.26)` px). Aniq `lh` berilganlari
    // quyidagi xaritada — ular formulaga bo'ysunmaydi.
    //
    // Bu ro'yxat **atayin qo'lda** yozilgan: `typography.dart` da uslub
    // `height: null` bilan qo'shilsa yoki mavjud qiymat sezdirmay o'zgarsa,
    // CI shu testda yiqiladi.
    const Map<String, double> explicitLh = <String, double>{
      'body5': 1.2, // tokens.json 120 % + screens: barcha fs=20 tuguni lh=24
      'body6': 1.2, // CR-F01 / M84
      'body7': 1.5, // CR-F01 / M84 — body6 dan farqi faqat shu
    };

    double autoLhPx(double fs) => (fs * 1.26).roundToDouble();

    test('D-28: AUTO tokenlar lineHeight = round(fontSize x 1.26) px', () {
      // Coordinator o'lchovidagi jadval (D-28) — formulani mustaqil tekshiradi.
      const Map<int, int> px = <int, int>{
        10: 13,
        12: 15,
        14: 18,
        16: 20,
        18: 23,
        20: 25,
        24: 30,
        26: 33,
        32: 40,
        40: 50,
        48: 60,
      };
      for (final MapEntry<int, int> e in px.entries) {
        expect(autoLhPx(e.key.toDouble()), e.value.toDouble(), reason: '${e.key} px');
      }

      for (final MapEntry<String, TextStyle> e in AppTypography.all.entries) {
        if (explicitLh.containsKey(e.key)) {
          continue; // aniq qiymat — pastdagi testda.
        }
        final double fs = e.value.fontSize!;
        expect(e.value.height, isNotNull, reason: '${e.key}: height null (D-28 buzildi)');
        expect(px.containsKey(fs.round()), isTrue, reason: '${e.key}: $fs px jadvalda yo\'q');
        expect(
          e.value.height! * fs,
          closeTo(autoLhPx(fs), 0.0001),
          reason: '${e.key} lineHeight px',
        );
      }
    });

    test('D-28: aniq lh berilgan tokenlar — body5/body6 = 120 %, body7 = 150 %', () {
      for (final MapEntry<String, double> e in explicitLh.entries) {
        expect(AppTypography.all[e.key]!.height, e.value, reason: '${e.key} lineHeight');
      }
      // Yig'indi: 23 tokendan 3 tasi aniq, qolgani AUTO.
      expect(AppTypography.all.keys.where(explicitLh.containsKey).length, explicitLh.length);
    });

    test('D-28: hech bir tokenda height null emas', () {
      for (final MapEntry<String, TextStyle> e in AppTypography.all.entries) {
        expect(e.value.height, isNotNull, reason: e.key);
      }
    });

    test('M84 tuzatildi: body6 va body7 bir xil emas (lineHeight farqi)', () {
      expect(AppTypography.body6Style.fontSize, AppTypography.body7Style.fontSize);
      expect(AppTypography.body6Style.height, isNot(AppTypography.body7Style.height));
      expect(AppTypography.body6Style, isNot(AppTypography.body7Style));
    });

    test('M83: display oilasi Plus Jakarta Sans ExtraBold (800)', () {
      expect(kFontFamilyDisplay, kFontFamilyBase);
      expect(AppTypography.display1Style.fontFamily, kFontFamilyBase);
      expect(AppTypography.display1Style.fontWeight, FontWeight.w800);
      expect(AppTypography.display2Style.fontWeight, FontWeight.w800);
    });

    test('D-26: barcha tokenlar Plus Jakarta Sans oilasida', () {
      expect(kFontFamilyBase, 'Plus Jakarta Sans');
      for (final TextStyle s in AppTypography.all.values) {
        expect(s.fontFamily, kFontFamilyBase);
      }
    });

    test('variable shrift: har tokenda wght o\'qi fontWeight ga teng', () {
      for (final MapEntry<String, TextStyle> e in AppTypography.all.entries) {
        final List<FontVariation>? v = e.value.fontVariations;
        expect(v, isNotNull, reason: '${e.key} da fontVariations yo\'q');
        expect(v!.length, 1, reason: '${e.key} da faqat wght kutilgan');
        expect(v.single.axis, 'wght', reason: '${e.key} o\'qi');
        expect(
          v.single.value,
          e.value.fontWeight!.value.toDouble(),
          reason: '${e.key} wght ≠ fontWeight',
        );
      }
    });

    test('withWeight fontWeight bilan wght o\'qini birga o\'zgartiradi', () {
      final TextStyle s = AppTypography.body16Style.withWeight(FontWeight.w700);
      expect(s.fontWeight, FontWeight.w700);
      expect(s.fontVariations, <FontVariation>[const FontVariation('wght', 700)]);
      expect(s.fontSize, AppTypography.body16Style.fontSize);
    });

    test('rang tokenda emas (widget beradi)', () {
      for (final TextStyle s in AppTypography.all.values) {
        expect(s.color, isNull);
      }
    });
  });

  group('M85 — textScaler clamp 0.85…1.3', () {
    test('chegaralar', () {
      expect(kMinTextScale, 0.85);
      expect(kMaxTextScale, 1.3);
    });

    test('juda kichik va juda katta masshtab qisiladi', () {
      expect(clampedTextScaler(TextScaler.noScaling, ZoomLevel.normal).scale(100), 100);
      expect(
        clampedTextScaler(const TextScaler.linear(0.5), ZoomLevel.normal).scale(100),
        closeTo(85, 0.001),
      );
      expect(
        clampedTextScaler(const TextScaler.linear(3), ZoomLevel.normal).scale(100),
        closeTo(130, 0.001),
      );
    });

    test('M94 Zoom.large tizim masshtabiga ko\'paytiriladi va qisiladi', () {
      expect(
        clampedTextScaler(TextScaler.noScaling, ZoomLevel.large).scale(100),
        closeTo(130, 0.001),
      );
      expect(
        clampedTextScaler(const TextScaler.linear(1.2), ZoomLevel.large).scale(100),
        closeTo(130, 0.001),
      );
      expect(ZoomLevel.normal.toggled, ZoomLevel.large);
      expect(ZoomLevel.large.toggled, ZoomLevel.normal);
    });

    testWidgets('TextScaleGuard MediaQuery ni qisadi', (WidgetTester tester) async {
      late TextScaler observed;
      await pumpUi(
        tester,
        const TextScaleGuard(zoom: ZoomLevel.large, child: _Probe()),
        textScale: 2,
      );
      observed = _Probe.last!;
      expect(observed.scale(100), closeTo(130, 0.001));
    });
  });
}

class _Probe extends StatelessWidget {
  const _Probe();

  static TextScaler? last;

  @override
  Widget build(BuildContext context) {
    last = MediaQuery.textScalerOf(context);
    return const SizedBox.shrink();
  }
}
