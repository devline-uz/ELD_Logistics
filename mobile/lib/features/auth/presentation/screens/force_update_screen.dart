/// `M-57 Force update` (`/update`) 🎨 — tz-mobile 1523.
///
/// **Bloklovchi:** `Back` yo'q (`PopScope(canPop: false)`), yagona amal —
/// do'konni ochish. `latest_version` / `min_supported_version` ko'rsatiladi.
///
/// 4 holat: `to'la` (versiyalar ma'lum) · `bo'sh` (`app/config` keshi yo'q —
/// versiya satri `N/A`) · `yuklanish` (do'kon ochilmoqda) · `xato` (do'kon
/// topilmadi).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/force_update_controller.dart';
import '../widgets/auth_shell.dart';

class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ForceUpdateState state = ref.watch(forceUpdateControllerProvider);
    final AppLocalizations l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: AuthShell(
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(
                Icons.system_update_alt_rounded,
                size: Spacing.s40,
                color: context.colors.primary,
              ),
              const SizedBox(height: Spacing.s15),
              Text(
                l10n.authUpdateTitle,
                textAlign: TextAlign.center,
                style: context.text.h4.copyWith(color: context.colors.textPrimary),
              ),
              const SizedBox(height: Spacing.s10),
              Text(
                l10n.authUpdateMessage,
                textAlign: TextAlign.center,
                style: context.text.body15.copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(height: Spacing.s10),
              Text(
                l10n.authUpdateVersions(state.currentVersion, state.requiredVersion ?? kEmptyValue),
                textAlign: TextAlign.center,
                style: context.text.body16.copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
          if (state.storeUnavailable)
            Center(child: AuthErrorText(message: l10n.authUpdateStoreUnavailable))
          else
            const SizedBox.shrink(),
          AppButton.primary(
            label: l10n.authUpdateAction,
            busy: state.opening,
            onPressed: ref.read(forceUpdateControllerProvider.notifier).openStore,
          ),
        ],
      ),
    );
  }
}
