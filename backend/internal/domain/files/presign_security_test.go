//go:build integration

// The declared upload size must be signed into the URL, not merely validated:
// otherwise POST /files/presign is a size check the client can walk around by
// PUTting a bigger body to the very same signature.
package files_test

import (
	"net/http"
	"strconv"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/devline/onebook-eld/internal/domain/files/dto"
	"github.com/devline/onebook-eld/internal/testutil"
)

func TestPresignSignsTheDeclaredSize(t *testing.T) {
	t.Parallel()
	srv, fake := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	const size = int64(1 << 20)
	resp := client.Post("/api/v1/files/presign", dto.PresignRequest{
		Kind: "dvir_photo", ContentType: "image/jpeg", SizeBytes: size,
		Filename: "pre-trip-front.jpg",
	})
	testutil.RequireStatus(t, resp, http.StatusOK)

	var env dto.PresignEnvelope
	resp.JSON(&env)

	// size_bytes reaches the signer, and the client is told to send it back.
	require.Len(t, fake.Requests(), 1)
	require.Equal(t, size, fake.Requests()[0].ContentLength,
		"size_bytes must be handed to the presigner, not only validated")
	require.Equal(t, strconv.FormatInt(size, 10), env.Data.Headers["Content-Length"])
	require.Equal(t, "image/jpeg", env.Data.Headers["Content-Type"])
	require.LessOrEqual(t, size, env.Data.MaxBytes)
}

// A size above the per kind ceiling never reaches the signer at all.
func TestPresignRejectsAnOversizedDeclarationBeforeSigning(t *testing.T) {
	t.Parallel()
	srv, fake := newServer(t)
	tn := testutil.SeedTenant(t, filePermissions...)
	client := srv.AsTenant(tn)

	resp := client.Post("/api/v1/files/presign", dto.PresignRequest{
		Kind: "dvir_photo", ContentType: "image/jpeg", SizeBytes: (5 << 20) + 1,
	})
	require.Equal(t, http.StatusRequestEntityTooLarge, resp.Code)
	require.Empty(t, fake.Requests(), "nothing may be signed for a rejected size")
}
