# ONEBOOK ELD — Texnik Topshiriq v2.0

**Sana:** 2026-09-06 · **Versiya:** 2.2 (v1.0 — birlashtirilgan TZ; v2.0 — sanoat benchmark'i bo'yicha qayta ishlangan; v2.1 — backend Go; v2.2 — ketma-ket ish tartibi: avval backend, keyin frontend; Swagger code-first)
**Holat:** Ishlab chiqish uchun asos. `❓` bilan belgilangan bandlar buyurtmachi tasdig'ini kutadi.

> **v2 nima uchun kerak bo'ldi.** v1 dizayndan qoidalarni to'g'ri chiqargan, lekin (1) AQSh domeni (FMCSA/IFTA/US DOT/miles) Pokiston–Markaziy Osiyo bozoriga moslashtirilmagan, (2) log tahrirlash "tamper-evident" tamoyiliga zid edi, (3) unidentified driving, sync protokoli, NFR, acceptance criteria yo'q edi, (4) DB/API sxemasida tracking, trailer, sessiya jadvallari tushib qolgan edi, (5) A va B qismlar orasida bir qancha ziddiyat bor edi. v2 bularni **sanoat yetakchilari** (Samsara, Motive/KeepTruckin, Geotab, Omnitracs, Trimble) amaliyoti bilan solishtirib yopadi.

---

## Changelog v1 → v2

| # | O'zgarish | Sabab / benchmark |
|---|---|---|
| 1 | **Region profili** qo'shildi: `regulation_profile`, `unit_system (metric/imperial)`, `region` — Company darajasida | Samsara/Motive: US/Canada/Mexico rulesetlari + km/mi tanlovi. Pokiston/O'zbekiston uchun km, mahalliy raqamlar |
| 2 | IFTA → **"Masofa hisoboti (hudud bo'yicha)"**, FMCSA Report → **"Regulator eksporti"**, US DOT → **"Ro'yxat raqami"** (label sozlanadi) | Domenni generic qilish, AQSh bozori uchun keyin qayta yoqiladi |
| 3 | **Log tahrirlash: admin taklif → haydovchi tasdiq/rad**, asl yozuv saqlanadi, `DR` vaqti qisqartirilmaydi | FMCSA §395.30 va Samsara/Motive/Geotab: "Edit request / Driver approval" |
| 4 | **Unidentified driving** (kimga tegishli emas haydash) bo'limi | Barcha yetakchilarda "Unassigned/Unidentified HOS" |
| 5 | **Offline sync protokoli**: `client_event_id`, batch, idempotency, konflikt qoidalari | Motive Vehicle Gateway / Samsara buffer amaliyoti |
| 6 | HOS: PC/YM, sleeper split, 34h restart, tanaffus qoidalari, kun chegarasi (Home Terminal TZ), golden test-case talabi | Geotab "exception rules", FMCSA 2020 rulesets |
| 7 | Sertifikatlangan kun tahrirlansa → qayta sertifikatsiya; 8 kundan eskirgan sertifikatlanmagan kunlar admin ogohlantirishi | Samsara "Uncertified logs" alert |
| 8 | Session policy: **bitta user = bitta telefon + bitta planshet**; co-driver switch auth modeli; Leave Truck oqimi | Dizaynda ikki klient bir haydovchi uchun |
| 9 | Parol: faqat invitation orqali (Driver formasidan `Password` olib tashlandi, admin "Reset password" yuboradi) | B §16 bilan ziddiyat yopildi |
| 10 | Ruxsatlar ro'yxati yakuniy + scope (`company/branch/self`); `branches` jadvali | Sub Admin uchun asos |
| 11 | Billing: **MVP — qo'lda onboarding + invoice**, self-service/Stripe — 2-bosqich | Stripe Pokistonda merchant sifatida mavjud emas; dizaynda signup/subscription ekranlari yo'q |
| 12 | DB: `telemetry`, `trailers`, `shipping_documents`, `defect_types`, `sessions`, `signatures`, `maintenance_schedule_units`, `log_edit_requests`, `unidentified_events`, `hos_policy_versions` | v1 bo'shliqlari |
| 13 | API: sync/batch, upload (presigned), tracking, reports, min-version, edit-request endpointlari; WS auth header orqali | v1 bo'shliqlari |
| 14 | NFR bo'limi, mobil OS cheklovlari (background BLE, Location always), Play/App Store xavflari | ELD ilovalarning eng katta amaliy riski |
| 15 | Acceptance criteria + Definition of Done — **majburiy** (loyiha pudratchi — Devline — tomonidan qilinadi) | v1 "shart emas" degan edi |
| 16 | Backup: PITR (WAL) → RPO ≤ 15 daqiqa | v1 RPO 24h audit tizimi uchun kam |
| 17 | Xarajatlar to'g'rilandi (App Store $99/yil, Play $25), xarita/telemetriya xarajati qo'shildi | v1 xatosi |
| 18 | Kanonik nomlar jadvali, MoSCoW ustuvorlik, eski havolalar (01-hujjat, 03-TEXNIK…) tozalandi | Hujjat sifati |
| 19 | Dashboard, Chat, Leave Truck, Trip Details — spetsifikatsiya qo'shildi | v1'da yo'q/bir qatorli edi |
| 20 | Timeline bog'liqliklari to'g'rilandi (Maintenance ↔ Telemetriya) | v1 xatosi |
| 21 | **Backend — Go (yakuniy qaror)**: Go 1.23+, chi, pgx/sqlc, goose, asynq, gorilla/websocket; loyiha tuzilmasi va HOS engine alohida paket | v2.0'da ochiq edi |
| 22 | **Swagger — code-first (swaggo)**: Go annotatsiyalaridan `swagger.json`, `/api/docs` UI, DTO qatlami majburiy, bosqichlararo `oasdiff` breaking tekshiruvi | Ish tartibi ketma-ket (avval backend, keyin frontend) — qo'lda `openapi.yaml` yuritish ortiqcha yuk |

---

## Mundarija

- **QISM A — Biznes-logika** (§0–21)
- **QISM B — Texnik arxitektura** (§0–23)
- **QISM C — Lug'at**
- **QISM D — DB sxemasi · Sync protokoli · API · Timeline · Risk · Acceptance**

Ustuvorlik belgilari: **[MUST]** — MVP'siz ishga tushmaydi · **[SHOULD]** — MVP'da kutiladi · **[MAY]** — 2-bosqich.

---

# QISM A — BIZNES-LOGIKA

**Manba:** Figma `ELD Software (Copy)` (`NLDjNYebjCuNswunequFv2`), dizayn tahlili prezentatsiyasi (144 bet, 2026-08-05), buyurtmachi qarorlari (2026-09-04/06), sanoat benchmark'i.

## 0. Ushbu hujjat qanday o'qiladi

- **D** — dizayndagi dalil; **Q** — qoida; **B** — benchmark (sanoat amaliyoti); **✅** — qabul qilingan qaror; **❓** — buyurtmachi tasdig'i kerak.
- Dizayn bilan sanoat amaliyoti to'qnashganda **xavfsizlik/audit talabi ustun** (masalan log tahrirlash). Bunday joylarda dizaynga kichik UI o'zgarishi kerakligi alohida belgilangan (`🎨 dizayn o'zgarishi`).
- Har bir qoida raqamlangan (Q1…), ustuvorligi bor. QISM D'dagi traceability jadvali qoida → jadval → endpoint bog'lanishini beradi.

## 1. Obyektlar modeli

