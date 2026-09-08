package reports

import (
	"archive/zip"
	"bytes"
	"context"
	"encoding/csv"
	"fmt"
	"html/template"
	"strconv"
	"time"

	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/chromedp"
	"github.com/xuri/excelize/v2"

	"github.com/devline/onebook-eld/internal/domain/reports/dto"
)

// Table is the shape every tabular report is reduced to before rendering. One
// intermediate keeps CSV, XLSX and PDF byte-identical in content.
type Table struct {
	// Title is the document heading.
	Title string
	// Subtitle carries the window and the filters the report was built with.
	Subtitle string
	// Headers is the column row.
	Headers []string
	// Rows is the body; every row must have len(Headers) cells.
	Rows [][]string
}

// Renderer turns report HTML into the delivered document. It mirrors the daily
// log and DVIR renderers so every PDF surface degrades the same way when no
// headless Chrome is reachable.
type Renderer interface {
	// Render answers the document bytes together with its content type.
	Render(ctx context.Context, html []byte) ([]byte, string, error)
}

// HTMLRenderer is the fallback used when no headless Chrome is reachable: the
// caller receives the report as HTML instead of PDF.
type HTMLRenderer struct{}

// Render implements Renderer.
func (HTMLRenderer) Render(_ context.Context, html []byte) ([]byte, string, error) {
	return html, "text/html; charset=utf-8", nil
}

// ChromeRenderer prints the report with headless Chrome (chromedp).
type ChromeRenderer struct {
	// Timeout bounds one print job.
	Timeout time.Duration
	// Fallback answers when Chrome is unreachable; nil means the error wins.
	Fallback Renderer
}

// Render implements Renderer.
func (c ChromeRenderer) Render(ctx context.Context, html []byte) ([]byte, string, error) {
	timeout := c.Timeout
	if timeout <= 0 {
		timeout = 60 * time.Second
	}
	pdf, err := c.print(ctx, html, timeout)
	if err != nil {
		if c.Fallback != nil {
			return c.Fallback.Render(ctx, html)
		}
		return nil, "", err
	}
	return pdf, "application/pdf", nil
}

func (c ChromeRenderer) print(ctx context.Context, html []byte, timeout time.Duration) ([]byte, error) {
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()
	allocCtx, cancelAlloc := chromedp.NewContext(ctx)
	defer cancelAlloc()

	var out []byte
	err := chromedp.Run(allocCtx,
		chromedp.Navigate("about:blank"),
		chromedp.ActionFunc(func(ctx context.Context) error {
			frame, err := page.GetFrameTree().Do(ctx)
			if err != nil {
				return err
			}
			return page.SetDocumentContent(frame.Frame.ID, string(html)).Do(ctx)
		}),
		chromedp.ActionFunc(func(ctx context.Context) error {
			data, _, err := page.PrintToPDF().WithPrintBackground(true).Do(ctx)
			if err != nil {
				return err
			}
			out = data
			return nil
		}),
	)
	return out, err
}

// RenderCSV writes the table as RFC 4180 CSV.
func RenderCSV(t Table) ([]byte, error) {
	var buf bytes.Buffer
	w := csv.NewWriter(&buf)
	if err := w.Write(safeRow(t.Headers)); err != nil {
		return nil, err
	}
	for _, row := range t.Rows {
		if err := w.Write(safeRow(row)); err != nil {
			return nil, err
		}
	}
	w.Flush()
	return buf.Bytes(), w.Error()
}

// safeCell neutralises spreadsheet formula injection. A cell whose text comes
// from tenant data (a unit number, a driver name, a location) must never be
// evaluated when the CSV is opened in Excel or Sheets, so a leading formula
// trigger is escaped with a single quote. XLSX is written through SetCellStr,
// which is already inert.
func safeCell(v string) string {
	if v == "" {
		return v
	}
	switch v[0] {
	case '=', '+', '-', '@', '\t', '\r':
		// A negative metre or second count is data, not a formula.
		if _, err := strconv.ParseFloat(v, 64); err == nil {
			return v
		}
		return "'" + v
	}
	return v
}

func safeRow(in []string) []string {
	out := make([]string, len(in))
	for i, v := range in {
		out[i] = safeCell(v)
	}
	return out
}

