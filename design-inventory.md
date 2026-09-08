# ONEBOOK ELD — Dizayn inventari

**Manba:** `ELD-Prezentatsiya.pdf` (144 bet, 960×540 pt slaydlar, Skia/PDF, 2026-08-05)
**Prezentatsiya sarlavhasi:** «ELD Software — batafsil prezentatsiya»
**Asl dizayn manbasi:** Figma «ELD Software (Copy)» · fayl kaliti `NLDjNYebjCuNswunequFv2`

> Ushbu inventar prezentatsiyaning **matn qatlamidan** (to'liq, so'zma-so'z) va slaydlarga
> joylangan **render rasmlarining o'lchamlaridan** (platformani aniqlash uchun) tuzilgan.
> Prezentatsiyaning o'zi ham Figma dizaynining tahlili, shuning uchun ba'zi joylarda
> «dizaynda aniqlanmagan» degan izohlar bor — ular shundayligicha ko'chirildi.

**Platformani aniqlash usuli:** har slaydga joylangan render rasm o'lchami:
`1440×…` yoki `1400×…` → **web admin panel (1440 px)**; `393×85x` → **mobil telefon (393×852/854)**;
`1366×1024` / `1350×1012` → **planshet (1366×1024)**.

---

## I. Kirish (bet 1–6)

### Bet 1 — Muqova
- **Platforma:** —(slayd muqovasi)
- Sarlavha: `ONEBOOK ELD` / `ELD Software`
- Kichik sarlavha: «Elektron log qurilmasi tizimi — Figma dizaynining to'liq tahlili»
- KPI raqamlari: `3` klient ilova · `180+` ekran · `158` renderlangan ekran · `2` tema
- Manba satri: «Manba: Figma ELD Software (Copy) · NLDjNYebjCuNswunequFv2 · 2026-08-05 · batafsil versiya»

### Bet 2 — Mundarija («USHBU HUJJATDA»)
Sakkiz bo'lim:
| # | Bo'lim | Izoh |
|---|---|---|
| I | Kirish | Metodologiya · fayl tuzilishi · qatlamlar holati |
| II | Dizayn tizimi | Ranglar · tipografika · grid · effektlar |
| III | Admin Panel | Karkas va 19 seksiya — har bir jadval, forma, modal |
| IV | Mobil ilova | Kirishdan huquqiy sahifalargacha |
| V | Planshet ilovasi | Yagona boshqaruv ekrani va barcha modallar |
| VI | Dark tema | Mobil va planshet |
| VII | Ma'lumot lug'ati | Statuslar · maydonlar · cheklovlar · nuqson ro'yxatlari |
| VIII | Yakun | Nomuvofiqliklar · aniqlanmagan nuqtalar · registr |

Izoh: har slaydda ekranning Figma tugun id'si ko'rsatilgan (masalan `123:1207`).

### Bet 3 — Metodologiya
- **Kiritilgan:** ko'rinadigan qatlamlardagi ekranlar; ekran matnlari so'zma-so'z (imlo xatolari bilan); Figma uslublari (paint/text/grid/effect); ekran holatlaridan kelib chiqadigan oqim va qoidalar; har tugunning id va o'lchami.
- **Kiritilmagan:** yashirilgan qatlamlar (eskirgan iteratsiyalar); begona shablonlar (TailAdmin, Car Rental, proytecto-MC); texnologiya/arxitektura takliflari; me'yoriy hujjat talqinlari; dizaynda yo'q taxminlar.
- **Qanday olingan:** Figma Desktop Bridge (plugin) · `loadAllPagesAsync()` · matnlar koordinata bo'yicha saralangan · rasmlar `exportAsync` · audit izi `.figma-cache/`.

### Bet 4 — Figma fayl tuzilishi (10 sahifa)
**Jadval ustunlari:** `SAHIFA` · `ID` · `YUQORI DARAJA` · `MAZMUNI` · `HOLAT`

| SAHIFA | ID | YUQORI DARAJA | MAZMUNI | HOLAT |
|---|---|---|---|---|
| Cover | 0:1 | 2 FRAME | Muqova, «180 + screens» | ishchi |
| Branding & Color | 14:2 | 3 SECTION | Color · Typography · Grid | manba |
| Admin Panel | 14:5 | 24 element | 19 ko'rinadigan seksiya + 2 yashirilgan freym | manba |
| Mobile Application | 14:6 | 5 SECTION | Light + 2× Dark tema, 1 yashirilgan | manba |
| Tablet Application | 14:7 | 7 element | Light + Dark tema, 5 yashirilgan | manba |
| -- | 14:8 | 3 FRAME | proytecto-MC.com MVP skrinshotlari | begona |
| -- | 14:9 | 1 TEXT | #1E1E1E matni | chiqindi |
| -- | 14:4 | 5 element | «Universal ELD» — avvalgi admin iteratsiyasi | eskirgan |
| -- | 14:10 | 1 SECTION | TailAdmin V2.0 PRO shabloni | begona |
| -- | 14:3 | 0 | bo'sh | — |

### Bet 5 — Qatlamlar holati (amaldagi vs eskirgan)
**Jadval ustunlari:** `QATLAM` · `ID` · `HOLAT` · `FARQI`

| QATLAM | ID | HOLAT | FARQI |
|---|---|---|---|
| Admin › Maintainance | 268:30430 | yashirilgan | 4 tab: Schedule / Upcoming / Verification / History |
| Admin › Maintainance | 1225:5291 | amaldagi | 3 tab: Schedule / Due / History |
| Admin › Subscription ×2 | 498:3772 · 498:4353 | yashirilgan | Obuna moduli qamrovda yo'q |
| Mobile › Mobile Application | 1206:9697 | yashirilgan | DOT Report nomi, Maintenance ekranlari |
| Mobile › Light Theme | 1070:6813 | amaldagi | Inspection Report nomi, Maintenance yo'q |
| Mobile › Dark Theme ×2 | 2665:25648 · 3497:433 | amaldagi | Light temaning nusxasi |
| Tablet › Section 3 / Home / Section 1 | 1495:43530 va boshq. | yashirilgan | Eski nav: Home · Change Status · Log Report · Message · Options |
| Tablet › Light / Dark Theme | 1470:21013 · 2197:104566 | amaldagi | Duty Status / Actions panelli |

Muhim: **mobil Maintenance moduli bu bosqichda yo'q** — ekranlar `Not part of this phase` (`2627:25743`) freymi ichida; joriy Profile menyusida Maintenance bandi yo'q.

### Bet 6 — Mahsulot tarkibi (uch klient, umumiy backend)
| Klient | O'lcham / tema | Tafsilot |
|---|---|---|
| **VEB — Admin Panel** | 1440 px · faqat light tema | 19 seksiya, 130 ekran-daraja tugun · ofis xodimi uchun · rol asosida ruxsat (`Roles & Permissions`) · **yuqori navigatsiya, sidebar yo'q** |
| **TELEFON — Mobil ilova** | 393 × 852 / 854 px · light + dark | 73 ekran (light), 63 (dark) · haydovchi uchun · **ro'yxatdan o'tish yo'q** · bosh ekranning ikki tartibi mavjud |
| **PLANSHET — Planshet ilovasi** | 1366 × 1024 px · light + dark | 52 ekran (light), 51 (dark) · kabinada o'rnatilgan · yagona boshqaruv ekrani + modallar · mobil bilan bir xil oqimlar |

Uch klientning login ekranida bir xil matn: «This app does not support account registration. Please reach out to your fleet manager for assistance.»

Dizaynda uchraydigan **rol nomlari:** `Service Manager` · `Operations Manager` · `Sub Admin` · `Administrator` · `Data Analyst` · `Safety Manager` · `Fleet Manager`.

---

## II. Dizayn tizimi (bet 7–11)

> To'liq dizayn tizimi bo'limi fayl oxirida ham takrorlangan («Dizayn tizimi» bo'limi).

### Bet 7 — Bo'lim muqovasi «Dizayn tizimi»
Statistika: `40` paint style · `1` effect style · `4` grid style · `0` text style.

### Bet 8 — Ranglar: asosiy va Neutral (`14:147 · COLOR`, render `Color Palette · 14:148`)
**COLOR'S guruhi:**
| Nom | HEX |
|---|---|
| Primary | `#B7002C` |
| Light | `#EFF4FB` |
| Bg Light | `#FCFCFD` |
| Bg Dark | `#1B222C` |
| Sidebar | `#233040` |
| Grey Light | `#F5F5F5` |
| Grey Dark | `#303E4B` |
| Stroke | `#E5E7EB` |
| Dark stroke | `#52565F` |
| GREY | `#F2F4F7` |

**NEUTRAL — 11 pog'ona:** `#FCFCFD` · `#F4F5F6` · `#E6E8EC` · `#D6D8E0` · `#B1B5C3` · `#777E90` · `#3F4352` · `#353945` · `#23262F` · `#1C1E24` · `#18191D`

**Gradientlar:** uch uslub — `L`, `l`, `lll` — barchasi `GRADIENT_LINEAR`; muqovadagi ellipse-gradient instansiyalarida ishlatilgan.

Nuqson: palitra sahifasidagi ba'zi HEX/RGB yozuvlari mos kelmaydi (masalan Warning `#F9B385` yozilgan, RGB esa 246,176,71).

### Bet 9 — Ranglar: holat, diagramma, shaffof (`14:147 · COLOR`)
**STATE COLOR — uch pog'ona** (ustunlar: `HOLAT` · `1 · FON` · `2 · ASOSIY` · `3 · TO'Q`):
| HOLAT | 1 · FON | 2 · ASOSIY | 3 · TO'Q |
|---|---|---|---|
| Success | `#C5EFD8` | `#2FA766` | `#103923` |
| Warning | `#FCEAC8` | `#F6BA47` | `#7B5D24` |
| Error | `#F9DADB` | `#E2464A` | `#5A1C1E` |

**DECORATIVE COLORS — 7 rang:** Pink `#EE4E68` · Teal `#30B0C7` · Green `#47BB75` · Purple `#7E5EF7` · Orange `#F5693D` · Yellow `#F7CB46` · Blue `#466FF7`

**CHART COLORS:** Green `#2FA766` va Red `#E2464A` — Success/Error bilan bir xil (diagrammalar uchun alohida rang yo'q).

**TRANSPARENT COLORS** (ustunlar: `RANG` · `SHAFFOFLIK`): Neutral 10 `#1C1E24` 35 % · Neutral 8 `#353945` 40 % · Red `#E2464A` 30 % · Green `#2FA766` 30 %

**Interfeysda qanday ishlatilgan:**
- Primary — admin header, asosiy tugmalar, faol nav elementi, CYCLE indikatori, sahifalash faol raqami
- Success — `Completed`, `Certified`, `Online`, `Signed` badge'lari, DRIVE indikatori, trailer/document badge'lari
- Warning — `Warning:` satri fon, BREAK indikatori
- Error — `Violation:` satri, `Not Signed`, `Ongoing`, `Not Found`, muddati o'tgan qiymatlar, `Logout`
- Blue `#466FF7` — SHIFT indikatori va log grid chizig'i

### Bet 10 — Tipografika (`14:543 · TYPOGRAPHY`, render `Typography · 14:544`)
Shriftlar: **IBM Plex Sans** (asosiy), **Product Sans** (faqat Display).
| DARAJA | SHRIFT · USLUB | PX |
|---|---|---|
| Display 1 | Product Sans Bold | 48 |
| Display 2 | Product Sans Bold | 40 |
| Heading 1 | IBM Plex Sans Bold | 48 |
| Heading 2 | IBM Plex Sans Bold | 40 |
| Heading 3 | IBM Plex Sans Bold | 32 |
| Heading 4 | IBM Plex Sans Bold | 24 |
| Body 1 | IBM Plex Sans SemiBold | 26 |
| Body 2 | IBM Plex Sans Medium | 26 |
| Body 3 | IBM Plex Sans Bold | 24 |
| Body 4 | IBM Plex Sans Regular | 24 |
| Body 5 | IBM Plex Sans Bold | 20 |
| Body 6 / 7 | IBM Plex Sans Regular | 20 |
| Body 8 | IBM Plex Sans Bold | 18 |
| Body 9 | IBM Plex Sans Medium | 18 |
| Body 10 | IBM Plex Sans Regular | 18 |
| Body 11 | IBM Plex Sans Bold | 16 |
| Body 12 | IBM Plex Sans Medium | 16 |
| Body 13 | IBM Plex Sans Regular | 16 |
| Body 14 | IBM Plex Sans Medium | 14 |
| Body 15 | IBM Plex Sans Regular | 14 |
| Body 16 | IBM Plex Sans Regular | 12 |
| Body 17 | IBM Plex Sans Regular | 10 |

Nuqson: lokal matn uslublari yaratilmagan (0 text style) — shkala komponentlarga biriktirilmagan. Body 6 va Body 7 bir xil (Regular 20) — takror.

### Bet 11 — Grid tizimi va o'lchovlar (`14:652 · GRID`, render `Grid · 14:653`)
**Jadval ustunlari:** `USLUB` · `COUNT` · `TYPE` · `WIDTH` · `OFFSET` · `GUTTER` · `MARGIN`
| USLUB | COUNT | TYPE | WIDTH | OFFSET | GUTTER | MARGIN |
|---|---|---|---|---|---|---|
| Desktop | 12 Column | Center | 80 px | — | 24 px | — |
| Dashboard with Sidebar · sidebar | 1 column | Left | 280 px | 0 px | 20 px | — |
| Dashboard with Sidebar · kontent | 12 Column | Right | 79 px | 24 px | 16 px | — |
| Login | 5 Column | Center | 88 px | — | 16 px | — |
| Sidebar | 4 Column | Stretch | — | — | 12 px | 16 px |

**EFFEKT USLUBI:** `Carts Dropdown` — `DROP_SHADOW`, radius 27.25 (dashboard kartalari va dropdown menyular).
**VARIABLES:** bitta to'plam `Variable collection`, 1 mode (`Mode 1`), 1 o'zgaruvchi — token tizimi qurilmagan.

**EKRAN BALANDLIKLARI** (ustunlar: `KLIENT` · `KENGLIK` · `DIZAYNDA UCHRAYDIGAN BALANDLIKLAR`):
| KLIENT | KENGLIK | BALANDLIKLAR |
|---|---|---|
| Admin | 1440 px | 792 · 907 · 1010 · 1024 · 1047 · 1055 · 1066 · 1123 · 1125 · 1301 · 1829 · 2211 |
| Mobil | 393 px | 851 · 852 · 854 · 874 · 891 · 893 · 1037 · 1152 · 1650 · 1702 |
| Planshet | 1366 px | 936 · 1024 · 1421 |

Nuqson: `Dashboard with Sidebar` gridida sidebar bor, lekin amaldagi Admin Panelda sidebar yo'q — bu grid eskirgan `--` (`14:4`) iteratsiyasiga tegishli.

---

## III. Admin Panel — veb, 1440 px, faqat light tema (bet 12–82)

### Bet 12 — Bo'lim muqovasi «Admin Panel»
`19` seksiya · `130` ekran-daraja tugun · `8` asosiy modul · `4` hisobot turi.

### Bet 13 — Modullar xaritasi
| Modul | Ichki ekranlar |
|---|---|
| Dashboard | KPI · xarita · marshrutlar |
| Tracking | Ro'yxat · xarita · diagnostika |
| Logs | Logs By Unit · Logs By Driver · + Log view (3 tab) |
| Fleet Operations | Unit Management · Driver Management · Users · Roles & Permissions |
| Maintenance | Schedule · Due · History |
| Reports | FMCSA Report · IFTA Report · DVIR Report · Activity Report |
| Support & History | Histories · Contact Support · Feedback |
| Chat | Haydovchilar bilan yozishma |

**Nav tashqarisidagi ekranlar:**
- `Settings` — profil menyusi orqali (Company · Profile · Password Setting · Company history)
- `Track on Map` — `Unit Management` va `Tracking` dan kiriladi
- `Log view` — `Logs` jadvalidan satr bosilganda
- Har modulning View / Add / Edit ekranlari

Nomuvofiqlik (slaydda yozilgan): nav nomlari farq qiladi — `Fleet Operations` / `Fleet Management`, `Reports` / `Report`, `Support & History` / `Histories`.

### Bet 14 — Karkas: tepa panel anatomiyasi (`159:4970 · HEADER OPTIONS`, render `Dashboard · 123:1207`)
- **Platforma:** web 1440 px
- **QATLAM 1 — brend panel (to'q qizil `#B7002C`):** chapda logotip `ONE BOOK ELD`; markazda qidiruv — placeholder `Search Driver` + `Search` tugmasi (lupa ikonkasi); o'ngda tema almashtirgich (quyosh ikonkasi), bildirishnoma qo'ng'irog'i, profil avatari.
- **QATLAM 2 — navigatsiya (oq fon):** `Dashboard` · `Tracking` · `Logs` · `Fleet Operations` · `Maintenance` · `Reports` · `Support & History` · `Chat`. Faol element qizil rangda va ostida qizil chiziq; ochiladigan menyuli elementlarda `⌄`.
- **QATLAM 3 — breadcrumb (ichki ekranlarda):** masalan `Unit Management › Unit # 101 › Track on Map`, `Logs By Unit › Unit #`, `Due › 10 units`.
- **HEADER OPTIONS seksiyasi:** har nav holati alohida freym — Dashboard (159:5488), Tracking (159:5540), Logs (159:5592), Fleet Operations (159:5644), Reports (159:5731), History (159:5783), Chat (159:5861), **Maintainance** (267:30340) — 1440×125…127 px.

### Bet 15 — Flyout menyular (rasmlar)
Renderlar: `Fleet Operations · 159:5127`, `Logs · 498:5230`, `Reports · 159:5220`, `Support & History · 1200:4802`.
Har punktda ikonka + nom + tavsif satri. Faqat `Fleet Operations` flyoutida haqiqiy tavsif matni bor; qolgan uchtasida placeholder.

### Bet 16 — Flyout menyular, tafsilot
**Jadval ustunlari:** `NAV ELEMENTI` · `PUNKT` · `TAVSIF MATNI`
| NAV ELEMENTI (o'lcham) | PUNKT | TAVSIF MATNI |
|---|---|---|
| Fleet Operations (352×260) | Unit Management | «Manage your fleets» |
| | Driver Management | «Manage your drivers» |
| | Users | «Manage users in your system» |
| | Roles & Permissions | «Manage roles in your system» |
| Logs (352×156) | Logs By Unit · Logs By Driver | Lorem ipsum — matn yozilmagan |
| Reports (394×284) | FMCSA Report · IFTA Report · DVIR Report · Activity Report | lorem ipsum — matn yozilmagan |
| Support & History (394×224) | Histories · Contact Support · Feedback | lorem ipsum — matn yozilmagan |

### Bet 17–18 — Jadval anatomiyasi: bo'sh va to'la holat
- **Platforma:** web 1440 px (renderlar `Bo'sh holat · 1225:5292` 1400×1094 va `To'la holat · 153:140` 1440×1125)
- **Tarkibiy qismlar (yuqoridan pastga):** sahifa sarlavhasi + o'ngda asosiy amal tugmasi → tab qatori (agar bo'lsa) → filtr paneli (qidiruv, sana, `Export …`, `Import …`) → jadval sarlavhasi (kulrang fon, kichik harflar) → satrlar (oq fon, pastida 1 px chiziq) → sahifalash (chapda `Rows per page: 10`, o'ngda `Previous  1  Next`).
- **BO'SH HOLAT:** sarlavha `No Data Found`, ostida `There is no data to show you right now` + illyustratsiya. Jadval sarlavhasi va sahifalash ko'rinib turadi.
- **Yagona istisno:** `Log By Driver` (500:9277) — «Select driver first, to display the data in the table.»
- **Nuqson:** `Maintenance › Due` — bo'sh holatda ustunlar `Remind` va `Due Date`, to'la holatda `Remaining Frequency` va `Reminder Sent`. Nomuvofiqlik.

### Bet 19–20 — Ustun tanlash paneli va amal menyusi (`236:2354 · 252:12844`)
- **Platforma:** web. Render: `Unit ustunlari · 236:2354` (238×308 — kichik dropdown paneli).
- **Ustun tanlash paneli:** jadval o'ng burchagidagi tugma orqali; birinchi band `Select All`, keyin har ustun uchun belgilash (checkbox).

| UNIT MANAGEMENT (236:2354) | DRIVER MANAGEMENT (252:12844) |
|---|---|
| Select All | Select All |
| Unit # | First Name |
| License Plate | Last Name |
| Make & Model | Username |
| Year | Co-Driver |
| Device ID | Unit # |
| VIN | App Version |
| | Activated On |

- **Amal menyusi (`Action` ustuni):** har satr oxirida `···` tugmasi. Ochilgan holati alohida ekran sifatida chizilmagan; mavjud amallar: `View`, `Edit`, `Inactive`, `Delete`, `Change Password` (haydovchi), `Track on Map` (unit), `Mark as Complete` (maintenance).
- Izoh: ustun yashirish/ko'rsatish faqat Unit va Driver modullarida chizilgan.

### Bet 21–22 — Tasdiqlash modallari
- **Platforma:** web (renderlar 1400×1094 ×2). Renderlar: `Inactive · 159:5914`, `Delete · 252:10562`.
- Ikki xil hayot sikli: faollik (`Active` ⇄ `Inactive`) qaytariladigan; o'chirish qaytarib bo'lmaydigan.

**Jadval ustunlari:** `AMAL` · `SARLAVHA` · `MATN` · `TUGMALAR`
| AMAL (id) | SARLAVHA | MATN | TUGMALAR |
|---|---|---|---|
| Unit faolsizlantirish (159:5914) | Are you absolutely sure? | «Are you sure you want to inactive the unit?» | Cancel / Confirm |
| Unit o'chirish (159:6847) | Are you absolutely sure? | «This action cannot be undone. Are you sure you want to delete the unit?» | Cancel / Confirm |
| Driver faolsizlantirish (252:9767) | Are you absolutely sure? | «Are you sure you want to inactive the driver?» | Cancel / Confirm |
| Driver o'chirish (252:10562) | Are you absolutely sure? | «…delete the driver?» | Cancel / Confirm |
| User o'chirish (259:13873) | Are you absolutely sure? | «…delete the user?» | Cancel / Confirm |
| Role o'chirish (332:47243) | Are you absolutely sure? | «…delete the role?» | Cancel / Confirm |

### Bet 23 — Dashboard: KPI kartalari (`146:135 · 123:1207`, render `Dashboard · 123:1207 · 1440×1829`)
- **Platforma:** web 1440×1829
- Sahifa sarlavhasi: `Dashboard Overview`

**KPI kartalari** (ustunlar: `KARTA` · `QIYMAT` · `KESIM` · `IKONKA RANGI`):
| KARTA | QIYMAT | KESIM | IKONKA RANGI |
|---|---|---|---|
| Total Drivers | 62 | — | ko'k |
| Total Units | 69 | — | to'q sariq |
| Disconnected ELD | 32 | Today | kulrang |
| Violations | 6 | This week | qizil |

**Beshinchi karta — statuslar kesimi:** `Total DR` 42 · `Total ON` 6 · `Total SB` 12 · `Total OFF` 2 (yig'indisi 62 = Total Drivers).
**Kartalar pastidagi rangli chiziq:** Total Drivers — ko'k, Total Units — to'q sariq, Disconnected ELD — **yashil**, Violations — qizil, statuslar kartasi — sariq.

### Bet 24 — Dashboard: Units Tracking va Route's Details (`146:135`)
- **Platforma:** web
- **Units Tracking bloki:** interaktiv xarita (Google Maps ko'rinishi). Yuqori o'ng burchakda afsona: `● Drive` `● Sleep` `● On-Duty` `● Off-Duty`. Vaqt filtri: `Today` / `This week`. Marker ikonkasi statusga qarab: strelka — Drive, pauza — Off-Duty, nuqta — On-Duty, doira — Sleep.
- **Marker kartochkasi — uch qurilma holati:** `232:1997` Online (yashil nuqta) · `232:2029` Offline · `232:2061` Disconnected. O'lchami 200×217; tarkibi: haydovchi nomi, holat, `Unit #:`, `Odometer:`, `Location:` (tashqi havola ikonkasi), nisbiy vaqt (`4 hours ago`), `View Tracking ›` tugmasi.
- **Route's Details jadvali** — o'ngda qidiruv `Search Driver` (dropdown).

**Ustunlar** (`USTUN` · `NAMUNA QIYMAT`):
| USTUN | NAMUNA QIYMAT |
|---|---|
| Unit # | 101 … 110 |
| Date | 17/12/2025 |
| Driver Name | Susan Sumanggih |
| From | Lockheed Martin El Segundo, CA |
| To | 539 River Rd - Major Retail Co. |
| Status | `Completed` / `Ongoing` |

**Statuslar:** `Completed` — yashil fon; `Ongoing` — qizil fon. Jadvalda 10 satr, o'ng chekkada vertikal scroll — sahifalash yo'q.

### Bet 25 — Tracking: haydovchilar ro'yxati (`264:20269 · 264:23678`, render `tracking · 264:23678` 1440×1125)
- **Platforma:** web 1440 px
- **Filtr paneli:** `Search driver` (qidiruv) · sana tanlagich (`Apr 21, 2025`) · `Type` (dropdown) · `Export Drivers` · `Import Drivers`

**Jadval ustunlari** (`USTUN` · `FORMAT / QIYMATLAR`):
| USTUN | FORMAT / QIYMATLAR |
|---|---|
| # | 1 … 10 |
| Driver Name | Kiss Dorka, Dudás Nikolett … |
| Unit # | 894, 458, 255 … |
| Status | `SB` · `DR` · `ON` · `OFF` — rangli badge |
| Last Known Location | `48.8566, 2.3522, 30` + nisbiy vaqt (`13 hours ago`) |

- Aniqlanmagan: `Last Known Location` uchinchi soni nima ekani ko'rsatilmagan.
- **Bo'sh holat:** `No Data Found` + `There is no data to show you right now`
- **Sahifalash:** `Rows per page: 10` · `Previous` · `1` · `Next`

### Bet 26 — Track on Map: yig'ilgan panel (`264:20269 · 265:28242`, render `Track on Map (collapse) · 163:13598` 1400×1037)
- **Platforma:** web
- **Ikki kirish yo'li:** Unit Management → satr amali → breadcrumb `Unit Management › Unit # 101 › Track on Map` (163:13598); Tracking → satr → breadcrumb `Tracking › Unit # 101` (265:28242).
- **Xarita paneli boshqaruvlari:** sarlavha `Unit # 101` + `←` qaytish; o'ngda `Refresh`; sana navigatori `‹ February 15,2024 ›`; xaritada raqamli to'xtash markerlari (1,2,3,4) va sariq yo'nalish chizig'i; chapda qatlam tanlash va joylashuvga o'tish tugmalari; o'ngda pastda `+` / `−` zoom.
- **Marker kartochkasi:** haydovchi nomi, `Online`, `Odometer: 1234321 miles`, `Location: Blue Valley, Phase 3, near shell pump.` (tashqi havola ikonkasi), nisbiy vaqt (`A minute ago`, `20 minutes ago`).

**Uchta holat alohida chizilgan** (`HOLAT` · `UNIT MANAGEMENT` · `TRACKING`):
| HOLAT | UNIT MANAGEMENT | TRACKING |
|---|---|---|
| yig'ilgan | 163:13598 | 265:28242 |
| Refresh bosilgan | 249:3683 | 265:28750 |
| yoyilgan | 237:2475 | 265:29262 |

Yon panel yopiq holatda o'ng chekkada kichik `›` tugmasi — bosilganda panel yoyiladi.

### Bet 27 — Track on Map: yoyilgan panel va diagnostika (`237:2475`, render 1440×1047)
- **Platforma:** web
- **1 — Haydovchi bloki:** nomi + ogohlantirish ikonkasi (qizil uchburchak), `Online`, joylashuv (`Blue Valley, Phase 3` + qurilma ikonkasi), batareya `92%`, tezlik `52mph`, vaqt tamg'asi `11:03 10/02/2024`, `Shift Ends in 01:10:23`. O'ngda `⋮` menyusi.
- **2 — UNIT DIAGNOSTICS** (`KO'RSATKICH` · `NAMUNA QIYMAT`):

| KO'RSATKICH | NAMUNA QIYMAT |
|---|---|
| VIN | 2B4NC9EH4GN934616 |
| Engine Hours | 1070h 12m |
| Odometer | 993107mi |
| Fuel | 100% |
| Bus | J1939/J1708 |
| Coolant Level % | 100% |
| Coolant Temperature | 79 |
| Oil Level % | 101.6% |

- **3 — HISTORIES:** har segment — boshlanish nuqtasi (`1.04 mi W of Harrisburg, OH`), `Range: May 20, 10:05 EST - May 20, 14:05 EST`, `Duration: 04h 05m`, tugash nuqtasi (`0.64 mi N of Florence, KY`). Chapda vertikal timeline nuqtalari. Alohida freymlar: 249:3566 va 265:29619 (367×843), 6 segmentli scroll ro'yxati.
- **Nomuvofiqlik:** Tracking'dan kirilganda (265:29262) blok `Unit Inspection`, Unit Management'dan kirilganda `Unit Diagnostics`. Ko'rsatkichlar bir xil.

### Bet 28 — Unit Management: ro'yxat (`153:995 · 153:140`, render `Fleet Management · 153:140 · 1440×1125`)
- **Platforma:** web 1440×1125
- **Sarlavha va amallar:** sarlavha `Unit Management`, o'ngda `Add Unit`. Tablar: `Active` / `Inactive`. Filtr: `Search unit#`, `Export Units`, `Import Units`, o'ngda ustun tanlash tugmasi.

**Ustunlar** (`USTUN` · `NAMUNA` · `IZOH`):
| USTUN | NAMUNA | IZOH |
|---|---|---|
| # | 1 … 10 | tartib raqami |
| Unit # | 345, 541, 654 | kompaniya ichki raqami |
| License Plate | PY 97 A 9895 | |
| Make & Model | Mercedes-Benz C-Class | |
| Year | 2018 | |
| ELD | `PT30_A9A1`, `PT30_EE35` | qiymat yo'q bo'lsa `Not Found` (qizil) |
| VIN | 1VWAP7A3XDC068406 | |
| Action | `···` | |

- **Nomuvofiqlik:** boshqa ekranlarda shu jadval `Manufacturer - Model` va `Device ID` deb nomlangan (`AP-AM4-0001172` formatidagi qiymatlar bilan) — ikki xil nomlash va ikki xil ELD id formati.
- **Bo'sh holat:** `No Data Found` + `There is no data to show you right now`
- **Sahifalash:** `Rows per page: 10` · `Previous` · `1` · `Next`
- **Render sarlavhasi nomuvofiq:** slaydda ekran nomi `Fleet Management`, dizaynda `Unit Management`.

### Bet 29 — Unit: Add / Edit formasi (`153:3124 · 157:4241`, render `Fleet Add · 153:3124 · 1440×1024`)
- **Platforma:** web · **modal** (orqa fonda ro'yxat ko'rinadi)
- Modal sarlavhasi `Add Unit` (tahrirlashda `Edit Unit`), blok nomi `UNIT DETAILS`

**Maydonlar** (`MAYDON` · `TUR` · `PLACEHOLDER / QIYMAT`):
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Unit # * | matn | `#` |
| ELD * | ro'yxat (select) | Choose ELD Type |
| Make * | ro'yxat | Select make |
| Model * | ro'yxat | Select model |
| License Plate Number * | matn | Enter license plate number |
| License Plate Issue State | ro'yxat | Select issuing state |
| Year | matn | `0000` |
| Fuel Type* | ro'yxat | Choose fuel type |
| VIN | radio + matn | `Get VIN From ELD` / `Enter VIN Manually` |
| Notes | ko'p qatorli (textarea) | Add notes |

**Alohida bayroqcha (checkbox):** `Sleeper Not Available (Day Cab, Box Truck, or Pickup Truck)` — «The Sleeper Berth (SB) status will be disabled.» Belgilansa haydovchi SB statusini tanlay olmaydi.
**Tugmalar:** `Cancel` / `Save` (tahrirlashda `Update`).

### Bet 30 — Unit: Edit va View (`157:4241 · 252:4983`)
- **Platforma:** web (renderlar 1400×996 va 1440×1024)
- Renderlar: `Fleet Edit · 157:4241`, `Fleet View · 252:4983`

### Bet 31 — Unit: Edit va View, tafsilot (`157:4241 · 252:4983`)
- **Platforma:** web · modal
- **EDIT (to'ldirilgan holat):** Add bilan bir xil maydonlar, qiymatlar: `101`, `PT30_EE35`, `BMW`, `i4`, `California`, `2021`, `Diesel`. Tugma `Update`.
- **VIEW — UNIT DETAILS** (`MAYDON` · `NAMUNA`):

| MAYDON | NAMUNA |
|---|---|
| Drivers | John Smith, William Bond (co) |
| ELD | PT30_A86E |
| Activated On | Apr 18, 2025 |
| VIN # | xxxxxxxxxxxx |
| Makes | BMW |
| Model | i5 |
| Year | xxxx |
| Sleeper Berth | Not Available |
| License plate number | xxxxxxxxx |
| License plate issuing state | California |
| Fuel Type | Petrol |
| Notes | Lorem Ipsum … |

- **Drivers maydoni:** bir unitda ikki haydovchi, ikkinchisi `(co)` belgisi bilan → Unit ↔ Driver bog'lanishi asosiy + co-driver juftligi.
- **View sarlavhasi:** `Unit # 101` (unit raqami sarlavha). View ekranida orqa fonda `Add New Fleet` tugmasi ko'rinadi.

### Bet 32 — Unit: Activities jurnali (`167:3035`, render `Fleet View (Info) · 167:3035`)
- **Platforma:** web · View ekranining ikkinchi ko'rinishi, blok nomi `UNIT ACTIVITIES`

| USTUN | NAMUNA QIYMAT |
|---|---|
| Time Stamp | 12:03 11/02/2024 |
| Activity | Lorem ipsum |

Dizaynda 10 satr, barchasi `Lorem ipsum` — haqiqiy hodisa turlari ko'rsatilmagan.

**Driver Activities bilan farqi:**
| JURNAL | USTUNLAR |
|---|---|
| Unit (167:3035) | Time Stamp · Activity |
| Driver (257:1676) | Time Stamp · Edited By · Activity |

### Bet 33 — Driver Management: ro'yxat (`252:5769 · 252:8975`, render `Drivers Mangement · 252:8975` — **imlo xatosi «Mangement»**)
- **Platforma:** web 1400×1147
- Sarlavha `Driver Management`, tugma `Add Driver`. Tablar `Active` / `Inactive`. Filtr: `Search driver`, `Export Drivers`, `Import Drivers`.

| USTUN | NAMUNA | IZOH |
|---|---|---|
| # | 1 … 10 | |
| First Name | Bessie | |
| Last Name | Lane | |
| Username | username1123 | |
| Co-Driver | Kiss Dorka | |
| Fleet Manager | Kiss Dorka | |
| Unit # | 894 | |
| App Version | 2.23 / 2.21 | yashil/kulrang nuqta bilan |
| Activated On | 17/12/2025 | |
| Action | `···` | |

`App Version` oldida rangli nuqta: eng yangi versiya — yashil, eskisi — kulrang.
**Bo'sh holat:** `No Data Found` + `There is no data to show you right now` · **Sahifalash:** `Rows per page: 10` · `Previous` · `1` · `Next`

### Bet 34 — Driver: Add formasi, 18 maydon (`252:6345`, render `driver Add · 252:6345 · 1440×1179`)
- **Platforma:** web · modal · blok `DRIVER DETAILS` (dizaynda eng ko'p maydonli forma)

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| First Name * | matn | Enter first name |
| Last Name * | matn | Enter last name |
| Username * | matn | Enter username |
| Password * | parol | Enter password |
| Email Address * | matn | Enter email address |
| Phone Number * | matn | Enter phone number |
| Unit # | ro'yxat | Choose unit# |
| Co-Driver * | ro'yxat | Choose co-driver |
| Driver's License Plate Number * | matn | Enter license number |
| Driver's License Plate Issue State | ro'yxat | Choose license state |
| City | matn | Enter city |
| State | matn | Enter state |
| Zip Code | matn | Enter zip code |
| Fleet Manager | ro'yxat | Choose fleet manager |
| Home Terminal Address | matn | Enter home terminal address |
| Address 1 | matn | — |
| Address 2 | matn | — |
| Notes | ko'p qatorli | Add notes |

Izoh: `Unit #` ixtiyoriy, lekin `Co-Driver *` majburiy.

### Bet 35–36 — Driver: View, Activities, Edit va parol (`252:7008 · 257:1676 · 258:2523`)
- **Platforma:** web (renderlar 1400×996, 1400×996, 1400×1094)
- Renderlar: `Driver View · 252:7008`, `Activities · 257:1676`, `Change password · 258:2523`
- **VIEW — DRIVER DETAILS:** sarlavha — haydovchi ismi (`John Smith`). Ikki tab: `Information` / `Activities`.
  Maydonlar: `First name`, `Last name`, `Username`, `Email Address`, `Phone number`, `Unit #`, `Co-driver`, `Fleet Manager`, `License plate number`, `License plate issuing state`, `City`, `State`, `Zip code`, `Home terminal address`, `Address 1`, `Address 2`, `Notes`.
  Parol View'da ko'rsatilmaydi — faqat Edit formasida (`252:8313`, qiymat `1234john5678` ochiq ko'rinadi).
- **ACTIVITIES jurnali:**

| USTUN | NAMUNA |
|---|---|
| Time Stamp | 12:03 Feb 11,2024 |
| Edited By | Varga Dóra |
| Activity | Change active status from N/A to 22/022025 |

Faqat birinchi satrda haqiqiy hodisa matni, qolganlari `Lorem ipsum`.
- **CHANGE PASSWORD modali:** maydonlar `New password` (placeholder `New password`), `Confirm new password` (placeholder `Confirm password`). Tugmalar `Cancel` / `Update`. Admin eski parolni bilishi shart emas.

### Bet 37–38 — User Management (`259:12588`)
- **Platforma:** web (renderlar `User Management · 259:13137` 1440×1125, `Add User · 259:14668` 1400×996, `Edit User · 259:15295` 1400×996)

**Ro'yxat ustunlari:**
| USTUN | NAMUNA |
|---|---|
| # | 1 … 10 |
| First Name | Bessie |
| Last Name | Lane |
| Email Address | jginspace@mac.com |
| Role | Kiss Dorka |
| Phone Number | (252) 555-0126 |
| Action | `···` |

Nuqson: `Role` ustunida ism yozilgan («Kiss Dorka») — placeholder xatosi.
**Filtr:** `Search user`, `Export Drivers`, `Import Drivers` — eksport tugmalari nomi «Drivers» qolgan (nomuvofiqlik).

**ADD / EDIT USER — USER DETAILS:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| First Name * | matn | Enter first name |
| Last Name * | matn | Enter last name |
| Email Address * | matn | name@mail.com |
| Role * | ro'yxat | Assign role |
| Phone Number * | matn | Enter phone number |

Edit holatida (`259:15295`): `John`, `Smith`, `john@gmail.com`, `Safety Manager`, `+92 334 567222`. Tugma `Update`. Barcha 5 maydon majburiy; foydalanuvchi bitta rolga ega.

### Bet 39–40 — Roles & Permissions (`330:44019`)
- **Platforma:** web (renderlar `R&P ro'yxati · 330:44577` 1440×1125, `Add Role · 330:45466` 1400×996)
- **Ro'yxat ustunlari:** `#` · `Role Name` · `Action`. Filtr `Search role`. Tugma `Add Role`.
- **Dizayndagi 5 rol:** `Service Manager` · `Operations Manager` · `Sub Admin` · `Administrator` · `Data Analyst`
- **ADD / EDIT ROLE tuzilishi:**
  - Blok 1 — `ROLE DETAILS`: `Role Name *` (placeholder `Add role name`, qiymat `Fleet Manager`)
  - Blok 2 — `PERMISSIONS DETAILS`: modullarga guruhlangan belgilash (checkbox) ro'yxati
  - Tugmalar `Cancel` / `Save` (`Update`)
- **OGOHLANTIRISH: ekrandagi ruxsatlar ro'yxati begona domendan (go'zallik saloni):**
  `Dashboard`, `View carts`, `View salons reservation graph`, `View revenue graph`, `View active & inactive clients graph`, `View male & female Salons piechart`, `View male & female clients piechart`, `Salons`, `Add salons`, `Edit salons`, `Active/inactive salons`, `Delete salons`, `View salon gallery`, `Clients`, `View clients`, `Active/inactive clients`, `Delete clients`, `Employees`, `Add employees`, `Edit employees`, `Active/inactive employees`, `Delete employees`.
  Dizayndan olinadigan yagona narsa — struktura: rol nomi + modullar bo'yicha guruhlangan amal darajasidagi ruxsatlar (`Add` / `Edit` / `Active/inactive` / `Delete` / `View`).

### Bet 41 — Histories (`259:16327 · 259:16876`, render `Histories · 259:16876` 1400×1094)
- **Platforma:** web
- Sarlavha `Histories`, o'ngda **`Add User`** tugmasi (nomi mos emas — nomuvofiqlik).
- **Filtrlar:** `Search driver` · `Start date` · `End date` · `Export Drivers` · `Import Drivers`

| USTUN | NAMUNA |
|---|---|
| Driver Name | Bessie Cooper |
| Edited By | Sípos Veronika |
| Date | Fri, 29/11/2025 |

Sana formati hafta kuni bilan: `Fri, 29/11/2025`, `Mon, 04/08/2025`, `Tues, 02/11/2025`, `Wed, 13/02/2025`, `Thurs, 19/11/2025`, `Sat, 03/03/2025`, `Sun, 30/07/2025`.
**Nuqson:** hafta kuni qisqartmalari bir xil emas — `Tues`, `Thurs` (4 harf) va `Fri`, `Mon`, `Wed`, `Sat`, `Sun` (3 harf).
Izoh: to'rt audit jurnali mavjud — Unit, Driver, Histories, hamda Settings › Company history.

### Bet 42 — Maintenance: modul xaritasi (`1225:5291 · amaldagi qatlam`)
- **Platforma:** web
- Oqim: `Schedule` (reja tuzilgan, muddat kelmagan) → `Due` (muddati kelgan yoki o'tgan) → `History` (`Completed` / `Cancelled`)

**Uch tab, uch xil ustun to'plami:**
| TAB (id) | USTUNLAR |
|---|---|
| Schedule (1225:5895) | Unit # · Types · Schedule Name · Maintenance Frequency · Action |
| Due (1225:5433) | Unit # · License Plate · Types · Schedule Name · Remaining Frequency · Reminder Sent · Action |
| History (1225:7810) | Maintenance Date · Unit # · Driver Name · Make & Model · Invoice # · Vendor Name · Cost · Schedule Name |
| History kengaytirilgan (1225:8959) | + Types · Status · Action |

**Barcha ekranlar (17 ta):** Schedule — bo'sh 1225:5292 · Due — to'la 1225:5433 · Schedule — bo'sh 1225:5762 · Schedule — to'la 1225:5895 · View single 1225:6156 · Add single 1225:6519 · Add multiple 1225:6738 · Edit 1225:7232 · View multiple 1225:7468 · History — bo'sh 1225:7666 · History — to'la 1225:7810 · Content (ustunlar) 1225:8959 · View completed 1225:9310 · View cancelled 1227:13594 · Mark complete — bo'sh 1225:9702 · Mark complete — to'la 1225:11739 · multiple → view 1225:12183

**Eskirgan qatlamdan farqi:** yashirilgan 268:30430 da 4 tab bo'lgan — `Schedule` / `Upcoming` / `Verification` / `History`, hamda `Verification- rejected` va `Reason of Rejection` oqimi. Amaldagi dizaynda Verification olib tashlangan, `Upcoming` → `Due` deb qayta nomlangan.

### Bet 43–44 — Maintenance: Schedule va Due tablari (`1225:5895 · 1225:5433`)
- **Platforma:** web (renderlar `Schedule · 1225:5895` 1400×1094, `Due · 1225:5433` 1440×1125)

**Qiymat turlari:**
| USTUN | DIZAYNDAGI QIYMATLAR |
|---|---|
| Types | Oil Change · Tyre · Engine Oil Change · Lights Change · Lease Expiry · Grease |
| Schedule Name | Scheduled PM · Scheduled · New · Urgent |
| Maintenance Frequency | 2000 miles · 20 days · 2000 engine hours |
| Remaining Frequency | 2000 miles · 2 days due · 02hr 23 min · 20 miles due |
| Reminder Sent | 2000 miles |

Chastota uch birlikda: masofa (miles), vaqt (days), dvigatel soati (engine hours).
**Vizual belgilar:** muddati kelgan/o'tgan qiymatlar **qizil** (`2 days due`, `20 miles due`); guruh satri `10 Units` ko'rinishida, `License Plate` ustunida `-`; `Export` tugmasi filtr panelida (yuklab olish ikonkasi bilan).

**Bo'sh holatdagi nomuvofiqlik:**
| EKRAN | 5-USTUN | 6-USTUN |
|---|---|---|
| Due — bo'sh 1225:5292 | Remind | Due Date |
| Due — to'la 1225:5433 | Remaining Frequency | Reminder Sent |

### Bet 45 — Maintenance: View (single), chastota mantiqi (`1225:6156`, render `View (single) · 1225:6156` 1400×996)
- **Platforma:** web · modal · blok nomi **`MAINTAINANCE DETAILS`** (imlo xatosi — «Maintainance»)

| MAYDON | NAMUNA |
|---|---|
| Unit # | 101 |
| Schedule Name | Urgent |
| Maintenance type | Oil Change |
| Current Frequency | 200 miles |
| Maintenance Frequency | 2000 miles |
| Next Frequency | 2200 miles |
| Remind before | 1500 miles |
| Alert Type | Upcoming |
| Delivery Method | Email |
| Notify co-driver | Yes |
| Notes | Lorem Ipsum … |

**Formula:** `Next Frequency = Current Frequency + Maintenance Frequency` (200 + 2000 = 2200 ✔).
`Remaining Frequency` — Next Frequency gacha qolgan masofa/vaqt; manfiy bo'lsa «overdue» (mobilda `overdue 1 miles`).

### Bet 46–47 — Maintenance: Add single va multiple (`1225:6519 · 1225:6738`)
- **Platforma:** web (renderlar `Add single · 1225:6519` 1440×1179, `Add multiple · 1225:6738` 1400×1147) · modal
- **Rejim tanlash:** `Single Unit` / `Multiple Units`

**MAINTENANCE DETAILS:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Maintenance Type * | ro'yxat | Select maintenance type |
| Unit # * | ro'yxat | Select unit # — faqat single |
| Maintenance Frequency * | son + birlik | Enter value + `Miles` |
| Set Reminder (before service due) * | son + birlik | Enter value + `Miles` |
| Schedule Name * | matn | Enter schedule name |
| Current Frequency | son + birlik | `1000` + `Miles` — faqat single |
| Notes | ko'p qatorli | Add notes |

**UNITS bloki — faqat multiple:** `Select All` + har unit satri: `Unit # 101 Mercedes AMG · Current Frequency: 1000 Miles`.

**ALERTS bloki:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Alert Type * | ro'yxat | Select alert type (qiymat: `Upcoming`) |
| Delivery Method * | ro'yxat | Select delivery method (qiymat: `Email`) |
| Notify co-driver | belgilash (checkbox) | — |

**Tugmalar:** `Cancel` / `Save` (Edit'da `Update`, 1225:7232).
Aniqlanmagan: `Alert Type` va `Delivery Method` ro'yxatlarining to'liq tarkibi ko'rsatilmagan.

### Bet 48–49 — Maintenance: View multiple va guruh ichi (`1225:7468 · 1225:12183`)
- **Platforma:** web (renderlar 1400×996 va 1400×1120)
- **VIEW (multiple):** sarlavha `10 Units`, yuqorida single bilan bir xil maydonlar, pastda `UNITS` ro'yxati:

| UNIT | CURRENT FREQUENCY | NEXT FREQUENCY |
|---|---|---|
| Unit # 101 Mercedes AMG | 200 miles | 2200 miles |
| Unit # 102 Mercedes AMG | 200 miles | 2200 miles |
| Unit # 103 Mercedes AMG | 200 miles | 2200 miles |
| Unit # 104 Mercedes AMG | 200 miles | 2200 miles |

Nuqson: shu ekranda `Notify Co-driver` bosh harf bilan (boshqa joyda `Notify co-driver`) — imlo nomuvofiqligi.
- **Guruh ichiga kirish:** jadvaldagi `10 Units` satri bosilganda alohida ekran — breadcrumb `Due › 10 units`; sarlavha `10 units`, o'ngda `Refresh`; filtr `Search unit#`, `Export`; jadval Due tabi bilan bir xil ustunlar, 9 satr. Barcha satrlarda `Types = Tyre`, `Schedule Name = Scheduled PM`, `Remaining Frequency = 2 days due`.
- `Refresh` tugmasi faqat shu ekranda.

### Bet 50–51 — Maintenance: yakunlash (`1225:9702 · 1225:11739`)
- **Platforma:** web (renderlar `Mark as Complete — bo'sh · 1225:9702` 1440×1125, `Mark as Complete — to'la · 1225:11739` 1400×1094) · modal
- **`MARK MAINTENANCE AS COMPLETE` modali:**

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Invoice # | matn | Enter invoice # → `124356` |
| Vendor Name | matn | Enter vendor name → `XYZ Vendors` |
| Cost | matn | `$200` |
| Maintenance Date | sana | `--/--/--` → `11/12/2025` |
| Invoice | fayl | `Upload invoice (.pdf format)` → `INV124356.pdf` |

**Tugmalar:** `Cancel` / `Save`. Fayl formati: faqat PDF.
- **Eskirgan qatlamdagi qo'shimcha oqim (268:30430):** `Mark Maintenance as Rejected` modali — `Reason of Rejection` («Write the reason for rejecting the maintenance»), hamda `Verification- Rejected - View` ekrani (`Rejected Date`, `Reason of Rejection`). Amaldagi dizaynda rad etish oqimi yo'q.

### Bet 52–53 — Maintenance: History ko'rish (`1225:9310 · 1227:13594`)
- **Platforma:** web (renderlar `Completed · 1225:9310` 1400×996, `Cancelled · 1227:13594` 1400×996)

**COMPLETED holati:**
| MAYDON | NAMUNA |
|---|---|
| Status | `Completed` |
| Unit # | 101 |
| Driver Name | Smith john |
| Maintenance Date | Apr 18, 2025 |
| Schedule Name | Schedule |
| Invoice # | INV0086532 |
| Vendor Name | Smith John |
| Cost | $321 |
| Odometer | 233,876 mi |
| Engine Hours | 234 hr 34 min |
| Attachment | Invoice.pdf |

So'ngra ikki blok: `PRE-TRIP INSPECTION` va `POST-TRIP INSPECTION` (ichidagi kontent dizaynda to'ldirilmagan).

**CANCELLED holati:** `Status` = `Cancelled`, `Unit #` 101, `Driver Name` Smith john, `Schedule Name` Schedule, `Odometer` 233,876 mi, `Engine Hours` 234 hr 34 min.
Farqi: bekor qilingan yozuvda moliyaviy maydonlar (`Maintenance Date`, `Invoice #`, `Vendor Name`, `Cost`, `Attachment`) va tekshiruv bloklari yo'q.

### Bet 54 — Logs: modul xaritasi (`312:40199 · 500:9276 · LOG VIEW`)
- **Platforma:** web
- Oqim: `Logs By Unit` (unit kesimi, bir kun) → `Log view` (3 tab: `Driver's Log` · `Report` · `Trip Planner`) ← `Logs By Driver` (haydovchi kesimi, sana oralig'i)

| EKRAN | KESIM | ASOSIY FILTR |
|---|---|---|
| Logs By Unit (312:40746) | bitta kun, barcha unitlar | sana (`Apr 21, 2025`) |
| Logs By Driver (500:9418) | bitta haydovchi, sana oralig'i | `Start date - End date` |

**Umumiy filtrlar:** `Search driver` · `Location` · `Violations` · `Warnings` · `Export Drivers` · `Import Drivers`
(`Location` faqat Logs By Unit'da; `Violations` va `Warnings` — mustaqil filtrlar.)

**Ustunlar taqqoslash:**
| LOGS BY UNIT | LOGS BY DRIVER |
|---|---|
| # | # |
| Device Status | — |
| Unit # | Date |
| Driver Name | Unit # |
| Status | Status |
| Last Known Location | Last Known Location |
| Warnings & Violations | Warnings & Violations |
| kengaytirilgan: `Break` `Drive` `Shift` `Cycle` `Recap` | kengaytirilgan: bir xil |

### Bet 55–56 — Logs By Unit: asosiy va kengaytirilgan ko'rinish (`312:40746 · 381:54574`)
- **Platforma:** web (renderlar `log · 312:40746` 1440×1125, `kengaytirilgan · 381:54574` 1400×477)

| USTUN | QIYMATLAR |
|---|---|
| Device Status | `Online` · `Offline` · `Disconnected` |
| Status | `SB` · `DR` · `ON` · `OFF` |
| Break / Drive / Shift / Cycle | 08:00 · 11:00 · 14:00 · 70:00 |
| Recap | status kodi (`SB`, `DR`, …) |

Ba'zi satrlarda HOS qiymatlari bir xil (`06:23`×4) — placeholder.
**Ogohlantirish matnlari:** `Trailer not set.` · `Shipping document is not set` · `Shift Limit`
Jadval ustidagi izoh: «Violations can be removed after completion of second qualify break.»
Jadvalda raqamli badge (`1`) — qoidabuzarliklar soni.

### Bet 57 — Log view: HOS bloki va 24 soatlik grid (`384:55489`, render `Log view · driver's log · 384:55489 · 1440×2211`)
- **Platforma:** web 1440×2211
- **Sarlavha qismi:** breadcrumb `Logs By Unit › Unit #`; sarlavha `Unit # 101` + `←`; haydovchi bloki (nomi, platforma belgisi Android/PT, `Online`, telefon, `Driver 2 co` havolasi); sana navigatori `‹ February 15,2024 ›`; o'ngda `Report` va `Current Location` tugmalari.
- **HOS bloki — 4 halqasimon indikator:** `BREAK` 08:00 · `DRIVE` 09:00 · `SHIFT` 10:00 · `CYCLE` 65:00. Ostida: `Certified: No` · `W.H 01:03` · `Violations: No`
- **Tablar:** `Driver's Log` · `Report` · `Trip Planner`
- **24 soatlik grid:** qatorlar `OFF` · `SB` · `DR` · `ON`; o'ng chekkada har status jami `11:03` · `00:00` · `05:30` · `00:00`; pastda o'ngda `Total: 07:34`; grid ustida hodisa markerlari (PTI badge'lari, rangli belgilar), tooltip vaqt (`05:10:11 AM` / `06:10:11 AM`); status chizig'i ko'k (`#466FF7`).
- **Ogohlantirish satrlari (grid ostida):** `Violation: Trailer is not set` (qizil) · `Warning: Trailer is not set` (sariq/warning)

### Bet 58 — Log view: voqealar jadvali va Log Form (`384:55489 · 475:4854`, render `Log view · reports tab · 475:5370`)
- **Platforma:** web

**Voqealar jadvali — asosiy ustunlar:**
| USTUN | NAMUNA |
|---|---|
| # | 1 … 10 |
| Status | `DR`, `PTI`, `POWER OFF` |
| Start | 12:33:18 AM |
| Duration | 18h:10m:06s |
| Last Known Location | `48.8566, 2.3522, 30` + nusxalash ikonkasi |
| Odometer | 894 |
| Engine Hours | 894 |
| Notes | Kiss Dorka |

Kengaytirilgan ko'rinishda (`475:4854`, 1630×648) qo'shimcha: `Document` (`112V38YWG`), `Trailer` (`HV2200915`), `Action`.

**Status — ikki xil yozuv turi:** duty status (davomiylikka ega): `DR` `OFF` `SB` `ON`; hodisa (nuqtaviy): `PTI` `POWER ON` `POWER OFF` `FUEL` `CERTIFY`.

**LOG FORM bloki:**
| MAYDON | NAMUNA | KO'RINISHI |
|---|---|---|
| Unit # | 101 | matn |
| Driver Name | Smith john | matn |
| Co-Driver | William | matn |
| Distance | 23ml | matn |
| Trailers | `Bobtail`, `HV2306595` | yashil badge |
| Shipping Docs | `115PVTPV8`, `115PVTPV4` | yashil badge |
| Signature | `Signed` + imzo tasviri | yashil matn |

`Trailers` va `Shipping Docs` — vergul bilan ro'yxat (bir kunda bir nechta).

### Bet 59–60 — Log view: status kiritish va Report tabi (`480:8990 · 475:5370`)
- **Platforma:** web (renderlar `Insert duty status · 480:8990` 1400×1094, `Log view · reports tab · 475:5370`)
- **INSERT DUTY STATUS paneli** (grid ostida ochiladi, log grid ustiga bosilganda). Status tanlash tugmalari: `OFF` · `SLEEP` · `DRIVING` · `ON (YM)` · `OFF (PC)` · `ON`

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| From * | vaqt | 06:10:00 |
| To * | vaqt | 11:40:00 |
| Note * | matn | Add note |

**Tugmalar:** `Cancel` / `Confirm`. `Note *` majburiy (audit talabi).
Izoh: `ON (YM)` — Yard Move, `OFF (PC)` — Personal Conveyance; haydovchi ilovasining status tugmalarida yo'q, faqat admin tahrirlashda.
- **REPORT tabi:** sarlavha `Report`, o'ngda `Download` tugmasi, markazda `PDF VIEW` sohasi.

**Log view — uch tabning vazifasi:**
| TAB | NIMA KO'RSATADI |
|---|---|
| Driver's Log | grid + voqealar jadvali + Log Form |
| Report | PDF ko'rinish + Download |
| Trip Planner | xarita + segmentlar + Plan a Trip |

### Bet 61–62 — Log view: Trip Planner (`475:6184 · 475:6693`)
- **Platforma:** web (renderlar `Trip Planner · 475:6184` 1338×1400, `Plan a Trip · 475:6693` 1338×1400)
- **Trip Planner ko'rinishi:** xarita + raqamli nuqtalar (1…4). Nuqta kartochkasi:

| MAYDON | NAMUNA |
|---|---|
| Status: | `END` |
| Date: | Last Friday at 11:54 PM |
| Odometer: | 1234321 miles |
| Location: | Blue Valley, Phase 3, near shell pump. |
| Coordinates: | 36.9876543355555, 23,97464553778 |
| Duration: | 24m 8s |
| Stopped: | Apr 10, 11:54 AM to 01:10 PM |

Nuqson: koordinatada vergul va nuqta aralash (`23,97464553778`).
- **PLAN A TRIP formasi:**

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| From * | matn | 1.55 mi millstone, PA |
| To * | ro'yxat | `Select \|` |
| Copy last location | havola | boshlanish nuqtasini oxirgi joylashuvdan olish |

Tugma `Run Trip`. Yuqorida `Satellite` rejimi almashtirgichi va `Location updated: An hour ago`.
- **Haydovchi tomonida natijasi:** mobil bildirishnoma «Admin has added a new route.» — «From "ABC LOCATION" to "XYZ LOCATION"». Marshrut Dashboard'dagi Route's Details jadvalida `Ongoing` holatida paydo bo'ladi (Completed'ga o'tishi dizaynda ko'rsatilmagan).

### Bet 63–64 — Logs By Driver (`500:9276`)
- **Platforma:** web (renderlar `log by driver · 500:9418` 1400×1094, `kengaytirilgan · 500:10258` 1400×540)
- **Farqlari:** sarlavha **`Log By Driver`** (jadval ichida `Logs/ Log by driver` seksiyasi); filtr `Start date - End date` (oraliq); birinchi ustun `Date`, `Unit #` ikkinchi; `Device Status` ustuni yo'q.
- **Kengaytirilgan ustunlar:** `Break` · `Drive` · `Shift` · `Cycle` · `Recap` (Logs By Unit bilan bir xil)
- **Ogohlantirishlar:** shu ekranda `Shift Limit`; Logs By Unit'da `Trailer not set.`
- **Bo'sh holatdagi maxsus matn:** «Select driver first, to display the data in the table.» — yagona ekran, standart `There is no data to show you right now` dan farq qiladi.

### Bet 65 — Hisobotlar: to'rt turi (`REPORTS FLYOUT · 159:5220`)
- **Platforma:** web

| HISOBOT (id) | KESIM | SHAKLLANTIRISH | CHIQARISH | HOLAT KUZATUVI |
|---|---|---|---|---|
| Activity Report (292:18830) | Drivers / Units | darhol (jadval) | `Download CSV` · `Print` | yo'q |
| IFTA Report (303:23807) | Units / States | `Generate Report` → chorak | CSV / PDF | yo'q, lekin «5-kunga qadar tayyor» |
| FMCSA Report (307:34380) | haydovchi bo'yicha | `Generate Report` | tashqi tizimga yuborish | `Status` + `Submission ID` |
| DVIR Report (549:3958) | haydovchi bo'yicha | `Generate Report` | — | 7 holatli |

**Umumiy jihatlar:** har birida `Generate Report` tugmasi (DVIR'da ba'zi ekranda `Add DVIR` — nomuvofiqlik); Generate formasi modal, orqa fonda ro'yxat; blok nomi `REPORT DETAILS` (IFTA'da boshqacha); tugmalar `Cancel` / `Generate`.
**Farqli jihatlar:** Activity — hisobot emas, jonli jadval; IFTA — `GENERATE AS` (CSV/PDF) va `GET BTY` (States & Trucks / States only); FMCSA — `Type` tanlovi (8 kunlik yoki Custom Range); DVIR — imzo maydonlari (`Paste driver signature here`).

### Bet 66–67 — Activity Report: ikki kesim (`292:18830 · 296:21457`)
- **Platforma:** web (renderlar `Drivers · 292:19388` 1400×1094, `Units · 296:22009` 1400×1094)

**DRIVERS kesimi:**
| USTUN | NAMUNA |
|---|---|
| Driver Name | Sípos Veronika |
| Odometer Change | 18599 mi |
| Driving Time (HH:MM:SS) | 18:10:06 |

Filtr: `Search driver`, `11/02/2025 — 11/03/2025`, `Export Drivers`, `Import Drivers`.

**UNITS kesimi:**
| USTUN | NAMUNA |
|---|---|
| Driver Name | Sípos Veronika |
| Unit # | 345 |
| Odometer Change | 18599 mi |
| Driving Time (HH:MM:SS) | 18:10:06 |
| Start Odometer | 18599 mi |
| End Odometer | 18599 mi |

`Odometer Change = End Odometer − Start Odometer`. Filtr `Search vehicle number` ga o'zgaradi.
**Nuqson:** oxirgi ustun sarlavhasi `Odometer Change` deb yozilgan, `End Odometer` bo'lishi kerak (`296:22009`).

### Bet 68 — Activity Report: View (`294:20263 · 296:22614`, render `Activity Report / View · 294:20263` 1400×1094)
- **Platforma:** web
- **Sarlavha:** breadcrumb `Activity Report › Driver's Name` (Units kesimida `Activity Report › Unit #`). O'ngda `Download CSV` va `Print`, sana oralig'i takrorlangan.

| USTUN | NAMUNA |
|---|---|
| # | 1 … 10 |
| Date | 17/12/2025 |
| Start | 12:33:18 AM |
| Duration | 18h:10m:06s |
| Location | 48.8566, 2.3522, 30 |
| Odometer | 18599 mi |
| Eng. Hrs | 6690 |
| Document | `N/A` yoki `1161L6WBX` |
| Notes | Ac ut consequat… |

`Status` ustuni yo'q. Nuqson: `Download CSV` tugmasi ikki joyda takrorlangan (sarlavha qatorida va filtr qatorida).

### Bet 69–70 — IFTA Report: Units va States (`303:23807`)
- **Platforma:** web (renderlar `Units · 303:24365` 1440×1301, `States · 306:32784` 1400×1265)
- **Yuqori ko'rsatkichlar:** `IFTA Miles` 18,654 · `Non-IFTA Miles` 0 · `Total Miles` 18,654 (`Total = IFTA + Non-IFTA`)
- **Filtrlar:** `Year` · `Quarter` · `State` · `Unit`. Boshqa variantda (`306:31401`): `Year` · `By Month` · `Month` · `State` · `Unit`.

**Ikki ko'rinish:**
| TAB | USTUNLAR |
|---|---|
| Units | Unit # · VIN · State · Miles · Month |
| States | State · Total Miles |

Shtat kodlari: `MA` `AZ` `SD` `MN` `OH` `OR` `DE` `AL` `XT` `MD` — **`XT` AQSh shtat kodi emas** (test ma'lumoti xatosi).

### Bet 71 — IFTA: Generate Report (`306:29752 · 306:30638`, render `IFTA (Generate report) · 306:29752` 1400×1147)
- **Platforma:** web · modal
- **Bloklar:** `GENERATE AS` — CSV / PDF tanlovi; `GET BTY` — `States & Trucks` / `States only` tanlovi

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| States * | ko'p tanlov | Select states |
| Trucks * | ko'p tanlov | Select trucks — faqat `States & Trucks` rejimida |
| Quarter * | ro'yxat | Select quarter |
| Year * | ro'yxat | Select year |

**Tugmalar:** `Cancel` / `Generate`.
**Ekrandagi eslatma:** «Reports will be ready by the fifth day of each month.»
`States only` rejimida `Trucks *` maydoni yo'qoladi (`306:30638`) — shartli maydon.
**Imlo xatosi:** `GET BTY` — ehtimol `GET BY` bo'lishi kerak.

### Bet 72 — FMCSA Report (`307:34380`)
- **Platforma:** web (renderlar `ro'yxat · 307:34977` 1400×1026, `Generate — 8 kun · 307:36440` 1400×1092, `Generate — Custom Range · 307:39467` 1400×1092)

### Bet 73 — FMCSA Report, tafsilot (`307:34380`)
- **Platforma:** web

**Ro'yxat ustunlari:**
| USTUN | NAMUNA |
|---|---|
| Driver Name | Tóth Kamilla |
| Comment | njsxndksck d |
| Start Date | 2025-04-09, 00:00:00 |
| End Date | 2025-04-16, 10:42:22 |
| Status | `Pending` / `Information` |
| Processed Time | 2025-04-16, 10:42:22 |
| Submission ID | `Pending` yoki `b814efcb-6a4c-4698-9747-5379bf3fbedb` (UUID) |

**GENERATE formasi — `REPORT DETAILS`:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Type * | ro'yxat | `Roadside inspection DOT report (8 days)` yoki `Custom Range` |
| Driver* | ro'yxat | Select driver |
| From * / To* | sana | faqat Custom Range'da — 10/02/2024 / 12/02/2024 |
| Comment * | ko'p qatorli | Add comment |

### Bet 74–75 — DVIR Report (`549:3958`)
- **Platforma:** web (renderlar `ro'yxat · 549:4080` 1440×1055, `Generate — No Defects · 549:4377` 1400×1092, `Generate — Defects corrected · 552:5102` 1400×1092)

**Ro'yxat ustunlari:**
| USTUN | NAMUNA |
|---|---|
| Driver Name | Tóth Kamilla |
| Address | 208 Olson Boulevard, Toyburgh |
| Created At | Thurs, 2025-04-16, 10:42:22 |
| Status | 7 xil qiymat |
| Action | `···` |

**7 status:** `Not Started` · `In Progress` · `Submitted` · `Submitted - No Defects` · `Submitted - Defects Found` · `Repaired` · `Certified`
(Mobil ilovadagi 3 turdan — `No-defects`, `Defects - not fixed`, `Defects - fixed` — kengroq.)

**GENERATE formasi — shartli maydonlar:** doimiy `Driver*` (Select driver), `Date *` (`--/--/--`). Natija turi tanlovi: `No Defects` / `Defects needs to be corrected` / `Defects corrected`.
| TANLOV (id) | QO'SHIMCHA MAYDONLAR |
|---|---|
| No Defects (549:4377) | `Driver's Signature *` (`Paste driver signature here`) |
| Defects needs to be corrected (549:4550) | + `Truck Defects*` (`Select truck defects`), `Trailer Defects *` (`Select trailer defects`) |
| Defects corrected (552:5102) | + `Mechanic Signature *` (`Paste mechanic signature here`) |

Imzo joylashtiriladi (`Paste …`), chizilmaydi.

### Bet 76–77 — Contact Support: tiketlar (`1187:7707`)
- **Platforma:** web (renderlar `Contact Support · 1187:7849` 1400×986, `Ticket View · 1193:8353` 1440×1005, `Status click · 1194:4616`)

**Ro'yxat:**
| USTUN | NAMUNA |
|---|---|
| Ticket # | #53326622 |
| Driver Name | Sípos Veronika |
| Subject | I karawhiua nga tuakana ak ratou rakau |
| Issue Date | 29/11/2025 11:05 AM |
| Status | `New` / `In Progress` / `Resolved` |

Filtr: `Search driver`, `Issue date`, `Status`, `Export Drivers`, `Import Drivers`.
**Nomuvofiqlik:** bo'sh holatda ustunlar `Ticket ID` va `Message`, to'la holatda `Ticket #` va `Subject`.

**TICKET DETAILS:**
| MAYDON | NAMUNA |
|---|---|
| Ticket # | 101 |
| Ticket Status | `New` |
| Driver Name | Smith john |
| Contact On | Email address |
| Email Address | abc@gmail.com |
| Issue Date | 11/02/2025 11:05 AM |
| Subject | Schedule |
| Ticket Description | Lorem Ipsum … |

**Status o'zgartirish modali:** sarlavha `Ticket Status`, ichida `Status` ro'yxati (qiymat `New`), tugmalar `Cancel` / `Save`.

### Bet 78–79 — Feedback va Chat (`1194:5057 · 283:15886`)
- **Platforma:** web (renderlar `Feedback · 1194:5207` 1440×792, `Chat · 283:15887` 1400×770)

**FEEDBACK:**
| USTUN | NAMUNA |
|---|---|
| Driver Name | Sípos Veronika |
| App Rating | yulduzchalar (1–5) |
| Feedback | Maui he tatai hei whakamanahia… |
| Submitted On | 29/11/2025 11:05 AM |

Feedback javob talab qilmaydi — holat ustuni, amal tugmasi yoki javob yozish imkoni yo'q. Uzun matnlar `…` bilan qisqartirilgan, ochilgan ko'rinish dizaynda yo'q.

**CHAT:**
- Chapda suhbatlar ro'yxati (`Search driver` bilan): Jennifer Markus, Iva Ryan, Jerry Helfer, David Elson, Mary Freund. Har satrda: ism, oxirgi xabar parchasi, vaqt.
- O'ngda yozishmalar oynasi, sarlavhada suhbatdosh ismi. Xabarlar sana/vaqt ajratgichlari bilan: `Today`, `Wed`, `06:32 PM`. Pastda kiritish maydoni: `Type your message here ...`
- Demo matnlar boshqa loyihadan («Did you finish the Hi-FI wireframes for flora app design?»).
- Chat 1440×1005. Fayl biriktirish, o'qilgan belgisi, onlayn holat dizaynda yo'q.

### Bet 80 — Settings: to'rt tab (`481:9842 · profil menyusi orqali`)
- **Platforma:** web (renderlar `Company · 481:9967` 1440×792, `Profile · 487:10921` 1400×770, `Password Setting · 487:11048` 1400×770)

**COMPANY tabi (1440×792):**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Company Name * | matn | Lorem ipsum |
| Company Address * | matn | Address |
| Home Terminal Address * | matn | Address |
| Home Terminal Time zone * | ro'yxat | Central Daylight Time |
| Email Address * | matn | abc@gmail.com |
| Phone Number * | matn | --------------- |
| US DOT * | matn | 40766678 |
| Company Logo * | fayl | Upload Logo |

**PROFILE tabi:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| First Name * | matn | Lorem ipsum |
| Last Address * | matn | Address |
| Email Address * | matn | abc@gmail.com |
| Phone Number * | matn | --------------- |

Nuqson: `Last Address *` — ehtimol `Last Name` bo'lishi kerak.

**PASSWORD SETTING tabi:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| New Password * | parol | Lorem ipsum |
| Confirm Password * | parol | Address |

Placeholder'lar mos emas; eski parolni so'rash maydoni yo'q. Barcha tablarda tugmalar `Cancel` / `Save`.
**To'rtinchi tab:** `Company history` (bet 81).

### Bet 81 — Settings: Company history (`489:11156`, render `Company history · 489:11156 · 1440×1105`)
- **Platforma:** web
- **Filtrlar — uchta mustaqil qidiruv:** `Search Driver` · `Search Dispatcher` · `Search Unit`; hamda `Export Drivers` · `Import Drivers`.
  Izoh: `Dispatcher` so'zi faqat shu ekranda uchraydi.

| USTUN | NAMUNA |
|---|---|
| Edited By | Bessie Cooper |
| Changes | `DOCUMENT changed from na to 113S1Y9MX` |
| Date | Fri, 29/11/2025 |

**O'zgarish matni formati:** `<OBYEKT> changed from <eski> to <yangi>`
Namunalar: `DOCUMENT changed from na to 113S1Y9MX`; `DOCUMENT changed from 1151QVVNM to na`; Driver Activities'dan: `Change active status from N/A to 22/022025`.
**Nuqson:** bo'sh qiymat belgisi `na` va `N/A` ikki xil yozilgan.

**To'rtta audit jurnali:**
| JURNAL | QAMROV | USTUNLAR |
|---|---|---|
| Unit Activities | bitta unit | Time Stamp · Activity |
| Driver Activities | bitta haydovchi | Time Stamp · Edited By · Activity |
| Histories | barcha haydovchilar | Driver Name · Edited By · Date |
| Company history | kompaniya sozlamalari | Edited By · Changes · Date |

### Bet 82 — Profil menyusi va Header Options (`484:10822 · 159:4970`)
- **Platforma:** web (render `Profil menyusi · 484:10822 · 252×153`, `Cover · Thumbnails Figma · 2142:16231`)
- **PROFIL MENYUSI (252×153):** kompaniya nomi (`Company Name`) · foydalanuvchi (`First name . Last name`) · `Settings` (Settings ekraniga) · `Logout` (qizil rangda). Faqat 2 amal.
- **Nav holatlari alohida chizilgan:** Header Options seksiyasida har nav holati uchun 1440×125…127 freym: `Dashboard`, `Tracking`, `Logs`, `Fleet Operations`, `Reports`, `History`, `Chat`, `Maintainance`.
- **Muqova sahifasi:** «180 + screens» va `Full version`; iPhone 14 Pro freymlarida mokaplar; begona matn «Seamless Healthcare Access Mobile App Design»; yana bir kichik muqova (`3171:224`, 360×360).
- **ADMIN PANELDA DARK TEMA YO'Q:** header'da tema almashtirgich ikonkasi (quyosh) bor, lekin dark tema ekranlari dizaynda yo'q.

---

## IV. Mobil ilova — haydovchi uchun, 393 × 852 / 854 px, Light + Dark (bet 83–107)

### Bet 83 — Bo'lim muqovasi «Mobil ilova»
`73` light ekran · `63` dark ekran · `2` bosh ekran tartibi · `44` truck defect.

### Bet 84 — Mobil: ekranlar xaritasi (`1070:6813 · Light Theme · amaldagi qatlam`)
**Asosiy oqimlar:**
| GURUH | EKRANLAR |
|---|---|
| Kirish | Splash · Login · Login-filled · Leave truck |
| Bosh ekran | ELD DISCONNECTED (2 tartib) · ELD CONNECTED · Documents modali · Yon menyu · Banner |
| Duty status | Change Status · Quick notes · Location error · IN-DRIVE FOCUSED · 5-daqiqa so'rovi |
| Co-driver | CO-DRIVER tasdiqi · Switch button (hujjat tanlash) |
| ELD | ELD not CONNECTED · Permissions |
| Log Report | Main · Logs · DVIR (bo'sh/to'la) · log satri |
| DVIR | Add DVIR · vehicle defects · truck/trailer ro'yxatlari · 3 yakuniy holat · DVIR details |
| Certify | Signature-edit (8/11 kun) · Sign (4 variant) · Certify Selected · Certify Today |
| Inspection | Inspection Report · Begin inspection · send via email · send file |
| Profil | Profile · Settings · Diagnosis · Check Network · Give feedback |
| Support | add support form · Support & Helpdesk |
| Boshqa | Chat · Notification (to'la/bo'sh) · Privacy Policy · Terms of Use |

**Navigatsiya elementlari:** tepa panel (393×54): hamburger · `OneBook ELD` · qo'ng'iroq · xat · yangilash. Yon menyu (drawer) chapdan. Pastki tab (B tartibda): 4 bo'lim — Home + 3 ikonka. Kategoriyalar qatori: `Inspection Report` · `Log Report` · `Co-driver` · `Leave Truck`.

**Prototip yozuvlari** (izoh komponentlari `Component 95` … `Component 178`): `Signup/Login screens`, `Home Screen`, `Home screen →Trip Details`, `Home screen →Signature`, `Home screen →Signature (All)`, `Home screen →Signature (Today)`, `Home screen →Banner (ELD not connected)`, `Home screen →Log (row click)`, `Home screen →Category (co-driver)`, `Change status → ON duty / Sleep / OFF duty`, `Change status → OFF duty (location error)`, `Drive mode (automaticlly)` [imlo xatosi], `Log Report Screen → Main / Log / DVIR tab`, `Add DVIR → no defects / defects not fixed / defects fixed`, `Defects List`, `Inspection Report (begin inspec / send email / send file)`, `Profile → check N/W / setting / diagnosis / feedback / support form`, `App bar → Refresh / Chat / Notification`, `leave truck`, `Privacy and Terms of Use`.

### Bet 85–86 — Mobil: kirish oqimi (`958:22 · 958:44 · 1113:9176 · 1116:9231`)
- **Platforma:** mobil 393×852 (4 render)
- Ekranlar: `Splash · 958:22`, `Login · 958:44`, `Login - filled · 1113:9176`, `Leave truck · 1116:9231`

**LOGIN ekrani:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Username or Email address | matn | Enter email address → `abc976` |
| Password | parol | Enter password → `********` (ko'z ikonkasi bilan) |

Tugma `Login`. Bo'sh holatda tugma kulrang (o'chirilgan), to'ldirilganda qora — forma validatsiyasi bor.
Matn: «This app does not support account registration. Please reach out to your fleet manager for assistance.»
Pastda: `Copyright © 2025 OneBook ELD`.
- **SPLASH:** faqat logotip, matn yo'q (0 ta TEXT tugun).
- **LEAVE TRUCK:** login formasining nusxasi + qo'shimcha `Return to truck` tugmasi.
- **Nomuvofiqlik:** yon menyuda `Leave the Truck`, kategoriyalar qatorida `Leave Truck`.

### Bet 87–88 — Mobil: bosh ekranning ikki tartibi (`A: 1202:9259 · B: 2177:12192`)
- **Platforma:** mobil (renderlar `A tartib + yon menyu · 1202:9259` 393×854; `B tartib · 2177:12192` 334×1400 — uzun scroll)
- **A TARTIB — halqasimon indikatorlar (393×854):**
  - ELD banneri: `ELD . Not connected` (qizil)
  - Haydovchi bloki: nomi, joriy status (`Off-duty`), `Unit Number: 1021`
  - `Hours of Service` — 4 halqa: `BREAK 08:00` · `DRIVE 09:00` · `SHIFT 10:00` · `CYCLE 65:00`
  - Status tugmalari: `Off-duty` · `On Duty` · `Sleep` + taymer `10:45 23`
  - `Trip Details` kartasi (qalam ikonkasi bilan)
  - `Signature` kartasi: `Certify — Not Signed`
  - Log bloki: grid + jami + jadval
- **B TARTIB — chiziqli indikatorlar (393×1650):**
  - Sana bloki: `19 / Mon, November`
  - Unit bloki: `1021 / John Smith, BMW mi7 2019`
  - Joriy status katta ko'rsatkich: `On-duty` + `10h 45m 32s`, yonida ikki o'tish tugmasi (`SB` / `OFF`)
  - `Hours of Service` — 4 chiziqli indikator, har birida `10:45 23`
  - Tezkor amallar qatori: `Inspection Report` · `Log Report` · `Co-driver` · `Leave Truck`
  - `Certify (Last 8 days)` — sarlavhada kunlar soni
  - Pastda 4 bo'limli tab navigatsiyasi
- Aniqlanmagan: qaysi tartib yakuniy ekani belgilanmagan; status tugmalari soni farq qiladi (3 ta vs 2 ta).

### Bet 89–90 — Mobil: bosh ekran holatlari (`LIGHT THEME`)
- **Platforma:** mobil 393×852 (5 render)
- Ekranlar: `Documents modali · 2230:20627`, `ELD not connected · 1102:1738`, `Permissions · 1107:2310`, `CO-DRIVER · 1113:8480`, `Switch button · 1113:8764`

**DOCUMENTS modali:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Trailer Number | teg ro'yxati | `Bobtail ×` (o'chirish belgisi bilan) |
| Shipping Document | teg ro'yxati | `N/A ×` |
| Note | matn | Add Note |

Tugmalar `Cancel` / `Save`.

**ELD ulanish xatosi:** «In order to connect to the ELD, you must allow all the permissions.» — `Cancel` / `Allow Permissions`

**PERMISSIONS ekrani:**
| RUXSAT | HOLAT |
|---|---|
| Location | `Not allowed` |
| Location always | `Not allowed` |
| Bluetooth | `Allowed` |
| Notifications | `Allowed` |
| Turn on GPS | `On` (tugmacha/toggle) |
| Turn on bluetooth | `Off` (tugmacha/toggle) |

Yon menyudagi `Permissions` bandida qizil ogohlantirish belgisi.

**CO-DRIVER almashuvi:** «Are you sure you want to switch to co-driver?» — `Cancel` / `Switch`.
`Select shipping document`: `Myself` (`Documents: N/A` `Trailers: Bobtail`) / `Co-driver` (`Documents: N/A` `Trailers: N/A`).

### Bet 91–92 — Mobil: duty status boshqaruvi (`1083:10550 · 1170:2313 · 1102:2021`)
- **Platforma:** mobil (renderlar `Change Duty Status · 1083:10550` 393×891, `Quick notes · 1170:2313`, `Location error · 1102:2021`, `IN-DRIVE FOCUSED · 1170:2684`, `5-daqiqa so'rovi · 2181:17282` — barchasi 393×852)
- **CHANGE DUTY STATUS:** yuqorida HOS indikatorlari takrorlanadi. Status tanlash: `On Duty` · `Sleep` · `Off Duty`

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Location | matn | Enter Location |
| Notes | matn | Enter Notes |
| Trailer Number | matn | Bobtail |
| Shipping Document | matn | N/A |

`DR (Drive)` tugmasi yo'q — avtomatik aniqlanadi (komponent nomi: `Drive mode (automaticlly)`).
Boshqa variantda eslatma: «Please change your status to update trailer and document.»
- **QUICK NOTES — 10 shablon:** `PTI` · `Hook` · `Pickup` · `Dropoff` · `Delivery` · `Inspection` · `Checkin` · `Fueling` · `Checkout` · `Other`
  Eslatma: «Notes field has max 60 character limit». Tugmalar `Cancel` / `Add Notes`.
- **Joylashuv xatosi:** «It looks like your location might be inaccurate. Want to update it?» / «It might take a few moments to proceed!» — `Cancel` / `Update Now`
- **Haydash rejimi (IN-DRIVE FOCUSED):** ekran to'liq band — `Duty Hours`, `In-motion`, `11 MAY, 2025 11:05 PM`, katta hisoblagich `09:00:20` + `DRIVE`, `Driving Time Left 02:32:02`, `Current Location 342, Plot B`.
- **5-daqiqa so'rovi:** «You've been idle for 5 minutes. Are you still driving?» — `No` / `Yes, Driving`

### Bet 93–94 — Mobil: Log Report (`1085:14341 · 1085:13169 · 1154:6104`)
- **Platforma:** mobil 393×854/852 (5 render)
- Ekranlar: `Main · 1085:14341`, `Logs · 1085:13169`, `DVIR bo'sh · 1087:14921`, `DVIR to'la · 1154:6104`, `Log satri · 1111:7334`
- **Umumiy elementlar:** tablar `Main` · `Logs` · `DVIR`; 8 kunlik sana tasmasi `Fri 07 … Fri 14`, joriy kun **qizil**; pastda `Log Report` tab elementi faol.

**MAIN tabi:**
| MAYDON | NAMUNA |
|---|---|
| Shipping documents | N/A |
| Trailer numbers | bobtail |
| Certify | `Not Signed` |
| Notes | Lorem ipsum |

`Driver Information` bloki: `Driver Name`, `Unit #` (1234), `Main Terminal` (5432 Lorem Ipsum).

**LOGS tabi:** grid (`OFF` / `SB` / `DR` / `ON`) + jami `OFF 03:06` · `SB 00:00` · `DR 00:00` · `ON 00:00` + `Warning: Trailer is not set` + jadval `Status` · `Start Time` · `Location` · `Document`. Kengaytirilgan jadval (`2230:21266`): + `Trailers` · `Notes` · `Action`.

**DVIR tabi:**
| USTUN | QIYMATLAR |
|---|---|
| Trailer Number | `Bobtail` / `N/A` |
| Type | `No-defects` · `Defects - not fixed` · `Defects - fixed` |
| Created At | May 28, 02:24:54 PM |

Bo'sh holat: `No DVIR Found` + `There is no data to show you right now`.

**LOG SATRI bosilganda:** log kartasi — `Status` (`ON`), `Start`, `Duration` (`22:02:21`), `Location`, `Odometer` (324543), `Engine hours` (333.22), `Notes`.

### Bet 95–96 — Mobil: DVIR yaratish oqimi (`1089:4441 → 1090:5027`)
- **Platforma:** mobil 393×852 (5 render)
- Oqim: `Add DVIR` (Trailer + nuqsonlar) → `No Defects` (Driver Signature) → `Defects not fixed` (Driver Signature) → `Defects fixed` (+ Mechanic Signature)

**ADD DVIR formasi:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Unit Number | avtomatik | 1021 |
| Trailers | matn | Enter Trailer Number |
| Truck Defects | tanlash | `Add Defects` + `+` |
| Trailer Defects | tanlash | `Add Defects` + `+` |

`Driver Information` bloki — avtomatik to'ldiriladi: `Time` (May 20, Tue), `Location` (Lorem ipsum), `Odometer` (1000).
Tugmalar `Cancel` / `Next`.

**Yakuniy qadam — uch variant:**
| HOLAT (id) | TANLOV | IMZO |
|---|---|---|
| nuqson yo'q (1090:4687) | `No Defects` | Driver Signature |
| nuqson bor (1090:4901) | `Selected defects needs to be fixed` / `Selected defects fixed` | Driver Signature |
| tuzatilgan (1090:5027) | yuqoridagi ikki tanlov | Driver Signature + Mechanic Signature |

Barchasida `Cancel` / `Confirm`.
**Nuqson tanlash ekrani:** ikki ro'yxat (`Truck defects` / `Trailer defects`), birinchisida `Accident Photo` yuklash bandi. Tugmalar `Cancel` / `Save`.

### Bet 97–98 — Mobil: nuqson ro'yxatlari (`1169:1887` 44 band · `1169:2106` 13 band)
- **Platforma:** mobil (renderlar `Truck defects · 1169:1887 · 301×1487`, `Trailer defects · 1169:2106 · 301×467`)

**TRUCK DEFECTS — 44 band:** Accident Photo · Engine · Battery · Exhaust · Air Lines · Body · Brake Accessories · Brakes, Parking · Brakes, Service · Clutch · Coupling Device · Defroster/Heater · Drive Line · Engine (takror) · Fifth Wheel · Frame & Assembly · Front Axle · Fuel Tanks · Horn · Lights (Head - Stop) · Lights (Turn Indicators) · Mirrors · Mufflers · Oil Pressure · Radiator · Rear End · Refresh (?) · Safety Equipment (Fire Extinguisher) · Safety Equipment (Reflective) · Safety Equipment (Flags - Flares) · Safety Equipment (Spare Bulbs) · Safety Equipment (Spare Seal Beam) · Suspension System · Starter · Steering · Tachograph · Tires · Tire Chains · Transmission · Wheel & Rims · Windows · Windshield Wipers · Other

**Nuqson:** `Engine` ikki marta takrorlanadi; `Refresh` bandi nuqson emas — ro'yxatga tasodifan tushgan.

**TRAILER DEFECTS — 13 band:** Brake Connections · Brakes · Coupling Device · Doors · Hitch · Landing Gear · Lights - All · Roof · Suspension System · Tarpaulin · Tires · Wheel & Rims · Other

**DVIR DETAILS ko'rinishi (`1166:869`):** `Time` (`May 20, 11:05 PM`), `Location` (`3.40 mi West of BRIDGE`), `Odometer` (`1000`), so'ngra tanlangan `Truck defects` va `Trailer defects` ro'yxatlari.
Izoh: admin DVIR Generate formasida ham shu ikki ro'yxat ishlatiladi.

### Bet 99–100 — Mobil: sertifikatsiya (Certify) (`1102:397 · 1102:817`)
- **Platforma:** mobil 393×852 (4 render)
- Ekranlar: `Certify (Last 8 days) · 1102:397`, `Certify (Last 11 days) · 1102:931`, `Sign · 1102:817`, `Not Ready · 1102:1260`
- **Kunlar ro'yxati:** sarlavha `Certify (Last 8 days)` yoki `Certify (Last 11 days)` — **dizaynda ikki xil**. Yuqorida `Certify Today` tugmasi.

| SANA | HOLAT |
|---|---|
| Tue, May 20 | `Uncertified` |
| Mon, May 19 | `Uncertified` |
| Sun, May 18 | `Certified` |

**Pastdagi tugma tanlovga qarab:**
| HOLAT | TUGMA |
|---|---|
| tanlov yo'q | `Certify All` |
| 1 kun tanlangan | `Certify Selected (1)` |
| bugungi kun | `Certify Today` |

**SIGN ekrani — 4 variant:**
| TUGUN | FARQI |
|---|---|
| 1102:817 | `Use my signature` + `Save my signature` |
| 2590:23861 | imzo saqlangan holat |
| 2590:24226 | `Save my signature` siz |
| 1102:1599 | `Sign Button` varianti |

Matn: «I hereby certify that my data entries and my record of duty status for 24 hour period are true and correct». Tugmalar `Cancel` / `Confirm`.
**NOT READY holati:** sana + `Not Ready` / `Sign`. Kun sertifikatsiyaga tayyor bo'lmasligi mumkin — sharti dizaynda ko'rsatilmagan.

### Bet 101–102 — Mobil: Inspection Report (yo'l tekshiruvi) (`1111:7825`)
- **Platforma:** mobil 393×854 (4 render)
- Ekranlar: `Inspection Report · 1111:7825`, `Begin inspection · 1111:8013`, `send via email · 1169:1196`, `send file to DOT · 1169:1332`

**Uch mustaqil amal:**
| AMAL | TAVSIF MATNI | TUGMA |
|---|---|---|
| 1 | «Review the logs for the past 7 days + today» / «Click "Begin Inspection" button, and hand your device to the officer.» | `Begin Inspection` |
| 2 | «Send the logs for the past 7 days + today via email» / «Email your logs to the officer if they request a paper copy.» | `Send via email` |
| 3 | «Send the ELD output file to the Insection officer» / «Send your ELD Output file for the inspection if the officer requests.» | `Send the file` |

Oyna: 7 kun + bugun (log tasmasi ham 8 kunlik; FMCSA `Roadside inspection DOT report (8 days)` bilan mos).
- **BEGIN INSPECTION rejimi:** ekran soddalashadi — faqat sana tasmasi va log grid, navigatsiya olib tashlanadi.
- **SEND VIA EMAIL formasi:** `Email Address` (matn, placeholder `Enter email address`). Tavsif: «Email your logs to the officer if they request a paper copy». Tugmalar `Cancel` / `Send Logs`.
- **SEND FILE FOR INSPECTION:**

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Type | tanlov | `Web service` / `Email` |
| Email Address | matn | faqat `Email` tanlanganda (`2695:1078`) |
| Comment | matn | Write output file comment |

**Imlo xatosi:** `Insection` — `Inspection` bo'lishi kerak.

### Bet 103–104 — Mobil: profil va sozlamalar (`1119:445 · 1131:392`)
- **Platforma:** mobil 393×854/852 (5 render)
- Ekranlar: `Profile · 1119:445`, `Settings · 1131:392`, `Diagnosis · 1131:965`, `Check Network · 1122:319`, `Feedback · 1131:1149`
- **PROFILE ekrani:** avatar (bosh harflar `AK`), `Abdullah Khan . 1021`, `abc@gmail.com . +92 3345677788`, `1123456788 . California` (litsenziya . shtat).
  Menyu bandlari: `Settings ›` · `Check network ›` · `Zoom` (tugmacha/toggle) · `Dark mode` (tugmacha/toggle) · `Feedback ›` · `Customer support ›` · `User Manual ›`
  Izoh: eskirgan qatlamda (`1206:14181`) bu ro'yxatda `Maintenance` bandi ham bor edi — amaldagi dizaynda olib tashlangan.
- **SETTINGS:** ikki band — `Diagnosis of device` · `App updates`.
- **DIAGNOSIS OF DEVICE:**

| KO'RSATKICH | QIYMAT |
|---|---|
| ELD coordinates | `Not working` |
| GPS coordinates | `Not working` |
| Network quality | `Good` |

- **CHECK NETWORK:** yarim doira o'lchagich, shkala `0 · 20 · 30 · 50 · 75 · 100`, markazda qiymat (`0.00` yoki `14.00`) va birlik `mbps`. Tugma `Check Network`.
- **FEEDBACK:** «Share your experience to help us improve.»
  1) «How would you rate your overall experience with the mobile app?» — yulduzchalar
  2) «What new features or improvements would you like to see in the mobile app?» — `Write here..`
  Tugma `Submit`.

### Bet 105–106 — Mobil: support, chat, bildirishnoma, huquqiy (`1179:7028 · 1118:114 · 1156:7135`)
- **Platforma:** mobil 393×854/852 (6 render)
- Ekranlar: `add support form · 1179:7028`, `Support & Helpdesk · 1179:7142`, `Chat · 1118:114`, `Notification · 1156:7135`, `bo'sh · 1156:7244`, `Privacy Policy · 2627:25778`

**CONTACT SUPPORT formasi:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Aloqa kanali | tanlov | `Email address` / `Phone number` |
| Subject | matn | Add ticket subject |
| Ticket description | ko'p qatorli | Description |

Tugmalar `Cancel` / `Confirm`.
- **SUPPORT & HELPDESK ro'yxati:** har tiket — sana-vaqt (`12/02/2024 11:05 am`), holat badge'i (`In Progress` / `New` / `Resolved`), `#122546`, `Ticket Subject`, tavsif, `Contact On: Phone number` / `Email address`. Haydovchi holatni o'zgartira olmaydi.
- **NOTIFICATION — uch tur:**

| SARLAVHA | MATN |
|---|---|
| Admin has added a new route. | «From "ABC LOCATION" to "XYZ LOCATION"» |
| Maintenance overdue | «Maintenance was due 2 days ago.» |
| Maintenance upcoming | «You have a maintenance of type "Oil Change" after 100 miles.» |

Sana bo'yicha guruhlangan (`May 28, 2025`, `April 08, 2025`), har birida nisbiy vaqt (`2hrs`).
**Bo'sh holat:** `No Notifications Yet` + «Stay tuned! Important updates and alerts will appear here.»
- **HUQUQIY SAHIFALAR:** `Privacy Policy` va `Terms of Use` — bo'lim sarlavhasi `Overview Acceptance` va uzun matn bloki.
  Nuqson: matn boshqa mahsulotga tegishli — «Jusoor», «ONTime Log», «OnTime ELD» nomlari, Saudiya biznes platformasi kontenti.

---

## V. Planshet ilovasi — kabinada o'rnatilgan, 1366 × 1024 px, Light + Dark (bet 107–127)

### Bet 107 — Bo'lim muqovasi «Planshet ilovasi»
`52` light ekran · `51` dark ekran · `12` modal turi · `1` asosiy ekran.

### Bet 108 — Planshet: konsepsiya farqi (`1470:21013 · amaldagi qatlam`)
| JIHAT | MOBIL | PLANSHET |
|---|---|---|
| Navigatsiya | ekrandan ekranga o'tish | yagona ekran + modallar |
| Bosh ekran | vertikal scroll | uch ustunli, scroll'siz |
| HOS | halqa yoki chiziq | 4 halqa, katta |
| Amallar | yon menyu + kategoriyalar | `Actions` paneli |
| Log grid | alohida ekranda | doim ko'rinib turadi |
| Menyu | chapdan drawer | chapdan drawer (bir xil) |

**Eskirgan iteratsiya bilan farqi:** yashirilgan `Section 3` (`1495:43530`) da gorizontal menyu bo'lgan: `OneBook ELD` · `Home` · `Change Status` · `Log Report` · `Message` · `Options` · `Online`. Amaldagi dizaynda olib tashlangan.
Eskirgan qatlamda `Log Report / DVIR` bo'sh holati ham bor edi: `No DVIR Added Yet` + «Start to add your first report by clicking button below.» + `Add DVIR`.

### Bet 109 — Planshet: bosh ekran anatomiyasi (`1470:42666 · HOME/FULL SCREEN`, render 1366×1024)
- **Platforma:** planshet 1366×1024
- **TEPA PANEL:** markazda logotip, o'ngda xat, qo'ng'iroq, yangilash, tema almashtirgich; chapda ELD holati (`ELD . Connected`).
- **CHAP/MARKAZ — HOURS OF SERVICE:** `BREAK 08:00` · `DRIVE 09:00` · `SHIFT 10:00` · `CYCLE 65:00`
- **DUTY STATUS paneli:** joriy status (`On-duty`) va o'tish tugmalari (`Sleep`, `Off-duty`) + taymer `10:45 23`. Panel tepasida `Search Item ...` qidiruvi.
- **KARTALAR QATORI:** `Shipping Doc` · `Trailer Number` · `Notes` — `Trip Details` guruhida, `Edit` qalami bilan. O'ngda `Certify` kartasi — `Not Signed`, qizil ramka bilan.
- **O'NG USTUN — ACTIONS:** `FMCSA / Inspection Report` · `Co-driver` · `Leave Truck`
- **PASTKI QISM:** 24 soatlik log grid (`OFF` / `SB` / `DR` / `ON`) + jami `11:03` · `00:00` · `05:30` · `00:00`; `Violation: Trailer is not set` (qizil satr); `Warning: Trailer is not set` (sariq satr); jadval `Status` · `Start Time` · `Location`; hujjatlar jadvali `558612 / 01/25/2023 / ism`.

### Bet 110–111 — Planshet: yon menyu va log paneli (`2142:25753 · 2142:15234`)
- **Platforma:** planshet (renderlar `Yon menyu · 2142:25753 · 314×1024`, `Log paneli · 2142:15234 · 1326×597`)
- **YON MENYU tarkibi:** yuqorida avatar `AK`, `Abdullah Khan . 1021`, `abc@gmail.com . +92 3345677788`, `1123456788 . California`
  Bandlar: `Zoom` (tugmacha, yoqilgan) · `Check Network` · `Permissions (!)` · `Feedback` · `Customer Support` · `User Manual` · `Diagnosis of Device` · `App Updates` · `Logout` (qizil)
  Pastda: `Terms & Condition . Privacy Policy`
  Mobil Profile menyusidan farqi: planshetda `Dark mode` tugmachasi yo'q (tepa paneldagi ikonka orqali), lekin `Diagnosis of Device`, `App Updates`, `Terms & Condition` qo'shilgan.
- **LOG PANELI (kengaytirilgan):** grid ostidagi jami boshqacha formatda: `Off - 00:00` · `Sleep - 00:00` · `Driving - 06:23` · `On - 00:00` (mobilda qisqartma: `OFF 03:06` · `SB 00:00` · `DR 00:00` · `ON 00:00`) — **nomuvofiqlik**.
- **Kengaytirilgan jadval ustunlari:** `Status` · `Start Time` · `Location` · `Document` · `Trailers` · `Notes` · `Edit`
  Namuna qiymatlar: `ON / 02:03:23 AM / Glendale Store Front`, `DR / 04:03:23 AM / Burbank Store Front`, `SB / 02:03:23 PM / Pasadena Store Front`
  Nomuvofiqlik: oxirgi ustun planshetda `Edit`, mobilda `Action`.

### Bet 112–113 — Planshet: asosiy modallar (sarlavha qatori: `Cancel · sarlavha · amal`)
- **Platforma:** planshet 1366×1024 / 1350×1012
- Renderlar: `Edit Documents · 1470:19197`, `Change Duty Status · 1470:28679`, `Quick Notes · 1470:30704`

**EDIT DOCUMENTS:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Trailer Number | matn | Bobtail |
| Shipping Document | matn | N/A |
| Notes | ko'p qatorli | Add notes |

Sarlavha qatori: `Cancel` · `Edit Documents` · `Save`

**CHANGE DUTY STATUS:** modal ichida HOS indikatorlari takrorlanadi. Status tanlash: `On-duty` · `Sleep` · `Off-duty`
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Trailer Number | matn | Bobtail |
| Shipping Document | matn | N/A |
| Location | matn | Enter location (ogohlantirish ikonkasi bilan) |
| Notes | matn | Enter notes (`+` tugmasi bilan) |

Modal pastidagi izoh: «Please change your status to update trailer and document.»

**QUICK NOTES:** `Change Duty Status` ichidagi `+` orqali. 10 shablon: `PTI` · `Hook` · `Pickup` · `Drop off` · `Delivery` · `Inspection` · `Checkin` · `Fueling` · `Check out` · `Other`
Eslatma: «Notes field has max 60 character limit»
**Nomuvofiqlik:** mobilda `Dropoff` (bo'shliqsiz) va `Checkout`; planshetda `Drop off` va `Check out`.
Boshqa mobil variantda (`1232:14150`) butunlay boshqa to'plam: `Break`, `Shower`, `Breakfast`, `Dinner`, `Rest`, `Rest room`, `Sleep`, `Other`.

### Bet 114 — Planshet: co-driver, log detali, joylashuv (`1517:51373 · 1517:52371`)
- **Platforma:** planshet 1350×1012 (4 render)
- Renderlar: `Switch co driver · 1517:51373`, `Select Shipping Document · 1517:53372`, `Location error · 1470:29713`, `Log Detail · 1517:52371`

### Bet 115 — Planshet: co-driver, log detali, joylashuv (tafsilot)
- **CO-DRIVER ALMASHUVI:** «Are you sure you want to switch to co-driver?» — `Cancel` / `Switch`
- **SELECT SHIPPING DOCUMENT:**

| VARIANT | DOCUMENTS | TRAILERS |
|---|---|---|
| Myself | N/A | Bobtail |
| Co-driver | N/A | N/A |

Tugmalar `Cancel` / `Confirm`.
- **JOYLASHUV XATOSI:** «It looks like your location might be inaccurate. Want to update it?» / «It might take a few moments to proceed!» — `Cancel` / `Update Now`
- **LOG DETAIL modali:**

| MAYDON | NAMUNA |
|---|---|
| Status | `ON` |
| Start | 02:23:43 PM, 22 May |
| Duration | 22:02:21 |
| Location | 3.40 mi west of easr avon, NY |
| Odometer | 324543 |
| Engine hours | 333.22 |
| Notes | Lorem ipsum |

Log jadvalidagi satr bosilganda ochiladi (mobildagi `Eac row (on-click)` ekrani bilan bir xil).
**Imlo xatosi:** `easr avon` — `East Avon` bo'lishi kerak.

### Bet 116–117 — Planshet: sertifikatsiya (`1470:20134 · 1470:22044 · 1470:22998`)
- **Platforma:** planshet 1366×1024 / 1350×1012 (3 render)
- Renderlar: `Certify (Last 8 days) · 1470:20134`, `Sign · 1470:22044`, `Not Ready · 1470:22998`
- **KUNLAR RO'YXATI modali:** sarlavha qatori `Cancel · Certify (Last 8 days) · Certify Today`. Har satrda belgilash katakchasi; birinchi satrda qo'shimcha `Today` belgisi.

| SANA | BELGI | HOLAT |
|---|---|---|
| Tue, May 20 | `Today` | `Uncertified` |
| Mon, May 19 | — | `Uncertified` |
| Sun, May 18 | — | `Certified` |

Pastda yashil tugma: `Certify All` yoki `Certify Selected (1)`.
Mobildan farqi: planshetda sertifikatlangan kunlar ham belgilangan holatda ko'rsatiladi.
- **SIGN modali:** sarlavha qatori `Cancel · Mon, 12 May · Save`

| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Driver Signature | chizish maydoni | — |
| Use My Signature | havola | saqlangan imzoni qo'llash |
| Save my signature | belgilash | faqat 1470:22044 variantida |

Matn: «I hereby certify that my data entries and my record of duty status for 24 hour period are true and correct»
Ikki variant: `1470:22044` (Save my signature bilan), `2417:29993` (usiz).
- **NOT READY:** sarlavha qatori `Not Ready · Mon, 12 May · Sign`.

### Bet 118–119 — Planshet: Log Report va Inspection Report (`2142:16317 · 2156:46277`)
- **Platforma:** planshet 1366×1024 (3 render)
- Renderlar: `Log Report / Main · 2142:16317`, `Log Report / Logs · 2142:22733`, `Inspection Report · 2156:46277`
- **LOG REPORT:** tablar `Main` · `Logs` · `DVIR`. Sana tasmasi `07 Jan … 14 Jan` (oy nomi bilan; mobilda hafta kuni bilan — nomuvofiqlik).

| TAB | KONTENT |
|---|---|
| Main | `Trip Details`: `Shipping Doc`, `Trailer Number`, `Signed` / `Not Signed`, `Notes`, `Driver Name` (Abdullah Shah), `Unit #` (1021), `Main Terminal` (234 Lorem ipsum) |
| Logs | `Log Details` — grid + jami + ogohlantirishlar + kengaytirilgan jadval |
| DVIR | ro'yxat: `Trailer Number` · `Type` · `Created At` |

- **INSPECTION REPORT:** mobil uch amal bloki bilan bir xil, lekin chapda `Log Detail` paneli va sana tasmasi ko'rinib turadi.

| MODAL (id) | MAYDONLAR |
|---|---|
| Send via Email (2156:47218) | `Email Address` (`Enter email address`) — `Cancel` / `Send Logs` |
| Send file to DOT (2156:48249) | `Web service` / `Email address`, `Email Address`, `Comment` (`Write output file comment`) — `Cancel` / `Send` |

**Nomuvofiqlik:** planshetda «Send the ELD output file to the DOT officer», mobilda «… to the Insection officer».
Ikkinchi variant `2697:21073` da `Email Address` maydoni yo'q (Web service tanlangan holat).

### Bet 120–121 — Planshet: sozlama modallari va haydash rejimi (`2142:26925 · 2190:90626`)
- **Platforma:** planshet 1350×1012 / 1366×1024 (6 render)
- Renderlar: `Check Network · 2142:26925`, `Permissions · 2142:28945`, `Diagnosis · 2142:31232`, `Feedback · 2142:32880`, `drive-focused · 2190:90626`, `5 mint idle · 2195:97628`

| MODAL | MAZMUNI |
|---|---|
| Check Network | yarim doira o'lchagich, `0.00 mbps`, `Check Network` tugmasi |
| Permissions | `Location`, `Location always`, `Bluetooth`, `Notifications` + `Turn on GPS`, `Turn on bluetooth` |
| Diagnosis of Device | `ELD coordinates`, `GPS coordinates`, `Network quality` |
| Feedback | reyting + ikki savol, `Cancel` / `Submit` |

Nuqson: Feedback matnida «mobile app» deyilgan — planshetda ham mobil matni.
- **HAYDASH REJIMI:** `Duty Hours` sarlavhasi; `In-motion` + `11 May, 2025 12:05 AM`; katta hisoblagich `09:00:20` + `DRIVE`; `Driving Time Left 02:32:02`; `Current Location 342, Plot B`.
  «You've been idle for 5 minutes. Are you still driving?» — `No` / `Yes, driving`
  **Nomuvofiqlik:** mobilda `Yes, Driving` (bosh harf), planshetda `Yes, driving`.
  Yashirilgan qatlamda `Change Status / Duty Hours` (`1343:2980`) ekranida uch hisoblagich: `BREAK 05:00`, `DRIVE 05:00`, `SHIFT 05:00`.

### Bet 122–123 — Planshet: Contact Support va bildirishnomalar (`2146:35984 · 2150:41614`)
- **Platforma:** planshet 1366×936 / 1350×926 / 1350×1012 (4 render)
- Renderlar: `Contact Support · 2146:35984`, `Add Ticket · 2146:39644`, `bo'sh holat · 2146:38704`, `Notification · 2150:41614`

**CONTACT SUPPORT — to'liq sahifa jadvali:**
| USTUN | NAMUNA |
|---|---|
| Ticket ID | #122221 |
| Subject | `Support request`, `New contact request`, `Change request`, `Delete contact request` |
| Description | uzun matn, `…` bilan qisqartirilgan |
| Date & Time | 15 May 2020 11:00 pm |
| Contact On | `Email Address` / `Phone Number` |
| Status | `New` / `In-Progress` / `Resolved` |

**Nomuvofiqlik:** admin panelda `In Progress` (bo'shliq bilan), planshetda `In-Progress` (defis bilan).

**ADD TICKET modali:**
| MAYDON | TUR | PLACEHOLDER / QIYMAT |
|---|---|---|
| Aloqa kanali | tanlov | `Email address` / `Phone number` |
| Subject | matn | Add ticket subject |
| Ticket description | ko'p qatorli | Description |

Tugmalar `Cancel` / `Confirm`.
**BO'SH HOLAT:** `No Ticket Added Yet` + «Start to add your first ticket by clicking button below.» + `Add Ticket` — admin paneldagi `No Data Found` dan farq qiladi.
**BILDIRISHNOMALAR:** mobil bilan bir xil uch tur, lekin vaqt absolyut formatda `28 May, 10:04 am` (mobilda nisbiy `2hrs`).

---

## VI. Dark tema (bet 124–128)

### Bet 124 — Bo'lim muqovasi «Dark tema»
`63` mobil dark ekran · `51` planshet dark ekran · `0` admin dark ekran.

### Bet 125–126 — Dark tema: mobil va planshet (`2665:25648 · 2197:104566`)
- **Platforma:** mobil 393×851 + planshet 1366×1024
- Renderlar: `Mobil · dark tema`, `Planshet · dark tema · 2186:30658`

**Dark tema ranglari:**
| USLUB | HEX | QAYERDA |
|---|---|---|
| Color's/Bg Dark | `#1B222C` | asosiy fon |
| Color's/Grey Dark | `#303E4B` | kartalar foni |
| Color's/Dark stroke | `#52565F` | chegaralar |
| Color's/Sidebar | `#233040` | yon panel |
| Neutral 9–11 | `#23262F … #18191D` | chuqurroq sathlar |

**Nima o'zgaradi:** fon va karta ranglari almashadi; matn ranglari teskari (Neutral 1–3); Primary, State va Decorative ranglar o'zgarmaydi (status badge'lari, HOS halqalari, ogohlantirish satrlari bir xil); chegaralar `Dark stroke` ga o'tadi.

**Qamrov:**
| KLIENT | DARK TEMA | QATLAM |
|---|---|---|
| Mobil | to'liq | 2665:25648 + nusxa 3497:433 |
| Planshet | to'liq | 2197:104566 |
| Admin Panel | yo'q | — |

**Almashtirish:** mobil — `Profile › Dark mode` tugmachasi; planshet — tepa paneldagi tema ikonkasi; admin — ikonka bor, ekranlari chizilmagan.
Dark temada faqat ikki-uch ekran qo'shimcha: `drive-focused` (2190:90626), `5 mint idle` (2195:97628), `menu` (2197:103777).

### Bet 127–128 — Dark tema: planshet menyusi va farqlar (`2197:103777`)
- **Platforma:** planshet 1350×1012 (renderlar `Planshet dark · menu · 2197:103777`, `Planshet light · feedback · 2142:32880`)

**Dark temadagi ekran nomlari farqi:**
| LIGHT | DARK |
|---|---|
| Edit Documents | edit doc |
| Log (row click) | log (row click) |
| Home/Full screen | Home/Full screen.. |
| Certify (No date selected) | Certify (date selected) — qo'shimcha holat |

**Faqat dark temada mavjud ekranlar:** `drive-focused` 2190:90626 · `5 mint idle` 2195:97628 · `menu` 2197:103777 · `Certify (date selected)` ×2 · `Switch co driver` ×2 · `Container` 2373:20953
**Faqat light temada mavjud:** `Frame 1321317424` (log paneli) · `codriver - document` · `Hours of service (clicked)`
**Mobil dark tema ekranlar soni:** Light 73 · Dark 63 — 10 ekran dark temada chizilmagan (asosan `Add DVIR` oqimi va `vehicle defects`).

---

## VII. Ma'lumot lug'ati (bet 129–136)

### Bet 129 — Bo'lim muqovasi «Ma'lumot lug'ati»
`17` obyekt turi · `9` status to'plami · `44` truck defect · `13` trailer defect.

### Bet 130 — Duty status va HOS (barcha klientlarda umumiy)
**Duty status kodlari:**
| KOD | TO'LIQ NOMI | QAYERDA UCHRAYDI | QO'LDA TANLANADIMI |
|---|---|---|---|
| OFF | Off-duty / Off Duty | barcha klient | ha |
| SB | Sleep / SLEEP | barcha klient | ha |
| DR | Drive / DRIVING | barcha klient | yo'q — avtomatik |
| ON | On-duty / On Duty | barcha klient | ha |
| ON (YM) | Yard Move (to'liq nomi yozilmagan) | faqat admin log tahrirlash | faqat admin |
| OFF (PC) | Personal Conveyance (to'liq nomi yozilmagan) | faqat admin log tahrirlash | faqat admin |

**HOS — 4 hisoblagich:** `BREAK 08:00` · `DRIVE 09:00` · `SHIFT 10:00` · `CYCLE 65:00`
Boshqa ekranlarda: `08:00 / 11:00 / 14:00 / 70:00` (admin Logs By Unit jadvali).
Nima ko'rsatadi: qolgan vaqt, sarflangan emas (dalil: `Driving Time Left 02:32:02`, `Shift Ends in 01:10:23`). `CYCLE` ko'p kunlik oyna. Admin jadvalida qo'shimcha `Recap` ustuni.
**Aniqlanmagan:** hisoblash formulalari, 65:00 va 70:00 orasidagi tanlov qoidasi, tiklash (reset) sharti, `Recap` mantiqi.

### Bet 131 — Barcha status to'plamlari (modul bo'yicha)
| MODUL / OBYEKT | MAYDON | QIYMATLAR |
|---|---|---|
| Haydovchi | duty status | `OFF` · `SB` · `DR` · `ON` (+ `ON (YM)`, `OFF (PC)`) |
| Qurilma (admin) | Device Status | `Online` · `Offline` · `Disconnected` |
| Qurilma (mobil/planshet) | banner | `ELD . Connected` · `ELD . Not connected` · `ELD not connected` |
| Log voqeasi | Status | `DR` · `OFF` · `PTI` · `POWER OFF` · `POWER ON` · `FUEL` · `CERTIFY` |
| Marshrut | Status | `Completed` · `Ongoing` |
| Maintenance | Status (History) | `Completed` · `Cancelled` |
| Maintenance | Schedule Name | `Scheduled PM` · `Scheduled` · `New` · `Urgent` |
| DVIR (mobil) | Type | `No-defects` · `Defects - not fixed` · `Defects - fixed` |
| DVIR (admin) | Status | `Not Started` · `In Progress` · `Submitted` · `Submitted - No Defects` · `Submitted - Defects Found` · `Repaired` · `Certified` |
| Tiket | Status | `New` · `In Progress` / `In-Progress` · `Resolved` |
| FMCSA hisobot | Status | `Pending` · `Information` |
| Sertifikatsiya | kun holati | `Certified` · `Uncertified` · `Not Ready` |
| Imzo | Signature / Certify | `Signed` · `Not Signed` |
| Unit / Driver | faollik | `Active` · `Inactive` |

### Bet 132 — Obyektlar va maydonlari (ekranlardan chiqarilgan ma'lumot modeli)
| OBYEKT | KALIT MAYDONLAR |
|---|---|
| Company | Company Name · Company Address · Home Terminal Address · Home Terminal Time zone · Email · Phone · US DOT · Company Logo |
| User | First/Last Name · Email · Role · Phone |
| Role | Role Name · ruxsatlar to'plami |
| Driver | First/Last Name · Username · Password · Email · Phone · Unit # · Co-Driver · License Plate Number + Issue State · City · State · Zip · Fleet Manager · Home Terminal Address · Address 1/2 · Notes · App Version · Activated On |
| Unit | Unit # · ELD · Make · Model · Year · License Plate Number + Issue State · Fuel Type · VIN · Sleeper Berth · Notes · Activated On |
| ELD Device | Device ID · ulanish holati · VIN · Engine Hours · Odometer · Fuel · Bus · Coolant Level/Temp · Oil Level |
| Duty Status Event | Status · Start · Duration · Location · Odometer · Engine Hours · Notes · Document · Trailer |
| Daily Log | Sana · grid · jami · Certified · Log Form |
| DVIR | Unit · Trailer Number · Truck/Trailer defects · Driver Signature · Mechanic Signature · Type · Created At · Time/Location/Odometer |
| Maintenance Schedule | Unit(lar) · Type · Schedule Name · Maintenance Frequency · Reminder · Current/Next Frequency · Alert Type · Delivery Method · Notify co-driver · Notes |
| Maintenance Record | Maintenance Date · Invoice # · Vendor Name · Cost · Odometer · Engine Hours · Attachment · Status |
| Trip / Route | Unit # · Date · Driver · From · To · Status · Coordinates · Duration · Stopped |
| Ticket | Ticket # · Driver · Subject · Description · Contact On · Issue Date · Status |
| Feedback | Driver · App Rating · Feedback · Submitted On |
| Report | turi bo'yicha parametrlar · Status · Submission ID · Processed Time |
| Notification | Sarlavha · matn · vaqt |
| Chat message | Matn · vaqt · yuboruvchi |

### Bet 133 — Majburiy va shartli maydonlar (dizaynda `*` bilan belgilangan)
**Majburiy maydonlar — modul bo'yicha:**
| MODUL | MAJBURIY |
|---|---|
| Unit | Unit # · ELD · Make · Model · License Plate Number · Fuel Type |
| Driver | First Name · Last Name · Username · Password · Email Address · Phone Number · Co-Driver · Driver's License Plate Number |
| User | barcha 5 maydon |
| Role | Role Name |
| Maintenance | Maintenance Type · Unit # (single) · Maintenance Frequency · Set Reminder · Schedule Name · Alert Type · Delivery Method |
| FMCSA | Type · Driver · Comment |
| IFTA | States · Trucks (rejimga qarab) · Quarter · Year |
| DVIR | Driver · Date · Truck Defects · Trailer Defects · Driver's Signature · Mechanic Signature |
| Settings › Company | barcha maydonlar |
| Log tahrirlash | From · To · Note |

Ixtiyoriy: Unit'da `Year`, `License Plate Issue State`; Driver'da `Unit #`, `City`, `State`, `Zip Code`, `Fleet Manager`, `Home Terminal Address`, `Address 1/2`, `Notes`.

**Shartli maydonlar:**
| SHART | NATIJA |
|---|---|
| `Sleeper Not Available` belgilansa | «The Sleeper Berth (SB) status will be disabled.» — haydovchi ilovasida SB tugmasi o'chadi |
| `Get VIN From ELD` / `Enter VIN Manually` | VIN kiritish usuli almashadi |
| Maintenance `Multiple Units` | `Unit #` o'rniga `UNITS` ro'yxati + `Select All` |
| IFTA `States only` | `Trucks *` maydoni yo'qoladi |
| FMCSA `Custom Range` | `From *` / `To*` paydo bo'ladi |
| DVIR `Defects corrected` | `Mechanic Signature *` paydo bo'ladi |
| DVIR `Defects needs to be corrected` | `Truck Defects*` va `Trailer Defects *` paydo bo'ladi |
| Send file `Email` | `Email Address` paydo bo'ladi |
| Certify — kun tanlansa | `Certify All` → `Certify Selected (n)` |

### Bet 134 — Cheklovlar, formulalar va ro'yxatlar
**Cheklovlar:**
| CHEKLOV | QIYMAT | MANBA |
|---|---|---|
| Izoh uzunligi | 60 belgi | «Notes field has max 60 character limit» |
| Sahifadagi satrlar | 10 (standart) | `Rows per page: 10` |
| Invoice fayl formati | PDF | «Upload invoice (.pdf format)» |
| Sertifikatsiya oynasi | 8 yoki 11 kun | `Certify (Last 8 days)` / `(Last 11 days)` |
| Tekshiruv oynasi | 7 kun + bugun | «the past 7 days + today» |
| FMCSA DOT hisoboti | 8 kun | `Roadside inspection DOT report (8 days)` |
| Harakatsizlik so'rovi | 5 daqiqa | «You've been idle for 5 minutes» |
| IFTA hisobot tayyorligi | oyning 5-kuni | «Reports will be ready by the fifth day of each month.» |

**Hisoblash formulalari:** `Next Frequency = Current Frequency + Maintenance Frequency` · `Total Miles = IFTA Miles + Non-IFTA Miles` · `Odometer Change = End Odometer − Start Odometer`

**Ro'yxatlar — dizaynda to'liq ko'rsatilgan:**
| RO'YXAT | BANDLAR SONI | MANBA |
|---|---|---|
| Truck defects | 44 (2 xatolik bilan) | 1169:1887 |
| Trailer defects | 13 | 1169:2106 |
| Quick notes (variant A) | 10 | 1170:2313 |
| Quick notes (variant B) | 8 | 1232:14150 |
| Maintenance turlari | 6 | jadval qiymatlaridan |
| Rollar | 5+2 | 330:44577 + boshqa ekranlardan |

**Ro'yxatlar — dizaynda to'liq emas:** `Choose ELD Type` (faqat id formatlari: `PT30_A86E`, `PT30_EE35`, `PT30_A9A1`, `AP-AM4-0001172`) · `Choose fuel type` (faqat `Petrol`, `Diesel`) · `Select alert type` (faqat `Upcoming`) · `Select delivery method` (faqat `Email`) · `Select make` / `Select model` (Mercedes-Benz, Porsche, Lexus, Chevrolet, Honda, Tesla, Toyota, Audi, BMW)

### Bet 135 — Audit jurnallari va bildirishnomalar
**To'rt audit jurnali:**
| JURNAL | EKRAN | USTUNLAR |
|---|---|---|
| Unit faoliyati | 167:3035 | Time Stamp · Activity |
| Driver faoliyati | 257:1676 | Time Stamp · Edited By · Activity |
| Haydovchilar tarixi | 259:16876 | Driver Name · Edited By · Date |
| Kompaniya tarixi | 489:11156 | Edited By · Changes · Date |

**Bildirishnomalar — uch tur:**
| TUR | SARLAVHA | MATN |
|---|---|---|
| Marshrut | Admin has added a new route. | «From "ABC LOCATION" to "XYZ LOCATION"» |
| Xizmat kechikkan | Maintenance overdue | «Maintenance was due 2 days ago.» |
| Xizmat yaqin | Maintenance upcoming | «You have a maintenance of type "Oil Change" after 100 miles.» |

**Vaqt formati:** mobil — sana bo'yicha guruhlash (`May 28, 2025`), nisbiy vaqt (`2hrs`); planshet — guruhlanmagan, absolyut (`28 May, 10:04 am`).
Aniqlanmagan: ELD uzilishi, qoidabuzarlik yoki sertifikatsiya eslatmasi uchun bildirishnomalar dizaynda yo'q.

### Bet 136 — Ogohlantirish va qoidabuzarlik (ikki daraja)
- `Warning: Trailer is not set` · `Violation: Trailer is not set` — bir xil sabab ikkala darajada. Warning qachon Violation'ga aylanishi ko'rsatilmagan.

**Dizayndagi barcha sabablar:**
| MATN | QAYERDA |
|---|---|
| Trailer is not set / Trailer not set. | log ekranlari, Logs By Unit, mobil Log Report |
| Shipping document is not set | Logs By Unit |
| Shift Limit | Log By Driver |

Izoh: «Violations can be removed after completion of second qualify break.»
**Filtrlash:** Logs By Unit va Log By Driver ekranlarida ikki mustaqil filtr: `Violations` va `Warnings`.
**Dashboard'da:** `Violations: 6` (This week) · `Disconnected ELD: 32` (Today).

**Vizual ko'rinishi:**
| DARAJA | FON | MATN RANGI |
|---|---|---|
| Warning | `#FCEAC8` | `#7B5D24` |
| Violation | `#F9DADB` | `#5A1C1E` |

Jadvalda raqamli badge (`1`) — qoidabuzarliklar soni. Log ekranida (384:55489) ikkala satr bir vaqtda ko'rsatilgan.

---

## VIII. Yakun (bet 137–144)

### Bet 137 — Bo'lim muqovasi «Yakun»
`20+` nomuvofiqlik · `16` aniqlanmagan nuqta · `4 turdagi` begona kontent.

### Bet 138 — Nomuvofiqliklar 1: nomlash va imlo
To'liq ro'yxat quyida: **B.1 bo'limi** (navigatsiya nomlari) va **C bo'limi** (imlo xatolari).

### Bet 139 — Nomuvofiqliklar 2: struktura va kontent
To'liq ro'yxat quyida: **B.2 bo'limi** (ustun/maydon nomuvofiqliklari) va **B.3 bo'limi** (begona kontent).

### Bet 140 — Eskirgan iteratsiya «Universal ELD» (`--` sahifasi · `14:4` · talab emas)
| JIHAT | ESKIRGAN (14:4) | AMALDAGI (14:5) |
|---|---|---|
| Brend | Universal ELD | OneBook ELD |
| Navigatsiya | chapda sidebar | yuqorida gorizontal |
| Tuzilma | ko'p-kompaniyali | bitta kompaniya |
| Kirish nuqtasi | `Companies` ro'yxati | to'g'ridan-to'g'ri Dashboard |
| Terminologiya | `Vehicles` | `Units` |
| Dashboard | `Welcome To Admin Panel!` | `Dashboard Overview` |

**Sidebar tuzilishi (eskirgan):** Menu: Dashboard · Logs · Tracking · All Companies / LIST: Drivers · Vehicles · Users · Role & Permission / REPORTS: FMCSA Report · Activity Report / MoRE: Chat · History
**Ko'p-kompaniyali ekranlar:** `Companies / Empty` (31:5428) — ustunlar `# · Company Name · Address · US DOT · Contact Number`; `Companies / Added` (36:8441) — 2 kompaniya: ABC Logistic Company INC, XYZ Logistic Services Pvt Ltd.
**Dashboard KPI (eskirgan):** Total Drivers · Total Vehicles · Total DR · Total SB · Total ON · Total OFF — 6 karta. `Tracking Overview` bloki tablari: Dashboard · Logs · Driver's Log · Violations · Tracking.

### Bet 141 — Aniqlanmagan nuqtalar (16 ta)
1. HOS hisoblash formulalari va qoidalar to'plami (`65:00` yoki `70:00`)
2. `Recap` ustuni qanday hisoblanadi
3. Sertifikatsiya oynasi — 8 kunmi yoki 11 kun (dizaynda ikkalasi ham bor)
4. Kunning `Not Ready` bo'lish sharti
5. Harakat aniqlash chegarasi va manbai (ELD yoki GPS)
6. Harakatsizlik so'roviga `No` javobidan keyingi status; javob bo'lmasa nima bo'ladi
7. Joylashuv aniqligining chegarasi
8. Warning qachon Violation'ga aylanadi
9. DVIR holat o'tishlarini kim boshqaradi; `Certified` kimga tegishli
10. Marshrut `Ongoing` → `Completed` o'tishi qanday sodir bo'ladi
11. Inactive unit/driver'ga bog'liq loglar va DVIR'lar bilan nima bo'ladi
12. Rolli ruxsatlar ro'yxatining haqiqiy mazmuni
13. ELD qurilma modellari ro'yxati (`Choose ELD Type`)
14. `Alert Type` va `Delivery Method` variantlari
15. Sana/vaqt formati — dizaynda 6 xil variant: `17/12/2025` · `Apr 18, 2025` · `2025-04-16, 10:42:22` · `Feb 11,2024` · `12:03 11/02/2024` · `Fri, 29/11/2025`
16. Export/Import fayl formatlari (faqat IFTA'da CSV/PDF ko'rsatilgan)

### Bet 142 — Ekranlar registri: Admin Panel (19 ko'rinadigan seksiya)
| SEKSIYA | ID | EKRAN | ASOSIY EKRANLAR |
|---|---|---|---|
| Dashboard | 146:135 | 1 | Dashboard 123:1207 |
| Fleet Management / Unit Management | 153:995 | 12 | ro'yxat · Add · View · View (Info) · Edit · Inactive · Delete · Track ×3 |
| Fleet Management / Drivers Management | 252:5769 | 9 | ro'yxat · Add · View ×2 · Edit · Inactive · Change password · Delete |
| Maintainance (amaldagi) | 1225:5291 | 17 | Schedule · Due · History · Add ×2 · Edit · View ×2 · Mark complete ×2 · … |
| Tracking | 264:20269 | 6 | ro'yxat · Track on Map ×3 · Histories |
| Log | 312:40199 | 9 | Logs By Unit · Log view (3 tab) · Insert duty status · kengaytirilgan |
| Fleet Management / User | 259:12588 | 5 | ro'yxat · Add · Edit · Delete |
| Fleet Management / Histories | 259:16327 | 2 | bo'sh · to'la |
| Logs / Log by driver | 500:9276 | 3 | bo'sh · to'la · kengaytirilgan |
| Role & Permissions | 330:44019 | 5 | ro'yxat ×2 · Add · Edit · Delete |
| Report / Activity Report | 292:18830 | 6 | Drivers ×2 · Units ×2 · View ×2 |
| Report / IFTA Report | 303:23807 | 7 | Units ×3 · States ×2 · Generate ×2 |
| Report / FMCSA Report | 307:34380 | 4 | ro'yxat ×2 · Generate ×2 |
| Report / DVIR Report | 549:3958 | 5 | ro'yxat ×2 · Generate ×3 |
| Profile / Setting | 481:9842 | 5 | Company · Profile · Password · Company history |
| Chat | 283:15886 | 1 | Chat 283:15887 |
| Header Options | 159:4970 | 12 | 8 nav holati + 4 flyout |
| support & history / Contact support | 1187:7707 | 4 | bo'sh · to'la · View · Status |
| support & history / Feedback | 1194:5057 | 2 | bo'sh · to'la |

Yashirilgan: `Maintainance` 268:30430 (22 ekran, eskirgan) va `Subscription` ×2 (498:3772, 498:4353).

### Bet 143 — Ekranlar registri: Mobil va Planshet
**Mobile Application (14:6):**
| SEKSIYA | ID | EKRAN | HOLAT |
|---|---|---|---|
| Mobile Application / Light Theme | 1070:6813 | 73 | amaldagi |
| Mobile Application / Dark Theme | 2665:25648 | 63 | amaldagi |
| Mobile Application / Dark Theme (nusxa) | 3497:433 | 63 | amaldagi |
| Mobile Application | 1206:9697 | 67 | yashirilgan |
| Section 1 | 1119:653 | 3 | yashirilgan |

**Tablet Application (14:7):**
| SEKSIYA | ID | EKRAN | HOLAT |
|---|---|---|---|
| OneBookELD Tablet App - Light Theme | 1470:21013 | 52 | amaldagi |
| OneBookELD Tablet App - Dark Theme | 2197:104566 | 51 | amaldagi |
| Section 3 | 1495:43530 | 28 | yashirilgan |
| Home | 1804:31752 | 15 | yashirilgan |
| Section 1 | 1349:2701 | 2 | yashirilgan |

**Umumiy hisob (ekran-daraja tugun):** Cover 7 · Branding & Color 3 · Admin Panel 130 · Mobile Application 269 · Tablet Application 152 · `--` sahifalari 42 · **Jami 603**
Prezentatsiyada: `158` renderlangan ekran · `100 %` amaldagi seksiyalar qamrovi.

### Bet 144 — Yakun
`3` klient ilova (Admin Panel · Mobil · Planshet) · `19` admin seksiyasi · `88` biznes qoidasi · `16` aniqlanmagan nuqta.
**Yetkazilgan hujjatlar:** `docs/01-TEXNIK-TOPSHIRIQ.md` (ekran-ekran spetsifikatsiya) · `docs/02-BIZNES-LOGIKA.md` (88 qoida Q1–Q88) · `docs/ELD-Prezentatsiya.pdf` · `docs/prezentatsiya/build.py` + `parts/`
**Manba va audit izi:** Figma ELD Software (Copy) `NLDjNYebjCuNswunequFv2`; ekstraksiya dumplari `.figma-cache/`.

---

# A. DIZAYN TIZIMI (yig'ma)

## A.1 Ranglar (hex)
**Asosiy (COLOR'S guruhi):**
| Nom | HEX | Qayerda ishlatilgan |
|---|---|---|
| Primary | `#B7002C` | admin header (brend panel), asosiy tugmalar, faol nav elementi + ostidagi chiziq, CYCLE indikatori, sahifalash faol raqami |
| Light | `#EFF4FB` | — |
| Bg Light | `#FCFCFD` | asosiy oq fon |
| Bg Dark | `#1B222C` | dark tema asosiy fon |
| Sidebar | `#233040` | dark tema yon panel |
| Grey Light | `#F5F5F5` | — |
| Grey Dark | `#303E4B` | dark tema kartalar foni |
| Stroke | `#E5E7EB` | chegaralar (light) |
| Dark stroke | `#52565F` | chegaralar (dark) |
| GREY | `#F2F4F7` | jadval sarlavhasi foni |

**Neutral — 11 pog'ona:** `#FCFCFD` · `#F4F5F6` · `#E6E8EC` · `#D6D8E0` · `#B1B5C3` · `#777E90` · `#3F4352` · `#353945` · `#23262F` · `#1C1E24` · `#18191D`

**State colors — uch pog'ona (fon / asosiy / to'q):**
| HOLAT | FON | ASOSIY | TO'Q |
|---|---|---|---|
| Success | `#C5EFD8` | `#2FA766` | `#103923` |
| Warning | `#FCEAC8` | `#F6BA47` | `#7B5D24` |
| Error | `#F9DADB` | `#E2464A` | `#5A1C1E` |

**Decorative — 7 rang:** Pink `#EE4E68` · Teal `#30B0C7` · Green `#47BB75` · Purple `#7E5EF7` · Orange `#F5693D` · Yellow `#F7CB46` · Blue `#466FF7`
**Chart colors:** Green `#2FA766`, Red `#E2464A` (Success/Error bilan bir xil — alohida palitra yo'q)
**Transparent:** Neutral 10 `#1C1E24` 35 % · Neutral 8 `#353945` 40 % · Red `#E2464A` 30 % · Green `#2FA766` 30 %
**Gradientlar:** 3 uslub (`L`, `l`, `lll`), barchasi `GRADIENT_LINEAR`

**Status ranglari (interfeysda):**
- Yashil (Success) — `Completed`, `Certified`, `Online`, `Signed`, DRIVE indikatori, trailer/document badge'lari
- Sariq (Warning) — `Warning:` satri foni, BREAK indikatori
- Qizil (Error) — `Violation:` satri, `Not Signed`, `Ongoing`, `Not Found`, muddati o'tgan qiymatlar (`2 days due`, `20 miles due`), `Logout`
- Ko'k `#466FF7` — SHIFT indikatori va log grid chizig'i
- Dashboard KPI ikonkalari: Total Drivers ko'k · Total Units to'q sariq · Disconnected ELD kulrang (karta ostidagi chiziq esa **yashil**) · Violations qizil · statuslar kartasi sariq

## A.2 Shriftlar va o'lchamlar
- **IBM Plex Sans** — asosiy shrift; **Product Sans** — faqat Display darajasi
- Shkala: Display 1/2 (48/40 Product Sans Bold), Heading 1–4 (48/40/32/24 Bold), Body 1–17 (26 → 10 px). To'liq jadval — bet 10 bo'limida.
- Figma'da **0 ta lokal text style** — shkala komponentlarga biriktirilmagan. `Body 6` va `Body 7` bir xil (Regular 20) — takror.

## A.3 Grid va spacing
| USLUB | COUNT | TYPE | WIDTH | OFFSET | GUTTER | MARGIN |
|---|---|---|---|---|---|---|
| Desktop | 12 Column | Center | 80 px | — | 24 px | — |
| Dashboard with Sidebar · sidebar | 1 column | Left | 280 px | 0 px | 20 px | — |
| Dashboard with Sidebar · kontent | 12 Column | Right | 79 px | 24 px | 16 px | — |
| Login | 5 Column | Center | 88 px | — | 16 px | — |
| Sidebar | 4 Column | Stretch | — | — | 12 px | 16 px |

`Dashboard with Sidebar` gridi **eskirgan** (amaldagi admin panelda sidebar yo'q).

## A.4 Effektlar va radius
- Yagona effekt uslubi: **`Carts Dropdown`** — `DROP_SHADOW`, **radius 27.25**. Dashboard kartalari va dropdown menyularda.
- Boshqa radius qiymatlari prezentatsiyada ko'rsatilmagan — *(o'qib bo'lmadi / berilmagan)*.
- Umumiy spacing shkalasi (4/8 pt kabi) prezentatsiyada ko'rsatilmagan — *(berilmagan)*.

## A.5 Tokenlar
Bitta `Variable collection`, 1 mode (`Mode 1`), 1 o'zgaruvchi — **token tizimi qurilmagan**, ranglar paint style orqali biriktirilgan.

## A.6 Ikonka uslubi
Prezentatsiyada ikonka nabori/uslubi (line/filled, grid o'lchami) alohida ko'rsatilmagan — *(berilmagan)*. Ekranlarda uchraydigan ikonkalar: lupa (qidiruv), quyosh (tema), qo'ng'iroq (bildirishnoma), avatar, `···` (satr amali), `⋮`, `⌄` (dropdown), qalam (edit), yuklab olish (export), tashqi havola, nusxalash, qizil uchburchak (ogohlantirish), ko'z (parol), `+` / `−` (zoom).

## A.7 Ekran o'lchamlari
| KLIENT | KENGLIK | BALANDLIKLAR |
|---|---|---|
| Admin (web) | 1440 px | 792 · 907 · 1010 · 1024 · 1047 · 1055 · 1066 · 1123 · 1125 · 1301 · 1829 · 2211 |
| Mobil | 393 px | 851 · 852 · 854 · 874 · 891 · 893 · 1037 · 1152 · 1650 · 1702 |
| Planshet | 1366 px | 936 · 1024 · 1421 |

## A.8 Takrorlanuvchi UI patternlari
- **Ro'yxat ekrani:** sarlavha + asosiy amal tugmasi → tab qatori → filtr paneli (qidiruv, sana, Export…, Import…) → jadval (kulrang sarlavha, oq satrlar, 1 px chiziq) → sahifalash (`Rows per page: 10` · `Previous` · `1` · `Next`)
- **Bo'sh holat (admin):** `No Data Found` + `There is no data to show you right now` + illyustratsiya
- **Bo'sh holat (planshet):** `No Ticket Added Yet` + «Start to add your first ticket by clicking button below.» + amal tugmasi
- **Bo'sh holat (mobil DVIR):** `No DVIR Found` + `There is no data to show you right now`
- **Bo'sh holat (bildirishnoma):** `No Notifications Yet` + «Stay tuned! Important updates and alerts will appear here.»
- **Tasdiqlash modali:** sarlavha `Are you absolutely sure?` + savol matni + `Cancel` / `Confirm`
- **Forma modali (admin):** blok nomi (`… DETAILS`) + maydonlar + `Cancel` / `Save` (yoki `Update`)
- **Modal (planshet):** yuqorida bir qatorda `Cancel` · sarlavha · amal (`Save` / `Confirm`)
- **Yuklanish holati:** dizaynda **hech qayerda ko'rsatilmagan** — *(yo'q)*
- **Xato holati:** faqat inline ogohlantirish satrlari (`Violation:`, `Warning:`) va modal matnlari (ELD ruxsat xatosi, joylashuv aniqligi xatosi); umumiy xato ekrani yo'q — *(yo'q)*

---

# B. NOMLASH NOMUVOFIQLIKLARI

## B.1 Navigatsiya va ekran nomlari (bet 138)
| VARIANT A | VARIANT B | QAYERDA |
|---|---|---|
| Fleet Operations | Fleet Management | nav qatori turli ekranlarda |
| Reports | Report | nav qatori |
| Support & History | Histories | nav qatori |
| Inspection Report | DOT Report | mobil (amaldagi vs eskirgan) |
| Unit Diagnostics | Unit Inspection | Track on Map — ikki kirish yo'li |
| Leave the Truck | Leave Truck | mobil yon menyu vs kategoriyalar |
| In Progress | In-Progress | admin vs planshet tiket holati |
| Yes, Driving | Yes, driving | mobil vs planshet |
| Dropoff / Checkout | Drop off / Check out | mobil vs planshet quick notes |
| Notify co-driver | Notify Co-driver | Add vs View maintenance |

## B.2 Ustun / maydon nomuvofiqliklari (bet 139)
| MUAMMO | TAFSILOT |
|---|---|
| Bo'sh vs to'la holat | `Maintenance › Due`: bo'shda `Remind`, `Due Date`; to'lada `Remaining Frequency`, `Reminder Sent` |
| Contact Support | bo'shda `Ticket ID`, `Message`; to'lada `Ticket #`, `Subject` |
| Unit jadvali | `Make & Model` / `ELD` vs `Manufacturer - Model` / `Device ID` |
| ELD id formati | `PT30_A9A1` vs `AP-AM4-0001172` — ikki xil |
| Activity Report | oxirgi ustun `Odometer Change` deb yozilgan, `End Odometer` bo'lishi kerak |
| User Management | `Role` ustunida ism yozilgan; `Export Drivers` tugmasi `Users` bo'lishi kerak |
| Histories | sarlavha tugmasi `Add User` — mos emas |
| Profile / Setting | birinchi ekran (481:9843) FMCSA Report jadvalini ko'rsatadi |
| Log jami formati | mobil: `OFF 03:06`; planshet: `Off - 00:00` |
| Bo'sh qiymat | `na` vs `N/A` |
| Hafta kuni | `Tues`, `Thurs` (4 harf) vs `Fri`, `Mon`, `Wed`, `Sat`, `Sun` (3 harf) |
| Truck defects | `Engine` ikki marta; `Refresh` nuqson emas |
| Quick notes | ikki xil to'plam: 10 bandli (PTI, Hook…) va 8 bandli (Break, Shower, Breakfast…) |
| Sertifikatsiya oynasi | `Certify (Last 8 days)` vs `Certify (Last 11 days)` |
| Log jadvali oxirgi ustuni | planshetda `Edit`, mobilda `Action` |
| Sana tasmasi | mobilda hafta kuni bilan (`Fri 07`), planshetda oy nomi bilan (`07 Jan`) |
| Bildirishnoma vaqti | mobilda nisbiy (`2hrs`), planshetda absolyut (`28 May, 10:04 am`) |
| ELD output file matni | planshet: «to the DOT officer», mobil: «to the Insection officer» |
| Sana/vaqt formati | 6 xil variant (bet 141, 15-punkt) |
| DVIR holat to'plami | mobil 3 tur vs admin 7 holat |
| Dark/Light tugun nomlari | `Edit Documents` → `edit doc`; `Home/Full screen` → `Home/Full screen..` |

## B.3 Begona kontent — 4 turdagi (bet 139)
| NIMA | QAYERDA | NIMA BO'LISHI KERAK |
|---|---|---|
| Rolli ruxsatlar — go'zallik saloni domeni (`Salons`, `Clients`, `Employees`) | 330:45466 · 331:46454 | ELD modullari bo'yicha qayta yozilishi |
| Privacy Policy / Terms of Use — «Jusoor», «ONTime Log», «OnTime ELD» (Saudiya biznes platformasi) | mobil 2627:25778 · planshet 2568:25226 | buyurtmachidan haqiqiy matn |
| Chat xabarlari — dizayn jarayoni haqida («Hi-FI wireframes for flora app design») | admin 283:15887 · mobil 1118:114 | haqiqiy ssenariy |
| Muqova sarlavhasi — «Seamless Healthcare Access Mobile App Design» | 2142:16231 | ELD nomi |

**Butun begona sahifalar:** `--` (14:10) TailAdmin V2.0 PRO shabloni · `--` (14:8) proytecto-MC.com MVP skrinshotlari · `--` (14:4) «Universal ELD» avvalgi iteratsiyasi.

**Placeholder qolgan joylar:** Logs / Reports / Support & History flyoutlarida `lorem ipsum` tavsiflar; Unit va Driver Activities jurnallarida barcha satrlar `Lorem ipsum`; Settings Password tabida `Lorem ipsum` / `Address` placeholder'lari.

---

# C. IMLO XATOLARI (prezentatsiyada aynan yozilgan)

| DIZAYNDA | TO'G'RISI | QAYERDA |
|---|---|---|
| `Maintainance` | Maintenance | seksiya va tugma nomlari (267:30340, 268:30430, 1225:5291, `MAINTAINANCE DETAILS` bloki) |
| `Invocie` | Invoice | mobil upload formasi |
| `Grese` | Grease | maintenance jadvali |
| `0verdue` | Overdue | mobil maintenance (nol harfi `O` o'rniga) |
| `Insection` | Inspection | mobil Inspection Report |
| `Drivers Mangement` | Drivers Management | ekran nomi (252:8975) |
| `Selecetd` | Selected | planshet ekran nomi |
| `easr avon` | East Avon | log detali namunasi |
| `GET BTY` | GET BY | IFTA Generate formasi |
| `Last Address *` | Last Name | Settings › Profile |
| `cManagement - Inactive` | Driver Management - Inactive | ekran nomi |
| `automaticlly` | automatically | mobil komponent nomi `Drive mode (automaticlly)` |
| `5 mint idle` | 5 min idle | planshet dark tema ekran nomi |
| `23,97464553778` | 23.97464553778 | Trip Planner koordinatasi (vergul/nuqta aralash) |
| `XT` | (AQSh shtat kodi emas) | IFTA States ro'yxati |
| Warning `#F9B385` yozilgan, RGB `246,176,71` | mos emas | Color Palette sahifasi |

---

# D. EKRANLAR RO'YXATI JADVALI

| BET | EKRAN NOMI | PLATFORMA | MODUL |
|---|---|---|---|
| 1 | Muqova (ELD Software) | — | prezentatsiya |
| 2 | Mundarija | — | prezentatsiya |
| 3 | Metodologiya | — | prezentatsiya |
| 4 | Figma fayl tuzilishi | — | prezentatsiya |
| 5 | Qatlamlar holati | — | prezentatsiya |
| 6 | Mahsulot tarkibi | — | prezentatsiya |
| 7 | Dizayn tizimi (muqova) | — | Dizayn tizimi |
| 8 | Color Palette (14:148) | — | Dizayn tizimi |
| 9 | State / Decorative / Transparent ranglar | — | Dizayn tizimi |
| 10 | Typography (14:544) | — | Dizayn tizimi |
| 11 | Grid (14:653) | — | Dizayn tizimi |
| 12 | Admin Panel (muqova) | web | Admin |
| 13 | Modullar xaritasi | web | Admin |
| 14 | Header / karkas (Dashboard 123:1207) | web 1440 | Karkas |
| 15–16 | Flyout menyular (Fleet Operations, Logs, Reports, Support & History) | web | Karkas |
| 17–18 | Jadval anatomiyasi — bo'sh (1225:5292) / to'la (153:140) | web 1440 | Umumiy pattern |
| 19–20 | Ustun tanlash paneli (236:2354, 252:12844) | web | Umumiy pattern |
| 21–22 | Tasdiqlash modallari (Inactive 159:5914, Delete 252:10562) | web | Umumiy pattern |
| 23 | Dashboard Overview — KPI (123:1207) | web 1440×1829 | Dashboard |
| 24 | Units Tracking + Route's Details (146:135) | web | Dashboard |
| 25 | Tracking — haydovchilar ro'yxati (264:23678) | web 1440×1125 | Tracking |
| 26 | Track on Map — yig'ilgan (163:13598 / 265:28242) | web | Tracking |
| 27 | Track on Map — yoyilgan + Unit Diagnostics (237:2475) | web 1440×1047 | Tracking |
| 28 | Unit Management — ro'yxat (153:140) | web 1440×1125 | Fleet Operations |
| 29 | Unit — Add (153:3124) | web 1440×1024 | Fleet Operations |
| 30–31 | Unit — Edit (157:4241) / View (252:4983) | web | Fleet Operations |
| 32 | Unit — Activities jurnali (167:3035) | web | Fleet Operations |
| 33 | Driver Management — ro'yxat (252:8975) | web 1400×1147 | Fleet Operations |
| 34 | Driver — Add (252:6345) | web 1440×1179 | Fleet Operations |
| 35–36 | Driver — View (252:7008) / Activities (257:1676) / Change password (258:2523) | web | Fleet Operations |
| 37–38 | User Management — ro'yxat (259:13137) / Add (259:14668) / Edit (259:15295) | web | Fleet Operations |
| 39–40 | Roles & Permissions — ro'yxat (330:44577) / Add Role (330:45466) | web | Fleet Operations |
| 41 | Histories (259:16876) | web 1400×1094 | Support & History |
| 42 | Maintenance — modul xaritasi (1225:5291) | web | Maintenance |
| 43–44 | Maintenance — Schedule (1225:5895) / Due (1225:5433) | web | Maintenance |
| 45 | Maintenance — View single (1225:6156) | web | Maintenance |
| 46–47 | Maintenance — Add single (1225:6519) / Add multiple (1225:6738) | web | Maintenance |
| 48–49 | Maintenance — View multiple (1225:7468) / guruh ichi (1225:12183) | web | Maintenance |
| 50–51 | Maintenance — Mark as Complete (1225:9702 / 1225:11739) | web | Maintenance |
| 52–53 | Maintenance — History: Completed (1225:9310) / Cancelled (1227:13594) | web | Maintenance |
| 54 | Logs — modul xaritasi | web | Logs |
| 55–56 | Logs By Unit (312:40746) + kengaytirilgan (381:54574) | web 1440×1125 | Logs |
| 57 | Log view — Driver's Log (384:55489) | web 1440×2211 | Logs |
| 58 | Log view — voqealar jadvali + Log Form (475:4854 / 475:5370) | web | Logs |
| 59–60 | Insert duty status (480:8990) + Report tabi (475:5370) | web | Logs |
| 61–62 | Trip Planner (475:6184) / Plan a Trip (475:6693) | web | Logs |
| 63–64 | Logs By Driver (500:9418) + kengaytirilgan (500:10258) | web | Logs |
| 65 | Hisobotlar — to'rt turi | web | Reports |
| 66–67 | Activity Report — Drivers (292:19388) / Units (296:22009) | web | Reports |
| 68 | Activity Report — View (294:20263) | web | Reports |
| 69–70 | IFTA Report — Units (303:24365) / States (306:32784) | web | Reports |
| 71 | IFTA — Generate Report (306:29752 / 306:30638) | web | Reports |
| 72–73 | FMCSA Report — ro'yxat (307:34977) / Generate (307:36440, 307:39467) | web | Reports |
| 74–75 | DVIR Report — ro'yxat (549:4080) / Generate (549:4377, 549:4550, 552:5102) | web | Reports |
| 76–77 | Contact Support — ro'yxat (1187:7849) / Ticket View (1193:8353) / Status (1194:4616) | web | Support & History |
| 78–79 | Feedback (1194:5207) / Chat (283:15887) | web | Support & History / Chat |
| 80 | Settings — Company (481:9967) / Profile (487:10921) / Password Setting (487:11048) | web 1440×792 | Settings |
| 81 | Settings — Company history (489:11156) | web 1440×1105 | Settings |
| 82 | Profil menyusi (484:10822) + Header Options | web | Karkas |
| 83 | Mobil ilova (muqova) | mobil | Mobil |
| 84 | Mobil — ekranlar xaritasi | mobil | Mobil |
| 85–86 | Splash (958:22) · Login (958:44) · Login-filled (1113:9176) · Leave truck (1116:9231) | mobil 393×852 | Kirish |
| 87–88 | Bosh ekran A tartib (1202:9259) / B tartib (2177:12192) | mobil 393×854 / 393×1650 | Bosh ekran |
| 89–90 | Documents modali (2230:20627) · ELD not connected (1102:1738) · Permissions (1107:2310) · CO-DRIVER (1113:8480) · Switch button (1113:8764) | mobil 393×852 | Bosh ekran / ELD |
| 91–92 | Change Duty Status (1083:10550) · Quick notes (1170:2313) · Location error (1102:2021) · IN-DRIVE FOCUSED (1170:2684) · 5-daqiqa so'rovi (2181:17282) | mobil | Duty status |
| 93–94 | Log Report — Main (1085:14341) · Logs (1085:13169) · DVIR bo'sh (1087:14921) · DVIR to'la (1154:6104) · Log satri (1111:7334) | mobil | Log Report |
| 95–96 | Add DVIR (1089:4441) · vehicle defects (1169:1467) · No Defects (1090:4687) · Defects (1090:4901) · Defects + mechanic (1090:5027) | mobil | DVIR |
| 97–98 | Truck defects (1169:1887) · Trailer defects (1169:2106) · DVIR details (1166:869) | mobil | DVIR |
| 99–100 | Certify Last 8 days (1102:397) · Last 11 days (1102:931) · Sign (1102:817) · Not Ready (1102:1260) | mobil | Certify |
| 101–102 | Inspection Report (1111:7825) · Begin inspection (1111:8013) · send via email (1169:1196) · send file to DOT (1169:1332) | mobil 393×854 | Inspection |
| 103–104 | Profile (1119:445) · Settings (1131:392) · Diagnosis (1131:965) · Check Network (1122:319) · Feedback (1131:1149) | mobil | Profil |
| 105–106 | add support form (1179:7028) · Support & Helpdesk (1179:7142) · Chat (1118:114) · Notification (1156:7135 / 1156:7244) · Privacy Policy (2627:25778) | mobil | Support / Huquqiy |
| 107 | Planshet ilovasi (muqova) | planshet | Planshet |
| 108 | Planshet — konsepsiya farqi | planshet | Planshet |
| 109 | Home / Full screen (1470:42666) | planshet 1366×1024 | Bosh ekran |
| 110–111 | Yon menyu (2142:25753, 314×1024) · Log paneli (2142:15234, 1326×597) | planshet | Navigatsiya / Log |
| 112–113 | Edit Documents (1470:19197) · Change Duty Status (1470:28679) · Quick Notes (1470:30704) | planshet 1366×1024 | Modallar |
| 114–115 | Switch co driver (1517:51373) · Select Shipping Document (1517:53372) · Location error (1470:29713) · Log Detail (1517:52371) | planshet 1350×1012 | Modallar |
| 116–117 | Certify (1470:20134) · Sign (1470:22044) · Not Ready (1470:22998) | planshet | Certify |
| 118–119 | Log Report Main (2142:16317) · Logs (2142:22733) · Inspection Report (2156:46277) | planshet 1366×1024 | Log Report / Inspection |
| 120–121 | Check Network (2142:26925) · Permissions (2142:28945) · Diagnosis (2142:31232) · Feedback (2142:32880) · drive-focused (2190:90626) · 5 mint idle (2195:97628) | planshet | Sozlamalar / Haydash |
| 122–123 | Contact Support (2146:35984) · Add Ticket (2146:39644) · bo'sh holat (2146:38704) · Notification (2150:41614) | planshet 1366×936 | Support |
| 124 | Dark tema (muqova) | mobil + planshet | Dark tema |
| 125–126 | Mobil dark tema (2665:25648) · Planshet dark tema (2186:30658) | mobil 393×851 + planshet 1366×1024 | Dark tema |
| 127–128 | Planshet dark menu (2197:103777) · Planshet light feedback (2142:32880) | planshet 1350×1012 | Dark tema |
| 129 | Ma'lumot lug'ati (muqova) | — | Lug'at |
| 130 | Duty status va HOS | barcha | Lug'at |
| 131 | Barcha status to'plamlari | barcha | Lug'at |
| 132 | Obyektlar va maydonlari | barcha | Lug'at |
| 133 | Majburiy va shartli maydonlar | barcha | Lug'at |
| 134 | Cheklovlar, formulalar, ro'yxatlar | barcha | Lug'at |
| 135 | Audit jurnallari va bildirishnomalar | barcha | Lug'at |
| 136 | Ogohlantirish va qoidabuzarlik | barcha | Lug'at |
| 137 | Yakun (muqova) | — | Yakun |
| 138 | Nomuvofiqliklar — nomlash va imlo | — | Yakun |
| 139 | Nomuvofiqliklar — struktura va kontent | — | Yakun |
| 140 | Eskirgan iteratsiya «Universal ELD» (14:4) | web (eskirgan) | Yakun |
| 141 | Aniqlanmagan nuqtalar (16) | — | Yakun |
| 142 | Ekranlar registri — Admin Panel | web | Yakun |
| 143 | Ekranlar registri — Mobil va Planshet | mobil + planshet | Yakun |
| 144 | Yakun / yetkazilgan hujjatlar | — | Yakun |

**Izoh:** 144 betdan 66 tasida render ekran rasmi bor (jami 158 renderlangan ekran). Qolgan betlar matnli tafsilot yoki bo'lim muqovasi. Platforma ustunidagi qiymatlar slaydga joylangan render rasm o'lchamlaridan aniqlangan (`1440/1400×…` → web, `393×85x` → mobil, `1366×1024` / `1350×1012` → planshet).
