// Export hardening: a CSV or XLSX export is opened in a spreadsheet, so a cell
// that starts with a formula trigger is executable code on the reader's
// machine. Every cell of a report comes from tenant data (unit numbers, driver
// names, DVIR locations), which any user with `units.update` can set.
package reports

import (
	"encoding/csv"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCSVExportNeutralisesFormulaInjection(t *testing.T) {
	table := Table{
		Headers: []string{"Unit", "Name", "Distance (m)"},
		Rows: [][]string{
			{"=cmd|'/c calc'!A1", "+1+1", "412345"},
			{"@SUM(A1:A9)", "-DDE(\"cmd\";\"/c calc\")", "-500"},
			{"1021", "John Miller", "0"},
		},
	}

	body, err := RenderCSV(table)
	require.NoError(t, err)

	rows, err := csv.NewReader(strings.NewReader(string(body))).ReadAll()
	require.NoError(t, err)
	require.Len(t, rows, 4)

	for _, cell := range []string{rows[1][0], rows[1][1], rows[2][0], rows[2][1]} {
		require.True(t, strings.HasPrefix(cell, "'"),
			"a formula trigger must be escaped, got %q", cell)
	}
	// Numbers stay numbers: a negative odometer change is data, not a formula.
	require.Equal(t, "412345", rows[1][2])
	require.Equal(t, "-500", rows[2][2])
	require.Equal(t, "1021", rows[3][0])
	require.Equal(t, "John Miller", rows[3][1])
}

func TestHTMLExportEscapesTenantText(t *testing.T) {
	body, err := RenderHTML(Table{
		Title:    "Activity report",
		Subtitle: `<script>alert(1)</script>`,
		Headers:  []string{"Unit"},
		Rows:     [][]string{{`<img src=x onerror=alert(1)>`}},
	})
	require.NoError(t, err)
	require.NotContains(t, string(body), "<script>")
	require.NotContains(t, string(body), "<img ")
	require.Contains(t, string(body), "&lt;script&gt;")
	require.Contains(t, string(body), "&lt;img src=x onerror=alert(1)&gt;")
}
