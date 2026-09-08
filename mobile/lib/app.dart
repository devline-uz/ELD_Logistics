/// Ilova ildizi: `MaterialApp.router`, tema, lokalizatsiya va **bootstrap
/// ulanishlari**.
///
/// Dizayn tizimi `core/ui` dan keladi (M1): `AppTheme.light` / `AppTheme.dark`
/// + `TextScaleGuard` (M85 `textScaler` 0.85…1.3) + `Zoom` toggle (M94).
///
/// [AppBootstrap] — `core` va modullar orasidagi yagona «sim» qatlami:
/// `core` da `BuildContext`/l10n yo'q, modullar esa bir-birini ko'rmaydi (M5),
/// shuning uchun global tinglovchilar aynan shu yerda o'rnatiladi.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/background/background_providers.dart';
import 'core/background/background_service.dart';
import 'core/router/app_router.dart';
import 'core/router/auth_state.dart';
import 'core/session/session_profile.dart';
import 'core/sync/sync_providers.dart';
import 'core/ui/theme.dart';
import 'core/ui/theme_controller.dart';
import 'core/ui/typography.dart';
import 'features/auth/data/auth_providers.dart';
import 'features/auth/domain/auth_models.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/drive_mode/presentation/controllers/drive_mode_controller.dart';
import 'features/duty_status/domain/duty_status_models.dart';
import 'features/notifications/presentation/notification_providers.dart';
import 'l10n/generated/app_localizations.dart';

class EldApp extends ConsumerWidget {
  const EldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final AppUiSettings ui = ref.watch(appUiSettingsProvider);

    return MaterialApp.router(
      routerConfig: router,
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ui.themeMode,
      // M85: matn masshtabi bir joyda cheklanadi — ekranlarda takrorlanmaydi.
      // `builder` konteksti `Localizations` ostida, shuning uchun bootstrap
      // ulanishlari (l10n talab qiladiganlari) shu yerda o'rnatiladi.
      builder: (BuildContext context, Widget? child) => TextScaleGuard(
        zoom: ui.zoom,
        child: AppBootstrap(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// Global tinglovchilar: auto-DR, push deep-link, fon xizmati, sessiya profili.
///
/// Ilovaning **butun** hayoti davomida yashaydi va hech qanday tab'ga
/// bog'lanmaydi — M4 ning «auto-DR faqat Home ochiq bo'lganda ishlaydi»
/// muammosi shu bilan yopiladi.
class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  AuthStatus? _lastStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppLocalizations l10n = AppLocalizations.of(context);

    // M62: `M-16` idle bildirishnomasi matni (core da l10n konteksti yo'q).
    DriveModeController.alertTitle = l10n.idleAlertTitle;
    DriveModeController.alertBody = l10n.idleAlertBody;

    // Android FGS kanali nomi/tavsifi (§10.4). Provayder holatini qurilish
    // paytida o'zgartirib bo'lmaydi — kadr tugagach yoziladi.
    final String name = l10n.eldServiceChannelName;
    final String description = l10n.eldServiceChannelDescription;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        ref
            .read(backgroundChannelLabelsProvider.notifier)
            .set(name: name, description: description);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // **Auto-DR (M56/M62):** kontroller `keepAlive` bo'lsa ham, hech kim uni
    // tinglamasa qurilmaydi. Global obuna uni barcha tab'larda tirik saqlaydi
    // (avval faqat Home tinglar edi). Login'gacha harakat kuzatilmaydi —
    // GPS/ELD taymerlari sessiyasiz ishga tushmaydi.
    if (ref.watch(authStatusProvider) == AuthStatus.authenticated) {
      ref.listen<DriveModeState>(driveModeControllerProvider, _onDriveMode);
    }

    // M145: push deep-link — sovuq start ham shu oqimdan keladi.
    ref.listen<AsyncValue<String>>(pushDeepLinkProvider, (
      AsyncValue<String>? _,
      AsyncValue<String> next,
    ) {
      final String? route = next.value;
      if (route != null && route.isNotEmpty && mounted) {
        GoRouter.of(context).go(route);
      }
    });

    ref.listen<AuthStatus>(authStatusProvider, (AuthStatus? _, AuthStatus next) {
      unawaited(_onAuthStatus(next));
    });

    return widget.child;
  }

  /// Duty status → chat «driving mode» (M140) va fon xizmati profili (§10.4).
  void _onDriveMode(DriveModeState? previous, DriveModeState next) {
    final bool driving = next.status == DutyStatusValue.driving;
    if (previous != null && (previous.status == DutyStatusValue.driving) == driving) {
      return;
    }
    unawaited(ref.read(backgroundCoordinatorProvider).setDriving(driving));
  }

  /// Sessiya holati o'zgarganda: profilni `kv_settings` ga yozish, push token,
  /// sync scheduler va fon xizmati.
  Future<void> _onAuthStatus(AuthStatus status) async {
    if (_lastStatus == status) {
      return;
    }
    _lastStatus = status;

    switch (status) {
      case AuthStatus.authenticated:
        await _writeSessionProfile();
        await ref.read(pushTokenRegistrarProvider).start();
        await _startBackgroundService();
        ref.read(syncSchedulerProvider).start();
      case AuthStatus.locked:
      case AuthStatus.unauthenticated:
        await ref.read(pushTokenRegistrarProvider).stop();
        await ref.read(backgroundCoordinatorProvider).stop();
        // M17: outbox **saqlanadi** — scheduler faqat to'xtatiladi.
        ref.read(syncSchedulerProvider).stop();
      case AuthStatus.unknown:
        break;
    }
  }

  /// Login javobidagi profil → `kv_settings` (`driver_id`, `driver_name`, …).
  ///
  /// Qolgan kalitlar (`carrier_name`, `home_terminal_address`, `unit_number`,
  /// `vehicle_label`) `sync/pull` dan keladi — [PullApplier] yozadi.
  Future<void> _writeSessionProfile() async {
    final AuthRepository auth = ref.read(authRepositoryProvider);
    final DriverProfile? profile = auth.cachedProfile;
    if (profile == null) {
      return;
    }
    await ref
        .read(sessionProfileProvider.notifier)
        .write(
          SessionProfile(
            driverId: profile.id,
            driverName: profile.fullName,
            driverEmail: profile.email,
          ),
        );
  }

  Future<void> _startBackgroundService() async {
    if (!mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    await ref
        .read(backgroundCoordinatorProvider)
        .start(
          BackgroundNotification(
            title: l10n.eldServiceChannelName,
            body: l10n.eldServiceChannelDescription,
          ),
        );
  }
}
