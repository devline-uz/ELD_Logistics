/// `M-02 Login` (`/login`) va `M-03 Leave truck` (`/paused`).
///
/// Figma: `958:44 Login` · `1113:9176 Login - filled` · `1116:9231 leave truck`
/// (dark: `2665:32374` / `2665:32428`).
///
/// Tartib (Figma `Frame 1321317004`, oraliq 25 dp):
/// `[Username + Password]` → `Login` → `Category / Small` eslatmasi;
/// `M-03` da `Login` ustida qo'shimcha `Return to truck` (secondary) tugmasi.
/// Footer: `Copyright © <yil> OneBook ELD`, 72 dp, ustida 1 px chegara.
///
/// 4 holat: `bo'sh` (tugma o'chirilgan) · `to'la` · `yuklanish` (tugmada
/// spinner) · `xato` (inline qizil matn). Oflayn — banner + o'chirilgan tugma.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/time/time_providers.dart';
import '../../../../core/ui/ui.dart';
import '../../auth_routes.dart';
import '../../domain/auth_models.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({required this.mode, super.key});

  final LoginMode mode;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoginState state = ref.watch(loginControllerProvider);
    final LoginController controller = ref.read(loginControllerProvider.notifier);
    final AppLocalizations l10n = context.l10n;

    ref.listen<LoginState>(loginControllerProvider, (LoginState? prev, LoginState next) {
      if (next.status.isSuccess && prev?.status.isSuccess != true) {
        _password.clear();
        context.go(next.requiresTotpSetup ? AuthRoute.twoFactor : AppRoute.home);
      }
    });

    final String year = ref.watch(timeSourceProvider).now().year.toString();

    return AuthShell(
      banners: <Widget>[
        if (state.offline) BannerStrip(message: l10n.authOfflineBanner, tone: BannerTone.offline),
        if (state.replacedSession)
          BannerStrip(message: _replacedMessage(context), tone: BannerTone.info),
      ],
      header: widget.mode == LoginMode.leaveTruck ? const _PausedDriverHeader() : null,
      footer: widget.mode == LoginMode.signIn ? Text(l10n.authCopyright(year)) : null,
      children: <Widget>[
        // --- Maydonlar bloki (Figma `Frame 5`, ichki oraliq 25) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              controller: _username,
              label: l10n.authUsernameLabel,
              hint: l10n.authUsernameHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !state.status.isSubmitting,
              errorText: state.usernameIssue == null ? null : l10n.authErrorUsernameRequired,
              onChanged: controller.setUsername,
            ),
            const SizedBox(height: Spacing.s25),
            AppTextField(
              controller: _password,
              label: l10n.authPasswordLabel,
              hint: l10n.authPasswordHint,
              obscureText: state.obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: !state.status.isSubmitting,
              errorText: state.passwordIssue == null ? null : l10n.authErrorPasswordTooShort,
              suffix: IconButton(
                onPressed: controller.toggleObscure,
                iconSize: Spacing.s20,
                tooltip: state.obscurePassword ? l10n.authShowPassword : l10n.authHidePassword,
                icon: Icon(
                  state.obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: context.colors.textSecondary,
                ),
              ),
              onChanged: controller.setPassword,
              onSubmitted: (String _) => controller.submit(),
            ),
            if (state.status.isFailure) ...<Widget>[
              const SizedBox(height: Spacing.s10),
              AuthErrorText(message: _errorMessage(context, state)),
            ],
          ],
        ),

        // --- Amallar (M-03 da `Return to truck` yuqorida) ---
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.mode == LoginMode.leaveTruck) ...<Widget>[
              AppButton.secondary(
                label: l10n.authReturnToTruck,
                onPressed: state.status.isSubmitting
                    ? null
                    : () => context.go(
                        '${AppRoute.pin}?${AuthRoute.actionParam}='
                        '${PinAction.returnToTruck.wire}',
                      ),
              ),
              const SizedBox(height: Spacing.s15),
            ],
            AppButton.primary(
              label: l10n.authLoginButton,
              busy: state.status.isSubmitting,
              onPressed: state.canSubmit ? controller.submit : null,
            ),
            const SizedBox(height: Spacing.s15),
            Align(
              child: AppButton.text(
                label: l10n.authForgotPassword,
                expand: false,
                onPressed: () => context.go(AuthRoute.forgot),
              ),
            ),
          ],
        ),

        // --- Ro'yxatdan o'tish yo'q eslatmasi (M12, matn o'zgartirilmaydi) ---
        AuthNoticeCard(message: l10n.authNoRegistrationNotice),
      ],
    );
  }

  String _replacedMessage(BuildContext context) => context.deviceProfile.isTablet
      ? context.l10n.authReplacedSessionTablet
      : context.l10n.authReplacedSessionPhone;

  String _errorMessage(BuildContext context, LoginState state) {
    final String? code = state.status.errorCode;
    if (code == null) {
      return context.l10n.errUnknown;
    }
    final Duration? retryAfter = state.status.retryAfter;
    if (retryAfter != null) {
      return context.l10n.authRateLimited(retryAfter.inSeconds);
    }
    return localizedApiErrorCode(context.l10n, code);
  }
}

/// `M-03`: pauza qilingan haydovchi ismi ekranning yuqorisida.
class _PausedDriverHeader extends ConsumerWidget {
  const _PausedDriverHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? name = ref.watch(pausedDriverNameProvider);
    if (name == null || name.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      context.l10n.authPausedBanner(name),
      textAlign: TextAlign.center,
      style: context.text.body12.copyWith(color: context.colors.textPrimary),
    );
  }
}
