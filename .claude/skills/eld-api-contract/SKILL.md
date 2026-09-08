---
name: eld-api-contract
description: ELD REST API kontrakti — endpoint ro'yxati, URL/metod konventsiyalari, permission mapping, javob shakllari. Yangi HTTP endpoint qo'shayotganda majburiy.
---

# API kontrakti (TZ D§3)

Base: `/api/v1`. Endpoint nomlari **aynan shu jadvaldan** olinadi; chetlashish = TZ CR talab qiladi.

| Guruh | Endpointlar |
|---|---|
| Auth | `POST /auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/2fa/verify`, `/auth/2fa/setup`, `/auth/invitation/accept`, `/auth/password/forgot`, `/auth/password/reset`, `POST /auth/pin/verify`, `GET /auth/sessions`, `DELETE /auth/sessions/{id}` |
| App | `GET /app/config`, `GET /me` |
| Companies (Super Admin) | `GET/POST /companies`, `PATCH /companies/{id}`, `PATCH /companies/{id}/subscription` |
| Company (Admin) | `GET/PATCH /company`, `GET/POST/PATCH /company/branches`, `GET /company/hos-policy`, `POST /company/hos-policy`, `GET/PATCH /company/notification-settings`, `GET /company/history` |
| Users/Roles | `GET/POST /users`, `PATCH/DELETE /users/{id}`, `POST /users/{id}/resend-invitation`, `POST /users/{id}/reset-password`, `GET/POST /roles`, `PATCH/DELETE /roles/{id}`, `GET /permissions` |
| Units | `GET/POST /units`, `GET/PATCH/DELETE /units/{id}`, `POST /units/{id}/activate`, `/deactivate`, `/assign-driver`, `GET /units/{id}/diagnostics`, `GET /units/{id}/history?from&to`, `POST /units/import`, `GET /units/export` |
| Drivers | `GET/POST /drivers`, `GET/PATCH/DELETE /drivers/{id}`, `POST /drivers/{id}/activate|deactivate`, `GET /drivers/{id}/activities`, `POST /drivers/import`, `GET /drivers/export`, `GET/POST/DELETE /drivers/{id}/co-drivers` |
| ELD devices | `GET/POST /eld-devices`, `GET/PATCH/DELETE /eld-devices/{id}`, `POST /eld-devices/{id}/assign-unit` |
| Trailers/Docs | CRUD `/trailers`, `/shipping-documents` |
| Sync (mobil) | `POST /sync/push`, `GET /sync/pull` |
| Logs | `GET /drivers/{id}/daily-logs?from&to`, `GET /daily-logs/{id}`, `GET /daily-logs/{id}/pdf`, `POST /daily-logs/{id}/certify`, `GET /drivers/{id}/hos-summary`, `GET /drivers/{id}/duty-status-events` |
| Log edits | `POST /log-edit-requests`, `GET /log-edit-requests?status=pending`, `POST /log-edit-requests/{id}/approve`, `/reject`, `POST /daily-logs/{id}/events` |
| Unidentified | `GET /unidentified-events`, `POST /unidentified-events/{id}/assign`, `/claim`, `/annotate` |
| Inspection | `POST /inspection/email`, `POST /inspection/transfer`, `GET /inspection/logs` |
| Violations | `GET /violations`, `GET /violations/{id}` |
| Tracking | `GET /tracking/live`, `GET /units/{id}/trips?date`, `GET /trips/{id}`, WS `tracking` |
| Routes | `GET/POST /routes`, `GET/PATCH/DELETE /routes/{id}`, `POST /routes/{id}/not-completed`, `GET /routes/{id}/directions` |
| DVIR | `GET /dvir-reports`, `GET /dvir-reports/{id}`, `POST /dvir-reports` (mobil), `POST /dvir-reports/{id}/repair`, `GET /dvir-reports/{id}/pdf`, `GET /dvir-reports/pending-certification?unit_id`, `POST /dvir-reports/{id}/certify`, `GET/POST/PATCH /defect-types` |
| Maintenance | CRUD `/maintenance-schedules`, `GET /maintenance/due`, `POST /maintenance-schedule-units/{id}/complete`, `/cancel`, `GET /maintenance-records` |
| Reports | `POST /reports/export-jobs`, `GET /reports/export-jobs/{id}`, `GET /reports/activity`, `GET /reports/distance-by-region?quarter&year&mode`, `GET /reports/uncertified-logs` |
| Dashboard | `GET /dashboard/summary` |
| Notifications | `GET /notifications`, `PATCH /notifications/{id}/read`, `POST /notifications/read-all`, `POST /devices/push-token` |
| Files | `POST /files/presign` → `{upload_url, key}` |
| Support | `GET/POST /support-tickets`, `PATCH /support-tickets/{id}/status`, `POST /support-tickets/{id}/messages`, `POST /feedback`, `GET /feedback` |
| Chat | `GET /chat/threads`, `GET /chat/threads/{driver_id}/messages?before`, `POST /chat/threads/{driver_id}/messages`, `POST /chat/messages/{id}/read`, WS `chat` |
| Audit | `GET /audit-log?table&record_id&from&to&user` |

## Konventsiyalar
- Resurs nomlari — ko'plik, kebab-case. Amal (action) — `POST /resource/{id}/verb`.
- `PATCH` — qisman yangilash (pointer maydonlar); `PUT` ishlatilmaydi.
- `DELETE` — **soft-delete** (`deleted_at`), 204. `logs/dvir/violations/telemetry/audit_log` uchun DELETE **yo'q**.
- Javob: bitta obyekt `{"data":{...}}`, ro'yxat `{"data":[...],"meta":{"page":1,"per_page":25,"total":0}}`.
- Sana/vaqt — ISO 8601 UTC (`2026-09-06T05:12:00Z`); sana — `2026-09-06`.
- `X-Company-Id` — faqat Super Admin. `Idempotency-Key` — POST'larda ixtiyoriy, `/sync/push` da majburiy.
- Versiyalash: `/api/v1` backward-compatible; `GET /app/config` → `min_supported_version`, `latest_version`, `force_update`.

## Permission mapping (namuna)
`GET /units` → `units.read` · `POST /units` → `units.create` · `POST /units/{id}/deactivate` → `units.deactivate` ·
`POST /log-edit-requests` → `logs.propose_edit` · `POST /unidentified-events/{id}/assign` → `logs.assign_unidentified` ·
`GET /reports/*` → `reports.read`, eksport → `reports.export` · `GET /audit-log` → `audit.view` ·
`POST /company/hos-policy` → `hos_policy.update` · `POST /dvir-reports/{id}/repair` → `dvir.repair`.
Driver (mobil, scope=`self`) endpointlari: `/sync/*`, `/me`, o'z `daily-logs`, `certify`, `log-edit-requests approve/reject`, `unidentified claim`, `dvir` yaratish/certify, `chat`, `support-tickets`, `feedback`, `notifications`, `files/presign`, `auth/pin/verify`.

## WebSocket
`GET /api/v1/ws` — `Authorization: Bearer` header. Kanallar: `tracking`, `notifications`, `chat`, `dashboard`.
Xabar: `{"type":"subscribe","channel":"tracking","filter":{"unit_ids":[...]},"since":"…Z"}` →
`{"type":"event","channel":"tracking","data":{...},"ts":"…Z"}`. Ping/pong 30 s. Hujjat: `docs/websocket.md`.
