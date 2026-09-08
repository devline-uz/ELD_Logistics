/// `M-22 Main` · `M-23 Logs` · `M-24 DVIR` — Figma `1085:14341`, `1085:13169`,
/// `1087:14921` (tz-mobile 1258–1294).
///
/// Bitta `LogReportController` (M7) + ikkita `View`: telefonda vertikal,
/// planshetda `Main`/`Logs` yonma-yon (T-14/T-15).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/day_timeline.dart';
import '../../domain/log_models.dart';
import '../controllers/log_report_controller.dart';
import '../controllers/logs_providers.dart';
import '../widgets/log_duty_grid.dart';
import '../widgets/log_event_detail_sheet.dart';
import '../widgets/log_widgets.dart';

class LogReportScreen extends ConsumerStatefulWidget {
  const LogReportScreen({this.initialTab, super.key});

  /// `/logs?tab=main|logs|dvir`.
  final String? initialTab;

  @override
  ConsumerState<LogReportScreen> createState() => _LogReportScreenState();
}

class _LogReportScreenState extends ConsumerState<LogReportScreen> {
  @override
  void initState() {
    super.initState();
    final String? tab = widget.initialTab;
    if (tab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(logReportControllerProvider.notifier).applyRouteTab(tab);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final LogReportState state = ref.watch(logReportControllerProvider);
    final LogReportController controller = ref.read(logReportControllerProvider.notifier);
    final AsyncValue<List<LogDayRef>> strip = ref.watch(logStripProvider);

    return AdaptiveScaffold(
      maxContentWidth: ContentWidth.wide,
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(title: l10n.logsTitle),
      applyHorizontalPadding: false,
      phone: (BuildContext c) =>
          _Body(state: state, controller: controller, strip: strip, twoColumn: false),
      tablet: (BuildContext c) =>
          _Body(state: state, controller: controller, strip: strip, twoColumn: true),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.state,
    required this.controller,
    required this.strip,
    required this.twoColumn,
  });

  final LogReportState state;
  final LogReportController controller;
  final AsyncValue<List<LogDayRef>> strip;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double padding = screenPaddingH(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: _TabBar(active: state.tab, onSelected: controller.selectTab),
        ),
        const SizedBox(height: Spacing.s10),
        _DateStrip(strip: strip, selected: state.selectedDate, onSelected: controller.selectDate),
        const SizedBox(height: Spacing.s10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: switch (state.tab) {
              LogTab.main => _MainTab(twoColumn: twoColumn),
              LogTab.logs => _LogsTab(twoColumn: twoColumn),
              LogTab.dvir => _DvirTab(twoColumn: twoColumn),
            },
          ),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.active, required this.onSelected});

  final LogTab active;
  final ValueChanged<LogTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Map<LogTab, String> labels = <LogTab, String>{
      LogTab.main: l10n.logsTabMain,
      LogTab.logs: l10n.logsTabLogs,
      LogTab.dvir: l10n.logsTabDvir,
    };

    return Row(
      children: <Widget>[
        for (final LogTab tab in LogTab.values)
          Padding(
            padding: const EdgeInsets.only(right: Spacing.s10),
            child: AppChip(
              label: labels[tab]!,
              selected: tab == active,
              onTap: () => onSelected(tab),
            ),
          ),
      ],
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.strip, required this.selected, required this.onSelected});

  final AsyncValue<List<LogDayRef>> strip;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) => asyncView<List<LogDayRef>>(
    strip,
    loading: const SizedBox(height: 64, child: LoadingSkeleton(itemCount: 1)),
    error: (Object _) => const SizedBox(height: 64),
    data: (List<LogDayRef> days) => DateStrip8Day(
      days: <DateStripDay>[
        for (final LogDayRef day in days)
          DateStripDay(date: day.date, certified: day.certified, hasViolation: day.hasViolation),
      ],
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

/// `M-22 Main` · planshetda `T-14` (tz-mobile 1548) — ikki ustun.
class _MainTab extends ConsumerWidget {
  const _MainTab({required this.twoColumn});

  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return _DayAsync(
      builder: (LogDayView day) {
        final Widget summary = LogCard(
          children: <Widget>[
            LogInfoRow(
              label: l10n.logsShippingDocuments,
              value: day.shippingDocuments.isEmpty ? kEmptyValue : day.shippingDocuments.join(', '),
            ),
            LogInfoRow(
              label: l10n.logsTrailerNumbers,
              value: day.trailerNumbers.isEmpty ? kEmptyValue : day.trailerNumbers.join(', '),
            ),
            LogInfoRow(
              label: l10n.logsCertify,
              value: day.certification == DayCertification.uncertified
                  ? l10n.logsNotSigned
                  : l10n.logsSigned,
              valueColor: day.certification == DayCertification.uncertified ? c.error : c.success,
            ),
            LogInfoRow(label: l10n.logsNotes, value: AppFormats.orNa(day.notes)),
          ],
        );
        final Widget driver = LogCard(
          title: l10n.logsDriverInformation,
          children: <Widget>[
            LogInfoRow(label: l10n.logsDriverName, value: AppFormats.orNa(day.driver.driverName)),
            LogInfoRow(label: l10n.logsUnitNumber, value: AppFormats.orNa(day.driver.unitNumber)),
            LogInfoRow(
              label: l10n.logsHomeTerminal,
              value: AppFormats.orNa(day.driver.homeTerminal),
            ),
          ],
        );

        return ListView(
          padding: const EdgeInsets.only(bottom: Spacing.s20),
          children: <Widget>[
            if (twoColumn)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: summary),
                  const SizedBox(width: Spacing.s20),
                  Expanded(child: driver),
                ],
              )
            else ...<Widget>[summary, const SizedBox(height: Spacing.cardGap), driver],
          ],
        );
      },
    );
  }
}

