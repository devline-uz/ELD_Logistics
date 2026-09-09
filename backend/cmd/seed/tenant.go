package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/domain/company"
)

// seedAll writes the whole dataset inside the caller's transaction.
func (s *seeder) seedAll() {
	s.seedSuperAdmin()

	s.seedTenantCore(onebook)
	s.seedFleet(onebook)
	s.seedLogs(onebook)
	s.seedTracking(onebook)
	s.seedInspections(onebook)
	s.seedOps(onebook)

	s.seedTenantCore(silkroad)
	s.seedFleet(silkroad)
	s.seedLogs(silkroad)
	s.seedTracking(silkroad)
	s.seedInspections(silkroad)
	s.seedOps(silkroad)
}

// seedSuperAdmin creates the platform account (company_id IS NULL), which owns
// the /platform/companies surface and belongs to no tenant.
func (s *seeder) seedSuperAdmin() {
	if s.err != nil {
		return
	}
	var roleID uuid.UUID
	err := s.tx.QueryRow(s.ctx,
		`SELECT id FROM roles WHERE company_id IS NULL AND is_system AND lower(name) = 'administrator' AND deleted_at IS NULL`,
	).Scan(&roleID)
	if err != nil {
		s.err = fmt.Errorf("system Administrator template: %w", err)
		return
	}

	s.exec(`
		INSERT INTO users (id, company_id, branch_id, first_name, last_name, email, phone,
		                   username, password_hash, role_id, status, activated_at)
		VALUES ($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, 'active', $9)
		ON CONFLICT (id) DO UPDATE SET
		  password_hash = EXCLUDED.password_hash,
		  status        = 'active',
		  failed_logins = 0,
		  locked_until  = NULL,
		  deleted_at    = NULL`,
		sid("user", "platform", "superadmin"), "Platform", "Owner",
		"superadmin@onebook.test", "+1-312-555-0001", "superadmin",
		s.passwordHash, roleID, s.now.AddDate(0, -6, 0))
}

// seedTenantCore provisions one company the way POST /platform/companies does:
// the company row, its first HOS policy version, its branches, its copy of the
// system roles with their permissions, the A§19 notification defaults and one
// account per role.
func (s *seeder) seedTenantCore(t tenantSpec) {
	companyID := sid("company", t.Key)

	settings, err := jsonBytes(company.DefaultSettings(t.Region))
	if err != nil {
		s.err = err
		return
	}
	s.exec(`
		INSERT INTO companies (id, name, address, home_terminal_address, timezone, email, phone,
		                       registration_no, region, unit_system, regulation_profile,
		                       subscription_status, subscription_end_at, plan, settings)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15::jsonb)
		ON CONFLICT (id) DO UPDATE SET
		  name = EXCLUDED.name, address = EXCLUDED.address,
		  subscription_status = EXCLUDED.subscription_status,
		  subscription_end_at = EXCLUDED.subscription_end_at,
		  settings = EXCLUDED.settings, deleted_at = NULL`,
		companyID, t.Name, t.Address, t.HomeTerminal, t.Timezone, t.Email, t.Phone,
		t.Registration, t.Region, t.UnitSystem, t.Regulation,
		t.Subscription, s.now.AddDate(0, 0, t.SubscriptionDays), t.Plan, settings)

	s.exec(`SET LOCAL app.company_id = ` + quoteLiteral(companyID.String()))

	policy, err := company.DefaultHosPolicyJSON()
	if err != nil {
		s.err = err
		return
	}
	s.exec(`
		INSERT INTO hos_policy_versions (id, company_id, effective_from, policy)
		VALUES ($1,$2,$3,$4::jsonb)
		ON CONFLICT (id) DO UPDATE SET policy = EXCLUDED.policy, deleted_at = NULL`,
		sid("hos_policy", t.Key), companyID, s.now.AddDate(0, -6, 0), policy)

	for _, b := range t.Branches {
		s.exec(`
			INSERT INTO branches (id, company_id, name, address, timezone)
			VALUES ($1,$2,$3,$4,$5)
			ON CONFLICT (id) DO UPDATE SET
			  name = EXCLUDED.name, address = EXCLUDED.address, deleted_at = NULL`,
			sid("branch", t.Key, b.Key), companyID, b.Name, b.Address, b.Timezone)
	}

	s.seedRoles(t, companyID)
	s.seedNotificationDefaults(t, companyID)
	s.seedAccounts(t, companyID)
}

