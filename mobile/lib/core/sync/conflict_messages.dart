/// §5.6 konflikt sabablarini lokalizatsiya qilingan matnga bog'laydi (M30).
///
/// `sync_core` sof Dart bo'lgani uchun u faqat **kalit** qaytaradi; matn shu
/// yerda `AppLocalizations` dan olinadi (hard-coded matn taqiq).
library;

import 'package:sync_core/sync_core.dart';

import '../i18n/l10n_extension.dart';

/// Rad etish sababining foydalanuvchiga ko'rinadigan matni.
String conflictMessage(AppLocalizations l10n, RejectReason reason) =>
    switch (presentationFor(reason).messageKey) {
      'conflictTimeInFuture' => l10n.conflictTimeInFuture,
      'conflictTimeOutOfRange' => l10n.conflictTimeOutOfRange,
      'conflictLogLocked' => l10n.conflictLogLocked,
      'conflictSuperseded' => l10n.conflictSuperseded,
      'conflictInvalidPayload' => l10n.conflictInvalidPayload,
      'conflictSpecialNotAllowed' => l10n.conflictSpecialNotAllowed,
      'conflictSleeperBerthUnavailable' => l10n.conflictSleeperBerthUnavailable,
      'conflictDriveNotManual' => l10n.conflictDriveNotManual,
      'conflictYardMoveEnded' => l10n.conflictYardMoveEnded,
      _ => l10n.conflictUnknown,
    };

/// `M-55` dagi amal tugmasi matni; amal bo'lmasa `null`.
String? conflictActionLabel(AppLocalizations l10n, RejectReason reason) =>
    switch (presentationFor(reason).action) {
      ConflictAction.resend => l10n.conflictActionResend,
      ConflictAction.contactSupport => l10n.conflictActionContactSupport,
      ConflictAction.sendDiagnostics => l10n.conflictActionSendDiagnostics,
      ConflictAction.viewOnly ||
      ConflictAction.informational ||
      ConflictAction.hideToggle ||
      ConflictAction.disableSleeperBerth ||
      ConflictAction.none => null,
    };

/// Navbat turining foydalanuvchiga ko'rinadigan nomi (`M-54`).
String outboxKindLabel(AppLocalizations l10n, OutboxKind kind) => switch (kind) {
  OutboxKind.event => l10n.syncKindEvent,
  OutboxKind.telemetry => l10n.syncKindTelemetry,
  OutboxKind.dvir => l10n.syncKindDvir,
  OutboxKind.chat => l10n.syncKindChat,
  OutboxKind.certify => l10n.syncKindCertify,
  OutboxKind.claim => l10n.syncKindClaim,
  OutboxKind.logEdit => l10n.syncKindLogEdit,
  OutboxKind.pushToken => l10n.syncKindPushToken,
  OutboxKind.feedback => l10n.syncKindFeedback,
  OutboxKind.support => l10n.syncKindSupport,
};
