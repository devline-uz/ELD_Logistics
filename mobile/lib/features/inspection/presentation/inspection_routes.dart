/// Inspection modulining marshrutlari (tz-mobile §11.1: M-37…M-41).
///
/// `core/router/app_router.dart` shu ro'yxatni ildizga qo'shadi — kiosk rejimi
/// tab tasmasidan **tashqarida** bo'lishi shart (M-38: navigatsiya yo'q).
///
/// `M-39 Exit PIN`, `M-40 Send via email`, `M-41 Send the file` — marshrut emas,
/// modal (`showExitPinDialog`, `showSendEmailSheet`, `showSendFileSheet`).
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/inspection_kiosk_screen.dart';
import 'screens/inspection_report_screen.dart';

abstract final class InspectionRoute {
  const InspectionRoute._();

  /// `M-37 Inspection Report` (uch amal).
  static const String report = '/inspection';

  /// `M-38 Begin inspection` — kiosk rejimi.
  static const String kiosk = '/inspection/view';
}

/// `GoRouter` ga qo'shiladigan inspection marshrutlari.
final List<RouteBase> inspectionRoutes = <RouteBase>[
  GoRoute(
    path: InspectionRoute.report,
    builder: (BuildContext context, GoRouterState state) => const InspectionReportScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: 'view',
        builder: (BuildContext context, GoRouterState state) => const InspectionKioskScreen(),
      ),
    ],
  ),
];
