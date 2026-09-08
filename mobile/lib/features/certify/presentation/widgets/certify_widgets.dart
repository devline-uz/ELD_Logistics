/// Certify moduli widgetlari (M-29 · M-30 · M-31).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/certify_models.dart';

/// Holat badge'i (§12.1 jadvali).
StatusBadge certifyBadge(BuildContext context, CertifyStatus status) {
  final AppLocalizations l10n = context.l10n;
  return switch (status) {
    CertifyStatus.certified => StatusBadge(
      label: l10n.certifyBadgeCertified,
      tone: StatusTone.success,
      dense: true,
    ),
    CertifyStatus.uncertified => StatusBadge(
      label: l10n.certifyBadgeUncertified,
      tone: StatusTone.neutral,
      dense: true,
    ),
    CertifyStatus.needsRecertify => StatusBadge(
      label: l10n.certifyBadgeNeedsRecertify,
      tone: StatusTone.warning,
      dense: true,
    ),
    CertifyStatus.pendingSync => StatusBadge(
      label: l10n.certifyBadgePendingSync,
      tone: StatusTone.neutral,
      icon: Icons.schedule,
      dense: true,
    ),
    CertifyStatus.notReady => StatusBadge(
      label: l10n.certifyBadgeNotReady,
      tone: StatusTone.neutral,
      dense: true,
    ),
  };
}

/// `M-29` ro'yxatining satri: checkbox + sana + badge.
class CertifyDayTile extends StatelessWidget {
  const CertifyDayTile({
    required this.day,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final CertifyDay day;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = day.selectable;

    return Semantics(
      selected: selected,
      enabled: enabled,
      child: Material(
        color: c.surface,
        borderRadius: Radii.cardRadius,
        child: InkWell(
          onTap: enabled ? onToggle : null,
          borderRadius: Radii.cardRadius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: Radii.cardRadius,
              border: Border.all(
                color: selected ? c.primary : c.stroke,
                width: selected ? Strokes.emphasis : Strokes.thin,
              ),
            ),
            padding: const EdgeInsets.all(Spacing.s15),
            child: Row(
              children: <Widget>[
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: enabled ? (selected ? c.primary : c.strokeStrong) : c.textDisabled,
                ),
                const SizedBox(width: Spacing.s10),
                Expanded(
                  child: Text(
                    AppFormats.listHeaderOf(day.date),
                    style: context.text.body12.copyWith(
                      color: enabled ? c.textPrimary : c.textDisabled,
                    ),
                  ),
                ),
                certifyBadge(context, day.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `M-30` dagi huquqiy matn bloki.
class CertifyLegalText extends StatelessWidget {
  const CertifyLegalText({super.key});

  @override
  Widget build(BuildContext context) => Text(
    context.l10n.certifyLegalText,
    style: context.text.body16.copyWith(color: context.colors.textSecondary),
  );
}
