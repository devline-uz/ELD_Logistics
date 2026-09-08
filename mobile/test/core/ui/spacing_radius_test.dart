/// Spacing / radius / stroke tokenlari — Figma o'lchovlari (M86, DIFF #D-01/#D-04).
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spacing — 5 pt baza', () {
    test('shkala 5/10/15/20/25/30/40', () {
      expect(Spacing.base, 5);
      expect(Spacing.scale, <double>[5, 10, 15, 20, 25, 30, 40]);
    });

    test('har qadam bazaga karrali', () {
      for (final double v in Spacing.scale) {
        expect(v % Spacing.base, 0, reason: '$v 5 ga bo\'linmaydi');
      }
    });

    test('ekran padding: telefon 16, planshet 24', () {
      expect(Spacing.screenPaddingPhone, 16);
      expect(Spacing.screenPaddingTablet, 24);
    });

    test('teginish maydonlari M8 ga mos', () {
      expect(TouchTarget.phone, 48);
      expect(TouchTarget.tablet, 56);
      expect(TouchTarget.driving, 64);
    });
  });

  group('Radii — Figma histogrammasi', () {
    test('kanonik qiymatlar', () {
      expect(Radii.sm, 4);
      expect(Radii.md, 8);
      expect(Radii.lg, 12);
      expect(Radii.xl, 24);
      expect(Radii.pill, 200);
    });

    test('DIFF #D-01: 27.25 radius sifatida ishlatilmaydi', () {
      final List<double> all = <double>[
        Radii.sm,
        Radii.md,
        Radii.lg,
        Radii.xl,
        Radii.pill,
        Radii.card,
        Radii.button,
        Radii.input,
        Radii.chip,
        Radii.sheet,
        Radii.modal,
      ];
      expect(all, isNot(contains(27.25)));
    });

    test('semantik aliaslar dominant qiymatlarga bog\'langan', () {
      expect(Radii.card, Radii.md);
      expect(Radii.button, Radii.lg);
      expect(Radii.input, Radii.lg);
      expect(Radii.chip, Radii.pill);
      expect(Radii.sheet, Radii.xl);
    });

    test('BorderRadius konstantalari mos', () {
      expect(Radii.cardRadius, const BorderRadius.all(Radius.circular(8)));
      expect(Radii.sheetRadius, const BorderRadius.vertical(top: Radius.circular(24)));
    });
  });

  group('Strokes', () {
    test('default 1, urg\'u 2', () {
      expect(Strokes.thin, 1);
      expect(Strokes.emphasis, 2);
    });
  });

  group('ShadowSpec — Carts Dropdown', () {
    test('blur 27.25, offset (0, 7.79), opacity 10.1 %', () {
      expect(ShadowSpec.blurRadius, 27.25);
      expect(ShadowSpec.offset, const Offset(0, 7.79));
      expect(ShadowSpec.spreadRadius, 0);
      expect(ShadowSpec.opacityLight, closeTo(0.101, 1e-9));
    });
  });
}
