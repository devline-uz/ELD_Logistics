package db

import (
	"errors"
	"net/http"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/devline/onebook-eld/internal/apierr"
)

// PostgreSQL SQLSTATE codes handled explicitly.
const (
	sqlStateUniqueViolation     = "23505"
	sqlStateForeignKeyViolation = "23503"
	sqlStateCheckViolation      = "23514"
	sqlStateNotNullViolation    = "23502"
	sqlStateInsufficientPriv    = "42501"
	sqlStateSerializationFail   = "40001"
	sqlStateDeadlockDetected    = "40P01"
)

// MapError converts a pgx error into an *apierr.E. resource names the entity
// for 404 messages. Errors that are already *apierr.E pass through unchanged.
func MapError(err error, resource string) error {
	if err == nil {
		return nil
	}
	if _, ok := apierr.From(err); ok {
		return err
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.NotFound(resource)
	}

	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case sqlStateUniqueViolation:
			return apierr.Wrap(err, apierr.CodeUniqueViolation, http.StatusConflict,
				"a record with these values already exists")
		case sqlStateForeignKeyViolation:
			return apierr.Wrap(err, apierr.CodeConflict, http.StatusConflict,
				"referenced record does not exist or is still in use")
		case sqlStateCheckViolation, sqlStateNotNullViolation:
			return apierr.Wrap(err, apierr.CodeValidationError, http.StatusUnprocessableEntity,
				"request violates a data constraint")
		case sqlStateInsufficientPriv:
			// RLS denial: never disclose existence across tenants.
			return apierr.NotFound(resource)
		case sqlStateSerializationFail, sqlStateDeadlockDetected:
			return apierr.Wrap(err, apierr.CodeConflict, http.StatusConflict,
				"concurrent update, please retry")
		}
	}

	return apierr.Internal(err, "database error")
}

// IsUniqueViolation reports whether err is a Postgres unique violation.
func IsUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == sqlStateUniqueViolation
}

// IsNoRows reports whether err means "no rows returned".
func IsNoRows(err error) bool {
	return errors.Is(err, pgx.ErrNoRows)
}
