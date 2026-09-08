/// Inspection moduli uchun umumiy vizual bloklar.
///
/// **Dark tema Figma da chizilmagan** — barcha rang `core/ui` tokenlaridan
/// olinadi, dark variant avtomatik hosil bo'ladi.
library;

import 'package:flutter/material.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/hos/duty_slot.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/inspection_grid.dart';
import '../../domain/inspection_models.dart';

/// `AsyncValue.error` obyektini foydalanuvchi matniga o'giradi.
String localizedInspectionError(AppLocalizations l10n, Object error) =>
    error is ApiError ? localizedApiError(l10n, error) : l10n.errUnknown;

/// Grid qator nomlari (lokalizatsiya qilingan).
Map<DutySlot, String> dutyRowLabels(AppLocalizations l10n) => <DutySlot, String>{
  DutySlot.offDuty: l10n.inspectionDutyOff,
  DutySlot.sleeper: l10n.inspectionDutySb,
  DutySlot.driving: l10n.inspectionDutyDr,
  DutySlot.onDuty: l10n.inspectionDutyOn,
};

/// Metr → mil (US), bo'sh bo'lsa `N/A` (#B-10).
String inspectionMiles(BuildContext context, int? meters) => meters == null
    ? kEmptyValue
    : context.l10n.inspectionDistanceMiles(AppFormats.count((meters / 1609.344).round()));

/// Karta konteyneri (Figma: `#F5F5F5` fon, 1 px chegara).
class InspectionCard extends StatelessWidget {
  const InspectionCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: padding ?? const EdgeInsets.all(Spacing.s20),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: child,
    );
  }
}

/// `M-37` uch amaldan biri: sarlavha + tavsif + tugma.
class InspectionActionCard extends StatelessWidget {
  const InspectionActionCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.busy = false,
    this.hint,
    super.key,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool busy;

  /// Amal mavjud bo'lmasa (oflayn) ko'rsatiladigan izoh.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return InspectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: context.text.body11.copyWith(color: c.textPrimary)),
          const SizedBox(height: Spacing.s5),
          Text(body, style: context.text.body14.copyWith(color: c.textSecondary)),
          if (hint != null) ...<Widget>[
            const SizedBox(height: Spacing.s5),
            Text(hint!, style: context.text.body16.copyWith(color: c.warningDark)),
          ],
          const SizedBox(height: Spacing.s15),
          AppButton.primary(label: actionLabel, onPressed: onAction, busy: busy),
        ],
      ),
    );
  }
}

/// `Log Form` shapkasi: Driver, Carrier, Home Terminal, Unit, Trailers, Docs,
/// Distance, Time Zone (M-38).
class InspectionLogFormHeader extends StatelessWidget {
  const InspectionLogFormHeader({required this.report, required this.day, super.key});

  final InspectionReport report;
  final InspectionDay day;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final InspectionLogForm form = day.form;

    return InspectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.inspectionDailyLogTitle,
            style: context.text.body11.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: Spacing.s10),
          _Row(
            label: l10n.inspectionLogDriver,
            value: AppFormats.orNa(form.driverName ?? report.driverName),
          ),
          _Row(
            label: l10n.inspectionLogCarrier,
            value: AppFormats.orNa(form.carrierName ?? report.carrierName),
          ),
          _Row(
            label: l10n.inspectionLogHomeTerminal,
            value: AppFormats.orNa(form.homeTerminalAddress ?? report.homeTerminalAddress),
          ),
          _Row(label: l10n.inspectionLogUnit, value: _joined(form.unitNumbers)),
          _Row(label: l10n.inspectionLogTrailers, value: _joined(form.trailerNumbers)),
          _Row(label: l10n.inspectionLogDocuments, value: _joined(form.shippingDocs)),
          _Row(
            label: l10n.inspectionLogDistance,
            value: inspectionMiles(context, form.distanceMeters ?? day.distanceMeters),
          ),
          _Row(
            label: l10n.inspectionLogTimezone,
            value: AppFormats.orNa(day.timezone.isEmpty ? report.timezone : day.timezone),
          ),
        ],
      ),
    );
  }

  static String _joined(List<String> values) => values.isEmpty ? kEmptyValue : values.join(', ');
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(label, style: context.text.body14.copyWith(color: c.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: context.text.body14.copyWith(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// Kun gridi: 24 soatlik `DutyGrid24h` gorizontal scroll ichida.
class InspectionDayGrid extends StatelessWidget {
  const InspectionDayGrid({required this.day, required this.dayStart, super.key});

  final InspectionDay day;

  /// Kunning UTC boshlanishi (Home Terminal TZ bo'yicha).
  final DateTime dayStart;

  @override
  Widget build(BuildContext context) {
    final List<InspectionSpan> spans = inspectionSpans(day: day, dayStart: dayStart);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: DutyGridMetrics.totalWidth,
        child: DutyGrid24h(
          rowLabels: dutyRowLabels(context.l10n),
          segments: <DutySegment>[
            for (final InspectionSpan span in spans)
              DutySegment(slot: dutySlotOf(span.status), start: span.start, end: span.end),
          ],
        ),
      ),
    );
  }
}

/// Eventlar jadvali: `Status · Time · Location · Odometer` (M-38).
class InspectionEventsTable extends StatelessWidget {
  const InspectionEventsTable({required this.events, super.key});

  final List<InspectionEvent> events;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          color: c.surfaceAlt,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s10, vertical: Spacing.s10),
          child: Row(
            children: <Widget>[
              _cell(context, l10n.inspectionColStatus, flex: 2, header: true),
              _cell(context, l10n.inspectionColTime, flex: 3, header: true),
              _cell(context, l10n.inspectionColLocation, flex: 4, header: true),
              _cell(context, l10n.inspectionColOdometer, flex: 3, header: true),
            ],
          ),
        ),
        for (final InspectionEvent event in events)
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: c.stroke, width: Strokes.thin),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.s10, vertical: Spacing.s10),
            child: Row(
              children: <Widget>[
                _cell(context, _statusLabel(l10n, event.status), flex: 2),
                _cell(context, AppFormats.eventTimeOf(event.at), flex: 3),
                _cell(context, AppFormats.orNa(event.locationText), flex: 4),
                _cell(context, inspectionMiles(context, event.odometerMeters), flex: 3),
              ],
            ),
          ),
      ],
    );
  }

  static String _statusLabel(AppLocalizations l10n, DutyStatus status) => switch (status) {
    DutyStatus.off => l10n.inspectionDutyOff,
    DutyStatus.sb => l10n.inspectionDutySb,
    DutyStatus.dr => l10n.inspectionDutyDr,
    DutyStatus.on => l10n.inspectionDutyOn,
  };

  static Widget _cell(
    BuildContext context,
    String text, {
    required int flex,
    bool header = false,
  }) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: header
          ? context.text.body16.copyWith(color: context.colors.textSecondary)
          : context.text.body16.copyWith(color: context.colors.textPrimary),
    ),
  );
}
