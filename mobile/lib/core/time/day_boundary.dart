/// Kun chegarasi — Home Terminal TZ 00:00–24:00 (§7.3, M42).
///
/// Qurilma vaqt zonasi **hech qachon** ishlatilmaydi: haydovchi zonani kesib
/// o'tsa ham kun o'zgarmaydi. DST kunlari 23 yoki 25 soat bo'ladi.
library;

import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Zaxira zona: kompaniya profili hali kelmagan bo'lsa.
const String kFallbackTimeZone = 'UTC';

bool _initialized = false;

/// IANA tzdata ni yuklaydi. `main()` da bir marta chaqiriladi.
void initTimeZones() {
  if (_initialized) {
    return;
  }
  tzdata.initializeTimeZones();
  _initialized = true;
}

/// Home Terminal zonasi; noma'lum nom kelsa UTC ga tushadi (ilova yiqilmaydi).
tz.Location resolveLocation(String timeZoneName) {
  initTimeZones();
  try {
    return tz.getLocation(timeZoneName);
  } on tz.LocationNotFoundException {
    return tz.getLocation(kFallbackTimeZone);
  }
}

/// [utc] qaysi log kuniga tushishini `YYYY-MM-DD` ko'rinishida qaytaradi.
String logDateOf(DateTime utc, String timeZoneName) {
  final tz.TZDateTime local = tz.TZDateTime.from(utc.toUtc(), resolveLocation(timeZoneName));
  return formatLogDate(local);
}

/// `YYYY-MM-DD` (leksikografik tartib = xronologik tartib).
String formatLogDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// `YYYY-MM-DD` ni (yil, oy, kun) ga ajratadi.
({int year, int month, int day}) parseLogDate(String logDate) {
  final List<String> parts = logDate.split('-');
  if (parts.length != 3) {
    throw FormatException('log_date `YYYY-MM-DD` bo\'lishi kerak', logDate);
  }
  return (year: int.parse(parts[0]), month: int.parse(parts[1]), day: int.parse(parts[2]));
}

/// Kun boshlanishi (UTC).
DateTime dayStartUtc(String logDate, String timeZoneName) {
  final ({int year, int month, int day}) parts = parseLogDate(logDate);
  final tz.Location location = resolveLocation(timeZoneName);
  return tz.TZDateTime(location, parts.year, parts.month, parts.day).toUtc();
}

/// Kun tugashi (keyingi kun boshlanishi, UTC) — yarim ochiq `[start, end)`.
DateTime dayEndUtc(String logDate, String timeZoneName) {
  final ({int year, int month, int day}) parts = parseLogDate(logDate);
  final tz.Location location = resolveLocation(timeZoneName);
  return tz.TZDateTime(location, parts.year, parts.month, parts.day + 1).toUtc();
}

/// Kun uzunligi: DST kunlarida 23 yoki 25 soat (`dst_spring_forward_23h_day`,
/// `dst_fall_back_25h_day` golden vektorlari).
Duration dayLength(String logDate, String timeZoneName) =>
    dayEndUtc(logDate, timeZoneName).difference(dayStartUtc(logDate, timeZoneName));

/// Oxirgi [days] kunning log sanalari, yangisi birinchi.
List<String> recentLogDates({required DateTime now, required String timeZoneName, int days = 14}) {
  final tz.Location location = resolveLocation(timeZoneName);
  final tz.TZDateTime today = tz.TZDateTime.from(now.toUtc(), location);
  return List<String>.generate(
    days,
    (int i) => formatLogDate(tz.TZDateTime(location, today.year, today.month, today.day - i)),
    growable: false,
  );
}

/// Joriy log kuni Home Terminal TZ da (#B-32).
///
/// `DateTime(now.year, now.month, now.day)` **ishlatilmaydi**: u qurilma
/// zonasidagi kunni beradi va zona kesib o'tilganda log noto'g'ri kunga
/// tushadi (M42).
String todayLogDate({required DateTime now, required String timeZoneName}) =>
    logDateOf(now, timeZoneName);

/// `YYYY-MM-DD` → kalendar sanasi (`DateTime(y, m, d)`).
///
/// Natija **instant emas**, faqat ko'rsatish/tanlov uchun kalendar sanasi:
/// grid va oraliq hisoblari [dayStartUtc] / [dayEndUtc] dan foydalanadi.
DateTime calendarDateOf(String logDate) {
  final ({int year, int month, int day}) parts = parseLogDate(logDate);
  return DateTime(parts.year, parts.month, parts.day);
}

/// Kalendar sanasini vaqt qismisiz normallashtiradi (zona konvertatsiyasi
/// **yo'q** — kirish allaqachon Home Terminal kalendar sanasi).
DateTime normalizeCalendarDate(DateTime date) => DateTime(date.year, date.month, date.day);

/// Joriy kalendar sanasi Home Terminal TZ da.
DateTime todayCalendarDate({required DateTime now, required String timeZoneName}) =>
    calendarDateOf(todayLogDate(now: now, timeZoneName: timeZoneName));
