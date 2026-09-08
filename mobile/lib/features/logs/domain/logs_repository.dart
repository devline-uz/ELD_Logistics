/// Logs moduli domen kontraktlari (M5).
library;

import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import 'log_models.dart';

/// M136: haydovchining o'z tahriri (`note` majburiy).
class DriverLogEdit {
  const DriverLogEdit({
    required this.logDate,
    required this.from,
    required this.to,
    required this.status,
    required this.note,
    this.special = SpecialMode.none,
    this.unitId,
  });

  /// `YYYY-MM-DD` (Home Terminal TZ).
  final String logDate;
  final DateTime from;
  final DateTime to;
  final DutyStatus status;

  /// **Majburiy** (M136) — bo'sh bo'lsa so'rov yuborilmaydi.
  final String note;

  final SpecialMode special;
  final String? unitId;
}

/// [DriverLogEdit] validatsiya natijasi (biznes qoidasi, widget'da emas).
enum DriverEditIssue {
  /// `note` bo'sh (M136).
  noteRequired,

  /// `to <= from`.
  invalidRange,

  /// M133: avtomatik yozilgan `DR` o'zgartirilmaydi.
  drImmutable,

  /// Kun `locked=true` — faqat edit-request orqali.
  dayLocked,
}

/// M133/M136: tahrir taklifi ruxsat etilganmi.
List<DriverEditIssue> validateDriverEdit(
  DriverLogEdit edit, {
  required bool dayLocked,
  required bool overlapsAutoDriving,
}) {
  final List<DriverEditIssue> issues = <DriverEditIssue>[];
  if (edit.note.trim().isEmpty) {
    issues.add(DriverEditIssue.noteRequired);
  }
  if (!edit.to.isAfter(edit.from)) {
    issues.add(DriverEditIssue.invalidRange);
  }
  if (dayLocked) {
    issues.add(DriverEditIssue.dayLocked);
  }
  // `DR → PC/YM` ruxsat etilgan istisno (M133).
  final bool toSpecial = edit.special != SpecialMode.none;
  if (overlapsAutoDriving && !toSpecial) {
    issues.add(DriverEditIssue.drImmutable);
  }
  return issues;
}

/// Log ma'lumotlari — oflayn-first (lokal Drift), mutatsiya outbox orqali.
abstract interface class LogsRepository {
  /// 8 kunlik sana tasmasi (M96), eng eskisi birinchi.
  Stream<List<LogDayRef>> watchStrip({int days = 8});

  /// Bitta kunning to'liq ko'rinishi (M-22/M-23).
  Stream<LogDayView> watchDay(DateTime date);

  /// `DVIR` tabi ro'yxati (M-24).
  Stream<List<DvirListItem>> watchDvir({int limit = 50});

  /// M136: tahrirni outbox'ga qo'yadi. Validatsiya yiqilsa
  /// [DriverEditRejected] tashlanadi.
  Future<void> submitDriverEdit(DriverLogEdit edit);
}

/// Domen validatsiyasi yiqildi — hech narsa yozilmadi.
class DriverEditRejected implements Exception {
  const DriverEditRejected(this.issues);

  final List<DriverEditIssue> issues;

  @override
  String toString() => 'DriverEditRejected($issues)';
}
