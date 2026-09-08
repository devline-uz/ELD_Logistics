/// M4 ekranlari uchun golden qobig'i: `ProviderScope` + tema + l10n +
/// `DeviceProfile` ga to'g'ri `MediaQuery`.
library;

import 'package:alchemist/alchemist.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../golden_harness.dart' as harness;
import '../../golden_harness.dart' show GoldenDevice, GoldenTheme;

/// Ekranni golden uchun tayyorlaydi (M7: profil `MediaQuery` dan).
Widget m4GoldenHost({
  required Widget child,
  required List<Override> overrides,
  required GoldenTheme theme,
  required GoldenDevice device,
  Size? size,
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.of(theme.brightness),
    localizationsDelegates: const <LocalizationsDelegate<Object?>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (BuildContext context, Widget? inner) => MediaQuery(
      data: MediaQueryData(size: size ?? device.size, textScaler: TextScaler.noScaling),
      child: inner!,
    ),
    home: child,
  ),
);

/// [goldenMatrix] ning M4 varianti: har konfiguratsiya uchun yangi
/// `ProviderScope` quriladi (holat oqib ketmasin).
void m4GoldenMatrix(
  String name, {
  required Widget Function() child,
  required List<Override> Function() overrides,
  List<GoldenDevice> devices = GoldenDevice.values,
  Size? size,
}) {
  for (final GoldenTheme theme in GoldenTheme.values) {
    for (final GoldenDevice device in devices) {
      final Size surface = size ?? device.size;
      goldenTest(
        '$name · ${theme.id} · ${device.id}',
        fileName: '${name}_${theme.id}_${device.id}',
        constraints: BoxConstraints.tight(surface),
        pumpBeforeTest: harness.pumpOnce,
        builder: () => m4GoldenHost(
          child: child(),
          overrides: overrides(),
          theme: theme,
          device: device,
          size: surface,
        ),
      );
    }
  }
}
