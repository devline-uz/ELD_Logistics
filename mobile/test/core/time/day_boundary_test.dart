/// Kun chegarasi: Home Terminal TZ, DST 23/25 soat (§7.3, M42).

library;

import 'package:eld_mobile/core/time/day_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(initTimeZones);

  test('log kuni Home Terminal TZ da hisoblanadi, qurilma TZ da emas', () {
    // 2026-03-10 04:30Z = 2026-03-09 23:30 America/Chicago (CDT, hali oldingi kun).
    expect(logDateOf(DateTime.utc(2026, 3, 10, 4, 30), 'America/Chicago'), '2026-03-09');
    expect(logDateOf(DateTime.utc(2026, 3, 10, 4, 30), 'UTC'), '2026-03-10');
  });

  test('kun chegarasi mahalliy 00:00', () {
    // Sentabr — CDT (UTC-5).
    expect(dayStartUtc('2026-09-07', 'America/Chicago'), DateTime.utc(2026, 9, 7, 5));
    expect(dayEndUtc('2026-09-07', 'America/Chicago'), DateTime.utc(2026, 9, 8, 5));
    expect(dayLength('2026-09-07', 'America/Chicago'), const Duration(hours: 24));
  });

  test('DST bahor: kun 23 soat (dst_spring_forward_23h_day)', () {
    expect(dayLength('2026-03-08', 'America/Chicago'), const Duration(hours: 23));
  });

  test('DST kuz: kun 25 soat (dst_fall_back_25h_day)', () {
    expect(dayLength('2026-11-01', 'America/Chicago'), const Duration(hours: 25));
  });

  test('noma\'lum zona UTC ga tushadi, ilova yiqilmaydi', () {
    expect(logDateOf(DateTime.utc(2026, 9, 7, 23), 'Mars/Olympus'), '2026-09-07');
  });

  test('formatLogDate / parseLogDate teskari amallar', () {
    expect(formatLogDate(DateTime.utc(2026, 1, 5)), '2026-01-05');
    final ({int day, int month, int year}) parts = parseLogDate('2026-01-05');
    expect(parts.year, 2026);
    expect(parts.month, 1);
    expect(parts.day, 5);
    expect(() => parseLogDate('2026/01/05'), throwsFormatException);
  });

  test('recentLogDates yangisidan eskisiga qarab beradi', () {
    final List<String> dates = recentLogDates(
      now: DateTime.utc(2026, 9, 7, 12),
      timeZoneName: 'America/Chicago',
      days: 3,
    );
    expect(dates, <String>['2026-09-07', '2026-09-06', '2026-09-05']);
  });

  group('#B-32 — kalendar sanasi Home Terminal TZ da', () {
    test('todayLogDate qurilma TZ dan mustaqil', () {
      // 2026-09-08 03:00Z = 2026-09-07 22:00 America/Chicago.
      final DateTime now = DateTime.utc(2026, 9, 8, 3);
      expect(todayLogDate(now: now, timeZoneName: 'America/Chicago'), '2026-09-07');
      expect(todayLogDate(now: now, timeZoneName: 'UTC'), '2026-09-08');
      expect(todayLogDate(now: now, timeZoneName: 'Asia/Tashkent'), '2026-09-08');
    });

    test('calendarDateOf vaqt qismisiz sana beradi', () {
      expect(calendarDateOf('2026-03-08'), DateTime(2026, 3, 8));
      expect(normalizeCalendarDate(DateTime(2026, 3, 8, 17, 45)), DateTime(2026, 3, 8));
    });

    test('todayCalendarDate DST bahor kunida ham to\'g\'ri kun beradi', () {
      // 2026-03-08 08:30Z — America/Chicago da soat 03:30 (o'tish kuni, 23 soat).
      expect(
        todayCalendarDate(now: DateTime.utc(2026, 3, 8, 8, 30), timeZoneName: 'America/Chicago'),
        DateTime(2026, 3, 8),
      );
      expect(dayLength('2026-03-08', 'America/Chicago'), const Duration(hours: 23));
    });

    test('recentLogDates DST o\'tishida kunni sakratmaydi/takrorlamaydi', () {
      // `subtract(Duration(days: 1))` shu yerda 2026-03-08 ni ikki marta berardi.
      final List<String> spring = recentLogDates(
        now: DateTime.utc(2026, 3, 10, 12),
        timeZoneName: 'America/Chicago',
        days: 4,
      );
      expect(spring, <String>['2026-03-10', '2026-03-09', '2026-03-08', '2026-03-07']);

      final List<String> fall = recentLogDates(
        now: DateTime.utc(2026, 11, 2, 12),
        timeZoneName: 'America/Chicago',
        days: 4,
      );
      expect(fall, <String>['2026-11-02', '2026-11-01', '2026-10-31', '2026-10-30']);
      expect(dayLength('2026-11-01', 'America/Chicago'), const Duration(hours: 25));
    });
  });
}
