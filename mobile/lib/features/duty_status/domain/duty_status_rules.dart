/// Duty status biznes qoidalari (tz-mobile §9.2, §9.4, §9.6, §9.8, §9.9).
///
/// **Sof funksiyalar:** widget ham, provayder ham qaror qabul qilmaydi —
/// hammasi shu yerda va unit test bilan qoplangan.
library;

import 'package:hos_engine/hos_engine.dart';
import 'package:sync_core/sync_core.dart';

import 'duty_status_models.dart';

/// `Notes` maydonining chegarasi (tz-mobile §9.2).
const int kMaxDutyNotesLength = 60;

/// GPS aniqligi shundan yomon bo'lsa `M-14` dialogi taklif qilinadi.
const double kLocationAccuracyThresholdM = 150;

/// `intermediate` eventlar oralig'i (M63).
const Duration kIntermediateInterval = Duration(minutes: 60);

/// Formani saqlashga to'sqinlik qiladigan sabablar.
enum DutyIssue {
  /// `DR` qo'lda tanlanmaydi (M51/M56).
  drivingNotManual,

  /// Status ham, PC/YM ham o'zgarmadi.
  statusUnchanged,

  /// `Notes` 60 belgidan uzun.
  notesTooLong,

  /// PC uchun sabab majburiy (tz-mobile §9.8).
  reasonRequired,

  /// Unit'da sleeper berth yo'q (M52).
  sleeperUnavailable,

  /// `allow_pc=false` (M64).
  pcNotAllowed,

  /// `allow_ym=false` (M64).
  ymNotAllowed,
}

/// Formani tekshiradi. Bo'sh ro'yxat — saqlash mumkin.
List<DutyIssue> validateDutyDraft({
  required DutyStatusDraft draft,
  required DutyStatusContext context,
}) {
  final List<DutyIssue> issues = <DutyIssue>[];

  if (!draft.status.isSelectable) {
    issues.add(DutyIssue.drivingNotManual);
  }
  if (draft.status == DutyStatusValue.sleeper && !context.sleeperAvailable) {
    issues.add(DutyIssue.sleeperUnavailable);
  }
  if (draft.special == DutySpecial.personalConveyance) {
    if (!context.pcAllowed) {
      issues.add(DutyIssue.pcNotAllowed);
    }
    if (draft.reason.trim().isEmpty) {
      issues.add(DutyIssue.reasonRequired);
    }
  }
  if (draft.special == DutySpecial.yardMove && !context.ymAllowed) {
    issues.add(DutyIssue.ymNotAllowed);
  }
  if (draft.notes.length > kMaxDutyNotesLength) {
    issues.add(DutyIssue.notesTooLong);
  }
  if (draft.status == context.current && draft.special == context.special) {
    issues.add(DutyIssue.statusUnchanged);
  }
  return issues;
}

/// Tanlangan status uchun ruxsat etilgan maxsus rejim (M64: taqiqlangani
/// **yashiriladi**, o'chirilgan holatda emas).
DutySpecial? availableSpecialFor(DutyStatusValue status, HosPolicy policy) => switch (status) {
  DutyStatusValue.off when policy.allowPc => DutySpecial.personalConveyance,
  DutyStatusValue.on when policy.allowYm => DutySpecial.yardMove,
  _ => null,
};

/// Status almashganda eskirgan PC/YM ni tozalaydi.
DutySpecial normalizeSpecial(DutyStatusValue status, DutySpecial special) =>
    special.host == status ? special : DutySpecial.none;

/// GPS aniqligi yomon — `M-14` dialogi ko'rsatiladi.
bool locationNeedsConfirmation(double? accuracyM) =>
    accuracyM != null && accuracyM > kLocationAccuracyThresholdM;

/// Tezlik YM chegarasidan oshdi — YM tugaydi va `DR` boshlanadi (tz-mobile §9.4).
bool yardMoveExpired({
  required DutySpecial special,
  required double? speedKmh,
  required HosPolicy policy,
}) => special == DutySpecial.yardMove && speedKmh != null && shouldExitYardMove(speedKmh, policy);

/// PC rejimida harakat `DR` yozmaydi (tz-mobile §9.4).
bool autoDriveSuppressed(DutySpecial special) => special == DutySpecial.personalConveyance;

/// Tezlik `DR` ni boshlashi kerakmi (ECM yo'q bo'lsa GPS fallback).
bool motionStartsDriving({required double speedKmh, required HosPolicy policy}) =>
    shouldStartDriving(speedKmh, policy);

/// Quick note ni mavjud matnga **qo'shadi** (almashtirmaydi) va 60 belgiga
/// kesadi (M55).
String appendQuickNote(String current, String note) {
  final String trimmed = current.trim();
  final String merged = trimmed.isEmpty ? note : '$trimmed, $note';
  return merged.length <= kMaxDutyNotesLength ? merged : merged.substring(0, kMaxDutyNotesLength);
}

/// Bir nechta quick note ni ketma-ket qo'shadi.
String appendQuickNotes(String current, Iterable<String> notes) =>
    notes.fold<String>(current, appendQuickNote);

/// Qo'shilganda matn kesilganmi (foydalanuvchi ogohlantiriladi).
bool quickNotesTruncated(String current, Iterable<String> notes) {
  final String trimmed = current.trim();
  final String merged = <String>[if (trimmed.isNotEmpty) trimmed, ...notes].join(', ');
  return merged.length > kMaxDutyNotesLength;
}

/// M66: ELD ulanmagan bo'lsa event `manual_no_eld` bo'lib yoziladi.
EventOrigin dutyEventOrigin({required bool eldConnected, bool auto = false}) {
  if (auto) {
    return EventOrigin.auto;
  }
  return eldConnected ? EventOrigin.driver : EventOrigin.manualNoEld;
}

/// Eventga yoziladigan izoh: sabab (PC/YM) va `Notes` birlashadi.
String? dutyEventNotes(DutyStatusDraft draft) {
  final String reason = draft.reason.trim();
  final String notes = draft.notes.trim();
  final String merged = <String>[
    if (reason.isNotEmpty) reason,
    if (notes.isNotEmpty) notes,
  ].join(' — ');
  return merged.isEmpty ? null : merged;
}
