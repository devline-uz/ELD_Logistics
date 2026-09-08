// Package auth implements the security core: password hashing, access token
// issuing and verification, refresh token rotation, session policy, TOTP, PIN
// and the role permission cache. It owns no SQL; persistence lives in
// internal/domain/auth.
package auth

// Permission keys (TZ A§16 Q82). This block is the single source of truth; the
// seed migration mirrors it into system_settings.permission_keys for
// GET /permissions.
const (
	// Company and organisation.
	PermCompanyRead        = "company.read"
	PermCompanyUpdate      = "company.update"
	PermCompanyHistoryView = "company.history.view"
	PermBranchesRead       = "branches.read"
	PermBranchesCreate     = "branches.create"
	PermBranchesUpdate     = "branches.update"
	PermBranchesDelete     = "branches.delete"
	PermHosPolicyRead      = "hos_policy.read"
	PermHosPolicyUpdate    = "hos_policy.update"
	PermNotifSettingsRead  = "notification_settings.read"
	PermNotifSettingsWrite = "notification_settings.update"

	// Users, roles, permissions.
	PermUsersRead          = "users.read"
	PermUsersCreate        = "users.create"
	PermUsersUpdate        = "users.update"
	PermUsersDelete        = "users.delete"
	PermUsersInvite        = "users.invite"
	PermUsersResetPassword = "users.reset_password"
	PermRolesRead          = "roles.read"
	PermRolesCreate        = "roles.create"
	PermRolesUpdate        = "roles.update"
	PermRolesDelete        = "roles.delete"
	PermPermissionsRead    = "permissions.read"

	// Fleet.
	PermUnitsRead         = "units.read"
	PermUnitsCreate       = "units.create"
	PermUnitsUpdate       = "units.update"
	PermUnitsDelete       = "units.delete"
	PermUnitsActivate     = "units.activate"
	PermUnitsDeactivate   = "units.deactivate"
	PermUnitsAssignDriver = "units.assign_driver"
	PermUnitsImport       = "units.import"
	PermUnitsExport       = "units.export"
	PermUnitsDiagnostics  = "units.diagnostics"

	PermDriversRead            = "drivers.read"
	PermDriversCreate          = "drivers.create"
	PermDriversUpdate          = "drivers.update"
	PermDriversDelete          = "drivers.delete"
	PermDriversActivate        = "drivers.activate"
	PermDriversDeactivate      = "drivers.deactivate"
	PermDriversImport          = "drivers.import"
	PermDriversExport          = "drivers.export"
	PermDriversManageCoDrivers = "drivers.manage_co_drivers"
	PermDriversResetPassword   = "drivers.reset_password"
	// PermDriversLicenseView gates the clear text licence number. It is a key
	// of its own so revealing PII is not implied by "may edit a driver".
	PermDriversLicenseView = "drivers.license.view"

	PermELDDevicesRead       = "eld_devices.read"
	PermELDDevicesCreate     = "eld_devices.create"
	PermELDDevicesUpdate     = "eld_devices.update"
	PermELDDevicesDelete     = "eld_devices.delete"
	PermELDDevicesAssignUnit = "eld_devices.assign_unit"

	PermTrailersRead   = "trailers.read"
	PermTrailersCreate = "trailers.create"
	PermTrailersUpdate = "trailers.update"
	PermTrailersDelete = "trailers.delete"

	PermShippingDocsRead   = "shipping_documents.read"
	PermShippingDocsCreate = "shipping_documents.create"
	PermShippingDocsUpdate = "shipping_documents.update"
	PermShippingDocsDelete = "shipping_documents.delete"

	// Logs and HOS. Q82.2: no delete permission in audit critical modules.
	PermLogsRead                = "logs.read"
	PermLogsCertify             = "logs.certify"
	PermLogsProposeEdit         = "logs.propose_edit"
	PermLogsApproveEdit         = "logs.approve_edit"
	PermLogsRejectEdit          = "logs.reject_edit"
	PermLogsAddEvent            = "logs.add_event"
	PermLogsExport              = "logs.export"
	PermLogsAssignUnidentified  = "logs.assign_unidentified"
	PermLogsAnnotateUnidentifed = "logs.annotate_unidentified"
	PermLogsClaimUnidentified   = "logs.claim_unidentified"

	PermInspectionView     = "inspection.view"
	PermInspectionEmail    = "inspection.email"
	PermInspectionTransfer = "inspection.transfer"

	PermViolationsRead = "violations.read"

	// Tracking and routes.
	// TZ QISM D §3 Tracking guruhi: GET /tracking/live va GET /units/{id}/trips,
	// GET /trips/{id} aynan shu kalitlar bilan qo'riqlanadi.
	PermTrackingViewLive    = "tracking.view_live"
	PermTrackingViewHistory = "tracking.view_history"
	PermRoutesRead          = "routes.read"
	PermRoutesCreate        = "routes.create"
	PermRoutesUpdate        = "routes.update"
	PermRoutesDelete        = "routes.delete"
	PermRoutesComplete      = "routes.complete"

	// DVIR and maintenance.
	PermDVIRRead          = "dvir.read"
	PermDVIRCreate        = "dvir.create"
	PermDVIRRepair        = "dvir.repair"
	PermDVIRCertify       = "dvir.certify"
	PermDVIRExport        = "dvir.export"
	PermDefectTypesRead   = "defect_types.read"
	PermDefectTypesCreate = "defect_types.create"
	PermDefectTypesUpdate = "defect_types.update"
	PermMaintenanceRead   = "maintenance.read"
	PermMaintenanceCreate = "maintenance.create"
	PermMaintenanceUpdate = "maintenance.update"
	PermMaintenanceDelete = "maintenance.delete"
	PermMaintenanceDone   = "maintenance.complete"
	PermMaintenanceCancel = "maintenance.cancel"

	// Reporting and platform surfaces.
	PermReportsRead       = "reports.read"
	PermReportsExport     = "reports.export"
	PermDashboardRead     = "dashboard.read"
	PermNotificationsRead = "notifications.read"
	PermChatRead          = "chat.read"
	PermChatSend          = "chat.send"
	PermSupportRead       = "support.read"
	PermSupportCreate     = "support.create"
	// PermSupportUpdateStatus gates the `new → in_progress → resolved` transition.
	PermSupportUpdateStatus = "support.update_status"
	PermFeedbackRead        = "feedback.read"
	PermFeedbackCreate      = "feedback.create"
	PermFilesUpload         = "files.upload"
	PermAuditView           = "audit.view"
)

