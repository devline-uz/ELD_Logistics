/// `M-12` formasining qayta ishlatiladigan qismlari (`T-04` bilan umumiy).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/duty_status_models.dart';

/// Status tugmalari — **uchta** (M52). `Sleeper Berth` unit'da bo'lmasa
/// yashirilmaydi, o'chiriladi.
///
/// Figma `1083:10550` tartibi: `On Duty · Sleep · Off Duty`; yorliq `Sleep`
/// (bir qatorga sig'adi), ikonkalar rangli (amber oy, qizil power).
class DutyStatusSelector extends StatelessWidget {
  const DutyStatusSelector({
    required this.selected,
    required this.onSelected,
    required this.sleeperAvailable,
    this.order = kDutyStatusFigmaOrder,
    super.key,
  });

  final DutyStatusValue selected;
  final ValueChanged<DutyStatusValue> onSelected;
  final bool sleeperAvailable;

  /// Ko'rsatish tartibi (dizayn bo'yicha; domen tartibi o'zgarmaydi).
  final List<DutyStatusValue> order;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Row(
      children: <Widget>[
        for (final DutyStatusValue value in order) ...<Widget>[
          Expanded(
            child: _StatusTile(
              label: switch (value) {
                DutyStatusValue.off => l10n.dutyStatusOffDuty,
                DutyStatusValue.sleeper => l10n.dutyStatusSleep,
                DutyStatusValue.on => l10n.dutyStatusOnDuty,
                DutyStatusValue.driving => l10n.dutyStatusDriving,
              },
              icon: switch (value) {
                DutyStatusValue.off => Icons.power_settings_new,
                DutyStatusValue.sleeper => Icons.nightlight_round,
                DutyStatusValue.on => Icons.local_shipping,
                DutyStatusValue.driving => Icons.drive_eta,
              },
              accent: switch (value) {
                DutyStatusValue.off => context.colors.primary,
                DutyStatusValue.sleeper => context.colors.warning,
                DutyStatusValue.on => context.colors.decoTeal,
                DutyStatusValue.driving => context.colors.success,
              },
              selected: value == selected,
              enabled: value != DutyStatusValue.sleeper || sleeperAvailable,
              disabledTooltip: l10n.dutySleeperUnavailable,
              onTap: () => onSelected(value),
            ),
          ),
          if (value != order.last) const SizedBox(width: Spacing.s10),
        ],
      ],
    );
  }
}

/// Figma dagi ko'rsatish tartibi (`On Duty · Sleep · Off Duty`).
const List<DutyStatusValue> kDutyStatusFigmaOrder = <DutyStatusValue>[
  DutyStatusValue.on,
  DutyStatusValue.sleeper,
  DutyStatusValue.off,
];

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.enabled,
    required this.disabledTooltip,
    required this.onTap,
  });

  final String label;
  final IconData icon;

  /// Tanlanmagan holatdagi ikonka rangi (Figma: rangli ikonkalar).
  final Color accent;

  final bool selected;
  final bool enabled;
  final String disabledTooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color fg = !enabled
        ? c.textDisabled
        : selected
        ? c.onPrimary
        : c.textSecondary;
    final Color iconColor = !enabled
        ? c.textDisabled
        : selected
        ? c.onPrimary
        : accent;

    final Widget tile = Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: Radii.buttonRadius,
        child: Container(
          constraints: BoxConstraints(minHeight: touchTarget(context) + Spacing.s25),
          decoration: BoxDecoration(
            color: selected ? c.decoTeal : c.surface,
            borderRadius: Radii.buttonRadius,
            border: Border.all(color: selected ? c.decoTeal : c.stroke, width: Strokes.thin),
          ),
          padding: const EdgeInsets.symmetric(vertical: Spacing.s10, horizontal: Spacing.s5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: iconColor, size: Spacing.s25),
              const SizedBox(height: Spacing.s5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.body14.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
    return enabled ? tile : Tooltip(message: disabledTooltip, child: tile);
  }
}

/// Chip'lar maydoni (`Trailer Number`, `Shipping Document`) — `×` bilan.
class DutyChipField extends StatelessWidget {
  const DutyChipField({
    required this.label,
    required this.values,
    required this.onRemove,
    this.onAdd,
    this.addLabel,
    super.key,
  });

  final String label;

  /// Ko'rsatiladigan qiymatlar (`id → matn` mapping chaqiruvchida bo'ladi).
  final List<String> values;
  final ValueChanged<String> onRemove;
  final VoidCallback? onAdd;
  final String? addLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: context.text.body14.copyWith(color: c.textPrimary)),
        const SizedBox(height: Spacing.s5),
        Container(
          width: double.infinity,
          // Figma: konteyner balandligi ~52 (chip 32 + padding 10).
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.all(Spacing.s10),
          decoration: BoxDecoration(
            color: c.surfaceMuted,
            borderRadius: Radii.inputRadius,
            border: Border.all(color: c.stroke, width: Strokes.thin),
          ),
          child: Wrap(
            spacing: Spacing.s5,
            runSpacing: Spacing.s5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (values.isEmpty) const AppChip.removable(label: kEmptyValue, onRemove: null),
              for (final String value in values)
                AppChip.removable(label: value, onRemove: () => onRemove(value)),
              if (onAdd != null && addLabel != null)
                AppChip(label: addLabel!, icon: Icons.add, onTap: onAdd),
            ],
          ),
        ),
      ],
    );
  }
}
