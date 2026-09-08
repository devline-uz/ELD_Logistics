// Package pgconv holds the conversions between Go domain types and the pgtype
// wrappers sqlc generates. Every domain package shares these helpers so the
// NULL semantics of a column stay identical across modules.
package pgconv

import (
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
)

// UUID maps a value UUID onto pgtype. The nil UUID becomes SQL NULL.
func UUID(id uuid.UUID) pgtype.UUID {
	if id == uuid.Nil {
		return pgtype.UUID{}
	}
	return pgtype.UUID{Bytes: id, Valid: true}
}

// UUIDPtr maps an optional UUID onto pgtype. Both a nil pointer and the nil
// UUID become SQL NULL.
func UUIDPtr(id *uuid.UUID) pgtype.UUID {
	if id == nil {
		return pgtype.UUID{}
	}
	return UUID(*id)
}

// ToUUIDPtr reads a nullable UUID column.
func ToUUIDPtr(v pgtype.UUID) *uuid.UUID {
	if !v.Valid {
		return nil
	}
	id := uuid.UUID(v.Bytes)
	return &id
}

// UUIDString renders a nullable UUID column as an optional string.
func UUIDString(v pgtype.UUID) *string {
	if !v.Valid {
		return nil
	}
	s := uuid.UUID(v.Bytes).String()
	return &s
}

// UUIDStringOrEmpty renders a nullable UUID column, using "" for NULL.
func UUIDStringOrEmpty(v pgtype.UUID) string {
	if !v.Valid {
		return ""
	}
	return uuid.UUID(v.Bytes).String()
}

// Time maps a value timestamp onto pgtype. The zero time becomes SQL NULL and
// every stored instant is normalised to UTC.
func Time(t time.Time) pgtype.Timestamptz {
	if t.IsZero() {
		return pgtype.Timestamptz{}
	}
	return pgtype.Timestamptz{Time: t.UTC(), Valid: true}
}

// TimePtr maps an optional timestamp onto pgtype.
func TimePtr(t *time.Time) pgtype.Timestamptz {
	if t == nil {
		return pgtype.Timestamptz{}
	}
	return pgtype.Timestamptz{Time: t.UTC(), Valid: true}
}

// ToTimePtr reads a nullable timestamptz column as UTC.
func ToTimePtr(v pgtype.Timestamptz) *time.Time {
	if !v.Valid {
		return nil
	}
	t := v.Time.UTC()
	return &t
}

// Deref reads a nullable text column, using "" for NULL.
func Deref(v *string) string {
	if v == nil {
		return ""
	}
	return *v
}

// NilIfEmpty writes an empty string as SQL NULL.
func NilIfEmpty(v string) *string {
	if v == "" {
		return nil
	}
	return &v
}
