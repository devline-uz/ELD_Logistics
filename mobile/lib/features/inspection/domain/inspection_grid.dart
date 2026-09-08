/// Duty grid uchun kun ichidagi oraliqlarni hisoblash (sof Dart, M5).
///
/// Widget ichida hisoblash **taqiq** — bu yerda, chunki DST kunlarida kun
/// 23/25 soat bo'lishi mumkin va oraliqlar kun chegarasiga qirqiladi.
library;

import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import 'inspection_models.dart';

/// Kun boshidan hisoblangan bitta status oralig'i.
class InspectionSpan {
  const InspectionSpan({required this.status, required this.start, required this.end});

  final DutyStatus status;
  final Duration start;
  final Duration end;

  Duration get length => end - start;
}

/// [day] eventlaridan kun bo'ylab uzluksiz oraliqlar quradi.
///
/// [dayStart] — kunning UTC boshlanishi, [dayLength] — kun uzunligi
/// (DST da 23 yoki 25 soat). Kun boshidan birinchi eventgacha bo'lgan bo'shliq
/// [carryOver] status bilan to'ldiriladi (oldingi kundan davom etuvchi status);
/// `null` bo'lsa bo'shliq qoldiriladi.
List<InspectionSpan> inspectionSpans({
  required InspectionDay day,
  required DateTime dayStart,
  Duration dayLength = const Duration(hours: 24),
  DutyStatus? carryOver,
}) {
  final List<InspectionSpan> spans = <InspectionSpan>[];
  DutyStatus? current = carryOver;
  Duration cursor = Duration.zero;

  for (final InspectionEvent event in day.events) {
    Duration offset = event.at.toUtc().difference(dayStart.toUtc());
    if (offset.isNegative) {
      offset = Duration.zero;
    }
    if (offset > dayLength) {
      offset = dayLength;
    }
    if (current != null && offset > cursor) {
      spans.add(InspectionSpan(status: current, start: cursor, end: offset));
    }
    current = event.status;
    if (offset > cursor) {
      cursor = offset;
    }
  }

  if (current != null && cursor < dayLength) {
    spans.add(InspectionSpan(status: current, start: cursor, end: dayLength));
  }
  return spans;
}
