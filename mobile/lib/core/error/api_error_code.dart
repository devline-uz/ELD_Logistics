/// Backend xato kodlari — YAGONA manba: `backend/internal/apierr/codes.go`
/// va `contracts/swagger.json` javob tavsiflari.
///
/// Bu yerda kod O'YLAB TOPILMAYDI. Yangi kod backendda paydo bo'lgach qo'shiladi.
library;

/// Kanonik API xato kodlari (string literal tarqatish taqiq — faqat shu const bloki).
abstract final class ApiErrorCode {
  const ApiErrorCode._();

  // --- Generic transport / request ---
  static const String validationError = 'VALIDATION_ERROR';
  static const String badRequest = 'BAD_REQUEST';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String uniqueViolation = 'UNIQUE_VIOLATION';
  static const String rateLimited = 'RATE_LIMITED';
  static const String internalError = 'INTERNAL_ERROR';
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const String payloadTooLarge = 'PAYLOAD_TOO_LARGE';
  static const String unsupportedMediaType = 'UNSUPPORTED_MEDIA_TYPE';

  // --- Auth / sessiya ---
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String accountInactive = 'ACCOUNT_INACTIVE';
  static const String accountSuspended = 'ACCOUNT_SUSPENDED';
  static const String lockedOut = 'LOCKED_OUT';
  static const String totpRequired = 'TOTP_REQUIRED';
  static const String totpInvalid = 'TOTP_INVALID';
  static const String totpSetupRequired = 'TOTP_SETUP_REQUIRED';
  static const String totpAlreadyEnabled = 'TOTP_ALREADY_ENABLED';
  static const String pinRequired = 'PIN_REQUIRED';
  static const String pinInvalid = 'PIN_INVALID';
  static const String pinNotSet = 'PIN_NOT_SET';
  static const String pinLocked = 'PIN_LOCKED';
  static const String sessionReplaced = 'SESSION_REPLACED';
  static const String sessionExpired = 'SESSION_EXPIRED';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String tokenInvalid = 'TOKEN_INVALID';
  static const String tokenRevoked = 'TOKEN_REVOKED';
  static const String tokenReused = 'TOKEN_REUSED';
  static const String invitationExpired = 'INVITATION_EXPIRED';
  static const String invitationUsed = 'INVITATION_USED';
  static const String invitationInvalid = 'INVITATION_INVALID';
  static const String deviceNotAllowed = 'DEVICE_NOT_ALLOWED';
  static const String passwordWeak = 'PASSWORD_WEAK';
  static const String passwordReused = 'PASSWORD_REUSED';

  // --- Tenancy / obuna ---
  static const String tenantMismatch = 'TENANT_MISMATCH';
  static const String subscriptionReadonly = 'SUBSCRIPTION_READONLY';
  static const String subscriptionExpired = 'SUBSCRIPTION_EXPIRED';
  static const String quotaExceeded = 'QUOTA_EXCEEDED';
  static const String featureDisabled = 'FEATURE_DISABLED';

  // --- HOS / driver logs ---
  static const String drImmutable = 'DR_IMMUTABLE';
  static const String logNotReady = 'LOG_NOT_READY';
  static const String logCertified = 'LOG_CERTIFIED';
  static const String timeInFuture = 'TIME_IN_FUTURE';
  static const String timeOutOfRange = 'TIME_OUT_OF_RANGE';
  static const String duplicateEvent = 'DUPLICATE_EVENT';
  static const String eventOutOfOrder = 'EVENT_OUT_OF_ORDER';
  static const String statusNotAllowed = 'STATUS_NOT_ALLOWED';
  static const String eventImmutable = 'EVENT_IMMUTABLE';
  static const String editNotAllowed = 'EDIT_NOT_ALLOWED';
  static const String editRejected = 'EDIT_REJECTED';
  static const String cycleNotSupported = 'CYCLE_NOT_SUPPORTED';
  static const String malfunctionActive = 'MALFUNCTION_ACTIVE';

