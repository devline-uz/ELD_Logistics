// Package files implements the upload presigning endpoint and the CSV/XLSX
// import & export of drivers and units. It implements server.Module.
//
// The API never proxies file bytes: POST /files/presign hands the client a
// signed S3 PUT URL and only the object key is persisted (TZ B§3.4).
package files

import (
	"context"
	"io"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/audit"
	core "github.com/devline/onebook-eld/internal/auth"
	appcrypto "github.com/devline/onebook-eld/internal/crypto"
	"github.com/devline/onebook-eld/internal/db"
	authdomain "github.com/devline/onebook-eld/internal/domain/auth"
	"github.com/devline/onebook-eld/internal/domain/files/dto"
	mw "github.com/devline/onebook-eld/internal/middleware"
	"github.com/devline/onebook-eld/internal/storage"
	"github.com/devline/onebook-eld/internal/tenant"
)

// exportRowLimit caps one export so a single request cannot stream the whole
// database into memory.
const exportRowLimit = 50000

// Deps are the files service collaborators.
type Deps struct {
	Repo      Repo
	Presigner storage.Presigner
	Cipher    *appcrypto.Cipher
	Audit     audit.Recorder
	Notifier  authdomain.Notifier
	Verifier  mw.AuthVerifier
	Logger    *slog.Logger
	// Now is overridable in tests.
	Now func() time.Time
}

// Service holds the file, import and export business logic.
type Service struct {
	repo      Repo
	presigner storage.Presigner
	cipher    *appcrypto.Cipher
	recorder  audit.Recorder
	notifier  authdomain.Notifier
	log       *slog.Logger
	now       func() time.Time
}

// NewService wires the files service.
func NewService(d Deps) *Service {
	s := &Service{
		repo:      d.Repo,
		presigner: d.Presigner,
		cipher:    d.Cipher,
		recorder:  d.Audit,
		notifier:  d.Notifier,
		log:       d.Logger,
		now:       d.Now,
	}
	if s.log == nil {
		s.log = slog.Default()
	}
	if s.recorder == nil {
		s.recorder = audit.NopRecorder{}
	}
	if s.now == nil {
		s.now = time.Now
	}
	return s
}

// RequestMeta carries the transport facts the audit trail records.
type RequestMeta struct {
	IP        string
	UserAgent string
}

// Presign validates the upload against the kind whitelist and returns a signed
// PUT URL valid for 15 minutes.
func (s *Service) Presign(ctx context.Context, in dto.PresignRequest) (*dto.PresignResponse, error) {
	kind := strings.ToLower(strings.TrimSpace(in.Kind))
	maxBytes, err := checkUpload(kind, in.ContentType, in.SizeBytes)
	if err != nil {
		return nil, err
	}
	if s.presigner == nil {
		return nil, apierr.New(apierr.CodeUnavailable, http.StatusServiceUnavailable,
			"object storage is not configured")
	}

	// The key is derived server side from the tenant, the kind and a random
	// uuid; only the file extension comes from the client and it is sanitised.
	companyID := tenant.CompanyID(ctx)
	key := storage.BuildKey(companyID, kind, in.Filename, s.now().UTC())

	// Q: size_bytes is signed together with the key and the content type, so
	// the object store itself rejects a body that is not exactly the size the
	// per kind ceiling was checked against.
	signed, err := s.presigner.PresignPut(ctx, storage.PutRequest{
		Key:           key,
		ContentType:   normaliseContentType(in.ContentType),
		ContentLength: in.SizeBytes,
		Expiry:        storage.DefaultExpiry,
	})
	if err != nil {
		return nil, apierr.Wrap(err, apierr.CodeStorageError, http.StatusBadGateway,
			"could not create an upload url")
	}

	return &dto.PresignResponse{
		UploadURL: signed.URL,
		Key:       signed.Key,
		Method:    http.MethodPut,
		ExpiresAt: signed.ExpiresAt,
		MaxBytes:  maxBytes,
		Headers:   signed.Headers,
	}, nil
}

// ImportSource is the uploaded file the handler extracted from the multipart
// request.
type ImportSource struct {
	Body        io.Reader
	Filename    string
	ContentType string
}

