# 16. Nomuvofiqliklar reestri

Dizayn inventarida **31 ta nomlash nomuvofiqligi** (B.1 + B.2), **16 ta imlo xatosi** (C) va **4 turdagi begona kontent** (B.3) qayd etilgan. Quyida har biri uchun **kanonik qaror**, **sabab** va **manba**. Qaror manbalari ustuvorligi: `backend` > `tz.md §1.3` > `tz.md` (boshqa) > `frontend qarori`.

## 16.1 Navigatsiya va ekran nomlari (B.1 — 10 ta)

| № | Dizayndagi variant | ✅ Kanonik qaror | Sabab | Manba |
|---|---|---|---|---|
| N1 | `Fleet Operations` / `Fleet Management` | **Fleet Management** | Kanonik nomlar jadvalida qat'iy belgilangan; «Operations» kengroq va noaniq | `tz.md` §1.3 |
| N2 | `Reports` / `Report` | **Reports** | Modul ko'plikda (4 hisobot turi) | `tz.md` §1.3 |
| N3 | `Support & History` / `Histories` | **Support & History** (ichida `Histories` punkti) | Ikkalasi ham kerak: modul nomi va ichki ekran nomi | `tz.md` §1.3 |
| N4 | `Inspection Report` / `DOT Report` | **Inspection Report** | `DOT` — AQSh domeni; `regulation_profile=generic` da ma'nosiz. Web'da faqat tarix ekrani (§7.12) | `tz.md` §1.3, Q0.2 |
| N5 | `Unit Diagnostics` / `Unit Inspection` | **Unit Diagnostics** | Blok ELD telemetriyasini ko'rsatadi, tekshiruv (inspection) emas — DVIR bilan chalkashadi | `tz.md` §1.3 |
| N6 | `Leave the Truck` / `Leave Truck` | **Leave Truck** | Mobil/planshet; web'ga taalluqli emas, terminologiya birligi uchun qayd | `tz.md` §1.3 |
| N7 | `In Progress` / `In-Progress` | **In Progress** (backend qiymati `in_progress`) | Backend enum'i `in_progress`; ko'rsatiladigan matn probel bilan | backend + `tz.md` §1.3 |
| N8 | `Yes, Driving` / `Yes, driving` | **Yes, driving** | Mobil; sentence-case umumiy qoidasi | `tz.md` §1.3 |
| N9 | `Dropoff`/`Checkout` vs `Drop off`/`Check out` | **Drop-off**, **Check-out** | Quick notes katalogi Company darajasida sozlanadi; default ro'yxat shu yozuvda | `tz.md` §1.3 |
| N10 | `Notify co-driver` / `Notify Co-driver` | **Notify co-driver** | Sentence-case; Maintenance formasi va View'da bir xil | `tz.md` §1.3 |

## 16.2 Ustun / maydon nomuvofiqliklari (B.2 — 21 ta)

| № | Muammo | ✅ Kanonik qaror | Sabab | Manba |
|---|---|---|---|---|
| N11 | `Maintenance › Due`: bo'shda `Remind`/`Due Date`, to'lada `Remaining Frequency`/`Reminder Sent` | **`Remaining Frequency` + `Reminder Sent`** ikkala holatda | Ustunlar to'plami ma'lumot borligiga qarab **hech qachon** o'zgarmaydi; bo'sh holatda ham sarlavha ko'rinadi | frontend (F109) |
| N12 | Contact Support: `Ticket ID`/`Message` vs `Ticket #`/`Subject` | **`Ticket #`, `Subject`** | Kanonik nomlar jadvali; backendda `subject` maydoni bor | `tz.md` §1.3 + backend |
| N13 | Unit jadvali: `Make & Model`/`ELD` vs `Manufacturer - Model`/`Device ID` | **`Make & Model`, `ELD`** | Backend maydonlari `make`, `model`, `eld_device_serial`; qisqaroq va ro'yxatga sig'adi | backend (F82) |
| N14 | ELD id formati `PT30_A9A1` vs `AP-AM4-0001172` | **Vendor serial raqami, format majburlanmaydi** | Har vendor o'z formatini beradi; UI validatsiya qilmaydi, faqat ko'rsatadi | `tz.md` §1.3, §10 |
| N15 | Activity Report oxirgi ustun `Odometer Change` (ikki marta) | **`End Odometer`** oxirgi ustun, `Odometer Change` alohida | `Odometer Change = End − Start`; ikkalasi ham kerak | `tz.md` §1.3, Q75 |
| N16 | User Management: `Role` ustunida ism; `Export Drivers` tugmasi | **Rol nomi**; tugma `Export Users` — lekin backendda endpoint yo'q → **MVP'da olib tashlanadi** | Placeholder xatosi; eksport endpointi mavjud emas (§17-Q7) | backend + `tz.md` §1.3 |
| N17 | `Histories` sahifasida `Add User` tugmasi | **Tugma olib tashlanadi** | Audit jurnaliga yozuv qo'shib bo'lmaydi (`audit_log` append-only, tashqi yozuvsiz) | `tz.md` §1.3, §17 |
| N18 | `Profile / Setting` birinchi ekrani FMCSA jadvalini ko'rsatadi | **Dizayn xatosi — e'tiborga olinmaydi** | Noto'g'ri komponent nusxalangan; Settings tabi §7.13 bo'yicha quriladi | frontend |
| N19 | Log jami formati `OFF 03:06` vs `Off - 00:00` | **`OFF 03:06`** (uppercase kod + probel + `HH:MM`) | Status kodlari hamma joyda uppercase (`OFF/SB/DR/ON`) | `tz.md` §1.3 |
| N20 | Bo'sh qiymat `na` vs `N/A` | **`N/A`** | Standart qisqartma; i18n kaliti `common.na` | `tz.md` §1.3 |
| N21 | Hafta kuni `Tues`, `Thurs` (4 harf) vs 3 harf | **3 harf** (`Mon Tue Wed Thu Fri Sat Sun`) | `Intl.DateTimeFormat({weekday:'short'})` avtomatik beradi | `tz.md` §1.3 (F140) |
| N22 | Truck defects: `Engine` ikki marta, `Refresh` nuqson emas | **Dublikat va `Refresh` olib tashlanadi** | Nuqson katalogi `defect_types` jadvalidan boshqariladi (§7.6.1) | `tz.md` Q27.1 |
| N23 | Quick notes: 10 bandli vs 8 bandli ikki to'plam | **Bitta ro'yxat, Company darajasida sozlanadi** | Default: PTI, Hook, Pickup, Drop-off, Delivery, Inspection, Check-in, Fueling, Check-out, Break, Other | `tz.md` §1.3 |
| N24 | Sertifikatsiya oynasi `Last 8 days` vs `Last 11 days` | **8 kun** (`certification_window_days = 8`) | Global konstanta; 8 kundan eskisi «Uncertified logs» hisobotida | `tz.md` Q19 |
| N25 | Log jadvali oxirgi ustuni: planshetda `Edit`, mobilda `Action` | **`Action`** (web admin uchun) | Ustun bitta amal emas, menyu (`···`) ni ochadi | frontend |
| N26 | Sana tasmasi: mobilda `Fri 07`, planshetda `07 Jan` | **Web'ga taalluqli emas**; web'da to'liq sana navigatori `‹ 17/12/2025 ›` | Web'da joy yetarli, qisqartma kerak emas | frontend (§12.2) |
| N27 | Bildirishnoma vaqti: nisbiy (`2hrs`) vs absolyut (`28 May, 10:04 am`) | **< 24 soat — nisbiy, keyin absolyut** | Yaqin hodisa uchun nisbiy tushunarli, eskisi uchun aniq sana kerak | frontend (F144) |
| N28 | ELD output file matni: «to the DOT officer» vs «to the Insection officer» | **«to the inspection officer»** (`generic`), «to the DOT officer» (`us_fmcsa`) | Imlo xatosi + domen bog'liqligi | `tz.md` Q0.2, C5 |
| N29 | Sana/vaqt formati — **6 xil variant** | **2 ta format**, `regulation_profile` ga bog'liq (§12.2 jadvali) | Yagona manba: `Intl` + company profili | `tz.md` §18.4 |
| N30 | DVIR holat to'plami: mobil 3 tur vs admin 7 holat | **Backend 6 holati kanonik** (§7.5, F106); mobil 3 turi — derived ko'rinish | Backend enum'i haqiqat; `Not Started`/`In Progress`/`Submitted` — UI derived yoki olib tashlangan | backend + `tz.md` Q30.2 |
| N31 | Dark/Light Figma tugun nomlari (`Edit Documents` → `edit doc`) | **E'tiborga olinmaydi** (Figma ichki nomlanishi) | Tugun nomi mahsulot matni emas; admin panelda dark tema yo'q (F53) | frontend |

