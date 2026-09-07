## 7.8 Reports

**Umumiy:** har hisobotda filtr paneli + jadval/ko'rsatkichlar + `Export` tugmasi. Eksport — **asinxron** (§11), istisno: `GET /units/export`, `GET /drivers/export` (darhol fayl).

### 7.8.1 Activity Report — `/reports/activity`
- **Ruxsat:** `reports.read` · **Endpoint:** `GET /reports/activity?subject=drivers|units&from*&to*&unit_id&driver_id`
- **Tablar:** `Drivers` / `Units` (`subject`)
- **Drivers ustunlari:** `Driver Name · Start Odometer · End Odometer · Odometer Change · Driving Time (HH:MM:SS)`
- **Units ustunlari:** `+ Unit #`
- **F120** Dizaynda oxirgi ustun `Odometer Change` deb ikki marta yozilgan. ✅ `tz.md` §1.3: **`End Odometer`** oxirgi ustun, `Odometer Change` alohida ustun (`= End − Start`, Q75). §16
- **F121** Dizaynda `Download CSV` tugmasi **ikki joyda** takrorlangan → ✅ **bitta**, filtr panelida. §16
- **Detal:** `/reports/activity/:subjectId` — breadcrumb `Activity Report › <nom>`; ustunlar `# · Date · Start · Duration · Location · Odometer · Eng. Hrs · Document · Notes`
- **Eksport:** `POST /reports/export-jobs {type:"activity", format:"csv|xlsx|pdf", params:{…}}`

### 7.8.2 Distance by Region — `/reports/distance-by-region` (dizaynda «IFTA Report»)
- **Ruxsat:** `reports.read` · **Endpoint:** `GET /reports/distance-by-region?quarter*&year*&mode=regions_and_units|regions_only&unit_id`
- **F122 [MUST]** Ekran nomi `regulation_profile` ga bog'liq (`tz.md` Q0.2): `fmcsa_us` → **`IFTA Report`**, `generic` → **`Distance by Region`**. Bitta i18n kalit, ikkita qiymat.
- **Yuqori ko'rsatkichlar:** `IFTA Miles / In-region distance` · `Non-IFTA / Out-of-region` · `Total` (`Total = In + Out`)
- **Tablar:** `Units` (`Unit # · VIN · Region · Distance · Month`) / `Regions` (`Region · Total distance`)
- **Filtrlar:** `Year *` · `Quarter *` · `Region` · `Unit`
- **F123** Dizayndagi eslatma «Reports will be ready by the fifth day of each month» **olib tashlanadi** — `tz.md` §14: kunlik agregat (`unit_region_distance_daily`), hisobot **darhol tayyor**. §16
- **F124** Dizayndagi shtat kodlari orasida `XT` bor — AQSh shtat kodi emas, test ma'lumoti xatosi. Regionlar ro'yxati **backenddan** (`company.settings.distance_regions`), hardcode qilinmaydi. §16
- **Generate modali:** `GENERATE AS` (`csv|pdf|xlsx`) · **`GET BY`** (dizaynda `GET BTY` — imlo xatosi) → `regions_and_units` / `regions_only` · `Regions *` (ko'p tanlov) · `Units *` (faqat `regions_and_units` rejimida — shartli maydon) · `Quarter *` · `Year *` → `POST /reports/export-jobs {type:"distance_by_region"}`

### 7.8.3 Regulator Export — `/reports/regulator` (dizaynda «FMCSA Report»)
- **Ruxsat:** `reports.read` / `reports.export` · **Endpointlar:** `GET /reports/export-jobs?type=regulator` · `POST /reports/export-jobs {type:"regulator"}` · `GET /reports/export-jobs/{id}`
- **F125** Ekran nomi profilga bog'liq: `fmcsa_us` → **`FMCSA Report`**, `generic` → **`Regulator Export`**.
- **Ustunlar:** `# · Driver Name · Comment · Start Date · End Date · Status (queued|running|done|failed) · Processed Time (finished_at) · Job ID · Action (Download)`
- **F126** Dizayndagi `Submission ID` (UUID) → ✅ **`Job ID`** = `export_job.id`. Dizayndagi `Status: Pending / Information` → backend enum'i `queued|running|done|failed`. §16
- **Generate modali — `REPORT DETAILS`:** `Type *` (`Roadside inspection report (8 days)` / `Custom Range`) · `Driver *` · `From */To *` (faqat Custom Range) · `Comment *`
- **F127** `tz.md` §14: `fmcsa_us` da FMCSA output file + web-service — **2-bosqich**; `generic` da PDF+CSV darhol. UI ikkalasini `export_job.format` orqali qo'llab-quvvatlaydi.

### 7.8.4 DVIR Report — `/reports/dvir`
- **Ruxsat:** `reports.read` · **Endpointlar:** `GET /dvir-reports` (jonli ro'yxat) · `POST /reports/export-jobs {type:"dvir"}`
- **F107** ga muvofiq: **imzo joylashtirish formasi yo'q**. Faqat filtr (`Driver`, `Unit`, `Date range`, `Type`, `Status`) + `Export` (`csv|xlsx|pdf`).

### 7.8.5 Uncertified Logs — `/reports/uncertified-logs`
- **Ruxsat:** `reports.read` · **Endpoint:** `GET /reports/uncertified-logs?driver_id&branch_id`
- **Ustunlar:** `Driver · Log date · Days uncertified · Unit · Totals · Action (Send reminder / Open log)`
- **F128** `tz.md` Q19.1: 8 kundan eskirgan sertifikatlanmagan kunlar **shu hisobotda** ko'rinadi (haydovchi ilovasidagi 8 kunlik oynadan tashqarida ham).

### 7.8.6 HOS Summary export
- `POST /reports/export-jobs {type:"hos", params:{driver_id, from, to}}` — alohida ekran emas, Logs By Driver va Driver View'dagi `Export` tugmasi.

### 7.8.7 Export Jobs — `/reports/exports`
- **Ruxsat:** `reports.read` · **Endpointlar:** `GET /reports/export-jobs?status&type&mine` · `GET /reports/export-jobs/{id}`
- **Ustunlar:** `# · Type · Format · Params · Requested by · Created · Started · Finished · Size · Status · Download`
- **F129** `mine=true` — default (o'z eksportlarim); `Show all` toggle bilan kompaniya bo'yicha. Batafsil oqim — §11.

---

