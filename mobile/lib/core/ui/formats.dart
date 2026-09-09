/// Sana/vaqt formatlari (tz-mobile §11.0.7, M91/M92).
///
/// **M92 [MUST]** — barcha formatlar `intl` + `en_US`; hafta kunlari 3 harfli
/// (`Mon…Sun`), bo'sh qiymat — `N/A`.
///
/// Bu yerda **UI formatlashi** turadi; domen mantiqi emas. Vaqt manbai
/// `core/time/TimeSource` (bu funksiyalar `DateTime.now()` ni chaqirmaydi).
library;

import 'package:intl/intl.dart';

/// M92: yagona lokal.
const String kFormatLocale = 'en_US';

/// M92: bo'sh qiymat ko'rsatkichi (#B-10).
const String kEmptyValue = 'N/A';

abstract final class AppFormats {
  const AppFormats._();

  /// Sana tasmasi (8 kun): `Fri 07`.
  static final DateFormat dayStrip = DateFormat('EEE dd', kFormatLocale);

  /// Sana tasmasi — hafta kuni qatori: `Fri` (#B-16).
  static final DateFormat dayStripWeekday = DateFormat('EEE', kFormatLocale);

  /// Sana tasmasi — kun raqami qatori: `07` (#B-16).
  static final DateFormat dayStripNumber = DateFormat('dd', kFormatLocale);

  /// Ro'yxat sarlavhasi / guruh: `Tue, May 20`.
  static final DateFormat listHeader = DateFormat('EEE, MMM d', kFormatLocale);

  /// To'liq sana-vaqt: `May 28, 2025 · 02:24 PM`.
  static final DateFormat _fullDate = DateFormat('MMM d, yyyy', kFormatLocale);
  static final DateFormat _fullTime = DateFormat('hh:mm a', kFormatLocale);

  /// Log event vaqti: `02:03:23 AM`.
  static final DateFormat eventTime = DateFormat('hh:mm:ss a', kFormatLocale);

  /// Bildirishnoma (24 soatdan keyin): `May 28, 10:04 AM`.
  static final DateFormat notificationDate = DateFormat('MMM d, hh:mm a', kFormatLocale);

  /// `EEE dd`.
  static String dayStripOf(DateTime? value) => value == null ? kEmptyValue : dayStrip.format(value);

  /// `EEE`.
  static String dayStripWeekdayOf(DateTime? value) =>
      value == null ? kEmptyValue : dayStripWeekday.format(value);

  /// `dd`.
  static String dayStripNumberOf(DateTime? value) =>
      value == null ? kEmptyValue : dayStripNumber.format(value);

  /// `EEE, MMM d`.
  static String listHeaderOf(DateTime? value) =>
      value == null ? kEmptyValue : listHeader.format(value);

  /// `MMM d, yyyy · hh:mm a`.
  static String fullDateTime(DateTime? value) =>
      value == null ? kEmptyValue : '${_fullDate.format(value)} · ${_fullTime.format(value)}';

  /// `hh:mm:ss a`.
  static String eventTimeOf(DateTime? value) =>
      value == null ? kEmptyValue : eventTime.format(value);

  /// Davomiylik / hisoblagich: `HH:mm:ss` (`22:02:21`). Soat 24 dan oshishi mumkin.
  static String durationHms(Duration? value) {
    if (value == null) {
      return kEmptyValue;
    }
    final Duration d = value.isNegative ? Duration.zero : value;
    final String h = d.inHours.toString().padLeft(2, '0');
    final String m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final String s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// HOS indikatori: `HH:mm` (`08:00`).
  static String durationHm(Duration? value) {
    if (value == null) {
      return kEmptyValue;
    }
    final Duration d = value.isNegative ? Duration.zero : value;
    final String h = d.inHours.toString().padLeft(2, '0');
    final String m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Butun son (badge, hisoblagich) — `en_US` guruhlash bilan (`1,204`).
  static final NumberFormat _integer = NumberFormat.decimalPattern(kFormatLocale);

  /// Hisoblagich qiymati matni.
  static String count(int? value) => value == null ? kEmptyValue : _integer.format(value);

  /// Koordinata: `.` o'nlik ajratgich, 11 xona (`23.97464553778`).
  static String coordinate(double? value, {int fractionDigits = 11}) =>
      value == null ? kEmptyValue : value.toStringAsFixed(fractionDigits);

  /// Bo'sh/`null` matnni `N/A` ga aylantiradi (#B-10).
  static String orNa(String? value) =>
      (value == null || value.trim().isEmpty) ? kEmptyValue : value;
}
