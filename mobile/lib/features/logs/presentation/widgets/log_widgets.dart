/// `Log Report` ning umumiy widgetlari (M-22 · M-23 · M-24 · M-25).
///
/// Figma parite: M-22 `1085:14341`, M-23 `1085:13169`.
/// Barcha konteynerlar `core/ui` komponentlaridan (`AppCard`, `KeyValueRow`,
/// `StatusBadge`) quriladi — bu yerda takroriy karta/qator yozilmaydi.
library;

import 'package:flutter/material.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../../../../core/hos/duty_slot.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/log_models.dart';

/// `Label — value` juftligi — Figma **ikki ustun** (#B-20).
class LogInfoRow extends StatelessWidget {
  const LogInfoRow({required this.label, required this.value, this.valueColor, super.key});

  final String label;
  final String value;

  /// `null` bo'lmasa — qiymat shu rangda (`Not Signed` → `error`).
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => KeyValueRow(
    label: label,
    value: value,
    valueWidget: valueColor == null
        ? null
        : Text(
            value,
            style: context.text.body13.copyWith(color: valueColor),
            textAlign: TextAlign.end,
          ),
  );
}

/// Bo'lim sarlavhasi — karta **tashqarisida**, ustida (#B-21).
class LogSectionTitle extends StatelessWidget {
  const LogSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.s10),
    child: Text(title, style: context.text.body8.copyWith(color: context.colors.textPrimary)),
  );
}

/// Status qisqartmasi (`ON`, `DR`, …) — to'ldirilgan to'rtburchak `r4`,
/// oq matn (#B-17).
class DutyStatusChip extends StatelessWidget {
  const DutyStatusChip({required this.status, super.key});

  final DutyStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s10, vertical: Spacing.base / 2),
      decoration: BoxDecoration(
        color: c.dutyColor(dutySlotOf(status)),
        borderRadius: Radii.badgeRadius,
      ),
      child: Text(
        status.wire,
        style: context.text.body16.withWeight(FontWeight.w500).copyWith(color: c.onPrimary),
      ),
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

/// M-23 jadval ustun kengliklari (Figma: `Status` · `Start Time` ·
/// `Location` · `Document`; **`Action` ustuni yo'q** — u faqat kengaytirilgan
/// ko'rinishda, M-25 sheet ichida).
abstract final class LogTableMetrics {
  const LogTableMetrics._();

  static const double status = 60;
  static const double startTime = 100;
  static const double location = 130;
  static const double document = 120;
  static const double gap = Spacing.s10;
  static const double rowPadding = Spacing.s10;

  static const double totalWidth =
      status + startTime + location + document + gap * 3 + rowPadding * 2;
}

/// M-23 jadvali: karta ichida, gorizontal scroll + ko'rinadigan indikator.
class LogTable extends StatefulWidget {
  const LogTable({required this.events, required this.onSelected, super.key});

  final List<LogEventView> events;
  final ValueChanged<LogEventView> onSelected;

  @override
  State<LogTable> createState() => _LogTableState();
}

class _LogTableState extends State<LogTable> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
      child: RawScrollbar(
        controller: _controller,
        thumbVisibility: true,
        thickness: Spacing.base,
        radius: const Radius.circular(Radii.sm),
        // Figma: amber thumb, jadval ostida.
        thumbColor: c.warning,
        trackColor: c.stroke,
        trackVisibility: true,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: Spacing.s10),
            child: SizedBox(
              width: LogTableMetrics.totalWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const LogTableHeader(),
                  for (final LogEventView event in widget.events) ...<Widget>[
                    Divider(height: Strokes.thin, thickness: Strokes.thin, color: c.stroke),
                    LogTableRow(event: event, onTap: () => widget.onSelected(event)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// M-23 jadval sarlavhasi (`Action` ustunisiz).
class LogTableHeader extends StatelessWidget {
  const LogTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final TextStyle style = context.text.body17
        .withWeight(FontWeight.w500)
        .copyWith(color: c.textSecondary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LogTableMetrics.rowPadding,
        0,
        LogTableMetrics.rowPadding,
        Spacing.s10,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: LogTableMetrics.status,
            child: Text(l10n.logsColumnStatus, style: style),
          ),
          const SizedBox(width: LogTableMetrics.gap),
          SizedBox(
            width: LogTableMetrics.startTime,
            child: Text(l10n.logsColumnStartTime, style: style),
          ),
          const SizedBox(width: LogTableMetrics.gap),
          SizedBox(
            width: LogTableMetrics.location,
            child: Text(l10n.logsColumnLocation, style: style),
          ),
          const SizedBox(width: LogTableMetrics.gap),
          SizedBox(
            width: LogTableMetrics.document,
            child: Text(l10n.logsColumnDocument, style: style),
          ),
        ],
      ),
    );
  }
}

/// M-23 jadval satri. Bosilganda `M-25` bottom-sheet ochiladi.
class LogTableRow extends StatelessWidget {
  const LogTableRow({required this.event, required this.onTap, super.key});

  final LogEventView event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final TextStyle style = context.text.body16
        .withWeight(FontWeight.w500)
        .copyWith(color: c.textPrimary);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LogTableMetrics.rowPadding,
          vertical: LogTableMetrics.rowPadding,
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: LogTableMetrics.status,
              child: Row(
                children: <Widget>[
                  if (event.status != null)
                    DutyStatusChip(status: event.status!)
                  else
                    Text(kEmptyValue, style: style),
                  // M137: tahrirlangan event `✎` bilan belgilanadi.
                  if (event.edited)
                    Flexible(
                      child: Icon(Icons.edit_note, size: Spacing.s15, color: c.textSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: LogTableMetrics.gap),
            SizedBox(
              width: LogTableMetrics.startTime,
              child: Text(AppFormats.eventTimeOf(event.start), style: style, maxLines: 1),
            ),
            const SizedBox(width: LogTableMetrics.gap),
            SizedBox(
              width: LogTableMetrics.location,
              child: Text(
                AppFormats.orNa(event.location),
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: LogTableMetrics.gap),
            SizedBox(
              width: LogTableMetrics.document,
              child: Text(
                AppFormats.orNa(event.document),
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
