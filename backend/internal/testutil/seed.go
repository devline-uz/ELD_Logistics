package testutil

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/tenant"
)

// Tenant is a fully populated company: everything a cross-tenant or permission
// test normally needs, seeded in one call.
type Tenant struct {
	Company Company
	Branch  Branch
	Role    Role
	User    User
	Driver  Driver
	Unit    Unit
	Device  EldDevice
	Trailer Trailer
	Doc     ShippingDocument
	Log     DailyLog
	Event   DutyStatusEvent
	Dvir    DvirReport
}

// ID is a shorthand for the company id.
func (tn *Tenant) ID() uuid.UUID { return tn.Company.ID }

// Principal builds the context principal for this tenant's user.
func (tn *Tenant) Principal() *tenant.Principal {
	companyID := tn.Company.ID
	return &tenant.Principal{
		UserID:      tn.User.ID,
		CompanyID:   &companyID,
		RoleID:      tn.Role.ID,
		Scope:       tenant.ScopeAll,
		SessionID:   uuid.New(),
		DeviceType:  tenant.DeviceWeb,
		Permissions: append([]string(nil), tn.Role.Permissions...),
	}
}

// DriverPrincipal builds a self scoped principal for this tenant's driver user.
func (tn *Tenant) DriverPrincipal(permissions ...string) *tenant.Principal {
	p := tn.Principal()
	p.UserID = tn.Driver.UserID
	p.Scope = tenant.ScopeSelf
	p.DeviceType = tenant.DevicePhone
	if len(permissions) > 0 {
		p.Permissions = permissions
	}
	return p
}

// SeedTenant creates one complete company. permissions are attached to the
// tenant's role.
func SeedTenant(t testing.TB, permissions ...string) *Tenant {
	t.Helper()

	c := NewCompany(t)
	b := NewBranch(t, c.ID)
	role := NewRole(t, c.ID, permissions)
	u := NewUser(t, c.ID, WithRole(role), WithBranch(b))
	driverUser := NewUser(t, c.ID, WithRole(role))
	d := NewDriver(t, c.ID, WithUser(driverUser))
	unit := NewUnit(t, c.ID)
	dev := NewEldDevice(t, c.ID, WithUnit(unit))
	trl := NewTrailer(t, c.ID)
	doc := NewShippingDocument(t, c.ID)
	log := NewDailyLog(t, c.ID, WithDriver(d))
	ev := NewDutyStatusEvent(t, c.ID, WithDriver(d), WithUnit(unit),
		WithEventTime(time.Now().UTC().Add(-time.Hour)))
	dvir := NewDvirReport(t, c.ID, WithUnit(unit), WithDriver(d))

	return &Tenant{
		Company: c, Branch: b, Role: role, User: u, Driver: d,
		Unit: unit, Device: dev, Trailer: trl, Doc: doc,
		Log: log, Event: ev, Dvir: dvir,
	}
}

// SeedTwoCompanies creates two independent, fully populated tenants for
// cross-tenant isolation tests.
func SeedTwoCompanies(t testing.TB, permissions ...string) (a, b *Tenant) {
	t.Helper()
	return SeedTenant(t, permissions...), SeedTenant(t, permissions...)
}

// PermissionKeys returns the full RBAC permission list seeded by
// 00012_seed.sql, for permission matrix tests.
func PermissionKeys(t testing.TB) []string {
	t.Helper()
	var keys []string
	err := AdminPool(t).QueryRow(Ctx(t),
		`SELECT value FROM system_settings WHERE key = 'permission_keys'`).Scan(&keys)
	require.NoError(t, err, "read permission_keys")
	return keys
}
