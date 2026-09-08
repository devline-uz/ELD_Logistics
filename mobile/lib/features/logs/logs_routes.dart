/// Logs modulining marshrutlari (eld-screens registri: M-22…M-25).
///
/// `core/router/app_router.dart` shu ro'yxatni `Logs` tab shell'iga qo'shadi.
/// `M-25` marshrut emas — `showLogEventDetail` modali.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/log_report_screen.dart';

abstract final class LogsRoute {
  const LogsRoute._();

  /// `M-22/23/24` — `?tab=main|logs|dvir`.
  static const String report = '/logs';

  /// Sub-tab so'rov parametri.
  static const String tabParam = 'tab';

  /// [report] ga konkret tab bilan havola.
  static String reportTab(String tab) => '$report?$tabParam=$tab';
}

/// `GoRouter` ga qo'shiladigan logs marshrutlari.
final List<RouteBase> logsRoutes = <RouteBase>[
  GoRoute(
    path: LogsRoute.report,
    builder: (BuildContext context, GoRouterState state) =>
        LogReportScreen(initialTab: state.uri.queryParameters[LogsRoute.tabParam]),
  ),
];