// AllPermissions is the complete, ordered permission catalogue.
var AllPermissions = []string{
	PermCompanyRead, PermCompanyUpdate, PermCompanyHistoryView,
	PermBranchesRead, PermBranchesCreate, PermBranchesUpdate, PermBranchesDelete,
	PermHosPolicyRead, PermHosPolicyUpdate,
	PermNotifSettingsRead, PermNotifSettingsWrite,
	PermUsersRead, PermUsersCreate, PermUsersUpdate, PermUsersDelete, PermUsersInvite, PermUsersResetPassword,
	PermRolesRead, PermRolesCreate, PermRolesUpdate, PermRolesDelete, PermPermissionsRead,
	PermUnitsRead, PermUnitsCreate, PermUnitsUpdate, PermUnitsDelete, PermUnitsActivate, PermUnitsDeactivate,
	PermUnitsAssignDriver, PermUnitsImport, PermUnitsExport, PermUnitsDiagnostics,
	PermDriversRead, PermDriversCreate, PermDriversUpdate, PermDriversDelete, PermDriversActivate,
	PermDriversDeactivate, PermDriversImport, PermDriversExport, PermDriversManageCoDrivers,
	PermDriversResetPassword, PermDriversLicenseView,
	PermELDDevicesRead, PermELDDevicesCreate, PermELDDevicesUpdate, PermELDDevicesDelete, PermELDDevicesAssignUnit,
	PermTrailersRead, PermTrailersCreate, PermTrailersUpdate, PermTrailersDelete,
	PermShippingDocsRead, PermShippingDocsCreate, PermShippingDocsUpdate, PermShippingDocsDelete,
	PermLogsRead, PermLogsCertify, PermLogsProposeEdit, PermLogsApproveEdit, PermLogsRejectEdit,
	PermLogsAddEvent, PermLogsExport, PermLogsAssignUnidentified, PermLogsAnnotateUnidentifed, PermLogsClaimUnidentified,
	PermInspectionView, PermInspectionEmail, PermInspectionTransfer,
	PermViolationsRead,
	PermTrackingViewLive, PermTrackingViewHistory,
	PermRoutesRead, PermRoutesCreate, PermRoutesUpdate, PermRoutesDelete, PermRoutesComplete,
	PermDVIRRead, PermDVIRCreate, PermDVIRRepair, PermDVIRCertify, PermDVIRExport,
	PermDefectTypesRead, PermDefectTypesCreate, PermDefectTypesUpdate,
	PermMaintenanceRead, PermMaintenanceCreate, PermMaintenanceUpdate, PermMaintenanceDelete,
	PermMaintenanceDone, PermMaintenanceCancel,
	PermReportsRead, PermReportsExport,
	PermDashboardRead, PermNotificationsRead,
	PermChatRead, PermChatSend,
	PermSupportRead, PermSupportCreate, PermSupportUpdateStatus,
	PermFeedbackRead, PermFeedbackCreate,
	PermFilesUpload, PermAuditView,
}

var permissionSet = func() map[string]struct{} {
	m := make(map[string]struct{}, len(AllPermissions))
	for _, p := range AllPermissions {
		m[p] = struct{}{}
	}
	return m
}()

// IsValidPermission reports whether key belongs to the catalogue. Role editors
// MUST reject anything else so unknown keys can never widen access.
func IsValidPermission(key string) bool {
	_, ok := permissionSet[key]
	return ok
}

// FilterKnown drops unknown keys from a candidate permission list.
func FilterKnown(keys []string) []string {
	out := make([]string, 0, len(keys))
	seen := make(map[string]struct{}, len(keys))
	for _, k := range keys {
		if !IsValidPermission(k) {
			continue
		}
		if _, dup := seen[k]; dup {
			continue
		}
		seen[k] = struct{}{}
		out = append(out, k)
	}
	return out
}
