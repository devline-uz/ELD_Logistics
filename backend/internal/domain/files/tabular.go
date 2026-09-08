package files

import (
	"bytes"
	"encoding/csv"
	"io"
	"net/http"
	"strings"

	"github.com/xuri/excelize/v2"

	"github.com/devline/onebook-eld/internal/apierr"
)

// Export / import formats.
const (
	FormatCSV  = "csv"
	FormatXLSX = "xlsx"
)

// maxImportRows caps one import file so a single request cannot exhaust the
// transaction. TZ NFR: 1000 rows must import in under 30 s.
const maxImportRows = 5000

// table is a decoded spreadsheet: a normalised header plus the data rows.
type table struct {
	header []string
	rows   [][]string
}

// index returns the column position of name, or -1.
func (t table) index(name string) int {
	for i, h := range t.header {
		if h == name {
			return i
		}
	}
	return -1
}

// cell reads a cell defensively: short rows yield an empty string.
func cell(row []string, idx int) string {
	if idx < 0 || idx >= len(row) {
		return ""
	}
	return strings.TrimSpace(row[idx])
}

// parseTable decodes a CSV or XLSX upload into a table. The format is taken
// from the file name, falling back to the content type.
func parseTable(r io.Reader, filename, contentType string) (table, error) {
	switch detectFormat(filename, contentType) {
	case FormatXLSX:
		return parseXLSX(r)
	default:
		return parseCSV(r)
	}
}

func detectFormat(filename, contentType string) string {
	name := strings.ToLower(filename)
	switch {
	case strings.HasSuffix(name, ".xlsx"), strings.HasSuffix(name, ".xlsm"):
		return FormatXLSX
	case strings.HasSuffix(name, ".csv"):
		return FormatCSV
	}
	if strings.Contains(normaliseContentType(contentType), "spreadsheetml") {
		return FormatXLSX
	}
	return FormatCSV
}

func parseCSV(r io.Reader) (table, error) {
	reader := csv.NewReader(r)
	reader.FieldsPerRecord = -1
	reader.TrimLeadingSpace = true

	records, err := reader.ReadAll()
	if err != nil {
		return table{}, apierr.BadRequest("the CSV file could not be parsed")
	}
	return fromRecords(records)
}

func parseXLSX(r io.Reader) (table, error) {
	f, err := excelize.OpenReader(r)
	if err != nil {
		return table{}, apierr.BadRequest("the XLSX file could not be parsed")
	}
	defer func() { _ = f.Close() }()

	sheets := f.GetSheetList()
	if len(sheets) == 0 {
		return table{}, apierr.BadRequest("the workbook has no sheet")
	}
	records, err := f.GetRows(sheets[0])
	if err != nil {
		return table{}, apierr.BadRequest("the first sheet could not be read")
	}
	return fromRecords(records)
}

func fromRecords(records [][]string) (table, error) {
	// Skip leading blank lines so a template downloaded and re-saved by Excel
	// still imports.
	for len(records) > 0 && isBlank(records[0]) {
		records = records[1:]
	}
	if len(records) == 0 {
		return table{}, apierr.Validation("the file is empty",
			apierr.FieldError{Field: "file", Message: "at least a header row is required"})
	}

	header := make([]string, 0, len(records[0]))
	for _, h := range records[0] {
		header = append(header, normaliseHeader(h))
	}

	rows := make([][]string, 0, len(records)-1)
	for _, rec := range records[1:] {
		if isBlank(rec) {
			continue
		}
		rows = append(rows, rec)
	}
	if len(rows) > maxImportRows {
		return table{}, apierr.New(apierr.CodeBatchTooLarge, http.StatusUnprocessableEntity,
			"the file has too many rows").WithDetails(apierr.FieldError{
			Field: "file", Message: "at most " + itoa(maxImportRows) + " rows",
		})
	}
	return table{header: header, rows: rows}, nil
}

// normaliseHeader accepts "First Name", "first_name" and "FIRST-NAME" alike.
func normaliseHeader(h string) string {
	h = strings.TrimSpace(strings.ToLower(h))
	h = strings.TrimPrefix(h, "\ufeff")
	h = strings.ReplaceAll(h, " ", "_")
	h = strings.ReplaceAll(h, "-", "_")
	return h
}

func isBlank(rec []string) bool {
	for _, v := range rec {
		if strings.TrimSpace(v) != "" {
			return false
		}
	}
	return true
}

// requireColumns reports every mandatory column the header is missing.
func requireColumns(t table, columns []string) error {
	var details []apierr.FieldError
	for _, c := range columns {
		if t.index(c) < 0 {
			details = append(details, apierr.FieldError{Field: c, Message: "column is missing"})
		}
	}
	if len(details) > 0 {
		return apierr.Validation("the file header does not match the template", details...)
	}
	return nil
}

// ---------------------------------------------------------------- rendering

// renderCSV encodes a header and rows as UTF-8 CSV.
func renderCSV(header []string, rows [][]string) ([]byte, error) {
	var buf bytes.Buffer
	w := csv.NewWriter(&buf)
	if err := w.Write(header); err != nil {
		return nil, apierr.Internal(err, "could not render the CSV file")
	}
	for _, row := range rows {
		if err := w.Write(row); err != nil {
			return nil, apierr.Internal(err, "could not render the CSV file")
		}
	}
	w.Flush()
	if err := w.Error(); err != nil {
		return nil, apierr.Internal(err, "could not render the CSV file")
	}
	return buf.Bytes(), nil
}

// renderXLSX encodes a header and rows as a single sheet workbook.
func renderXLSX(sheet string, header []string, rows [][]string) ([]byte, error) {
	f := excelize.NewFile()
	defer func() { _ = f.Close() }()

	idx, err := f.NewSheet(sheet)
	if err != nil {
		return nil, apierr.Internal(err, "could not render the XLSX file")
	}
	f.SetActiveSheet(idx)
	_ = f.DeleteSheet("Sheet1")

	if err := f.SetSheetRow(sheet, "A1", &header); err != nil {
		return nil, apierr.Internal(err, "could not render the XLSX file")
	}
	for i, row := range rows {
		values := make([]any, len(row))
		for j, v := range row {
			values[j] = v
		}
		axis, err := excelize.CoordinatesToCellName(1, i+2)
		if err != nil {
			return nil, apierr.Internal(err, "could not render the XLSX file")
		}
		if err := f.SetSheetRow(sheet, axis, &values); err != nil {
			return nil, apierr.Internal(err, "could not render the XLSX file")
		}
	}

	buf, err := f.WriteToBuffer()
	if err != nil {
		return nil, apierr.Internal(err, "could not render the XLSX file")
	}
	return buf.Bytes(), nil
}

// contentTypeFor maps an export format onto its MIME type.
func contentTypeFor(format string) string {
	if format == FormatXLSX {
		return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
	}
	return "text/csv; charset=utf-8"
}

// parseFormat validates the ?format query parameter.
func parseFormat(raw string) (string, error) {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "", FormatCSV:
		return FormatCSV, nil
	case FormatXLSX:
		return FormatXLSX, nil
	default:
		return "", apierr.Validation("invalid query parameter",
			apierr.FieldError{Field: "format", Message: "must be one of: csv, xlsx"})
	}
}
