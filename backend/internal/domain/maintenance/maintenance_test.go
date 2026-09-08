//go:build integration

// Integration coverage of the maintenance module: the Q33 next_due_value /
// remaining arithmetic against live telemetry, the Q34 overdue flag, the Q42.1
// completion re-base, the Q43 financial-free cancellation, the Q37/Q38
// fire-once reminder and cross-tenant isolation (404, never 403).
package maintenance_test

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/maintenance"
	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
	"github.com/devline/onebook-eld/internal/testutil"
)

// allMaintenancePerms is every permission the module gates on.
var allMaintenancePerms = []string{
	core.PermMaintenanceRead, core.PermMaintenanceCreate, core.PermMaintenanceUpdate,
	core.PermMaintenanceDelete, core.PermMaintenanceDone, core.PermMaintenanceCancel,
}

var now = time.Date(2026, 9, 6, 12, 0, 0, 0, time.UTC)

type harness struct {
	srv     *testutil.TestServer
	svc     *maintenance.Service
	alerter *recordingAlerter
}

func newHarness(t testing.TB) *harness {
	t.Helper()
	pool := testutil.NewDB(t)
	rec := &recordingAlerter{}
	mod := maintenance.New(maintenance.Deps{
		Repo:     maintenance.NewRepo(pool, audit.NewPgRecorder(pool, testutil.Logger())),
		Verifier: testutil.ContextVerifier(),
		Alerter:  rec,
		Log:      testutil.Logger(),
		Now:      func() time.Time { return now },
	})
	return &harness{srv: testutil.NewServer(t, mod), svc: mod.Service(), alerter: rec}
}

func (h *harness) client(tn *testutil.Tenant) *testutil.TestServer { return h.srv.AsTenant(tn) }

// seedLastState writes the telemetry snapshot the due list reads (Q33).
func seedLastState(t testing.TB, companyID, unitID uuid.UUID, odometerM int64, engineHours float64) {
	t.Helper()
	_, err := testutil.AdminPool(t).Exec(testutil.Ctx(t),
		`INSERT INTO unit_last_state (unit_id, company_id, ts, odometer_m, engine_hours, online_status)
		 VALUES ($1,$2,$3,$4,$5,'online')
		 ON CONFLICT (unit_id) DO UPDATE
		   SET odometer_m = EXCLUDED.odometer_m, engine_hours = EXCLUDED.engine_hours, ts = EXCLUDED.ts`,
		unitID, companyID, now.Add(-time.Minute), odometerM, engineHours)
	require.NoError(t, err, "seed unit_last_state")
}

