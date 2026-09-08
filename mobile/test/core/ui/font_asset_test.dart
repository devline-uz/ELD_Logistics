/// D-26: kanonik shrift **Plus Jakarta Sans** haqiqatan ilovaga ulanganini
/// isbotlaydigan test.
///
/// Uch qatlam tekshiriladi:
/// 1. `pubspec.yaml` da oila e'lon qilingan va `.ttf` fayllari diskda bor;
/// 2. oila yuklanganda matn kengligi `flutter_test` ning standart shriftidan
///    farq qiladi (ya'ni `fontFamily` topilmay Roboto/test shriftiga
///    tushmayapti);
/// 3. `fontVariations: FontVariation('wght', N)` haqiqiy og'irlikni beradi —
///    variable shriftda `fontWeight` yolg'iz o'zi yetmaydi (D-26 tuzog'i).
library;

import 'dart:io';

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _regularAsset = 'assets/fonts/PlusJakartaSans-VariableFont_wght.ttf';
const String _italicAsset = 'assets/fonts/PlusJakartaSans-Italic-VariableFont_wght.ttf';

const String _probe = 'Hamburgefonstiv 0123';

double _width(TextStyle style) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: _probe, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final double w = painter.width;
  painter.dispose();
  return w;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final FontLoader loader = FontLoader(kFontFamilyBase)
      ..addFont(File(_regularAsset).readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });

  group('D-26 — Plus Jakarta Sans ilovaga ulangan', () {
    test('pubspec.yaml da oila e\'lon qilingan va fayllar diskda bor', () {
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- family: Plus Jakarta Sans'));
      expect(pubspec, contains('asset: $_regularAsset'));
      expect(pubspec, contains('asset: $_italicAsset'));
      expect(File(_regularAsset).existsSync(), isTrue, reason: 'regular .ttf yo\'q');
      expect(File(_italicAsset).existsSync(), isTrue, reason: 'italic .ttf yo\'q');
      expect(File('assets/fonts/OFL.txt').existsSync(), isTrue, reason: 'litsenziya yo\'q');
    });

    test('matn kengligi standart test shriftidan farq qiladi', () {
      final double fallback = _width(const TextStyle(fontSize: 16));
      final double jakarta = _width(AppTypography.body13Style);
      expect(
        jakarta,
        isNot(closeTo(fallback, 0.01)),
        reason: 'kenglik bir xil — oila topilmagan va fallback ishlagan',
      );
    });

    test('wght o\'qi kenglikka ta\'sir qiladi (variable shrift ishlayapti)', () {
      final double w400 = _width(AppTypography.body13Style);
      final double w700 = _width(AppTypography.body11Style);
      expect(w700, greaterThan(w400), reason: 'wght 700 kengroq bo\'lishi kerak');
    });

    test('wght o\'qi fontWeight siz ham ishlaydi (variation haqiqatan uzatiladi)', () {
      // `fontWeight` bermay, faqat `fontVariations` bilan: kenglik farqi
      // variable o'q rostdan ham shriftga uzatilayotganini isbotlaydi.
      const TextStyle thin = TextStyle(
        fontFamily: kFontFamilyBase,
        fontSize: 16,
        fontVariations: <FontVariation>[FontVariation('wght', 200)],
      );
      const TextStyle heavy = TextStyle(
        fontFamily: kFontFamilyBase,
        fontSize: 16,
        fontVariations: <FontVariation>[FontVariation('wght', 800)],
      );
      expect(_width(heavy), greaterThan(_width(thin)));
    });

    test('display1 (800) h1 (700) dan kengroq — M83 ExtraBold amalda', () {
      expect(_width(AppTypography.display1Style), greaterThan(_width(AppTypography.h1Style)));
    });
  });
}
