# Permission katalogi (GENERATSIYA)

Manba: `admin/openapi/swagger.json` → har operatsiyaning `x-permission` maydoni.
Qayta yaratish: `npm run api` dan keyin `python3 scripts/gen-permissions-doc.py`.

**104 ta haqiqiy permission kaliti**, 28 guruh. Uchta maxsus qiymat permission emas:

| Maxsus qiymat | Operatsiya | Ma'no |
|---|---|---|
| `public` | 6 | auth'siz ochiq (login, parol tiklash, invitation) |
| `authenticated` | 7 | har qanday tizimga kirgan foydalanuvchi, permission tekshirilmaydi |
| `super_admin` | 4 | alohida bayroq, rol emas (F33) — `/companies*` CRUD |

> ⚠️ TZ §4.1 «105 kalit» deydi — **noto'g'ri**. Backend yakuniy tozalashda 4 ta o'lik kalitni
> olib tashladi (`tracking.read`, `tracking.history`, `trips.read`, `support.update`) va
> `drivers.license.view` ni qo'shdi. **Haqiqiy son — 104.** Katalogdagi 104 kalitning
> hammasi ishlatiladi (ishlatilmagan 0, yetishmayotgan 0).

## OR mantiq bilan qo'riqlangan endpointlar (CI testida ISTISNO)

swaggo OR sintaksisiga ega emas — Swagger faqat bitta kalit ko'rsatadi, backend esa ikkitasini qabul qiladi:

| Endpoint | Swagger'da | Haqiqatda |
|---|---|---|
| `GET /unidentified-events` | `logs.assign_unidentified` | `logs.assign_unidentified` **yoki** `logs.read` |
| `GET /permissions` | `permissions.read` | `permissions.read` **yoki** `roles.read` |

## Kalitlar guruh bo'yicha

### `audit.*` (1)

| Kalit | Metod | Endpoint |
|---|---|---|
| `audit.view` | GET | `/audit-log` |
|  | GET | `/audit-log/tables` |

### `branches.*` (4)

| Kalit | Metod | Endpoint |
|---|---|---|
| `branches.create` | POST | `/company/branches` |
| `branches.delete` | DELETE | `/company/branches/{id}` |
| `branches.read` | GET | `/company/branches` |
| `branches.update` | PATCH | `/company/branches/{id}` |

### `chat.*` (2)

| Kalit | Metod | Endpoint |
|---|---|---|
| `chat.read` | GET | `/chat/threads` |
|  | GET | `/chat/threads/{driver_id}/messages` |
|  | POST | `/chat/messages/{id}/read` |
| `chat.send` | POST | `/chat/threads/{driver_id}/messages` |

### `company.*` (3)

| Kalit | Metod | Endpoint |
|---|---|---|
| `company.history.view` | GET | `/company/history` |
| `company.read` | GET | `/company` |
| `company.update` | PATCH | `/company` |

### `dashboard.*` (1)

| Kalit | Metod | Endpoint |
|---|---|---|
| `dashboard.read` | GET | `/dashboard/summary` |

### `defect_types.*` (3)

| Kalit | Metod | Endpoint |
|---|---|---|
| `defect_types.create` | POST | `/defect-types` |
| `defect_types.read` | GET | `/defect-types` |
| `defect_types.update` | PATCH | `/defect-types/{id}` |

### `drivers.*` (11)

| Kalit | Metod | Endpoint |
|---|---|---|
| `drivers.activate` | POST | `/drivers/{id}/activate` |
| `drivers.create` | POST | `/drivers` |
| `drivers.deactivate` | POST | `/drivers/{id}/deactivate` |
| `drivers.delete` | DELETE | `/drivers/{id}` |
| `drivers.export` | GET | `/drivers/export` |
| `drivers.import` | GET | `/drivers/import-template` |
|  | POST | `/drivers/import` |
| `drivers.license.view` | GET | `/drivers/{id}/license` |
| `drivers.manage_co_drivers` | DELETE | `/drivers/{id}/co-drivers` |
|  | DELETE | `/drivers/{id}/co-drivers/{co_driver_id}` |
|  | POST | `/drivers/{id}/co-drivers` |
| `drivers.read` | GET | `/drivers` |
|  | GET | `/drivers/{id}` |
|  | GET | `/drivers/{id}/activities` |
|  | GET | `/drivers/{id}/co-drivers` |
| `drivers.reset_password` | POST | `/drivers/{id}/reset-password` |
| `drivers.update` | PATCH | `/drivers/{id}` |

### `dvir.*` (5)

