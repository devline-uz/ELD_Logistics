---
name: flutter-drift
description: Drift (SQLite) lokal sxemasi, forward-only migratsiya, retention va 100 MB byudjet, outbox patterni, SyncScheduler backoff/mutex, konflikt sabab→UI mapping, SQLCipher va TimeSource qoidalari. Lokal DB, outbox yoki sync scheduler kodi ustida ishlaganda majburiy.
---

# Drift — lokal DB, outbox, sync scheduler (tz-mobile §5, §7)

**Manba:** `tz-mobile.md` **368–506** (§5) va **605–650** (§7) qatorlar — faqat shu qismlarni o'qi.
Server tomoni — `.claude/skills/eld-sync/SKILL.md`. **Prinsip:** ilova tarmoqni hech qachon kutmaydi —
har amal avval lokal DB ga yoziladi, UI darhol yangilanadi.

## Umumiy konventsiyalar [MUST]
- Vaqtlar **UTC** (`DateTime` UTC yoki `INTEGER` epoch ms); kunga ajratish **faqat Home Terminal TZ** da (M42).
- Masofa `_m`, tezlik `_kmh`, murakkab tuzilmalar — `TEXT` ustunda JSON.
- Drift `watch()` → `StreamProvider`; UI DB ni poll qilmaydi. DAO'lar `lib/.../db/`, sof algoritmlar `packages/sync_core` da.

