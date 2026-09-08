/// `M-56 Signed out elsewhere` (`/signed-out`) 🎨 — Figma referensi yo'q
/// (tz-mobile 1522, §4.6).
///
/// Eski qurilma birinchi `401 TOKEN_REVOKED` da shu ekranga tushadi:
/// «Your account was used to sign in on another `<device_type>`.» + `Sign in again`.
///
/// **M17:** oflayn navbat **o'chirilmaydi** — ekran buni aniq aytadi, aks
/// holda haydovchi yozuvlari yo'qolgan deb o'ylaydi.
///
/// Holatlar: bu ekran statik (yuklanish/bo'sh holati yo'q); yagona o'zgaruvchi
/// — qaysi qurilma turida sessiya olingani.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/security/secure_vault.dart';
import '../../../../core/ui/ui.dart';
import '../../data/session_manager.dart';
import '../../domain/driver_session.dart';
import '../widgets/auth_shell.dart';

class SignedOutScreen extends ConsumerWidget {
  const SignedOutScreen({this.replacedBy = SessionDeviceType.phone, super.key});

  /// Sessiyani egallagan qurilma turi (`?device=phone|tablet|web`).
  final SessionDeviceType replacedBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return AuthShell(
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(Icons.devices_other_outlined, size: Spacing.s40, color: context.colors.error),
            const SizedBox(height: Spacing.s15),
            Text(
              l10n.authSignedOutTitle,
              textAlign: TextAlign.center,
              style: context.text.h4.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: Spacing.s10),
            Text(
              switch (replacedBy) {
                SessionDeviceType.tablet => l10n.authSignedOutMessageTablet,
                SessionDeviceType.web => l10n.authSignedOutMessageWeb,
                SessionDeviceType.phone => l10n.authSignedOutMessagePhone,
              },
              textAlign: TextAlign.center,
              style: context.text.body15.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
        AuthNoticeCard(message: l10n.authSignedOutQueueNotice),
        AppButton.primary(
          label: l10n.authSignedOutAction,
          onPressed: () async {
            // Slot bo'shatiladi (outbox tegilmaydi — M17), keyin `M-02`.
            await ref.read(sessionManagerProvider.notifier).signOut(DriverSlot.primary);
            if (context.mounted) {
              context.go(AppRoute.login);
            }
          },
        ),
      ],
    );
  }
}
