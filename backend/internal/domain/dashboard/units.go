package dashboard

import "github.com/devline/onebook-eld/internal/apierr"

// errUnknownUnits is returned when a filter names a unit the tenant does not
// own. It is a 404 so the existence of another company's unit is never
// confirmed.
var errUnknownUnits = apierr.NotFound("unit")
