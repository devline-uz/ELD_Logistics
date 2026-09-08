package files

import (
	"errors"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/devline/onebook-eld/internal/apierr"
	core "github.com/devline/onebook-eld/internal/auth"
	"github.com/devline/onebook-eld/internal/domain/files/dto"
	"github.com/devline/onebook-eld/internal/httpx"
	mw "github.com/devline/onebook-eld/internal/middleware"
)

// maxImportUpload is the multipart parsing budget for an import file. The
// global body limit still applies first.
const maxImportUpload = 2 << 20

// Module wires the file, import and export routes into the /api/v1 router. It
// implements server.Module.
//
// The `/units/import`, `/units/export` and `/units/import-template` routes live
// here rather than in internal/domain/fleet: chi lets independent modules add
// routes under the same prefix, and it keeps the whole import/export surface in
// one place.
type Module struct {
	svc      *Service
	verifier mw.AuthVerifier
}

// New builds the files module.
func New(d Deps) *Module {
	return &Module{svc: NewService(d), verifier: d.Verifier}
}

// Service exposes the business layer for sibling modules and tests.
func (m *Module) Service() *Service { return m.svc }

// RegisterRoutes implements server.Module.
func (m *Module) RegisterRoutes(r chi.Router) {
	r.Route("/files", func(f chi.Router) {
		f.Use(mw.Authenticate(m.verifier), mw.RequireFullSession, mw.RequireCompany)
		f.With(mw.RequirePermission(core.PermFilesUpload)).Post("/presign", m.presign)
	})

	r.Group(func(g chi.Router) {
		g.Use(mw.Authenticate(m.verifier), mw.RequireFullSession, mw.RequireCompany, mw.Scope)

		g.With(mw.RequirePermission(core.PermDriversImport)).Post("/drivers/import", m.importDrivers)
		g.With(mw.RequirePermission(core.PermDriversImport)).Get("/drivers/import-template", m.driverTemplate)
		g.With(mw.RequirePermission(core.PermDriversExport)).Get("/drivers/export", m.exportDrivers)

		g.With(mw.RequirePermission(core.PermUnitsImport)).Post("/units/import", m.importUnits)
		g.With(mw.RequirePermission(core.PermUnitsImport)).Get("/units/import-template", m.unitTemplate)
		g.With(mw.RequirePermission(core.PermUnitsExport)).Get("/units/export", m.exportUnits)
	})
}

func metaOf(r *http.Request) RequestMeta {
	return RequestMeta{IP: httpx.ClientIP(r), UserAgent: r.UserAgent()}
}

func scopeOf(r *http.Request) mw.ScopeFilter {
	f, _ := mw.ScopeFrom(r.Context())
	return f
}

