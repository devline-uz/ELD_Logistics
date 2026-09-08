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
      tone: StatusTone.error,
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
///
/// Figma `1102:397`: satrlar **bitta** kulrang karta ichida, alohida chegara yo'q
/// (satr 305x35, oraliq 20).
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
      child: InkWell(
        onTap: enabled ? onToggle : null,
        borderRadius: Radii.badgeRadius,
        child: Row(
          children: <Widget>[
            AppCheckbox(value: selected, onChanged: enabled ? (bool _) => onToggle() : null),
            const SizedBox(width: Spacing.s10),
            Expanded(
              child: Text(
                AppFormats.listHeaderOf(day.date),
                style: context.text.body15.copyWith(
                  color: enabled ? c.textPrimary : c.textSecondary,
                ),
              ),
            ),
            certifyBadge(context, day.status),
          ],
        ),
      ),
    );
  }
}

/// `Certify Today` qatori — ro'yxat ustidagi alohida karta (Figma 345x48).
class CertifyTodayRow extends StatelessWidget {
  const CertifyTodayRow({required this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppCard(
      grouped: true,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s20, vertical: Spacing.s15),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              context.l10n.certifyToday,
              style: context.text.body14.copyWith(color: c.textPrimary),
            ),
          ),
          Icon(Icons.chevron_right, size: Spacing.s20, color: c.textPrimary),
        ],
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
