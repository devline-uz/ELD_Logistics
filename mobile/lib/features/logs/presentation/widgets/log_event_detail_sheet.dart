/// `M-25 Log event detail` — telefonda bottom-sheet, planshetda `TabletModal`
/// (`T-09`). Origin badge va `Edited` belgisi M137 bo'yicha.
library;

import 'package:flutter/material.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/log_models.dart';
import 'log_widgets.dart';

/// Profilga mos modalda event tafsilotini ko'rsatadi.
Future<void> showLogEventDetail(BuildContext context, LogEventView event) =>
    showAdaptiveModal<void>(
      context: context,
      builder: (BuildContext ctx) => LogEventDetailView(event: event),
    );

class LogEventDetailView extends StatelessWidget {
  const LogEventDetailView({required this.event, super.key});

  final LogEventView event;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Widget body = _Body(event: event);

    if (DeviceProfile.of(context).isTablet) {
      return TabletModal(
        title: l10n.logsDetailTitle,
        cancelLabel: l10n.logsClose,
        onCancel: () => Navigator.of(context).pop(),
        child: body,
      );
    }
    return AppBottomSheet(title: l10n.logsDetailTitle, child: body);
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.event});

  final LogEventView event;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.logsColumnStatus,
                style: context.text.body14.copyWith(color: c.textSecondary),
              ),
            ),
            if (event.status != null) DutyStatusChip(status: event.status!),
          ],
        ),
        const SizedBox(height: Spacing.s10),
        LogInfoRow(label: l10n.logsDetailStart, value: AppFormats.fullDateTime(event.start)),
        LogInfoRow(
          label: l10n.logsDetailDuration,
          value: event.duration == null ? kEmptyValue : AppFormats.durationHms(event.duration),
        ),
        LogInfoRow(label: l10n.logsColumnLocation, value: AppFormats.orNa(event.location)),
        LogInfoRow(
          label: l10n.logsDetailOdometer,
          value: event.odometerM == null ? kEmptyValue : AppFormats.count(event.odometerM),
        ),
        LogInfoRow(
          label: l10n.logsDetailEngineHours,
          value: event.engineHours == null ? kEmptyValue : event.engineHours!.toStringAsFixed(2),
        ),
        LogInfoRow(label: l10n.logsColumnNotes, value: AppFormats.orNa(event.notes)),
        const SizedBox(height: Spacing.s10),
        Wrap(
          spacing: Spacing.s10,
          runSpacing: Spacing.s5,
          children: <Widget>[
            StatusBadge(
              label: originLabel(l10n, event.origin),
              tone: StatusTone.neutral,
              dense: true,
            ),
            if (event.edited) ...<Widget>[
              StatusBadge(
                label: l10n.logsDetailEdited,
                tone: StatusTone.warning,
                icon: Icons.edit_outlined,
                dense: true,
              ),
            ],
            // M99: `Action` ustuni Figma jadvalida yo'q — qulf/tahrirlash
            // belgisi kengaytirilgan ko'rinishda (M-25) ko'rsatiladi.
            if (!event.isEditable) ...<Widget>[
              StatusBadge(
                label: l10n.logsLockedRow,
                tone: StatusTone.neutral,
                icon: Icons.lock_outline,
                dense: true,
              ),
            ],
            if (event.pendingSync) ...<Widget>[
              StatusBadge(
                label: l10n.editsPendingSync,
                tone: StatusTone.neutral,
                icon: Icons.schedule,
                dense: true,
              ),
            ],
          ],
        ),
        if (event.edited && event.originalSummary != null) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          Text(
            l10n.logsDetailOriginalValue(event.originalSummary!),
            style: context.text.body16.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}
