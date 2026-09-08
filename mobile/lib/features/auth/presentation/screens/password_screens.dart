/// `M-06 Forgot password` (`/forgot`) va `M-07 Reset password` (`/reset`) 🎨.
///
/// Figma referensi yo'q — tz-mobile §4.1 (249–252) va §21.6 asosida,
/// `M-02` ning qobig'i (`AuthShell`) va komponentlari qayta ishlatiladi.
///
/// 4 holat: `bo'sh` (token yo'q / maydon bo'sh) · `to'la` · `yuklanish` ·
/// `xato`. Muvaffaqiyat — `EmptyState` ko'rinishidagi tasdiq + `Back to login`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/auth_policies.dart';
import '../controllers/password_controllers.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/auth_shell.dart';
import '../widgets/password_strength_meter.dart';

// --------------------------------------------------------------- M-06

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _login = TextEditingController();

  @override
  void dispose() {
    _login.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordState state = ref.watch(forgotPasswordControllerProvider);
    final ForgotPasswordController controller = ref.read(forgotPasswordControllerProvider.notifier);
    final AppLocalizations l10n = context.l10n;

    if (state.status.isSuccess) {
      return AuthShell(
        children: <Widget>[
          EmptyState(
            icon: Icons.mark_email_read_outlined,
            title: l10n.authForgotTitle,
            message: l10n.authForgotSent,
            actionLabel: l10n.authBackToLogin,
            onAction: () => context.go(AppRoute.login),
          ),
        ],
      );
    }

    return AuthShell(
      children: <Widget>[
        AuthHeading(title: l10n.authForgotTitle, description: l10n.authForgotDescription),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              controller: _login,
              label: l10n.authUsernameLabel,
              hint: l10n.authUsernameHint,
              keyboardType: TextInputType.emailAddress,
              enabled: !state.status.isSubmitting,
              errorText: state.loginIssue == null ? null : l10n.authErrorUsernameRequired,
              onChanged: controller.setLogin,
              onSubmitted: (String _) => controller.submit(),
            ),
            if (state.status.isFailure) ...<Widget>[
              const SizedBox(height: Spacing.s10),
              AuthErrorText(message: localizedApiErrorCode(l10n, state.status.errorCode ?? '')),
            ],
          ],
        ),
        AppButton.primary(
          label: l10n.authForgotSubmit,
          busy: state.status.isSubmitting,
          onPressed: state.canSubmit ? controller.submit : null,
        ),
        Align(
          child: AppButton.text(
            label: l10n.authBackToLogin,
            expand: false,
            onPressed: () => context.go(AppRoute.login),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------- M-07

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({required this.token, super.key});

  /// Deep link tokeni (`onebookeld://reset?token=…`, M162).
  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      ref.read(resetPasswordControllerProvider.notifier).setToken(widget.token);
    });
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ResetPasswordState state = ref.watch(resetPasswordControllerProvider);
    final ResetPasswordController controller = ref.read(resetPasswordControllerProvider.notifier);
    final AppLocalizations l10n = context.l10n;

    // «Bo'sh» holat — deep link tokensiz ochilgan.
    if (widget.token.isEmpty) {
      return AuthShell(
        children: <Widget>[
          EmptyState(
            icon: Icons.link_off,
            title: l10n.authResetTitle,
            message: l10n.authResetMissingToken,
            actionLabel: l10n.authBackToLogin,
            onAction: () => context.go(AppRoute.login),
          ),
        ],
      );
    }

    if (state.status.isSuccess) {
      return AuthShell(
        children: <Widget>[
          EmptyState(
            icon: Icons.lock_reset,
            title: l10n.authResetTitle,
            message: l10n.authResetSuccess,
            actionLabel: l10n.authBackToLogin,
            onAction: () => context.go(AppRoute.login),
          ),
        ],
      );
    }

    return AuthShell(
      children: <Widget>[
        AuthHeading(title: l10n.authResetTitle, description: l10n.authResetDescription),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              controller: _password,
              label: l10n.authInvitePasswordLabel,
              hint: l10n.authPasswordHint,
              obscureText: state.obscure,
              enabled: !state.status.isSubmitting,
              errorText: state.pairIssue == PasswordPairIssue.tooShort
                  ? l10n.authErrorPasswordTooShort
                  : null,
              suffix: ObscureToggle(obscured: state.obscure, onPressed: controller.toggleObscure),
              onChanged: controller.setPassword,
            ),
            const SizedBox(height: Spacing.s10),
            PasswordStrengthMeter(strength: state.strength),
            const SizedBox(height: Spacing.s25),
            AppTextField(
              controller: _confirm,
              label: l10n.authInvitePasswordConfirmLabel,
              hint: l10n.authPasswordHint,
              obscureText: state.obscure,
              enabled: !state.status.isSubmitting,
              errorText: state.pairIssue == PasswordPairIssue.mismatch
                  ? l10n.authPasswordMismatch
                  : null,
              onChanged: controller.setPasswordConfirm,
              onSubmitted: (String _) => controller.submit(),
            ),
            if (state.status.isFailure) ...<Widget>[
              const SizedBox(height: Spacing.s10),
              AuthErrorText(message: localizedApiErrorCode(l10n, state.status.errorCode ?? '')),
            ],
          ],
        ),
        AppButton.primary(
          label: l10n.authResetSubmit,
          busy: state.status.isSubmitting,
          onPressed: state.canSubmit ? controller.submit : null,
        ),
        Align(
          child: AppButton.text(
            label: l10n.authBackToLogin,
            expand: false,
            onPressed: () => context.go(AppRoute.login),
          ),
        ),
      ],
    );
  }
}