| Kalit | Metod | Endpoint |
|---|---|---|
| `dvir.certify` | POST | `/dvir-reports/{id}/certify` |
| `dvir.create` | POST | `/dvir-reports` |
| `dvir.export` | GET | `/dvir-reports/{id}/pdf` |
| `dvir.read` | GET | `/dvir-reports` |
|  | GET | `/dvir-reports/pending-certification` |
|  | GET | `/dvir-reports/{id}` |
| `dvir.repair` | POST | `/dvir-reports/{id}/repair` |

### `eld_devices.*` (5)

| Kalit | Metod | Endpoint |
|---|---|---|
| `eld_devices.assign_unit` | POST | `/eld-devices/{id}/assign-unit` |
| `eld_devices.create` | POST | `/eld-devices` |
| `eld_devices.delete` | DELETE | `/eld-devices/{id}` |
| `eld_devices.read` | GET | `/eld-devices` |
|  | GET | `/eld-devices/{id}` |
| `eld_devices.update` | PATCH | `/eld-devices/{id}` |

### `feedback.*` (2)

| Kalit | Metod | Endpoint |
|---|---|---|
| `feedback.create` | POST | `/feedback` |
| `feedback.read` | GET | `/feedback` |

### `files.*` (1)

| Kalit | Metod | Endpoint |
|---|---|---|
| `files.upload` | POST | `/files/presign` |

### `hos_policy.*` (2)

| Kalit | Metod | Endpoint |
|---|---|---|
| `hos_policy.read` | GET | `/company/hos-policy` |
| `hos_policy.update` | POST | `/company/hos-policy` |

### `inspection.*` (3)

| Kalit | Metod | Endpoint |
|---|---|---|
| `inspection.email` | POST | `/inspection/email` |
| `inspection.transfer` | POST | `/inspection/transfer` |
| `inspection.view` | GET | `/inspection/logs` |
|  | POST | `/inspection/begin` |

### `logs.*` (10)

| Kalit | Metod | Endpoint |
|---|---|---|
| `logs.add_event` | POST | `/daily-logs/{id}/events` |
| `logs.annotate_unidentified` | POST | `/unidentified-events/{id}/annotate` |
| `logs.approve_edit` | POST | `/log-edit-requests/{id}/approve` |
| `logs.assign_unidentified` | GET | `/unidentified-events` |
|  | POST | `/unidentified-events/{id}/assign` |
| `logs.certify` | POST | `/daily-logs/{id}/certify` |
| `logs.claim_unidentified` | POST | `/unidentified-events/{id}/claim` |
| `logs.export` | GET | `/daily-logs/{id}/pdf` |
| `logs.propose_edit` | POST | `/log-edit-requests` |
| `logs.read` | GET | `/daily-logs/{id}` |
|  | GET | `/drivers/{id}/daily-logs` |
|  | GET | `/drivers/{id}/duty-status-events` |
|  | GET | `/drivers/{id}/hos-summary` |
|  | GET | `/log-edit-requests` |
|  | GET | `/sync/pull` |
|  | POST | `/sync/push` |
| `logs.reject_edit` | POST | `/log-edit-requests/{id}/reject` |

### `maintenance.*` (6)

| Kalit | Metod | Endpoint |
|---|---|---|
| `maintenance.cancel` | POST | `/maintenance-schedule-units/{id}/cancel` |
| `maintenance.complete` | POST | `/maintenance-schedule-units/{id}/complete` |
| `maintenance.create` | POST | `/maintenance-schedules` |
| `maintenance.delete` | DELETE | `/maintenance-schedules/{id}` |
| `maintenance.read` | GET | `/maintenance-records` |
|  | GET | `/maintenance-schedule-units/{id}` |
|  | GET | `/maintenance-schedules` |
|  | GET | `/maintenance-schedules/{id}` |
|  | GET | `/maintenance/due` |
| `maintenance.update` | PATCH | `/maintenance-schedules/{id}` |

### `notification_settings.*` (2)

| Kalit | Metod | Endpoint |
|---|---|---|
| `notification_settings.read` | GET | `/company/notification-settings` |
| `notification_settings.update` | PATCH | `/company/notification-settings` |

### `notifications.*` (1)

| Kalit | Metod | Endpoint |
|---|---|---|
| `notifications.read` | GET | `/notifications` |
|  | PATCH | `/notifications/{id}/read` |
|  | POST | `/devices/push-token` |
|  | POST | `/notifications/read-all` |

### `permissions.*` (1)

| Kalit | Metod | Endpoint |
|---|---|---|
| `permissions.read` | GET | `/permissions` |

### `reports.*` (2)

