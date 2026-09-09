package main

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
)

// jsonBytes marshals a value for a jsonb parameter.
func jsonBytes(v any) ([]byte, error) {
	out, err := json.Marshal(v)
	if err != nil {
		return nil, fmt.Errorf("marshal json: %w", err)
	}
	return out, nil
}

// quoteLiteral escapes a value for the few statements that cannot take a bind
// parameter (SET LOCAL). Every caller passes a uuid, never user input.
func quoteLiteral(v string) string {
	return "'" + strings.ReplaceAll(v, "'", "''") + "'"
}

// upperKey is the short uppercase tenant tag used in seeded serial numbers.
func upperKey(key string) string {
	if len(key) > 3 {
		key = key[:3]
	}
	return strings.ToUpper(key)
}

// uuidStrings renders ids for a ::uuid[] parameter.
func uuidStrings(ids ...uuid.UUID) []string {
	out := make([]string, 0, len(ids))
	for _, id := range ids {
		out = append(out, id.String())
	}
	return out
}

// mustLocation resolves an IANA zone, falling back to UTC so a missing tzdata
// entry cannot abort the seed.
func mustLocation(name string) *time.Location {
	loc, err := time.LoadLocation(name)
	if err != nil {
		return time.UTC
	}
	return loc
}

// dayStart is midnight of the day offset days back from now, in loc.
func dayStart(now time.Time, loc *time.Location, offset int) time.Time {
	local := now.In(loc).AddDate(0, 0, offset)
	return time.Date(local.Year(), local.Month(), local.Day(), 0, 0, 0, 0, loc)
}

// at returns the local wall clock time of a day plus hour/minute, in UTC.
func at(day time.Time, hour, minute int) time.Time {
	return day.Add(time.Duration(hour)*time.Hour + time.Duration(minute)*time.Minute).UTC()
}