## Jadvallar (§5.1)
| Jadval | Maqsad | Kalit maydonlar |
|---|---|---|
| `outbox_items` | Universal chiqish navbati | `id` PK, `kind` (`event`/`telemetry`/`dvir`/`chat`/`certify`/`claim`/`log_edit`/`push_token`/`feedback`/`support`), `payload` JSON, `client_id` UUID, `device_seq` INT, `session_slot`, `user_id`, `created_at`, `attempts`, `next_attempt_at`, `state` (`pending`/`inflight`/`acked`/`rejected`), `reject_reason`, `reject_seen` BOOL |
| `duty_events` | Duty eventlari (lokal ko'zgu) | `client_event_id` UUID **UNIQUE**, `server_id`, `event_type`, `status`, `special`, `event_time`, `time_source`, `time_unverified`, `clock_skew_sec`, `device_seq`, `origin`, `lat`, `lng`, `gps_accuracy_m`, `location_text`, `odometer_m`, `engine_hours`, `speed_kmh`, `notes`, `unit_id`, `eld_device_id`, `trailer_ids` JSON, `shipping_doc_ids` JSON, `sync_state`, `superseded_by`, `locked` |
| `telemetry_buffer` | ECM/GPS nuqtalari | `ts` (`unit_id` bilan UNIQUE), `lat`, `lng`, `speed_kmh`, `heading_deg`, `odometer_m`, `engine_hours`, `ignition`, `fuel_pct`, `coolant_*`, `oil_level_pct`, `battery_*`, `diagnostics` JSON, `disconnected`, `duty_status`, `driver_id`, `sent` BOOL |
| `daily_logs` | Kunlik loglar ko'zgusi | `log_date`, `driver_id`, `timezone`, `certification_status`, `signed_at`, `distance_m`, `totals` JSON, `ready`, `updated_at` |
| `hos_state` | Hisoblagichlar keshi | `driver_id`, `computed_at`, `counters` JSON, `recap` JSON, `policy_version_id` |
| `hos_policy` | Policy versiyalari | `version_id`, `effective_from`, `payload` JSON |
| `dvir_drafts` | DVIR qoralamalari | `client_id`, `unit_id`, `type`, `defects` JSON, `trailer_ids`, `notes`, `driver_signature_key`, `local_photo_paths` JSON, `state` (`draft`/`queued`/`sent`) |
| `dvir_reports` | Serverdan olingan DVIR (14 kun) | `id`, `status`, `kind`, `type`, `unit_id`, `created_at`, `has_critical_defect`, `out_of_service`, JSON |
| `chat_outbox` / `chat_messages` | Chat navbati va tarixi | `client_id`, `kind`, `text`, `file_key`, `lat`, `lng`, `status` (`queued`/`sent`/`delivered`/`read`/`failed`) |
| `log_edit_requests` | Pending edits | `id`, `daily_log_id`, `log_date`, `changes` JSON, `source`, `status`, `created_at`, `local_decision` |
| `unidentified_events` | Claim kutayotgan bloklar | `id`, `unit_id`, `start_at`, `end_at`, `distance_m`, `status`, `dismissed_local` |
| `notifications` | Bildirishnomalar keshi | `id`, `alert_type`, `title`, `body`, `entity_type`, `entity_id`, `read`, `created_at` |
| `files_queue` | Yuklanmagan foto/imzo | `local_path`, `kind`, `content_type`, `size_bytes`, `presigned_key`, `upload_url`, `expires_at`, `state`, `attempts` |
| `ref_defect_types` / `ref_quick_notes` / `ref_trailers` | Katalog keshlari | `sync/pull` dan yangilanadi |
| `sync_cursor` | Kursor va statistika | `next_since`, `last_push_at`, `last_pull_at`, `last_error` |
| `kv_settings` | Sozlamalar | `key`, `value` (`device_id`, `device_seq`, `home_terminal_tz`, tema, zoom, til, oxirgi trailer) |

## Indekslar (majburiy minimum)
`outbox_items(state, next_attempt_at, device_seq)`, `outbox_items(kind, state)`, `UNIQUE(duty_events.client_event_id)`,
`duty_events(event_time DESC)`, `duty_events(sync_state)`, `UNIQUE(telemetry_buffer.unit_id, ts)`, `telemetry_buffer(sent, ts)`,
`UNIQUE(daily_logs.driver_id, log_date)`, `chat_messages(created_at DESC)`, `notifications(read, created_at DESC)`, `files_queue(state, attempts)`.

## Migratsiya [MUST]
- **P10 / M21:** forward-only — `schemaVersion` faqat oshadi, `MigrationStrategy.onUpgrade` har qadamni alohida
  yozadi; chiqarilgan migratsiyani **tahrirlash taqiq** (goose qoidasi bilan bir xil) — yangisini qo'sh.
- **M22:** `drift_dev/schema` snapshotlari repoda; har `schemaVersion` uchun `schema dump`, CI da `drift_dev schema verify`.
- Boshlang'ich `schemaVersion = 1`; har migratsiya uchun in-memory SQLite testi. `beforeOpen`: `PRAGMA foreign_keys = ON`.

## Retention va hajm (§5.2)
| Ma'lumot | Minimal saqlash | Tozalash sharti |
|---|---|---|
| `duty_events` | **≥14 kun** | `sync_state=acked` **va** >30 kun |
| `telemetry_buffer` | 14 kun yoki `sent=true` gacha | `sent=true` va >48 soat |
| `daily_logs`, `dvir_reports` | 14 kun (8 kunlik sertifikatsiya oynasi + zaxira) | >30 kun |
| `chat_messages` | oxirgi 500 xabar / 30 kun | LRU |
| Fayllar (foto/imzo) | yuklanguncha + 7 kun | yuklangandan keyin |
| Konflikt ro'yxati (`rejected`) | **7 kun** (M30) | 7 kundan keyin |
| **Umumiy byudjet** | **≤100 MB** | **90 MB** dan oshsa telemetriyaning eng eski **10%** o'chadi |

**M23 [MUST]** Eventlar hech qanday sharoitda avtomatik o'chirilmaydi — faqat server
`accepted`/`duplicate` bergandan **va** 30 kun o'tgandan keyin. Hajm siqilganda ham
eventlar tegilmaydi («0 event yo'qotish» NFR).

## Outbox patterni (§5.3)
```
amal → domen validatsiyasi (sof, sync_core)
     → TRANSAKSIYA: [domen jadvali] + [outbox_items]   ← atomik
     → UI darhol yangilanadi (optimistik)
SyncScheduler → push (batch) / pull (kursor) → natijalarni qo'llash
```
- **M19:** `client_event_id` — qurilmada generatsiya qilingan `UUID v4`, hech qachon o'zgarmaydi; idempotentlikning yagona kaliti.
- **M20:** `device_seq` — qurilma bo'yicha yagona, monoton o'suvchi `INTEGER`; `kv_settings` da **atomik
  `UPDATE … RETURNING`** bilan oshiriladi (alohida `SELECT`+`UPDATE` taqiq). Ilova qayta o'rnatilsa `device_id` yangilanadi, seq 0 dan.
- **M24:** yozuv **har doim** bitta Drift tranzaksiyasida: domen jadvali + `outbox_items`; biri yiqilsa — ikkalasi rollback.
- **M25:** yuborish tartibi `device_seq` bo'yicha o'sish (batch ichida ham). `rejected` element navbatni
  **bloklamaydi** — `state=rejected` bo'lib chetga chiqadi va foydalanuvchiga ko'rsatiladi.
- **M33 batch bo'lish** (`sync_core`, sof funksiya + test):
  1. `state=pending` va `next_attempt_at <= now` ni `device_seq` bo'yicha o'qi.
  2. Chegaralar: `events ≤500`, `telemetry ≤5000`, `dvir ≤100`, `chat ≤500`, **jami JSON ≤4 MB**.
  3. Elementlarni `inflight` qil, **barqaror** `Idempotency-Key` generatsiya qil va **saqla**.
  4. Yubor: timeout **30 s** (haydash rejimida **15 s**); javob kelsa `inflight → acked|rejected`.
  5. Timeout/tarmoq xatosi: elementlar `pending` ga qaytadi, **kalit saqlanadi** — keyingi urinishda aynan o'sha
     kalit (server 24 soat replay). `409 IDEMPOTENCY_CONFLICT` → yangi kalit + qayta yig'ish, Sentry'ga yoziladi.
- **M31:** server kanonik — `sync/pull` `events` lokal ko'zguni to'liq qayta quradi, lokal faqat hali `acked`
  bo'lmagan outbox elementlarini optimistik qatlam qilib qo'shadi. `applyPull()` bitta tranzaksiyada atomik.

## SyncScheduler (§5.4)
| Trigger | Xatti-harakat |
|---|---|
| Foreground'ga chiqish | Darhol push+pull |
| Tarmoq paydo bo'ldi (`connectivity_plus`) | Darhol push+pull, **2 s debounce** |
| Doimiy taymer | Onlayn **60 s**, haydash rejimida **30 s**, oflayn — urinmaydi |
| Kritik event (`certify`, `dvir`, `duty_status`, `claim`) | Darhol push urinishi |
| Fon xizmati (Android FGS) | Ekran o'chiq bo'lsa ham 60 s |
| Qo'lda | Tepa paneldagi `Refresh` ikonkasi |

- **Backoff [MUST]:** `1 s → 2 s → 5 s → 15 s → 60 s → 300 s` (maks **5 daqiqa**), har urinishda **±20% jitter**;
  `429 RATE_LIMITED` da `Retry-After` ustun; muvaffaqiyatdan keyin backoff **nolga** tushadi.
  Kechikish `outbox_items.next_attempt_at` ga yoziladi.
- **M26 [MUST]:** bir vaqtda faqat **bitta** sync sikli (mutex); ikkinchi trigger navbatga qo'yiladi, parallel push yo'q.
- **M27 [SHOULD]:** telemetriya alohida past ustuvorlikli navbatda — metered tarmoqda **≤1000 nuqta**, Wi-Fi da **≤5000**.
  Eventlar **hech qachon** kechiktirilmaydi.

## Konflikt sabab → UI matn (§5.6)
| `reason` | UI xabari (en) | Amal |
|---|---|---|
| `time_in_future` | «This entry was recorded ahead of server time and was not accepted. Check your device clock.» | `M-55` da qayta yuborish |
| `time_out_of_range` | «This entry is outside the accepted time range.» | Faqat ko'rish |
| `log_locked` | «That day is already certified. Ask your fleet manager for a log edit.» | `Contact support` |
| `superseded` | «Another device recorded a status at the same time. The other entry was kept.» | Faqat ma'lumot |
| `invalid_payload` | «This entry could not be saved (invalid data).» | Diagnostikaga jo'natish |
| `pc_not_allowed` / `ym_not_allowed` | «Personal Conveyance / Yard Move is disabled for your company.» | Toggle yashiriladi |
| `sleeper_berth_unavailable` | «Sleeper Berth is not available on this unit.» | SB tugmasi o'chadi |
| `drive_not_manual` / `auto_drive` | «Driving status is set automatically and cannot be changed by hand.» | — |
| `yard_move_ended` | «Yard Move ended automatically — the vehicle exceeded <n> km/h.» | Toast + logda ko'rinadi |

- **M29:** `superseded` — **xato emas**: element `accepted` belgilanadi, `superseded_by` yoziladi, lokal log pull dan keyin yangilanadi.
- **M30:** `M-55 Sync conflicts` — rad etilgan/almashtirilgan elementlar (sana, tur, sabab, asl qiymat);
  `reject_seen=false` → qizil nuqta, ko'rilgandan keyin `true`; ro'yxat 7 kun.

## Sync holati UI (§5.5)
| Holat | Ko'rinish | Tafsilot |
|---|---|---|
| `synced` | Kulrang bulut ✓ + «Synced <nisbiy vaqt>» | — |
| `pending` | Aylanuvchi ikonka + «<n> pending» | `M-54` |
| `offline` | Uzilgan bulut + «Offline — <n> queued» | `M-54` |
| `conflict` | Qizil nuqta + «<n> need attention» | `M-55` |

**M28:** `M-54 Sync status`: oxirgi push/pull vaqti, navbat elementlari turlari bo'yicha, oxirgi xato kodi,
`Retry now` tugmasi, `next_since` kursori (diagnostika).

## Shifrlash
Drift DB **SQLCipher** bilan shifrlanadi `[SHOULD]` (`sqlcipher_flutter_libs`); kalit Keystore/Keychain da,
kodda yoki `SharedPreferences` da **hech qachon** emas. Kalit yo'qolsa DB qayta yaratilmaydi — qayta login.

## Vaqt — `TimeSource` (§7)
- Ustuvorlik: **1)** ELD RTC → `time_source="eld_rtc"`, **2)** server offseti → `"server"`,
  **3)** telefon soati → `"phone"` + `time_unverified=true`.
