/// Unidentified modulining marshruti (eld-screens registri: M-28).
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/unidentified_screen.dart';

abstract final class UnidentifiedRoute {
  const UnidentifiedRoute._();

  /// `M-28 Unidentified driving claim` (Home'dagi sariq kartadan, M100).
  static const String list = '/unidentified';
}

/// `GoRouter` ga qo'shiladigan marshrutlar.
final List<RouteBase> unidentifiedRoutes = <RouteBase>[
  GoRoute(
    path: UnidentifiedRoute.list,
    builder: (BuildContext context, GoRouterState state) => const UnidentifiedScreen(),
  ),
];
