/// `Leave Truck` va to'liq `Logout` tasdiq oqimlari (§4.8, M18, M93).
///
/// `Leave Truck` **≠ `Log out`**: sessiya `paused` bo'ladi, refresh token
/// tirik qoladi, qaytish faqat PIN orqali (`M-04` → `M-03`).
///
/// Ikkala tasdiq ham `ConfirmDialog` (destruktiv variant) — telefon va
/// planshetda bir xil, chunki qaror matni qisqa (M122 modal sarlavha qatori
/// bu yerda kerak emas).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/ui/ui.dart';
import '../../auth_routes.dart';
import '../../domain/leave_truck_policy.dart';
import '../../domain/session_policy.dart';
import '../controllers/leave_truck_controller.dart';

/// `Leave Truck` tugmasi bosilganda: tasdiq → §4.8 qadamlari → yo'naltirish.
///
/// Co-driver faol bo'lsa ekran **Home'da qoladi** (Login ko'rsatilmaydi).
Future<void> showLeaveTruckDialog(BuildContext context, WidgetRef ref) async {
  final AppLocalizations l10n = context.l10n;
  final LeaveTruckController controller = ref.read(leaveTruckControllerProvider.notifier);
  final LeaveTruckPrompt prompt = controller.prompt;

  final bool confirmed = await showConfirmDialog(
    context: context,
    title: l10n.authLeaveTruckConfirmTitle,
    message: switch (prompt) {
      LeaveTruckPrompt.coDriverTakesOver => l10n.authLeaveTruckCoDriverBody(
        ref.read(leaveTruckCoDriverNameProvider),
      ),
      LeaveTruckPrompt.offDutyWarning => l10n.authLeaveTruckConfirmBody,
    },
    cancelLabel: l10n.commonCancel,
    confirmLabel: l10n.authLeaveTruckAction,
    destructive: true,
  );
  if (!confirmed || !context.mounted) {
    return;
  }

  final LeaveTruckOutcome outcome = await controller.leaveTruck();
  if (!context.mounted) {
    return;
  }
  switch (outcome) {
    case LeaveTruckOutcome.coDriverPromoted:
      // Ekran Home'da qoladi — faqat `ActiveDriverBanner` yangilanadi.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authLeaveTruckDone)));
    case LeaveTruckOutcome.paused:
      context.go(AuthRoute.paused);
  }
}

/// Drawer'dagi qizil `Logout` (`pause=false`) — **M18** ogohlantirishi bilan.
Future<void> showLogoutDialog(BuildContext context, WidgetRef ref) async {
  final AppLocalizations l10n = context.l10n;
  final LeaveTruckController controller = ref.read(leaveTruckControllerProvider.notifier);

  final bool confirmed = await showConfirmDialog(
    context: context,
    title: l10n.authLogoutTitle,
    message: switch (controller.logoutPrompt()) {
      LogoutPrompt.unsyncedRecords => l10n.authLogoutUnsynced(controller.queuedRecords),
      LogoutPrompt.plain => l10n.authLogoutBody,
    },
    cancelLabel: l10n.commonCancel,
    confirmLabel: l10n.authLogoutAction,
    destructive: true,
  );
  if (!confirmed || !context.mounted) {
    return;
  }

  await controller.logout();
  if (context.mounted) {
    context.go(AppRoute.login);
  }
}
