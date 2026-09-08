## 7.3 Fleet Management

### 7.3.1 Unit Management — `/units`
- **Ruxsat:** `units.read` · **Endpoint:** `GET /units`
- **Tablar:** `Active` (`status=active`) / `Inactive` (`status=inactive`)
- **Filtrlar:** `search` (unit #, plate, VIN) · `branch_id` (scope=company da) · `out_of_service` (boolean) · `include_inactive`
- **Saralash:** `unit_number | status | make | year | created_at`

| Ustun | Maydon | Izoh |
|---|---|---|
| # | tartib | `(page-1)*per_page + i + 1` |
| Unit # | `unit_number` | |
| License Plate | `license_plate` | + `plate_region` kichik matn |
| Make & Model | `make` + `model` | ✅ kanonik: **`Make & Model`** (dizayndagi `Manufacturer - Model` emas) |
| Year | `year` | |
| ELD | `eld_device_serial` | bo'sh → `Not Found` (error rangda). ✅ ustun nomi **`ELD`**, qiymat — **qurilma serial raqami** |
| VIN | `vin` | `truncate` + nusxalash ikonkasi |
| Status | `status` + `out_of_service` | `out_of_service=true` → qizil `Out of service` badge |
| Action | `···` | |

- **Amallar:** `Add Unit` (`units.create`) · satr: `View` · `Edit` (`units.update`) · `Track on Map` · `Activate/Deactivate` (`units.activate/deactivate`) · `Delete` (`units.delete`)
- **Panel amallari:** `Export Units` (`units.export` → `GET /units/export?format=csv|xlsx`) · `Import Units` (`units.import`, §7.3.3) · ustun tanlash
- **Bo'sh/xato:** §6.5 / §6.7

### 7.3.2 Unit — Add / Edit / View / Activities
| Ekran | Marshrut | Endpoint | Ruxsat |
|---|---|---|---|
| Add (modal) | `/units` + `?modal=add` | `POST /units` (`Idempotency-Key`) | `units.create` |
| Edit (modal) | `?modal=edit&id=` | `PATCH /units/{id}` | `units.update` |
| View | `/units/:id` | `GET /units/{id}` | `units.read` |
| Activities | `/units/:id/activities` (tab) | `GET /units/{id}/history` | `units.read` |
| Diagnostics | `/units/:id/diagnostics` (tab) | `GET /units/{id}/diagnostics` | `units.diagnostics` |
| Assign driver | modal | `POST /units/{id}/assign-driver` | `units.assign_driver` |

**Add/Edit forma — `UNIT DETAILS`** (majburiylik `tz.md` §18.1 bo'yicha, dizayndan farq §16 da):

| Maydon | Tur | Majburiy | Manba/qiymatlar |
|---|---|---|---|
| Unit # | text | ✅ | |
| Make | select | ✅ | erkin matn + tavsiya ro'yxati |
| Model | select | ✅ | |
| License Plate Number | text | ✅ | |
| Plate Issue Region | select | — | label `regulation_profile` ga bog'liq (`License Plate Issue State` / `Plate Issue Region`) |
| Fuel Type | select | ✅ | `diesel · petrol · cng · lpg · electric · hybrid` (backend enum) |
| Year | number | — | 1950…joriy+1 |
| ELD | select | — | `GET /eld-devices?status=active` dan; **ixtiyoriy** (`tz.md` §18.1) |
| VIN | text | — | 17 belgi; «Get VIN from ELD» / «Enter VIN manually» radio |
| Branch | select | — | `scope=company` da ko'rinadi |
| GVWR class | select | — | **[MAY]** |
| Sleeper Not Available | checkbox | — | «The Sleeper Berth (SB) status will be disabled.» → `sleeper_berth=false` |
| Notes | textarea | — | ≤ 60 belgi |

**F82** Dizaynda `ELD *` va `Fuel Type*` majburiy, `Make/Model` ham majburiy edi; `tz.md` §18.1: majburiy — **Unit #, Make, Model, License Plate, Fuel Type**; ELD va VIN — ixtiyoriy (VIN ECM'dan o'qilsa avtomatik). ✅ TZ ustun. §16.

**View — `UNIT DETAILS`:** sarlavha `Unit # <unit_number>`. Maydonlar: Drivers (primary + `(co)`), ELD, Activated On, VIN, Make, Model, Year, Sleeper Berth (`Available`/`Not Available`), License plate + region, Fuel Type, Branch, Notes, Status, Out of service.
**Activities** (`GET /units/{id}/history`): `Time Stamp · Action · Changed by · Details`. Dizaynda 2 ustun (`Time Stamp · Activity`) va barcha satrlar `Lorem ipsum` edi → backend `audit_log` yozuvlari asosida **4 ustun** (§16).
**Diagnostics tab:** `device_serial · device_vendor · device_model · device_firmware · connection_type · connection_state · sim_present · last_seen_at · malfunction_codes[] · telemetry{}` (VIN, engine hours, odometer, fuel, coolant, oil, bus). Birliklar §12 bo'yicha konvertatsiya qilinadi.

### 7.3.3 Import — Units va Drivers
- **Endpoint:** `GET /units/import-template?format=csv|xlsx` · `POST /units/import` (`multipart`, `Idempotency-Key`); driverlar uchun `/drivers/import*`
- **Oqim:** modal → (1) «Download template» → (2) fayl tanlash (drag&drop, ≤ 10 MB, `.csv/.xlsx`) → (3) yuborish → (4) natija: `ImportRowError[]` (`row`, `field`, `message`) jadvali
- **F83** `tz.md` §18.4: **all-or-nothing** — bitta kritik xato bo'lsa hech narsa yozilmaydi. UI buni aniq aytadi: «Nothing was imported. Fix N errors and try again.» Xatolar jadvalini CSV sifatida yuklab olish mumkin.

### 7.3.4 Driver Management — `/drivers`
- **Ruxsat:** `drivers.read` · **Endpoint:** `GET /drivers`
- **Tablar:** Active / Inactive (+ `invited` holati badge bilan)
- **Filtrlar:** `search` · `status` (`invited|active|inactive`) · `branch_id` · `fleet_manager_id` · `include_inactive`
- **Saralash:** `name | username | status | created_at`

| Ustun | Maydon |
|---|---|
| # | tartib |
| First Name | `first_name` |
| Last Name | `last_name` |
| Username | `username` |
| Co-Driver | `GET /drivers/{id}/co-drivers` (ro'yxatda ko'rsatilmaydi — §F84) |
| Fleet Manager | `fleet_manager_name` |
| Unit # | `default_unit_number` |
| App Version | `app_version` + rangli nuqta (eng yangi = success, eski = neutral) |
| Activated On | `activated_on` |
| Status | `status` badge (`invited` — warning) |
| Action | `···` |

**F84** Dizayndagi `Co-Driver` ustuni ro'yxat javobida **yo'q** (alohida endpoint `GET /drivers/{id}/co-drivers`). ✅ Ustun **default'da yashirin**; Driver View ichida to'liq ro'yxat. N+1 so'rov qilinmaydi. §16/§17.
**F85** `App Version` uchun "eng yangi versiya" — `GET /app/config` dagi `latest_version`. Eski bo'lsa neutral nuqta + tooltip `Update available`.

- **Amallar:** `Add Driver` · satr: `View · Edit · Change Password · Activate/Deactivate · Delete`
- **`Change Password` → ✅ `Send password reset`** (`POST /drivers/{id}/reset-password`, `drivers.reset_password`). Dizayndagi «admin yangi parol kiritadi» modali **olib tashlanadi** (`tz.md` qaror 21: parol faqat invitation/reset orqali). §16
- **Panel:** `Export Drivers` (`GET /drivers/export`) · `Import Drivers` · ustun tanlash

### 7.3.5 Driver — Add / Edit / View / Activities
| Ekran | Marshrut | Endpoint |
|---|---|---|
| Add | modal | `POST /drivers` |
| Edit | modal | `PATCH /drivers/{id}` |
| View (Information) | `/drivers/:id` | `GET /drivers/{id}` |
| Activities | `/drivers/:id/activities` | `GET /drivers/{id}/activities` |
| Daily logs | `/drivers/:id/logs` | `GET /drivers/{id}/daily-logs` |
| HOS summary | View ichidagi blok | `GET /drivers/{id}/hos-summary?date=` |
| Co-drivers | View ichidagi blok | `GET/POST/DELETE /drivers/{id}/co-drivers` (`drivers.manage_co_drivers`) |

**Forma — `DRIVER DETAILS`** (majburiylik `tz.md` §18.1):

| Maydon | Majburiy | Izoh |
|---|---|---|
| First Name / Last Name | ✅ | |
| Username | ✅ | 4–32, `[a-z0-9._]` |
| Email | ✅ (yoki Phone) | invitation kanali |
| Phone | ✅ (yoki Email) | |
| License No | ✅ | forma'da to'liq kiritiladi, ro'yxat/View'da **maskalangan** (§F86) |
| License Region | — | label profilga bog'liq |
| Default Unit | — | `GET /units?status=active` |
| Fleet Manager | — | `GET /users` |
| Branch | — | `scope=company` da |
| Home Terminal | — | |
| City / State / Zip / Address 1 / Address 2 | — | |
| Notes | — | ≤ 60 |

**F86 [MUST]** `Password` maydoni **yo'q** (dizaynda bor edi — §16). `Co-Driver` maydoni formadan olib tashlanadi va **ixtiyoriy** bo'lib View ichidagi alohida blokka ko'chadi (`tz.md` qaror 22). Dizaynda `Co-Driver *` majburiy edi — ✅ bekor qilinadi.
**F87 [MUST] License PII:** ro'yxat va View'da `license_no_masked` ko'rsatiladi. `drivers.license.view` ruxsati bo'lsa — «Reveal» tugmasi → `GET /drivers/{id}/license` → qiymat **30 soniyaga** ochiladi, keyin qayta maskalanadi; ochish `audit_log`ga tushadi. Ochilgan qiymat clipboard'ga faqat aniq bosish bilan.
**Activities:** `Time Stamp · Edited By · Activity` (dizayndagi 3 ustun saqlanadi, `audit_log` dan).

### 7.3.6 ELD Devices — `/eld-devices` 🎨
- **Ruxsat:** `eld_devices.read` · **Endpointlar:** `GET/POST /eld-devices`, `GET/PATCH/DELETE /eld-devices/{id}`, `POST /eld-devices/{id}/assign-unit`
- **Filtrlar:** `search` · `status` (`active|inactive|malfunction`) · `unit_id` · `connection_type` (`bluetooth|wifi|cellular|usb`) · saralash `serial|vendor|status|created_at`
- **Ustunlar:** `Serial · Vendor · Model · Firmware · Connection · Status · Assigned Unit · Last seen · Action`
- **Amallar:** `Register device` · `Edit` · `Assign to unit` · `Delete`
- **F88** Dizaynda bu ekran **yo'q** (ELD faqat Unit formasida select edi), lekin backendda to'liq CRUD bor va TZ §10 uni talab qiladi → 🎨 standart ro'yxat patterni bo'yicha quriladi.

### 7.3.7 Trailers — `/trailers` 🎨
- **Ruxsat:** `trailers.read` · `GET/POST /trailers`, `GET/PATCH/DELETE /trailers/{id}`; filtr `search`
- **Ustunlar:** `Number · Notes · Created · Action`. Dizaynda yo'q (`tz.md` §1: v1'da jadval yo'q edi) → 🎨 sodda CRUD.

### 7.3.8 Shipping Documents — `/shipping-documents` 🎨
- **Ruxsat:** `shipping_documents.read` · `GET/POST /shipping-documents`, `GET/PATCH/DELETE /shipping-documents/{id}`
- **Ustunlar:** `Number · Notes · Created · Action`. 🎨 sodda CRUD.

### 7.3.9 User Management — `/users`
- **Ruxsat:** `users.read` · `GET /users` · saralash `last_name|first_name|username|email|status|created_at`
- **Filtrlar:** `search` · `status` (`invited|active|inactive`) · `role_id` · `branch_id`
- **Ustunlar:** `# · First Name · Last Name · Email · **Role** (rol nomi) · Phone · Branch · Status · Action`
- **F89** Dizaynda `Role` ustunida **ism** yozilgan («Kiss Dorka») — placeholder xatosi. ✅ rol nomi. `Export Drivers` tugmasi → ✅ **`Export Users`**; backendda `/users/export` **yo'q** → tugma MVP'da **olib tashlanadi** (§17 CR nomzodi). §16
- **Amallar:** `Invite User` (`POST /users`, `users.create`) · `Edit` (`PATCH /users/{id}`) · `Activate/Deactivate` (`POST /users/{id}/activate|deactivate`, `users.update`) · `Resend invitation` (`POST /users/{id}/resend-invitation`, `users.invite`) · `Send password reset` (`POST /users/{id}/reset-password`) · `Delete` (`users.delete`)
- **Forma — `USER DETAILS`:** `First Name *`, `Last Name *`, `Email *`, `Phone`, `Role *` (`GET /roles`), `Branch` — 5 maydon dizayndagidek + Branch. `Password` maydoni **yo'q**.

### 7.3.10 Roles & Permissions — `/roles`
- **Ruxsat:** `roles.read` · `GET/POST /roles`, `PATCH/DELETE /roles/{id}` · `GET /permissions` (`permissions.read`)
- **Filtrlar:** `search` · `scope` (`company|branch|self`) · `is_system`
- **Ustunlar:** `# · Role Name · Scope · Users · System · Action`
- **F90 [MUST] Ruxsatlar ro'yxati to'liq qayta yoziladi.** Dizayndagi ro'yxat **go'zallik saloni domenidan** (`Salons`, `Clients`, `Employees`, `View salons reservation graph` …) — butunlay begona. ✅ Dizayndan **faqat struktura** olinadi: `Role Name *` + modullarga guruhlangan checkbox'lar. Manba — `GET /permissions` (105 kalit) va `backend/internal/auth/permissions.go`.

**Ruxsat guruhlari UI'da** (kalit prefiksidan avtomatik, i18n bilan nomlanadi):
`Company · Branches · HOS Policy · Notification Settings · Users · Roles · Units · Drivers · ELD Devices · Trailers · Shipping Documents · Logs · Inspection · Violations · Tracking · Routes · DVIR · Defect Types · Maintenance · Reports · Dashboard · Notifications · Chat · Support · Feedback · Files · Audit`

Har guruhda: guruh `Select All` + kalitlar. Kalit yorlig'i — amal nomi (`Read`, `Create`, `Update`, `Delete`, `Activate`, `Export`, `Import`, `Assign driver`, `Diagnostics`, `Reveal licence number`, …).
- **F91** `scope` tanlovi (`company | branch`) — rol formasida majburiy maydon (`tz.md` Q82.1). `self` — faqat tizim Driver roli, UI'da tanlanmaydi.
- **F92** `is_system=true` rollar (`Super Admin`, `Administrator`): tahrirlash va o'chirish **bloklangan**, `Duplicate` tugmasi taklif qilinadi.
- **F93** Rolni o'chirishda foydalanuvchilari bo'lsa — backend `409 CONFLICT`; UI: «N users still use this role. Reassign them first.» + `/users?role_id=` havolasi.
- **F94** Noma'lum permission kaliti hech qachon yuborilmaydi (backend `FilterKnown` bilan tashlaydi, lekin UI ham `GET /permissions` ro'yxati bilan cheklanadi).

---

