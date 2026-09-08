/// Log edits modulining marshrutlari (eld-screens registri: M-26, M-27).
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/pending_edit_detail_screen.dart';
import 'presentation/screens/pending_edits_screen.dart';

abstract final class LogEditsRoute {
  const LogEditsRoute._();

  /// `M-26 Pending edits`.
  static const String list = '/logs/pending-edits';

  /// `M-27 Pending edit detail`.
  static const String detailPattern = '/logs/pending-edits/:id';

  /// Yo'l parametri nomi.
  static const String idParam = 'id';

  /// [detailPattern] ga konkret so'rov bilan havola.
  static String detailFor(String id) => '$list/$id';
}

/// `GoRouter` ga qo'shiladigan log-edit marshrutlari.
final List<RouteBase> logEditsRoutes = <RouteBase>[
  GoRoute(
    path: LogEditsRoute.list,
    builder: (BuildContext context, GoRouterState state) => const PendingEditsScreen(),
  ),
  GoRoute(
    path: LogEditsRoute.detailPattern,
    builder: (BuildContext context, GoRouterState state) =>
        PendingEditDetailScreen(requestId: state.pathParameters[LogEditsRoute.idParam] ?? ''),
  ),
];
