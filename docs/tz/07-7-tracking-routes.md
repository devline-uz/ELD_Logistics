## 7.7 Tracking

### 7.7.1 Tracking ro'yxati — `/tracking`
- **Ruxsat:** `tracking.view_live` · **Endpoint:** `GET /tracking/live` + WS `tracking` kanali
- **Filtrlar:** `unit_ids` · `branch_id` · `online_status` (`online|idle|offline|disconnected`) · `include_inactive` · `search` (driver/unit — klient tomonda, backend `search` bermaydi)

| Ustun | Manba |
|---|---|
| # | tartib |
| Driver Name | `driver.name` |
| Unit # | `unit_number` |
| Status | `duty_status` chip |
| Device | `online_status` badge + `eld_device_serial` |
| Speed | `speed_kmh` → §12 |
| Last Known Location | `lat`, `lng` + reverse-geocode matni + `last_seen_at` nisbiy vaqt |
| Action | `Track on Map` |

- **F115** WS `unit_last_state` kelganda satr **joyida yangilanadi** (jadval qayta yuklanmaydi): `queryClient.setQueryData` bilan. Yangilangan satr 600 ms `bg-light` bilan yonib o'chadi.
- **F116** `online_status` filtri backend enum'ida `idle` ham bor (`websocket.md` da yo'q) — UI to'rt qiymatni ham beradi.

### 7.7.2 Track on Map — `/tracking/units/:unitId` (yoki `/units/:id/track`)
- **Ruxsat:** `tracking.view_live` (+ `tracking.view_history` tarix uchun, `units.diagnostics` diagnostika uchun)
- **Endpointlar:** `GET /tracking/live?unit_ids=` · `GET /units/{id}/trips?date=` · `GET /trips/{id}?include_polyline=true` · `GET /units/{id}/diagnostics` · WS `tracking` (`filter.unit_ids`)
- **Breadcrumb:** `Unit Management › Unit # 101 › Track on Map` **yoki** `Tracking › Unit # 101` — ikki kirish yo'li
- **Tarkib:** xarita (to'liq kenglik) + o'ng yon panel (yig'ilgan/yoyilgan, `›` tugmasi bilan)
- **Xarita boshqaruvlari:** sarlavha `Unit # <n>` + `←` · `Refresh` (majburiy re-fetch, `tz.md` Q63) · sana navigatori `‹ <sana> ›` · qatlam tanlash · joylashuvga o'tish · `+`/`−` zoom
- **Yon panel — 3 blok:**
  1. **Haydovchi:** nomi + ogohlantirish ikonkasi, online holati, joylashuv, batareya, tezlik, vaqt tamg'asi, `Shift ends in HH:MM:SS` (`hos-summary` dan)
  2. **UNIT DIAGNOSTICS** (`GET /units/{id}/diagnostics` → `telemetry{}`): `VIN · Engine Hours · Odometer · Fuel · Bus · Coolant Level % · Coolant Temperature · Oil Level %` + `malfunction_codes[]`
  3. **HISTORIES** (`GET /units/{id}/trips?date=`): har segment — boshlanish nuqtasi, `Range`, `Duration`, tugash nuqtasi; vertikal timeline; segment bosilganda xaritada polyline yoritiladi
- **F117 [MUST]** Blok nomi **`Unit Diagnostics`** — ikkala kirish yo'lida ham (dizaynda Tracking'dan kirilganda `Unit Inspection` edi; `tz.md` §1.3 kanonik nomi `Unit Diagnostics`). §16

### 7.7.3 Routes — `/routes`
- **Ruxsat:** `routes.read` · **Endpointlar:** `GET/POST /routes`, `GET/PATCH/DELETE /routes/{id}`, `GET /routes/{id}/directions`, `POST /routes/{id}/not-completed` (`routes.complete`)
- **Filtrlar:** `status` (`ongoing|completed|not_completed|cancelled`) · `unit_id` · `driver_id`; saralash `created_at|sequence|status`
- **Ustunlar:** `# · Unit # · Driver · From · To · Sequence · Geofence · Started · Completed · Status · Action`
- **Amallar:** `Create route` · `Edit` · `Close as not completed` (sabab: `breakdown · cancelled · load_rejected · road_closed · driver_change · other` + izoh) · `Delete`
- **F118** `ongoing → completed` **avtomatik** (geofence ichida ≥ 2 daq, `tz.md` Q66–68) — UI'da qo'lda "Complete" tugmasi **yo'q**, faqat `not-completed`. §16/§17-10
- **F119** Dashboard DTO'sida route status enum'i `planned|in_progress|completed|not_completed|cancelled`, Routes DTO'sida `ongoing|completed|not_completed|cancelled`. ✅ **Routes DTO'si kanonik** (`tz.md` Q66); UI ikkala qiymatni ham qabul qiladigan normalizator yozadi (`planned|in_progress → ongoing`) va farqni §17 ga backend CR sifatida chiqaradi.

---

