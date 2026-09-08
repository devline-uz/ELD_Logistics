/// `M-54` va `M-55` marshrutlari (tz-mobile §11.1: `/sync`, `/sync/conflicts`).
///
/// TODO(M1): `core/router/app_router.dart` shu ro'yxatni ildiz marshrutlariga
/// qo'shadi (`...syncRoutes()`); router fayli hozircha boshqa agent qo'lida.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/sync_conflicts_screen.dart';
import 'screens/sync_status_screen.dart';

abstract final class SyncRoute {
  const SyncRoute._();

  /// `M-54 Sync status`.
  static const String status = '/sync';

  /// `M-55 Sync conflicts`.
  static const String conflicts = '/sync/conflicts';
}

/// `GoRouter` ga qo'shiladigan marshrutlar.
List<RouteBase> syncRoutes() => <RouteBase>[
  GoRoute(
    path: SyncRoute.status,
    builder: (BuildContext context, GoRouterState state) => const SyncStatusScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: 'conflicts',
        builder: (BuildContext context, GoRouterState state) => const SyncConflictsScreen(),
      ),
    ],
  ),
];
