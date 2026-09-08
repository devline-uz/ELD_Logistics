# `v1` API review — pre-freeze

Scope: TZ D§3 contract conformance and internal consistency of the current
`docs/swagger.json`, ahead of freezing `v1` (Bosqich 9, tasks.md). This is a
review, not a change — every item below ends in a recommendation
(**saqlash** / **o'chirish** / **TZ ga CR**), no code was touched.

---

## 1. Naming consistency

**Good, and worth keeping as-is:**

- Path segments are uniformly kebab-case for multi-word resources
  (`daily-logs`, `dvir-reports`, `log-edit-requests`, `notification-settings`,
  `maintenance-schedules`, `unidentified-events`, `import-template`,
  `hos-policy`, `export-jobs`). No snake_case or camelCase path segment found.
- JSON body fields and query parameters are uniformly snake_case
  (`driver_id`, `co_driver_id`, `alert_type`, `with_messages`). No field mixes
  case styles.
- Resources are plural (`/units`, `/drivers`, `/violations`, ...); the two
  singular exceptions — `/company` (one row per tenant, there is nothing to
  enumerate) and `/auth`, `/me`, `/app` (not resources) — are intentional and
  match the TZ D§3 table. **Saqlash.**
- Action endpoints consistently follow `POST /resource/{id}/verb`
  (`/activate`, `/deactivate`, `/certify`, `/repair`, `/claim`, `/assign`, ...).
  **Saqlash.**

**No naming inconsistency was found** worth a CR; the deviations that exist
are additions, not renames — see §6.

---

## 2. `null` semantics

The codebase uses two different shapes for "empty" on purpose, and the split
is consistent once you know the rule, but it is **not written down anywhere**:

- **Read models** (list/detail responses): optional scalars are plain
  `string`/non-pointer and serialize to `""`/`0`, never `null`
  (e.g. `fleet/dto.Unit.Notes string`). Fields that are genuinely meaningful
  as "absent" use a pointer (`*time.Time` for `last_login_at`,
  `*float64` for chat `lat`/`lng` — 0,0 is a real coordinate, so it cannot
  stand for "no location").
- **Update models** (`PATCH` bodies): the same field becomes a pointer
  (`*string Notes`) so the handler can distinguish "field omitted, don't
  touch" from "field sent as empty string, clear it" — this is the pointer
  convention the API contract skill already names ("`PATCH` — qisman
  yangilash (pointer maydonlar)").

This dual shape (checked across `fleet`, `drivers`, `maintenance`, `logs`,
`duty` DTOs) is applied consistently. **Recommendation: saqlash the
behaviour, TZ ga CR to add one sentence to D§3** stating the rule explicitly
("javobda ixtiyoriy maydon `null` emas, standart qiymat; `PATCH` so'rovida
ixtiyoriy maydon pointer — yo'q bo'lsa o'zgarmaydi, `null`/bo'sh bo'lsa
tozalanadi") so a frontend/mobile client author does not have to reverse
engineer it from the Swagger schema.

---

## 3. Pagination

`internal/httpx/pagination.go` + `ListEnvelope` are applied uniformly:
`?page` (default 1) / `?per_page` (default 25, allowed 10/25/50, hard cap
100 — over-cap answers `422` with `field: "per_page"`), response
`{"data":[...],"meta":{"page":1,"per_page":25,"total":N}}`. No endpoint was
found returning a bare array or a different meta shape. **Saqlash.**

One gap: the contract doesn't say what a client should assume about `total`
under RLS-filtered `scope=self` (driver) queries — is `total` the count
visible to the caller or the tenant-wide count? Sampling the driver-scoped
list handlers shows the `Count...` sqlc query always carries the same
`WHERE` as the `List...` query, so `total` is always "what this caller can
see" — consistent, just undocumented. **TZ ga CR** (one line in D§3).

---

## 4. Error codes

`internal/apierr/codes.go` is the single const block the conventions require
— 84 codes, all `UPPER_SNAKE_CASE`, no duplicates, no ad-hoc string literals
found outside it (`apierr.E{Code: ...}` is the only construction site).
Status mapping is consistent: `422` for `VALIDATION_ERROR` /
field-level failures, `400` for malformed input, `401`/`403`/`404`/`409`/`429`
used as documented, cross-tenant reads confirmed to answer `404` (not `403`)
in the handlers sampled (`drivers`, `fleet`, `maintenance`). **Saqlash.**

---

## 5. Date/time format

All timestamps are `time.Time` (UTC, `timestamptz` in Postgres) and every
sampled example tag renders `RFC3339` with a `Z` suffix
(`"2026-09-06T05:12:00Z"`); date-only fields (`log_date`, HOS `date`) are a
plain `string` typed field with a `YYYY-MM-DD` example, correctly *not*
`time.Time` (avoids a spurious time-of-day). Consistent everywhere sampled.
**Saqlash.**

**Real gap found:** no DTO field anywhere uses swaggo's `format:"date-time"`
/ `format:"date"` struct tag. Checking the generated
`docs/swagger.json` confirms the schema for every `time.Time` field is
`{"type":"string","example":"..."}` — no `"format"` key at all. A client
generator (openapi-generator, orval, swagger-codegen) reading this spec
cannot tell `activated_on` is a timestamp rather than an opaque string; the
distinction currently exists only in the example value and in this document.
**Recommendation: not a CR (it's a spec-quality bug, not a contract
question)** — file it as a follow-up task for whichever domain agent next
touches each `dto/` package: add `format:"date-time"` to every `time.Time`
field and `format:"date"` to the `YYYY-MM-DD` string fields, then `make swag`.
Left unfixed here because it requires editing `internal/domain/*/dto/*.go`,
outside this review's write scope.

---

## 6. TZ D§3 deviations (from `tasks.md` § "API kontraktdan chetlashishlar")

All are **additions** — nothing in the D§3 table is missing from the
implementation.

| Endpoint | Note | Recommendation |
|---|---|---|
| `DELETE /company/branches/{id}` | Not in the contract table | **Saqlash + TZ ga CR.** A branch is a real tenant resource with the same soft-delete lifecycle as everything else; omitting DELETE was almost certainly a table oversight, not a deliberate immutability choice (compare `routes`, `units`, which do have DELETE). |
| `POST /users/{id}/activate` / `/deactivate` | Not listed for `users` (only for `units`/`drivers`) | **Saqlash + TZ ga CR.** `drivers` already has this pair; users need the same lever to suspend an office account without deleting it (audit trail, re-enable later). Consistent with the existing pattern, just missing from the table. |
| `GET /units/import-template`, `GET /drivers/import-template` | Not listed | **Saqlash + TZ ga CR.** Both resources already have `import`/`export`; a template endpoint is the same feature family (tells the client the exact column headers `import` expects) and has no security surface of its own (static template, `*.read` permission). |
| `GET /drivers/{id}/license` | Not listed; returns the decrypted `license_no` | **TZ ga CR, security review required before freeze.** This is the one deviation with real risk: it's a new way to read PII (`license_no_enc`) that the contract table never anticipated, so it never went through a D§3 threat-modelling pass. `tasks.md` already records it goes through `drivers.license.view` and an `audit_log` `license_reveal` entry (README §Conventions) — that mitigation should be *confirmed in the security audit*, not just assumed, before this endpoint is allowed to stay in a frozen `v1`. |
| `DELETE /drivers/{id}/co-drivers/{co_driver_id}` vs `DELETE /drivers/{id}/co-drivers` | Both exist; the contract table lists the collection form | **Pick one, TZ ga CR.** Two DELETE routes for the same relationship is a real inconsistency (which one does a client integrate against?). Recommend keeping the collection form only if "clear all co-drivers" is an actual product need, otherwise **o'chirish** the collection DELETE and keep `{co_driver_id}` — deleting one named co-driver is the far more common operation and matches the REST convention used everywhere else in this API (`DELETE /resource/{id}`, never a bulk collection delete). |
| `GET /units/{id}/diagnostics`, `GET /units/{id}/history` | `diagnostics` is in the contract table already (§ Units row); `history` is not | **`diagnostics`: saqlash, kontrakt bilan mos.** **`history`: saqlash + TZ ga CR** — every other domain that has a mutable lifecycle (`company`, `drivers` via `activities`) exposes a history/activity feed; a unit's assignment/status history is the same shape and useful for support/audit, just not table-listed. |

**Net recommendation:** none of the seven deviations should be *removed*
before the freeze except the duplicate co-driver DELETE (pick one shape).
Six are legitimate feature gaps in the TZ table itself — batch them into a
single CR against D§3 rather than one CR per endpoint. The `license` endpoint
is the only one that should block the freeze until the security audit
explicitly signs off on it.

---

## 7. Not reviewed here

- Swagger annotation completeness (100% handler/`example` coverage) —
  `eld-test-engineer` / `eld-code-reviewer` track this separately per
  `tasks.md` Bosqich 9.
- `oasdiff breaking` results against the API's own history — see the CI job
  output and the note in the stage-9 report; that is a spec-vs-spec check,
  orthogonal to this contract-vs-implementation review.

---

## 8. `v1` freeze decisions (Bosqich 10)

Final pass before tagging `docs/history/v1.0.json`. Three permission-matrix
findings had to be resolved one way or the other before freezing; two smaller
gaps (branch scope, a masking false positive) were fixed as bugs, not
contract questions.

### 8a. `LoginRateLimit` was hard-coded

`internal/middleware/ratelimit.go` ignored `cfg.RateLimit.Login`
(`RATE_LIMIT_LOGIN`, default `5`) and always used the
`LoginPerIPPerMinute = 5` constant; the config field only ever reached
`internal/auth.Guard`'s per-account lockout, never the HTTP layer.
**Fixed, not a contract change** (the wire value and the default happen to be
the same `5`, so no client-visible behaviour moved): `LoginRateLimit(store,
perMinute int)` now takes the limit explicitly, `cmd/api/wire.go` passes
`cfg.RateLimit.Login`, and a non-positive value still falls back to the
`5`/min default. An operator can now actually change the login budget via
`RATE_LIMIT_LOGIN` without a code change.

### 8b. `per_page` — tightened to {10, 25, 50}

`internal/httpx/pagination.go` accepted any `per_page` in `[1, 100]`; the
conventions and the task brief both say the UI/API contract is a closed set
of `{10, 25, 50}`. **Decision: tightened to the closed set** (option i from
the brief) — `per_page` outside `{10, 25, 50}` now answers `422
VALIDATION_ERROR` on every list endpoint, not just the ones that used to
document the gap.

This **is a breaking change** for any client currently sending, say,
`per_page=100` or `per_page=30` (several integration tests did exactly that
as a stand-in for "give me everything on one page" — they were rewritten to
use `per_page=50`, and one auditlog pagination test that asserted `per_page=2`
was rewritten to seed 15 rows and assert `per_page=10`/page 2). Rationale for
still doing it now rather than deferring: `v1` is the freeze point — after
this, `per_page` semantics are load-bearing for every future client
generator, and the closed set matches the UI page-size selector the contract
was written against. **No TZ CR needed** — the implementation now matches
the TZ text exactly; the CR would have gone the other direction (loosen the
TZ to match the old code), which is not what happened.

Note for future contract reviewers: `oasdiff` cannot see this change — the
Swagger `per_page` parameter has always been `type: integer` with a free
text description ("Rows per page (10/25/50, max 100)"), never an OpenAPI
`enum`, so the tightening is invisible to a spec diff. It is only visible in
`TestContractPagination` (`cmd/api/contract_integration_test.go`) and this
document.

### 8c. Dead permission keys

Four permission keys were seeded and cataloged but never enforced by any
route; one enforced route was gated on a key that doesn't semantically
match what it protects. Migration `db/migrations/00028_permission_cleanup.sql`
resolves all of it:

| Key | Finding | Decision |
|---|---|---|
| `tracking.read` | Dead — the tracking module actually checks `tracking.view_live` | **Removed** (catalogue, `role_permissions`, `internal/auth.AllPermissions`) |
| `tracking.history` | Dead — actual key is `tracking.view_history` | **Removed** |
| `trips.read` | Dead — no `/trips` endpoint exists; trip/unit history lives under `routes.*` and `tracking.view_history` | **Removed** |
| `support.update` | Dead — the only mutation is `support.update_status` (already fully migrated in `00025_support_audit_stage8.sql`, every role that had `support.update` also got `support.update_status`) | **Removed** |
| `company.history.view` | Seeded, real (a genuine narrower permission), but `GET /company/history` was gated on the much broader `audit.view` instead | **Wired**: the handler now requires `company.history.view`; every role that had `audit.view` also gets `company.history.view` (migration back-fill) so nobody loses access on upgrade |

This **is a breaking change** for the four removed keys: a role that only
held one of them (never observed in the seed data — every occurrence was
paired with `tracking.view_live`/`tracking.view_history`/`routes.read` or
`support.update_status`) would silently lose a permission that never gated
anything anyway. `GET /company/history` also changes its required
permission from `audit.view` to `company.history.view` — every default role
that could read the audit trail before the migration still can afterwards
(back-filled), but a **custom** role that was granted `audit.view` alone,
specifically to reach `/company/history` and nothing else in the audit
surface, keeps working (back-fill covers it); a custom role that somehow
had neither and expected `audit.view` to cover this endpoint no longer
works and must be granted `company.history.view` explicitly. **No TZ CR** —
these are internal RBAC catalogue entries, not part of the D§3 endpoint
contract; `GET /permissions` output shrinks by four strings, which is the
only externally visible effect beyond the two behavioural changes above.

### Smaller fixes bundled into this freeze (not contract decisions)

- **`dvir.ReportFilter` had no `branch_id`** — a branch-scoped DVIR export
  (`internal/domain/reports/export.go` `dvirTable`) silently returned every
  branch's inspections. Added `BranchID` to the filter, the sqlc query
  (`ListDvirReports`/`CountDvirReports` now join `units` and filter on
  `un.branch_id`), and wired it from both `GET /dvir-reports` (via
  `mw.ScopeFrom`) and the report export path (already-scoped
  `dto.ExportParams.BranchID`). Bug fix, not a contract change — the response
  shape is identical, only the row set for a branch-scoped caller shrinks to
  what it should always have been.
- **`DashboardSummary` had no branch filter on the KPI cards** — only the
  "Route's Details" block was branch-scoped; every KPI number (active units,
  violations, uncertified logs, ...) was company-wide even for a
  branch-scoped principal. Added `branch_id` to the `DashboardKPI` sqlc
  query (each card now joins the entity that actually carries `branch_id` —
  `units` or `drivers` — and filters on it) and wired the existing
  `windows.BranchID` through to it. Bug fix, not a contract change.
- **`internal/httpx/mask.go` `phoneRe` masked ISO dates** — `2026-09-06`
  matches the same "digits with separators" shape as a phone number.
  `MaskSecrets` now skips a match that parses as `time.DateOnly`
  (`2006-01-02`) before redacting it. A log line quoting a real date is no
  longer replaced with `[REDACTED]`; genuine phone numbers are unaffected
  (a valid date string is never a valid phone number and vice versa).
- **`GET /feedback` was missing the `order` query parameter in Swagger** —
  found by `oasdiff` (`request-parameter-removed` against `v0.8`). The
  handler already accepted it (`httpx.ParseSort` always reads both `sort`
  and `order`); only the annotation was missing. Added
  `@Param order query string false "Sort order" Enums(asc, desc)`.

### Wiring fixes (no behavioural surface, but were previously silent gaps)

- **`jobs.RetentionDeps.Files`** was never set in `cmd/worker/main.go`, so an
  expired report export cleared its DB row but left the S3 object behind
  forever. Added `newFileRemover(objStore)`: `storage.NewPresignRemover(s3,
  nil)` when the worker resolved a real `*storage.S3` backend,
  `storage.NopRemover{}` for the in-memory fallback (local/dev without S3
  credentials).
- **`middleware.PgSubscriptionSource.Invalidate`** was defined but never
  called by anything. `POST /companies` create and
  `PATCH /companies/{id}/subscription` are the only writers of
  `companies.subscription_status`/`subscription_end_at` in this MVP (billing
  is manual); `companies.Service` now takes an optional
  `SubscriptionInvalidator` and drops the cached state right after
  `UpdateSubscription` commits, so `RequireWritableSubscription` never
  enforces a stale answer for up to `DefaultSubscriptionTTL` (1 minute).
  `jobs.HandleSubscriptionExpiring` was checked and does **not** need this:
  it only sends the 14/3/1-day warning emails and never writes
  `subscription_status`/`subscription_end_at`, so there is nothing for it to
  invalidate.

### `v1` freeze verdict

**Ready to freeze.** All three permission-matrix findings (§8a–§8c) were
consciously resolved, not deferred; the two decisions with real
client-visible impact (§8b tightened `per_page`, §8c removed four permission
keys and re-gated `GET /company/history`) are intentional pre-`v1` contract
firming, documented here and in `docs/history/v1.0.json`'s companion
`oasdiff` output — acceptable precisely because they land *before* the
freeze, not after. No further TZ CRs are required by this pass beyond the
pre-existing ones already on file in §2, §3 and §6.
