## 7.5 DVIR — `/dvir`

- **Ruxsat:** `dvir.read` · **Endpointlar:** `GET /dvir-reports`, `GET /dvir-reports/{id}`, `GET /dvir-reports/pending-certification`, `POST /dvir-reports/{id}/repair` (`dvir.repair`), `POST /dvir-reports/{id}/certify` (`dvir.certify`), `GET /dvir-reports/{id}/pdf` (`dvir.export`)
- **Tablar:** `All` · `Pending certification` (`GET /dvir-reports/pending-certification`)
- **Filtrlar:** `unit_id` · `driver_id` · `type` (`pre_trip|post_trip`) · `status` · `from`/`to`

| Ustun | Manba |
|---|---|
| # | tartib |
| Driver Name | |
| Unit # / Trailer | |
| Type | `pre_trip` / `post_trip` badge |
| Defects | nuqsonlar soni; kritik bo'lsa qizil ikonka |
| Location | manzil matni |
| Created At | `created_at` |
| Status | 6 qiymat (quyida) |
| Action | `···` |

**F106 [MUST] Status to'plami — backend enum'i ustun:**
`draft · submitted_no_defects · submitted_defects_found · repaired · certified · closed_no_certification`
Dizayndagi 7 qiymat (`Not Started`, `In Progress`, `Submitted`, `Submitted - No Defects`, `Submitted - Defects Found`, `Repaired`, `Certified`) bilan moslashtirish:
| Dizayn | Backend | Qaror |
|---|---|---|
| `Not Started` | — | ✅ **derived**, ro'yxatda emas: «Units without a DVIR today» filtri (`tz.md` Q30.2) |
| `In Progress` | `draft` | ✅ faqat mobil lokal holat; admin ro'yxatida **ko'rsatilmaydi** (Q30.2) |
| `Submitted` | — | ✅ olib tashlanadi (ikki aniq holat bor) |
| `Submitted - No Defects` | `submitted_no_defects` | ✅ |
| `Submitted - Defects Found` | `submitted_defects_found` | ✅ |
| `Repaired` | `repaired` | ✅ |
| `Certified` | `certified` | ✅ |
| — | `closed_no_certification` | ✅ **yangi**: unit inactive bo'lganda yopilgan (Q30.1) |

- **Detal (`/dvir/:id`):** sarlavha + status · unit/trailer · tur · vaqt/joylashuv/odometer · nuqsonlar ro'yxati (kategoriya, `is_critical`, foto ≤ 5, izoh) · haydovchi imzosi (ko'rish) · mexanik imzosi (agar bor) · tarix (kim, qachon, qaysi holatga)
- **Amallar:** `Record repair` (`dvir.repair`) — modal: izoh (majburiy), invoice fayl (ixtiyoriy, §10) · `Certify` (`dvir.certify`) · `Download PDF`
- **F107 [MUST]** Admin **DVIR yaratmaydi** (`tz.md` Q31). Dizayndagi `Generate Report` formasi (`Paste driver signature here`, `Paste mechanic signature here`) — **olib tashlanadi**. Uning o'rniga: (a) `/dvir` ro'yxati + filtrlar, (b) `Export` → `POST /reports/export-jobs {type:"dvir"}` (§11). §16
- **F108** Kritik nuqsonli DVIR → unit `out_of_service` bayrog'i; ro'yxatda va Unit ekranida qizil banner (`tz.md` Q27.2).

---

## 7.6 Maintenance — `/maintenance`

**Uchta tab, uchta ma'lumot manbai:**

| Tab | Marshrut | Endpoint | Ruxsat |
|---|---|---|---|
| Schedule | `/maintenance/schedules` | `GET /maintenance-schedules?status=&q=` | `maintenance.read` |
| Due | `/maintenance/due` | `GET /maintenance/due?unit_id=&schedule_id=&status=` | `maintenance.read` |
| History | `/maintenance/history` | `GET /maintenance-records?unit_id=&status=completed\|cancelled&from=&to=` | `maintenance.read` |

**Schedule ustunlari:** `# · Unit # (yoki «N Units») · Type · Schedule Name · Maintenance Frequency · Status · Action`
**Due ustunlari:** `# · Unit # · License Plate · Type · Schedule Name · **Remaining Frequency** · **Reminder Sent** · Action`
**F109** Dizaynda bo'sh holatda `Remind`/`Due Date`, to'la holatda `Remaining Frequency`/`Reminder Sent` ustunlari edi. ✅ **Ikkalasida ham `Remaining Frequency` va `Reminder Sent`** — bo'sh va to'la holat ustunlari **hech qachon farq qilmaydi**. §16

