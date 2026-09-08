// Attachment key hardening (Q77, TZ B§3.4). A ticket or a ticket message
// stores a raw object key the client sent. Without a tenant check the key is a
// pointer into any bucket path, and a presigned GET issued later would honour
// whatever was stored — a cross-tenant file read through the support desk.
package support

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

func TestNormalizeAttachmentsRefusesForeignKeys(t *testing.T) {
	mine := uuid.New()
	theirs := uuid.New()

	ok, err := normalizeAttachments(mine, []string{
		mine.String() + "/chat/2026/09/a.jpg",
		"  " + mine.String() + "/chat/2026/09/b.pdf  ",
		"",
	})
	require.NoError(t, err)
	require.Len(t, ok, 2, "empty entries are dropped, own keys are kept")

	for _, bad := range []string{
		theirs.String() + "/chat/2026/09/a.jpg",                  // another tenant's object
		"tickets/2026/09/a.jpg",                                  // no tenant prefix at all
		"/" + mine.String() + "/chat/a.jpg",                      // absolute path
		mine.String() + "/../" + theirs.String() + "/chat/a.jpg", // traversal
		mine.String(),       // bare prefix, no object
		mine.String() + "/", // bare prefix with a slash
		uuid.Nil.String() + "/chat/a.jpg",
	} {
		_, err := normalizeAttachments(mine, []string{bad})
		require.Error(t, err, "key %q must be refused", bad)
	}
}

func TestNormalizeAttachmentsKeepsTheQ77Budget(t *testing.T) {
	mine := uuid.New()
	key := func(n string) string { return mine.String() + "/chat/2026/09/" + n + ".jpg" }

	_, err := normalizeAttachments(mine, []string{key("a"), key("b"), key("c")})
	require.NoError(t, err)

	_, err = normalizeAttachments(mine, []string{key("a"), key("b"), key("c"), key("d")})
	require.Error(t, err, "at most three files per ticket (Q77)")
}