// presign godoc
//
//	@Summary		Presign a file upload
//	@Description	TZ B§3.4 — the API never proxies bytes. `kind` is a closed whitelist (dvir_photo, invoice, signature, logo, chat, import); the content type and the size are checked against the per-kind ceiling (DVIR photo ≤ 5 MiB, invoice ≤ 10 MiB) before anything is signed. The object key is derived server side from the tenant, the kind and a random uuid — a client supplied path is never trusted — and only that key is stored. The URL is a PUT valid for 15 minutes; its `Content-Type` **and** `Content-Length` headers are part of the signature, so the upload must be exactly `size_bytes` long — the ceiling cannot be bypassed after presigning. Send every header of `headers` verbatim.
//	@Tags			files
//	@Accept			json
//	@Produce		json
//	@Param			body	body		dto.PresignRequest	true	"Upload description"
//	@Success		200		{object}	dto.PresignEnvelope
//	@Failure		400		{object}	dto.ErrorResponse	"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		413		{object}	dto.ErrorResponse	"FILE_TOO_LARGE"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR / FILE_TYPE_INVALID"
//	@Failure		502		{object}	dto.ErrorResponse	"STORAGE_ERROR"
//	@Failure		503		{object}	dto.ErrorResponse	"SERVICE_UNAVAILABLE"
//	@Security		BearerAuth
//	@x-permission	"files.upload"
//	@Router			/files/presign [post]
func (m *Module) presign(w http.ResponseWriter, r *http.Request) {
	var in dto.PresignRequest
	if err := httpx.DecodeAndValidate(r, &in); err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.Presign(r.Context(), in)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

// importDrivers godoc
//
//	@Summary		Import drivers from CSV/XLSX
//	@Description	TZ §18.4 — multipart upload of `drivers_import_template` (first_name, last_name, username, phone, email, license_no, license_region, home_terminal). Validation is row by row and **all-or-nothing**: one critical error and nothing at all is written; the body then lists every `{row, field, message}` and the response status is 422. Every imported driver gets a users row (Driver role, status `invited`) and an invitation link; `license_no` is stored AES-256-GCM encrypted.
//	@Tags			drivers
//	@Accept			mpfd
//	@Produce		json
//	@Param			file	formData	file	true	"CSV or XLSX file"
//	@Success		200		{object}	dto.ImportResultEnvelope
//	@Failure		400		{object}	dto.ErrorResponse		"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse		"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse		"FORBIDDEN"
//	@Failure		409		{object}	dto.ErrorResponse		"UNIQUE_VIOLATION / INVALID_STATE"
//	@Failure		413		{object}	dto.ErrorResponse		"PAYLOAD_TOO_LARGE"
//	@Failure		422		{object}	dto.ImportResultEnvelope	"VALIDATION_ERROR — nothing was written"
//	@Security		BearerAuth
//	@x-permission	"drivers.import"
//	@Router			/drivers/import [post]
func (m *Module) importDrivers(w http.ResponseWriter, r *http.Request) {
	src, cleanup, err := readUpload(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	defer cleanup()

	out, err := m.svc.ImportDrivers(r.Context(), src, metaOf(r))
	writeImport(w, r, out, err)
}

// importUnits godoc
//
//	@Summary		Import units from CSV/XLSX
//	@Description	TZ §18.4 — multipart upload of `units_import_template` (unit_number, make, model, year, plate, plate_region, vin, fuel_type, sleeper_berth). Validation is row by row and **all-or-nothing**: one critical error and nothing at all is written; the body then lists every `{row, field, message}` and the response status is 422.
//	@Tags			units
//	@Accept			mpfd
//	@Produce		json
//	@Param			file	formData	file	true	"CSV or XLSX file"
//	@Success		200		{object}	dto.ImportResultEnvelope
//	@Failure		400		{object}	dto.ErrorResponse		"BAD_REQUEST"
//	@Failure		401		{object}	dto.ErrorResponse		"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse		"FORBIDDEN"
//	@Failure		409		{object}	dto.ErrorResponse		"UNIQUE_VIOLATION"
//	@Failure		413		{object}	dto.ErrorResponse		"PAYLOAD_TOO_LARGE"
//	@Failure		422		{object}	dto.ImportResultEnvelope	"VALIDATION_ERROR — nothing was written"
//	@Security		BearerAuth
//	@x-permission	"units.import"
//	@Router			/units/import [post]
func (m *Module) importUnits(w http.ResponseWriter, r *http.Request) {
	src, cleanup, err := readUpload(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	defer cleanup()

	out, err := m.svc.ImportUnits(r.Context(), src, metaOf(r))
	writeImport(w, r, out, err)
}

// exportDrivers godoc
//
//	@Summary		Export drivers
//	@Description	Downloads the driver list as CSV (default) or XLSX. `license_no` is exported **masked**, never in clear text. Every download is recorded in `audit_log` (who exported what, TZ B§3.6).
//	@Tags			drivers
//	@Produce		text/csv
//	@Param			format				query	string	false	"File format"	Enums(csv, xlsx)	default(csv)
//	@Param			status				query	string	false	"Driver status"	Enums(invited, active, inactive)
//	@Param			branch_id			query	string	false	"Branch id (uuid)"
//	@Param			include_inactive	query	bool	false	"Include deactivated drivers"	default(false)
//	@Success		200					{file}	binary	"CSV or XLSX file"
//	@Failure		401					{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403					{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422					{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.export"
//	@Router			/drivers/export [get]
func (m *Module) exportDrivers(w http.ResponseWriter, r *http.Request) {
	format, filter, err := exportQuery(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ExportDrivers(r.Context(), scopeOf(r), format, filter, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	writeDownload(w, out)
}

// exportUnits godoc
//
//	@Summary		Export units
//	@Description	Downloads the unit list as CSV (default) or XLSX. Every download is recorded in `audit_log`.
//	@Tags			units
//	@Produce		text/csv
//	@Param			format				query	string	false	"File format"	Enums(csv, xlsx)	default(csv)
//	@Param			status				query	string	false	"Unit status"	Enums(active, inactive)
//	@Param			branch_id			query	string	false	"Branch id (uuid)"
//	@Param			include_inactive	query	bool	false	"Include deactivated units"	default(false)
//	@Success		200					{file}	binary	"CSV or XLSX file"
//	@Failure		401					{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403					{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422					{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"units.export"
//	@Router			/units/export [get]
func (m *Module) exportUnits(w http.ResponseWriter, r *http.Request) {
	format, filter, err := exportQuery(r)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.ExportUnits(r.Context(), scopeOf(r), format, filter, metaOf(r))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	writeDownload(w, out)
}

// driverTemplate godoc
//
//	@Summary		Download the driver import template
//	@Description	TZ §18.4 — `drivers_import_template` with the exact column order the importer expects, plus one sample row.
//	@Tags			drivers
//	@Produce		text/csv
//	@Param			format	query	string	false	"File format"	Enums(csv, xlsx)	default(csv)
//	@Success		200		{file}	binary	"CSV or XLSX file"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"drivers.import"
//	@Router			/drivers/import-template [get]
func (m *Module) driverTemplate(w http.ResponseWriter, r *http.Request) {
	format, err := parseFormat(r.URL.Query().Get("format"))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.DriverTemplate(format)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	writeDownload(w, out)
}

// unitTemplate godoc
//
//	@Summary		Download the unit import template
//	@Description	TZ §18.4 — `units_import_template` with the exact column order the importer expects, plus one sample row.
//	@Tags			units
//	@Produce		text/csv
//	@Param			format	query	string	false	"File format"	Enums(csv, xlsx)	default(csv)
//	@Success		200		{file}	binary	"CSV or XLSX file"
//	@Failure		401		{object}	dto.ErrorResponse	"UNAUTHORIZED"
//	@Failure		403		{object}	dto.ErrorResponse	"FORBIDDEN"
//	@Failure		422		{object}	dto.ErrorResponse	"VALIDATION_ERROR"
//	@Security		BearerAuth
//	@x-permission	"units.import"
//	@Router			/units/import-template [get]
func (m *Module) unitTemplate(w http.ResponseWriter, r *http.Request) {
	format, err := parseFormat(r.URL.Query().Get("format"))
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	out, err := m.svc.UnitTemplate(format)
	if err != nil {
		httpx.WriteError(w, r, err)
		return
	}
	writeDownload(w, out)
}

// ---------------------------------------------------------------- helpers

func exportQuery(r *http.Request) (string, ExportFilter, error) {
	format, err := parseFormat(r.URL.Query().Get("format"))
	if err != nil {
		return "", ExportFilter{}, err
	}
	branchID, err := httpx.QueryUUID(r, "branch_id")
	if err != nil {
		return "", ExportFilter{}, err
	}
	includeInactive, err := httpx.QueryBool(r, "include_inactive")
	if err != nil {
		return "", ExportFilter{}, err
	}

	f := ExportFilter{BranchID: branchID}
	if status := strings.TrimSpace(r.URL.Query().Get("status")); status != "" {
		f.Status = &status
	}
	if includeInactive != nil {
		f.IncludeInactive = *includeInactive
	}
	return format, f, nil
}

// readUpload extracts the `file` part of a multipart request.
func readUpload(r *http.Request) (ImportSource, func(), error) {
	noop := func() {}
	if ct := normaliseContentType(r.Header.Get("Content-Type")); ct != "multipart/form-data" {
		return ImportSource{}, noop, apierr.New(apierr.CodeUnsupportedType,
			http.StatusUnsupportedMediaType, "Content-Type must be multipart/form-data")
	}
	//nolint:gosec // G120: r.Body is already wrapped by mw.BodyLimit (defaultBodyLimit) in server/routes.go
	if err := r.ParseMultipartForm(maxImportUpload); err != nil {
		var maxErr *http.MaxBytesError
		if errors.As(err, &maxErr) {
			return ImportSource{}, noop, apierr.New(apierr.CodePayloadTooLarge,
				http.StatusRequestEntityTooLarge, "the import file is too large")
		}
		return ImportSource{}, noop, apierr.BadRequest("the multipart body could not be parsed")
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		return ImportSource{}, noop, apierr.Validation("the file part is missing",
			apierr.FieldError{Field: "file", Message: "required"})
	}

	cleanup := func() {
		_ = file.Close()
		if r.MultipartForm != nil {
			_ = r.MultipartForm.RemoveAll()
		}
	}
	return ImportSource{
		Body:        file,
		Filename:    header.Filename,
		ContentType: header.Header.Get("Content-Type"),
	}, cleanup, nil
}

// writeImport answers an import: 200 with the report when everything was
// written, 422 with the same report when the file was rejected as a whole.
func writeImport(w http.ResponseWriter, r *http.Request, out *dto.ImportResult, err error) {
	if err != nil {
		if out == nil {
			httpx.WriteError(w, r, err)
			return
		}
		// All-or-nothing rejection: the per-row report is the useful body.
		httpx.WriteJSON(w, http.StatusUnprocessableEntity, httpx.Envelope{Data: out})
		return
	}
	httpx.WriteData(w, http.StatusOK, out)
}

func writeDownload(w http.ResponseWriter, d *Download) {
	w.Header().Set("Content-Type", d.ContentType)
	w.Header().Set("Content-Disposition", `attachment; filename="`+d.Filename+`"`)
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(d.Body) //nolint:gosec // G705: d.Body/ContentType are server-generated exports, not attacker input; nosniff set above
}