// ImportDrivers validates every row first and writes the whole file in one
// transaction. TZ §18.4 is all-or-nothing: one critical error and nothing is
// written.
func (s *Service) ImportDrivers(ctx context.Context, src ImportSource, meta RequestMeta) (*dto.ImportResult, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, err
	}
	t, err := parseTable(src.Body, src.Filename, src.ContentType)
	if err != nil {
		return nil, err
	}
	if err := requireColumns(t, driverRequiredColumns); err != nil {
		return nil, err
	}

	rows, rowErrors := s.validateDriverRows(ctx, companyID, t)
	if len(rowErrors) > 0 {
		return &dto.ImportResult{Imported: 0, Total: len(t.rows), Errors: rowErrors}, errImportRejected(len(rowErrors))
	}
	if len(rows) == 0 {
		return &dto.ImportResult{Imported: 0, Total: 0, Errors: []dto.ImportRowError{}}, nil
	}

	role, err := s.repo.RoleByName(ctx, companyID, driverRoleName)
	if err != nil {
		if db.IsNoRows(err) {
			return nil, apierr.New(apierr.CodeInvalidState, http.StatusConflict,
				"the Driver role is missing for this company")
		}
		return nil, db.MapError(err, "role")
	}

	invites := make([]DriverInvitation, 0, len(rows))
	tokens := make([]string, 0, len(rows))
	expiresAt := s.now().UTC().Add(core.InvitationTTL)
	for _, row := range rows {
		token, err := appcrypto.RandomToken(core.RefreshTokenBytes)
		if err != nil {
			return nil, apierr.Internal(err, "could not create an invitation token")
		}
		channel, recipient := "email", row.Email
		if recipient == "" {
			channel, recipient = "sms", row.Phone
		}
		tokens = append(tokens, token)
		invites = append(invites, DriverInvitation{
			TokenHash: appcrypto.HashSHA256(token),
			Channel:   channel,
			Recipient: recipient,
			Purpose:   authdomain.PurposeInvitation,
			ExpiresAt: expiresAt,
		})
	}

	entries := []audit.Entry{{
		TableName: "drivers",
		RecordID:  companyID,
		Field:     "import",
		Action:    audit.Action("import"),
		NewValue:  map[string]any{"rows": len(rows), "filename": src.Filename},
		CompanyID: companyID,
		IP:        meta.IP,
	}}

	created, err := s.repo.ImportDrivers(ctx, companyID, role.ID, rows, invites, entries)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}

	for i, c := range created {
		if i < len(tokens) {
			s.deliverInvitation(ctx, c, companyID, tokens[i])
		}
	}

	return &dto.ImportResult{
		Imported: len(created),
		Total:    len(t.rows),
		Errors:   []dto.ImportRowError{},
	}, nil
}

// ImportUnits validates every row first and writes the whole file in one
// transaction (all-or-nothing, TZ §18.4).
func (s *Service) ImportUnits(ctx context.Context, src ImportSource, meta RequestMeta) (*dto.ImportResult, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, err
	}
	t, err := parseTable(src.Body, src.Filename, src.ContentType)
	if err != nil {
		return nil, err
	}
	if err := requireColumns(t, unitRequiredColumns); err != nil {
		return nil, err
	}

	rows, rowErrors := s.validateUnitRows(ctx, companyID, t)
	if len(rowErrors) > 0 {
		return &dto.ImportResult{Imported: 0, Total: len(t.rows), Errors: rowErrors}, errImportRejected(len(rowErrors))
	}
	if len(rows) == 0 {
		return &dto.ImportResult{Imported: 0, Total: 0, Errors: []dto.ImportRowError{}}, nil
	}

	entries := []audit.Entry{{
		TableName: "units",
		RecordID:  companyID,
		Field:     "import",
		Action:    audit.Action("import"),
		NewValue:  map[string]any{"rows": len(rows), "filename": src.Filename},
		CompanyID: companyID,
		IP:        meta.IP,
	}}

	imported, err := s.repo.ImportUnits(ctx, companyID, rows, entries)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}
	return &dto.ImportResult{
		Imported: imported,
		Total:    len(t.rows),
		Errors:   []dto.ImportRowError{},
	}, nil
}

// Download is a rendered file ready to be streamed to the client.
type Download struct {
	Filename    string
	ContentType string
	Body        []byte
}

// ExportDrivers renders the driver list as CSV or XLSX and writes the export to
// audit_log (who downloaded what, TZ B§3.6).
func (s *Service) ExportDrivers(
	ctx context.Context, scope mw.ScopeFilter, format string, f ExportFilter, meta RequestMeta,
) (*Download, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, err
	}
	f.CompanyID = companyID
	f.Limit = exportRowLimit
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		f.BranchID = scope.BranchID
	}

	rows, err := s.repo.ExportDrivers(ctx, f)
	if err != nil {
		return nil, db.MapError(err, "driver")
	}

	data := make([][]string, 0, len(rows))
	for _, row := range rows {
		data = append(data, driverExportRow(row, s.maskLicense))
	}

	body, err := render(driverTemplateName, driverExportColumns, data, format)
	if err != nil {
		return nil, err
	}

	s.recordExport(ctx, companyID, "drivers", len(rows), format, meta)

	return &Download{
		Filename:    "drivers_export_" + s.now().UTC().Format("20060102T150405Z") + "." + format,
		ContentType: contentTypeFor(format),
		Body:        body,
	}, nil
}

