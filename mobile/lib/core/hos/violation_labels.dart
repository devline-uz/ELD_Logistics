/// HOS buzilish kodi → lokalizatsiya qilingan matn (yagona mapping).
///
/// Kodlar `hos_engine` dagi [ViolationType] konstantalari bilan bir xil —
/// ular Go `internal/hos` violation turlarining aynan nusxasi, shuning uchun
/// bu yerda satr literal yozilmaydi.
library;

import 'package:hos_engine/hos_engine.dart' show ViolationType;

import '../i18n/l10n_extension.dart';

/// `violations.type` → foydalanuvchi matni; noma'lum kod uchun umumiy xato.
String violationTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  ViolationType.driveLimit => l10n.hosViolationDriveLimit,
  ViolationType.shiftLimit => l10n.hosViolationShiftLimit,
  ViolationType.breakRequired => l10n.hosViolationBreakRequired,
  ViolationType.cycleLimit => l10n.hosViolationCycleLimit,
  ViolationType.uncertifiedLog => l10n.hosViolationUncertifiedLog,
  ViolationType.formMannerTrailer => l10n.hosViolationFormMannerTrailer,
  ViolationType.formMannerDoc => l10n.hosViolationFormMannerDoc,
  ViolationType.unidentifiedDriving => l10n.hosViolationUnidentifiedDriving,
  ViolationType.eldMalfunction => l10n.hosViolationEldMalfunction,
  ViolationType.missingDvir => l10n.hosViolationMissingDvir,
  _ => l10n.errUnknown,
};
