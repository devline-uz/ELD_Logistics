/// Auth modulining marshrutlari (eld-screens registri §1: M-01…M-08, M-57).
///
/// `core/router/app_router.dart` shu ro'yxatni o'z `routes:` iga qo'shadi —
/// routerning o'zi bu agentning hududida emas.
///
/// ```dart
/// routes: <RouteBase>[...authRoutes, StatefulShellRoute.indexedStack(...)]
/// ```
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import 'domain/auth_models.dart';
import 'domain/driver_session.dart';
import 'presentation/controllers/login_controller.dart';
import 'presentation/screens/force_update_screen.dart';
import 'presentation/screens/invitation_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/password_screens.dart';
import 'presentation/screens/pin_screen.dart';
import 'presentation/screens/sessions_screen.dart';
import 'presentation/screens/signed_out_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/totp_screen.dart';

/// `AppRoute` da yo'q auth yo'llari (registrdan aynan ko'chirilgan).
abstract final class AuthRoute {
  const AuthRoute._();

  /// M-03 Leave truck / Return to truck.
  static const String paused = '/paused';

  /// M-05 Accept invitation (`?token=`).
  static const String invite = '/invite';

  /// M-06 Forgot password.
  static const String forgot = '/forgot';

  /// M-07 Reset password (`?token=`).
  static const String reset = '/reset';

  /// M-08 Two-factor (TOTP).
  static const String twoFactor = '/2fa';

  /// M-57 Force update (bloklovchi).
  static const String update = '/update';

  /// M-56 Signed out elsewhere (`?device=phone|tablet|web`).
  static const String signedOut = '/signed-out';

  /// M-58 Sessions (my devices).
  static const String sessions = '/profile/sessions';

  /// Deep link va marshrut so'rov parametri nomi.
  static const String tokenParam = 'token';

  /// `M-04` uchun `?action=switch_driver|return_to_truck`.
  static const String actionParam = 'action';

  /// `M-56` uchun `?device=phone|tablet|web` — sessiyani egallagan qurilma.
  static const String deviceParam = 'device';

  /// Login'dan **oldin** ochiladigan ekranlar — qo'riqchi ularni
  /// `/login` ga qaytarmaydi (`app_router.dart` `redirect`).
  ///
  /// `paused` bu yerda emas: u `locked` sessiya uchun, `/pin` bilan birga
  /// alohida ishlanadi. `update` (M-57) esa har qanday holatda bloklovchi.
  static const Set<String> publicPaths = <String>{
    invite,
    forgot,
    reset,
    twoFactor,
    update,
    signedOut,
  };
}

/// Auth ekranlari. Marshrut yo'llari `eld-screens` registridan.
final List<RouteBase> authRoutes = <RouteBase>[
  GoRoute(
    path: AppRoute.splash,
    builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
  ),
  GoRoute(
    path: AppRoute.login,
    builder: (BuildContext context, GoRouterState state) =>
        const LoginScreen(mode: LoginMode.signIn),
  ),
  GoRoute(
    path: AuthRoute.paused,
    builder: (BuildContext context, GoRouterState state) =>
        const LoginScreen(mode: LoginMode.leaveTruck),
  ),
  GoRoute(
    path: AppRoute.pin,
    builder: (BuildContext context, GoRouterState state) =>
        PinScreen(action: PinAction.parse(state.uri.queryParameters[AuthRoute.actionParam])),
  ),
  GoRoute(
    path: AuthRoute.invite,
    builder: (BuildContext context, GoRouterState state) =>
        InvitationScreen(token: state.uri.queryParameters[AuthRoute.tokenParam] ?? ''),
  ),
  GoRoute(
    path: AuthRoute.forgot,
    builder: (BuildContext context, GoRouterState state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AuthRoute.reset,
    builder: (BuildContext context, GoRouterState state) =>
        ResetPasswordScreen(token: state.uri.queryParameters[AuthRoute.tokenParam] ?? ''),
  ),
  GoRoute(
    path: AuthRoute.twoFactor,
    builder: (BuildContext context, GoRouterState state) => const TotpScreen(),
  ),
  GoRoute(
    path: AuthRoute.update,
    builder: (BuildContext context, GoRouterState state) => const ForceUpdateScreen(),
  ),
  GoRoute(
    path: AuthRoute.signedOut,
    builder: (BuildContext context, GoRouterState state) => SignedOutScreen(
      replacedBy: SessionDeviceType.parse(state.uri.queryParameters[AuthRoute.deviceParam]),
    ),
  ),
  GoRoute(
    path: AuthRoute.sessions,
    builder: (BuildContext context, GoRouterState state) => const SessionsScreen(),
  ),
];