| Obyekt | Qayerdan | Kalit maydonlar | v2 izoh |
|---|---|---|---|
| **Company** (tenant) | `Settings › Company` | Name, Address, Home Terminal Address, **Home Terminal Time zone**, Email, Phone, **Registration No** (label: `US DOT` / `Ro'yxat raqami` — profilga qarab), Logo, **region, unit_system, regulation_profile, hos_policy** | region/unit/profil yangi |
| **Branch** | (yangi, UI: Settings › Branches) | Name, Address, Time zone | Sub Admin scope uchun. 🎨 oddiy CRUD ekran kerak **[SHOULD]** |
| **User** | `User Management` | First/Last Name, Email, Phone, Role, Branch (ixtiyoriy), Status (invited/active/inactive) | Parol maydoni yo'q — invitation |
| **Role** | `Roles & Permissions` | Name, permission to'plami, is_system | |
| **Driver** | `Driver Management` | First/Last Name, Username, Email, Phone, License No + Issue Region, City/State, Zip, Fleet Manager, Home Terminal, Address, Notes, Default Unit, Co-Driver (**ixtiyoriy**), App Version, Activated On | `Password` olib tashlandi; Co-Driver ixtiyoriy |
| **Unit** | `Unit Management` | Unit #, ELD device, Make, Model, Year, Plate + Issue Region, Fuel Type, VIN, Sleeper Berth flag, Notes, Activated On, **GVWR class** (MAY) | |
| **Trailer** | Log Form, DVIR, status form | Number, Notes | v1'da jadval yo'q edi |
| **Shipping Document** | Log Form, status form | Number, Notes | v1'da jadval yo'q edi |
| **ELD Device** | Unit formasi, Tracking | Serial/Device ID, model, firmware, connection type, last_seen, malfunction flags | |
| **Duty Status Event** | Log ekranlari | Type (status/hodisa), Status, event_time, origin, location, odometer, engine hours, notes, trailer(lar), doc(lar), edit lineage | to'liq maydonlar |
| **Log Edit Request** | (yangi) | Taklif qilingan o'zgarish, taklif qiluvchi, holat (pending/approved/rejected) | 🎨 haydovchi ilovasida "Pending edits" ekrani |
| **Unidentified Event** | (yangi) | Unit, vaqt oralig'i, masofa, tayinlangan haydovchi | 🎨 admin "Unassigned driving" ro'yxati |
| **Daily Log** | `Log view`, `Log Report` | Sana (Home Terminal TZ), grid, jamilar, sertifikatsiya holati, Log Form | |
| **DVIR** | DVIR ekranlari | Unit, Trailer, **Type (pre-trip/post-trip)**, defects, imzolar, holat | type yangi |
| **Defect Type** | (katalog) | Name, category (truck/trailer), is_active | Dizayndagi 44 band tozalanadi |
| **Maintenance Schedule / Record** | `Maintenance` | v1 kabi + `last_service_value` (eski "Current Frequency") | |
| **Telemetry point** | Tracking | ts, lat/lng, speed, heading, odometer, engine hours, fuel, diagnostika | yangi jadval |
| **Route** | Dashboard, Trip Planner | Unit, Driver, From, To, geofence radius, Status | |
| **Ticket / Feedback / Chat message / Notification** | Support, Chat, Notification | v1 kabi (Chat §15.4'da spetsifikatsiya) | |
| **Session** | (texnik) | user, device_id, device_type (phone/tablet/web), refresh token, last_seen | Session policy uchun |
| **Subscription** | (texnik, MVP: Super Admin qo'lda) | plan, status, period, invoice | |

### 1.1 Bog'lanishlar

- **Driver ↔ Unit** — `unit_driver_assignments` (primary/co_driver, `assigned_at/unassigned_at`). Driver formasidagi `Unit #` = **default unit**; haqiqiy bog'lanish haydovchi mashinaga "kirganda" (Connect to ELD) yoziladi.
- **Driver ↔ Co-Driver** — simmetrik emas: A'ning co-driver'i B bo'lsa, B'ning ro'yxatida A avtomatik ko'rinadi (tizim ikki tomonlama ko'rsatadi, saqlash — bitta yozuv `driver_pairs`).
- **User ↔ Role** 1:1; **User ↔ Branch** N:1 (ixtiyoriy).
- **Company** — barcha jadvallarda `company_id`; tenant izolyatsiyasi **[MUST]** (QISM B §3.5).

### 1.2 Dizayn tizimi
v1 §1.2 o'zgarishsiz (1440 / 393×852 / 1366×1024; Primary `#B7002C`; IBM Plex Sans + Product Sans; Success `#2FA766`, Warning `#F6BA47`, Error `#E2464A`; standart ro'yxat-ekran patterni).

### 1.3 Kanonik nomlar (dizayndagi nomuvofiqliklar hal qilindi) **[MUST]**

| Dizayndagi variantlar | ✅ Kanonik |
|---|---|
| Fleet Operations / Fleet Management | **Fleet Management** |
| Reports / Report | **Reports** |
| Support & History / Histories | **Support & History** (ichida `Histories`) |
| Inspection Report / DOT Report | **Inspection Report** |
| Unit Diagnostics / Unit Inspection | **Unit Diagnostics** |
| Leave the Truck / Leave Truck | **Leave Truck** |
| In Progress / In-Progress | **In Progress** |
| Yes, Driving / Yes, driving | **Yes, driving** |
| Dropoff/Checkout vs Drop off/Check out | **Drop-off**, **Check-out** |
| Notify co-driver / Notify Co-driver | **Notify co-driver** |
| Maintainance, Invocie, Grese, 0verdue, Insection, Mangement, Selecetd, GET BTY | Maintenance, Invoice, Grease, Overdue, Inspection, Management, Selected, GET BY |
| Bo'sh qiymat `na` / `N/A` | **N/A** |
| ELD ID: `PT30_A9A1` vs `AP-AM4-0001172` | Qurilma serial raqami — vendor formati (§10) |
| Log jami: `OFF 03:06` / `Off - 00:00` | `OFF 03:06` |
| Hafta kuni `Tues`/`Fri` | 3 harf (`Tue`, `Fri`) |
| Contact Support: Ticket ID/Message vs Ticket #/Subject | **Ticket #**, **Subject** |
| Activity Report oxirgi ustun | **End Odometer** (Odometer Change alohida ustun) |
| Users › Role ustunida ism, `Export Drivers` tugmasi | Role nomi; **Export Users** |
| Histories › `Add User` tugmasi | tugma olib tashlanadi |
| Mobil bosh ekran A/B tartibi | ❓ **B (pastki tab)** taklif — bir qo'l bilan boshqarish qulay; buyurtmachi tasdiqlaydi |
| Quick notes 10 bandli vs 8 bandli | **Bitta ro'yxat, Company darajasida sozlanadi** (default: PTI, Hook, Pickup, Drop-off, Delivery, Inspection, Check-in, Fueling, Check-out, Break, Other) |

### 1.4 Region profili **[MUST]** (yangi)

**B:** Samsara/Motive/Geotab — ruleset (US 60/70, Canada South/North, Mexico va h.k.) + km/mi tanlovi Company/haydovchi darajasida.

| Sozlama | Qiymatlar | Default |
|---|---|---|
| `region` | `PK`, `UZ`, `US`, `other` | mijozga qarab |
| `unit_system` | `metric` (km, km/h, °C, litr) / `imperial` (mi, mph, °F, gal) | `metric` |
| `regulation_profile` | `fmcsa_us` (IFTA, US DOT, FMCSA eksport labellari yoqiladi) / `generic` | `generic` |
| `hos_policy` | §4 parametrlari | FMCSA 70/8 |
| `distance_regions` | masofa hisoboti uchun hudud ro'yxati (AQSh shtatlari / Pokiston viloyatlari / O'zbekiston viloyatlari) | region bo'yicha |

**Q0.1** Barcha masofa/tezlik qiymatlari **bazada SI (metr, km/h)** saqlanadi; UI `unit_system`ga qarab konvertatsiya qiladi. Dizayndagi `mph/miles` — faqat `imperial` rejimda ko'rinadi.
**Q0.2** `US DOT`, `IFTA`, `FMCSA Report`, `License Plate Issue State` labellari `regulation_profile`ga qarab: `generic`da → `Registration No`, `Distance by Region`, `Regulator Export`, `Plate Issue Region`.

## 2. Faollik holati (Active / Inactive / Deleted)

**Q1** Active ⇄ Inactive — qaytariladigan; Delete — soft-delete, qaytarib bo'lmaydi (UI'da).
**Q2** Inactive yozuvlar alohida tabda; Delete qilinganlar faqat Super Admin'ga.
**Q3** Har ikkala o'tish `audit_log`ga.
**✅** Inactive: `status=inactive`, `deleted_at=null`. Delete: `deleted_at` yoziladi. Bog'liq log/DVIR/telemetriya **o'chmaydi**, hisobotlarda Active davr ko'rinadi, Inactive davr ham **"include inactive" filtri bilan** ko'rish mumkin (v1'dan farqi: audit uchun tarix yopilmaydi).
**Q3.1** Inactive Driver ilovaga kira olmaydi (`403 ACCOUNT_INACTIVE`), sessiyalari bekor qilinadi. Inactive Unit'ga ELD ulanmaydi.

## 3. Duty status

### 3.1 Holatlar
`OFF` · `SB` · `DR` · `ON` + maxsus rejimlar: **`OFF (PC)`** — Personal Conveyance, **`ON (YM)`** — Yard Move.
**Q4** `DR` qo'lda tanlanmaydi (tugmalar: Off-duty / On Duty / Sleep). PC va YM — `Off-duty`/`On Duty` ostidagi ichki variant sifatida (`🎨` kichik dizayn qo'shimchasi: status modalida "Personal conveyance" / "Yard move" toggle). Company `hos_policy.allow_pc`, `allow_ym` bilan yoqiladi.
**Q4.1** PC rejimida harakat `DR` deb yozilmaydi (OFF hisoblanadi, HOS'ga kirmaydi), lekin telemetriya to'liq yoziladi va logda `PC` belgisi bilan ko'rinadi. **B:** FMCSA §395.8, Samsara/Motive.
**Q4.2** YM rejimida harakat `ON` hisoblanadi (Drive limitga kirmaydi, Shift'ga kiradi). Tezlik `hos_policy.ym_max_speed_kmh` (default 32 km/h ≈ 20 mph) dan oshsa YM avtomatik tugaydi → `DR`.
**Q4.3** Unit `sleeper_berth=false` bo'lsa `SB` tugmasi o'chiq (v1 Q86).

### 3.2 Avtomatik `DR`
**✅ Q5** ECM tezligi ≥ `hos_policy.motion_threshold_kmh` (default **8 km/h ≈ 5 mph**) → `DR` + haydash rejimi ekrani. Manba: ELD/ECM; ECM yo'q bo'lsa (malfunction) — GPS tezligi fallback, event `source=gps_fallback` belgisi bilan.
**Q5.1** To'xtash: tezlik 0 va ≥ 3 soniya (v1 kabi).
**Q5.2** Haydash rejimida har **60 daqiqada** intermediate location event yoziladi (**B:** FMCSA "intermediate log", Samsara/Motive).
**Q5.3** ELD ulangan, lekin **hech qanday haydovchi login qilmagan** holda harakat → **Unidentified driving** (§10.4).

### 3.3 Harakatsizlik so'rovi
**Q6** 5 daqiqa harakatsizlik → `You've been idle for 5 minutes…`. `Yes, driving` → `DR`. `No` **yoki 1 daqiqa javobsiz** → `ON`. Avtomatik o'tish vaqti — so'rov chiqqan payt (5 daqiqa oldingi to'xtash vaqti emas — **B:** FMCSA 6 daqiqa qoidasi: 5 daq + 1 daq).

### 3.4 Status o'zgartirish formasi
**Q7** `Location` (avtomatik, qo'lda tuzatish mumkin), `Notes` (≤60 belgi, shablon yoki qo'lda), `Trailer(s)`, `Shipping Doc(s)` — ro'yxat, bir nechta bo'lishi mumkin. Trailer/doc o'zgarishi statusni o'zgartirmasdan ham mumkin (`🎨` status modalidan alohida "Update trailer/doc" — v1 Q7 dizayn matni saqlanadi, lekin alohida hodisa `TRAILER_CHANGE`/`DOC_CHANGE` yoziladi).
**Q7.1** ELD ulanmagan (`Not connected`) holda qo'lda status o'zgartirish **mumkin** (haydovchi kabinada emas yoki qurilma buzilgan); bunday event `origin=manual_no_eld`, `time_source=phone`, `time_unverified=true` belgisi bilan yoziladi va admin logida sariq belgi bilan ko'rinadi. **B:** Motive/Samsara "Manual log entry — device not connected".

### 3.5 Joylashuv
**Q9** GPS aniqligi > 150 m → "location might be inaccurate" taklifi. Location matni: reverse-geocoding orqali `"12 km NE of <shahar>"` formatida (**B:** FMCSA format), geocoding natijasi keshlanadi (QISM B §7.3).

## 4. Hours of Service (HOS)

### 4.1 Hisoblagichlar
`BREAK` · `DRIVE` · `SHIFT` · `CYCLE` — qolgan vaqt (v1 Q10–Q12). Ranglar v1 kabi.

### 4.2 `hos_policy` parametrlari **[MUST]** (Company darajasida, versiyalanadi — QISM D §1)

| Kalit | Default (FMCSA 70/8) | Izoh |
|---|---|---|
| `drive_limit_min` | 660 (11h) | |
| `shift_window_min` | 840 (14h) | birinchi ON/DR'dan boshlanadi |
| `break_required_after_drive_min` | 480 (8h) | |
| `break_duration_min` | 30 | |
| `break_qualifying_statuses` | `[OFF, SB, ON]` | 2020 qoidasi: ON ham hisoblanadi; `[OFF, SB]` — qat'iy variant |
| `daily_rest_min` | 600 (10h) | uzluksiz OFF/SB → Shift/Drive reset |
| `cycle_limit_min` | 4200 (70h) | yoki 3600 (60h) |
| `cycle_days` | 8 | yoki 7 |
| `cycle_restart_min` | 2040 (34h) | uzluksiz OFF/SB → Cycle reset; `null` = restart yo'q |
| `sleeper_split_enabled` | true | 7/3 va 8/2 split (jami ≥10h, biri ≥7h SB) |
| `allow_pc`, `allow_ym`, `ym_max_speed_kmh` | true, true, 32 | |
| `motion_threshold_kmh` | 8 | |
| `short_haul_exception` | false | MAY (2-bosqich) |
| `adverse_conditions_extension_min` | 120 | MAY — haydovchi qo'lda yoqadi, sabab bilan |

**Q10.1** Parametrlar o'zgarganda `hos_policy_versions`ga `effective_from` bilan yangi yozuv; **eski kunlar o'sha paytdagi siyosat bilan** hisoblanadi (retroaktiv violation paydo bo'lmaydi).

### 4.3 Hisoblash qoidalari (algoritm — o'zgarmas)
**Q10.2 Kun chegarasi:** Daily Log kuni = Company (yoki Driver'ning Home Terminal) **timezone'idagi 00:00–24:00**. Barcha eventlar UTC'da saqlanadi, kunga ajratish TZ bo'yicha. Haydovchi TZ kesib o'tsa ham kun o'zgarmaydi. **B:** FMCSA "home terminal time".
**Q10.3 Shift:** `daily_rest_min` uzluksiz OFF/SB'dan keyingi birinchi ON/DR'dan boshlanadi; 14h oynaga OFF/SB kirmaydi (uzaytirmaydi).
**Q10.4 Break:** oxirgi ≥30 daq uzluksiz `break_qualifying_statuses`dan keyin 8h yig'indi DR bo'lsa → Break=0 → keyingi DR = violation.
**Q10.5 Cycle:** oxirgi `cycle_days` kun (bugun bilan) ON+DR yig'indisi; `cycle_restart_min` uzluksiz OFF/SB → 0.
**Q10.6 Sleeper split:** SB ≥7h (yoki ≥8h) + OFF/SB ≥2h (≥3h) juftligi = daily rest ekvivalenti; uzun qism 14h oynani "to'xtatadi".
**Q10.7 Recap:** `recap[d] = cycle_limit − Σ(ON+DR, oxirgi cycle_days)` va ertaga qo'shiladigan soat = `cycle_days` kun oldingi kunning ON+DR. **[SHOULD]** — v1'da ⏸ edi; formula aniq bo'lgani uchun MVP'ga kiritiladi (faqat derived qiymat).
**Q10.8 Ikki implementatsiya, bitta haqiqat:** HOS hisoblagich **Flutter (offline) va Go backend (`internal/hos` paketi)**da bir xil bo'lishi shart. Talab: `hos-test-vectors.json` (≥30 ssenariy: oddiy kun, split sleeper, restart, PC/YM, TZ o'tishi, offline kechikkan eventlar) — ikkala kodbaza CI'da shu vektorlardan o'tadi **[MUST]**. Server hisobi — kanonik (violation'lar serverda yaratiladi); mobil — ko'rsatish va oldindan ogohlantirish.
**Q10.9** Haydash rejimi ekranida `Driving Time Left = min(DRIVE, SHIFT, CYCLE, BREAK)`.

## 5. Kunlik log (Daily Log)

### 5.1 Tuzilishi
**Q13** Log = eventlar ketma-ketligi; grid — vizual; jamilar — davomiylikdan.
**Q15** `duty_status_events.event_type`: `status_change` (OFF/SB/DR/ON, PC/YM bayrog'i bilan), `intermediate` (60 daq), `power_on/power_off` (ELD), `login/logout`, `pti` (pre-trip inspection belgisi), `fuel`, `certify`, `trailer_change`, `doc_change`, `malfunction`, `diagnostic`, `engine_on/off`. Grid ustida faqat `pti/fuel/certify/malfunction` ikonkasi.
**Q13.1** Har bir event: `event_time` (UTC), `time_source (eld_rtc/phone/server)`, `origin (auto/driver/admin_edit/assigned)`, `location` (lat, lng, matn), `odometer_m`, `engine_hours`, `notes`, `unit_id`, `eld_device_id`, `client_event_id`, `seq` (qurilma ketma-ket raqami).

### 5.2 Log Form
**Q16** Kunlik "shapka": Unit(lar), Driver, Co-Driver, Distance (telemetriyadan, qo'lda tuzatilmaydi), Trailers[], Shipping Docs[], Signature. Bir kunda bir nechta unit bo'lsa — ro'yxat.

### 5.3 Log tahrirlash — **taklif/tasdiq modeli [MUST]** (v1'dan tubdan farq)
**B:** FMCSA §395.30(c); Samsara "Log edit request", Motive "Edit request → driver approves", Geotab "Proposed edits". Admin hech qachon logni bevosita o'zgartirmaydi.

```
Admin "Insert/Edit duty status" (From, To, Status, Note*) 
   → log_edit_requests (pending)
   → Push haydovchiga: "Admin proposed a change to your log for <date>"
   → Haydovchi ilovasida "Pending edits" ekrani 🎨 (Approve / Reject + sabab)
   → Approve: yangi event(lar) `origin=admin_edit`, asl eventlar `superseded_by` bilan saqlanadi;
              kun `certification_status=needs_recertify`
   → Reject: request `rejected`, log o'zgarmaydi, admin xabar oladi
```
**Q17** Note majburiy. Haydovchining o'zi ham o'z logini tahrirlashi mumkin (`origin=driver_edit`, note majburiy) — o'sha darhol qo'llanadi, asl saqlanadi.
**Q17.1 Taqiqlar:** avtomatik yozilgan `DR` vaqtini qisqartirish yoki `DR`ni boshqa statusga o'zgartirish **mumkin emas** (faqat `DR`→`PC/YM` haydovchi tomonidan, sabab bilan, va faqat unidentified→assign). `intermediate`, `power`, `malfunction` eventlar tahrirlanmaydi.
**Q17.2** Tahrirlangan event logda `✎` belgisi va tooltip'da asl qiymat + kim + qachon (Audit §17).
**Q18** Sertifikatlangan kun tahrirlansa → `needs_recertify`, haydovchi qayta imzolaydi (§6).

## 6. Sertifikatsiya
**Q19/✅** Oyna `certification_window_days = 8` (global konstanta). Ro'yxat: oxirgi 8 kun, holatlar `Certified / Uncertified / Needs re-certify`.
**Q19.1** 8 kundan eskirgan sertifikatlanmagan kun: ro'yxatda qolmaydi, lekin **admin "Uncertified logs" hisoboti/alerti**da ko'rinadi va haydovchi `Log Report`dan istalgan kunni ochib imzolashi mumkin **[SHOULD]**. **B:** Samsara/Motive.
**Q20–Q24** v1 kabi: `Certify All / Selected / Today`; imzo — chizish yoki saqlangan; huquqiy matn. Saqlangan imzo `signatures` jadvalida (object storage, shifrlangan).
**Q25/✅** `Not Ready` = faqat imzo yo'q. Trailer/Doc bo'sh — Warning (§12).
**Q26** Admin haydovchi nomidan sertifikatlamaydi. Admin DVIR/log uchun "Paste signature" — **olib tashlanadi** (🎨), o'rniga §7.4.
**Q26.1** Sertifikatsiya = event `certify` + `daily_logs.signed_at`, imzo rasm kaliti, `signed_ip/device_id`. Sertifikatlangan eventlar `locked=true` (faqat edit-request orqali).

## 7. DVIR

### 7.1 Yaratish oqimi
v1 kabi + **`type`**: `pre_trip` / `post_trip` (haydovchi tanlaydi; default — kun boshida pre, oxirida post). 🎨 bitta toggle. **B:** barcha yetakchilarda pre/post ajratiladi.
**Q27** Mechanic Signature faqat "defects fixed" da. **Q28** Time/Location/Odometer avtomatik.
**Q27.1** Nuqson ro'yxati — `defect_types` katalogi (Company darajasida sozlanadi; default 43 truck + trailer bandlari, `Engine` dublikati va `Refresh` olib tashlangan). Har nuqsonga foto (≤5) va izoh.
**Q27.2** Kritik nuqsonlar (`is_critical=true`: brakes, steering, tires, lights…) → Unit `out_of_service` bayrog'i, admin/Service Manager'ga darhol alert **[SHOULD]**.

### 7.2 Holat mashinasi
```
draft → submitted_no_defects
draft → submitted_defects_found → repaired (Service Manager, note + ixtiyoriy invoice) → certified
```
**✅** `certified`: keyingi pre-trip DVIR'da shu Unit uchun tizim "Previous defects repaired?" so'raydi → haydovchi imzosi. **Q30.1 Fallback:** 7 kun ichida keyingi DVIR bo'lmasa yoki boshqa haydovchi tasdiqlasa ham qabul; Unit inactive bo'lsa `closed_no_certification` holati bilan yopiladi.
**Q30.2** `in_progress` holati — faqat mobil lokal (draft), serverga `submitted` bilan boradi; admin jadvalida `Not Started` = kun uchun DVIR yo'q (derived), `In Progress` ko'rsatilmaydi.

### 7.3 DVIR turlari (mobil)
`No defects` · `Defects – not fixed` · `Defects – fixed` — holatdan derived.

### 7.4 Admin tomonidan DVIR
**Q31 (o'zgardi):** Admin **haydovchi nomidan DVIR yaratmaydi**. `Generate Report` = mavjud DVIR'lardan **hisobot/PDF** shakllantirish (Driver, Date range, Unit). 🎨 forma soddalashadi. Sabab: imzoni admin "joylashtirishi" auditda haqiqiy imzo emas. Istisno **[MAY]**: qog'oz DVIR'ni kiritish — `source=paper_import`, imzo skan fayl, haydovchi tasdig'i bilan.

## 8. Maintenance
**Q32** Schedule → Due → History; holat o'zgaradi, yozuv ko'chmaydi.
**Q33 (nomlar aniqlashtirildi):** `last_service_value` (dizaynda "Current Frequency"), `interval` (Maintenance Frequency), `next_due_value = last_service_value + interval`, `remaining = next_due_value − current_value`; `current_value` — telemetriyadan (odometer/engine hours) yoki sana. UI labellari dizayndagidek qoladi, ma'nosi tooltip'da.
**Q34** `remaining < 0` → overdue, qizil. **Q35** Birlik: km/mi (unit_system), days, engine hours.
**Q37/Q38** Reminder `reminder_before` ga yetganda bir marta; `Reminder Sent` qayd; co-driver'ga ham.
**Q39/Q40** Multiple units → `maintenance_schedule_units` (har unitning o'z `last_service_value`, `next_due_value`).
**Q41–Q43** Yakunlash: Invoice #, Vendor, Cost, Date, PDF/JPG; cancelled — moliyaviy maydonsiz.
**Q42.1** Complete qilinganda `last_service_value` = o'sha paytdagi odometer/engine hours; `Due` → `Schedule` (yangi `next_due_value`).
**Q44** Mobilda maintenance yo'q (MVP); haydovchiga faqat bildirishnoma.
**Bog'liqlik:** odometer/engine-hours asosli rejalar **telemetriya**ga muhtoj (QISM D Timeline'da to'g'rilandi).

## 9. Co-driver va bitta kabinada ikki haydovchi

**B:** Samsara/Motive: ikkala haydovchi bitta qurilmada o'z hisobi bilan login qiladi ("Team driving"); faol haydovchi (`DR` egasi) bittasi; ikkinchisi `OFF/SB/ON`.

**Q45** Kabinada bir qurilma (planshet yoki telefon) ikki haydovchi sessiyasini ushlaydi: `active_driver` va `co_driver`. Ikkalasi ham o'z parolи bilan login qiladi (bir marta), keyin `Switch` → tasdiq → kim faol haydovchi ekani almashadi (PIN/parol qayta so'raladi — 🎨 `Switch` modaliga PIN maydoni).
**Q45.1** Harakat aniqlanganda `DR` faqat `active_driver`ga yoziladi; co-driver statusi o'zgarmaydi.
**Q46** Trailer/Doc — haydovchi bo'yicha; switch'da "Myself / Co-driver" tanlovi (v1).
**Q47** Admin ikkala logni ko'radi.
**Q45.2 Leave Truck:** haydovchi `Leave Truck` bosganda: status `OFF` (tasdiq bilan), ELD ulanishi uziladi, sessiya **saqlanadi** (`paused`), ekran login/`Return to truck`ga qaytadi. `Return to truck` → parol/PIN → ELD qayta ulanadi. Co-driver qolsa u faol bo'ladi. Haydovchi mashinani tark etsa-yu, mashina yursa → unidentified driving.

## 10. ELD qurilmasi

### 10.1 Holatlar
Mobil: `Connected / Not connected`. Admin: `Online` (telemetriya ≤ 5 daq), `Offline` (>5 daq, oxirgi holat ma'lum), `Disconnected` (ELD ↔ telefon uzilgan, qurilma xabar bergan) , `Malfunction`.
### 10.2 Ruxsatlar — v1 Q49–Q50 (Location always, Bluetooth, Notifications). QISM B §22 platforma cheklovlari.
### 10.3 Diagnostika — v1 Q51–Q52.
### 10.4 Unidentified driving **[MUST]** (yangi)
**B:** FMCSA §395.32; Samsara "Unassigned HOS", Motive "Unidentified driving events", Geotab "Unassigned logs".
- ELD qurilma harakatni **o'zi** (login bo'lmasa ham) yozadi va buferlaydi; telefon ulanganda yoki qurilma to'g'ridan-to'g'ri (agar SIM bo'lsa) serverga yuboradi → `unidentified_events` (unit, start/end, masofa, trek).
- Haydovchi login qilganda ilova: "There are N unidentified driving events on this vehicle. Claim?" → qabul qilsa event uning logiga `origin=assigned` bilan qo'shiladi.
- Admin `Unassigned driving` ekrani 🎨: haydovchiga tayinlash (taklif → haydovchi tasdig'i, §5.3) yoki izoh bilan "unassigned" qoldirish (masalan mexanik test-drive).
- 8 kundan ortiq tayinlanmagan → admin alerti.
### 10.5 Malfunction / Diagnostic **[SHOULD]**
Standart kodlar (FMCSA Appendix A namunasida): `P` power, `E` engine sync, `T` timing, `L` positioning, `R` data recording, `S` data transfer, `O` other. Haydovchiga banner (`ELD malfunction — keep paper logs`), adminga alert, event `malfunction` logga yoziladi.

## 11. Inspection Report (yo'l tekshiruvi)
**Q53** 7 kun + bugun. **Q54** `Begin Inspection` — soddalashgan ekran + PIN bilan chiqish (`🎨` inspektor boshqa ekranga o'tolmasin).
**Q55/Q56 (o'zgardi):** `Send via email` — PDF (log grid + eventlar + Log Form), `Send the file` — `regulation_profile=fmcsa_us` da FMCSA ELD output file (web service/email); `generic` da CSV + PDF ZIP. Comment ixtiyoriy.

## 12. Ogohlantirishlar va qoidabuzarliklar

**Q57** Ikki daraja: `warning` / `violation`. Serverda yaratiladi (kanonik), mobil oldindan ko'rsatadi.

| Tur | Warning | Violation | Yopilishi |
|---|---|---|---|
| `form_manner_trailer` / `form_manner_doc` | kun ochiq, maydon bo'sh | kun sertifikatlangan, maydon bo'sh | maydon to'ldirilib qayta sertifikatlansa |
| `drive_limit` | qolgan ≤ 30 daq (sozlanadi) | DR limitdan oshdi | daily rest'dan keyin |
| `shift_limit` | qolgan ≤ 60 daq | Shift oynasidan tashqarida DR | daily rest'dan keyin |
| `break_required` | qolgan ≤ 30 daq | 8h DR'dan keyin tanaffussiz DR | qualifying break'dan keyin |
| `cycle_limit` | qolgan ≤ 2 h | Cycle'dan oshib DR | restart yoki kun tushib qolishi bilan |
| `uncertified_log` | 1 kun | ≥ 2 kun sertifikatlanmagan | imzo |
| `unidentified_driving` | — | 8 kun tayinlanmagan | tayinlash |
| `eld_malfunction` | diagnostic | malfunction | qurilma tiklanganda |
| `missing_dvir` **[MAY]** | pre-trip yo'q, harakat boshlandi | — | DVIR yuborilsa |

**Q58 (aniqlashtirildi):** dizayndagi "Violations can be removed after completion of second qualify break" → `break_required` violation qualifying break bilan yopiladi; `drive/shift` — daily rest bilan. Violation **o'chmaydi**, `resolved_at` bilan yopiladi va tarixda qoladi (**B:** Samsara — violation tarixi saqlanadi).
**Q59** Filtrlar mustaqil. **Q60** Dashboard `Violations: This week` = **joriy ISO hafta (Du–Ya), Company TZ**.
**Q57.1** Warning chegaralari `hos_policy.warning_thresholds` da sozlanadi.

## 13. Tracking

**Q61/Q62** Telemetriya ECM'dan: VIN, odometer, engine hours, fuel, coolant, oil, tezlik, batareya, bus turi.
**Q63 (o'zgardi):** Xarita **avtomatik** yangilanadi (WebSocket, §B5); `Refresh` tugmasi qoladi (majburiy re-fetch). Har unit `last_seen` nisbiy vaqt.
**Q63.1 Yuborish chastotasi (qurilma → server):** haydashda har **30 s yoki 300 m** (qaysi avval), to'xtaganda har 5 daq, ignition off — 1 hodisa. Offline'da lokal buferga, keyin batch.
**Q64/Q65** Segmentlar (trip) — ignition on → off yoki ≥ 15 daq to'xtash bo'yicha; vaqt Company TZ bilan.
**Q66–Q68 Trip Planner / Route:** `ongoing` yaratilganda; `completed` — unit destination **geofence radiusi (default 300 m)** ichida ≥ 2 daq turganda; `not_completed` — admin, sabab ro'yxati (`breakdown, cancelled, load_rejected, road_closed, driver_change, other` + izoh). Bir unitda bir vaqtda bir nechta route bo'lsa — `sequence` bilan, `completed` faqat joriy (eng kichik sequence) uchun tekshiriladi.
**Q66.1** Marshrut chizig'i — xarita provayderining routing API'si (QISM B §7.3); haydovchiga push + ilovada "Open in Maps".

## 14. Hisobotlar

| Hisobot | Tarkib | Shakllantirish |
|---|---|---|
| **Distance by Region** (dizaynda IFTA) | Unit/Region/Distance/Month; `regions & units` / `regions only`; chorak+yil | Telemetriya trekini `distance_regions` poligonlariga kesib hisoblash; **kunlik agregat** (`unit_region_distance_daily`) — hisobot darhol tayyor (v1'dagi "5-kunga qadar" olib tashlandi) |
| **Regulator Export** (dizaynda FMCSA) | Driver, 8 kun / custom range, comment | `fmcsa_us` — FMCSA output file + web-service (2-bosqich); `generic` — PDF+CSV darhol. Status `ready/failed` |
| **Activity Report** | Drivers / Units, Start/End Odometer, Odometer Change | jonli jadval, CSV/Print |
| **HOS Summary** | haydovchi bo'yicha kunlik jamilar, violation'lar | CSV/PDF |
| **DVIR Report** | filtrlangan DVIR ro'yxati + PDF | §7.4 |
| **Uncertified logs / Unassigned driving** | §6, §10.4 | jonli |

**Q75** `Odometer Change = End − Start`. Barcha eksportlar `reports_export_jobs` orqali asinxron (katta hajm), tayyor bo'lganda bildirishnoma + yuklab olish havolasi (24 soat amal qiladi).

## 15. Support, Feedback, Chat

**Q77–Q80** Tiket `new → in_progress → resolved` (admin), kanal tanlovi, feedback javobsiz — v1 kabi. Qo'shimcha: tiketga fayl (≤3), admin javobi tiket ichida (thread) **[SHOULD]**.

### 15.4 Chat **[SHOULD]** (yangi spetsifikatsiya)
- Kanal: **Company ofisi ↔ Driver** (1:1, driver tomonida bitta "Dispatch" chati; admin tomonida haydovchilar ro'yxati). Guruh chat — MAY.
- Xabar: matn (≤ 2000), rasm/PDF (≤ 10 MB), joylashuv ulashish. `sent/delivered/read` holatlari.
- Transport: WebSocket `chat` kanali (admin) + Push (driver); offline'da navbatga, qaytganda yuboriladi.
- Haydash rejimida chat **bloklanadi** (faqat ovozli o'qish — MAY). **B:** Samsara/Motive driver distraction policy.
- Saqlash: 1 yil.

## 16. Rollar va ruxsatlar **[MUST]**

**Q81** Rol → permission to'plami; User → bitta rol; rollar dinamik (`Add Role`); `Super Admin` (tizim), `Administrator` (kompaniya) — `is_system=true`, o'chirilmaydi.
**Q82 Yakuniy permission kalitlari:**

| Modul | Kalitlar |
|---|---|
| dashboard | `dashboard.view` |
| units | `units.read/create/update/deactivate/delete` |
| drivers | `drivers.read/create/update/deactivate/delete`, `drivers.reset_password` |
| users, roles | `users.*`, `roles.*` (read/create/update/delete) |
| logs | `logs.read`, `logs.propose_edit`, `logs.assign_unidentified`, `logs.export` |
| dvir | `dvir.read`, `dvir.repair`, `dvir.export` |
| maintenance | `maintenance.read/create/update/complete/cancel/delete` |
| tracking | `tracking.view_live`, `tracking.view_history`, `routes.read/create/update` |
| violations | `violations.read` |
| reports | `reports.read`, `reports.export` |
| support | `support.read`, `support.update_status`, `feedback.read`, `chat.use` |
| company | `company.read/update`, `branches.*`, `audit.view`, `hos_policy.update` |

**Q82.1 Scope:** har rolga `scope = company | branch`; Driver roli — `self` (faqat o'z ma'lumoti, mobil API). Branch scope → barcha so'rovlar `branch_id` bilan filtrlanadi.
**Default rollar (namuna, o'zgartirsa bo'ladi):** Administrator (hammasi), Sub Admin (branch scope, hammasi minus `company.update`, `roles.*`, `hos_policy.update`), Fleet Manager (units/drivers/routes/tracking/logs.propose_edit), Dispatcher (tracking/routes/chat), Service Manager (dvir.repair, maintenance.*), Safety Manager (logs/violations/dvir read+export, logs.propose_edit), Data Analyst (barcha `.read`, `reports.export`), Driver (mobil).
**Q82.2** Delete faqat soft; audit-muhim modullarda (`logs`, `dvir`, `violations`, `telemetry`, `audit_log`) `delete` **yo'q**.

## 17. Audit va tarix
**✅** Yagona `audit_log` (§D1). UI'dagi 4 jurnal — filtrlangan ko'rinishlar. Qo'shimcha yoziladi: login/logout/failed login, permission o'zgarishi, eksportlar (kim nimani yuklab oldi), log-edit request'lar, hos_policy o'zgarishi. `audit_log` **append-only** (DB darajasida UPDATE/DELETE taqiqlangan rol).

## 18. Ma'lumot kiritish qoidalari

### 18.1 Majburiy maydonlar (o'zgarishlar qalin)
| Modul | Majburiy |
|---|---|
| Unit | Unit #, Make, Model, License Plate, Fuel Type (ELD, VIN — ixtiyoriy; **VIN ECM'dan o'qilsa to'ldiriladi**) |
| Driver | First/Last Name, Username, Phone, Email **(SMS/Email invitation uchun kamida bittasi)**, License No (**Co-Driver, Password — ixtiyoriy/yo'q**) |
| User | First/Last Name, Email yoki Phone, Role |
| Maintenance | v1 kabi |
| Distance Report | regions, units (rejimga qarab), quarter, year |
| Regulator Export | type, driver, (custom range) |
| Log edit request | From, To, Status, Note |
| Company | Name, Address, Time zone, region, unit_system (Registration No — ixtiyoriy) |

### 18.2 Shartli maydonlar — v1 §18.2 saqlanadi (Sleeper Not Available, VIN usuli, Multiple Units, regions only, Custom Range, Defects corrected, Email).

### 18.3 Cheklovlar
Izoh 60 belgi · Rows per page 10/25/50 · Invoice PDF/JPG/PNG ≤ 10 MB · DVIR foto ≤ 5 × 5 MB · Sertifikatsiya oynasi 8 kun · Inspection 7+1 kun · Username 4–32, `[a-z0-9._]` · Parol ≥ 10 belgi, harf+raqam · VIN 17 belgi (ixtiyoriy tekshiruv) · Plate — regionga qarab regex (sozlanadi).

### 18.4 Sana/vaqt, birliklar, fayl formatlari
- DB/API: ISO 8601 UTC; Company TZ — kun chegarasi (§4.3).
- UI: `DD/MM/YYYY`, 24 soat (`generic`), `MM/DD/YYYY` 12 soat (`fmcsa_us`) — `regulation_profile`ga bog'liq.
- Birliklar: §1.4.
- Import: CSV/XLSX, **shablon fayl yuklab olinadi** (`drivers_import_template.csv`: first_name, last_name, username, phone, email, license_no, license_region, home_terminal; `units_import_template.csv`: unit_number, make, model, year, plate, plate_region, vin, fuel_type, sleeper_berth). Validatsiya: qator-qator xato hisoboti, hech narsa yozilmaydi agar ≥1 kritik xato (`all-or-nothing`, MAY: partial).
- Export: CSV/XLSX/PDF.

## 19. Bildirishnomalar
**Q87/Q88** Sana bo'yicha guruh, aniq qiymatlar — v1 kabi.

| Alert Type | Kimga | Kanallar (default) |
|---|---|---|
| `hos_warning` / `hos_violation` | Driver, Safety/Fleet Manager | Push · Push+Email |
| `route_assigned` / `route_completed` | Driver / Admin | Push |
| `dvir_defects` / `dvir_critical` | Service Manager, Fleet Manager | Push+Email · Push+Email+SMS |
| `log_edit_request` / `log_edit_resolved` | Driver / Admin | Push |
| `uncertified_log` | Driver (kunlik 1 marta, 20:00 Company TZ) | Push |
| `unidentified_driving` | Admin | Push+Email |
| `eld_disconnected` / `eld_malfunction` | Driver, Admin | Push · Push+Email |
| `maintenance_upcoming` / `overdue` | Fleet/Service Manager (+ co-driver) | Push+Email |
| `chat_message` | ikkala tomon | Push |
| `subscription_expiring` | Administrator | Email (14, 3, 1 kun) |

**Q89** Kanallar: Push (FCM/APNs), Email, SMS, Telegram (**[MAY]**) — provayder abstraktsiyasi. Company darajasida har alert uchun kanal/qabul qiluvchi sozlanadi; foydalanuvchi o'zi Push'ni o'chira olmaydi faqat `hos_*`, `eld_*` uchun (xavfsizlik). "Quiet hours" — MAY.

## 20. Dashboard (yangi)
KPI kartalar (Company TZ): `Active Units` (bugun telemetriya bergan), `Drivers On Duty` (hozir ON/DR), `Violations` (joriy hafta), `Disconnected ELD` (hozir), `Uncertified Logs` (≥2 kun), `Unassigned driving` (kutayotgan). Status bloki: hozirgi OFF/SB/DR/ON soni. `Route's Details` — bugungi marshrutlar. Har karta → tegishli ekranga havola. Yangilanish: 60 s polling yoki WS `dashboard` kanali.

## 21. Qarorlar reestri (v2)

| № | Savol | Qaror |
|---|---|---|
| 1–16 | v1 reestri | Saqlanadi, quyidagilar bilan o'zgartirilgan: 1 (Inactive davri hisobotda ko'rinadi), 6 (Recap MVP'ga), 9 (DVIR fallback), 10 (Violation jadvali), 12 (permission ro'yxati yakuniy) |
| 17 | Bozor/domen | `regulation_profile` + `unit_system`; IFTA/FMCSA generic |
| 18 | Log tahrirlash | taklif/tasdiq, DR qisqartirilmaydi |
| 19 | Unidentified driving | MUST |
| 20 | Session | 1 telefon + 1 planshet + web |
| 21 | Parol | invitation; Driver formasida parol yo'q |
| 22 | Co-Driver majburiyligi | ixtiyoriy |
| 23 | Admin DVIR | hisobot, nomidan yaratish yo'q |
| 24 | Billing MVP | qo'lda/invoice, self-service 2-bosqich |
| 25 | Bosh ekran A/B | ❓ B taklif |
| 26 | Xarita provayderi | ❓ §B7.3 taklif |
| 27 | ELD qurilma modeli | ⏸ §B8 mezonlar bo'yicha tanlanadi |
| 28 | Privacy/Terms | ❓ buyurtmachidan |
| 29 | Fuel Type ro'yxati | Diesel, Petrol, CNG, LPG, Electric, Hybrid (Company sozlaydi) |
| 30 | Acceptance criteria | MUST (§D6) |

---

# QISM B — TEXNIK ARXITEKTURA

## 0. Loyiha konteksti (to'g'rilandi)
- Mijoz — Pokiston; dastlabki bozor — Pokiston ichki tashish; keyingi — Markaziy Osiyo; uzoq muddat — AQSh (`fmcsa_us` profili shu uchun saqlanadi).
- Qamrov — og'ir CMV; GVWR filtri MAY.
- **Ishlab chiqish — Devline (pudratchi).** Shuning uchun acceptance criteria, DoD, bosqichli qabul, o'zgarish so'rovlari (change request) jarayoni — **majburiy** (§D6).
- Uch klient: Admin (veb), Driver (telefon), Driver (planshet, kabina). Backend umumiy.

## 1. Offline rejim va vaqt yaxlitligi

**Q-B1.1 Offline-first:** mobil ilova lokal DB (SQLite/Drift yoki Isar) — barcha eventlar, HOS holati, so'nggi 8 kun log, DVIR draft, chat navbati. Internet qaytganda avtomatik sync (§D2 protokol).
**Q-B1.2 Vaqt manbai (ustuvorlik):** 1) ELD RTC (GPS bilan sinxron) → 2) server vaqti (oxirgi sync'da olingan offset) → 3) telefon soati (`time_unverified=true`). Telefon soati bilan ELD/server farqi > 2 daq → haydovchiga ogohlantirish, eventda `clock_skew_sec` yoziladi. **B:** FMCSA "timing compliance" malfunction (>10 daq).
**Q-B1.3 Lokal saqlash chegarasi:** kamida **14 kun** eventlar + telemetriya bufer (≈ 2×30 s × 14 kun ≈ 40 000 nuqta) — 100 MB dan kam.
**Q-B1.4** Transport: ELD ↔ telefon — BLE (background); telefon ↔ server — HTTPS (REST batch) + WebSocket (faqat admin/planshet real-vaqt). `MessageTransport` abstraktsiyasi saqlanadi (MQTT kelajakda, ayniqsa SIM'li qurilmalar uchun).

## 2. Ma'lumotlar bazasi — audit arxitekturasi
- Markazlashgan `audit_log` (append-only; DB roli UPDATE/DELETE huquqisiz).
- Soft-delete: `deleted_at` (nullable). `is_deleted` **olib tashlandi** — partial unique index `… WHERE deleted_at IS NULL` va default filtr (ORM scope) yetadi.
- Qayta qo'shilganda yangi yozuv; "Merge" — MAY.
- JSON maydonlar (defects, hos_policy) audit'da `old_value/new_value` JSONB sifatida.

## 3. Xavfsizlik

### 3.1 Token va sessiyalar
- Access token (JWT, 15 daq) + refresh token (opaque, DB'da `sessions` jadvalida, `device_id` bilan bog'langan).
- Driver: refresh 30 kun **sliding**; Admin: 7 kun; `expires_at = min(muddat, company.subscription_end_at + grace 7 kun)`.
- Refresh token rotation (har ishlatilganda yangisi, eskisi bekor; qayta ishlatish → butun sessiya bekor).
- Logout / Leave Truck(`paused`) / Inactive / parol o'zgarishi → tegishli sessiyalar bekor.
### 3.2 API himoyasi
Rate limit: login 5/min/IP + 10/soat/akkaunt (lockout 15 daq, adminга alert); umumiy 600 so'rov/daq/foydalanuvchi; sync batch 60/daq. `429` + `Retry-After`.
### 3.3 Shifrlash
TLS 1.2+ hamma joyda; parol — Argon2id; litsenziya raqami — AES-256-GCM, kalit **KMS/secret manager**da (env faylda emas), kalit aylanishi yiliga; imzo/foto/hujjat — object storage SSE + presigned URL (15 daq); JWT sirlari — KMS. PII loglarga yozilmaydi (mask).
### 3.4 2FA
Super Admin, Administrator — majburiy: **TOTP (authenticator) asosiy**, SMS — zaxira; recovery kodlar (10 ta). Boshqa rollar — ixtiyoriy.
### 3.5 Tenant izolyatsiyasi **[MUST]**
Har so'rov `company_id` token'dan; ORM darajasida global scope + PostgreSQL **Row Level Security** (`SET app.company_id`) ikkinchi qatlam. Cross-tenant test — acceptance'da.
### 3.6 WebSocket auth
Token **`Authorization` header** yoki ulanishdan keyingi birinchi `auth` xabari (URL query'da emas). Ping/pong 30 s, 2 ta o'tkazilsa uzish; qayta ulanishda `since=<ts>` bilan backfill.

## 4. Scalability
Me'yor: 2 000 unit × 100 kompaniya (100 000 unit). Telemetriya: 100 000 × 2/daq × 8 soat haydash ≈ **100 mln nuqta/kun** — bu asosiy yuk. Yechim: TimescaleDB hypertable (`telemetry`), 1 daq/5 daq continuous aggregates, raw nuqtalar **90 kun**, agregatlar 3 yil; Redis — so'nggi joylashuv (`unit:last`). WS: bitta node ≈ 20–50k ulanish; Redis pub/sub bilan gorizontal. MVP boshlang'ich yuk — 1–5 kompaniya, ~100–500 unit.

## 5. Real-vaqt tracking
WS kanallar: `tracking` (unit_id filtri), `notifications`, `chat`, `dashboard`. Yangilanish — qurilma yuborgan zahoti (≤ 30 s). REST — qolgan hamma narsa. Mobil Driver ilovasi WS ishlatmaydi (Push + REST); planshet — ixtiyoriy.

## 6. Texnologiya stacki

### 6.1 Backend — **Go** ✅ (yakuniy qaror)

**Asos:** bitta statik binar (deploy oddiy), goroutine'lar bilan minglab WS/BLE-relay ulanish, past xotira, kuchli typing, uzoq muddatli barqarorlik. Jamoa tanlovi.

| Qatlam | Kutubxona / vosita | Izoh |
|---|---|---|
| Til | **Go 1.23+** | `go.mod`, `go vet`, `golangci-lint` majburiy |
| HTTP router | **chi** (`go-chi/chi/v5`) | Stdlib `net/http` mos, middleware zanjiri; alternativ — echo |
| API hujjati | **swaggo/swag + http-swagger** (code-first) | Handler izohlaridan `swagger.json` + `/api/docs` UI (§6.4) |
| Validatsiya | `go-playground/validator` (struct teglari) | DTO darajasida; xato → `422` + `details[]` |
| DB driver | **pgx v5** (pool) | |
| SQL | **sqlc** (type-safe query'lar `.sql` fayllardan) | ORM emas — RLS/`SET app.company_id` va murakkab HOS/telemetriya query'lari uchun aniq SQL kerak |
| Migratsiya | **goose** (SQL migratsiyalar, forward-only) | CI'da `goose status` tekshiruvi |
| WebSocket | `gorilla/websocket` (yoki `coder/websocket`) + Redis pub/sub | Hub pattern: kanal → obunachilar |
| Queue / job | **asynq** (Redis) | eksport, bildirishnoma, geocoding, violation hisobi, retry/backoff |
| Cron | asynq scheduler | uncertified alert, reminder, retention/lifecycle |
| Cache | `redis/go-redis/v9` | `unit:last`, rate-limit, sessiya kesh |
| Auth | `golang-jwt/jwt/v5`, Argon2id (`x/crypto/argon2`), TOTP (`pquerna/otp`) | |
| Konfiguratsiya | env (`caarlos0/env`) + secret manager | `.env` faqat dev |
| Logging | stdlib **`log/slog`** (JSON) | PII mask middleware |
| Observability | Sentry Go SDK, Prometheus (`promhttp`), OpenTelemetry trace (SHOULD) | |
| PDF | `go-pdf/fpdf` yoki **chromedp** (HTML→PDF, log grid uchun qulay) | headless Chrome alohida konteyner |
| Excel/CSV | `excelize`, `encoding/csv` | |
| Email/SMS/Push | SES/Resend SDK, mahalliy SMS HTTP API, FCM (`firebase.google.com/go`), APNs (`sideshow/apns2`) | `Notifier` interfeysi orqali |
| Geo | PostGIS (SQL) + `paulmach/orb` (polyline, geofence) | |
| Test | stdlib `testing` + `testify`, `testcontainers-go` (Postgres+Timescale), golden fayllar | HOS vektorlari — `internal/hos/testdata/*.json` |
| Rate limit | `ulule/limiter` (Redis) | |

**Loyiha tuzilmasi (standart layout):**
```
cmd/api            — HTTP+WS server (main)
cmd/worker         — asynq worker (jobs, cron)
cmd/migrate        — goose wrapper
docs/              — swag init chiqishi: swagger.json/yaml + websocket.md (qo'lda)
docs/history/      — har bosqich oxiridagi swagger.json nusxasi (oasdiff uchun)
internal/hos       — HOS engine: sof funksiyalar, DB'siz, golden testlar
internal/sync      — offline sync protokoli (push/pull, idempotency, konflikt)
internal/domain/{units,drivers,logs,dvir,maintenance,routes,reports,...}
internal/auth, internal/tenant (RLS/company scope), internal/audit
internal/ws        — hub, kanallar
internal/notify    — Notifier interfeysi + push/email/sms/telegram
internal/geo       — GeoProvider interfeysi (OSM/Google)
internal/db        — sqlc chiqishi, migratsiyalar (db/migrations/*.sql, db/queries/*.sql)
pkg/eldproto       — ELD qurilma protokoli parserlari (vendor bo'yicha)
deploy/            — Dockerfile, compose, GitHub Actions
```
**Qoidalar:** `internal/hos` va `internal/sync` — tashqi bog'liqliksiz (faqat stdlib), shunda Flutter tomonidagi Dart implementatsiya bilan bir xil test-vektorlarni ishlatadi. Har domen paketi: `dto/` (request/response struct'lar, swagger teglari bilan), `service.go` (biznes), `repo.go` (sqlc), `http.go` (handler + swag annotatsiyalari). Kontekst orqali `company_id` va `user` uzatiladi; har DB tranzaksiya `SET LOCAL app.company_id` bilan boshlanadi (RLS).

**DB:** PostgreSQL 16 + TimescaleDB + PostGIS. **Cache/queue:** Redis 7.

### 6.2 Admin panel
React 18 + TypeScript + Vite + Tailwind; TanStack Query; react-hook-form + zod; **API tiplari va klient — backend chiqargan `swagger.json` dan generatsiya** (`openapi-typescript` + `openapi-fetch`), qo'lda tip yozilmaydi (§6.4). Xarita — MapLibre GL (yoki Google Maps SDK). WS — `reconnecting-websocket`.

### 6.3 Mobil/planshet
Flutter 3.x (bitta kodbaza); BLE — `flutter_blue_plus` yoki vendor SDK (platform channel); lokal DB — Drift (SQLite); background — Android foreground service, iOS bluetooth-central/location; **API klient — `swagger.json` dan generatsiya** (`openapi-generator` `dart-dio`); HOS engine — Dart port, `hos-test-vectors.json` bilan.

### 6.4 API hujjati — **code-first Swagger** (swaggo) **[MUST]**

**Ish tartibi:** avval backend to'liq ko'tariladi, keyin frontend. Shuning uchun qo'lda yoziladigan
`openapi.yaml` (spec-first) **ishlatilmaydi** — uning asosiy foydasi (frontend backend'ni kutmasdan
mock'ga qarshi ishlashi) ketma-ket ishlashda yo'qoladi, qo'shimcha yuk esa qoladi.
O'rniga: **Go kodidagi izohlardan Swagger avtomatik generatsiya qilinadi.**

| Nima | Vosita |
|---|---|
| Annotatsiyalar → `docs/swagger.json` + `swagger.yaml` | **swaggo/swag** (`swag init`) |
| Swagger UI endpoint | `swaggo/http-swagger` → `GET /api/docs/index.html` |
| Xom spec | `GET /api/docs/swagger.json` (frontend generatsiya uchun) |
| Model tavsifi | struct teglari: `json:"unit_number" example:"1021"`, `validate:"required"`, `enums:"OFF,SB,DR,ON"` |

**Handler annotatsiyasi namunasi (majburiy format):**
```go
// CreateUnit godoc
// @Summary      Unit yaratish
// @Description  Q18.1 — majburiy: unit_number, make, model, license_plate, fuel_type.
// @Tags         units
// @Accept       json
// @Produce      json
// @Param        body  body      dto.UnitCreate  true  "Unit ma'lumotlari"
// @Success      201   {object}  dto.UnitEnvelope
// @Failure      409   {object}  dto.ErrorResponse  "UNIQUE_VIOLATION"
// @Failure      422   {object}  dto.ErrorResponse
// @Security     BearerAuth
// @x-permission units.create
// @Router       /units [post]
func (h *UnitHandler) Create(w http.ResponseWriter, r *http.Request) { ... }
```

**Qoidalar [MUST]:**
1. **DTO qatlami majburiy.** Handler'lar `internal/domain/*/dto` paketidagi struct'lar bilan ishlaydi;
   DB modeli (sqlc chiqishi) **hech qachon** to'g'ridan-to'g'ri javobga chiqmaydi
   (aks holda ichki maydonlar sizib chiqadi va sxema DB migratsiyasi bilan tasodifan o'zgaradi).
2. Har eksport qilinadigan DTO maydonida `json`, `example`, kerak bo'lsa `enums` tegi bo'ladi —
   Swagger'da misolsiz maydon qolmasin (frontend uchun asosiy qiymat shu).
3. Har handler'da: `@Summary`, `@Tags`, `@Security`, `@x-permission`, barcha real xato kodlari
   (`400/401/403/404/409/422/429`) `dto.ErrorResponse` bilan.
4. Xato kodlari (`VALIDATION_ERROR`, `DR_IMMUTABLE`, `LOG_NOT_READY` …) — bitta Go `const` blokida
   (`internal/apierr`), Swagger tavsifiga shu ro'yxat chiqadi.
5. `swag init` — CI'da; natija (`docs/`) commit qilinadi va `git diff --exit-code` bilan tekshiriladi
   (annotatsiya yangilanmasa PR o'tmaydi).
6. WebSocket kanallari Swagger'ga tushmaydi — ular `docs/websocket.md` da qo'lda yoziladi
   (kanal, xabar JSON namunasi, obuna formati — TZ D §3).

**Frontend bosqichi boshlanganda (backend tayyor):**
- `swagger.json` dan TypeScript tiplari va klient generatsiya qilinadi
  (`openapi-typescript` + `openapi-fetch`), Flutter uchun `openapi-generator dart-dio`.
  Ya'ni tiplar baribir qo'lda yozilmaydi — faqat manba boshqa (kod → spec, spec → kod emas).
- Swagger UI staging'da ochiq bo'ladi; frontend jamoasi endpointlarni brauzerda sinab ko'radi.
- Postman kolleksiyasi `swagger.json` dan import qilinadi.

**Muhim cheklov (ongli ravishda qabul qilingan trade-off):** code-first'da API shakli kod yozilgach
ma'lum bo'ladi — frontend backend'ni kutadi va spec avtomatik "breaking change" tekshiruvidan
o'tmaydi. Buni yumshatish uchun:
- **Har bosqich oxirida `swagger.json` nusxasi saqlanadi** (`docs/history/v0.N.json`) va keyingi
  bosqichda `oasdiff breaking docs/history/v0.N.json docs/swagger.json` CI'da ishlaydi — mobil ilova
  Store'da eski versiyada qolgani uchun (§12) bu majburiy.
- Backend bosqichi tugagach, frontend boshlangunga qadar **API review** o'tkaziladi (nomlash,
  null'lar, pagination, xato kodlari) — undan keyin `v1` muzlatiladi, o'zgarish faqat
  backward-compatible yoki `/api/v2`.
- Endpoint nomlari va javob shakllari — TZ QISM D §3 jadvaliga muvofiq; kod TZ'dan chetlashsa,
  avval TZ o'zgartiriladi (CR), keyin kod.

## 7. Fayl saqlash, retention, xarita

### 7.1 Object storage — DigitalOcean Spaces (S3-mos) yoki Cloudflare R2 (egress bepul). Presigned upload (client → storage), server faqat kalitni saqlaydi.
### 7.2 Retention
| Tur | Qaror |
|---|---|
| Duty status events, daily logs, violations, audit_log | **3 yil** issiq (FMCSA 6 oy min; AQSh bozori uchun ham yetarli) |
| DVIR + foto | 3 yil (foto 1 yildan keyin cold) |
| Maintenance/invoice | 3 yil |
| Masofa agregatlari (IFTA-ekvivalent) | **5 yil** |
| Telemetriya raw | 90 kun; agregat/trek (soddalashtirilgan polyline, kunlik) 3 yil |
| Chat | 1 yil |
| Backup | 30 kun |
### 7.3 Xarita/geocoding ❓ (taklif)
Tracking uchun eng katta o'zgaruvchan xarajat — reverse geocoding (har status event + har 60 daq intermediate) va tile'lar. Taklif: **MapLibre + OpenStreetMap tile'lari (self-hosted yoki MapTiler) + Nominatim/Photon self-hosted reverse-geocoding** — deyarli bepul; Google Maps — Pokiston/O'zbekiston qamrovi yaxshi, lekin 100k unit'da oyiga ming dollarlab. Geocoding natijalari 100 m gridda keshlanadi. Buyurtmachi tanlaydi; arxitektura provayder-agnostik (`GeoProvider` interfeysi).

## 8. ELD apparat qurilmasi
Yo'l B (tayyor qurilma + BYOD ilova) saqlanadi. **Tanlov mezonlari (checklist):** J1939/J1708 + OBD-II; BLE 5 + (ideal) o'z SIM/LTE; **ichki bufer ≥ 7 kun** (unidentified driving uchun); RTC + GPS vaqt sinxron; tamper-evident (uzilish/bo'shatish hodisasi yoziladi); **ochiq SDK yoki hujjatlashtirilgan BLE protokol** (vendor lock-in'dan qochish); firmware OTA; -20…+60 °C. Nomzodlar ❓: Pacific Track PT30, Geotab GO9 (Geotab SDK bilan), Teltonika FMB/FMC (SIM'li, MQTT — Markaziy Osiyoda keng tarqalgan), iOSiX. Test uchun 2–3 dona.

## 9. Backup va DR
- PostgreSQL **WAL arxivlash + PITR** (RPO ≤ 15 daq) + kunlik full snapshot; alohida account/region; immutable (Object Lock) 30 kun.
- Object storage — versioning + cross-region replication (hujjatlar/imzolar).
- RTO 4 soat; **choraklik restore-test** (acceptance'da birinchi test).

## 10. Monitoring
Sentry (backend + Flutter + React), Grafana/Prometheus (yoki DO monitoring), UptimeRobot; alertlar → Telegram + Email. Kuzatiladi: API p95, WS ulanishlar, sync xatolari, queue lag, telemetriya kelishi (unit "jim" bo'lsa), backup natijasi, disk/CPU.

## 11. Test va sifat nazorati **[MUST]** (v1 "shart emas" — bekor qilindi)
- Unit testlar: HOS (golden vektorlar), sync/konflikt, permission/scope.
- Integratsiya: API kontrakt (OpenAPI'dan generatsiya), RLS cross-tenant test.
- E2E: Flutter integration test (login → connect → DR → certify), Playwright (admin asosiy oqimlar).
- Qurilma testi: real ELD bilan har bosqichda (§D4).
- Acceptance: §D6.

## 12. API versiyalash
Backward-compatible; `/api/v1`; deprecated header; **`GET /app/config`** — `min_supported_version`, `latest_version`, `force_update` (majburiy yangilash uchun); ilova ishga tushganda tekshiradi.

## 13. Xarajatlar (to'g'rilangan)

| # | Narsa | Oy | Izoh |
|---|---|---|---|
| 1 | Backend (2 node) + LB | $100–300 | |
| 2 | PostgreSQL (managed, Timescale) | $60–250 | |
| 3 | Redis | $15–50 | |
| 4 | Object storage | $5–20 | |
| 5 | Monitoring/Sentry | $0–30 | |
| 6 | SMS (invitation, 2FA zaxira, kritik alert) | $20–100 | Pokiston provayderi |
| 7 | Email (SES/Resend) | $0–20 | |
| 8 | Push | $0 | |
| 9 | Xarita/geocoding | **$0–50 (OSM self-host) / $200–2000 (Google)** | ❓ |
| 10 | Domen + SSL | $2 | |
| **Jami MVP** | | **~$200–800/oy** | |

Bir martalik: Apple Developer **$99/yil**, Google Play **$25** (bir marta), test qurilmalar $300–600, kod imzolash/ EV sertifikat (ixtiyoriy).
To'liq yuklama (100k unit): $3–8k/oy (telemetriya + xarita asosiy).

## 14. CI/CD
GitHub Actions: `golangci-lint` → `swag init` + `git diff --exit-code docs/` (annotatsiyalar yangilanganmi) → `oasdiff breaking` (oldingi bosqich swagger.json bilan) → test (golden HOS vektorlari majburiy, testcontainers) → build (Docker, multi-stage, distroless) → staging deploy (avtomatik) → production (qo'lda tasdiq, tag). Mobil: Fastlane/Codemagic → TestFlight/Internal testing. Migratsiyalar — forward-only, review majburiy. Muhitlar: `dev`, `staging`, `prod` (alohida DB/storage).

## 15. Onboarding va billing (o'zgardi)
- **MVP:** Super Admin panelida kompaniya yaratadi (Name, region, plan, trial/subscription_end_at, Administrator invitation). To'lov — **invoice** (bank/JazzCash/Easypaisa qo'lda), Super Admin `subscription_end_at`ni uzaytiradi. Kompaniyaga 14/3/1 kun oldin email; muddat + 7 kun grace → faqat o'qish rejimi (haydovchi ilovasi HOS yozishni **davom ettiradi** — compliance to'xtamaydi, admin panel read-only).
- **2-bosqich:** self-service signup, tarif (per-unit yoki flat), onlayn to'lov (Pokiston: JazzCash/Easypaisa/Safepay; xalqaro: Stripe — Pokiston merchant'i uchun mavjud emas, shuning uchun mahalliy yur. shaxs yoki Paddle/Lemon Squeezy kabi MoR ❓). 🎨 Signup/Subscription ekranlari dizayni kerak.

## 16. Akkaunt yaratish va parol
v1 §16 saqlanadi (invitation, foydalanuvchi parolni o'zi o'rnatadi, Resend, Forgot password). Qo'shimcha: invitation link 72 soat; Driver uchun **6 xonali PIN** (Switch/Return to truck uchun, ilova ichida o'rnatiladi); admin `Reset password` = invitation qayta yuborish. ❓ Asosiy kanal: **SMS** (haydovchilar uchun), Email (ofis).

## 17. 2FA — §3.4.

## 18. Interfeys tili
MVP — **faqat Ingliz** (dizaynga mos). Lekin **barcha UI matnlari birinchi kundan i18n fayllarida** (`en.json`; Flutter `intl`, React `i18next`) — **[MUST]**, keyin Urdu (RTL) / O'zbek / Rus qo'shish arzon bo'lsin. Sana/raqam formati `Intl` orqali.

## 19. Data residency
Bitta region (Singapur/Frankfurt — DO/Hetzner). Pokiston data-localization talabi ❓ (yuridik tekshiruv); arxitektura region-agnostik (`REGION` env), kerak bo'lsa alohida instansiya.

## 20. Session policy (o'zgardi)
Bitta user uchun bir vaqtda: **1 web + 1 telefon + 1 planshet** (`device_type` bo'yicha bittadan). Xuddi shu turdagi yangi qurilma → eskisi bekor + "logged in on another device". Kabina planshetida ikki haydovchi (§A9) — ikki alohida user sessiyasi bitta qurilmada (`device_id` bir xil, `user_id` har xil) — ruxsat etiladi.

## 21. Nofunksional talablar (NFR) **[MUST]** (yangi)

| Ko'rsatkich | Talab |
|---|---|
| API p95 | ≤ 300 ms (ro'yxatlar), ≤ 800 ms (hisobot generatsiya so'rovi) |
| WS joylashuv kechikishi (qurilma → admin xarita) | ≤ 5 s onlayn holatda |
| Sync: 14 kunlik offline bufer yuklash | ≤ 60 s (4G) |
| Mobil ilova ishga tushish | ≤ 3 s; haydash rejimiga o'tish ≤ 1 s harakat aniqlangandan |
| Batareya (telefon, BLE + GPS, 8 soat haydash) | ≤ 25 % (ekran o'chiq) |
| Availability | 99.5 % (MVP), 99.9 % (2-bosqich) |
| Ma'lumot yo'qotish | 0 event (offline bufer + idempotent sync) |
| Xavfsizlik | OWASP ASVS L2; yillik pentest |
| Brauzerlar | so'nggi 2 versiya Chrome/Edge/Safari/Firefox |
| Mobil OS | Android 10+ (API 29), iOS 15+ |

## 22. Mobil platforma cheklovlari (yangi, risk)
- **Android:** foreground service (`FOREGROUND_SERVICE_LOCATION`, `CONNECTED_DEVICE`), Doze/battery optimization istisnosi so'raladi; Google Play **background location** uchun video + asos (ELD — qabul qilinadigan holat, lekin review 1–3 hafta).
- **iOS:** `bluetooth-central` + `location` background modes; ilova o'ldirilsa BLE qayta ulanish `state restoration` bilan; App Review'da "Why always location" matni.
- **Planshet kiosk:** Android "lock task mode" (MAY) — inspektor rejimi uchun PIN bilan chiqish.
- Vendor SDK Flutter'da bo'lmasa — platform channel (Kotlin/Swift) yoziladi; buni baholashga 1–2 hafta ajratiladi.

## 23. Ochiq savollar
| Mavzu | Holat |
|---|---|
| ELD qurilma modeli | ⏸ §8 mezonlar; nomzodlar test qilinadi |
| Xarita provayderi | ❓ §7.3 taklif |
| Bosh ekran A/B | ❓ B taklif |
| Privacy/Terms matni | ❓ buyurtmachi |
| Pokiston data-localization, e-imzo huquqiy kuchi | ❓ yuridik |
| Invitation asosiy kanali | ❓ SMS taklif |
| Signup/Subscription/Branches/Pending edits/Unassigned driving ekranlari | 🎨 dizayn buyurtmasi kerak |

---

# QISM C — LUG'AT

v1 lug'ati (ELD, HOS, FMCSA, CMV, RODS, DVIR, ECM, RTC, IFTA, IRP, Duty Status, Cycle, Shift, Break, Recap, Not Ready, Certify, Warning/Violation, Form and Manner, Malfunction, Tamper-evident; rollar; Offline-first, BLE, MQTT, WebSocket, REST, Audit log, Soft-delete, Sliding token, RPO, RTO, WORM, CI/CD, Backward-compatible, RTL, Data residency, Session policy, Tenant) **saqlanadi**. Yangi atamalar:

| Atama | Tushuntirish |
|---|---|
| **PC** (Personal Conveyance) | Haydovchining shaxsiy maqsadda (ish emas) mashina haydashi — OFF hisoblanadi, HOS'ga kirmaydi |
| **YM** (Yard Move) | Hovli/terminal ichida past tezlikda harakat — ON hisoblanadi, Drive limitga kirmaydi |
| **Unidentified / Unassigned driving** | Login qilmagan holda yozilgan harakat; keyin haydovchiga tayinlanadi |
| **Log edit request** | Admin taklif qilgan log o'zgarishi; faqat haydovchi tasdig'i bilan qo'llanadi |
| **Intermediate event** | Haydashda har 60 daqiqada yoziladigan joylashuv nuqtasi |
| **Sleeper split** | Daily rest'ni SB (≥7/8h) + OFF/SB (≥2/3h) ikki qismga bo'lish qoidasi |
| **34-hour restart** | Uzluksiz 34 soat OFF/SB → Cycle nolga qaytadi |
| **Regulation profile** | Company darajasida `fmcsa_us` / `generic` — labellar, hisobotlar, formatlar to'plami |
| **Golden test vectors** | HOS uchun kutilgan natijali ssenariylar to'plami; mobil va server bir xil o'tishi shart |
| **Geofence** | Nuqta atrofidagi radius; marshrut yakunlanishini aniqlash uchun |
| **Continuous aggregate** | TimescaleDB'da telemetriyani 1/5 daqiqalik yig'ma jadvalga avtomatik yig'ish |
| **RLS** (Row Level Security) | PostgreSQL qatordagi `company_id` bo'yicha kirishni bazaning o'zi cheklashi |
| **PITR** | Point-in-time recovery — WAL orqali istalgan daqiqaga tiklash |
| **Idempotency key / client_event_id** | Qayta yuborilgan so'rov ikkinchi marta yozilmasligi uchun mijoz yaratgan UUID |
| **MoR** (Merchant of Record) | Uchinchi tomon to'lovni o'z nomidan qabul qiluvchi (Paddle va h.k.) |
| **DoD** (Definition of Done) | Vazifa "tayyor" deb hisoblanishi uchun shartlar ro'yxati |
| **Swagger / OpenAPI** | REST API'ning mashina o'qiydigan tavsifi (`swagger.json`); Swagger UI — uni brauzerda ko'rish/sinash vositasi |
| **Code-first** | Avval kod yoziladi, API hujjati undan generatsiya qilinadi (loyihada tanlangan yondashuv) |
| **swaggo/swag** | Go izohlaridan Swagger hujjatini chiqaruvchi vosita |
| **DTO** | Handler kirish/chiqish struct'lari — DB modelidan alohida, tashqi kontrakt shu |
| **oasdiff** | Ikki Swagger fayl orasidagi breaking o'zgarishni topuvchi vosita |
| **sqlc / goose / asynq** | Go vositalari: SQL'dan type-safe kod, migratsiya, Redis navbat |

---

# QISM D — DB SXEMASI · SYNC PROTOKOLI · API · TIMELINE · RISK · ACCEPTANCE

## 1. Ma'lumotlar bazasi sxemasi (v2)

Umumiy: `id UUID`, `company_id` (tenant jadvallarida), `created_at`, `updated_at`, `deleted_at NULL`. Unique — partial (`WHERE deleted_at IS NULL`). `audit_log` — har o'zgarish.

```
companies
  id, name, address, home_terminal_address, timezone, email, phone,
  registration_no, logo_key, region, unit_system, regulation_profile,
  subscription_status (trial/active/grace/readonly), subscription_end_at, plan,
  settings JSONB (quick_notes[], fuel_types[], distance_regions_set)

hos_policy_versions
  id, company_id, effective_from, policy JSONB (A §4.2 kalitlari), created_by

branches            id, company_id, name, address, timezone
system_settings     key, value  (certification_window_days=8 ...)

users
  id, company_id (NULL = super admin), branch_id NULL, first_name, last_name,
  email NULL, phone NULL, username, password_hash, role_id,
  status (invited/active/inactive), totp_secret_enc NULL, pin_hash NULL,
  invited_at, activated_at, last_login_at, failed_logins, locked_until
  UNIQUE(company_id, username)

roles               id, company_id NULL, name, scope (company/branch/self), is_system
role_permissions    role_id, permission_key   PK(role_id, permission_key)
sessions
  id, user_id, device_id, device_type (web/phone/tablet), refresh_token_hash,
  status (active/paused/revoked), expires_at, last_seen_at, app_version, ip

drivers
  id, company_id, user_id, branch_id NULL, license_no_enc, license_region,
  home_terminal, city, state, zip, address1, address2, notes,
  fleet_manager_id (users), default_unit_id NULL, status, app_version, activated_on
driver_pairs        driver_a_id, driver_b_id, created_at  (co-driver, simmetrik)
signatures          id, user_id, image_key_enc, created_at, is_default

units
  id, company_id, branch_id NULL, unit_number, make, model, year, vin,
  license_plate, plate_region, fuel_type, sleeper_berth bool,
  gvwr_class NULL, status, out_of_service bool, notes, activated_on
  UNIQUE(company_id, unit_number), UNIQUE(company_id, vin)
eld_devices
  id, company_id, unit_id NULL, vendor, model, serial, firmware,
  connection_type, sim_present bool, last_seen_at, malfunction_codes[] , status
eld_device_assignments  id, eld_device_id, unit_id, from_at, to_at
unit_driver_assignments id, unit_id, driver_id, role (primary/co), assigned_at, unassigned_at
trailers            id, company_id, number, notes
shipping_documents  id, company_id, number, notes

duty_status_events
  id, company_id, driver_id NULL (NULL = unidentified), unit_id, eld_device_id NULL,
  event_type, status NULL (OFF/SB/DR/ON), special (none/pc/ym),
  event_time timestamptz, time_source (eld_rtc/server/phone), time_unverified bool,
  clock_skew_sec, origin (auto/driver/driver_edit/admin_edit/assigned),
  lat, lng, location_text, gps_accuracy_m, odometer_m, engine_hours,
  notes, trailer_ids UUID[], shipping_doc_ids UUID[],
  client_event_id UUID UNIQUE, device_seq bigint, received_at,
  superseded_by UUID NULL, locked bool, daily_log_id NULL
  INDEX (driver_id, event_time), (unit_id, event_time)

daily_logs
  id, company_id, driver_id, log_date date, timezone, unit_ids UUID[],
  co_driver_id NULL, distance_m, trailer_ids[], shipping_doc_ids[],
  totals JSONB (off/sb/dr/on sec), certification_status
  (uncertified/certified/needs_recertify), signed_at, signature_key, signed_device_id
  UNIQUE(driver_id, log_date)

log_edit_requests
  id, company_id, driver_id, daily_log_id, requested_by, status (pending/approved/rejected),
  changes JSONB ([{from,to,status,special,note}]), driver_note, resolved_at

unidentified_events
  id, company_id, unit_id, eld_device_id, start_at, end_at, distance_m, track_key,
  status (pending/assigned/annotated), assigned_driver_id NULL, annotation, resolved_by

violations
  id, company_id, driver_id, unit_id NULL, daily_log_id, type, severity,
  occurred_at, details JSONB, policy_version_id, resolved_at, resolved_reason

telemetry  (Timescale hypertable, partition by ts)
  ts, unit_id, eld_device_id, driver_id NULL, lat, lng, speed_kmh, heading,
  odometer_m, engine_hours, fuel_pct, coolant_temp_c, coolant_level_pct,
  oil_level_pct, battery_pct, ignition bool, source
telemetry_1min / telemetry_5min  (continuous aggregates)
unit_last_state     unit_id PK, ts, lat, lng, speed_kmh, duty_status, driver_id, online_status
trips               id, company_id, unit_id, driver_id NULL, start_at, end_at,
                    start_lat/lng, end_lat/lng, distance_m, polyline_key
unit_region_distance_daily  unit_id, region_code, date, distance_m  PK(unit_id,region_code,date)
regions             code, name, country, geom (PostGIS polygon)

dvir_reports
  id, company_id, unit_id, driver_id, type (pre_trip/post_trip),
  trailer_ids[], status, defects JSONB ([{defect_type_id, note, photo_keys[]}]),
  lat, lng, location_text, odometer_m, engine_hours,
  driver_signature_key, mechanic_id NULL, mechanic_note, mechanic_signature_key,
  repaired_at, certified_by_driver_id NULL, certified_at, source (app/paper_import)
defect_types        id, company_id NULL (NULL = default), name, category (truck/trailer), is_critical, is_active

maintenance_schedules
  id, company_id, name, type, interval_value, interval_unit (km/mi/days/engine_hours),
  reminder_before_value, alert_type, delivery_methods[], notify_co_driver, notes, status
maintenance_schedule_units
  id, schedule_id, unit_id, last_service_value, next_due_value, reminder_sent_at, status (scheduled/due/completed/cancelled)
maintenance_records
  id, company_id, schedule_unit_id NULL, unit_id, status (completed/cancelled),
  performed_at, invoice_no, vendor, cost, currency, odometer_m, engine_hours,
  invoice_key, dvir_pre_id NULL, dvir_post_id NULL, cancelled_reason

routes
  id, company_id, unit_id, driver_id, sequence, origin_text, origin_lat/lng,
  dest_text, dest_lat/lng, geofence_m, status, created_by, started_at, completed_at,
  not_completed_reason, note, polyline_key

notifications
  id, company_id, user_id, alert_type, title, body, entity_type, entity_id,
  channels[], sent_at, delivered_at, read_at
notification_settings  company_id, alert_type, channels[], recipient_roles[]

support_tickets     id, company_id, driver_id, subject, description, contact_on, status, attachments[]
ticket_messages     id, ticket_id, sender_id, text, created_at
feedback            id, company_id, driver_id, app_rating, text, submitted_at
chat_messages       id, company_id, driver_id, sender_id, kind (text/image/file/location),
                    text, file_key, lat/lng, sent_at, delivered_at, read_at
report_export_jobs  id, company_id, requested_by, type, params JSONB, status, file_key, expires_at
invitations         id, user_id, token_hash, channel, expires_at, used_at

audit_log (append-only)
  id, company_id NULL, table_name, record_id, field, old_value JSONB, new_value JSONB,
  action (insert/update/soft_delete/login/export/...), edited_by NULL, ip, ts
```

## 2. Offline sync protokoli **[MUST]** (yangi)

**Yuklash (mobil → server):** `POST /api/v1/sync/push`
```json
{ "device_id": "…", "app_version": "1.2.0", "clock": {"phone": "…Z", "eld_rtc": "…Z"},
  "events":  [ { "client_event_id": "uuid", "event_type": "status_change", "status": "ON",
                 "event_time": "2026-09-06T05:12:00Z", "time_source": "eld_rtc", "device_seq": 1042,
                 "lat": 31.52, "lng": 74.35, "odometer_m": 128430000, "notes": "Pickup", ... } ],
  "telemetry": [ { "ts": "…", "lat": …, "lng": …, "speed_kmh": 62, "odometer_m": … } ],
  "dvir": [ … ], "chat": [ … ] }
```
Javob: har element uchun `accepted | duplicate | rejected(reason)`; `server_time`. Batch ≤ 500 event / 5000 telemetriya nuqta. Retry — eksponensial (1 s → 5 daq), tartib saqlanadi (`device_seq`).
**Idempotency:** `client_event_id UNIQUE` → dublikat `duplicate`, xato emas.
**Tortish (server → mobil):** `GET /api/v1/sync/pull?since=<server_ts>` — pending edit requests, unidentified events (unit bo'yicha), assignment o'zgarishlari, hos_policy, defect catalog, quick notes, chat.
**Konflikt qoidalari:**
1. Bir haydovchi uchun bitta vaqtda ikki status event (turli qurilmalardan) → `device_seq` + `time_source` ustuvorligi (eld_rtc > server > phone); yutqazgan event `superseded_by` bilan saqlanadi, haydovchiga ogohlantirish.
2. Server tomonidagi o'zgarish (edit request approved) mobilga kelganda lokal log qayta quriladi — server kanonik.
3. Event vaqti kelajakda (> server + 5 daq) → `rejected(time_in_future)`, qurilma soati tekshiriladi.
4. Telemetriya dublikat (`unit_id, ts`) — ignore.

## 3. API spetsifikatsiyasi

Konventsiyalar (URL, metodlar, status kodlar, xato formati, pagination, filtr, UUID, ISO 8601 UTC, null) — v1 §2.0 saqlanadi. Qo'shimcha: `Idempotency-Key` header POST'larda (ixtiyoriy, sync'da majburiy); `X-Company-Id` — faqat Super Admin uchun (tenant tanlash).

### 3.1 Endpoint ro'yxati (v2, ~70)

| Guruh | Endpointlar |
|---|---|
| Auth | `POST /auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/2fa/verify`, `/auth/2fa/setup`, `/auth/invitation/accept`, `/auth/password/forgot`, `/auth/password/reset`, `POST /auth/pin/verify` (Switch/Return), `GET /auth/sessions`, `DELETE /auth/sessions/:id` |
| App | `GET /app/config` (min version, feature flags), `GET /me` |
| Companies (Super Admin) | `GET/POST/PATCH /companies`, `PATCH /companies/:id/subscription` |
| Company (Admin) | `GET/PATCH /company`, `GET/POST/PATCH /company/branches`, `GET /company/hos-policy`, `POST /company/hos-policy` (yangi versiya), `GET/PATCH /company/notification-settings`, `GET /company/history` |
| Users/Roles | `GET/POST/PATCH/DELETE /users`, `POST /users/:id/resend-invitation`, `POST /users/:id/reset-password`, `GET/POST/PATCH/DELETE /roles`, `GET /permissions` |
| Units | CRUD `/units`, `POST /units/:id/activate|deactivate`, `POST /units/:id/assign-driver`, `GET /units/:id/diagnostics`, `GET /units/:id/history?from&to`, `POST /units/import`, `GET /units/export` |
| Drivers | CRUD `/drivers`, `activate|deactivate`, `GET /drivers/:id/activities`, `POST /drivers/import`, `GET /drivers/export`, `GET/POST/DELETE /drivers/:id/co-drivers` |
| ELD devices | CRUD `/eld-devices`, `POST /eld-devices/:id/assign-unit` |
| Trailers/Docs | CRUD `/trailers`, `/shipping-documents` |
| Sync (mobil) | `POST /sync/push`, `GET /sync/pull` |
| Logs | `GET /drivers/:id/daily-logs?from&to`, `GET /daily-logs/:id` (events + form), `GET /daily-logs/:id/pdf`, `POST /daily-logs/:id/certify` (signature_key yoki saved), `GET /drivers/:id/hos-summary`, `GET /drivers/:id/duty-status-events` |
| Log edits | `POST /log-edit-requests`, `GET /log-edit-requests?status=pending`, `POST /log-edit-requests/:id/approve|reject` (Driver), `POST /daily-logs/:id/events` (driver self-edit) |
| Unidentified | `GET /unidentified-events`, `POST /unidentified-events/:id/assign` (admin → edit request), `POST /unidentified-events/:id/claim` (driver), `POST /unidentified-events/:id/annotate` |
| Inspection | `POST /inspection/email` (driver), `POST /inspection/transfer` (file/web-service), `GET /inspection/logs` (8 kun, read-only token — inspector mode) |
| Violations | `GET /violations`, `GET /violations/:id` |
| Tracking | `GET /tracking/live` (unit_last_state), `GET /units/:id/trips?date`, `GET /trips/:id` (polyline), WS `tracking` |
| Routes | CRUD `/routes`, `POST /routes/:id/not-completed`, `GET /routes/:id/directions` |
| DVIR | `GET /dvir-reports`, `GET /dvir-reports/:id`, `POST /dvir-reports/:id/repair`, `GET /dvir-reports/:id/pdf`, `GET /dvir-reports/pending-certification?unit_id` (driver), `POST /dvir-reports/:id/certify`, `GET/POST/PATCH /defect-types` |
| Maintenance | CRUD `/maintenance-schedules`, `GET /maintenance/due`, `POST /maintenance-schedule-units/:id/complete|cancel`, `GET /maintenance-records` |
| Reports | `POST /reports/export-jobs` (type: distance_by_region/regulator/activity/hos/dvir), `GET /reports/export-jobs/:id`, `GET /reports/activity`, `GET /reports/distance-by-region?quarter&year&mode`, `GET /reports/uncertified-logs` |
| Dashboard | `GET /dashboard/summary` |
| Notifications | `GET /notifications`, `PATCH /notifications/:id/read`, `POST /notifications/read-all`, `POST /devices/push-token` |
| Files | `POST /files/presign` (kind: dvir_photo/invoice/signature/logo/chat/import) → `{upload_url, key}` |
| Support | `GET/POST /support-tickets`, `PATCH /support-tickets/:id/status`, `POST /support-tickets/:id/messages`, `POST /feedback`, `GET /feedback` |
| Chat | `GET /chat/threads`, `GET /chat/threads/:driver_id/messages?before`, `POST /chat/threads/:driver_id/messages`, `POST /chat/messages/:id/read`, WS `chat` |
| Audit | `GET /audit-log?table&record_id&from&to&user` |

### 3.2 Misollar — v1 §2.1 (Units POST, login, DVIR, WS) saqlanadi, o'zgarishlar bilan: `POST /units` javobida `odometer_m`, `plate_region`; login javobida `sessions` cheklovi xabari (`replaced_session: true`); DVIR so'rovida `type`, `defects[{defect_type_id, note, photo_keys}]`; WS ulanish — `Authorization: Bearer` header, `subscribe` xabari `since` bilan.

**Swagger:** bu jadval — backend uchun **reja va kelishilgan kontrakt** (endpoint nomlari, metodlar, ruxsatlar). Kod yozilgach haqiqiy hujjat — swaggo generatsiya qilgan `/api/docs` (QISM B §6.4). Kod bu jadvaldan chetlashsa, avval TZ o'zgartiriladi (CR), keyin kod. Frontend bosqichida shu Swagger'dan TS/Dart klientlar generatsiya qilinadi.

## 4. Timeline (bog'liqliklar to'g'rilangan)

| Bosqich | Qamrov | Bog'liqlik | Chiqish mezoni (acceptance) |
|---|---|---|---|
| 0. Fundament | CI/CD, muhitlar, **swaggo sozlash + `/api/docs` ishlaydi**, DTO/xato konventsiyalari, DB sxema + RLS, auth (login/invitation/2FA/PIN/sessions), roles/permissions, audit_log, i18n skeleti | — | Cross-tenant test o'tdi; invitation oqimi e2e; Swagger UI'da auth endpointlari misollar bilan ko'rinadi |
| 1. Asosiy obyektlar | Super Admin kompaniya yaratish, Company settings (region/units/TZ), Branches, Units, Drivers, ELD devices, Trailers/Docs, import/export | 0 | CSV import 1000 satr < 30 s |
| 2. Qurilma va telemetriya | ELD vendor SDK/BLE ulanish, telemetriya ingestion, `unit_last_state`, trips, unidentified buffer | 1 | Real qurilma bilan 8 soatlik test, 0 yo'qotish |
| 3. HOS/Duty status | Events, offline sync, HOS engine (mobil+server, golden vektorlar), PC/YM, auto-DR, idle prompt | 2 | 30 golden vektor ikkala tomonda o'tdi; 24 soat offline test |
| 4. Log, sertifikatsiya, tahrirlash | Daily logs, Log Form, certify, edit requests, unidentified assign, violations/warnings, uncertified alerts | 3 | Edit request e2e; violation'lar vektorlarga mos |
| 5. Real-vaqt va bildirishnoma | WS tracking, dashboard, notification service (Push/Email/SMS), chat | 2 | ≤ 5 s kechikish |
| 6. DVIR va Maintenance | DVIR oqimi + holat mashinasi + PDF, defect catalog, schedules (odometer/engine hours telemetriyadan), records | 2, 5 | Overdue hisobi telemetriya bilan tekshirildi |
| 7. Marshrut va hisobotlar | Routes + geofence, Distance by Region (PostGIS), Activity, HOS, Regulator export, Inspection (email/file), export jobs | 2, 4 | Masofa hisoboti ± 2 % GPS trek bilan |
| 8. Support, sayqal, xavfsizlik | Tickets, feedback, monitoring, backup/restore test, pentest, Play/App Store review | hammasi | Restore test < 4 soat; Store'lar tasdiqladi |
| 9. Pilot va ishga tushirish | 1 kompaniya, 5–10 unit, 2 hafta pilot; xatolar; production | 8 | Pilot haydovchilari 2 hafta logni to'liq yuritdi |

**Tavsiya:** 2-bosqich (qurilma) — eng noaniq; 1-bosqich bilan parallel boshlanadi (spike).

## 5. Risk tahlili (kengaytirildi)

| # | Xavf | Ta'sir | Chora |
|---|---|---|---|
| 1 | Ransomware / ma'lumot yo'qolishi | Tizim to'xtashi | PITR + immutable backup, alohida account, 2FA, RLS |
| 2 | HOS hisobida xato / mobil ≠ server | Noto'g'ri violation, ishonch yo'qolishi | Golden vektorlar CI'da, server kanonik |
| 3 | **ELD vendor SDK/protokol yopiq yoki Flutter'da yo'q** | 2-bosqich cho'ziladi | Tanlov mezoni "ochiq protokol"; platform channel'ga vaqt; 2 nomzod parallel |
| 4 | **Play/App Store background location/BLE rad etishi** | Relizga to'sqinlik | Erta submit (TestFlight/Internal), asos video, ELD holati ko'rsatiladi |
| 5 | Offline-sync konflikt/dublikat | Nomos log | client_event_id, device_seq, konflikt qoidalari, test |
| 6 | Telemetriya hajmi/xarajat | Sekinlashuv, narx | Timescale agregatlar, 90 kun raw, Redis last-state |
| 7 | Xarita/geocoding xarajati | Byudjet | OSM self-host tanlovi, kesh |
| 8 | To'lov provayderi (Stripe yo'q) | Billing kechikadi | MVP invoice, MoR variant |
| 9 | Log tahrirlash huquqiy/audit da'vosi | Ma'lumot ishonchsizligi | Taklif/tasdiq modeli, DR o'zgarmas, append-only audit |
| 10 | Unidentified driving e'tibordan chetda qolishi | Compliance bo'shlig'i | 8 kun alerti, dashboard KPI |
| 11 | Bitta region | Mintaqaviy uzilish | Qabul qilingan; region-agnostik deploy |
| 12 | Kichik jamoa / bus factor | To'xtab qolish | TZ, Swagger (`/api/docs`), ADR (qarorlar yozuvi), code review |
| 17 | Go ekotizimida PDF/SMS/to'lov kutubxonalari kamroq | Qo'shimcha ish | chromedp (HTML→PDF), oddiy HTTP API'lar; ehtiyoj bo'lsa alohida kichik servis |
| 18 | Code-first: API shakli frontend boshlangunga qadar o'zgarishi | Frontend qayta ish | Backend bosqichi oxirida API review + `v1` muzlatish; `oasdiff` bosqichlararo; TZ D §3 jadvali kontrakt sifatida |
| 19 | Ketma-ket ish tartibi (frontend kutadi) | Umumiy muddat uzayadi | Backend bosqichlari qismlarga bo'linadi (auth+units tayyor bo'lgach frontend shu qismdan boshlashi mumkin); Swagger UI staging'da ochiq |
| 13 | Ko'p tillilik keyin talab qilinishi | Qayta ish | i18n fayllar birinchi kundan |
| 14 | Pokiston yuridik (data-localization, e-imzo) | Qayta konfiguratsiya | Yuridik tekshiruv 1-bosqichda; region-agnostik |
| 15 | GPS spoofing / soat o'zgartirish | Firibgarlik | ECM tezlik asosiy, RTC, clock_skew belgisi, unverified bayrog'i |
| 16 | Haydovchilar ilovani o'chirib qo'yishi (batareya) | Ma'lumot yo'qolishi | Qurilma buferi ≥ 7 kun → unidentified, foreground service, batareya NFR |

## 6. Acceptance criteria va Definition of Done **[MUST]** (yangi)

**DoD (har vazifa):** kod review; unit testlar (HOS/permission/sync uchun majburiy); **swag annotatsiyasi to'liq (`@Summary`, `@x-permission`, barcha xato kodlari) va `docs/` yangilangan (CI diff)**; DTO maydonlarida `example` teglari bor; migratsiya; audit_log yozuvi; i18n kalitlari; Sentry'da yangi xato yo'q; staging'da QA tasdig'i.

**Bosqich qabuli (buyurtmachi bilan):** har bosqich §4 "chiqish mezoni" + quyidagi umumiy:
1. **HOS:** 30 golden ssenariy (jumladan split sleeper, 34h restart, PC/YM, TZ, offline 24 soat, admin edit) — mobil va server natijalari bir xil.
2. **Offline:** 24 soat internetsiz haydash → sync → 0 yo'qolgan event, tartib to'g'ri.
3. **Tamper:** telefon soati 3 soat surildi → eventlar `time_unverified`/RTC bilan to'g'ri; admin log o'zgartira olmaydi (faqat request).
4. **Unidentified:** login'siz 20 km haydash → admin ro'yxatida, tayinlash oqimi ishlaydi.
5. **Xavfsizlik:** cross-tenant so'rov 404/403; 2FA; brute-force lockout; PII loglarda yo'q.
6. **DR:** backup'dan tiklash ≤ 4 soat, PITR 15 daq.
7. **NFR:** §B21 jadvali yuk testida (k6) o'tdi.
8. **Store:** ilovalar TestFlight/Internal testing'da; production review boshlangan.
9. **Hujjat:** Swagger UI ishlaydi va 100 % endpoint misollar bilan qoplangan, `docs/websocket.md`, deploy runbook, admin qo'llanma (qisqa), haydovchi qo'llanma (qisqa).

**O'zgarish so'rovlari (CR):** TZ'dan tashqari har talab — yozma CR, ta'sir (vaqt/narx) bahosi, ikki tomon tasdig'i.

## 7. Traceability (qisqa)

| Qoida | Jadval | Endpoint / ekran |
|---|---|---|
| Q5, Q5.3 | duty_status_events, unidentified_events | sync/push; Drive mode; Unassigned driving |
| Q10.x | hos_policy_versions, violations | /drivers/:id/hos-summary; Company › HOS policy 🎨 |
| Q17.x | log_edit_requests | /log-edit-requests; Insert duty status; Pending edits 🎨 |
| Q19–26 | daily_logs, signatures | /daily-logs/:id/certify; Certify ekranlari |
| Q27–31 | dvir_reports, defect_types | /dvir-reports; Add DVIR; DVIR Report |
| Q32–43 | maintenance_* | /maintenance-*; Maintenance tablari |
| Q45.x | sessions, driver_pairs | /auth/pin/verify; Switch; Leave Truck |
| Q63–68 | telemetry, trips, routes, unit_last_state | /tracking/live, WS tracking; Track on Map; Trip Planner |
| Q69–76 | unit_region_distance_daily, report_export_jobs | /reports/*; Reports |
| Q81–82 | roles, role_permissions | /roles; Roles & Permissions |
| Q83–85 | audit_log | /audit-log; Activities/Histories |

---
*Hujjat oxiri. Keyingi versiya: dizayn buyurtmasi (🎨 belgilangan ekranlar) va ❓ savollar yopilgach — v2.1.*
