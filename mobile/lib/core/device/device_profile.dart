/// Qurilma profili (tz-mobile §3, M6/M7).
///
/// Telefon va planshet — **turli ekran registrlari**. Profil `shortestSide`
/// bo'yicha aniqlanadi, model nomiga qarab emas.
library;

import 'package:flutter/widgets.dart';

/// M6: 600 dp — telefon/planshet chegarasi.
const double kTabletShortestSideDp = 600;

enum DeviceProfile {
  phone,
  tablet;

  bool get isPhone => this == DeviceProfile.phone;

  bool get isTablet => this == DeviceProfile.tablet;

  /// `MediaQuery` dan profil. `shortestSide` — orientatsiyaga bog'liq emas.
  static DeviceProfile fromSize(Size size) =>
      size.shortestSide >= kTabletShortestSideDp ? DeviceProfile.tablet : DeviceProfile.phone;

  static DeviceProfile of(BuildContext context) => fromSize(MediaQuery.sizeOf(context));
}

extension DeviceProfileContext on BuildContext {
  DeviceProfile get deviceProfile => DeviceProfile.of(this);
}
