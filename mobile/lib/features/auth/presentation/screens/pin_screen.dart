/// `M-04 PIN entry` (`/pin`) 🎨 — Figma referensi yo'q (tz-mobile §11.2, §4.5).
///
/// 6 xonali PIN, katta raqamli klaviatura (planshetda ham), xato hisoblagichi
/// va blok taymeri. `Forgot PIN?` → `M-02` parol bilan kirish.
///
/// 4 holat: `bo'sh` (nuqtalar bo'sh) · `to'la` (6 raqam, avtomatik yuborish) ·
/// `yuklanish` (tekshiruv) · `xato` (noto'g'ri PIN / blok / format).
///
/// **M157:** bu ekranda `FLAG_SECURE` yoqilishi kerak. Platforma chaqiruvi
/// `core/security` da — TODO(S-01): `ScreenProtection.enable()` porti so'raladi.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error_code.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/security/screen_protection.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/auth_models.dart';
import '../../domain/auth_policies.dart';
import '../controllers/co_driver_controller.dart';
import '../controllers/leave_truck_controller.dart';
import '../controllers/pin_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/pin_pad.dart';
import '../widgets/shipping_document_modal.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({required this.action, super.key});

  final PinAction action;

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> with SecureScreenMixin<PinScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      ref.read(pinControllerProvider.notifier).setAction(widget.action);
    });
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (Timer _) => ref.read(pinControllerProvider.notifier).tick(),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PinState state = ref.watch(pinControllerProvider);
    final PinController controller = ref.read(pinControllerProvider.notifier);
    final AppLocalizations l10n = context.l10n;

    ref.listen<PinState>(pinControllerProvider, (PinState? prev, PinState next) {
      if (next.status.isSuccess && prev?.status.isSuccess != true) {
        unawaited(_onVerified(context));
      }
    });

    final String? message = _message(context, state);

    return AuthShell(
      banners: <Widget>[
        if (state.verifiedOffline)
          BannerStrip(message: l10n.authPinOfflineNotice, tone: BannerTone.offline),
      ],
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              l10n.authPinTitle,
              textAlign: TextAlign.center,
              style: context.text.h4.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: Spacing.s10),
            Text(
              widget.action == PinAction.switchDriver
                  ? l10n.authPinSubtitleSwitchDriver
                  : l10n.authPinSubtitle,
              textAlign: TextAlign.center,
              style: context.text.body15.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
        state.status.isSubmitting
            ? SizedBox(
                height: Spacing.s25,
                child: Center(
                  child: Semantics(
                    label: l10n.authLoadingSemantics,
                    child: SizedBox(
                      height: Spacing.s20,
                      width: Spacing.s20,
                      child: CircularProgressIndicator(
                        strokeWidth: Strokes.emphasis,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
              )
            : PinDots(entered: state.entered.length, hasError: message != null),
        if (message != null)
          Center(child: AuthErrorText(message: message))
        else
          const SizedBox.shrink(),
        PinKeypad(
          enabled: state.canType,
          onDigit: controller.push,
          onBackspace: controller.backspace,
        ),
        Align(
          child: AppButton.text(
            label: l10n.authPinForgot,
            expand: false,
            onPressed: () => context.go(AppRoute.login),
          ),
        ),
      ],
    );
  }

  /// PIN tasdiqlangandan keyingi oqim (§3.3, §4.8).
  ///
  ///  * `switch_driver` → slotlar almashadi (`M9`) → `M-21 Select Shipping
  ///    Document` → Home;
  ///  * `return_to_truck` → sessiya `active`, BLE qayta ulanadi, sync → Home.
  Future<void> _onVerified(BuildContext context) async {
    switch (widget.action) {
      case PinAction.switchDriver:
        await ref.read(coDriverControllerProvider.notifier).confirmSwitch();
        if (!context.mounted) {
          return;
        }
        await showShippingDocumentModal(context);
      case PinAction.returnToTruck:
        await ref.read(leaveTruckControllerProvider.notifier).returnToTruck();
    }
    if (context.mounted) {
      context.go(AppRoute.home);
    }
  }

  /// Xato ustuvorligi: blok → server kodi → lokal format.
  String? _message(BuildContext context, PinState state) {
    final AppLocalizations l10n = context.l10n;
    if (state.isLocked) {
      return l10n.authPinLocked(state.lockRemaining.inSeconds);
    }
    final String? code = state.status.errorCode;
    if (code != null) {
      return switch (code) {
        ApiErrorCode.pinInvalid =>
          '${l10n.authPinErrorIncorrect} · ${l10n.authPinAttemptsLeft(state.attemptsLeft)}',
        ApiErrorCode.pinNotSet => l10n.authPinNotSet,
        _ => localizedApiErrorCode(l10n, code),
      };
    }
    return switch (state.formatIssue) {
      PinFormatIssue.length => l10n.authPinErrorLength,
      PinFormatIssue.repeated => l10n.authPinErrorRepeated,
      PinFormatIssue.sequence => l10n.authPinErrorSequence,
      null => null,
    };
  }
}