**History ustunlari:** `Maintenance Date · Unit # · Driver Name · Make & Model · Type · Status · Invoice # · Vendor Name · Cost · Schedule Name · Odometer · Engine Hours · Attachment · Action`
(11 dan ortiq ustun → default'da `Odometer`, `Engine Hours`, `Attachment` yashirin — F56)

- **Amallar:** `Add Maintenance` (`POST /maintenance-schedules`, `maintenance.create`) · satr: `View · Edit (PATCH) · Mark as Complete (POST /maintenance-schedule-units/{id}/complete) · Cancel (POST …/cancel) · Delete (DELETE /maintenance-schedules/{id})`
- **Guruh ichiga kirish:** `N Units` satri bosilganda → `/maintenance/schedules/:id/units`, breadcrumb `Due › N units`, ustunlar Due bilan bir xil, `Refresh` tugmasi

**Add / Edit formasi — `MAINTENANCE DETAILS`** (imlo to'g'rilangan: dizaynda `MAINTAINANCE DETAILS`):

| Maydon | Tur | Majburiy | Izoh |
|---|---|---|---|
| Maintenance Type | select | ✅ | katalog: Oil Change, Tyre, Engine Oil Change, Lights Change, Lease Expiry, **Grease** (dizaynda `Grese`) |
| Mode | radio | ✅ | `Single Unit` / `Multiple Units` |
| Unit # | select | ✅ (single) | |
| Units | ko'p tanlov | ✅ (multiple) | `Select All` + har unit uchun `last_service_value` |
| Maintenance Frequency | son + birlik | ✅ | birlik: `km/mi` (§12) · `days` · `engine hours` |
| Set Reminder (before service due) | son + birlik | ✅ | |
| Schedule Name | text | ✅ | |
| Current Frequency → **Last service value** | son + birlik | — | `tz.md` Q33: dizayn labeli qoladi, ma'nosi tooltip'da |
| Alert Type | select | ✅ | ✅ **`maintenance_upcoming` / `maintenance_overdue`** (backend `alert_type` enum'idan) — dizaynda ro'yxat berilmagan edi |
| Delivery Method | ko'p tanlov | ✅ | ✅ **`push · email · sms · in_app`** (`tz.md` Q89) |
| Notify co-driver | checkbox | — | ✅ kanonik yozuv: **`Notify co-driver`** (kichik harf) |
| Notes | textarea | — | ≤ 60 |

**F110 Formulalar** (`tz.md` Q33, dizayn bet 45 bilan mos):
`next_due_value = last_service_value + interval` · `remaining = next_due_value − current_value` · `remaining < 0` → **Overdue**, qizil (dizaynda `0verdue` — imlo xatosi, §16)
UI hech qanday formulani o'zi hisoblamaydi — barcha qiymatlar backenddan. Faqat **birlik konvertatsiyasi** frontendda (§12).

**View (single):** `Unit # · Schedule Name · Maintenance type · Last service value · Maintenance Frequency · Next Frequency · Remind before · Alert Type · Delivery Method · Notify co-driver · Notes`
**View (multiple):** yuqoridagi + `UNITS` jadvali (`Unit · Last service value · Next Frequency · Remaining`)

**`MARK MAINTENANCE AS COMPLETE` modali** (`POST /maintenance-schedule-units/{id}/complete`, `maintenance.complete`):
`Invoice #` · `Vendor Name` · `Cost` · `Maintenance Date` · `Invoice` (fayl — §10, `kind=invoice`)
**F111** Dizaynda «faqat PDF» yozilgan; `tz.md` §18.3: **PDF/JPG/PNG ≤ 10 MB**. ✅ TZ ustun. §16
**Cancel modali** (`POST …/cancel`): sabab (majburiy). Cancelled yozuvda moliyaviy maydonlar bo'lmaydi.

**F112** Dizayndagi eskirgan `Verification` tabi va `Mark Maintenance as Rejected` oqimi **yo'q** (amaldagi qatlamda ham olib tashlangan, backendda ham yo'q).
**F113** History detalidagi `PRE-TRIP INSPECTION` / `POST-TRIP INSPECTION` bloklari — dizaynda bo'sh edi. ✅ O'sha unit uchun **o'sha sanadagi DVIR'lar** ro'yxati bilan to'ldiriladi (`GET /dvir-reports?unit_id=&from=&to=`), har biri `/dvir/:id` ga havola.

### 7.6.1 Defect Types — `/settings/defect-types` 🎨
- **Ruxsat:** `defect_types.read` · `GET/POST /defect-types`, `PATCH /defect-types/{id}`
- **Filtrlar:** `category` (`truck|trailer`) · `is_active` · `is_critical`
- **Ustunlar:** `Name · Category · Critical · Active · Action`
- **F114** Dizayndagi 44 bandli truck ro'yxatidagi **`Engine` dublikati va `Refresh`** (nuqson emas) **olib tashlanadi** (`tz.md` Q27.1). §16

---

