//go:build integration

// Security regression coverage of the DVIR module: a client supplied object key
// (driver / mechanic signature, defect photo) may only name this tenant's own
// object, or a later presigned download would serve another company's file.
package dvir_test

import (
	"net/http"
	"testing"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

func TestForeignObjectKeysAreRejected(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allDvirPerms...)
	defectType := newDefectType(t, a.ID(), "Wipers", false)
	client := h.driverClient(a)

	// A signature key of another company.
	testutil.RequireStatusCode(t, client.Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID: a.Unit.ID.String(), Type: dto.TypePreTrip,
		DriverSignatureKey: objKey(b, "signature", "sig.png"),
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// A defect photo key of another company.
	testutil.RequireStatusCode(t, client.Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID: a.Unit.ID.String(), Type: dto.TypePreTrip,
		DriverSignatureKey: objKey(a, "signature", "sig.png"),
		Defects: []dto.DefectInput{{
			DefectTypeID: defectType.String(),
			PhotoKeys:    []string{objKey(b, "dvir_photo", "x.jpg")},
		}},
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// A traversal style key never reaches storage either.
	testutil.RequireStatusCode(t, client.Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID: a.Unit.ID.String(), Type: dto.TypePreTrip,
		DriverSignatureKey: "../" + b.ID().String() + "/signature/2026/09/s.png",
	}), http.StatusUnprocessableEntity, apierr.CodeValidationError)

	// The tenant's own key is accepted.
	testutil.RequireStatus(t, client.Post("/api/v1/dvir-reports", dto.DvirCreate{
		UnitID: a.Unit.ID.String(), Type: dto.TypePreTrip,
		DriverSignatureKey: objKey(a, "signature", "sig.png"),
	}), http.StatusCreated)
}

// The mechanic side of the flow is checked too: a repair may not attach another
// company's signature or invoice.
func TestRepairRejectsForeignKeys(t *testing.T) {
	t.Parallel()
	h := newHarness(t)
	a, b := testutil.SeedTwoCompanies(t, allDvirPerms...)
	defectType := newDefectType(t, a.ID(), "Lights", false)

	rep := submit(t, h, a, dto.TypePreTrip, dto.DefectInput{DefectTypeID: defectType.String()})
	testutil.RequireStatusCode(t, h.adminClient(a).Post("/api/v1/dvir-reports/"+rep.ID+"/repair",
		dto.DvirRepair{MechanicNote: "fixed", MechanicSignatureKey: objKey(b, "signature", "m.png")}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
	testutil.RequireStatusCode(t, h.adminClient(a).Post("/api/v1/dvir-reports/"+rep.ID+"/repair",
		dto.DvirRepair{MechanicNote: "fixed", InvoiceKey: objKey(b, "invoice", "i.pdf")}),
		http.StatusUnprocessableEntity, apierr.CodeValidationError)
}
