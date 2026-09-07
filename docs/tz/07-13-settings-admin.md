## 7.13 Settings — `/settings/*`

Kirish — profil menyusi orqali (dizayndagidek). Chapda ichki vertikal navigatsiya.

| Tab | Marshrut | Endpoint | Ruxsat |
|---|---|---|---|
| Company | `/settings/company` | `GET/PATCH /company` | `company.read` / `company.update` |
| Branches | `/settings/branches` | `GET/POST /company/branches`, `PATCH/DELETE /company/branches/{id}` | `branches.*` |
| Users | `/users` (Fleet menyusidan) | — | — |
| Roles | `/roles` | — | — |
| HOS Policy | `/settings/hos-policy` | `GET /company/hos-policy`, `POST /company/hos-policy` | `hos_policy.read/update` |
| Notifications | `/settings/notifications` | `GET/PATCH /company/notification-settings` | `notification_settings.*` |
| Defect Types | `/settings/defect-types` | §7.6.1 | `defect_types.*` |
| Company history | `/settings/company-history` | `GET /company/history` | `company.history.view` |
| Profile | `/settings/profile` | `GET /me` | authenticated |
| Security | `/settings/security` | `GET/DELETE /auth/sessions`, `POST /auth/2fa/*`, `POST /auth/password/*` | authenticated |

### 7.13.1 Company
**Maydonlar:** `Company Name *` · `Address *` · `Home Terminal Address *` · `Timezone *` (IANA ro'yxati) · `Email *` · `Phone *` · **`Registration No`** (label: `regulation_profile=fmcsa_us` → `US DOT`) · `Logo` (fayl, `kind=logo`) · `Region` (`PK|UZ|US|other`) · `Unit system` (`metric|imperial`) · `Regulation profile` (`generic|fmcsa_us`) · `Distance regions`
**Faqat ko'rish:** `plan`, `subscription_status`, `subscription_end_at` (o'zgartirish — Super Admin).
**F145 [MUST]** `unit_system` yoki `regulation_profile` o'zgartirilganda: tasdiq dialogi («This changes date formats and units across the whole panel») + saqlangandan keyin `GET /me` qayta olinadi va butun UI qayta formatlanadi (§12).

### 7.13.2 Branches 🎨
`Name · Address · Timezone · Users · Units · Action`. Sodda CRUD (`tz.md` §1: «🎨 oddiy CRUD ekran kerak [SHOULD]»).

### 7.13.3 HOS Policy 🎨 **[MUST]**
- **Endpoint:** `GET /company/hos-policy` (joriy amaldagi), `POST /company/hos-policy` (yangi versiya chiqarish)
- **Maydonlar** (`tz.md` §4.2, 15 parametr): `drive_limit_min` · `shift_window_min` · `break_required_after_drive_min` · `break_duration_min` · `break_qualifying_statuses[]` · `daily_rest_min` · `cycle_limit_min` · `cycle_days` · `cycle_restart_min` · `sleeper_split_enabled` · `allow_pc` · `allow_ym` · `ym_max_speed_kmh` · `motion_threshold_kmh` · `warning_thresholds{}` · `short_haul_exception` **[MAY]** · `adverse_conditions_extension_min` **[MAY]**
- **F146 [MUST]** Vaqt parametrlari UI'da **soat:daqiqa** sifatida kiritiladi (`11:00`), API'ga **daqiqada** yuboriladi. Preset tugmalari: `FMCSA 70/8` · `FMCSA 60/7`.
- **F147 [MUST]** `POST` — **yangi versiya yaratadi** (`effective_from` bilan), eskisini o'zgartirmaydi (`tz.md` Q10.1: retroaktiv violation paydo bo'lmaydi). UI aniq aytadi: «Publishing creates a new policy version effective from <sana>. Past days keep the policy that was in force then.» + tasdiq dialogi.
- **Versiyalar tarixi:** `effective_from`, `created_by`, farqlar (diff) ko'rinishi.

### 7.13.4 Notification settings 🎨
- **Endpoint:** `GET/PATCH /company/notification-settings`
- **Matritsa:** qator — 16 `alert_type`, ustun — kanal (`push · email · sms · in_app`), katak — checkbox; qo'shimcha ustun: **qabul qiluvchi rollar**.
- **F148** `hos_*` va `eld_*` uchun push **o'chirilmaydi** (`tz.md` Q89) — checkbox `disabled` + tooltip sabab bilan.

### 7.13.5 Company history
`Edited By · Changes · Date` + filtrlar (`table`, `action`, `record_id`, `user`, `from`, `to`).
**F149** Dizayndagi uchta mustaqil qidiruv (`Search Driver` · `Search Dispatcher` · `Search Unit`) → ✅ **bitta `user` filtri + `table` filtri**. `Dispatcher` so'zi faqat shu ekranda uchraydi va rol nomi sifatida ishlatilgan — olib tashlanadi. §16

### 7.13.6 Profile
`First Name * · Last Name * · Email * · Phone` (+ avatar).
**F150** Dizayndagi **`Last Address *`** — imlo/mantiq xatosi, ✅ **`Last Name`**. Placeholder'lardagi `Lorem ipsum` va `Address` — haqiqiy matnga almashtiriladi. §16

### 7.13.7 Security
- `Change password`: `Current password *` · `New password *` · `Confirm *`
- **F151** Dizaynda **eski parolni so'rash maydoni yo'q** edi — ✅ qo'shiladi (xavfsizlik talabi, sessiya o'g'irlangan holatda parolni almashtirishning oldini oladi). §16
- `Two-factor authentication`: yoqish/qayta o'rnatish (`POST /auth/2fa/setup|verify`)
- `Active sessions`: `GET /auth/sessions` → `Device type · Device · IP · Last seen · Current` + `Revoke` (`DELETE /auth/sessions/{id}`). Joriy sessiya `Revoke` = logout (tasdiq bilan).

---

## 7.14 Super Admin — `/admin/companies` **[MAY]**
- **Ruxsat:** `super_admin` · `GET/POST /companies`, `PATCH /companies/{id}`, `PATCH /companies/{id}/subscription`
- **Filtrlar:** `search` · `status` (`trial|active|grace|readonly`) · `region`; saralash `name|created_at|subscription_end_at`
- **F152** Super Admin tenant tanlaganda barcha so'rovlarga `X-Company-Id` header'i qo'shiladi (WS handshake'da ham). UI'da doimiy banner: «Viewing as <Company>» + chiqish tugmasi.
- **F153** MVP'dan tashqarida (`tz.md` qaror 24 — billing qo'lda). Marshrut mavjud, lekin **9-bosqichda** (§18) quriladi.

---

