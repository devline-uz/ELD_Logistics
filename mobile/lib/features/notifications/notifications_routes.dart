/// Notifications modulining marshrutlari (eld-screens registri: M-43).
///
/// M89: `Notifications` — **tab emas**, app bar'dagi qo'ng'iroq ikonkasi
/// ochadigan alohida ekran. Planshetda `T-29` shu ekranni modal/panel
/// sifatida ko'rsatadi (bir xil `Controller`).
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/notifications_screen.dart';

abstract final class NotificationsRoute {
  const NotificationsRoute._();

  /// `M-43 Notifications`.
  static const String list = '/notifications';
}

/// `GoRouter` ga qo'shiladigan notifications marshrutlari.
///
/// M145: element bosilganda deep link marshrutiga o'tiladi.
final List<RouteBase> notificationsRoutes = <RouteBase>[
  GoRoute(
    path: NotificationsRoute.list,
    builder: (BuildContext context, GoRouterState state) =>
        NotificationsScreen(onOpenDeepLink: (String route) => GoRouter.of(context).go(route)),
  ),
];
