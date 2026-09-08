package users

import (
	"net/http"
	"sort"
	"strings"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/users/dto"
)

// moduleLabels maps a permission key prefix onto its display name. The keys are
// derived from core.AllPermissions, which stays the single source of truth.
var moduleLabels = map[string]string{
	"company":               "Company",
	"branches":              "Branches",
	"hos_policy":            "HOS policy",
	"notification_settings": "Notification settings",
	"users":                 "Users",
	"roles":                 "Roles",
	"permissions":           "Permissions",
	"units":                 "Units",
	"drivers":               "Drivers",
	"eld_devices":           "ELD devices",
	"trailers":              "Trailers",
	"shipping_documents":    "Shipping documents",
	"logs":                  "Logs and HOS",
	"inspection":            "Roadside inspection",
	"violations":            "Violations",
	"tracking":              "Tracking",
	"trips":                 "Trips",
	"routes":                "Routes",
	"dvir":                  "DVIR",
	"defect_types":          "Defect types",
	"maintenance":           "Maintenance",
	"reports":               "Reports",
	"dashboard":             "Dashboard",
	"notifications":         "Notifications",
	"chat":                  "Chat",
	"support":               "Support",
	"feedback":              "Feedback",
	"files":                 "Files",
	"audit":                 "Audit log",
}

// permissionDescriptions documents every key of core.AllPermissions.
var permissionDescriptions = map[string]string{
	core.PermCompanyRead:        "View the company profile",
	core.PermCompanyUpdate:      "Update the company profile",
	core.PermCompanyHistoryView: "View the company change history",
	core.PermBranchesRead:       "View branches",
	core.PermBranchesCreate:     "Create branches",
	core.PermBranchesUpdate:     "Update branches",
	core.PermBranchesDelete:     "Delete branches",
	core.PermHosPolicyRead:      "View the HOS policy",
	core.PermHosPolicyUpdate:    "Change the HOS policy",
	core.PermNotifSettingsRead:  "View notification settings",
	core.PermNotifSettingsWrite: "Change notification settings",

	core.PermUsersRead:          "View users",
	core.PermUsersCreate:        "Invite new users",
	core.PermUsersUpdate:        "Update users, including activate and deactivate",
	core.PermUsersDelete:        "Delete users",
	core.PermUsersInvite:        "Resend an invitation link",
	core.PermUsersResetPassword: "Send a password reset link",
	core.PermRolesRead:          "View roles",
	core.PermRolesCreate:        "Create roles",
	core.PermRolesUpdate:        "Update roles and their permissions",
	core.PermRolesDelete:        "Delete roles",
	core.PermPermissionsRead:    "View the permission catalogue",

	core.PermUnitsRead:         "View units",
	core.PermUnitsCreate:       "Create units",
	core.PermUnitsUpdate:       "Update units",
	core.PermUnitsDelete:       "Delete units",
	core.PermUnitsActivate:     "Activate units",
	core.PermUnitsDeactivate:   "Deactivate units",
	core.PermUnitsAssignDriver: "Assign a driver to a unit",
	core.PermUnitsImport:       "Import units",
	core.PermUnitsExport:       "Export units",
	core.PermUnitsDiagnostics:  "View unit diagnostics",

	core.PermDriversRead:            "View drivers",
	core.PermDriversCreate:          "Create drivers",
	core.PermDriversUpdate:          "Update drivers",
	core.PermDriversDelete:          "Delete drivers",
	core.PermDriversActivate:        "Activate drivers",
	core.PermDriversDeactivate:      "Deactivate drivers",
	core.PermDriversImport:          "Import drivers",
	core.PermDriversExport:          "Export drivers",
	core.PermDriversManageCoDrivers: "Manage co-driver pairs",
	core.PermDriversResetPassword:   "Send a driver a password reset link",
	core.PermDriversLicenseView:     "Reveal a driver licence number in clear text",

	core.PermELDDevicesRead:       "View ELD devices",
	core.PermELDDevicesCreate:     "Register ELD devices",
	core.PermELDDevicesUpdate:     "Update ELD devices",
	core.PermELDDevicesDelete:     "Delete ELD devices",
	core.PermELDDevicesAssignUnit: "Assign an ELD device to a unit",

	core.PermTrailersRead:   "View trailers",
	core.PermTrailersCreate: "Create trailers",
	core.PermTrailersUpdate: "Update trailers",
	core.PermTrailersDelete: "Delete trailers",

	core.PermShippingDocsRead:   "View shipping documents",
	core.PermShippingDocsCreate: "Create shipping documents",
	core.PermShippingDocsUpdate: "Update shipping documents",
	core.PermShippingDocsDelete: "Delete shipping documents",

	core.PermLogsRead:                "View daily logs and duty status events",
	core.PermLogsCertify:             "Certify a daily log",
	core.PermLogsProposeEdit:         "Propose a log edit",
	core.PermLogsApproveEdit:         "Approve a log edit request",
	core.PermLogsRejectEdit:          "Reject a log edit request",
	core.PermLogsAddEvent:            "Add a duty status event",
	core.PermLogsExport:              "Export logs",
	core.PermLogsAssignUnidentified:  "Assign an unidentified driving event",
	core.PermLogsAnnotateUnidentifed: "Annotate an unidentified driving event",
	core.PermLogsClaimUnidentified:   "Claim an unidentified driving event",

	core.PermInspectionView:     "Open the roadside inspection view",
	core.PermInspectionEmail:    "Email an inspection report",
	core.PermInspectionTransfer: "Transfer logs to a safety official",

	core.PermViolationsRead: "View HOS violations",

	core.PermTrackingViewLive:    "View the live tracking map",
	core.PermTrackingViewHistory: "View trip history and trip detail",
	core.PermRoutesRead:          "View routes",
	core.PermRoutesCreate:        "Create routes",
	core.PermRoutesUpdate:        "Update routes",
	core.PermRoutesDelete:        "Delete routes",
	core.PermRoutesComplete:      "Complete or close a route",

	core.PermDVIRRead:          "View DVIR reports",
	core.PermDVIRCreate:        "Create a DVIR report",
	core.PermDVIRRepair:        "Record a DVIR repair",
	core.PermDVIRCertify:       "Certify a DVIR report",
	core.PermDVIRExport:        "Export DVIR reports",
	core.PermDefectTypesRead:   "View defect types",
	core.PermDefectTypesCreate: "Create defect types",
	core.PermDefectTypesUpdate: "Update defect types",
	core.PermMaintenanceRead:   "View maintenance schedules and records",
	core.PermMaintenanceCreate: "Create maintenance schedules",
	core.PermMaintenanceUpdate: "Update maintenance schedules",
	core.PermMaintenanceDelete: "Delete maintenance schedules",
	core.PermMaintenanceDone:   "Complete a maintenance task",
	core.PermMaintenanceCancel: "Cancel a maintenance task",

	core.PermReportsRead:         "View reports",
	core.PermReportsExport:       "Export reports",
	core.PermDashboardRead:       "View the dashboard",
	core.PermNotificationsRead:   "View notifications",
	core.PermChatRead:            "Read chat threads",
	core.PermChatSend:            "Send chat messages",
	core.PermSupportRead:         "View support tickets",
	core.PermSupportCreate:       "Create support tickets",
	core.PermSupportUpdateStatus: "Move a support ticket along new \u2192 in_progress \u2192 resolved",
	core.PermFeedbackRead:        "View feedback",
	core.PermFeedbackCreate:      "Send feedback",
	core.PermFilesUpload:         "Upload files",
	core.PermAuditView:           "View the audit log",
}