| Kalit | Metod | Endpoint |
|---|---|---|
| `reports.export` | POST | `/reports/export-jobs` |
| `reports.read` | GET | `/reports/activity` |
|  | GET | `/reports/distance-by-region` |
|  | GET | `/reports/export-jobs` |
|  | GET | `/reports/export-jobs/{id}` |
|  | GET | `/reports/uncertified-logs` |

### `roles.*` (4)

| Kalit | Metod | Endpoint |
|---|---|---|
| `roles.create` | POST | `/roles` |
| `roles.delete` | DELETE | `/roles/{id}` |
| `roles.read` | GET | `/roles` |
| `roles.update` | PATCH | `/roles/{id}` |

### `routes.*` (5)

| Kalit | Metod | Endpoint |
|---|---|---|
| `routes.complete` | POST | `/routes/{id}/not-completed` |
| `routes.create` | POST | `/routes` |
| `routes.delete` | DELETE | `/routes/{id}` |
| `routes.read` | GET | `/routes` |
|  | GET | `/routes/{id}` |
|  | GET | `/routes/{id}/directions` |
| `routes.update` | PATCH | `/routes/{id}` |

### `shipping_documents.*` (4)

| Kalit | Metod | Endpoint |
|---|---|---|
| `shipping_documents.create` | POST | `/shipping-documents` |
| `shipping_documents.delete` | DELETE | `/shipping-documents/{id}` |
| `shipping_documents.read` | GET | `/shipping-documents` |
|  | GET | `/shipping-documents/{id}` |
| `shipping_documents.update` | PATCH | `/shipping-documents/{id}` |

### `support.*` (3)

| Kalit | Metod | Endpoint |
|---|---|---|
| `support.create` | POST | `/support-tickets` |
|  | POST | `/support-tickets/{id}/messages` |
| `support.read` | GET | `/support-tickets` |
|  | GET | `/support-tickets/{id}` |
|  | GET | `/support-tickets/{id}/messages` |
| `support.update_status` | PATCH | `/support-tickets/{id}/status` |

### `tracking.*` (2)

| Kalit | Metod | Endpoint |
|---|---|---|
| `tracking.view_history` | GET | `/trips/{id}` |
|  | GET | `/units/{id}/trips` |
| `tracking.view_live` | GET | `/tracking/live` |

### `trailers.*` (4)

| Kalit | Metod | Endpoint |
|---|---|---|
| `trailers.create` | POST | `/trailers` |
| `trailers.delete` | DELETE | `/trailers/{id}` |
| `trailers.read` | GET | `/trailers` |
|  | GET | `/trailers/{id}` |
| `trailers.update` | PATCH | `/trailers/{id}` |

### `units.*` (10)

| Kalit | Metod | Endpoint |
|---|---|---|
| `units.activate` | POST | `/units/{id}/activate` |
| `units.assign_driver` | POST | `/units/{id}/assign-driver` |
| `units.create` | POST | `/units` |
| `units.deactivate` | POST | `/units/{id}/deactivate` |
| `units.delete` | DELETE | `/units/{id}` |
| `units.diagnostics` | GET | `/units/{id}/diagnostics` |
| `units.export` | GET | `/units/export` |
| `units.import` | GET | `/units/import-template` |
|  | POST | `/units/import` |
| `units.read` | GET | `/units` |
|  | GET | `/units/{id}` |
|  | GET | `/units/{id}/history` |
| `units.update` | PATCH | `/units/{id}` |

### `users.*` (6)

| Kalit | Metod | Endpoint |
|---|---|---|
| `users.create` | POST | `/users` |
| `users.delete` | DELETE | `/users/{id}` |
| `users.invite` | POST | `/users/{id}/resend-invitation` |
| `users.read` | GET | `/users` |
| `users.reset_password` | POST | `/users/{id}/reset-password` |
| `users.update` | PATCH | `/users/{id}` |
|  | POST | `/users/{id}/activate` |
|  | POST | `/users/{id}/deactivate` |

### `violations.*` (1)

| Kalit | Metod | Endpoint |
|---|---|---|
| `violations.read` | GET | `/violations` |
|  | GET | `/violations/{id}` |

## Maxsus qiymatli operatsiyalar

### `public`

- `GET /app/config`
- `POST /auth/invitation/accept`
- `POST /auth/login`
- `POST /auth/password/forgot`
- `POST /auth/password/reset`
- `POST /auth/refresh`

### `authenticated`

- `DELETE /auth/sessions/{id}`
- `GET /auth/sessions`
- `GET /me`
- `POST /auth/2fa/setup`
- `POST /auth/2fa/verify`
- `POST /auth/logout`
- `POST /auth/pin/verify`

### `super_admin`

- `GET /companies`
- `PATCH /companies/{id}`
- `PATCH /companies/{id}/subscription`
- `POST /companies`
