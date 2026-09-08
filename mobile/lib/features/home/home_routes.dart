/// Home modulining marshrutlari (eld-screens registri: M-09…M-11).
///
/// `M-10 Drawer` — `Scaffold.drawer`, `M-11 Edit documents` — modal;
/// ikkalasi ham marshrut emas.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import 'presentation/screens/home_screen.dart';

abstract final class HomeRoute {
  const HomeRoute._();

  /// `M-09 Home` — `AppRoute.home` bilan bir xil (tab shell ichida).
  static const String home = AppRoute.home;
}

/// Boshqa modullarga tegishli yo'llar — drawer va tezkor amallar havolalari.
///
/// Egasi o'sha modullar (`eld-screens` registri); bu yerda faqat nusxa,
/// shuning uchun ekranlarda string literal tarqalmaydi.
abstract final class HomeLinks {
  const HomeLinks._();

  /// `M-43 Notifications`.
  static const String notifications = '/notifications';

  /// `M-18 Permissions`.
  static const String permissions = '/permissions';

  /// `M-47 Check network`.
  static const String checkNetwork = '/profile/network';

  /// `M-46 Diagnosis of device`.
  static const String diagnosis = '/profile/diagnosis';

  /// `M-48 Give feedback`.
  static const String feedback = '/profile/feedback';

  /// `M-50 Support & Helpdesk`.
  static const String support = '/support';

  /// `M-52 Privacy Policy`.
  static const String privacy = '/legal/privacy';

  /// `M-53 Terms of Use`.
  static const String terms = '/legal/terms';

  /// Foydalanuvchi qo'llanmasi (`M-45 Settings` ichidagi bo'lim).
  static const String userManual = '/profile/settings';

  /// `App Updates` — `M-57` bloklovchi ekrani.
  static const String appUpdates = '/update';

  /// `M-03 Leave truck` (logout ham shu oqim orqali).
  static const String logout = '/paused';

  /// `M-03 Leave truck` — tezkor amal.
  static const String leaveTruck = '/paused';

  /// `M-20 Co-driver switch`.
  static const String coDriver = '/pin';

  /// `M-37 Inspection Report`.
  static const String inspection = '/inspection';

  /// `M-29 Certify`.
  static const String certify = '/certify';

  /// `M-26 Pending edits`.
  static const String pendingEdits = '/logs/pending-edits';

  /// `M-28 Unidentified driving claim`.
  static const String unidentified = '/unidentified';
}

/// `GoRouter` ga qo'shiladigan Home marshruti (tab shell ichiga).
final List<RouteBase> homeRoutes = <RouteBase>[
  GoRoute(
    path: HomeRoute.home,
    builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
  ),
];