// auditCriticalModules never expose a delete permission (TZ Q82.2): their
// records are the evidence trail and are append only.
var auditCriticalModules = map[string]struct{}{
	"logs":       {},
	"dvir":       {},
	"violations": {},
	"telemetry":  {},
	"audit_log":  {},
	"audit":      {},
}

// permissionCatalogue builds the grouped catalogue once, in the order of
// core.AllPermissions.
func permissionCatalogue() []dto.PermissionModule {
	modules := make([]dto.PermissionModule, 0, len(moduleLabels))
	index := make(map[string]int, len(moduleLabels))

	for _, key := range core.AllPermissions {
		module := moduleOf(key)
		pos, ok := index[module]
		if !ok {
			label := moduleLabels[module]
			if label == "" {
				label = module
			}
			modules = append(modules, dto.PermissionModule{Module: module, Label: label})
			pos = len(modules) - 1
			index[module] = pos
		}
		modules[pos].Permissions = append(modules[pos].Permissions, dto.Permission{
			Key:         key,
			Description: describe(key),
		})
	}
	return modules
}

// describe falls back to a generated sentence so a key added to the catalogue
// without a description still ships something readable.
func describe(key string) string {
	if v := permissionDescriptions[key]; v != "" {
		return v
	}
	label := moduleLabels[moduleOf(key)]
	if label == "" {
		label = moduleOf(key)
	}
	return strings.ReplaceAll(actionOf(key), "_", " ") + " " + strings.ToLower(label)
}

// moduleOf returns the module prefix of a permission key.
func moduleOf(key string) string {
	if i := strings.IndexByte(key, '.'); i > 0 {
		return key[:i]
	}
	return key
}

// actionOf returns the trailing action of a permission key.
func actionOf(key string) string {
	if i := strings.LastIndexByte(key, '.'); i >= 0 && i+1 < len(key) {
		return key[i+1:]
	}
	return ""
}

// validatePermissions rejects unknown keys and, explicitly, any delete
// permission in an audit critical module (TZ Q82.2). It returns the
// deduplicated, sorted set that will be written to role_permissions.
func validatePermissions(keys []string) ([]string, error) {
	details := make([]apierr.FieldError, 0, 4)
	seen := make(map[string]struct{}, len(keys))
	out := make([]string, 0, len(keys))

	for _, raw := range keys {
		key := strings.TrimSpace(raw)
		if key == "" {
			details = append(details, apierr.FieldError{Field: "permissions", Message: "must not be empty"})
			continue
		}
		if _, dup := seen[key]; dup {
			continue
		}
		seen[key] = struct{}{}

		if _, critical := auditCriticalModules[moduleOf(key)]; critical && actionOf(key) == "delete" {
			details = append(details, apierr.FieldError{
				Field:   "permissions",
				Message: key + " does not exist: audit critical modules have no delete permission",
			})
			continue
		}
		if !core.IsValidPermission(key) {
			details = append(details, apierr.FieldError{
				Field:   "permissions",
				Message: "unknown permission key: " + key,
			})
			continue
		}
		out = append(out, key)
	}

	if len(details) > 0 {
		return nil, apierr.Validation("unknown permission key", details...)
	}
	if len(out) == 0 {
		return nil, apierr.Validation("validation failed", apierr.FieldError{
			Field: "permissions", Message: "at least one permission is required",
		})
	}
	sort.Strings(out)
	return out, nil
}

// errSystemRoleImmutable is returned for any write against a system role.
func errSystemRoleImmutable() error {
	return apierr.New(apierr.CodeSystemRoleImmutable, http.StatusForbidden,
		"system roles cannot be modified or deleted")
}
