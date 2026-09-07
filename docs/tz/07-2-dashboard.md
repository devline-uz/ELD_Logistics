## 7.2 Dashboard — `/`

- **Maqsad:** kompaniyaning joriy holati bir ekranda. **Ruxsat:** `dashboard.read`
- **Endpointlar:** `GET /dashboard/summary` · WS `dashboard` kanali (`dashboard_summary`) · `GET /routes?status=ongoing` (kerak bo'lsa)
- **Yangilanish:** WS obunasi; WS yo'q bo'lsa **60 s polling** (`websocket.md` §4.4)

**KPI kartalari** (backend `kpi` obyekti — **9 ta maydon**, dizaynda 4 ta karta bor edi):

| Karta | Maydon | Kesim | Rang | Bosilganda |
|---|---|---|---|---|
| Active Units | `active_units` | Today | orange | `/units?status=active` |
| Active Drivers | `active_drivers` | — | blue | `/drivers?status=active` |
| Drivers On Duty | `drivers_on_duty` | Now | blue | `/tracking` |
| Violations | `violations` | This week | error | `/violations?from=<hafta boshi>` |
| Disconnected ELD | `disconnected_eld` | Now | neutral | `/tracking?online_status=disconnected` |
| Malfunction ELD | `malfunction_eld` | Now | error | `/eld-devices?status=malfunction` |
| Uncertified Logs | `uncertified_logs` | ≥2 kun | warning | `/reports/uncertified-logs` |
| Unassigned Driving | `unassigned_driving` | Pending | warning | `/logs/unassigned` |
| Pending Log Edits | `pending_log_edits` | Pending | warning | `/logs/edit-requests?status=pending` |

**F80** Dizayndagi 4 karta o'rniga **9 karta** ko'rsatiladi (backend beradi, `tz.md` §20 talab qiladi): 2 qatorli grid, birinchi qatorda eng muhim 5 tasi. Dizayndagi `Total Drivers`/`Total Units` → **`Active Drivers`/`Active Units`** (backend semantikasi: bugun telemetriya bergan). §16.
**F81** Dizayndagi «Disconnected ELD kartasi ostidagi chiziq **yashil**» — xato, semantikaga zid. ✅ `neutral`, qiymat > 0 bo'lsa `error`. §16.

**Status bloki** (beshinchi karta): `status.off/sb/dr/on` — 4 raqam + rangli nuqta. Bosilganda `/tracking?duty_status=…`.

**Units Tracking bloki:** MapLibre xarita (§9), marker'lar `GET /tracking/live` dan, WS `tracking` bilan yangilanadi. Afsona: `● Drive · ● Sleep · ● On-Duty · ● Off-Duty`. Vaqt filtri `Today / This week` — **faqat marker tarixi uchun**, jonli holat doim joriy.

**Route's Details jadvali** (`summary.routes[]`):
| Ustun | Manba | Format |
|---|---|---|
| Unit # | `unit_number` | |
| Date | `created_at` | §12 formati |
| Driver Name | `driver_name` | |
| From | `origin` | manzil matni, `truncate` + tooltip |
| To | `destination` | |
| Status | `status` | `ongoing` (warning) · `completed` (success) · `not_completed` (error) · `cancelled` (neutral) |

Dizaynda 10 satr + vertikal scroll, sahifalash yo'q — ✅ saqlanadi; «View all» havolasi `/routes` ga.

- **Bo'sh holat:** har blok alohida (`No routes today`, `No units reporting`)
- **Xato:** har blok mustaqil `ErrorState` — bittasining yiqilishi butun dashboardni buzmaydi

---

