/// Golden testlar uchun global konfiguratsiya (CR-M02: `alchemist`).
///
/// `golden_toolkit` **discontinued** (oxirgi reliz 2023-02, `sdk <3.0.0`) —
/// `alchemist ^0.14.0` (MIT) bilan almashtirildi.
///
/// * `platformGoldensConfig.enabled = false` — mahalliy OS shriftlariga
///   bog'liq goldenlar chiqarilmaydi (CI va noutbuk bir xil natija bersin).
/// * `ciGoldensConfig.obscureText = false` — matn `flutter_test` ning
///   deterministik test shrifti bilan chiziladi.
/// * `renderShadows = true` — `Carts Dropdown` soyasi golden'da ko'rinadi.
library;

import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/scheduler.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Skeleton shimmer va sync aylanishi golden'da to'xtatiladi.
  timeDilation = 1;

  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
      ciGoldensConfig: CiGoldensConfig(obscureText: false, renderShadows: true),
    ),
    run: testMain,
  );
}