func decodeSchedule(t testing.TB, resp *testutil.Response) dto.Schedule {
	t.Helper()
	var env struct {
		Data dto.Schedule `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeUnit(t testing.TB, resp *testutil.Response) dto.ScheduleUnit {
	t.Helper()
	var env struct {
		Data dto.ScheduleUnit `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeUnits(t testing.TB, resp *testutil.Response) []dto.ScheduleUnit {
	t.Helper()
	var env struct {
		Data []dto.ScheduleUnit `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

func decodeRecords(t testing.TB, resp *testutil.Response) []dto.Record {
	t.Helper()
	var env struct {
		Data []dto.Record `json:"data"`
	}
	resp.JSON(&env)
	return env.Data
}

// createSchedule files a km based plan covering the tenant unit.
func createSchedule(t testing.TB, h *harness, tn *testutil.Tenant, in dto.ScheduleCreate) dto.Schedule {
	t.Helper()
	if in.Name == "" {
		in.Name = "Plan " + uuid.NewString()[:8]
	}
	resp := h.client(tn).Post("/api/v1/maintenance-schedules", in)
	testutil.RequireStatus(t, resp, http.StatusCreated)
	return decodeSchedule(t, resp)
}

// dueRow reads the single progress row of a schedule.
// invoiceKey builds an object key of this tenant; a key of another company is
// refused by the service.
func invoiceKey(tn *testutil.Tenant) string {
	return storage.BuildKey(tn.ID(), "invoice", "inv.pdf", now)
}

func dueRow(t testing.TB, h *harness, tn *testutil.Tenant, scheduleID string) dto.ScheduleUnit {
	t.Helper()
	rows := decodeUnits(t, mustOK(t, h.client(tn).Get("/api/v1/maintenance/due",
		testutil.Query("schedule_id", scheduleID))))
	require.Len(t, rows, 1)
	return rows[0]
}

// ---------------------------------------------------------------- Q33 arithmetic

func TestDueListComputesRemainingFromTelemetry(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	// 103 430 km on the clock at the last service, 127 100 km now.
	seedLastState(t, tn.ID(), tn.Unit.ID, 127_100_000, 1234.5)

	last := 103430.0
	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm, ReminderBeforeValue: 1000,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})
	require.EqualValues(t, 1, sched.UnitCount)

	row := dueRow(t, h, tn, sched.ID)
	require.Equal(t, tn.Unit.ID.String(), row.UnitID)
	require.InDelta(t, 103430, *row.LastServiceValue, 0.01)
	require.InDelta(t, 127100, *row.CurrentValue, 0.01) // odometer_m / 1000
	require.InDelta(t, 128430, *row.NextDueValue, 0.01) // last + interval
	require.InDelta(t, 1330, *row.Remaining, 0.01)      // next_due - current
	require.False(t, row.Overdue)
	require.False(t, row.ReminderDue) // 1330 km left, reminder fires at 1000
	require.EqualValues(t, 127_100_000, *row.OdometerM)
}

func TestRemainingGoesNegativeAndFlagsOverdue(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 130_000_000, 1300)

	last := 103430.0
	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})

	row := dueRow(t, h, tn, sched.ID)
	require.InDelta(t, -1570, *row.Remaining, 0.01)
	require.True(t, row.Overdue, "Q34 — a negative remaining is overdue")
}

func TestEngineHoursAndMilesUseTheirOwnUnit(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 1_609_344, 1234.5)

	hoursLast := 1000.0
	hours := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 500, IntervalUnit: dto.UnitEngineHours,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &hoursLast}},
	})
	row := dueRow(t, h, tn, hours.ID)
	require.InDelta(t, 1234.5, *row.CurrentValue, 0.01)
	require.InDelta(t, 1500, *row.NextDueValue, 0.01)
	require.InDelta(t, 265.5, *row.Remaining, 0.01)

	milesLast := 0.0
	miles := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 10, IntervalUnit: dto.UnitMi,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &milesLast}},
	})
	milesRow := dueRow(t, h, tn, miles.ID)
	require.InDelta(t, 1000, *milesRow.CurrentValue, 0.01) // 1 609 344 m == 1000 mi
	require.InDelta(t, -990, *milesRow.Remaining, 0.01)
	require.True(t, milesRow.Overdue)
}

func TestDayIntervalCountsCalendarDays(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)

	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 90, IntervalUnit: dto.UnitDays, ReminderBeforeValue: 7,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String()}},
	})
	row := dueRow(t, h, tn, sched.ID)
	require.NotNil(t, row.NextDueAt)
	require.Equal(t, now.AddDate(0, 0, 90), *row.NextDueAt)
	require.InDelta(t, 0, *row.CurrentValue, 0.01)
	require.InDelta(t, 90, *row.Remaining, 0.5)
	require.False(t, row.Overdue)
}

func TestCurrentValueIsNullWithoutTelemetry(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)

	last := 100.0
	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})
	row := dueRow(t, h, tn, sched.ID)
	require.Nil(t, row.CurrentValue)
	require.Nil(t, row.Remaining)
	require.False(t, row.Overdue)
}

// ---------------------------------------------------------------- Q42.1

func TestCompleteRebasesTheDuePointAndWritesAHistoryRecord(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 130_000_000, 1300)

	last := 103430.0
	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})
	row := dueRow(t, h, tn, sched.ID)
	require.True(t, row.Overdue)

	cost := 420.5
	invoice := invoiceKey(tn)
	done := decodeUnit(t, mustOK(t, h.client(tn).Post(
		"/api/v1/maintenance-schedule-units/"+row.ID+"/complete", dto.CompleteInput{
			InvoiceNo: "INV-10233", Vendor: "Dallas Truck Service", Cost: &cost,
			InvoiceKey: invoice, Notes: "Oil and filter replaced",
		})))

	// Q42.1 — last_service_value is the reading at completion time, the row
	// goes Due -> Schedule and next_due_value is rebased.
	require.Equal(t, dto.StatusScheduled, done.Status)
	require.InDelta(t, 130000, *done.LastServiceValue, 0.01)
	require.InDelta(t, 155000, *done.NextDueValue, 0.01)
	require.InDelta(t, 25000, *done.Remaining, 0.01)
	require.False(t, done.Overdue)
	require.Nil(t, done.ReminderSentAt, "the reminder guard is cleared for the next cycle")

	records := decodeRecords(t, mustOK(t, h.client(tn).Get("/api/v1/maintenance-records",
		testutil.Query("unit_id", tn.Unit.ID.String()), testutil.Query("status", "completed"))))
	require.Len(t, records, 1)
	require.Equal(t, "INV-10233", records[0].InvoiceNo)
	require.Equal(t, "Dallas Truck Service", records[0].Vendor)
	require.InDelta(t, 420.5, *records[0].Cost, 0.001)
	require.Equal(t, invoice, records[0].InvoiceKey)
	require.EqualValues(t, 130_000_000, *records[0].OdometerM)
}

func TestCompleteWithoutTelemetryIsRefused(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)

	last := 100.0
	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})
	row := dueRow(t, h, tn, sched.ID)

	resp := h.client(tn).Post("/api/v1/maintenance-schedule-units/"+row.ID+"/complete", dto.CompleteInput{})
	testutil.RequireStatusCode(t, resp, http.StatusUnprocessableEntity, apierr.CodeMaintenanceNoReading)
}

func TestCancelCarriesNoFinancialFields(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 130_000_000, 1300)

	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String()}},
	})
	row := dueRow(t, h, tn, sched.ID)

	cancelled := decodeUnit(t, mustOK(t, h.client(tn).Post(
		"/api/v1/maintenance-schedule-units/"+row.ID+"/cancel", dto.CancelInput{Reason: "Unit sold"})))
	require.Equal(t, dto.StatusCancelled, cancelled.Status)
	require.Equal(t, "Unit sold", cancelled.CancelledReason)

	records := decodeRecords(t, mustOK(t, h.client(tn).Get("/api/v1/maintenance-records",
		testutil.Query("unit_id", tn.Unit.ID.String()), testutil.Query("status", "cancelled"))))
	require.Len(t, records, 1)
	require.Equal(t, "Unit sold", records[0].CancelledReason)
	require.Empty(t, records[0].InvoiceNo)
	require.Empty(t, records[0].Vendor)
	require.Nil(t, records[0].Cost)

	// A closed row accepts neither completion nor a second cancellation.
	again := h.client(tn).Post("/api/v1/maintenance-schedule-units/"+row.ID+"/cancel",
		dto.CancelInput{Reason: "again"})
	testutil.RequireStatusCode(t, again, http.StatusConflict, apierr.CodeMaintenanceInvalidState)
	complete := h.client(tn).Post("/api/v1/maintenance-schedule-units/"+row.ID+"/complete", dto.CompleteInput{})
	testutil.RequireStatusCode(t, complete, http.StatusConflict, apierr.CodeMaintenanceInvalidState)

	// A cancelled row leaves the open due list.
	open := decodeUnits(t, mustOK(t, h.client(tn).Get("/api/v1/maintenance/due",
		testutil.Query("schedule_id", sched.ID))))
	require.Empty(t, open)
}

// ---------------------------------------------------------------- Q37/Q38

func TestReminderFiresExactlyOncePerCycle(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	// 500 km left against a 1000 km reminder window.
	seedLastState(t, tn.ID(), tn.Unit.ID, 127_930_000, 1300)

	last := 103430.0
	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm, ReminderBeforeValue: 1000,
		NotifyCoDriver: true,
		Units:          []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})
	row := dueRow(t, h, tn, sched.ID)
	require.True(t, row.ReminderDue)

	ctx := tenant.WithCompanyID(context.Background(), tn.ID())
	sent, err := h.svc.SendReminders(ctx)
	require.NoError(t, err)
	require.Equal(t, 1, sent)
	require.Equal(t, []string{maintenance.ReminderDue}, h.alerter.kinds())

	// Q37 — a second sweep is a no-op, the `reminder_sent_at` stamp is the guard.
	sent, err = h.svc.SendReminders(ctx)
	require.NoError(t, err)
	require.Zero(t, sent)
	require.Len(t, h.alerter.kinds(), 1)

	after := dueRow(t, h, tn, sched.ID)
	require.NotNil(t, after.ReminderSentAt)
	require.Equal(t, dto.StatusDue, after.Status)
}

func TestReminderStaysSilentBeforeTheWindow(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 110_000_000, 1300)

	last := 103430.0
	createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm, ReminderBeforeValue: 1000,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})

	sent, err := h.svc.SendReminders(tenant.WithCompanyID(context.Background(), tn.ID()))
	require.NoError(t, err)
	require.Zero(t, sent)
	require.Empty(t, h.alerter.kinds())
}

func TestOverdueRaisesTheOverdueReminder(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	seedLastState(t, tn.ID(), tn.Unit.ID, 140_000_000, 1300)

	last := 103430.0
	createSchedule(t, h, tn, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm, ReminderBeforeValue: 1000,
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String(), LastServiceValue: &last}},
	})

	sent, err := h.svc.SendReminders(tenant.WithCompanyID(context.Background(), tn.ID()))
	require.NoError(t, err)
	require.Equal(t, 1, sent)
	require.Equal(t, []string{maintenance.ReminderOverdue}, h.alerter.kinds())
}

// ---------------------------------------------------------------- schedules CRUD

func TestScheduleCrudAndFleetReplacement(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	second := testutil.NewUnit(t, tn.ID())
	client := h.client(tn)

	sched := createSchedule(t, h, tn, dto.ScheduleCreate{
		Name: "Oil change " + uuid.NewString()[:8], Type: "oil_change",
		IntervalValue: 25000, IntervalUnit: dto.UnitKm, ReminderBeforeValue: 1000,
		AlertType: dto.AlertEmail, DeliveryMethods: []string{"push", "email"},
		Notes: "Synthetic only",
		Units: []dto.ScheduleUnitInput{{UnitID: tn.Unit.ID.String()}},
	})
	require.Equal(t, dto.AlertEmail, sched.AlertType)
	require.Equal(t, []string{"push", "email"}, sched.DeliveryMethods)
	require.EqualValues(t, 1, sched.UnitCount)

	// Replacing the fleet detaches the old unit and attaches the new one.
	updated := decodeSchedule(t, mustOK(t, client.Patch("/api/v1/maintenance-schedules/"+sched.ID,
		dto.ScheduleUpdate{
			Status: strPtr(dto.ScheduleInactive),
			Units:  &[]dto.ScheduleUnitInput{{UnitID: second.ID.String()}},
		})))
	require.Equal(t, dto.ScheduleInactive, updated.Status)
	require.EqualValues(t, 1, updated.UnitCount)

	rows := decodeUnits(t, mustOK(t, client.Get("/api/v1/maintenance/due",
		testutil.Query("schedule_id", sched.ID))))
	require.Len(t, rows, 1)
	require.Equal(t, second.ID.String(), rows[0].UnitID)

	listed := mustOK(t, client.Get("/api/v1/maintenance-schedules", testutil.Query("status", dto.ScheduleInactive)))
	require.Contains(t, listed.String(), sched.ID)

	testutil.RequireStatus(t, client.Delete("/api/v1/maintenance-schedules/"+sched.ID), http.StatusNoContent)
	testutil.RequireStatusCode(t, client.Get("/api/v1/maintenance-schedules/"+sched.ID),
		http.StatusNotFound, apierr.CodeNotFound)
}

func TestScheduleRejectsAnUnknownUnitAndDuplicates(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t, allMaintenancePerms...)
	client := h.client(tn)

	unknown := client.Post("/api/v1/maintenance-schedules", dto.ScheduleCreate{
		Name: "Plan " + uuid.NewString()[:8], IntervalValue: 100, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{{UnitID: uuid.NewString()}},
	})
	testutil.RequireStatusCode(t, unknown, http.StatusNotFound, apierr.CodeNotFound)

	dup := client.Post("/api/v1/maintenance-schedules", dto.ScheduleCreate{
		Name: "Plan " + uuid.NewString()[:8], IntervalValue: 100, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{
			{UnitID: tn.Unit.ID.String()}, {UnitID: tn.Unit.ID.String()},
		},
	})
	testutil.RequireStatusCode(t, dup, http.StatusUnprocessableEntity, apierr.CodeValidationError)

	badUnit := client.Post("/api/v1/maintenance-schedules", dto.ScheduleCreate{
		Name: "Plan " + uuid.NewString()[:8], IntervalValue: 100, IntervalUnit: "parsecs",
	})
	testutil.RequireStatusCode(t, badUnit, http.StatusUnprocessableEntity, apierr.CodeValidationError)
}

// ---------------------------------------------------------------- isolation

func TestCrossTenantAccessAnswers404(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allMaintenancePerms...)
	seedLastState(t, a.ID(), a.Unit.ID, 130_000_000, 1300)

	sched := createSchedule(t, h, a, dto.ScheduleCreate{
		IntervalValue: 25000, IntervalUnit: dto.UnitKm,
		Units: []dto.ScheduleUnitInput{{UnitID: a.Unit.ID.String()}},
	})
	row := dueRow(t, h, a, sched.ID)

	other := h.client(b)
	testutil.RequireStatusCode(t, other.Get("/api/v1/maintenance-schedules/"+sched.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, other.Patch("/api/v1/maintenance-schedules/"+sched.ID,
		dto.ScheduleUpdate{Status: strPtr(dto.ScheduleInactive)}), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, other.Delete("/api/v1/maintenance-schedules/"+sched.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, other.Get("/api/v1/maintenance-schedule-units/"+row.ID),
		http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, other.Post("/api/v1/maintenance-schedule-units/"+row.ID+"/complete",
		dto.CompleteInput{}), http.StatusNotFound, apierr.CodeNotFound)
	testutil.RequireStatusCode(t, other.Post("/api/v1/maintenance-schedule-units/"+row.ID+"/cancel",
		dto.CancelInput{Reason: "nope"}), http.StatusNotFound, apierr.CodeNotFound)

	// The other tenant's due list and history never show the row.
	require.Empty(t, decodeUnits(t, mustOK(t, other.Get("/api/v1/maintenance/due",
		testutil.Query("unit_id", a.Unit.ID.String())))))
}

func TestUnauthenticatedAndUnprivilegedCallsAreRefused(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	tn := testutil.SeedTenant(t) // no permissions at all

	testutil.RequireStatus(t, h.srv.Anonymous().Get("/api/v1/maintenance/due"), http.StatusUnauthorized)
	testutil.RequireStatusCode(t, h.client(tn).Get("/api/v1/maintenance/due"),
		http.StatusForbidden, apierr.CodeForbidden)
}

// ---------------------------------------------------------------- helpers

type recordingAlerter struct {
	seen []string
}

func (r *recordingAlerter) Alert(_ context.Context, kind string, _ maintenance.Reminder) error {
	r.seen = append(r.seen, kind)
	return nil
}

func (r *recordingAlerter) kinds() []string { return r.seen }

func mustOK(t testing.TB, resp *testutil.Response) *testutil.Response {
	t.Helper()
	testutil.RequireStatus(t, resp, http.StatusOK)
	return resp
}

func strPtr(v string) *string { return &v }
