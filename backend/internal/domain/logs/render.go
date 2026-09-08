package logs

import (
	"bytes"
	"context"
	"encoding/base64"
	"fmt"
	"html/template"
	"log/slog"
	"time"

	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/chromedp"

	"github.com/devline/onebook-eld/internal/domain/logs/dto"
	"github.com/devline/onebook-eld/internal/tenant"
)

// Renderer turns the rendered report HTML into the delivered document.
type Renderer interface {
	// Render answers the document bytes together with its content type.
	Render(ctx context.Context, html []byte) ([]byte, string, error)
}

// Mail is one outgoing inspection e-mail (Q55).
type Mail struct {
	To          string
	Subject     string
	Body        string
	Attachment  []byte
	Filename    string
	ContentType string
}

// Mailer delivers the inspection report.
type Mailer interface {
	Send(ctx context.Context, m Mail) error
}

// ObjectStore stores the produced transfer archive. It is satisfied by
// storage.Putter.
type ObjectStore interface {
	PutObject(ctx context.Context, key string, body []byte, contentType string) error
}

// TokenIssuer mints the short lived, read only roadside token (Q54). It is
// satisfied by *auth.TokenService.
type TokenIssuer interface {
	Issue(p *tenant.Principal) (string, time.Time, error)
}

// HTMLRenderer is the fallback used when no headless Chrome is reachable: the
// caller receives the report as HTML instead of PDF.
//
// TODO(stage-6): wire ChromeRenderer from cmd/api and cmd/worker once the
// deployment image ships a Chromium binary; until then the API degrades to
// text/html rather than failing the roadside inspection.
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
		return nil, fmt.Errorf("logs: chromedp print: %w", err)
	}
	return out, nil
}

// LogMailer records the delivery instead of sending it.
//
// TODO(stage-6): replace with the internal/notify Notifier (SMTP/SES) once the
// notification module lands; the inspection flow already carries the PDF.
type LogMailer struct {
	Log *slog.Logger
}

// Send implements Mailer. The recipient address is PII, so only its domain is
// logged.
func (m LogMailer) Send(ctx context.Context, msg Mail) error {
	log := m.Log
	if log == nil {
		log = slog.Default()
	}
	log.InfoContext(ctx, "inspection report prepared for delivery",
		"subject", msg.Subject, "bytes", len(msg.Attachment), "filename", msg.Filename)
	return nil
}

// reportTemplate renders the log grid, the event list and the log form (Q55).
var reportTemplate = template.Must(template.New("report").Funcs(template.FuncMap{
	"pct":   gridPercent,
	"hours": gridHours,
	"kmOf":  func(m int64) string { return fmt.Sprintf("%.1f", float64(m)/1000) },
}).Parse(reportHTML))

