// Package apierr defines the single source of truth for API error codes and
// the transport agnostic error type carried across all layers.
package apierr

// Canonical API error codes. Every error returned to a client MUST use one of
// these codes; add new codes to this block only.
const (
	// Generic transport / request errors.
	CodeValidationError = "VALIDATION_ERROR"
	CodeBadRequest      = "BAD_REQUEST"
	CodeUnauthorized    = "UNAUTHORIZED"
	CodeForbidden       = "FORBIDDEN"
	CodeNotFound        = "NOT_FOUND"
	CodeConflict        = "CONFLICT"
	CodeUniqueViolation = "UNIQUE_VIOLATION"
	CodeRateLimited     = "RATE_LIMITED"
	CodeInternal        = "INTERNAL_ERROR"
	CodeUnavailable     = "SERVICE_UNAVAILABLE"
	CodePayloadTooLarge = "PAYLOAD_TOO_LARGE"
	CodeUnsupportedType = "UNSUPPORTED_MEDIA_TYPE"

	// Authentication / session.
	CodeInvalidCredentials = "INVALID_CREDENTIALS" //nolint:gosec // G101: error code label, not a credential value
	CodeAccountInactive    = "ACCOUNT_INACTIVE"
	CodeAccountSuspended   = "ACCOUNT_SUSPENDED"
	CodeLockedOut          = "LOCKED_OUT"
	CodeTOTPRequired       = "TOTP_REQUIRED"
	CodeTOTPInvalid        = "TOTP_INVALID"
	CodeTOTPSetupRequired  = "TOTP_SETUP_REQUIRED"
	CodeTOTPAlreadySetUp   = "TOTP_ALREADY_ENABLED"
	CodePINRequired        = "PIN_REQUIRED"
	CodePINInvalid         = "PIN_INVALID"
	CodePINNotSet          = "PIN_NOT_SET"
	CodePINLocked          = "PIN_LOCKED"
	CodeSessionReplaced    = "SESSION_REPLACED"
	CodeSessionExpired     = "SESSION_EXPIRED"
	CodeTokenExpired       = "TOKEN_EXPIRED"
	CodeTokenInvalid       = "TOKEN_INVALID"
	CodeTokenRevoked       = "TOKEN_REVOKED"
	CodeTokenReused        = "TOKEN_REUSED"
	CodeInvitationExpired  = "INVITATION_EXPIRED"
	CodeInvitationUsed     = "INVITATION_USED"
	CodeInvitationInvalid  = "INVITATION_INVALID"
	CodeDeviceNotAllowed   = "DEVICE_NOT_ALLOWED"
	CodePasswordWeak       = "PASSWORD_WEAK"
	CodePasswordReused     = "PASSWORD_REUSED"

	// Tenancy / subscription.
	CodeTenantMismatch       = "TENANT_MISMATCH"
	CodeSubscriptionReadonly = "SUBSCRIPTION_READONLY"
	CodeSubscriptionExpired  = "SUBSCRIPTION_EXPIRED"
	CodeQuotaExceeded        = "QUOTA_EXCEEDED"
	CodeFeatureDisabled      = "FEATURE_DISABLED"

	// HOS / driver logs domain.
	CodeDRImmutable       = "DR_IMMUTABLE"
	CodeLogNotReady       = "LOG_NOT_READY"
	CodeLogCertified      = "LOG_CERTIFIED"
	CodeTimeInFuture      = "TIME_IN_FUTURE"
	CodeTimeOutOfRange    = "TIME_OUT_OF_RANGE"
	CodeDuplicateEvent    = "DUPLICATE_EVENT"
	CodeEventOutOfOrder   = "EVENT_OUT_OF_ORDER"
	CodeStatusNotAllowed  = "STATUS_NOT_ALLOWED"
	CodeEventImmutable    = "EVENT_IMMUTABLE"
	CodeEditNotAllowed    = "EDIT_NOT_ALLOWED"
	CodeEditRejected      = "EDIT_REJECTED"
	CodeCycleNotSupported = "CYCLE_NOT_SUPPORTED"
	CodeMalfunctionActive = "MALFUNCTION_ACTIVE"

	// Sync / offline.
	CodeIdempotencyConflict = "IDEMPOTENCY_CONFLICT"
	CodeSyncConflict        = "SYNC_CONFLICT"
	CodeStaleVersion        = "STALE_VERSION"
	CodeBatchTooLarge       = "BATCH_TOO_LARGE"

	// Chat (TZ §15.4).
	// CodeDrivingModeBlocked rejects a driver message written while the driver
	// is in DR: the distraction policy blocks chat during driving.
	CodeDrivingModeBlocked = "DRIVING_MODE_BLOCKED"
	// CodeMessageTooLong rejects a chat message over the 2000 character limit.
	CodeMessageTooLong = "MESSAGE_TOO_LONG"

	// Resource state.
	CodeInUse           = "RESOURCE_IN_USE"
	CodeAlreadyAssigned = "ALREADY_ASSIGNED"
	CodeNotAssigned     = "NOT_ASSIGNED"
	CodeInvalidState    = "INVALID_STATE"
	CodeImmutable       = "IMMUTABLE"

	// Users, roles and permissions (TZ A§16).
	CodeSystemRoleImmutable = "SYSTEM_ROLE_IMMUTABLE"
	CodeRoleInUse           = "ROLE_IN_USE"
	CodeLastAdministrator   = "LAST_ADMINISTRATOR"
	CodeSelfTargetForbidden = "SELF_TARGET_FORBIDDEN"

	// DVIR and maintenance (TZ §7, §8).
	CodeDVIRInvalidTransition   = "DVIR_INVALID_TRANSITION"
	CodeDVIRNoDefects           = "DVIR_NO_DEFECTS"
	CodeDVIRAdminCreateDenied   = "DVIR_ADMIN_CREATE_DENIED"
	CodeDefectTypeUnknown       = "DEFECT_TYPE_UNKNOWN"
	CodeDefectTypeSystemLocked  = "DEFECT_TYPE_SYSTEM_LOCKED"
	CodeMaintenanceInvalidState = "MAINTENANCE_INVALID_STATE"
	CodeMaintenanceNoReading    = "MAINTENANCE_NO_READING"

	// Integrations.
	CodeUpstreamError    = "UPSTREAM_ERROR"
	CodeUpstreamTimeout  = "UPSTREAM_TIMEOUT"
	CodeStorageError     = "STORAGE_ERROR"
	CodeFileTooLarge     = "FILE_TOO_LARGE"
	CodeFileTypeInvalid  = "FILE_TYPE_INVALID"
	CodeDeviceUnknown    = "DEVICE_UNKNOWN"
	CodeDeviceProtocol   = "DEVICE_PROTOCOL_ERROR"
	CodeNotificationFail = "NOTIFICATION_FAILED"
)
