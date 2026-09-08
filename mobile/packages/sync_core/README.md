# sync_core

Pure Dart rules of the ONEBOOK ELD offline-first sync layer.

| Module | Responsibility | TZ |
|---|---|---|
| `outbox_item.dart` | `OutboxKind` / `OutboxState` / `OutboxRecord` value types | §5.1 |
| `batch.dart` | Batch selection and splitting under per-kind + byte limits | M33, M25, M27 |
| `backoff.dart` | `1s→2s→5s→15s→60s→300s` with ±20% jitter, `Retry-After` override | §5.4 |
| `conflict.dart` | `accepted/duplicate/rejected(reason)` → outcome + UI message key | §5.6, M29 |
| `retention.dart` | Retention cutoffs and the 100 MB storage budget | §5.2, M23 |
| `validation.dart` | `event_type` enum, future-time clamp, payload validation | M32, M41 |
| `idempotency.dart` | UUID v4 formatting for stable `Idempotency-Key` / `client_event_id` | M19, M33 |

Everything here is deterministic: the caller injects `now` (from `TimeSource`) and
random bytes. `DateTime.now()` and `Random()` are forbidden inside the package.