// ExportUnits renders the unit list as CSV or XLSX and audits the download.
func (s *Service) ExportUnits(
	ctx context.Context, scope mw.ScopeFilter, format string, f ExportFilter, meta RequestMeta,
) (*Download, error) {
	companyID, err := requireCompany(ctx)
	if err != nil {
		return nil, err
	}
	f.CompanyID = companyID
	f.Limit = exportRowLimit
	if scope.Scope == tenant.ScopeBranch && scope.BranchID != nil {
		f.BranchID = scope.BranchID
	}

	rows, err := s.repo.ExportUnits(ctx, f)
	if err != nil {
		return nil, db.MapError(err, "unit")
	}

	data := make([][]string, 0, len(rows))
	for _, row := range rows {
		data = append(data, unitExportRow(row))
	}

	body, err := render(unitTemplateName, unitExportColumns, data, format)
	if err != nil {
		return nil, err
	}

	s.recordExport(ctx, companyID, "units", len(rows), format, meta)

	return &Download{
		Filename:    "units_export_" + s.now().UTC().Format("20060102T150405Z") + "." + format,
		ContentType: contentTypeFor(format),
		Body:        body,
	}, nil
}

// DriverTemplate renders drivers_import_template in the requested format.
func (s *Service) DriverTemplate(format string) (*Download, error) {
	body, err := buildTemplate(driverTemplateName, driverImportColumns, driverTemplateSample, format)
	if err != nil {
		return nil, err
	}
	return &Download{
		Filename:    driverTemplateName + "." + format,
		ContentType: contentTypeFor(format),
		Body:        body,
	}, nil
}

// UnitTemplate renders units_import_template in the requested format.
func (s *Service) UnitTemplate(format string) (*Download, error) {
	body, err := buildTemplate(unitTemplateName, unitImportColumns, unitTemplateSample, format)
	if err != nil {
		return nil, err
	}
	return &Download{
		Filename:    unitTemplateName + "." + format,
		ContentType: contentTypeFor(format),
		Body:        body,
	}, nil
}

// ---------------------------------------------------------------- internals

const driverRoleName = "Driver"

func render(sheet string, header []string, rows [][]string, format string) ([]byte, error) {
	if format == FormatXLSX {
		return renderXLSX(sheet, header, rows)
	}
	return renderCSV(header, rows)
}

func (s *Service) recordExport(ctx context.Context, companyID uuid.UUID, table string, rows int, format string, meta RequestMeta) {
	err := s.recorder.Record(ctx, audit.Entry{
		TableName: table,
		RecordID:  companyID,
		Field:     "export",
		Action:    audit.ActionExport,
		NewValue:  map[string]any{"rows": rows, "format": format},
		CompanyID: companyID,
		IP:        meta.IP,
	})
	if err != nil {
		s.log.ErrorContext(ctx, "could not audit an export", "table", table, "error", err.Error())
	}
}

func (s *Service) deliverInvitation(ctx context.Context, c ImportedDriver, companyID uuid.UUID, token string) {
	if s.notifier == nil || c.Recipient == "" {
		return
	}
	cid := companyID
	if err := s.notifier.SendInvitation(ctx, authdomain.InvitationMessage{
		UserID: c.UserID, CompanyID: &cid, Channel: c.Channel, Recipient: c.Recipient,
		Purpose: authdomain.PurposeInvitation, Token: token, ExpiresAt: c.ExpiresAt,
	}); err != nil {
		s.log.WarnContext(ctx, "could not deliver an invitation", "error", err.Error())
	}
}

// maskLicense decrypts the stored licence and keeps only its last four
// characters; an export never carries the clear value.
func (s *Service) maskLicense(enc *string) string {
	if enc == nil || *enc == "" || s.cipher == nil {
		return ""
	}
	plain, err := s.cipher.DecryptString(*enc)
	if err != nil {
		return ""
	}
	r := []rune(plain)
	if len(r) <= 4 {
		return "***"
	}
	return "***" + string(r[len(r)-4:])
}

func requireCompany(ctx context.Context) (uuid.UUID, error) {
	companyID, ok := tenant.CompanyIDOK(ctx)
	if !ok {
		return uuid.Nil, apierr.Forbidden("no active company for this session")
	}
	return companyID, nil
}

// errImportRejected marks an all-or-nothing rejection. The handler still sends
// the per-row report as the response body.
func errImportRejected(count int) error {
	return apierr.Validation("the import was rejected: " + itoa(int64(count)) + " invalid rows; nothing was written")
}
