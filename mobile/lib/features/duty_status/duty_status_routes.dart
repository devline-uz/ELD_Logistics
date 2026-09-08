/// Duty status modulining marshrutlari (eld-screens registri: M-12…M-14).
///
/// `core/router/app_router.dart` shu ro'yxatni o'z `routes:` iga qo'shadi.
/// `M-13 Quick notes` va `M-14 Location inaccurate` — modal/dialog, ular
/// marshrut emas (`showQuickNotesSheet`, `showLocationInaccurateDialog`).
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/change_duty_status_screen.dart';

abstract final class DutyStatusRoute {
  const DutyStatusRoute._();

  /// `M-12 Change duty status`.
  static const String change = '/duty/change';
}

final List<RouteBase> dutyStatusRoutes = <RouteBase>[
  GoRoute(
    path: DutyStatusRoute.change,
    builder: (BuildContext context, GoRouterState state) => const ChangeDutyStatusScreen(),
  ),
];