/// `M-23 Logs` — grid + jadval.
class _LogsTab extends ConsumerWidget {
  const _LogsTab({required this.twoColumn});

  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return _DayAsync(
      builder: (LogDayView day) {
        // Oraliqlar repozitoriyda hisoblanadi (#B-32): kun chegarasi Home
        // Terminal TZ da, `until` esa `TimeSource` dan. Ekran qayta hisoblasa
        // grid va jamilar farq qilardi.
        final List<DaySpan> spans = day.spans;
        final Widget grid = LogDutyGrid(
          spans: spans,
          totals: day.totals,
          alerts: day.alerts,
          specialSpans: <DaySpan>[
            for (int i = 0; i < spans.length; i++)
              if (day.events.length > i && day.events[i].special != SpecialMode.none) spans[i],
          ],
        );

        final Widget table = day.events.isEmpty
            ? EmptyState(title: l10n.logsEmptyTitle, message: l10n.logsEmptyMessage)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const LogTableHeader(),
                  for (final LogEventView event in day.events)
                    LogTableRow(
                      event: event,
                      onTap: () => showLogEventDetail(context, event),
                      onEdit: event.isEditable ? () => showLogEventDetail(context, event) : null,
                    ),
                ],
              );

        if (twoColumn) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: SingleChildScrollView(child: grid)),
              const SizedBox(width: Spacing.s20),
              Expanded(child: SingleChildScrollView(child: table)),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: Spacing.s20),
          children: <Widget>[
            grid,
            const SizedBox(height: Spacing.s15),
            table,
          ],
        );
      },
    );
  }
}

/// `M-24 DVIR` · planshetda `T-16` (tz-mobile 1550) — ikki ustunli ro'yxat.
class _DvirTab extends ConsumerWidget {
  const _DvirTab({required this.twoColumn});

  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<DvirListItem>> items = ref.watch(logDvirProvider);

    return asyncView<List<DvirListItem>>(
      items,
      loading: const LoadingSkeleton(itemCount: 4),
      error: (Object _) => ErrorState(
        message: l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(logsRepositoryProvider),
      ),
      data: (List<DvirListItem> list) => list.isEmpty
          ? EmptyState(title: l10n.logsDvirEmptyTitle, message: l10n.logsDvirEmptyMessage)
          : twoColumn
          ? GridView.builder(
              padding: const EdgeInsets.only(bottom: Spacing.s20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: Spacing.s20,
                mainAxisSpacing: Spacing.s10,
                mainAxisExtent: 88,
              ),
              itemCount: list.length,
              itemBuilder: (BuildContext _, int index) => DvirListTile(item: list[index]),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: Spacing.s20),
              itemCount: list.length,
              separatorBuilder: (BuildContext _, int _) => const Divider(height: 1),
              itemBuilder: (BuildContext _, int index) => DvirListTile(item: list[index]),
            ),
    );
  }
}

/// Kun oqimining yuklanish/xato/bo'sh holatlari — uch tab uchun yagona joy.
class _DayAsync extends ConsumerWidget {
  const _DayAsync({required this.builder});

  final Widget Function(LogDayView day) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<LogDayView> day = ref.watch(selectedLogDayProvider);

    return asyncView<LogDayView>(
      day,
      loading: const LoadingSkeleton(itemCount: 3),
      error: (Object _) => ErrorState(
        message: l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(logsRepositoryProvider),
      ),
      data: (LogDayView value) => value.available
          ? builder(value)
          : ErrorState(
              message: l10n.logsOlderUnavailable,
              retryLabel: l10n.commonRetry,
              icon: Icons.cloud_off,
              onRetry: () => ref.invalidate(logsRepositoryProvider),
            ),
    );
  }
}
