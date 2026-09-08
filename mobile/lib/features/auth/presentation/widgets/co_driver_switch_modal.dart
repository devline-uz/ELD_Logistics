/// `M-20 Co-driver switch confirm` (dialog) · `T-07 Switch co-driver` (modal).
///
/// Figma: `1113:8480` (telefon) / `1517:51373` (planshet). Ikkala profil bitta
/// `CoDriverController` ni ulashadi (M7) — faqat qobiq boshqa: telefonda
/// `AppBottomSheet`, planshetda `TabletModal` (sarlavha qatori M122).
///
/// Oqim (§3.3): `Switch` → tasdiq → **PIN** (`action=switch_driver`) →
/// slotlar almashadi → `M-21 Select Shipping Document`.
///
/// 4 holat: `to'la` (ikki haydovchi) · `bo'sh` (co-driver login qilmagan) ·
/// `xato/bloklangan` (co-driver pauzada) · `yuklanish` (almashtirilmoqda).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/session_policy.dart';
import '../../domain/session_state.dart';
import '../controllers/co_driver_controller.dart';

/// Modalni profilga mos ko'rinishda ochadi.
///
/// Natija: `true` — foydalanuvchi PIN oqimiga o'tishni tanladi.
Future<bool?> showCoDriverSwitchModal(BuildContext context) => showAdaptiveModal<bool>(
  context: context,
  builder: (BuildContext ctx) => const CoDriverSwitchModal(),
);

class CoDriverSwitchModal extends ConsumerWidget {
  const CoDriverSwitchModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final CoDriverState state = ref.watch(coDriverControllerProvider);
    // Kichik telefonlarda EmptyState bilan birga sig'masligi mumkin — tana
    // har doim scroll ichida (M8 teginish maydonlari saqlanadi).
    final Widget body = SingleChildScrollView(child: CoDriverSwitchBody(state: state));

    return AdaptiveView(
      phone: (BuildContext c) => AppBottomSheet(title: l10n.authCoDriverTitle, child: body),
      tablet: (BuildContext c) => TabletModal(
        title: l10n.authCoDriverTitle,
        cancelLabel: l10n.commonCancel,
        actionLabel: state.canSwitch ? l10n.authCoDriverSwitchAction : null,
        actionEnabled: state.canSwitch && !state.busy,
        onAction: () => Navigator.of(c).pop(true),
        child: body,
      ),
    );
  }
}

/// Modal tanasi — golden va widget testlarida to'g'ridan-to'g'ri ishlatiladi.
class CoDriverSwitchBody extends StatelessWidget {
  const CoDriverSwitchBody({required this.state, super.key});

  final CoDriverState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SlotTile(label: l10n.authCoDriverActiveLabel, slot: state.activeDriver, highlighted: true),
        const SizedBox(height: Spacing.s10),
        if (state.needsCoDriverLogin)
          EmptyState(
            title: l10n.authCoDriverNoneTitle,
            message: l10n.authCoDriverNoneMessage,
            icon: Icons.person_add_alt_1_outlined,
          )
        else
          _SlotTile(label: l10n.authCoDriverSecondLabel, slot: state.coDriver, highlighted: false),
        if (state.blockedBy == SwitchBlockReason.coDriverPaused) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          BannerStrip(message: l10n.authCoDriverPausedMessage, tone: BannerTone.violation),
        ],
        const SizedBox(height: Spacing.s20),
        if (state.canSwitch)
          Text(
            l10n.authCoDriverSwitchBody(state.coDriver.driverName),
            style: context.text.body15.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
        if (state.needsCoDriverLogin) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          AppButton.primary(
            label: l10n.authCoDriverSignIn,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.label, required this.slot, required this.highlighted});

  final String label;
  final SessionSlotState slot;

  /// Faol haydovchi `primary` rang bilan ajratiladi (M10).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.all(Spacing.s15),
      decoration: BoxDecoration(
        color: highlighted ? c.primary : c.surfaceAlt,
        borderRadius: Radii.cardRadius,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.account_circle_outlined,
            size: Spacing.s30,
            color: highlighted ? c.onPrimary : c.textSecondary,
          ),
          const SizedBox(width: Spacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: context.text.body16.copyWith(
                    color: highlighted ? c.onPrimary : c.textSecondary,
                  ),
                ),
                Text(
                  slot.driverName.isEmpty ? kEmptyValue : slot.driverName,
                  style: context.text.body11.copyWith(
                    color: highlighted ? c.onPrimary : c.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (slot.isPaused)
            StatusBadge(label: context.l10n.authSessionsStatusPaused, tone: StatusTone.warning),
        ],
      ),
    );
  }
}
