/// Drive mode marshrutlari (eld-screens registri: M-15, M-16).
///
/// `M-16 Idle prompt` — marshrut emas, `M-15` ustidagi qatlam
/// (`IdlePromptOverlay`), shuning uchun bu ro'yxatda yo'q.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/drive_mode_screen.dart';

abstract final class DriveModeRoute {
  const DriveModeRoute._();

  /// `M-15 Drive mode (focused)`.
  static const String drive = '/drive';
}

final List<RouteBase> driveModeRoutes = <RouteBase>[
  GoRoute(
    path: DriveModeRoute.drive,
    builder: (BuildContext context, GoRouterState state) => const DriveModeScreen(),
  ),
];
