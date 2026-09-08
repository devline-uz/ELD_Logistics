/// M11 klasteri marshrutlari (tz-mobile §11.1: M-44, M-45, M-48…M-53).
///
/// Ikkiga bo'lingan: [profileBranchRoutes] `StatefulShellRoute` ning `Profile`
/// shoxiga tushadi (`/profile` — pastki tab), [profileRootRoutes] esa ildizga
/// (`/support`, `/legal/*` — tab tasmasisiz, to'liq ekran).
///
/// `/profile/network` (M-47), `/profile/diagnosis` (M-46), `/profile/sessions`
/// (M-58) va `/pin/change` **bu yerda ro'yxatga olinmaydi** — ular
/// `diagnostics` va `auth` modullariga tegishli. Ekranlar ularga
/// [pushOrNotify] orqali murojaat qiladi.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../feedback/presentation/screens/feedback_screen.dart';
import '../legal/presentation/screens/legal_screen.dart';
import '../settings/presentation/screens/settings_screen.dart';
import '../support/presentation/screens/support_form_screen.dart';
import '../support/presentation/screens/support_list_screen.dart';
import '../support/presentation/screens/ticket_thread_screen.dart';
import 'presentation/screens/profile_screen.dart';

abstract final class ProfileRoute {
  const ProfileRoute._();

  /// `M-44` — pastki tab shoxi.
  static const String profile = '/profile';

  /// `M-45`.
  static const String settings = '/profile/settings';

  /// `M-48`.
  static const String feedback = '/profile/feedback';

  /// `M-50` (ro'yxat) → `M-49` (forma) → `M-51` (thread).
  static const String support = '/support';
  static const String supportNew = '/support/new';

  /// `M-51` — `:id` tiket identifikatori.
  static String supportTicket(String id) => '/support/$id';

  /// `M-52` / `M-53`.
  static const String legalPrivacy = '/legal/privacy';
  static const String legalTerms = '/legal/terms';

  // --- Boshqa modullar ro'yxatga oladigan yo'llar (bu yerda faqat havola) ---

  /// `M-47 Check network` — `diagnostics`.
  static const String checkNetwork = '/profile/network';

  /// `M-46 Diagnosis of device` — `diagnostics`.
  static const String diagnosis = '/profile/diagnosis';

  /// `M-58 Sessions (my devices)` — `auth`.
  static const String sessions = '/profile/sessions';

  /// PIN almashtirish oqimi — `auth`.
  static const String changePin = '/pin/change';
}

/// `Profile` tab shoxining marshrutlari.
final List<RouteBase> profileBranchRoutes = <RouteBase>[
  GoRoute(
    path: ProfileRoute.profile,
    builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: 'settings',
        builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
      ),
      GoRoute(
        path: 'feedback',
        builder: (BuildContext context, GoRouterState state) => const FeedbackScreen(),
      ),
    ],
  ),
];

/// Ildizga (tab tasmasidan tashqarida) qo'shiladigan M11 marshrutlari.
final List<RouteBase> profileRootRoutes = <RouteBase>[
  GoRoute(
    path: ProfileRoute.support,
    builder: (BuildContext context, GoRouterState state) => const SupportListScreen(),
    routes: <RouteBase>[
      // `new` `:id` dan OLDIN turishi shart (go_router tartib bo'yicha moslaydi).
      GoRoute(
        path: 'new',
        builder: (BuildContext context, GoRouterState state) => const SupportFormScreen(),
      ),
      GoRoute(
        path: ':id',
        builder: (BuildContext context, GoRouterState state) =>
            TicketThreadScreen(ticketId: state.pathParameters['id'] ?? ''),
      ),
    ],
  ),
  GoRoute(
    path: ProfileRoute.legalPrivacy,
    builder: (BuildContext context, GoRouterState state) =>
        const LegalScreen(document: LegalDocumentKind.privacy),
  ),
  GoRoute(
    path: ProfileRoute.legalTerms,
    builder: (BuildContext context, GoRouterState state) =>
        const LegalScreen(document: LegalDocumentKind.terms),
  ),
];