  // --- Sync / offline ---
  static const String idempotencyConflict = 'IDEMPOTENCY_CONFLICT';
  static const String syncConflict = 'SYNC_CONFLICT';
  static const String staleVersion = 'STALE_VERSION';
  static const String batchTooLarge = 'BATCH_TOO_LARGE';

  // --- Chat ---
  static const String drivingModeBlocked = 'DRIVING_MODE_BLOCKED';
  static const String messageTooLong = 'MESSAGE_TOO_LONG';

  // --- Resurs holati ---
  static const String resourceInUse = 'RESOURCE_IN_USE';
  static const String alreadyAssigned = 'ALREADY_ASSIGNED';
  static const String notAssigned = 'NOT_ASSIGNED';
  static const String invalidState = 'INVALID_STATE';
  static const String immutable = 'IMMUTABLE';

  // --- Rollar / foydalanuvchilar ---
  static const String systemRoleImmutable = 'SYSTEM_ROLE_IMMUTABLE';
  static const String roleInUse = 'ROLE_IN_USE';
  static const String lastAdministrator = 'LAST_ADMINISTRATOR';
  static const String selfTargetForbidden = 'SELF_TARGET_FORBIDDEN';

  // --- DVIR / maintenance ---
  static const String dvirInvalidTransition = 'DVIR_INVALID_TRANSITION';
  static const String dvirNoDefects = 'DVIR_NO_DEFECTS';
  static const String dvirAdminCreateDenied = 'DVIR_ADMIN_CREATE_DENIED';
  static const String defectTypeUnknown = 'DEFECT_TYPE_UNKNOWN';
  static const String defectTypeSystemLocked = 'DEFECT_TYPE_SYSTEM_LOCKED';
  static const String maintenanceInvalidState = 'MAINTENANCE_INVALID_STATE';
  static const String maintenanceNoReading = 'MAINTENANCE_NO_READING';

  // --- Integratsiyalar ---
  static const String upstreamError = 'UPSTREAM_ERROR';
  static const String upstreamTimeout = 'UPSTREAM_TIMEOUT';
  static const String storageError = 'STORAGE_ERROR';
  static const String fileTooLarge = 'FILE_TOO_LARGE';
  static const String fileTypeInvalid = 'FILE_TYPE_INVALID';
  static const String deviceUnknown = 'DEVICE_UNKNOWN';
  static const String deviceProtocolError = 'DEVICE_PROTOCOL_ERROR';
  static const String notificationFailed = 'NOTIFICATION_FAILED';

  // --- Faqat mijoz tomonidagi sintetik kodlar (backendda YO'Q) ---
  /// Tarmoq yo'q / DNS / socket xatosi.
  static const String clientNetwork = 'CLIENT_NETWORK';

  /// Timeout (connect / send / receive).
  static const String clientTimeout = 'CLIENT_TIMEOUT';

  /// So'rov bekor qilindi.
  static const String clientCancelled = 'CLIENT_CANCELLED';

  /// Javobni parse qilib bo'lmadi / kutilmagan format.
  static const String clientUnknown = 'CLIENT_UNKNOWN';

  /// TLS / sertifikat pinning muvaffaqiyatsiz (M153, M-55).
  static const String clientTlsPinning = 'CLIENT_TLS_PINNING';

  /// Sessiyani tugatishga majbur qiladigan kodlar (M-44 «Signed out elsewhere»).
  static const Set<String> sessionTerminating = <String>{
    tokenRevoked,
    tokenReused,
    tokenInvalid,
    sessionExpired,
    sessionReplaced,
    accountInactive,
    accountSuspended,
    deviceNotAllowed,
  };

  /// Qayta urinish ma'noli bo'lgan kodlar (idempotent so'rovlar uchun).
  static const Set<String> retryable = <String>{
    rateLimited,
    serviceUnavailable,
    internalError,
    upstreamError,
    upstreamTimeout,
    storageError,
    clientNetwork,
    clientTimeout,
  };
}
