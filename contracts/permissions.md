# ONEBOOK ELD — permission kalitlari

Manba: `backend/internal/auth/permissions.go` · Swagger: 125 path / 166 operatsiya

Katalogda: **104** kalit · Endpointlarda ishlatilgan: **104**


## Kalitlar va ular qo'riqlaydigan endpointlar

| Permission | Endpointlar |
|---|---|
| `audit.view` | GET /audit-log<br>GET /audit-log/tables |
| `branches.create` | POST /company/branches |
| `branches.delete` | DELETE /company/branches/{id} |
| `branches.read` | GET /company/branches |
| `branches.update` | PATCH /company/branches/{id} |
| `chat.read` | POST /chat/messages/{id}/read<br>GET /chat/threads<br>GET /chat/threads/{driver_id}/messages |
| `chat.send` | POST /chat/threads/{driver_id}/messages |
| `company.history.view` | GET /company/history |
| `company.read` | GET /company |
| `company.update` | PATCH /company |
| `dashboard.read` | GET /dashboard/summary |
| `defect_types.create` | POST /defect-types |
| `defect_types.read` | GET /defect-types |
| `defect_types.update` | PATCH /defect-types/{id} |
| `drivers.activate` | POST /drivers/{id}/activate |
| `drivers.create` | POST /drivers |
| `drivers.deactivate` | POST /drivers/{id}/deactivate |
| `drivers.delete` | DELETE /drivers/{id} |
| `drivers.export` | GET /drivers/export |
| `drivers.import` | POST /drivers/import<br>GET /drivers/import-template |
| `drivers.license.view` | GET /drivers/{id}/license |
| `drivers.manage_co_drivers` | POST /drivers/{id}/co-drivers<br>DELETE /drivers/{id}/co-drivers<br>DELETE /drivers/{id}/co-drivers/{co_driver_id} |
| `drivers.read` | GET /drivers<br>GET /drivers/{id}<br>GET /drivers/{id}/activities<br>GET /drivers/{id}/co-drivers |
| `drivers.reset_password` | POST /drivers/{id}/reset-password |
| `drivers.update` | PATCH /drivers/{id} |
| `dvir.certify` | POST /dvir-reports/{id}/certify |
| `dvir.create` | POST /dvir-reports |
| `dvir.export` | GET /dvir-reports/{id}/pdf |
| `dvir.read` | GET /dvir-reports<br>GET /dvir-reports/pending-certification<br>GET /dvir-reports/{id} |
| `dvir.repair` | POST /dvir-reports/{id}/repair |
| `eld_devices.assign_unit` | POST /eld-devices/{id}/assign-unit |
| `eld_devices.create` | POST /eld-devices |
| `eld_devices.delete` | DELETE /eld-devices/{id} |
| `eld_devices.read` | GET /eld-devices<br>GET /eld-devices/{id} |
| `eld_devices.update` | PATCH /eld-devices/{id} |
| `feedback.create` | POST /feedback |
| `feedback.read` | GET /feedback |
| `files.upload` | POST /files/presign |
| `hos_policy.read` | GET /company/hos-policy |
| `hos_policy.update` | POST /company/hos-policy |
| `inspection.email` | POST /inspection/email |
| `inspection.transfer` | POST /inspection/transfer |
| `inspection.view` | POST /inspection/begin<br>GET /inspection/logs |
| `logs.add_event` | POST /daily-logs/{id}/events |
| `logs.annotate_unidentified` | POST /unidentified-events/{id}/annotate |
| `logs.approve_edit` | POST /log-edit-requests/{id}/approve |
| `logs.assign_unidentified` | GET /unidentified-events<br>POST /unidentified-events/{id}/assign |
| `logs.certify` | POST /daily-logs/{id}/certify |
| `logs.claim_unidentified` | POST /unidentified-events/{id}/claim |
| `logs.export` | GET /daily-logs/{id}/pdf |
| `logs.propose_edit` | POST /log-edit-requests |
| `logs.read` | GET /daily-logs/{id}<br>GET /drivers/{id}/daily-logs<br>GET /drivers/{id}/duty-status-events<br>GET /drivers/{id}/hos-summary<br>GET /log-edit-requests<br>GET /sync/pull<br>POST /sync/push |
| `logs.reject_edit` | POST /log-edit-requests/{id}/reject |
| `maintenance.cancel` | POST /maintenance-schedule-units/{id}/cancel |
| `maintenance.complete` | POST /maintenance-schedule-units/{id}/complete |
| `maintenance.create` | POST /maintenance-schedules |
| `maintenance.delete` | DELETE /maintenance-schedules/{id} |
| `maintenance.read` | GET /maintenance-records<br>GET /maintenance-schedule-units/{id}<br>GET /maintenance-schedules<br>GET /maintenance-schedules/{id}<br>GET /maintenance/due |
| `maintenance.update` | PATCH /maintenance-schedules/{id} |
| `notification_settings.read` | GET /company/notification-settings |
| `notification_settings.update` | PATCH /company/notification-settings |
| `notifications.read` | POST /devices/push-token<br>GET /notifications<br>POST /notifications/read-all<br>PATCH /notifications/{id}/read |
| `permissions.read` | GET /permissions |
| `reports.export` | POST /reports/export-jobs |
| `reports.read` | GET /reports/activity<br>GET /reports/distance-by-region<br>GET /reports/export-jobs<br>GET /reports/export-jobs/{id}<br>GET /reports/uncertified-logs |
| `roles.create` | POST /roles |
| `roles.delete` | DELETE /roles/{id} |
| `roles.read` | GET /roles |
| `roles.update` | PATCH /roles/{id} |
| `routes.complete` | POST /routes/{id}/not-completed |
| `routes.create` | POST /routes |
| `routes.delete` | DELETE /routes/{id} |
| `routes.read` | GET /routes<br>GET /routes/{id}<br>GET /routes/{id}/directions |
| `routes.update` | PATCH /routes/{id} |
| `shipping_documents.create` | POST /shipping-documents |
| `shipping_documents.delete` | DELETE /shipping-documents/{id} |
| `shipping_documents.read` | GET /shipping-documents<br>GET /shipping-documents/{id} |
| `shipping_documents.update` | PATCH /shipping-documents/{id} |
| `support.create` | POST /support-tickets<br>POST /support-tickets/{id}/messages |
| `support.read` | GET /support-tickets<br>GET /support-tickets/{id}<br>GET /support-tickets/{id}/messages |
| `support.update_status` | PATCH /support-tickets/{id}/status |
| `tracking.view_history` | GET /trips/{id}<br>GET /units/{id}/trips |
| `tracking.view_live` | GET /tracking/live |
| `trailers.create` | POST /trailers |
| `trailers.delete` | DELETE /trailers/{id} |
| `trailers.read` | GET /trailers<br>GET /trailers/{id} |
| `trailers.update` | PATCH /trailers/{id} |
| `units.activate` | POST /units/{id}/activate |
| `units.assign_driver` | POST /units/{id}/assign-driver |
| `units.create` | POST /units |
| `units.deactivate` | POST /units/{id}/deactivate |
| `units.delete` | DELETE /units/{id} |
| `units.diagnostics` | GET /units/{id}/diagnostics |
| `units.export` | GET /units/export |
| `units.import` | POST /units/import<br>GET /units/import-template |
| `units.read` | GET /units<br>GET /units/{id}<br>GET /units/{id}/history |
| `units.update` | PATCH /units/{id} |
| `users.create` | POST /users |
| `users.delete` | DELETE /users/{id} |
| `users.invite` | POST /users/{id}/resend-invitation |
| `users.read` | GET /users |
| `users.reset_password` | POST /users/{id}/reset-password |
| `users.update` | PATCH /users/{id}<br>POST /users/{id}/activate<br>POST /users/{id}/deactivate |
| `violations.read` | GET /violations<br>GET /violations/{id} |

## Maxsus belgilar

- `authenticated` — 7 operatsiya
- `public` — 6 operatsiya
- `super_admin` — 4 operatsiya