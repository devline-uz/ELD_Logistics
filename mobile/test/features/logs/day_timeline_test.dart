@Timeout(Duration(seconds: 60))
/// `day_timeline` va `validateDriverEdit` domen testlari (M98, M136).
library;

import 'package:eld_mobile/features/logs/domain/day_timeline.dart';
import 'package:eld_mobile/features/logs/domain/log_models.dart';
import 'package:eld_mobile/features/logs/domain/logs_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

void main() {
  final DateTime dayStart = DateTime(2026, 9, 7);

  LogEventView event(DutyStatus status, int hour) => LogEventView(
    clientEventId: 's$hour',
    status: status,
    start: dayStart.add(Duration(hours: hour)),
  );

  group('buildDaySpans', () {
    test('oraliqlar keyingi event bilan yopiladi', () {
      final List<DaySpan> spans = buildDaySpans(
        dayStart: dayStart,
        events: <LogEventView>[
          event(DutyStatus.off, 0),
          event(DutyStatus.dr, 6),
          event(DutyStatus.on, 9),
        ],
        until: dayStart.add(const Duration(hours: 12)),
      );

      expect(spans.length, 3);
      expect(spans[0].length, const Duration(hours: 6));
      expect(spans[1].length, const Duration(hours: 3));
      // Oxirgi oraliq `until` gacha.
      expect(spans[2].length, const Duration(hours: 3));
    });

    test('kun oxiridan oshib ketmaydi', () {
      final List<DaySpan> spans = buildDaySpans(
        dayStart: dayStart,
        events: <LogEventView>[event(DutyStatus.on, 23)],
        until: dayStart.add(const Duration(days: 2)),
      );
      expect(spans.single.end, const Duration(hours: 24));
    });

    test('bo\'sh kun — oraliq yo\'q', () {
      expect(
        buildDaySpans(dayStart: dayStart, events: const <LogEventView>[], until: dayStart),
        isEmpty,
      );
    });
  });

  test('totalsFromSpans jamilarni to\'g\'ri yig\'adi (M98)', () {
    final Map<DutyStatus, Duration> totals = totalsFromSpans(<DaySpan>[
      const DaySpan(status: DutyStatus.off, start: Duration.zero, end: Duration(hours: 3)),
      const DaySpan(
        status: DutyStatus.off,
        start: Duration(hours: 4),
        end: Duration(hours: 4, minutes: 6),
      ),
      const DaySpan(status: DutyStatus.dr, start: Duration(hours: 5), end: Duration(hours: 6)),
    ]);

    expect(totals[DutyStatus.off], const Duration(hours: 3, minutes: 6));
    expect(totals[DutyStatus.dr], const Duration(hours: 1));
    expect(totals[DutyStatus.sb], Duration.zero);
  });

  group('validateDriverEdit (M136/M133)', () {
    DriverLogEdit edit({String note = 'fix', SpecialMode special = SpecialMode.none}) =>
        DriverLogEdit(
          logDate: '2026-09-07',
          from: dayStart.add(const Duration(hours: 13)),
          to: dayStart.add(const Duration(hours: 15)),
          status: DutyStatus.on,
          note: note,
          special: special,
        );

    test('note majburiy', () {
      expect(
        validateDriverEdit(edit(note: '  '), dayLocked: false, overlapsAutoDriving: false),
        contains(DriverEditIssue.noteRequired),
      );
    });

    test('avtomatik DR ustiga yozish taqiq', () {
      expect(
        validateDriverEdit(edit(), dayLocked: false, overlapsAutoDriving: true),
        contains(DriverEditIssue.drImmutable),
      );
    });

    test('DR → PC istisnosi', () {
      expect(
        validateDriverEdit(
          edit(special: SpecialMode.pc),
          dayLocked: false,
          overlapsAutoDriving: true,
        ),
        isEmpty,
      );
    });

    test('locked kun — faqat edit-request orqali', () {
      expect(
        validateDriverEdit(edit(), dayLocked: true, overlapsAutoDriving: false),
        contains(DriverEditIssue.dayLocked),
      );
    });
  });
}