// seedRoles copies the system role templates onto the tenant, mirroring
// ProvisionCompanyRoles / ProvisionCompanyRolePermissions.
func (s *seeder) seedRoles(t tenantSpec, companyID uuid.UUID) {
	if s.err != nil {
		return
	}
	rows, err := s.tx.Query(s.ctx, `
		SELECT name, description, scope FROM roles
		WHERE company_id IS NULL AND is_system AND deleted_at IS NULL ORDER BY name`)
	if err != nil {
		s.err = fmt.Errorf("list role templates: %w", err)
		return
	}
	type tpl struct{ name, description, scope string }
	var templates []tpl
	for rows.Next() {
		var v tpl
		var desc *string
		if err := rows.Scan(&v.name, &desc, &v.scope); err != nil {
			rows.Close()
			s.err = fmt.Errorf("scan role template: %w", err)
			return
		}
		if desc != nil {
			v.description = *desc
		}
		templates = append(templates, v)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		s.err = fmt.Errorf("read role templates: %w", err)
		return
	}

	for _, v := range templates {
		roleID := roleID(t.Key, v.name)
		s.exec(`
			INSERT INTO roles (id, company_id, name, description, scope, is_system)
			VALUES ($1,$2,$3,$4,$5,false)
			ON CONFLICT (id) DO UPDATE SET
			  description = EXCLUDED.description, scope = EXCLUDED.scope, deleted_at = NULL`,
			roleID, companyID, v.name, v.description, v.scope)
		s.exec(`
			INSERT INTO role_permissions (role_id, permission_key)
			SELECT $1, rp.permission_key
			FROM roles tpl
			JOIN role_permissions rp ON rp.role_id = tpl.id
			WHERE tpl.company_id IS NULL AND tpl.is_system AND tpl.deleted_at IS NULL
			  AND lower(tpl.name) = lower($2)
			ON CONFLICT DO NOTHING`,
			roleID, v.name)
	}
}

// seedNotificationDefaults writes the TZ A§19 alert table for the tenant.
func (s *seeder) seedNotificationDefaults(t tenantSpec, companyID uuid.UUID) {
	for _, d := range company.AlertDefaults {
		recipients := make([]string, 0, len(d.RoleNames))
		for _, name := range d.RoleNames {
			recipients = append(recipients, roleID(t.Key, name).String())
		}
		s.exec(`
			INSERT INTO notification_settings (id, company_id, alert_type, channels, recipient_roles, enabled)
			VALUES ($1,$2,$3,$4::text[],$5::uuid[],true)
			ON CONFLICT (company_id, alert_type) DO UPDATE SET
			  channels = EXCLUDED.channels, recipient_roles = EXCLUDED.recipient_roles`,
			sid("notification_setting", t.Key, d.AlertType), companyID, d.AlertType,
			d.Channels, recipients)
	}
}