## 16.3 Imlo xatolari (C — 16 ta)

Barchasi **to'g'rilangan holda** yoziladi; hech biri kodga yoki i18n fayliga xato holida tushmaydi.

| № | Dizaynda | ✅ To'g'risi | Qayerda |
|---|---|---|---|
| C1 | `Maintainance` | **Maintenance** | seksiya nomi, `MAINTAINANCE DETAILS` bloki, nav element |
| C2 | `Invocie` | **Invoice** | mobil upload formasi (web: Maintenance complete modali) |
| C3 | `Grese` | **Grease** | maintenance turi katalogi |
| C4 | `0verdue` (nol) | **Overdue** | maintenance `remaining < 0` holati |
| C5 | `Insection` | **Inspection** | Inspection Report matnlari |
| C6 | `Drivers Mangement` | **Driver Management** | ekran nomi (kanonik birlikda: `Driver Management`) |
| C7 | `Selecetd` | **Selected** | planshet ekran nomi |
| C8 | `easr avon` | **East Avon** | log detali namunasi (test ma'lumoti) |
| C9 | `GET BTY` | **GET BY** | Distance by Region / IFTA Generate formasi |
| C10 | `Last Address *` | **Last Name** | Settings › Profile (F150) |
| C11 | `cManagement - Inactive` | **Driver Management — Inactive** | ekran nomi |
| C12 | `automaticlly` | **automatically** | mobil komponent nomi |
| C13 | `5 mint idle` | **5 min idle** | planshet ekran nomi |
| C14 | `23,97464553778` | **23.9746455** | koordinata: nuqta o'nlik ajratgich, 7 xona (F101) |
| C15 | `XT` shtat kodi | **Ro'yxatdan chiqariladi** | AQSh shtat kodi emas; regionlar backenddan (`distance_regions`) — F124 |
| C16 | Warning `#F9B385` yozilgan, RGB `246,176,71` | **`#F6BA47`** | RGB to'g'ri, hex yozuvi xato; `tz.md` §1.2 ham `#F6BA47` (F41) |

## 16.4 Begona kontent (B.3 — 4 tur) **[MUST olib tashlanadi]**

| Nima | Qayerda | ✅ O'rniga nima |
|---|---|---|
| **Rolli ruxsatlar — go'zallik saloni domeni** (`Salons`, `Clients`, `Employees`, `View salons reservation graph`, `View male & female Salons piechart` …) | Add/Edit Role ekrani (`330:45466`, `331:46454`) | **`GET /permissions` dan 105 ta haqiqiy kalit**, 26 modul guruhiga bo'lingan (§7.3.10, F90). Dizayndan faqat tuzilma olinadi: `Role Name *` + guruhlangan checkbox ro'yxati |
| **Privacy Policy / Terms of Use — «Jusoor», «ONTime Log», «OnTime ELD»** (Saudiya biznes platformasi matni) | mobil `2627:25778`, planshet `2568:25226` | ❓ Buyurtmachidan **haqiqiy huquqiy matn** (`tz.md` qaror 28). Web admin'da bu ekranlar yo'q; footer'da havolalar bo'ladi — matn kelmaguncha havolalar **ko'rsatilmaydi** |
| **Chat demo xabarlari — dizayn jarayoni haqida** («Did you finish the Hi-FI wireframes for flora app design?») | admin `283:15887`, mobil `1118:114` | **Haqiqiy ssenariy**: dispetcher ↔ haydovchi yozishmasi. Demo/seed ma'lumot sifatida: yuk topshirish, dok raqami, kechikish, tanaffus (F131) |
| **Muqova sarlavhasi — «Seamless Healthcare Access Mobile App Design»** | `2142:16231` | **ONEBOOK ELD** — mahsulot nomi. Prezentatsiya artefakti, mahsulotga ta'sir qilmaydi |

**Placeholder qolgan joylar** (barchasi haqiqiy matn bilan almashtiriladi):
| Joy | ✅ Nima yoziladi |
|---|---|
| Logs flyout tavsiflari (`lorem ipsum`) | «View logs by unit for a single day» · «View logs by driver over a date range» · «Review and approve driver log edit requests» · «Assign unidentified driving to drivers» · «HOS warnings and violations» |
| Reports flyout tavsiflari | «Driving time and odometer by driver or unit» · «Distance travelled per region» · «Regulator export for roadside inspections» · «DVIR history and export» · «Logs that are still uncertified» · «Your export downloads» |
| Support & History flyout tavsiflari | «Full audit trail of every change» · «Driver support tickets» · «App ratings and comments from drivers» |
| Unit / Driver Activities jadvallari (`Lorem ipsum`) | `audit_log` yozuvlari: `<FIELD> changed from <eski> to <yangi>`, `Driver assigned`, `Deactivated`, … |
| Settings › Password tabi (`Lorem ipsum`, `Address`) | To'g'ri placeholder'lar: «Enter your current password», «At least 10 characters with a letter and a number» |

## 16.5 Qo'shimcha qarorlar (dizayn ↔ TZ/backend to'qnashuvi)

| № | Dizaynda | ✅ Qaror | Sabab | Manba |
|---|---|---|---|---|
| D1 | Header'da tema almashtirgich (quyosh) | **Olib tashlanadi**, MVP faqat light | Admin panelda birorta dark ekran chizilmagan (130 tugundan 0 tasi); toggle ishlamas bo'lardi. Texnik tayyorgarlik (CSS o'zgaruvchilar) saqlanadi | F53 |
| D2 | Driver formasida `Password *` maydoni; Edit'da parol **ochiq matnda** (`1234john5678`) | **Maydon olib tashlanadi**; parol faqat invitation / reset link orqali | Parolni admin bilishi audit va xavfsizlik buzilishi; ochiq ko'rsatish — jiddiy nuqson | `tz.md` qaror 21, F86, F206 |
| D3 | Driver formasida `Co-Driver *` majburiy | **Ixtiyoriy**, formadan View ichidagi blokka ko'chadi | Ko'p kompaniyada co-driver umuman yo'q | `tz.md` qaror 22 |
| D4 | `Insert duty status` → `Confirm` (to'g'ridan-to'g'ri tahrir) | **`Send edit request`** — taklif → haydovchi tasdig'i | FMCSA §395.30: admin logni bevosita o'zgartira olmaydi. Eng katta dizayn↔TZ farqi | `tz.md` §5.3, F100 |
| D5 | DVIR `Generate Report`: `Paste driver signature here`, `Paste mechanic signature here` | **Forma olib tashlanadi**; faqat filtr + eksport | Admin joylashtirgan imzo — auditda haqiqiy imzo emas | `tz.md` Q26, Q31, F107 |
| D6 | Admin `Change Password` modali (haydovchi uchun yangi parol kiritish) | **`Send password reset`** (`POST /drivers/{id}/reset-password`) | D2 bilan bir xil sabab | `tz.md` qaror 21 |
| D7 | Dashboard: 4 KPI karta (`Total Drivers`, `Total Units`, `Disconnected ELD`, `Violations`) | **9 karta**, nomlari `Active Drivers` / `Active Units` | Backend `kpi` obyektida 9 maydon; TZ §20 oltita karta talab qiladi | backend + `tz.md` §20, F80 |
| D8 | `Disconnected ELD` kartasi ostidagi chiziq **yashil** | **Neutral; qiymat > 0 bo'lsa qizil** | Uzilgan qurilma — muammo, yashil noto'g'ri signal | frontend, F81 |
| D9 | Dashboard `Ongoing` marshrut — **qizil** fon | **Sariq (warning)** | Davom etayotgan marshrut xato emas; qizil `not_completed` uchun | frontend, F43 |
| D10 | `Last Known Location` = `48.8566, 2.3522, 30` (uchinchi son noma'lum) | **`<manzil matni> · lat, lng`**; uchinchi son (GPS aniqligi) ko'rsatilmaydi | Backend aniqlik maydonini bermaydi; manzil matni foydaliroq | backend, F95 |
| D11 | `IFTA Report`, `FMCSA Report`, `US DOT` labellari | **`regulation_profile` ga bog'liq**: `generic` → `Distance by Region`, `Regulator Export`, `Registration No` | Bozor Pokiston/O'zbekiston; AQSh domeni faqat `us_fmcsa` da | `tz.md` Q0.2, F122/F125 |
| D12 | «Reports will be ready by the fifth day of each month» | **Olib tashlanadi** — hisobot darhol tayyor | Kunlik agregat jadvali (`unit_region_distance_daily`) | `tz.md` §14, F123 |
| D13 | Maintenance invoice — «faqat PDF» | **PDF / JPG / PNG ≤ 10 MB** | TZ cheklovlari | `tz.md` §18.3, F111 |
| D14 | Maintenance `Alert Type`, `Delivery Method` ro'yxatlari berilmagan | `maintenance_upcoming` / `maintenance_overdue`; `push · email · sms · in_app` | Backend `alert_type` enum'i va TZ Q89 | backend, F110 |
| D15 | Bo'sh holat va «filtr natijasi bo'sh» bir xil | **Ajratiladi** (ikki xil matn + `Clear filters`) | Foydalanuvchi filtr sababli bo'shligini bilishi kerak | frontend, F69 |
| D16 | Yuklanish holati **hech qayerda ko'rsatilmagan** | Skeleton / overlay / spinner tizimi (§6.6) | Dizayn bo'shlig'i; 500 ms kechikish bilan miltillash oldini olish | frontend, F70 |
| D17 | Umumiy xato ekrani yo'q | 3 darajali xato tizimi (§6.7) | Dizayn bo'shlig'i | frontend, F72 |
| D18 | Ustun tanlash faqat Unit va Driver'da | **Barcha ro'yxatlarda** | Bir xil pattern; `localStorage` da saqlanadi | frontend, §6.1 |
| D19 | Company history: 3 mustaqil qidiruv (`Driver`, `Dispatcher`, `Unit`) | **`user` + `table` filtrlari** | Backend `audit-log` filtrlari shunday; `Dispatcher` faqat shu ekranda uchraydi | backend, F149 |
| D20 | Settings › Password: eski parol so'ralmaydi | **`Current password *` qo'shiladi** | O'g'irlangan sessiyada parol almashtirishning oldini oladi | frontend, F151 |
| D21 | Route `Run Trip` tugmasi | **`Create route`** | Amal marshrut yaratadi (`POST /routes`), «yugurtirmaydi» | backend, §7.4.3(d) |
| D22 | «Violations can be removed after completion of second qualify break» | «A `break_required` violation is resolved after a qualifying break; drive and shift violations after a daily rest.» | Violation **o'chmaydi**, `resolved_at` bilan yopiladi | `tz.md` Q58, F96 |
| D23 | Tasdiq matni «inactive the unit» | «**deactivate** the unit» | Grammatika | frontend, F66 |
| D24 | Logs ekranlarida `Export Drivers` / `Import Drivers` tugmalari | **Olib tashlanadi**; o'rniga `Export` (`export-jobs`) | Log ekranida haydovchi import qilish ma'nosiz — nusxalash xatosi | frontend, F96 |
| D25 | `Log By Driver` sarlavhasi | **`Logs By Driver`** | `Logs By Unit` bilan parallel | frontend, F97 |
| D26 | **TZ §4.1: «105 permission kaliti»** (dizaynda emas — TZ matnida) | **104 kalit**, 28 guruh | Backend yakuniy tozalashda 4 ta o'lik kalitni olib tashladi (`tracking.read`, `tracking.history`, `trips.read`, `support.update`) va `drivers.license.view` ni qo'shdi. Haqiqat manbai — `swagger.json` dagi `x-permission`, hujjat: `docs/api/permissions.md`; drift `admin/src/lib/permissions.catalog.test.ts` bilan majburlanadi | backend swagger, D-f7 |

---

# 17. Ochiq savollar

## 17.1 Dizayn inventarining 16 «aniqlanmagan nuqtasi» — holati

| № | Savol | Holat | Javob / manba |
|---|---|---|---|
| 1 | HOS formulalari; `65:00` yoki `70:00` | ✅ **Hal qilingan** | `hos_policy.cycle_limit_min` default **4200 (70:00)**; `65:00` — dizayn placeholderi. UI raqamni hardcode qilmaydi (`tz.md` §4.2, F98) |
| 2 | `Recap` qanday hisoblanadi | ✅ | `recap[d] = cycle_limit − Σ(ON+DR, oxirgi cycle_days)`; backend `hos-summary.recap[]` beradi (`tz.md` Q10.7) |
| 3 | Sertifikatsiya oynasi 8 yoki 11 kun | ✅ | **8 kun** (`tz.md` Q19) |
| 4 | `Not Ready` sharti | ✅ | **Faqat imzo yo'q**; trailer/doc bo'sh — Warning (`tz.md` Q25) |
| 5 | Harakat chegarasi va manbasi | ✅ | ECM ≥ `motion_threshold_kmh` (default **8 km/h**); ECM yo'q bo'lsa GPS fallback (`tz.md` Q5) |
| 6 | Harakatsizlik so'roviga `No` / javobsizlik | ✅ | `No` yoki 1 daqiqa javobsizlik → `ON` (`tz.md` Q6) |
| 7 | Joylashuv aniqligi chegarasi | ✅ | **> 150 m** → «location might be inaccurate» (`tz.md` Q9) |
| 8 | Warning qachon Violation'ga aylanadi | ✅ | `tz.md` Q57 jadvali + `hos_policy.warning_thresholds` |
| 9 | DVIR holat o'tishlari; `Certified` kimga tegishli | ✅ | Holat mashinasi `tz.md` §7.2; `certify` — Service Manager (`dvir.certify`) |
| 10 | Route `Ongoing → Completed` | ✅ | **Avtomatik**: geofence (default 300 m) ichida ≥ 2 daqiqa (`tz.md` Q66–68). Qo'lda faqat `not_completed` |
| 11 | Inactive unit/driver'ning loglari | ✅ | Loglar/DVIR **o'chmaydi**; `include_inactive` filtri bilan ko'rinadi (`tz.md` Q3) |
| 12 | Rolli ruxsatlar ro'yxatining haqiqiy mazmuni | ✅ | **105 kalit** — `backend/internal/auth/permissions.go` + `GET /permissions` (F90) |
| 13 | ELD qurilma modellari ro'yxati (`Choose ELD Type`) | ❓ **Ochiq** | `tz.md` qaror 27: qurilma modeli tanlanmagan (⏸). UI'da `ELD` maydoni — `GET /eld-devices` dan ro'yxatga aylantirildi (model qattiq ro'yxat emas) |
| 14 | `Alert Type` va `Delivery Method` variantlari | ✅ | `maintenance_upcoming`/`maintenance_overdue`; `push · email · sms · in_app` (F110) |
| 15 | Sana/vaqt formati (6 xil variant) | ✅ | **2 format**, `regulation_profile` ga bog'liq (§12.2) |
| 16 | Export/Import fayl formatlari | ✅ | Import: `csv`, `xlsx`. Eksport: `csv`, `xlsx`, `pdf`, `zip` (§11.3) |

**Natija: 16 dan 15 tasi hal qilindi**, 1 tasi (№13) backend qaroriga bog'liq va ochiq qoladi.

## 17.2 Yangi ochiq savollar

### Buyurtmachi tasdig'i kerak (❓)

| № | Savol | Nima uchun muhim | Taklif |
|---|---|---|---|
| ~~Q1~~ | ~~**Xarita tile provayderi**~~ | — | ✅ **YOPILDI 2026-09-07** — qaror quyida (D-Q1) |
| Q2 | **Product Sans litsenziyasi** | Display darajasida ishlatiladi; litsenziya bo'lmasa huquqiy risk | Fallback: IBM Plex Sans 700 (vizual farq minimal) |
| Q3 | **Privacy Policy / Terms of Use matni** (`tz.md` qaror 28) | Footer havolalari; hozircha begona («Jusoor») matn | Matn kelmaguncha havolalar ko'rsatilmaydi |
| Q4 | **Admin panelda dark tema kerakmi** | MVP'da yo'q (F53); keyingi bosqichda 50+ ekran uchun dizayn kerak | Mobil/planshet dark palitrasi mavjud — web uchun moslashtirish 🎨 |
| Q5 | **Kompaniya logotipi va brend elementlari** | `Company Logo` maydoni bor, lekin panel brendi (logotip fayli) yo'q | 🎨 SVG logotip + favicon to'plami |
| Q6 | **Bo'sh holat illyustratsiyasi** | Dizaynda «illyustratsiya» deb yozilgan, fayl yo'q | 🎨 1 ta universal SVG |
| Q14 | **Swagger `DOCS_TOKEN`** — `GET /api/docs/swagger.json` bearer token talab qiladi (tokensiz `401 UNAUTHORIZED: api docs requires a bearer token`) | Token bo'lmasa `npm run api` ishlamaydi: `src/api/schema.d.ts` placeholder bo'lib qoladi, `src/api/types.ts` domen alias'lari `unknown` ga yechiladi va API chaqiruvlari tip xavfsizligisiz qoladi. **Bosqich 0.7/0.8 ni bloklaydi, keyingi barcha bosqichlarga ta'sir qiladi** | Backend jamoasidan doimiy `DOCS_TOKEN` olinadi va `.env` (dev) hamda CI secret sifatida saqlanadi |

### Backend CR nomzodlari (`v1` muzlatilgan — v1.1 uchun)

| № | Bo'shliq | Ta'siri | MVP vaqtinchalik yechimi |
|---|---|---|---|
| Q7 | `GET /users/export` yo'q | Dizayndagi `Export Users` tugmasi ishlamaydi | Tugma olib tashlanadi (N16) |
| Q8 | `GET /logs/by-unit?date=` yo'q | «Bir kun × barcha unitlar × HOS» ekrani N+1 so'rov talab qiladi | `GET /tracking/live` + sahifadagi haydovchilar uchun `hos-summary` (parallel ≤ 6), HOS ustunlari default'da yashirin (F95) |
| Q9 | Global qidiruv endpointi yo'q | Header'dagi qidiruv | `GET /drivers?search=` + `GET /units?search=` parallel (F40) |
| Q10 | WS `auth` freymida `company_id` yo'q | Super Admin tenant rejimida real-vaqt ishlamaydi | Super Admin rejimida WS o'chiriladi, 60 s polling (F155) |
| Q11 | Route status enum'i ikki xil (`dashboard_dto` vs `routes_dto`) | Tip xavfsizligi | Normalizator: `planned\|in_progress → ongoing` (F119) |
| Q12 | `GET /tracking/live` da bbox filtri yo'q | Katta parkda barcha unitlar bir marta yuklanadi | Klasterlash + klient tomonda filtrlash (F167/F168) |
| Q13 | Chat: fayl biriktirish uchun `kind=chat` presign bor, lekin xabar DTO'sida `file_key` bitta | Bir xabarga bir fayl | Bir xabar = bir fayl (F132) |
| Q15 | `per_page` spec'da `enum` emas — oddiy `integer` (tavsifda faqat «max 100» yoki «10/25/50» matni), amalda 10/25/50 dan boshqa qiymat **422** qaytaradi | Frontend cheklovni faqat tip darajasida (`PerPage` union) majburlaydi; spec'dan generatsiya qilingan tip bu qoidani ko'rsatmaydi, boshqa klient (mobil, uchinchi tomon) buni bilmasdan noto'g'ri qiymat yuborishi mumkin | `per_page: {type: integer, enum: [10, 25, 50]}` spec'ga qo'shilsin |
| Q16 | Login rate limit (5 so'rov/daqiqa/IP, `POST /auth/login` → `429`) spec'da hujjatlashtirilmagan — faqat amaliy tekshiruv orqali ma'lum | E2E/dev muhitida kutilmagan `429` sabab tushunarsiz bo'lib qolishi mumkin; frontend chegarani spec'dan emas, tajribadan bilib qo'llaydi (fe-api §1) | `POST /auth/login` operatsiyasiga `x-rate-limit: 5/min/ip` (yoki tengdosh) izoh/annotatsiya qo'shilsin |
| Q18 | Uncertified Logs (7.8.5) `Send reminder` amali uchun endpoint swagger'da yo'q (`/notifications` faqat `GET`+`read`, `POST` yo'q) | Ekranda tugma bo'ladi, lekin chaqiradigan API yo'q | Bosqich 6.1: `useUncertifiedLogSendReminder` yozilmadi, tugma `disabled` + tooltip «Coming soon» rejimida qoldiriladi (ekran agentiga topshiriq); to'liq yozuv D29 da |

### Frontend ichki qarorlar (tasdiq talab qilmaydi, lekin qayd etiladi)

| № | Qaror |
|---|---|
| D-f1 | Refresh token `sessionStorage` da — backend httpOnly cookie bermagani uchun (F14). Backend CR bilan o'zgaradi |
| D-f2 | Minimal kenglik 1280 px; mobil/planshet web admin qo'llab-quvvatlanmaydi (F77) |
| D-f3 | Ikonka nabori — `lucide-react` (F50) |
| D-f4 | Radius shkalasi 4/8/12/16 — dizaynda berilmagan (F49) |
| D-f5 | Spacing shkalasi 4 pt — dizaynda berilmagan (F47) |
| D-f6 | Vaqt Company Home Terminal TZ da ko'rsatiladi, brauzer TZ da emas (F193) |
| D-f7 | ✅ **YOPILDI** (2026-09-07) — `PERM` endi taxminiy emas: 104 haqiqiy kalit `admin/openapi/swagger.json` dagi `x-permission` dan olindi (`docs/api/permissions.md`). Tafsilot: «Yopilgan qarorlar → D-f7» |
| D-f8 | `super_admin` — rol ham, permission kaliti ham emas: alohida bayroq. Katalogda `companies.*` kaliti **yo'q** — `x-permission: super_admin` bo'lgan 4 ta `/companies*` operatsiyasi faqat shu bayroq bilan ochiladi (`can.isSuperAdmin`), boshqa modullarni **kengaytirmaydi** |
| D-f9 | Routes (`/routes`) nav'da alohida element emas — Tracking/Dashboard ekranlaridan ochiladi (fe-permissions §6 «nav tashqarisidagi ekranlar») |
| D-f10 | `/2fa/verify` oqimi (0.11, TZ §7.1.2): `LoginResult` da faqat `requires_totp_setup` bor — allaqachon yoqilgan 2FA hisobi uchun alohida bayroq yo'q. `LoginRequest.totp_code` tavsifi «required once two factor authentication is enabled» deb yozilgan, ya'ni backend buni `login` chaqiruvining o'zida (ehtimol `VALIDATION_ERROR`, `details:[{field:"totp_code"}]`) bildiradi. Frontend shu farazga tayanib qurilgan: `/login` bu xatoni ko'rsa, login so'rovini (login+parol, navigatsiya `state`da, URL'da emas) `/2fa/verify` ga uzatadi va u yerda kod bilan qayta yuboradi. Spec bu oqimni aniq hujjatlashtirmagan — tasdiqlanishi kerak (`Q16` bilan bir xil bo'limda kuzatiladi) |

---



---

## Yopilgan qarorlar (frontend)

### D-Q1 — Xarita tile provayderi ✅ (2026-09-07, buyurtmachi tasdig'i bilan)

**Qaror: MVP uchun MapTiler Cloud; o'sish/xarajat bosimida chiqish yo'li — Protomaps (PMTiles) self-hosting.**

**Asos:**
- Ikkalasi ham bir xil abstraksiya — MapLibre **style JSON**. Ko'chish = `VITE_MAP_STYLE_URL` + CSP hostini almashtirish. **Kod o'zgarmaydi.**
- MapTiler kaliti **domen bo'yicha cheklanadi** → F9 (bundle'da ochiq maxfiy kalit bo'lmasligi) bajariladi.
- Mapbox **rad etildi**: GL JS v2+ litsenziyasi tile'larini MapLibre bilan ishlatishni taqiqlaydi, TZ §2.1 esa MapLibre'ni muzlatgan.
- Google Maps **rad etildi**: vector tile / style JSON bermaydi.
- Self-hosted OpenMapTiles/TileServer GL **rad etildi**: PMTiles bilan bir xil foyda, ammo doimiy server + DevOps yuki.

**Amalga oshirish shartlari (4-bosqichgacha):**

| № | Nima | Kim |
|---|---|---|
| 1 | MapTiler hisobi + **domen bo'yicha cheklangan** kalit (`eldadmin.stackyard.uz`, dev uchun `localhost`) | buyurtmachi / DevOps |
| 2 | `VITE_MAP_STYLE_URL` = style JSON URL (kalit URL ichida — shuning uchun domen cheklovi **majburiy**) | fe-architect |
| 3 | CSP (§13): `connect-src` va `img-src` ga `https://api.maptiler.com` qo'shiladi | frontend-security-reviewer |
| 4 | Style tanlovi: kam kontrastli **basic / dataviz** oilasi (satellite yoki streets emas) — 500 ta duty-status markeri ustidan o'qilishi kerak | map-engineer |
| 5 | Chiqish yo'li hujjatlashtiriladi: Shimoliy Amerika PMTiles (~8-15 GB) statik hostingda, `pmtiles://` protokoli | map-engineer (9-bosqichda README) |

**Ochiq qolgan kichik nuqta:** MapTiler tarif rejasi (free 100k tile/oy → paid) — haqiqiy trafik 4-bosqich performans o'lchovidan keyin aniqlanadi.

---

### D-f7 — Permission katalogi: taxminiy kalitlar → haqiqiy 104 ✅ (2026-09-07)

**Qaror: `admin/src/lib/permissions.ts` dagi `PERM` — `admin/openapi/swagger.json` dagi
`x-permission` maydonlaridan olingan 104 ta haqiqiy kalit (28 guruh). Taxminiy 90 kalit
butunlay almashtirildi.**

- **Manba (haqiqat):** `swagger.json` → `x-permission`; o'qish uchun jadval — **`docs/api/permissions.md`**
  (`GET /permissions` ish vaqtida shu ro'yxatni beradi).
- **TZ §4.1 dagi «105» — xato** (§16.5 D26 qatori). To'g'ri son — **104**: backend 4 ta o'lik kalitni
  olib tashladi (`tracking.read`, `tracking.history`, `trips.read`, `support.update`) va
  `drivers.license.view` ni qo'shdi.
- **Uchta maxsus qiymat permission emas** va `PERM` da yo'q: `public` (6 operatsiya),
  `authenticated` (7), `super_admin` (4 — alohida bayroq, F33, faqat `/companies*`).
- **Majburlash:** `admin/src/lib/permissions.catalog.test.ts` (0.17) swagger va `PERM` ni ikki
  tomonlama solishtiradi (har ikki yo'nalishda 0 farq) va sonni 104 deb tasdiqlaydi. Drift bo'lsa
  CI qizil bo'ladi va **backend ustun** — `PERM` yangilanadi.
- **OR mantiq istisnolari** (swaggo OR sintaksisiga ega emas; testda alohida ro'yxat):
  `GET /unidentified-events` → `logs.assign_unidentified` **yoki** `logs.read`;
  `GET /permissions` → `permissions.read` **yoki** `roles.read`. UI bu ekranlarda `can.any([...])` ishlatadi.
- **Marshrut prefiksi ≠ kalit** tuzoqlari (`company.history.view`, `users.update` ↔ activate/deactivate,
  `logs.export`, `support.update_status`, …) — `.claude/skills/fe-permissions/SKILL.md` §1.1 da.


### D27 — `regulation_profile`: nom va qiymatlar soni (2026-09-07, swagger'dan)

| Nima | TZ da | Backend'da (haqiqat) |
|---|---|---|
| Kalit nomi | `fmcsa_us` | **`us_fmcsa`** |
| Qiymatlar soni | 2 (`generic`, `fmcsa_us`) | **7** |
| To'liq ro'yxat | — | `us_fmcsa`, `generic`, `canada`, `texas`, `california`, `alaska`, `hawaii` |

**Manba:** `openapi3.json` → `company_dto.Company.regulation_profile` (va yana 7 ta DTO da bir xil).

**Oqibati (F1 — backend ustun):**
- Formatlash **ikki guruhga** yig'iladi: `us_fmcsa` → US shabloni; qolgan **oltitasi** → generic shabloni.
  `lib/format.ts` dagi `resolveDateFormatProfile()` shu ishni bajaradi.
- Ekran nomlari almashinuvi (F122 `IFTA Report`, F125 `FMCSA Report`, `US DOT` label) faqat `us_fmcsa` da.
- **Settings › Company** dagi `Regulation profile` select'i **yettita** qiymatni ko'rsatishi kerak
  (TZ §7.13.1 ikkitasini yozgan — eskirgan).
- 6-bosqich testlari «ikkala profil» emas, **kamida `us_fmcsa` + bitta generic-guruh** profilini qamrasin.

Tuzatildi: `.claude/skills/{fe-design-system,fe-testing}`, `docs/tz/07-8-reports.md`,
`docs/tz/07-13-settings-admin.md`, shu reestr.

### D-f9 — Users/Roles: bitta-element `GET` yo'q; import `422` konvert nomuvofiqligi (2026-09-07, Bosqich 2.1)

**1. `GET /users/{id}` va `GET /roles/{id}` swagger'da yo'q.**

- `users` uchun faqat `GET /users` (ro'yxat), `PATCH/DELETE /users/{id}`, `POST /users/{id}/
  activate|deactivate|resend-invitation|reset-password` bor. `roles` uchun faqat `GET /roles`
  (ro'yxat), `POST /roles`, `PATCH/DELETE /roles/{id}` bor.
- **MVP yechimi (frontend):** `src/api/queries/users.ts`ning `useUser(id)` va
  `src/api/queries/roles.ts`ning `useRole(id)` tarmoqqa so'rov yubormaydi — `['users','list',*]`/
  `['roles','list',*]` TanStack Query keshidan `id` bo'yicha qidiradi. Ro'yxat sahifasidan
  o'tilganda ishlaydi (kesh to'ldirilgan bo'ladi); to'g'ridan-to'g'ri havola bilan (deep link,
  sahifa yangilash) kirilganda kesh bo'sh bo'lishi mumkin va hook `undefined` qaytaradi — View/Edit
  ekrani bu holatni ro'yxatga qaytarish yoki ro'yxatni oldindan yuklash bilan hal qilishi kerak.
- **Tavsiya (CR):** backend `GET /users/{id}` va `GET /roles/{id}` qo'shsa (yoki mavjud DTO'da
  `id` orqali `PATCH` javobini takroriy ishlatib bo'lmaydi — chunki View ekran `PATCH`
  chaqirmasdan ochiladi), View/Edit ekranlari kesh holatiga bog'liq bo'lishdan xalos bo'ladi.

**2. `POST /units/import` va `POST /drivers/import` — `422` javobi umumiy xato konvertini buzadi.
✅ Hal qilindi (2026-09-07, `fe-architect`).**

- Spec: muvaffaqiyatli holatda ham, `422` (all-or-nothing, F83) holatida ham javob bir xil shaklda —
  `ImportResultEnvelope` (`{data:{imported,total,errors[{row,field,message}]}}`). Bu boshqa barcha
  endpointlardagi xato konvertidan (`{error:{code,message,details}}`) farq qiladi.
- **Yechim:** `src/api/client.ts`dagi `errorMiddleware` ro'yxat/predikat asosida ishlaydi —
  `STRUCTURED_ERROR_RESPONSE_PATHS` (`/units/import`, `/drivers/import`) ga mos so'rov uchun butun
  JSON tanani `ApiError.payload`ga saqlaydi (standart `code`/`status`/`message` normalizatsiyasi
  baribir ishlaydi, faqat `fields` bo'sh qoladi). Boshqa endpointlar uchun `errorMiddleware`
  o'zgarmadi (regressiya testi bilan tasdiqlangan). `ApiError`ga yangi `readonly payload?: unknown`
  maydoni qo'shildi.
- `src/api/queries/units.ts`ning `useUnitsImport()` va `drivers.ts`ning `useDriversImport()` `422`ni
  `catch` qilib, `ApiError.payload`dan generatsiya qilingan `ImportResult` tipini (`@/api/types`,
  `schema.d.ts`dan) o'qiydi va uni **muvaffaqiyat natijasi** sifatida qaytaradi — ekran faqat
  `result.errors.length`ga qarab jadval yoki muvaffaqiyat holatini ko'rsatadi:
  ```ts
  const { mutate, data } = useUnitsImport();
  // data?.errors?.length ? <ImportErrorTable errors={data.errors} /> : <SuccessToast />
  ```
- Kengaytiriladi: keyingi bosqichda shunga o'xshash "structured error" endpoint chiqsa,
  `STRUCTURED_ERROR_RESPONSE_PATHS`ga bitta predikat qo'shiladi — qattiq kodlangan
  `if (url === ...)` yo'q.
- MSW handlerlari (`unitsImportValidationErrorHandler`, `driversImportValidationErrorHandler`) ikkita
  qator xatosi bilan yangilandi; `src/api/client.test.ts` (yangi) + `units.test.ts`/`drivers.test.ts`
  `useUnitsImport`/`useDriversImport` bloklarida to'liq qamrov bor.


### Q17 — `POST /unidentified-events/{id}/assign` swagger'da buzuq (backend CR nomzodi)

**Muammo:** endpoint ikkita `in: body` parametrini e'lon qiladi (`id` va haqiqiy tana).
`swagger2openapi` ularni bitta `requestBody` ga yig'adi va **`{id}` path parametrini jim tashlab yuboradi**.

**Dalil:** `openapi3.json` da `x-s2o-warning: "... has multiple requestBodies"`;
`schema.d.ts` da `path: never`, `requestBody: string`.

**Vaqtinchalik yechim (frontend):** `api/queries/unidentified.ts` da hujjatlashtirilgan
`as unknown as <shape>` tip kasti — `units.ts` dagi import multipart nomuvofiqligi uchun
ishlatilgan naqshning aynan o'zi. `openapi-fetch` manbasida tasdiqlangan: `params.path`
almashinuvi ish vaqtida TS tipidan **mustaqil** bajariladi, ya'ni yechim funksional
jihatdan to'g'ri, shunchaki tipni bosish emas.

**Backend CR taklifi:** `id` ni `in: path` deb e'lon qilish (swaggo annotatsiyasi),
shunda generator to'g'ri tip beradi va kast olib tashlanadi.

---

### D28 — `POST /daily-logs/{id}/events` admin amali EMAS

Swagger tavsifi bu endpointni **haydovchining o'z tuzatishi** deb belgilaydi.
Admin panel undan **foydalanmaydi** (§1.1, Q26/Q31 — admin hech qachon haydovchi
nomidan log yozmaydi). Admin ekranlari **faqat** `useLogEditRequestPropose`
(taklif → haydovchi tasdig'i) orqali ishlaydi — F100.

`useLogAddEvent` hooki yozilgan, lekin izohida shu ogohlantirish bor.
Ekran agentlari uni **chaqirmasligi** kerak.

---

### D29 — Uncertified Logs `Send reminder` uchun backend endpoint yo'q (Bosqich 6.1, swagger'dan)

`docs/tz/07-8-reports.md` §7.8.5 (F128) Uncertified Logs jadvalida `Send reminder` amalini
talab qiladi. Swagger'da (`/notifications`, `/company/notification-settings`,
`/daily-logs/{id}/certify`, `/dvir-reports/{id}/certify`) shu maqsadga mos **hech qanday**
`POST` yo'q — `notifications` resursi faqat `GET` (ro'yxat) va o'qilgan deb belgilash
(`/notifications/{id}/read`, `/notifications/read-all`) operatsiyalarini beradi, admin
tomonidan **yangi** bildirishnoma/eslatma yaratish endpointi mavjud emas.

**MVP vaqtinchalik yechimi (Bosqich 6.1, `api/queries/reports.ts`):** `useUncertifiedLogSendReminder`
mutatsiyasi **yozilmadi** — mavjud bo'lmagan endpointga so'rov yubormaydi. Ekran agentiga
(keyingi bosqich) topshiriq: `Send reminder` tugmasi `disabled` holatda, tooltip
«Reminders are not available yet» (yoki tegishli i18n kaliti) bilan ko'rsatiladi.

**Backend CR taklifi:** `POST /reports/uncertified-logs/{driver_id}/remind` (yoki
`POST /notifications` umumiy yaratish endpointi) — kompaniya `notification-settings`dagi
kanal(lar) orqali haydovchiga eslatma yuboradi, javobda `sent_at` qaytaradi.


### D30 — DVIR `repair`: mexanik imzosi majburiy, lekin admin panelda uni olish oqimi yo'q

**Swagger:** `POST /dvir-reports/{id}/repair` tanasida `mechanic_note` **va**
`mechanic_signature_key` — **ikkalasi ham majburiy**.

**TZ (§7.5, 5.4):** faqat «izoh + invoice fayl» deb yozgan; mexanik imzosi haqida gap yo'q.

**Muammo:** admin panel imzo **olmaydi** (§1.1 — admin hech kim nomidan imzo qo'ymaydi).
Mexanik imzosi mobil/planshet ilovasida olinadi va obyekt-saqlashga yoziladi.
Ya'ni admin `Record repair` amalini **imzosiz bajara olmaydi**.

**MVP yechimi (frontend):** `Record repair` formasi `mechanic_signature_key` ni
**majburiy maydon** sifatida ko'rsatmaydi va amalni **bloklaydi** emas — buning o'rniga:
- Agar DVIR'da allaqachon `mechanic_signature_key` bo'lsa (mobilda olingan) — amal ishlaydi
- Aks holda tugma `disabled` + sabab: «Mechanic signature required — captured in the driver app»

**Backend CR nomzodi:** `mechanic_signature_key` ni ixtiyoriy qilish yoki
admin uchun alohida «office repair record» oqimi (imzosiz) qo'shish.