const reportHTML = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>Driver's Daily Log</title>
<style>
 body{font:12px/1.4 -apple-system,Segoe UI,Roboto,sans-serif;color:#111;margin:24px}
 h1{font-size:18px;margin:0 0 4px} h2{font-size:14px;margin:18px 0 6px}
 table{border-collapse:collapse;width:100%;margin-bottom:12px}
 th,td{border:1px solid #ccc;padding:4px 6px;text-align:left;font-size:11px}
 th{background:#f3f4f6}
 .grid{position:relative;height:96px;border:1px solid #444;margin:8px 0}
 .row{position:absolute;left:0;right:0;height:24px;border-bottom:1px dashed #bbb}
 .lbl{position:absolute;left:2px;top:4px;font-size:9px;color:#666}
 .bar{position:absolute;height:4px;background:#111}
 .meta span{margin-right:16px}
 .page{page-break-after:always}
</style></head><body>
<h1>Driver's Daily Log</h1>
<div class="meta">
 <span><b>Driver:</b> {{.DriverName}}</span>
 <span><b>Carrier:</b> {{.CarrierName}}</span>
 <span><b>Home terminal:</b> {{if .HomeTerminalAddress}}{{.HomeTerminalAddress}}{{else}}—{{end}}</span>
 <span><b>Timezone:</b> {{.Timezone}}</span>
 <span><b>Window:</b> {{.From}} … {{.To}}</span>
 <span><b>Generated:</b> {{.GeneratedAt.Format "2006-01-02 15:04 UTC"}}</span>
</div>
{{range .Days}}
<div class="page">
<h2>{{.LogDate}} — {{.CertificationStatus}}</h2>
<div class="grid">
 <div class="row" style="top:0"><span class="lbl">OFF</span></div>
 <div class="row" style="top:24px"><span class="lbl">SB</span></div>
 <div class="row" style="top:48px"><span class="lbl">DR</span></div>
 <div class="row" style="top:72px"><span class="lbl">ON</span></div>
 {{range .Events}}{{if .Status}}<div class="bar" style="left:{{pct .EventTime}}%;top:{{hours .Status}}px;width:2px"></div>{{end}}{{end}}
</div>
<table>
 <tr><th>Off duty</th><th>Sleeper</th><th>Driving</th><th>On duty</th><th>Distance (km)</th></tr>
 <tr><td>{{.Totals.OffMin}} min</td><td>{{.Totals.SBMin}} min</td><td>{{.Totals.DriveMin}} min</td>
     <td>{{.Totals.OnMin}} min</td><td>{{kmOf .DistanceM}}</td></tr>
</table>
<h2>Log form</h2>
<table>
 <tr><th>Units</th><td>{{range .Form.Units}}{{.UnitNumber}} {{end}}</td>
     <th>Co-driver</th><td>{{if .Form.CoDriverName}}{{.Form.CoDriverName}}{{else}}—{{end}}</td></tr>
 <tr><th>Trailers</th><td>{{range .Form.Trailers}}{{.Number}} {{end}}</td>
     <th>Shipping docs</th><td>{{range .Form.ShippingDocs}}{{.Number}} {{end}}</td></tr>
 <tr><th>Signed at</th><td>{{if .Form.SignedAt}}{{.Form.SignedAt.Format "2006-01-02 15:04 UTC"}}{{else}}not certified{{end}}</td>
     <th>Signature</th><td>{{if .Form.SignatureKey}}on file{{else}}—{{end}}</td></tr>
</table>
<h2>Events</h2>
<table>
 <tr><th>Time (UTC)</th><th>Type</th><th>Status</th><th>Special</th><th>Origin</th><th>Location</th><th>Odometer</th><th>Note</th></tr>
 {{range .Events}}<tr>
  <td>{{.EventTime.Format "15:04:05"}}</td><td>{{.EventType}}</td><td>{{.Status}}</td><td>{{.Special}}</td>
  <td>{{.Origin}}{{if .Edited}} ✎{{end}}</td>
  <td>{{if .LocationText}}{{.LocationText}}{{else}}—{{end}}</td>
  <td>{{if .OdometerM}}{{kmOf .OdometerM}} km{{else}}—{{end}}</td>
  <td>{{if .Notes}}{{.Notes}}{{else}}—{{end}}</td>
 </tr>{{end}}
</table>
{{if .Violations}}
<h2>Violations</h2>
<table><tr><th>Type</th><th>Severity</th><th>At (UTC)</th><th>Resolved</th></tr>
 {{range .Violations}}<tr><td>{{.Type}}</td><td>{{.Severity}}</td>
  <td>{{.OccurredAt.Format "2006-01-02 15:04"}}</td>
  <td>{{if .ResolvedAt}}{{.ResolvedReason}}{{else}}open{{end}}</td></tr>{{end}}
</table>{{end}}
</div>
{{end}}
</body></html>`

// gridPercent maps an instant onto the 24 hour grid.
func gridPercent(t time.Time) string {
	minutes := t.UTC().Hour()*60 + t.UTC().Minute()
	return fmt.Sprintf("%.3f", float64(minutes)/1440*100)
}

// gridHours maps a duty status onto its grid row offset.
func gridHours(status string) int {
	switch status {
	case "OFF":
		return 20
	case "SB":
		return 44
	case "DR":
		return 68
	case "ON":
		return 92
	}
	return 20
}

// RenderReportHTML renders the roadside report (log grid + events + log form).
func RenderReportHTML(rep dto.InspectionReport) ([]byte, error) {
	var buf bytes.Buffer
	if err := reportTemplate.Execute(&buf, rep); err != nil {
		return nil, fmt.Errorf("logs: render report: %w", err)
	}
	return buf.Bytes(), nil
}
