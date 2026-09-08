/// **M-17 ELD not connected** (dialog) — Figma `1102:1738`, tz-mobile
/// 894–905 · 876–881, qaror **M70**.
///
/// ELD ga ulanish uchun ruxsatlar yetishmasa chiqadi:
/// «In order to connect to the ELD, you must allow all the permissions.»
/// `Cancel` / `Allow Permissions`. **M66:** dialog status o'zgartirishni
/// bloklamaydi — foydalanuvchi `Cancel` bosib ishini davom ettira oladi.
///
/// ⚠️ Dark tema uchun Figma juftligi yo'q (`design/figma/MAP.md` §1) —
/// `ConfirmDialog` tokenlari ikkala temada ishlaydi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/eld/eld_permissions.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/permissions_controller.dart';

/// Dialog natijasi.
enum EldNotConnectedResult {
  /// `Cancel` yoki tashqariga bosildi.
  cancelled,

  /// `Allow Permissions` — §10.2 ketma-ketligi ishga tushdi.
  permissionsRequested,
}

/// M-17 ni ko'rsatadi. Ruxsatlar allaqachon yetarli bo'lsa dialog **ochilmaydi**
/// va `null` qaytadi (chaqiruvchi to'g'ridan-to'g'ri ulanishga o'tadi).
Future<EldNotConnectedResult?> showEldNotConnectedDialog(BuildContext context) =>
    showDialog<EldNotConnectedResult>(
      context: context,
      builder: (BuildContext context) => const EldNotConnectedDialog(),
    );

class EldNotConnectedDialog extends ConsumerWidget {
  const EldNotConnectedDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    return ConfirmDialog(
      title: l10n.eldNotConnectedDialogTitle,
      message: l10n.eldNotConnectedDialogMessage,
      cancelLabel: l10n.commonCancel,
      confirmLabel: l10n.eldNotConnectedDialogAllow,
      onCancel: () => Navigator.of(context).pop(EldNotConnectedResult.cancelled),
      onConfirm: () async {
        final NavigatorState navigator = Navigator.of(context);
        await ref.read(permissionsControllerProvider.notifier).runOnboardingFlow();
        if (navigator.mounted) {
          navigator.pop(EldNotConnectedResult.permissionsRequested);
        }
      },
    );
  }
}

/// M70: ulanishdan oldin ruxsatlarni tekshiradi.
///
/// `true` — ulanish davom etishi mumkin; `false` — M-17 ko'rsatildi.
Future<bool> ensureEldPermissions(BuildContext context, WidgetRef ref) async {
  final EldPermissionSnapshot snapshot = await ref.read(eldPermissionServiceProvider).snapshot();
  if (snapshot.canConnectEld) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  await showEldNotConnectedDialog(context);
  final EldPermissionSnapshot after = await ref.read(eldPermissionServiceProvider).snapshot();
  return after.canConnectEld;
}