// seedAccounts creates the office accounts and the driver accounts with their
// drivers rows. Every account is active and shares the seed password.
func (s *seeder) seedAccounts(t tenantSpec, companyID uuid.UUID) {
	activated := s.now.AddDate(0, -5, 0)

	for _, a := range t.Accounts {
		s.exec(`
			INSERT INTO users (id, company_id, branch_id, first_name, last_name, email, phone,
			                   username, password_hash, role_id, status, invited_at, activated_at, last_login_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,'active',$11,$12,$13)
			ON CONFLICT (id) DO UPDATE SET
			  password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id,
			  branch_id = EXCLUDED.branch_id, status = 'active',
			  failed_logins = 0, locked_until = NULL, deleted_at = NULL`,
			userID(t.Key, a.Username), companyID, branchRef(t.Key, a.Branch),
			a.First, a.Last, a.Email, a.Phone, a.Username, s.passwordHash,
			roleID(t.Key, a.Role), activated.AddDate(0, 0, -7), activated, s.now.Add(-3*time.Hour))
	}

	for i, d := range t.Drivers {
		uid := userID(t.Key, d.Username)
		s.exec(`
			INSERT INTO users (id, company_id, branch_id, first_name, last_name, email, phone,
			                   username, password_hash, pin_hash, role_id, status,
			                   invited_at, activated_at, last_login_at)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,'active',$12,$13,$14)
			ON CONFLICT (id) DO UPDATE SET
			  password_hash = EXCLUDED.password_hash, pin_hash = EXCLUDED.pin_hash,
			  role_id = EXCLUDED.role_id, branch_id = EXCLUDED.branch_id, status = 'active',
			  failed_logins = 0, locked_until = NULL, deleted_at = NULL`,
			uid, companyID, branchRef(t.Key, d.Branch), d.First, d.Last, d.Email, d.Phone,
			d.Username, s.passwordHash, s.pinHash, roleID(t.Key, roleDriver),
			activated.AddDate(0, 0, -7), activated, s.now.Add(-time.Duration(i+1)*time.Hour))

		// The fleet manager of record is the first Fleet Manager account.
		var manager any
		if id, ok := accountByRole(t, roleFleetManager); ok {
			manager = userID(t.Key, id)
		}
		s.exec(`
			INSERT INTO drivers (id, company_id, user_id, branch_id, license_no_enc, license_region,
			                     home_terminal, city, state, zip, address1, notes,
			                     fleet_manager_id, status, app_version, activated_on)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,'active','1.4.2',$14)
			ON CONFLICT (id) DO UPDATE SET
			  license_no_enc = EXCLUDED.license_no_enc, branch_id = EXCLUDED.branch_id,
			  fleet_manager_id = EXCLUDED.fleet_manager_id, status = 'active', deleted_at = NULL`,
			driverID(t.Key, d.Username), companyID, uid, branchRef(t.Key, d.Branch),
			s.encrypt(d.License), d.LicenseRegion, d.HomeTerminal, d.City, d.State, d.Zip,
			d.Address1, "seeded demo driver", manager, activated)

		s.exec(`
			INSERT INTO signatures (id, company_id, user_id, image_key_enc, is_default)
			VALUES ($1,$2,$3,$4,true)
			ON CONFLICT (id) DO UPDATE SET image_key_enc = EXCLUDED.image_key_enc, deleted_at = NULL`,
			sid("signature", t.Key, d.Username), companyID, uid,
			s.encrypt(fmt.Sprintf("signatures/%s/%s.png", t.Key, d.Username)))

		s.exec(`
			INSERT INTO device_push_tokens (id, company_id, user_id, device_id, platform, token, app_version)
			VALUES ($1,$2,$3,$4,$5,$6,'1.4.2')
			ON CONFLICT (id) DO UPDATE SET token = EXCLUDED.token, deleted_at = NULL`,
			sid("push_token", t.Key, d.Username), companyID, uid,
			fmt.Sprintf("device-%s-%s", t.Key, d.Username),
			[]string{"android", "ios"}[i%2],
			fmt.Sprintf("seed-fcm-token-%s-%s", t.Key, d.Username))
	}
}

// accountByRole returns the username of the first account holding role.
func accountByRole(t tenantSpec, role string) (string, bool) {
	for _, a := range t.Accounts {
		if a.Role == role {
			return a.Username, true
		}
	}
	return "", false
}

// roleID, userID, driverID and branchRef are the stable id helpers the rest of
// the seed addresses rows by.
func roleID(tenantKey, name string) uuid.UUID {
	return sid("role", tenantKey, strings.ToLower(name))
}

func userID(tenantKey, username string) uuid.UUID {
	return sid("user", tenantKey, username)
}

func driverID(tenantKey, username string) uuid.UUID {
	return sid("driver", tenantKey, username)
}

func unitID(tenantKey, number string) uuid.UUID {
	return sid("unit", tenantKey, number)
}

// branchRef returns nil for an account that is not bound to one terminal, so
// the column stays NULL rather than pointing at a missing branch.
func branchRef(tenantKey, branchKey string) any {
	if branchKey == "" {
		return nil
	}
	return sid("branch", tenantKey, branchKey)
}
