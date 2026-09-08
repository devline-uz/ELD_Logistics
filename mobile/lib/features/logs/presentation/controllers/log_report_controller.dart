/// `M-22/M-23/M-24 Log Report` kontrolleri (M7: telefon va planshet bitta
/// `Controller` ni ulashadi).
///
/// Kontroller faqat **tanlov holatini** saqlaydi; ma'lumot oqimlari
/// `logs_providers.dart` dagi `StreamProvider` lardan keladi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_context.dart';
import '../../../../core/time/day_boundary.dart';
import '../../../../core/time/time_providers.dart';
import '../../domain/log_models.dart';
import 'logs_providers.dart';

class LogReportState {
  const LogReportState({required this.tab, required this.selectedDate});

  final LogTab tab;

  /// Home Terminal TZ dagi kun (00:00).
  final DateTime selectedDate;

  LogReportState copyWith({LogTab? tab, DateTime? selectedDate}) =>
      LogReportState(tab: tab ?? this.tab, selectedDate: selectedDate ?? this.selectedDate);
}

class LogReportController extends Notifier<LogReportState> {
  @override
  LogReportState build() {
    // #B-32: bugungi kun Home Terminal TZ da aniqlanadi, qurilma zonasida emas.
    return LogReportState(
      tab: LogTab.main,
      selectedDate: todayCalendarDate(
        now: ref.read(timeSourceProvider).now(),
        timeZoneName: ref.watch(homeTerminalTzProvider),
      ),
    );
  }

  void selectTab(LogTab tab) {
    if (state.tab != tab) {
      state = state.copyWith(tab: tab);
    }
  }

  void selectDate(DateTime date) {
    // [date] tasmadan keladi — allaqachon Home Terminal kalendar sanasi.
    final DateTime day = normalizeCalendarDate(date);
    if (state.selectedDate != day) {
      state = state.copyWith(selectedDate: day);
    }
  }

  /// Ekran ochilishida marshrutdan kelgan tab (`/logs?tab=logs`).
  void applyRouteTab(String? wire) => selectTab(LogTab.fromWire(wire));

  /// Sana tasmasidan tanlangan kunning tafsiloti mavjudligini bildiradi.
  bool isAvailable(LogDayView day) => day.available;
}

final NotifierProvider<LogReportController, LogReportState> logReportControllerProvider =
    NotifierProvider<LogReportController, LogReportState>(LogReportController.new);

/// Tanlangan kun oqimi — ekran shu provayderni kuzatadi.
final Provider<AsyncValue<LogDayView>> selectedLogDayProvider = Provider<AsyncValue<LogDayView>>(
  (Ref ref) => ref.watch(logDayProvider(ref.watch(logReportControllerProvider).selectedDate)),
);
