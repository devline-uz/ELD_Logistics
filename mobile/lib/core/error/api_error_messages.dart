/// Backend xato kodi → foydalanuvchi matni (i18n) mapping jadvali.
///
/// Kodlar manbai: `backend/internal/apierr/codes.go` + `contracts/swagger.json`.
/// Jadvalga kod qo'shishdan oldin u backendda mavjudligi tekshiriladi.
library;

import '../../l10n/generated/app_localizations.dart';
import 'api_error.dart';
import 'api_error_code.dart';

/// Xato kodini lokalizatsiya qilingan matnga o'giradi.
///
/// Noma'lum kod uchun `errUnknown` qaytariladi — backend xabari
/// **hech qachon** to'g'ridan-to'g'ri ko'rsatilmaydi (texnik, tarjimasiz).
String localizedApiError(AppLocalizations l10n, ApiError error) =>
    localizedApiErrorCode(l10n, error.code);

/// Kod bo'yicha matn (xato obyekti bo'lmaganda).
String localizedApiErrorCode(AppLocalizations l10n, String code) => switch (code) {
  // --- Mijoz tomonidagi ---
  ApiErrorCode.clientNetwork => l10n.errNetwork,
  ApiErrorCode.clientTimeout => l10n.errTimeout,
  ApiErrorCode.clientTlsPinning => l10n.errTlsPinning,
  ApiErrorCode.clientCancelled => l10n.errUnknown,

  // --- Transport ---
  ApiErrorCode.validationError => l10n.errValidation,
  ApiErrorCode.badRequest => l10n.errBadRequest,
  ApiErrorCode.unauthorized => l10n.errUnauthorized,
  ApiErrorCode.forbidden => l10n.errForbidden,
  ApiErrorCode.notFound => l10n.errNotFound,
  ApiErrorCode.conflict ||
  ApiErrorCode.uniqueViolation ||
  ApiErrorCode.staleVersion ||
  ApiErrorCode.idempotencyConflict => l10n.errConflict,
  ApiErrorCode.rateLimited => l10n.errRateLimited,
  ApiErrorCode.internalError ||
  ApiErrorCode.upstreamError ||
  ApiErrorCode.storageError ||
  ApiErrorCode.notificationFailed => l10n.errServer,
  ApiErrorCode.serviceUnavailable || ApiErrorCode.upstreamTimeout => l10n.errUnavailable,
  ApiErrorCode.payloadTooLarge => l10n.errPayloadTooLarge,
  ApiErrorCode.unsupportedMediaType || ApiErrorCode.fileTypeInvalid => l10n.errFileTypeInvalid,

  // --- Auth / sessiya ---
  ApiErrorCode.invalidCredentials => l10n.errInvalidCredentials,
  ApiErrorCode.accountInactive => l10n.errAccountInactive,
  ApiErrorCode.accountSuspended => l10n.errAccountSuspended,
  ApiErrorCode.lockedOut => l10n.errLockedOut,
  ApiErrorCode.totpRequired => l10n.errTotpRequired,
  ApiErrorCode.totpInvalid => l10n.errTotpInvalid,
  ApiErrorCode.totpSetupRequired || ApiErrorCode.totpAlreadyEnabled => l10n.errTotpSetupRequired,
  ApiErrorCode.pinRequired => l10n.errPinRequired,
  ApiErrorCode.pinInvalid => l10n.errPinInvalid,
  ApiErrorCode.pinNotSet => l10n.errPinNotSet,
  ApiErrorCode.pinLocked => l10n.errPinLocked,
  ApiErrorCode.sessionReplaced => l10n.errSessionReplaced,
  ApiErrorCode.sessionExpired || ApiErrorCode.tokenExpired => l10n.errSessionExpired,
  ApiErrorCode.tokenRevoked ||
  ApiErrorCode.tokenReused ||
  ApiErrorCode.tokenInvalid => l10n.errTokenRevoked,
  ApiErrorCode.invitationInvalid => l10n.errInvitationInvalid,
  ApiErrorCode.invitationExpired => l10n.errInvitationExpired,
  ApiErrorCode.invitationUsed => l10n.errInvitationUsed,
  ApiErrorCode.deviceNotAllowed => l10n.errDeviceNotAllowed,
  ApiErrorCode.passwordWeak => l10n.errPasswordWeak,
  ApiErrorCode.passwordReused => l10n.errPasswordReused,

  // --- Tenancy / obuna ---
  ApiErrorCode.subscriptionReadonly => l10n.errSubscriptionReadonly,
  ApiErrorCode.subscriptionExpired => l10n.errSubscriptionExpired,
  ApiErrorCode.featureDisabled ||
  ApiErrorCode.quotaExceeded ||
  ApiErrorCode.tenantMismatch => l10n.errFeatureDisabled,

  // --- HOS / loglar ---
  ApiErrorCode.drImmutable => l10n.errDrImmutable,
  ApiErrorCode.logNotReady => l10n.errLogNotReady,
  ApiErrorCode.logCertified => l10n.errLogCertified,
  ApiErrorCode.timeInFuture => l10n.errTimeInFuture,
  ApiErrorCode.timeOutOfRange => l10n.errTimeOutOfRange,
  ApiErrorCode.duplicateEvent => l10n.errDuplicateEvent,
  ApiErrorCode.eventOutOfOrder => l10n.errEventOutOfOrder,
  ApiErrorCode.statusNotAllowed || ApiErrorCode.cycleNotSupported => l10n.errStatusNotAllowed,
  ApiErrorCode.eventImmutable || ApiErrorCode.immutable => l10n.errEventImmutable,
  ApiErrorCode.editNotAllowed => l10n.errEditNotAllowed,
  ApiErrorCode.editRejected => l10n.errEditRejected,
  ApiErrorCode.malfunctionActive => l10n.errMalfunctionActive,

  // --- Sync ---
  ApiErrorCode.syncConflict => l10n.errSyncConflict,
  ApiErrorCode.batchTooLarge => l10n.errBatchTooLarge,

  // --- Chat ---
  ApiErrorCode.drivingModeBlocked => l10n.errDrivingModeBlocked,
  ApiErrorCode.messageTooLong => l10n.errMessageTooLong,

  // --- Resurs holati ---
  ApiErrorCode.alreadyAssigned => l10n.errAlreadyAssigned,
  ApiErrorCode.notAssigned => l10n.errNotAssigned,
  ApiErrorCode.invalidState || ApiErrorCode.resourceInUse => l10n.errInvalidState,

  // --- DVIR ---
  ApiErrorCode.dvirInvalidTransition => l10n.errDvirInvalidTransition,
  ApiErrorCode.dvirNoDefects => l10n.errDvirNoDefects,
  ApiErrorCode.defectTypeUnknown ||
  ApiErrorCode.defectTypeSystemLocked => l10n.errDefectTypeUnknown,

  // --- Fayl / qurilma ---
  ApiErrorCode.fileTooLarge => l10n.errFileTooLarge,
  ApiErrorCode.deviceUnknown => l10n.errDeviceUnknown,
  ApiErrorCode.deviceProtocolError => l10n.errDeviceProtocol,

  _ => l10n.errUnknown,
};
