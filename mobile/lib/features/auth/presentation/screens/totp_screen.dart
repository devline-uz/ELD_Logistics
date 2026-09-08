/// `M-08 Two-factor (TOTP)` (`/2fa`) 🎨 — tz-mobile 1209–1213.
///
/// Setup qadamida secret ko'rsatiladi (QR emas: `qr_flutter` paketi
/// `pubspec.yaml` da yo'q — TODO(P-02) so'raladi, `otpauth_url` nusxalanadi),
/// verify qadamida 6 xonali kod. Yoqilgach recovery kodlar chiqadi.
///
/// 4 holat: `yuklanish` (setup so'rovi) · `bo'sh` (2FA talab qilinmaydi) ·
/// `xato` (`ErrorState` + `Retry`) · `to'la`.
///
/// **M157:** `FLAG_SECURE` kerak — TODO(S-01).
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
import '../../data/auth_providers.dart';
import '../../domain/auth_models.dart';
import '../../domain/auth_policies.dart';
import '../controllers/totp_controller.dart';
import '../widgets/auth_form_parts.dart';
import '../widgets/auth_shell.dart';

/// Yuklanish skeletining chegaralangan balandligi (3 ta karta).
const double _kSkeletonHeight = 300;

class TotpScreen extends ConsumerStatefulWidget {
  const TotpScreen({super.key});

  @override
  ConsumerState<TotpScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends ConsumerState<TotpScreen> with SecureScreenMixin<TotpScreen> {
  final TextEditingController _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _start());
  }

  void _start() {
    final DriverProfile? profile = ref.read(authRepositoryProvider).cachedProfile;
    ref
        .read(totpControllerProvider.notifier)
        .start(required: true, alreadyEnabled: profile?.totpEnabled ?? false);
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TotpState state = ref.watch(totpControllerProvider);
    final TotpController controller = ref.read(totpControllerProvider.notifier);
    final AppLocalizations l10n = context.l10n;

    if (state.loadErrorCode != null) {
      return AuthShell(
        children: <Widget>[
          ErrorState(
            title: l10n.authTotpTitle,
            message: localizedApiErrorCode(l10n, state.loadErrorCode!),
            retryLabel: l10n.commonRetry,
            onRetry: _start,
          ),
        ],
      );
    }

    return switch (state.step) {
      // `LoadingSkeleton` ichida `ListView` bor; `AuthShell` bolalarni
      // `SingleChildScrollView` ga joylaydi — vertikal chegara berilmasa
      // «Vertical viewport was given unbounded height» assertioni tushadi.
      TotpStep.loading => const AuthShell(
        children: <Widget>[
          SizedBox(height: _kSkeletonHeight, child: LoadingSkeleton(itemCount: 3)),
        ],
      ),
      TotpStep.notRequired => AuthShell(
        children: <Widget>[
          EmptyState(
            icon: Icons.verified_outlined,
            title: l10n.authTotpTitle,
            message: l10n.authTotpEmpty,
            actionLabel: l10n.authContinue,
            onAction: () => context.go(AppRoute.home),
          ),
        ],
      ),
      TotpStep.enabled => AuthShell(
        children: <Widget>[
          AuthHeading(
            title: l10n.authTotpRecoveryCodesTitle,
            description: l10n.authTotpRecoveryCodesHint,
          ),
          _RecoveryCodes(codes: state.recoveryCodes),
          AppButton.primary(label: l10n.authContinue, onPressed: () => context.go(AppRoute.home)),
        ],
      ),
      TotpStep.setup || TotpStep.verify => AuthShell(
        children: <Widget>[
          AuthHeading(
            title: l10n.authTotpTitle,
            description: state.step == TotpStep.setup
                ? l10n.authTotpSetupDescription
                : l10n.authTotpVerifyDescription,
          ),
          if (state.setup != null) _SetupKey(secret: state.setup!.secret),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppTextField(
                controller: _code,
                label: l10n.authTotpCodeLabel,
                enabled: !state.status.isSubmitting,
                keyboardType: TextInputType.number,
                maxLength: TotpCodePolicy.length,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                onChanged: controller.setCode,
                onSubmitted: (String _) => controller.submit(),
              ),
              if (state.status.isFailure) ...<Widget>[
                const SizedBox(height: Spacing.s10),
                AuthErrorText(message: localizedApiErrorCode(l10n, state.status.errorCode ?? '')),
              ],
            ],
          ),
          AppButton.primary(
            label: l10n.authTotpSubmit,
            busy: state.status.isSubmitting,
            onPressed: state.canSubmit ? controller.submit : null,
          ),
        ],
      ),
    };
  }
}

/// Setup kaliti — nusxalash mumkin, logga **yozilmaydi** (M159).
class _SetupKey extends StatelessWidget {
  const _SetupKey({required this.secret});

  final String secret;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(Spacing.s15),
      decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: Radii.cardRadius),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.authTotpSecretLabel,
                  style: context.text.body16.copyWith(color: context.colors.textSecondary),
                ),
                const SizedBox(height: Spacing.s5),
                SelectableText(
                  secret,
                  style: context.text.body12.copyWith(color: context.colors.textPrimary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.authTotpCopySecret,
            iconSize: Spacing.s20,
            icon: Icon(Icons.copy_rounded, color: context.colors.textSecondary),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: secret));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.authTotpSecretCopied)));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RecoveryCodes extends StatelessWidget {
  const _RecoveryCodes({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Spacing.s15),
    decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: Radii.cardRadius),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final String code in codes)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s5),
            child: SelectableText(
              code,
              style: context.text.body12.copyWith(color: context.colors.textPrimary),
            ),
          ),
      ],
    ),
  );
}
