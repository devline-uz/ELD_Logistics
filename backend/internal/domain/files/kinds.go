package files

import (
	"net/http"
	"sort"
	"strings"

	"github.com/devline/onebook-eld/internal/apierr"
)

// Upload kinds (TZ B§3.4). The list is closed: anything else is rejected
// before a signature is ever produced.
const (
	KindDVIRPhoto = "dvir_photo"
	KindInvoice   = "invoice"
	KindSignature = "signature"
	KindLogo      = "logo"
	KindChat      = "chat"
	KindImport    = "import"
)

// Size ceilings (TZ §18.3).
const (
	maxDVIRPhotoBytes = 5 << 20  // 5 MiB per photo
	maxInvoiceBytes   = 10 << 20 // 10 MiB
	maxSignatureBytes = 1 << 20
	maxLogoBytes      = 2 << 20
	maxChatBytes      = 10 << 20
	maxImportBytes    = 5 << 20
)

// Content types accepted per kind.
var (
	imageTypes = []string{"image/jpeg", "image/png", "image/webp", "image/heic"}
	docTypes   = []string{"application/pdf", "image/jpeg", "image/png"}
	sheetTypes = []string{
		"text/csv",
		"application/csv",
		"application/vnd.ms-excel",
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
	}
)

type kindPolicy struct {
	maxBytes     int64
	contentTypes []string
}

var kindPolicies = map[string]kindPolicy{
	KindDVIRPhoto: {maxDVIRPhotoBytes, imageTypes},
	KindInvoice:   {maxInvoiceBytes, docTypes},
	KindSignature: {maxSignatureBytes, []string{"image/png", "image/jpeg", "image/svg+xml"}},
	KindLogo:      {maxLogoBytes, []string{"image/png", "image/jpeg", "image/svg+xml", "image/webp"}},
	KindChat:      {maxChatBytes, append(append([]string{}, imageTypes...), "application/pdf")},
	KindImport:    {maxImportBytes, sheetTypes},
}

// AllowedKinds lists every accepted upload kind, sorted for the docs.
func AllowedKinds() []string {
	out := make([]string, 0, len(kindPolicies))
	for k := range kindPolicies {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}

// checkUpload validates the kind, its content type and its size ceiling. The
// whitelist is enforced here, before internal/storage ever signs anything.
func checkUpload(kind, contentType string, size int64) (int64, error) {
	policy, ok := kindPolicies[kind]
	if !ok {
		return 0, apierr.Validation("unsupported upload kind", apierr.FieldError{
			Field: "kind", Message: "must be one of: " + strings.Join(AllowedKinds(), ", "),
		})
	}

	ct := normaliseContentType(contentType)
	allowed := false
	for _, t := range policy.contentTypes {
		if t == ct {
			allowed = true
			break
		}
	}
	if !allowed {
		return 0, apierr.New(apierr.CodeFileTypeInvalid, http.StatusUnprocessableEntity,
			"content_type is not allowed for kind "+kind).WithDetails(apierr.FieldError{
			Field: "content_type", Message: "must be one of: " + strings.Join(policy.contentTypes, ", "),
		})
	}

	if size > policy.maxBytes {
		return 0, apierr.New(apierr.CodeFileTooLarge, http.StatusRequestEntityTooLarge,
			"file is larger than the limit for kind "+kind).WithDetails(apierr.FieldError{
			Field: "size_bytes", Message: "must be at most " + byteSize(policy.maxBytes),
		})
	}

	return policy.maxBytes, nil
}

// normaliseContentType drops parameters ("; charset=utf-8") and lowercases.
func normaliseContentType(v string) string {
	if i := strings.IndexByte(v, ';'); i >= 0 {
		v = v[:i]
	}
	return strings.ToLower(strings.TrimSpace(v))
}

func byteSize(n int64) string {
	switch {
	case n >= 1<<20:
		return itoa(n/(1<<20)) + " MiB"
	case n >= 1<<10:
		return itoa(n/(1<<10)) + " KiB"
	default:
		return itoa(n) + " B"
	}
}

func itoa(n int64) string {
	if n == 0 {
		return "0"
	}
	var buf [20]byte
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	return string(buf[i:])
}
