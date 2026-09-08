/// `eld_device` modulining marshrutlari (eld-screens registri §1: M-17…M-19).
///
/// `core/router/app_router.dart` shu ro'yxatni o'z `routes:` iga qo'shadi —
/// routerning o'zi bu agentning hududida emas:
///
/// ```dart
/// routes: <RouteBase>[...authRoutes, ...eldDeviceRoutes, ...]
/// ```
///
/// `M-17 ELD not connected` marshrut emas — `showEldNotConnectedDialog()`
/// bilan chaqiriladigan dialog (registrda `dialog`).
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/eld_connect_screen.dart';
import 'presentation/screens/permissions_screen.dart';

abstract final class EldDeviceRoute {
  const EldDeviceRoute._();

  /// `M-18 Permissions` — registrdan aynan ko'chirilgan.
  static const String permissions = '/permissions';

  /// `M-19 ELD device connect/scan`.
  static const String eld = '/eld';
}

/// M-18 va M-19 — ildizga (tab tasmasidan tashqarida, to'liq ekran).
final List<RouteBase> eldDeviceRoutes = <RouteBase>[
  GoRoute(
    path: EldDeviceRoute.permissions,
    builder: (BuildContext context, GoRouterState state) => const PermissionsScreen(),
  ),
  GoRoute(
    path: EldDeviceRoute.eld,
    builder: (BuildContext context, GoRouterState state) => const EldConnectScreen(),
  ),
];