// sheetName is the single worksheet every export writes into.
const sheetName = "Report"

// RenderXLSX writes the table as an Excel workbook.
func RenderXLSX(t Table) ([]byte, error) {
	f := excelize.NewFile()
	defer f.Close()

	idx, err := f.NewSheet(sheetName)
	if err != nil {
		return nil, err
	}
	f.SetActiveSheet(idx)
	// excelize seeds every workbook with a default sheet we do not use.
	if def := f.GetSheetName(0); def != "" && def != sheetName {
		_ = f.DeleteSheet(def)
	}

	for col, h := range t.Headers {
		cell, err := excelize.CoordinatesToCellName(col+1, 1)
		if err != nil {
			return nil, err
		}
		if err := f.SetCellStr(sheetName, cell, h); err != nil {
			return nil, err
		}
	}
	for r, row := range t.Rows {
		for c, v := range row {
			cell, err := excelize.CoordinatesToCellName(c+1, r+2)
			if err != nil {
				return nil, err
			}
			if err := f.SetCellStr(sheetName, cell, v); err != nil {
				return nil, err
			}
		}
	}

	buf, err := f.WriteToBuffer()
	if err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// reportHTML is the print stylesheet shared by every PDF export. It is
// deliberately plain: a regulator reads the numbers, not the design.
var reportHTML = template.Must(template.New("report").Parse(`<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>{{.Title}}</title>
<style>
 @page { size: A4 landscape; margin: 12mm; }
 body { font-family: -apple-system, "Helvetica Neue", Arial, sans-serif; font-size: 10px; color: #111; }
 h1 { font-size: 16px; margin: 0 0 2mm 0; }
 .sub { color: #555; margin: 0 0 4mm 0; }
 table { border-collapse: collapse; width: 100%; }
 th, td { border: 1px solid #bbb; padding: 3px 5px; text-align: left; vertical-align: top; }
 th { background: #eee; font-weight: 600; }
 tbody tr:nth-child(even) { background: #fafafa; }
</style></head><body>
<h1>{{.Title}}</h1>
<p class="sub">{{.Subtitle}}</p>
<table><thead><tr>{{range .Headers}}<th>{{.}}</th>{{end}}</tr></thead>
<tbody>{{range .Rows}}<tr>{{range .}}<td>{{.}}</td>{{end}}</tr>{{end}}</tbody></table>
</body></html>`))

// RenderHTML turns the table into the print document source.
func RenderHTML(t Table) ([]byte, error) {
	var buf bytes.Buffer
	if err := reportHTML.Execute(&buf, t); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// zipEntry is one member of a bundle archive.
type zipEntry struct {
	Name string
	Body []byte
}

// RenderZIP packs several rendered documents into one archive. It is the
// regulator bundle: a PDF for the inspector and a CSV for the back office.
func RenderZIP(entries []zipEntry) ([]byte, error) {
	var buf bytes.Buffer
	w := zip.NewWriter(&buf)
	for _, e := range entries {
		f, err := w.Create(e.Name)
		if err != nil {
			return nil, err
		}
		if _, err := f.Write(e.Body); err != nil {
			return nil, err
		}
	}
	if err := w.Close(); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// contentTypeFor maps an export format onto its MIME type.
func contentTypeFor(format string) string {
	switch format {
	case dto.FormatCSV:
		return "text/csv; charset=utf-8"
	case dto.FormatXLSX:
		return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
	case dto.FormatPDF:
		return "application/pdf"
	case dto.FormatZIP:
		return "application/zip"
	default:
		return "application/octet-stream"
	}
}

// extFor maps a content type onto the file extension the download should use.
// A PDF that fell back to HTML must not be delivered as `.pdf`.
func extFor(contentType, format string) string {
	switch {
	case contentType == "text/html; charset=utf-8":
		return ".html"
	case format == dto.FormatXLSX:
		return ".xlsx"
	case format == dto.FormatCSV:
		return ".csv"
	case format == dto.FormatPDF:
		return ".pdf"
	case format == dto.FormatZIP:
		return ".zip"
	default:
		return ".bin"
	}
}

// metresRow formats a metre value for a report cell. Reports ship metres: the
// backend never converts units (TZ B§6.1).
func metresRow(v int64) string { return fmt.Sprintf("%d", v) }
