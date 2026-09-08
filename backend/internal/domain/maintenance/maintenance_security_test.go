//go:build integration

// Security regression coverage of the maintenance module: the completion
// invoice key is client supplied and must belong to the calling tenant.
package maintenance_test

import (
	"net/http"
	"testing"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/maintenance/dto"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/testutil"
)

func TestCompleteRejectsAForeignInvoiceKey(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allMaintenancePerms...)

	sched := createSchedule(t, h, a, dto.ScheduleCreate{
		Name: "Oil change", IntervalValue: 25000, IntervalUnit: dto.UnitDays,
		Units: []dto.ScheduleUnitInput{{UnitID: a.Unit.ID.String()}},
	})
	row := dueRow(t, h, a, sched.ID)

	testutil.RequireStatusCode(t, h.client(a).Post(
		"/api/v1/maintenance-schedule-units/"+row.ID+"/complete",
		dto.CompleteInput{InvoiceKey: storage.BuildKey(b.ID(), "invoice", "inv.pdf", now)}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	testutil.RequireStatusCode(t, h.client(a).Post(
		"/api/v1/maintenance-schedule-units/"+row.ID+"/complete",
		dto.CompleteInput{InvoiceKey: "../" + b.ID().String() + "/invoice/2026/09/x.pdf"}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)

	mustOK(t, h.client(a).Post("/api/v1/maintenance-schedule-units/"+row.ID+"/complete",
		dto.CompleteInput{InvoiceKey: invoiceKey(a)}))
}
