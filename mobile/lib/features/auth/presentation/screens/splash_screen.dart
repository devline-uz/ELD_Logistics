/// `M-01 Splash` (`/`) — Figma `958:22` light / `2665:32354` dark.
///
/// Freym: fon `#FCFCFD` (= `colors.bg`), logotip `200.39×115.52` markazda,
/// **matn yo'q**. §19: 3 s dan uzoq bo'lsa progress ko'rsatiladi.
///
/// 4 holat: `yuklanish` (logotip, 3 s dan keyin progress) · `bo'sh` (bootstrap
/// natijasi bilan darhol o'tiladi) · `xato` (`ErrorState` + `Retry`) ·
/// `to'la` (yo'nalish bo'yicha navigatsiya).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/auth_state.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/ui/ui.dart';
import '../../auth_routes.dart';
import '../../domain/auth_repository.dart';
import '../controllers/splash_controller.dart';
import '../widgets/auth_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _progressTimer;
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
    _progressTimer = Timer(kSplashProgressThreshold, () {
      if (mounted) {
        setState(() => _showProgress = true);
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _route(BootstrapResult result) {
    final AuthStatusNotifier auth = ref.read(authStatusProvider.notifier);
    switch (result.destination) {
      case BootstrapDestination.forceUpdate:
        context.go(AuthRoute.update);
      case BootstrapDestination.home:
        auth.set(AuthStatus.authenticated);
        context.go(AppRoute.home);
      case BootstrapDestination.paused:
        auth.set(AuthStatus.locked);
        context.go(AuthRoute.paused);
      case BootstrapDestination.login:
        auth.set(AuthStatus.unauthenticated);
        context.go(AppRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<BootstrapResult>>(splashControllerProvider, (
      AsyncValue<BootstrapResult>? _,
      AsyncValue<BootstrapResult> next,
    ) {
      final BootstrapResult? value = next.value;
      if (value != null) {
        _route(value);
      }
    });

    final AsyncValue<BootstrapResult> state = ref.watch(splashControllerProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Center(
          child: state.hasError
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kAuthFormPaddingH),
                  child: ErrorState(
                    message: _errorMessage(context, state.error),
                    retryLabel: context.l10n.commonRetry,
                    onRetry: ref.read(splashControllerProvider.notifier).retry,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const AuthBrandLogo(),
                    const SizedBox(height: Spacing.s40),
                    if (_showProgress)
                      Semantics(
                        label: context.l10n.authSplashLoading,
                        child: SizedBox(
                          height: Spacing.s20,
                          width: Spacing.s20,
                          child: CircularProgressIndicator(
                            strokeWidth: Strokes.emphasis,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  String _errorMessage(BuildContext context, Object? error) =>
      error is ApiError ? localizedApiError(context.l10n, error) : context.l10n.authSplashError;
}
