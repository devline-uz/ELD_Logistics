/// Sana/vaqt formatlari — tz-mobile §11.0.7 (M91/M92).
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime sample = DateTime(2025, 5, 28, 14, 24, 3);

  test('sana tasmasi: EEE dd', () {
    expect(AppFormats.dayStripOf(DateTime(2025, 5, 28)), 'Wed 28');
    expect(AppFormats.dayStripOf(DateTime(2025, 3, 7)), 'Fri 07');
  });

  test('ro\'yxat sarlavhasi: EEE, MMM d', () {
    expect(AppFormats.listHeaderOf(DateTime(2025, 5, 20)), 'Tue, May 20');
  });

  test('to\'liq sana-vaqt: MMM d, yyyy · hh:mm a', () {
    expect(AppFormats.fullDateTime(sample), 'May 28, 2025 · 02:24 PM');
  });

  test('log event vaqti: hh:mm:ss a', () {
    expect(AppFormats.eventTimeOf(DateTime(2025, 5, 28, 2, 3, 23)), '02:03:23 AM');
  });

  test('davomiylik: HH:mm:ss va HH:mm', () {
    expect(AppFormats.durationHms(const Duration(hours: 22, minutes: 2, seconds: 21)), '22:02:21');
    expect(AppFormats.durationHm(const Duration(hours: 8)), '08:00');
    expect(AppFormats.durationHm(const Duration(hours: 70, minutes: 5)), '70:05');
  });

  test('manfiy davomiylik nolga qisiladi', () {
    expect(AppFormats.durationHm(const Duration(hours: -3)), '00:00');
  });

  test('koordinata `.` ajratgich bilan', () {
    expect(AppFormats.coordinate(23.97464553778), '23.97464553778');
  });

  test('M92 (#B-10): bo\'sh qiymat N/A', () {
    expect(AppFormats.dayStripOf(null), 'N/A');
    expect(AppFormats.fullDateTime(null), 'N/A');
    expect(AppFormats.durationHms(null), 'N/A');
    expect(AppFormats.coordinate(null), 'N/A');
    expect(AppFormats.orNa(''), 'N/A');
    expect(AppFormats.orNa('   '), 'N/A');
    expect(AppFormats.orNa('OK'), 'OK');
  });

  test('M92 (#B-11): hafta kuni 3 harfli, Tues/Thurs yo\'q', () {
    for (int d = 1; d <= 7; d++) {
      final String name = AppFormats.dayStripOf(DateTime(2025, 9, d)).split(' ').first;
      expect(name.length, 3, reason: name);
    }
  });
}
