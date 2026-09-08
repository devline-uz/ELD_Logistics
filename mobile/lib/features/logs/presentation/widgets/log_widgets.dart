/// `Log Report` ning umumiy widgetlari (M-22 · M-23 · M-24 · M-25).
library;

import 'package:flutter/material.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../../../../core/hos/duty_slot.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/log_models.dart';

/// `Label — value` juftligi (Figma `Categories` bloki).
class LogInfoRow extends StatelessWidget {
  const LogInfoRow({required this.label, required this.value, this.valueColor, super.key});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: context.text.body14.copyWith(color: c.textSecondary)),
          const SizedBox(height: Spacing.s5),
          Text(value, style: context.text.body12.copyWith(color: valueColor ?? c.textPrimary)),
        ],
      ),
    );
  }
}

/// Sarlavhali karta (`Driver Information`, kun ma'lumoti).
class LogCard extends StatelessWidget {
  const LogCard({required this.children, this.title, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title!, style: context.text.body8.copyWith(color: c.textPrimary)),
            const SizedBox(height: Spacing.s10),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Status qisqartmasi (`ON`, `DR`, …) — rangli pill.
class DutyStatusChip extends StatelessWidget {
  const DutyStatusChip({required this.status, super.key});

  final DutyStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s5, vertical: 2),
      decoration: BoxDecoration(
        color: c.dutyColor(dutySlotOf(status)),
        borderRadius: Radii.pillRadius,
      ),
      child: Text(status.wire, style: context.text.body16.copyWith(color: c.onPrimary)),
    );
  }
}

/// `Origin` badge (M-25) — lokalizatsiya qilingan nom.
String originLabel(AppLocalizations l10n, LogEventOrigin origin) => switch (origin) {
  LogEventOrigin.auto => l10n.logsOriginAuto,
  LogEventOrigin.driver => l10n.logsOriginDriver,
  LogEventOrigin.adminEdit => l10n.logsOriginAdminEdit,
  LogEventOrigin.assigned => l10n.logsOriginAssigned,
  LogEventOrigin.manualNoEld => l10n.logsOriginManualNoEld,
};

/// M-23 jadval sarlavhasi.
class LogTableHeader extends StatelessWidget {
  const LogTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final TextStyle style = context.text.body17.copyWith(color: c.textSecondary);

    return Container(
      color: c.surfaceAlt,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s10, vertical: Spacing.s5),
      child: Row(
        children: <Widget>[
          Expanded(flex: 3, child: Text(l10n.logsColumnStatus, style: style)),
          Expanded(flex: 4, child: Text(l10n.logsColumnStartTime, style: style)),
          Expanded(flex: 5, child: Text(l10n.logsColumnLocation, style: style)),
          Expanded(flex: 4, child: Text(l10n.logsColumnDocument, style: style)),
          SizedBox(
            width: Spacing.s30,
            child: Text(l10n.logsColumnAction, style: style),
          ),
        ],
      ),
    );
  }
}

/// M-23 jadval satri. Bosilganda `M-25` bottom-sheet ochiladi.
class LogTableRow extends StatelessWidget {
  const LogTableRow({required this.event, required this.onTap, this.onEdit, super.key});

  final LogEventView event;
  final VoidCallback onTap;

  /// `null` — tahrirlash mumkin emas (`🔒`).
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final TextStyle style = context.text.body16.copyWith(color: c.textPrimary);
    final bool editable = event.isEditable && onEdit != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.s10, vertical: Spacing.s10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  if (event.status != null) DutyStatusChip(status: event.status!),
                  if (event.status == null) Text(kEmptyValue, style: style),
                  // M137: tahrirlangan event `✎` bilan belgilanadi.
                  if (event.edited)
                    Flexible(
                      child: Icon(Icons.edit_note, size: Spacing.s15, color: c.textSecondary),
                    ),
                ],
              ),
            ),
            Expanded(flex: 4, child: Text(AppFormats.eventTimeOf(event.start), style: style)),
            Expanded(
              flex: 5,
              child: Text(
                AppFormats.orNa(event.location),
                style: style,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                AppFormats.orNa(event.document),
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: Spacing.s30,
              child: Semantics(
                button: editable,
                label: editable ? l10n.logsEditRow : l10n.logsLockedRow,
                child: InkWell(
                  onTap: editable ? onEdit : null,
                  child: Icon(
                    editable ? Icons.edit_outlined : Icons.lock_outline,
                    size: Spacing.s20,
                    color: editable ? c.primary : c.textDisabled,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `DVIR` tabi satri (M-24).
class DvirListTile extends StatelessWidget {
  const DvirListTile({required this.item, this.onTap, super.key});

  final DvirListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return ListTile(
      onTap: onTap,
      title: Text(
        AppFormats.orNa(item.trailerNumber),
        style: context.text.body11.copyWith(color: c.textPrimary),
      ),
      subtitle: Text(
        '${l10n.logsDvirColumnType}: ${item.type}',
        style: context.text.body16.copyWith(color: c.textSecondary),
      ),
      trailing: Text(
        AppFormats.fullDateTime(item.createdAt),
        style: context.text.body16.copyWith(color: c.textSecondary),
      ),
    );
  }
}
