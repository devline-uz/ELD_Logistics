/// Kun jadvali qurish — **sof domen mantiq** (widget ichida yozilmaydi).
///
/// Bu yerda `DateTime.now()` chaqirilmaydi: kun oxiri chegarasi chaqiruvchidan
/// (`TimeSource`) keladi.
library;

import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import 'log_models.dart';

/// Bir kunning bitta status oralig'i (grid uchun).
class DaySpan {
  const DaySpan({required this.status, required this.start, required this.end});

  final DutyStatus status;

  /// Kun boshidan siljish.
  final Duration start;
  final Duration end;

  Duration get length => end - start;
}

/// Kun boshidan hisoblangan siljish, `[0, 24h]` oralig'iga qisilgan.
Duration _offsetIn(DateTime dayStart, DateTime at) {
  final Duration raw = at.difference(dayStart);
  if (raw.isNegative) {
    return Duration.zero;
  }
  const Duration day = Duration(hours: 24);
  return raw > day ? day : raw;
}

/// [events] dan 24 soatlik grid oraliqlarini quradi.
///
/// [dayStart] — Home Terminal TZ dagi kun boshi; [until] — kun tugagan bo'lsa
/// kun oxiri, aks holda joriy vaqt (`TimeSource`).
List<DaySpan> buildDaySpans({
  required DateTime dayStart,
  required List<LogEventView> events,
  required DateTime until,
}) {
  final List<LogEventView> statusEvents = <LogEventView>[
    for (final LogEventView e in events)
      if (e.status != null) e,
  ]..sort((LogEventView a, LogEventView b) => a.start.compareTo(b.start));
  if (statusEvents.isEmpty) {
    return const <DaySpan>[];
  }

  final DateTime dayEnd = dayStart.add(const Duration(hours: 24));
  final DateTime edge = until.isAfter(dayEnd) ? dayEnd : until;

  final List<DaySpan> spans = <DaySpan>[];
  for (int i = 0; i < statusEvents.length; i++) {
    final LogEventView event = statusEvents[i];
    final DateTime endAt =
        event.end ?? (i + 1 < statusEvents.length ? statusEvents[i + 1].start : edge);
    final Duration start = _offsetIn(dayStart, event.start);
    final Duration end = _offsetIn(dayStart, endAt.isBefore(event.start) ? event.start : endAt);
    if (end <= start) {
      continue;
    }
    spans.add(DaySpan(status: event.status!, start: start, end: end));
  }
  return spans;
}

/// Status bo'yicha jamilar (M98). Grid oraliqlaridan hisoblanadi, shuning uchun
/// ekrandagi chiziq va raqamlar **doim mos** bo'ladi.
Map<DutyStatus, Duration> totalsFromSpans(List<DaySpan> spans) {
  final Map<DutyStatus, Duration> totals = <DutyStatus, Duration>{
    for (final DutyStatus code in DutyStatus.values) code: Duration.zero,
  };
  for (final DaySpan span in spans) {
    totals[span.status] = totals[span.status]! + span.length;
  }
  return totals;
}
