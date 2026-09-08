---
name: eld-sync
description: Offline sync protokoli — /sync/push va /sync/pull formati, idempotency, konflikt qoidalari, telemetriya ingestion, unidentified driving. internal/sync yoki telemetriya kodi ustida ishlaganda majburiy.
---

# Offline sync protokoli (TZ D§2, B§1, A§10.4)

`internal/sync` — **sof paket** (stdlib only) konflikt/validatsiya qoidalari uchun; DB I/O chaqiruvchi domen qatlamida.

## POST /api/v1/sync/push
```json
{ "device_id":"…", "app_version":"1.2.0",
  "clock": {"phone":"…Z","eld_rtc":"…Z"},
  "events":[{"client_event_id":"uuid","event_type":"status_change","status":"ON","special":"none",
             "event_time":"2026-09-06T05:12:00Z","time_source":"eld_rtc","device_seq":1042,
             "lat":31.52,"lng":74.35,"gps_accuracy_m":12,"odometer_m":128430000,
             "engine_hours":1234.5,"notes":"Pickup","trailer_ids":[],"shipping_doc_ids":[]}],
  "telemetry":[{"ts":"…","lat":…,"lng":…,"speed_kmh":62,"odometer_m":…,"ignition":true}],
  "dvir":[…], "chat":[…] }
```
Javob:
```json
{ "server_time":"…Z",
  "events":[{"client_event_id":"uuid","result":"accepted|duplicate|rejected","reason":"time_in_future"}],
  "telemetry":{"accepted":120,"duplicate":3},
  "dvir":[…], "chat":[…] }
```
- Batch chegarasi: **≤500 event**, **≤5000 telemetriya nuqta** (oshsa `422 BATCH_TOO_LARGE`).
- `Idempotency-Key` header **majburiy**.
- Retry — eksponensial (1 s → 5 daq), tartib `device_seq` bo'yicha saqlanadi.

## Idempotency
`duty_status_events.client_event_id UUID UNIQUE` → dublikat = `duplicate` natijasi, **xato emas** (200). Telemetriya dublikati `(unit_id, ts)` bo'yicha — jimgina ignore (`ON CONFLICT DO NOTHING`).

## Konflikt qoidalari
1. Bir haydovchi uchun bir vaqtda ikki status event (turli qurilma) → ustuvorlik: `time_source` `eld_rtc > server > phone`, teng bo'lsa katta `device_seq`. Yutqazgan event **saqlanadi** `superseded_by` bilan; haydovchiga ogohlantirish.
2. Server o'zgarishi (edit request approved) mobilga kelganda lokal log qayta quriladi — **server kanonik**.
3. `event_time > server_time + 5 daq` → `rejected(time_in_future)`.
4. Telemetriya dublikati — ignore.
5. `locked=true` (sertifikatlangan) kunga yangi event → faqat edit-request orqali; push'da `rejected(log_locked)`.

## Vaqt yaxlitligi
Ustuvorlik: 1) ELD RTC → 2) server vaqti (offset) → 3) telefon (`time_unverified=true`).
`|phone − eld_rtc/server| > 2 daq` → eventda `clock_skew_sec` yoziladi + ogohlantirish. >10 daq → `timing` malfunction.
ELD ulanmagan holda qo'lda status: `origin=manual_no_eld`, `time_source=phone`, `time_unverified=true` (adminda sariq belgi).

## GET /api/v1/sync/pull?since=<server_ts>
Qaytaradi: pending `log_edit_requests`, shu unit uchun `unidentified_events`, assignment o'zgarishlari, joriy `hos_policy`, `defect_types` katalogi, `quick_notes`, yangi `chat` xabarlari, `server_time`. Kursor — `since` (server ts), javobda `next_since`.

## Telemetriya ingestion
- Qurilma → server chastotasi: haydashda har **30 s yoki 300 m**, to'xtaganda 5 daq, ignition off — 1 hodisa.
- Yozish: `telemetry` hypertable'ga `COPY`/batch insert; `unit_last_state` upsert; Redis `unit:last:<unit_id>`; WS `tracking` kanaliga push.
- Trip segmentatsiyasi: ignition on→off yoki ≥15 daq to'xtash → `trips` yozuvi (start/end, distance_m, polyline object storage'ga).
- Kunlik `unit_region_distance_daily` — trekni `regions` poligonlariga PostGIS bilan kesib, asynq cron bilan.

## Unidentified driving (A§10.4)
- Login'siz harakat → `duty_status_events.driver_id = NULL` + `unidentified_events` (unit, start/end, distance_m, track_key), status `pending`.
- Haydovchi login qilganda `sync/pull` shu unit uchun pending ro'yxatni beradi → `POST /unidentified-events/:id/claim` → eventlar `origin=assigned` bilan uning logiga ko'chadi.
- Admin `assign` → **log edit request** yaratadi (haydovchi tasdig'i kerak), yoki `annotate` bilan izohlab qoldiradi.
- 8 kundan ortiq `pending` → admin alerti + `unidentified_driving` violation.
