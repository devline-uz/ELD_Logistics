/// `M-05 Accept invitation` (`/invite`) 🎨 — tz-mobile 1206–1208.
///
/// Parol (2×) + PIN (2×) + `Privacy Policy` / `Terms of Use` roziligi,
/// parol kuchi indikatori, `POST /auth/invitation/accept`.
///
/// 4 holat: `bo'sh` (deep link tokensiz) · `to'la` · `yuklanish` · `xato`.
///
/// **M157:** `FLAG_SECURE` kerak — TODO(S-01), `core/security` porti.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/security/screen_protection.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/auth_policies.dart';
import '../controllers/invitation_controller.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/auth_shell.dart';
import '../widgets/password_strength_meter.dart';

class InvitationScreen extends ConsumerStatefulWidget {
  const InvitationScreen({required this.token, super.key});

  /// `onebookeld://invite?token=…` (M162 oq ro'yxati routerda tekshiriladi).
  final String token;

  @override
  ConsumerState<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends ConsumerState<InvitationScreen>
    with SecureScreenMixin<InvitationScreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  final TextEditingController _pin = TextEditingController();
  final TextEditingController _pinConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      ref.read(invitationControllerProvider.notifier).setToken(widget.token);
    });
  }

  @override
  void dispose() {
    _password.dispose();
    _passwordConfirm.dispose();
    _pin.dispose();
    _pinConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final InvitationState state = ref.watch(invitationControllerProvider);
    final InvitationController controller = ref.read(invitationControllerProvider.notifier);
    final AppLocalizations l10n = context.l10n;

    if (widget.token.isEmpty) {
      return AuthShell(
        children: <Widget>[
          EmptyState(
            icon: Icons.link_off,
            title: l10n.authInviteTitle,
            message: l10n.authInviteMissingToken,
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
            icon: Icons.verified_user_outlined,
            title: l10n.authInviteTitle,
            message: l10n.authInviteSuccess,
            actionLabel: l10n.authBackToLogin,
            onAction: () => context.go(AppRoute.login),
          ),
        ],
      );
    }

    return AuthShell(
      children: <Widget>[
        AuthHeading(title: l10n.authInviteTitle, description: l10n.authInviteDescription),

        // --- Parol (2×) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              controller: _password,
              label: l10n.authInvitePasswordLabel,
              hint: l10n.authPasswordHint,
              obscureText: state.obscure,
              enabled: !state.status.isSubmitting,
              errorText: state.passwordIssue == PasswordPairIssue.tooShort
                  ? l10n.authErrorPasswordTooShort
                  : null,
              suffix: ObscureToggle(obscured: state.obscure, onPressed: controller.toggleObscure),
              onChanged: controller.setPassword,
            ),
            const SizedBox(height: Spacing.s10),
            PasswordStrengthMeter(strength: state.strength),
            const SizedBox(height: Spacing.s25),
            AppTextField(
              controller: _passwordConfirm,
              label: l10n.authInvitePasswordConfirmLabel,
              hint: l10n.authPasswordHint,
              obscureText: state.obscure,
              enabled: !state.status.isSubmitting,
              errorText: state.passwordIssue == PasswordPairIssue.mismatch
                  ? l10n.authPasswordMismatch
                  : null,
              onChanged: controller.setPasswordConfirm,
            ),
          ],
        ),

        // --- PIN (2×) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              controller: _pin,
              label: l10n.authInvitePinLabel,
              obscureText: true,
              enabled: !state.status.isSubmitting,
              keyboardType: TextInputType.number,
              maxLength: PinPolicy.length,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              errorText: _pinFormatMessage(l10n, state.pinFormatIssue),
              onChanged: controller.setPin,
            ),
            const SizedBox(height: Spacing.s25),
            AppTextField(
              controller: _pinConfirm,
              label: l10n.authInvitePinConfirmLabel,
              obscureText: true,
              enabled: !state.status.isSubmitting,
              keyboardType: TextInputType.number,
              maxLength: PinPolicy.length,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              errorText: state.pinIssue == PinPairIssue.mismatch ? l10n.authPinMismatch : null,
              onChanged: controller.setPinConfirm,
            ),
          ],
        ),

        // --- Rozilik ---
        InkWell(
          onTap: state.status.isSubmitting
              ? null
              : () => controller.setConsent(!state.consentGiven),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                value: state.consentGiven,
                onChanged: state.status.isSubmitting
                    ? null
                    : (bool? value) => controller.setConsent(value ?? false),
              ),
              Expanded(
                child: Text(
                  l10n.authInviteConsent,
                  style: context.text.body15.copyWith(color: context.colors.textPrimary),
                ),
              ),
            ],
          ),
        ),

        if (state.status.isFailure)
          AuthErrorText(message: localizedApiErrorCode(l10n, state.status.errorCode ?? ''))
        else
          const SizedBox.shrink(),

        AppButton.primary(
          label: l10n.authInviteSubmit,
          busy: state.status.isSubmitting,
          onPressed: state.canSubmit ? controller.submit : null,
        ),
      ],
    );
  }

  String? _pinFormatMessage(AppLocalizations l10n, PinFormatIssue? issue) => switch (issue) {
    PinFormatIssue.length => l10n.authPinErrorLength,
    PinFormatIssue.repeated => l10n.authPinErrorRepeated,
    PinFormatIssue.sequence => l10n.authPinErrorSequence,
    null => null,
  };
}
