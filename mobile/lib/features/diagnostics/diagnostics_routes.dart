/// `diagnostics` modulining marshrutlari (eld-screens registri §1: M-46, M-47).
///
/// Ikkala yo'l `Profile` tab shoxining ostida turadi (`ProfileRoute.diagnosis`
/// va `ProfileRoute.checkNetwork` shu yerga ishora qiladi — `profile` moduli
/// ularni **ro'yxatga olmaydi**, faqat `pushOrNotify` bilan chaqiradi).
///
/// `core/router/app_router.dart` shu ro'yxatni `Profile` shoxiga qo'shadi:
/// ```dart
/// routes: <RouteBase>[...profileBranchRoutes, ...diagnosticsRoutes]
/// ```
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/check_network_screen.dart';
import 'presentation/screens/diagnosis_screen.dart';

abstract final class DiagnosticsRoute {
  const DiagnosticsRoute._();

  /// `M-46 Diagnosis of device` — registrdan aynan ko'chirilgan.
  static const String diagnosis = '/profile/diagnosis';

  /// `M-47 Check network`.
  static const String checkNetwork = '/profile/network';
}

/// M-46 va M-47 — `Profile` shoxining to'liq ekranli bolalari.
final List<RouteBase> diagnosticsRoutes = <RouteBase>[
  GoRoute(
    path: DiagnosticsRoute.diagnosis,
    builder: (BuildContext context, GoRouterState state) => const DiagnosisScreen(),
  ),
  GoRoute(
    path: DiagnosticsRoute.checkNetwork,
    builder: (BuildContext context, GoRouterState state) => const CheckNetworkScreen(),
  ),
];
