## 7.4 Logs

### 7.4.1 Logs By Unit — `/logs/by-unit`
- **Maqsad:** bitta kun kesimida barcha unit'larning joriy holati va HOS hisoblagichlari.
- **Ruxsat:** `logs.read` + `tracking.view_live`
- **Endpointlar (kompozitsiya):** `GET /tracking/live` (sahifalangan: unit, driver, duty_status, online_status, joylashuv) + har satr uchun `GET /drivers/{driver_id}/hos-summary?date=<sana>` (faqat **kengaytirilgan** ustunlar ochiq bo'lganda) + `GET /violations?from=&to=` (bir so'rov, satrlarga guruhlanadi)

**F95 [MUST] Ma'lum bo'shliq.** Backendda «bir kun × barcha unitlar × HOS hisoblagichlari» beruvchi **yagona endpoint yo'q**. MVP yechimi:
1. Asosiy ustunlar `GET /tracking/live` dan (bitta so'rov).
2. `Break/Drive/Shift/Cycle/Recap` ustunlari **default'da yashirin**. Foydalanuvchi ularni ustun tanlash panelidan yoqsa — joriy sahifadagi (≤ 50) haydovchilar uchun `hos-summary` **parallel, `concurrency ≤ 6`** bilan olinadi va keshlanadi (`staleTime` 60 s).
3. §17 da CR nomzodi: `GET /logs/by-unit?date=` (v1.1).

| Ustun | Manba | Izoh |
|---|---|---|
| # | tartib | |
| Device Status | `online_status` | `online` (success) · `offline` (neutral) · `disconnected` (error) · `malfunction` (error + ikonka) |
| Unit # | `unit_number` | |
| Driver Name | `driver.name` | bo'sh → `Unassigned` |
| Status | `duty_status` | `StatusChip` |
| Last Known Location | `lat`, `lng`, `last_seen_at` | ✅ format: **`<Reverse-geocode matni>` · `lat, lng`** + nisbiy vaqt. Dizayndagi `48.8566, 2.3522, 30` uchinchi soni — aniqlanmagan; ✅ **GPS aniqligi (metr)** deb talqin qilinadi va **ko'rsatilmaydi** (backend bermaydi). §16 |
| Warnings & Violations | `GET /violations` | raqamli badge (soni) + hover'da ro'yxat; `severity` bo'yicha rang |
| Break / Drive / Shift / Cycle | `hos-summary.counters` | `HH:MM` **qolgan vaqt** (`tz.md` §4.1) |
| Recap | `hos-summary.recap[]` | ertaga qo'shiladigan soat (`tz.md` Q10.7) |

- **Filtrlar:** sana (bitta kun, default bugun) · `search` (driver) · `online_status` · `branch_id` · `Violations` (boolean) · `Warnings` (boolean) — mustaqil (`tz.md` Q59)
- **F96** Dizayndagi `Export Drivers`/`Import Drivers` tugmalari bu ekranda **ma'nosiz** → olib tashlanadi; o'rniga `Export` → `export-jobs` (`type=hos`). §16
- **Satr bosilganda:** `/logs/:dailyLogId` (Log view). `daily_log_id` `GET /drivers/{id}/daily-logs?from=<sana>&to=<sana>` orqali topiladi.
- **Ogohlantirish matnlari:** `Trailer not set.`, `Shipping document is not set`, `Shift Limit` — `violations[].type` ning i18n matnlari.
- **Jadval ustidagi izoh:** «Violations can be removed after completion of second qualify break.» → ✅ to'g'ri matn: **«A `break_required` violation is resolved after a qualifying break; drive and shift violations after a daily rest.»** (`tz.md` Q58). §16

### 7.4.2 Logs By Driver — `/logs/by-driver`
- **Ruxsat:** `logs.read` · **Endpoint:** `GET /drivers/{id}/daily-logs?from=&to=&page=&per_page=`
- **Majburiy tanlov:** haydovchi (`Select driver` combobox). Tanlanmaguncha jadval o'rnida: «Select driver first, to display the data in the table.» (§6.5)
- **Filtr:** `Start date – End date` (default: oxirgi 8 kun — sertifikatsiya oynasi)

| Ustun | Manba |
|---|---|
| # | tartib |
| Date | `log_date` |
| Unit # | `unit_ids[]` → nomlar (bir nechta bo'lsa vergul bilan) |
| Distance | `distance_m` → §12 konvertatsiya |
| OFF / SB / DR / ON | `totals` | `HH:MM` |
| Certification | `certification_status` (`uncertified` warning · `certified` success · `needs_recertify` error) + `signed_at` |
| Ready | `ready` (`Not Ready` = imzo yo'q, `tz.md` Q25) |
| Warnings & Violations | `GET /violations?driver_id=&from=&to=` |
| Break/Drive/Shift/Cycle/Recap | kengaytirilgan ustunlar, `GET /drivers/{id}/hos-summary?date=` |

- **Satr bosilganda:** `/logs/:id`
- **F97** Dizayndagi sarlavha `Log By Driver` → ✅ kanonik **`Logs By Driver`** (`Logs By Unit` bilan parallel). §16

### 7.4.3 Log view — `/logs/:id`
- **Ruxsat:** `logs.read` · **Endpoint:** `GET /daily-logs/{id}` → `DailyLogDetail` (`events[]`, `form`, `totals`, `violations[]`, `certification_status`)
- **Breadcrumb:** `Logs By Unit › Unit # <n> › <sana>` (kirish yo'liga qarab)
- **Sarlavha bloki:** haydovchi (nomi, platforma/ilova versiyasi, online holati, telefon, co-driver havolasi), sana navigatori `‹ <sana> ›` (`GET /drivers/{id}/daily-logs` bilan qo'shni kunlar), o'ngda `Report` va `Current Location` tugmalari

**HOS bloki — 4 halqa** (`GET /drivers/{id}/hos-summary?date=`):
| Halqa | Manba | Rang |
|---|---|---|
| BREAK | `counters.break_remaining_min` | warning |
| DRIVE | `counters.drive_remaining_min` | success |
| SHIFT | `counters.shift_remaining_min` | blue |
| CYCLE | `counters.cycle_remaining_min` | primary |

Ostida: `Certified: Yes/No` · `W.H <ish soati>` · `Violations: <soni>` · `Policy version` (tooltip'da `policy_version_id`, `tz.md` Q10.1).
**F98 [MUST]** Dizayndagi `CYCLE 65:00` — **placeholder**. Haqiqiy chegara `hos_policy.cycle_limit_min` (default **4200 = 70:00**, `tz.md` §4.2). UI hech qanday raqamni hardcode qilmaydi — hammasi `hos-summary` javobidan. §16/§17-1.

**Tablar:** `Driver's Log` · `Report` · `Trip Planner`

**(a) Driver's Log — 24 soatlik grid:**
- Qatorlar `OFF · SB · DR · ON`, o'ng chekkada har status jami (`HH:MM`), pastda `Total: HH:MM`
- Chiziq rangi `#466FF7`; `PC` va `YM` — shtrix pattern bilan ajratiladi
- Grid ustida hodisa markerlari: **faqat `pti · fuel · certify · malfunction`** (`tz.md` Q15)
- Hover'da tooltip: vaqt (`HH:mm:ss`), status, joylashuv
- **F99** Grid **SVG** bilan chiziladi (canvas emas) — a11y uchun `<title>`/`aria-label`, va ekranni kattalashtirilganda sifat yo'qolmasligi uchun. 1440 px da 1 soat ≈ 52 px.
- Grid ostida ogohlantirish satrlari (§6.9)

**Voqealar jadvali** (`events[]`):
`# · Status · Start · Duration · Last Known Location · Odometer · Engine Hours · Document · Trailer · Notes · Origin · Action`
- `Status` ikki tur: **duty status** (`DR/OFF/SB/ON`, davomiylikka ega) va **hodisa** (`PTI/POWER ON/POWER OFF/FUEL/CERTIFY/MALFUNCTION/…`, nuqtaviy)
- `Origin` ustuni (dizaynda yo'q, ✅ qo'shiladi): `auto · driver · driver_edit · admin_edit · assigned · manual_no_eld`. `admin_edit`/`driver_edit` → `✎` belgisi + tooltip'da asl qiymat, kim, qachon (`tz.md` Q17.2). `manual_no_eld` → sariq belgi (`tz.md` Q7.1)
- `Action` → `Propose edit` (`logs.propose_edit`)

**LOG FORM bloki** (`form`): `Unit #(lar) · Driver · Co-Driver · Distance · Trailers[] · Shipping Docs[] · Signature`
- Trailers/Docs — yashil badge'lar; `Signature` — `Signed` (success) yoki `Not Signed` (error) + imzo tasviri (faqat ko'rish)

**(b) INSERT / EDIT DUTY STATUS paneli** — grid ustiga bosilganda ochiladi
- **Ruxsat:** `logs.propose_edit` · **Endpoint:** `POST /log-edit-requests`
- **Maydonlar:** status tugmalari `OFF · SLEEP · DRIVING · ON (YM) · OFF (PC) · ON` · `From *` · `To *` · `Note *`
- **F100 [MUST] Bu — to'g'ridan-to'g'ri tahrir EMAS.** `tz.md` §5.3 (FMCSA §395.30): admin **taklif** yuboradi, haydovchi tasdiqlaydi. UI aniq aytadi:
  - Tugma `Confirm` → ✅ **`Send edit request`**
  - Panel tepasida izoh: «This will be sent to the driver for approval. The log is not changed until the driver approves.»
  - Yuborilgandan keyin: toast + `/logs/edit-requests` ga havola
  - **Taqiqlar** (`tz.md` Q17.1) UI darajasida ham: avtomatik `DR` intervalini **qisqartirish yoki boshqa statusga o'zgartirish mumkin emas** — bunday tanlovda tugma `disabled` + sabab; `intermediate`, `power_*`, `malfunction` eventlari tahrirlanmaydi (`Action` menyusi yo'q)
  - `Note *` majburiy, ≤ 60 belgi
- 🎨 Dizaynda tugma `Confirm` va hech qanday tasdiq oqimi ko'rsatilmagan — bu **eng katta dizayn↔TZ farqi**, §16 da qayd etilgan.

**(c) Report tabi:** `GET /daily-logs/{id}/pdf` (`logs.export`) → PDF `<iframe>`/`<object>` da ko'rsatiladi + `Download` tugmasi. Yuklanish — skeleton; xato — `ErrorState` + qayta urinish.

**(d) Trip Planner tabi:**
- **Endpointlar:** `GET /units/{id}/trips?date=` (`tracking.view_history`) · `GET /trips/{id}?include_polyline=true` · `POST /routes` (`routes.create`)
- Xarita + raqamli to'xtash markerlari; nuqta kartochkasi: `Status · Date · Odometer · Location · Coordinates · Duration · Stopped`
- **F101** Koordinata formati: **`36.9876543, 23.9746455`** — nuqta o'nlik ajratgich, vergul juftlik ajratgichi, **7 xona** (≈1 sm aniqlik). Dizayndagi `23,97464553778` — xato. §16
- **`Plan a Trip` formasi:** `From *` (matn + «Copy last location») · `To *` (manzil qidiruvi) · `Geofence radius` (default **300 m**, `tz.md` Q66) · `Note` → `POST /routes` → haydovchiga push. Tugma `Run Trip` → ✅ **`Create route`** (§16)
- `GET /routes/{id}/directions` — chizilgan marshrut polyline'i

### 7.4.4 Log Edit Requests — `/logs/edit-requests` 🎨
- **Ruxsat:** `logs.read` · **Endpointlar:** `GET /log-edit-requests?status=&driver_id=` · `POST /log-edit-requests/{id}/approve` (`logs.approve_edit`) · `POST /log-edit-requests/{id}/reject` (`logs.reject_edit`)
- **Tablar/filtr:** `Pending` · `Approved` · `Rejected`; `driver_id`
- **Ustunlar:** `# · Driver · Log date · Proposed change (from → to, status) · Note · Proposed by · Created · Status · Action`
- **Amallar:** `View` (log view'ga havola) · `Approve` / `Reject` (sabab majburiy) — **faqat tegishli ruxsat bilan**
- **F102** Dizaynda ekran **yo'q** (🎨) — `tz.md` §23 da «Pending edits ekranlari — dizayn buyurtmasi kerak» deb qayd etilgan. Standart ro'yxat patterni bilan quriladi.
- **F103** Adminning o'z taklifini o'zi tasdiqlashi backendda bloklanadi; UI'da ham `Approve` tugmasi taklif qiluvchi uchun ko'rinmaydi.

### 7.4.5 Unassigned Driving — `/logs/unassigned` 🎨
- **Ruxsat:** `logs.assign_unidentified` (ro'yxat) · **Endpointlar:** `GET /unidentified-events?status=&unit_id=&from=&to=` · `POST /unidentified-events/{id}/assign` (`logs.assign_unidentified`) · `POST /unidentified-events/{id}/annotate` (`logs.annotate_unidentified`) · `POST /unidentified-events/{id}/claim` (`logs.claim_unidentified`, mobil)
- **Ustunlar:** `# · Unit # · Start · End · Duration · Distance · Start/End location · Status (`pending|assigned|annotated`) · Action`
- **Amallar:** `Assign to driver` (select + izoh → **haydovchiga taklif ketadi**, `tz.md` §10.4) · `Annotate` (izoh bilan «unassigned» qoldirish, masalan mexanik test-drive) · xaritada trekni ko'rish
- **F104** 8 kundan ortiq `pending` — satr `error` fonda + Dashboard KPI (`unassigned_driving`) bilan bog'langan (`tz.md` Q57 `unidentified_driving` violation).

### 7.4.6 Violations — `/violations`
- **Ruxsat:** `violations.read` · **Endpointlar:** `GET /violations`, `GET /violations/{id}`
- **Filtrlar:** `driver_id` · `type` (10 qiymat: `form_manner_trailer, form_manner_doc, drive_limit, shift_limit, break_required, cycle_limit, uncertified_log, unidentified_driving, eld_malfunction, missing_dvir`) · `severity` (`warning|violation`) · `resolved` (boolean) · `from`/`to`
- **Ustunlar:** `# · Date · Driver · Unit · Type · Severity · Occurred at · Resolved at · Action`
- **Detal (`/violations/:id`):** tur tavsifi, HOS konteksti (o'sha kunning hisoblagichlari), tegishli daily log'ga havola, `resolved_at` va yopilish sababi
- **F105** Violation **o'chirilmaydi** (`tz.md` Q58, Q82.2) — `Delete` amali yo'q, faqat `resolved` badge.

---

