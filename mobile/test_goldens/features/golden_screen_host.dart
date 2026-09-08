/// Ekran (sahifa) goldenlari uchun qobiq.
///
/// `golden_harness.dart` dagi [GoldenHost] komponentlar uchun mo'ljallangan
/// (u bolani `SingleChildScrollView` ichiga soladi) — to'liq ekran uchun
/// `Scaffold` + `Expanded` bilan mos kelmaydi. Bu yerda ekran to'liq
/// `MaterialApp` ichida, aniq `MediaQuery` bilan chiziladi.
library;

import 'package:alchemist/alchemist.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../golden_harness.dart';

/// Ekranni tema + l10n + DI bilan o'raydi.
Widget goldenScreenHost({
  required Widget child,
  required GoldenTheme theme,
  required GoldenDevice device,
  List<Override> overrides = const <Override>[],
}) => ProviderScope(
  overrides: overrides,
  child: MediaQuery(
    data: MediaQueryData(size: device.size, textScaler: TextScaler.noScaling),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(theme.brightness),
      localizationsDelegates: const <LocalizationsDelegate<Object?>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  ),
);

/// Ekranni berilgan tema/qurilma konfiguratsiyalarida golden bilan solishtiradi.
///
/// **Eslatma (dizayn):** DVIR va Inspection oqimlari Figma da **faqat light**
/// temada chizilgan — dark variant `core/ui` tokenlari orqali avtomatik hosil
/// bo'ladi va shu goldenlar bilan qotiriladi.
void screenGoldenMatrix(
  String name, {
  required ValueGetter<Widget> builder,
  ValueGetter<List<Override>>? overrides,
  List<GoldenDevice> devices = GoldenDevice.values,
  List<GoldenTheme> themes = GoldenTheme.values,
  PumpAction pumpBeforeTest = onlyPumpAndSettle,
}) {
  for (final GoldenTheme theme in themes) {
    for (final GoldenDevice device in devices) {
      goldenTest(
        '$name · ${theme.id} · ${device.id}',
        fileName: '${name}_${theme.id}_${device.id}',
        constraints: BoxConstraints.tight(device.size),
        pumpBeforeTest: pumpBeforeTest,
        builder: () => goldenScreenHost(
          theme: theme,
          device: device,
          overrides: overrides?.call() ?? const <Override>[],
          child: builder(),
        ),
      );
    }
  }
}
