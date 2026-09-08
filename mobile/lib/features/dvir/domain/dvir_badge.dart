/// `kind` → badge mapping (tz-mobile M102, M103).
///
/// **M103 [MUST]:** badge faqat serverdagi `kind` maydonidan hosil bo'ladi;
/// mobil hech qachon `status` dan o'zi hisoblamaydi. `status` faqat qo'shimcha
/// belgini (`Awaiting certification` / `Closed`) tanlashda ishlatiladi.
library;

import 'dvir_models.dart';

/// Badge ohangi — `core/ui` `StatusTone` ga presentation qatlamida o'giriladi
/// (domen Flutter'ga bog'lanmaydi).
enum DvirBadgeTone { neutral, success, warning, error }

/// Badge tavsifi: asosiy yorliq + ixtiyoriy kichik izoh.
class DvirBadge {
  const DvirBadge({required this.label, required this.tone, this.suffix});

  /// Yorliq kaliti (`DvirBadgeLabel`) — matn `context.l10n` dan olinadi.
  final DvirBadgeLabel label;

  final DvirBadgeTone tone;

  /// Kichik qo'shimcha belgi (`Awaiting certification` / `Closed`).
  final DvirBadgeSuffix? suffix;
}

enum DvirBadgeLabel { draft, noDefects, defectsNotFixed, defectsFixed }

enum DvirBadgeSuffix { awaitingCertification, closed }

/// M102 jadvali. `kind == null` — lokal qoralama.
DvirBadge dvirBadgeOf({
  required DvirKind? kind,
  required DvirStatus status,
  bool isLocalDraft = false,
}) {
  if (isLocalDraft || kind == null) {
    return const DvirBadge(label: DvirBadgeLabel.draft, tone: DvirBadgeTone.neutral);
  }

  return switch (kind) {
    DvirKind.noDefects => const DvirBadge(
      label: DvirBadgeLabel.noDefects,
      tone: DvirBadgeTone.success,
    ),
    DvirKind.defectsNotFixed => const DvirBadge(
      label: DvirBadgeLabel.defectsNotFixed,
      tone: DvirBadgeTone.error,
    ),
    // `repaired` — mexanik tuzatgan, sertifikatsiya kutilmoqda.
    DvirKind.defectsUncertified => const DvirBadge(
      label: DvirBadgeLabel.defectsFixed,
      tone: DvirBadgeTone.warning,
      suffix: DvirBadgeSuffix.awaitingCertification,
    ),
    DvirKind.defectsFixed =>
      status == DvirStatus.closedNoCertification
          ? const DvirBadge(
              label: DvirBadgeLabel.defectsFixed,
              tone: DvirBadgeTone.neutral,
              suffix: DvirBadgeSuffix.closed,
            )
          : const DvirBadge(label: DvirBadgeLabel.defectsFixed, tone: DvirBadgeTone.success),
  };
}
