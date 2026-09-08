package dvir

import (
	"bytes"
	"context"
	"encoding/base64"
	"fmt"
	"html/template"
	"time"

	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/chromedp"

	"github.com/devline/onebook-eld/internal/apierr"
	"github.com/devline/onebook-eld/internal/domain/dvir/dto"
)

// Renderer turns the rendered report HTML into the delivered document. It
// mirrors the daily log renderer of internal/domain/logs so both surfaces
// degrade the same way when no headless Chrome is reachable.
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
		timeout = 30 * time.Second
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

	allocCtx, cancelAlloc := chromedp.NewExecAllocator(ctx, chromedp.DefaultExecAllocatorOptions[:]...)
	defer cancelAlloc()
	browserCtx, cancelBrowser := chromedp.NewContext(allocCtx)
	defer cancelBrowser()

	url := "data:text/html;base64," + base64.StdEncoding.EncodeToString(html)
	var out []byte
	err := chromedp.Run(browserCtx,
		chromedp.Navigate(url),
		chromedp.ActionFunc(func(ctx context.Context) error {
			buf, _, err := page.PrintToPDF().WithPrintBackground(true).Do(ctx)
			if err != nil {
				return err
			}
			out = buf
			return nil
		}),
	)
	if err != nil {
		return nil, fmt.Errorf("dvir: chromedp print: %w", err)
	}
	return out, nil
}

// RenderPDF builds the FMCSA style inspection report. Signature images stay
// object storage keys: the document references them, it never embeds PII.
func (s *Service) RenderPDF(ctx context.Context, rep dto.DvirReport) ([]byte, string, error) {
	var buf bytes.Buffer
	if err := reportTemplate.Execute(&buf, rep); err != nil {
		return nil, "", apierr.Internal(err, "could not render the DVIR report")
	}
	body, contentType, err := s.renderer.Render(ctx, buf.Bytes())
	if err != nil {
		return nil, "", apierr.Wrap(err, apierr.CodeUpstreamError, 502, "could not print the DVIR report")
	}
	return body, contentType, nil
}

// ExtFor maps the produced content type onto a file extension.
func ExtFor(contentType string) string {
	if contentType == "application/pdf" {
		return ".pdf"
	}
	return ".html"
}

var reportTemplate = template.Must(template.New("dvir").Funcs(template.FuncMap{
	"ts": func(v any) string {
		switch t := v.(type) {
		case time.Time:
			return t.UTC().Format(time.RFC3339)
		case *time.Time:
			if t == nil {
				return ""
			}
			return t.UTC().Format(time.RFC3339)
		}
		return ""
	},
}).Parse(`<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>DVIR {{.ID}}</title>
<style>
body{font-family:Helvetica,Arial,sans-serif;font-size:11px;color:#111;margin:24px}
h1{font-size:16px;margin:0 0 4px}
table{border-collapse:collapse;width:100%;margin-top:10px}
th,td{border:1px solid #999;padding:4px 6px;text-align:left;vertical-align:top}
th{background:#eee}
.crit{color:#b00020;font-weight:bold}
.meta td:first-child{width:180px;font-weight:bold;background:#f6f6f6}
</style></head><body>
<h1>Driver Vehicle Inspection Report</h1>
<div>{{.Type}} &middot; status {{.Status}} ({{.Kind}})</div>
<table class="meta">
<tr><td>Report</td><td>{{.ID}}</td></tr>
<tr><td>Unit</td><td>{{.UnitNumber}}{{if .OutOfService}} <span class="crit">OUT OF SERVICE</span>{{end}}</td></tr>
{{with .Driver}}<tr><td>Driver</td><td>{{.FirstName}} {{.LastName}}</td></tr>{{end}}
<tr><td>Performed at (UTC)</td><td>{{ts .PerformedAt}}</td></tr>
<tr><td>Location</td><td>{{.LocationText}}{{if .Lat}} ({{.Lat}}, {{.Lng}}){{end}}</td></tr>
<tr><td>Odometer (m)</td><td>{{if .OdometerM}}{{.OdometerM}}{{else}}&mdash;{{end}}</td></tr>
<tr><td>Engine hours</td><td>{{if .EngineHours}}{{.EngineHours}}{{else}}&mdash;{{end}}</td></tr>
<tr><td>Source</td><td>{{.Source}}</td></tr>
</table>

<h2>Defects</h2>
{{if .Defects}}
<table>
<tr><th>Item</th><th>Category</th><th>Critical</th><th>Note</th><th>Photos</th></tr>
{{range .Defects}}<tr>
<td>{{.Name}}</td><td>{{.Category}}</td>
<td>{{if .IsCritical}}<span class="crit">yes</span>{{else}}no{{end}}</td>
<td>{{.Note}}</td><td>{{len .PhotoKeys}}</td>
</tr>{{end}}
</table>
{{else}}<p>No defects reported.</p>{{end}}

<h2>Signatures &amp; repair</h2>
<table class="meta">
<tr><td>Driver signature</td><td>{{if .DriverSignatureKey}}on file{{else}}&mdash;{{end}}</td></tr>
<tr><td>Mechanic note</td><td>{{if .MechanicNote}}{{.MechanicNote}}{{else}}&mdash;{{end}}</td></tr>
<tr><td>Mechanic signature</td><td>{{if .MechanicSignatureKey}}on file{{else}}&mdash;{{end}}</td></tr>
<tr><td>Repaired at (UTC)</td><td>{{if .RepairedAt}}{{ts .RepairedAt}}{{else}}&mdash;{{end}}</td></tr>
<tr><td>Certified at (UTC)</td><td>{{if .CertifiedAt}}{{ts .CertifiedAt}}{{else}}&mdash;{{end}}</td></tr>
<tr><td>Closed at (UTC)</td><td>{{if .ClosedAt}}{{ts .ClosedAt}} &mdash; {{.ClosedReason}}{{else}}&mdash;{{end}}</td></tr>
</table>
</body></html>`))