- **`DateTime.now()` butun kodbazada faqat `TimeSource` ichida chaqiriladi** (§2.4 taqiqi, lint bilan qo'riqlanadi).
  DAO, repo, scheduler va testlar faqat `TimeSource` orqali; u monoton soat (`Stopwatch`/`elapsedRealtime`) +
  oxirgi ishonchli nuqtaga tayanadi, shuning uchun telefon soati o'zgarsa ham event vaqti sakramaydi.
- Skew: ≤2 daq — normal (`clock_skew_sec` informativ); >**2 daq** — sariq banner; >**10 daq** — `T` (timing)
  malfunction banneri + `event_type=malfunction` (kod `T`) outbox'ga.
- **M39:** `PushResponse.clock` (`ClockVerdict`) kanonik — mobil o'z hisobini u bilan almashtiradi
  (`source`, `clock_skew_sec`, `time_unverified`, `warning`, `malfunction_code`).
- **M40:** ELD ulanmagan qo'lda status: `origin=manual_no_eld`, `time_source=phone`, `time_unverified=true`;
  UI da sariq nuqta + «Recorded without ELD connection».
- **M41:** outbox'ga yozishdan **oldin** `TimeSource` bilan tekshir — kelajak vaqt ehtimoli bo'lsa server offseti
  qo'llanadi (`event_time > server_time + 5 daq` oldini olish).
- **M42:** kun chegarasi — Home Terminal TZ 00:00–24:00, `kv_settings.home_terminal_tz` da keshlanadi; DST kunlari
  23/25 soat (`dst_spring_forward_23h_day`, `dst_fall_back_25h_day`).
- **M43 [SHOULD]:** UI vaqtlari Home Terminal TZ da; farq bo'lsa «Times shown in <TZ abbr>» izohi.
