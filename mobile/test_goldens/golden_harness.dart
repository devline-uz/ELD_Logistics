/// Golden test yordamchisi — **4 konfiguratsiya** (tz-mobile C.3 DoD).
///
/// `light` / `dark` × `phone 393×852` / `tablet 1366×1024`.
/// Har chaqiruv 4 ta golden fayl hosil qiladi:
/// `test_goldens/goldens/ci/<name>_<theme>_<device>.png`.
library;

import 'package:alchemist/alchemist.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter/material.dart';

/// Referens o'lchamlar (tz-mobile §3).
enum GoldenDevice {
  phone('phone', Size(393, 852)),
  tablet('tablet', Size(1366, 1024));

  const GoldenDevice(this.id, this.size);

  final String id;
  final Size size;
}

/// Tema variantlari.
enum GoldenTheme {
  light('light', Brightness.light),
  dark('dark', Brightness.dark);

  const GoldenTheme(this.id, this.brightness);

  final String id;
  final Brightness brightness;
}

/// Komponentni 4 konfiguratsiyada golden bilan solishtiradi.
///
/// [builder] har safar yangi widget qaytaradi (holat oqib ketmasligi uchun).
/// [textScale] — M85 tekshiruvi uchun 1.3 berilishi mumkin.
void goldenMatrix(
  String name, {
  required ValueGetter<Widget> builder,
  double textScale = 1.0,
  EdgeInsets padding = const EdgeInsets.all(Spacing.s20),
  List<GoldenDevice> devices = GoldenDevice.values,
  List<GoldenTheme> themes = GoldenTheme.values,
  PumpAction pumpBeforeTest = onlyPumpAndSettle,
}) {
  for (final GoldenTheme theme in themes) {
    for (final GoldenDevice device in devices) {
      goldenTest(
        '$name · ${theme.id} · ${device.id}',
        fileName: '${name}_${theme.id}_${device.id}',
        textScaleFactor: textScale,
        constraints: BoxConstraints.tight(device.size),
        pumpBeforeTest: pumpBeforeTest,
        builder: () => GoldenHost(theme: theme, device: device, padding: padding, child: builder()),
      );
    }
  }
}

/// Cheksiz animatsiyali komponentlar uchun (`pumpAndSettle` ularda osilib
/// qoladi): bir marta pump qilib kadrni oladi.
final PumpAction pumpOnce = pumpNTimes(1, const Duration(milliseconds: 16));

/// Golden uchun minimal ilova qobig'i: tema, `MediaQuery`, `Directionality`.
///
/// `DeviceProfile` `MediaQuery.size` dan hisoblanadi (M7) — shuning uchun
/// planshet golden'ida `shortestSide >= 600` bo'lishi shart.
class GoldenHost extends StatelessWidget {
  const GoldenHost({
    required this.child,
    required this.theme,
    required this.device,
    this.padding = const EdgeInsets.all(Spacing.s20),
    super.key,
  });

  final Widget child;
  final GoldenTheme theme;
  final GoldenDevice device;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQueryData(size: device.size, textScaler: TextScaler.noScaling),
    child: Theme(
      data: AppTheme.of(theme.brightness),
      child: Builder(
        builder: (BuildContext context) => ColoredBox(
          color: context.colors.bg,
          child: DefaultTextStyle(
            style: context.text.body13.copyWith(color: context.colors.textPrimary),
            child: Navigator(
              onGenerateRoute: (RouteSettings _) => MaterialPageRoute<void>(
                builder: (BuildContext _) => Material(
                  color: context.colors.bg,
                  child: SingleChildScrollView(
                    child: Padding(padding: padding, child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
