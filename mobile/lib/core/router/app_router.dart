/// go_router: auth guard + `StatefulShellRoute.indexedStack` (4 tab).
///
/// Modullar o'z marshrut ro'yxatlarini eksport qiladi (`homeRoutes`,
/// `logsRoutes`, `certifyRoutes`, …), bu fayl esa faqat ularni yig'adi —
/// ekran importlari modul ichida qoladi va `core` `presentation` ga bog'lanmaydi.
///
/// Yig'ish qoidasi:
///  * **shell shoxlari** — pastki tasma ko'rinadigan ekranlar (`/home`, `/logs`,
///    `/chat`, `/profile` va ularning bolalari);
///  * **ildiz marshrutlari** — to'liq ekran (modal) oqimlar: duty status,
///    drive mode, certify, DVIR, inspection, ELD, sync.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_routes.dart';
import '../../features/certify/certify_routes.dart';
import '../../features/chat/chat_routes.dart';
import '../../features/dev/components_gallery.dart';
import '../../features/diagnostics/diagnostics_routes.dart';
import '../../features/drive_mode/drive_mode_routes.dart';
import '../../features/duty_status/duty_status_routes.dart';
import '../../features/dvir/presentation/dvir_routes.dart';
import '../../features/eld_device/eld_device_routes.dart';
import '../../features/home/home_routes.dart';
import '../../features/inspection/presentation/inspection_routes.dart';
import '../../features/log_edits/log_edits_routes.dart';
import '../../features/logs/logs_routes.dart';
import '../../features/notifications/notifications_routes.dart';
import '../../features/profile/profile_routes.dart';
import '../../features/sync/presentation/sync_routes.dart';
import '../../features/unidentified/unidentified_routes.dart';
import '../config/env.dart';
import '../i18n/l10n_extension.dart';
import 'auth_state.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Qo'riqchi tekshirmaydigan yo'llar: `core` + auth modulining login'dan
/// oldingi ekranlari (`/invite`, `/forgot`, `/reset`, `/2fa`, `/update`).
final Set<String> _publicPaths = <String>{...AppRoute.publicPaths, ...AuthRoute.publicPaths};

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<AuthStatus> refresh = ValueNotifier<AuthStatus>(ref.read(authStatusProvider));
  ref.listen<AuthStatus>(authStatusProvider, (AuthStatus? _, AuthStatus next) {
    refresh.value = next;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.splash,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = ref.read(authStatusProvider);
      final String location = state.matchedLocation;

      // M-57 har qanday holatda bloklovchi — qo'riqchi unga tegmaydi.
      if (location == AuthRoute.update) {
        return null;
      }

      return switch (status) {
        AuthStatus.unknown => location == AppRoute.splash ? null : AppRoute.splash,
        AuthStatus.unauthenticated => _publicPaths.contains(location) ? null : AppRoute.login,
        // `locked` sessiyada faqat PIN ekrani va `Leave truck` ochiq (§4.8).
        AuthStatus.locked =>
          location == AppRoute.pin || location == AuthRoute.paused ? null : AppRoute.pin,
        AuthStatus.authenticated =>
          _publicPaths.contains(location) || location == AppRoute.pin ? AppRoute.home : null,
      };
    },
    routes: <RouteBase>[
      ...authRoutes,
      // --- To'liq ekranli oqimlar (tab tasmasidan tashqarida) ---
      ...dutyStatusRoutes,
      ...driveModeRoutes,
      ...certifyRoutes,
      ...logEditsRoutes,
      ...unidentifiedRoutes,
      ...dvirRoutes,
      ...inspectionRoutes,
      ...eldDeviceRoutes,
      ...notificationsRoutes,
      ...profileRootRoutes,
      ...syncRoutes(),
      if (Env.devMenuVisible)
        GoRoute(
          path: AppRoute.devComponents,
          builder: (BuildContext context, GoRouterState state) => const ComponentsGalleryScreen(),
        ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) =>
            _MainShell(shell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(routes: homeRoutes),
          StatefulShellBranch(routes: logsRoutes),
          StatefulShellBranch(routes: chatRoutes),
          StatefulShellBranch(routes: <RouteBase>[...profileBranchRoutes, ...diagnosticsRoutes]),
        ],
      ),
    ],
  );
});

class _MainShell extends StatelessWidget {
  const _MainShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (int index) =>
          shell.goBranch(index, initialLocation: index == shell.currentIndex),
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: context.l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.article_outlined),
          selectedIcon: const Icon(Icons.article),
          label: context.l10n.navLogs,
        ),
        NavigationDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: context.l10n.navChat,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: context.l10n.navProfile,
        ),
      ],
    ),
  );
}
