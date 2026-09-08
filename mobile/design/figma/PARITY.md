# PARITY.md — Figma ↔ kod parite auditi

**Sana:** 2026-09-08 · **Auditor:** figma-parity · **Doira:** 10 ta kanonik mobil ekran (light, phone 393 dp)
**Etalon:** `design/figma/png_ref/<nodeId>__*__light.jpg` + `tool/figma_spec.py`
**Render:** `flutter test test_goldens --update-goldens --timeout=5x` → **284/284 o'tdi (exit 0)**, hech bir golden yiqilmadi.

> Bu hujjat faqat **o'lchov** natijasi. `lib/` ga o'zgartirish kiritilmagan.
> C bo'limidagi `- [ ]` bandlar keyingi agent (`screen-implementer`) uchun ish ro'yxati.

---

## A. Xulosa

### Parite darajasi

| Ekran | Figma node | Taxminiy parite |
|---|---|---|
| M-02 Login | `958-44` | **0 %** — golden umuman yo'q, render qilinmagan |
| M-09 Home | `2177-12192` | **~35 %** |
| M-12 Change duty status | `1083-10550` | **~45 %** |
| M-22 Log Report — Main | `1085-14341` | **~50 %** |
| M-23 Log Report — Logs | `1085-13169` | **~40 %** |
| M-29 Certify | `1102-397` | **~55 %** |
| M-32 Add DVIR | `1089-4441` | **~70 %** |
| M-42 Chat | `1118-114` | **~60 %** |
| M-44 Profile | `1119-445` | **~75 %** |
| M-45 Settings | `1131-392` | **~50 %** |

**Umumiy parite: ~50 %.**

Mazmun (bloklar to'plami va tartibi) asosan to'g'ri — TZ bo'yicha yozilgan. Tafovutlarning
ustun qismi **umumiy chrome va dizayn tokenlari** darajasida: app bar, bottom nav, karta,
segmented control, sana lentasi, tugma rangi, badge shakli. Ya'ni bu **10 ta alohida ish emas,
6–8 ta markaziy tuzatish** — `core/ui/` da tuzatilsa, 10 ekranning hammasi bir vaqtda yaxshilanadi.

### Bloklovchi tizimli sabablar (jiddiylik bo'yicha)

1. **[P0] `AppBarPrimary` Figma dan butunlay farq qiladi** — `centerTitle: true`, balandlik 56,
   fon oq, standart amal ikonkalari (bell/mail/refresh) yo'q. Figma: **chapga tekislangan**,
   **48 dp**, fon `#C2C1CD` @20 %, o'ngda 3 ikonkali guruh. **10/10 ekranga ta'sir qiladi.**
2. **[P0] Pastki navigatsiya (BNB-19) hech bir ekran goldenida yo'q** — `goldenScreenHost`
   ekranni `StatefulShellRoute` qobig'isiz chizadi. Bundan tashqari koddagi `NavigationBar`
   Material 3 default ko'rinishida (h 80, `#EFF4FB` pill indikator, hamma yorliq ko'rinadi),
   Figma esa h 94, faol element `#B7002C` r10 chip + yorliq **faqat faol elementda**.
   **10/10 ekranga ta'sir qiladi.**
3. **[P0] Ekran gorizontal maydoni 16 dp, Figma da 24 dp** — Figma da barcha karta eni **345**
   (393 − 2×24). Kod `Spacing.screenPaddingPhone = 16`. Har ekranda gorizontal ritm siljigan.
4. **[P1] Karta uslubi noto'g'ri** — Figma: fon `#F6F6F6`/`#F5F5F5`, **chegara yo'q**, `r12`,
   ichki padding **20**, kartalar orasi **15**. Kod: oq `surface` + 1 px `stroke` chegara,
   `Radii.card = 8`, `Spacing.cardPadding = 15`, `cardGap = 10`.
5. **[P1] Asosiy CTA rangi noto'g'ri** — Figma da birlamchi tugma va faol segment **qora
   `#1C1E24`**, kodda `AppButton.primary` → `c.primary = #B7002C` (qizil). `neutral` varianti
   (`c.neutralStrong`) mavjud, lekin ekranlar `primary` ishlatadi. Save / Next / Certify All /
   segmented active — hammasi qizil chiqmoqda.
6. **[P1] Komponentlar Material default ko'rinishida** — `Switch` (M3, kulrang thumb),
   `NavigationBar`, `Checkbox`, chat bubble `StadiumBorder`. Figma da hammasi maxsus chizilgan.
7. **[P2] Figma da bor, kodda umuman yo'q bloklar** — Home: HOS 2×2 karta grid, «Certify
   (Last 8 days)» imzo kartasi, Logs kartasi, ikkita status pill (SB/OFF) + swap;
   Certify: «Certify Today» qatori; Chat: typing indicator, mikrofon tugmasi;
   M-09/M-10: logotip lockup va hamburger.
8. **[P2] M-02 Login uchun golden test yo'q** — ekran hech qachon render qilinmaydi,
   regressiya ushlanmaydi. Yana 10 ta ekran shu holatda (D bo'limi).

---

## B. Tizimli tafovutlar

| # | Element | Figma qiymati | Koddagi qiymat | Ta'sir qilgan ekranlar | Tuzatish joyi |
|---|---|---|---|---|---|
| B-01 | App bar tekislash | sarlavha **LEFT**, `pad[12,21,12,21]` | `centerTitle: true` | 10/10 | `core/ui/components/app_bar_primary.dart` |
| B-02 | App bar balandligi | **48** (Home 54) | `kAppBarHeight = 56` | 10/10 | `core/ui/components/app_bar_primary.dart` |
| B-03 | App bar foni | `#C2C1CD` @20 % (≈`#F0F0F3`) | `c.surface` = `#FFFFFF` | 10/10 | `app_bar_primary.dart` + `tokens.dart` (`overlay` tokeni bor) |
| B-04 | App bar amallari | doim `Bell 24` · `mail 24` · `refresh 20`, gap 15 | ko'p ekranda `actions: []` | M-09, M-12, M-22, M-23, M-44 | `app_bar_primary.dart` (default `actions`) |
| B-05 | App bar leading | Figma: Home da hamburger + logotip lockup; ichki ekranlarda `<` | Home da leading yo'q, ichki ekranlarda `<` bor | M-09 | `features/home/.../home_screen.dart` |
| B-06 | Pastki navigatsiya | `BNB-19` h **94**, fill `#FFFFFF`, str `#E5E7EB`, inner shadow; faol = `#B7002C` r10 chip 50×29, oq ikonka; yorliq **faqat faol** elementda (Satoshi Bold 14) | `NavigationBar` M3 default: h 80, indikator `#EFF4FB` pill, **hamma** yorliq ko'rinadi | 10/10 | `core/router/app_router.dart` `_MainShell` + `core/ui/theme.dart` `navigationBarTheme` |
| B-07 | Ekran gorizontal padding | **24** (karta eni 345) | `screenPaddingPhone = 16` | 10/10 | `core/ui/spacing.dart` |
| B-08 | Karta foni/chegarasi | `#F6F6F6` fill, chegarasiz | `c.surface` (oq) + 1 px `stroke` | M-22, M-23, M-29, M-32, M-44, M-45 | `core/ui/` — umumiy `AppCard` komponenti YO'Q, har ekran o'zi quradi |
| B-09 | Karta radiusi | **12** (guruhlangan ro'yxat 16) | `Radii.card = md = 8` | 8/10 | `core/ui/radius.dart` |
| B-10 | Karta ichki padding | **20** | `Spacing.cardPadding = 15` | 8/10 | `core/ui/spacing.dart` |
| B-11 | Kartalar orasi | **15** | `Spacing.cardGap = 10` | 8/10 | `core/ui/spacing.dart` |
| B-12 | Birlamchi CTA rangi | `#1C1E24` (qora) | `c.primary = #B7002C` | M-12, M-29, M-32 | `core/ui/components/app_button.dart` |
| B-13 | CTA radiusi | **8** | `Radii.button = lg = 12` | M-12, M-29, M-32 | `core/ui/radius.dart` |
| B-14 | Ikkilamchi CTA | to'q kulrang fill `#F2F2F5`, chegarasiz | oq fill + chegara | M-12, M-32 | `app_button.dart` (`secondary`) |
| B-15 | Segmented control | konteyner 342×40 r8 fill `#C2C1CD`@20 %, pad 4; segment 110×32 r8 **teng enli**; faol fill `#1C1E24` oq matn | 3 ta alohida hug-width chip, faol qizil pill, konteyner yo'q | M-22, M-23, M-24 | `core/ui/components/` — komponent YO'Q, `features/logs/` ichida |
| B-16 | Sana lentasi (8 kun) | karta **60×80** r8/r10 fill `#F5F5F5`, gap 10; **ikki qator**: hafta kuni 12/21 `#777E90` + kun raqami 14–16/18; faol karta **qizil fill + oq matn** | karta ~63×62, **bir qator** «Mon 31», ostida kichik nuqta; faol holat ajratilmagan | M-22, M-23, M-24 | `core/ui/components/date_strip_8day.dart` |
| B-17 | Status badge shakli | to'ldirilgan to'rtburchak `r≈4–6`, **oq matn** (Uncertified=qizil fill, Certified=yashil fill; ON=cyan, DR=yashil, SB=amber) | `Radii.badge = pill`, **och tonli fon + to'q matn** | M-23, M-29 | `core/ui/components/status_badge.dart` + `radius.dart` |
| B-18 | Switch | iOS uslubi: yashil `#22C55E` track + to'liq oq doira thumb | Material 3: kulrang/kichik thumb, disabled da yashil track ichida **kulrang** thumb (buzuq ko'rinadi) | M-44, M-45 | `core/ui/theme.dart` `switchTheme` — maxsus `AppSwitch` kerak |
| B-19 | Checkbox | tanlanmagan: qora 1.5 px kontur `r2`; tanlangan: to'ldirilgan slate + oq belgi | Material default, och kulrang kontur, `r4` | M-29 | `core/ui/components/` — `AppCheckbox` YO'Q |
| B-20 | Kalit/qiymat qatori | **ikki ustun** (yorliq chapda `#777E90`, qiymat o'ngda `#1C1E24`) | **bitta ustun**, yorliq qiymat ustida | M-22, M-32 | `core/ui/components/` — `KeyValueRow` YO'Q |
| B-21 | Bo'lim sarlavhasi | karta **tashqarisida**, ustida | karta **ichida** | M-22 | `features/logs/` |
| B-22 | HOS ko'rsatkichi | M-09: 2×2 **karta grid** (yorliq + qiymat chipi + knobli bar); M-12: **4 ta halqa gauge** qator | ikkalasida ham bir xil 4 qatorli **linear bar** ro'yxati | M-09, M-12 | `core/ui/components/hos_indicators.dart` (`ring` varianti bor, ishlatilmagan) |
| B-23 | 24 soatlik grid | soat yorliqlari **yuqorida** `M,1..12,1..11,M`, 15-daqiqa mayda tirqishlar, chiziq **status rangida**, hodisa nuqtalari | yorliqlar `0..13` (24 soat **sig'maydi**), grid chiziqlari **ko'k**, chiziq **qora monoxrom**, nuqtalar yo'q | M-23 | `core/ui/components/duty_grid_24h.dart` |
| B-24 | Ogohlantirish bloki | amber to'ldirilgan quti (`r8`, pad 12) | fon**siz** oddiy amber/qizil matn | M-23 | `core/ui/components/banner_strip.dart` ishlatilmagan |
| B-25 | ELD banneri | `345×40` **r12 fill `#D70004`**, oq matn, chetdan 24 dp ichkarida | full-bleed yassi och-ko'k chiziq, **qizil matn**, radiussiz | M-09 | `core/ui/components/banner_strip.dart` |
| B-26 | Chat bubble | `r16`, «dum» burchagi `r4`, maks eni ~75 %, pad 12/16 | `StadiumBorder` (r = h/2) — ko'p qatorli xabarda buziladi | M-42 | `features/chat/presentation/widgets/` |
| B-27 | Matn kesilishi | Figma da yorliqlar to'liq | `Off Du…`, `Sleep…`, `Actio n` — ellipsis va noto'g'ri o'ralish | M-09, M-23 | `features/home/`, `features/logs/` |
| B-28 | Shrift oilasi | Figma aralash: `Plus Jakarta Sans` (app bar), `Satoshi Variable` (BNB, sana), `Product Sans`/`DM Sans` (segment) | yagona `Plus Jakarta Sans` | 10/10 | Qaror kerak — `DIFF.md` ga CR (Figma nomuvofiqligi, kod soddaroq) |

---

## C. Ekran bo'yicha

### M-02 Login — `958-44`
**Render:** ❌ **yo'q** — `login_screen.dart` uchun golden test mavjud emas.
Solishtirish faqat Figma etaloni asosida, kodni ko'rmasdan o'lchab bo'lmaydi.

- [ ] Golden test qo'shilsin (`test_goldens/features/auth/login_golden_test.dart`), keyin qayta o'lchansin
- [ ] Figma: markazda **logotip lockup** — qizil «One» monogrammasi + `BOOK ELD` (Plus Jakarta ExtraBold), yuqoridan ~130 dp
- [ ] Figma: `Username or Email address` yorlig'i input **ustida** (14, `#1C1E24`), input balandligi ~48, fill `#F7F7F8`, `r8`, placeholder `#9CA3AF`
- [ ] Figma: `Password` inputining o'ngida **kesilgan ko'z** ikonkasi (parol yashirilgan holat)
- [ ] Figma: `Login` tugmasi **disabled** holatda — kulrang `#8A8A96` fill, oq matn, h ~48, `r8`
- [ ] Figma: tugma ostida **info banner** — `r8` kulrang quti, chapda to'ldirilgan `i` doirasi, matn **justify** tekislangan, 2 qator
- [ ] Figma: ekran pastida 1 px ajratuvchi chiziq + `Copyright © 2025 OneBook ELD` markazda (`#6B7280`)

### M-09 Home — `2177-12192` (B tartib)
**Render:** `test_goldens/features/home/goldens/ci/m09_home_light_phone.png`
**Eslatma:** `png_ref/1202-9259__*` fayli aslida **drawer ochiq** holatni (M-10) ko'rsatadi, sof Home emas — MAP.md §1 dagi M-09 «A tartib» satri chalg'ituvchi.

- [ ] App bar: chapda **hamburger + logotip lockup** («One» qizil + `Book ELD`) — kodda markazlashgan `ONEBOOK ELD` matni
- [ ] App bar foni `#C2C1CD`@20 %, balandlik 54 (kodda oq, 56)
- [ ] ELD banner: `345×40 r12 fill #D70004`, **oq** matn, chetdan 24 dp — kodda full-bleed, radiussiz, qizil matn och fonda
- [ ] Status kartasi: ikonka **oq doira badge** ichida — kodda yalang'och ikonka
- [ ] Status taymeri formati `10h 45m 32s` — kodda `02:05:00`
- [ ] Status kartasi ostida: ajratuvchi + markazda **⇄ swap** ikonkasi, so'ng **2 ta** pill (`SB` oy ikonkasi bilan, `OFF` qizil power ikonkasi bilan) — kodda **3 ta** ikonkasiz tugma, yorliqlari kesilgan (`Off Du…`, `Sleep…`)
- [ ] «Hours of Service» sarlavhasi o'ngida **swap ikonkasi** (grid ↔ halqa) — kodda yo'q
- [ ] HOS bloki **2×2 karta grid**: har karta = rangli yorliq (BREAK amber / DRIVE yashil / SHIFT ko'k / CYCLE qizil) + `10:45 23` chipi + **knobli** progress bar — kodda 4 qatorli tekis linear ro'yxat
- [ ] Tez amallar: 4 ta **alohida chegarali karta** gorizontal scroll — kodda bitta karta ichida vertikal ajratuvchilar
- [ ] **«Signature» kartasi umuman yo'q**: «Certify (Last 8 days)» + 8 ta rangli nuqta (yashil/qizil) + qalam ikonkasi
- [ ] **«Logs» kartasi umuman yo'q**: mini 24 soatlik grid + `OFF 03:06 / SB 00:00 / DR 00:00 / ON 00:00` rangli jamilar
- [ ] Pastki navigatsiya goldenda yo'q (B-06)

### M-12 Change duty status — `1083-10550`
**Render:** `test_goldens/features/duty_status/goldens/ci/m12_change_duty_status_light_phone.png`

- [ ] App bar: chapga tekislangan sarlavha + `bell/mail/refresh`, fon `#C2C1CD`@20 %, h 48 — kodda `<` orqaga + markazlashgan sarlavha, oq fon, h 56
- [ ] HOS: **4 ta halqa gauge** qatori (BREAK amber `08:00`, DRIVE yashil `09:00`, SHIFT ko'k `10:00`, CYCLE qizil `65:00`) — kodda 4 qatorli linear bar
- [ ] Status tanlagich tartibi Figma: **On Duty · Sleep · Off Duty** — kodda teskari: `Off Duty · Sleeper Berth · On Duty`
- [ ] Ikonkalar Figma da **rangli** (amber oy, qizil to'ldirilgan power) — kodda monoxrom qora kontur
- [ ] Yorliq `Sleep` (1 qator) — kodda `Sleeper Berth` 2 qatorga o'raladi va katak balandligini buzadi
- [ ] Figma da **`Yard move` toggle yo'q** — kodda qo'shimcha qator (TZ dan; `DIFF.md` ga CR kerak)
- [ ] Figma da **`0/60` hisoblagich yo'q** — kodda Notes ostida bor
- [ ] Trailer/Shipping chipi: Figma `Bobtail ×` — × **matndan keyin**, chip kulrang pill, konteyner h ~52; kodda `× T-880` — × **oldin**, konteyner h ~90 (ortiqcha padding)
- [ ] Tugmalar: Figma `Cancel` kulrang fill (chegarasiz) + `Save` **qora** fill oq matn, teng enli, `r8` — kodda `Cancel` oq+chegara, `Save` fonsiz disabled matn
- [ ] Forma butun holda `345 r12 #F6F6F6` karta ichida, 24 dp chetdan — kodda full-bleed kulrang maydon
- [ ] Pastki navigatsiya (`Status` faol) goldenda yo'q

### M-22 Log Report — Main — `1085-14341`
**Render:** `test_goldens/features/logs/goldens/ci/m22_log_report_main_light_phone.png`

- [ ] App bar: chapga tekislangan `Log Report` (Plus Jakarta Bold 18, ls −0.3) + 3 ikonka, fon `#C2C1CD`@20 %, h 48
- [ ] Segmented: `342×40 r8` konteyner (fill `#C2C1CD`@20 %, pad 4), segmentlar **110×32 teng enli**, faol **qora `#1C1E24`** — kodda 3 ta kichik alohida chip, faol qizil pill
- [ ] Sana lentasi: karta `60×80 r8 fill #F5F5F5`, gap 10, **ikki qator** (`Fri` 12/21 `#777E90` + `14` 14–16/18), faol karta **qizil fill oq matn** — kodda `Mon 31` bir qator + kichik nuqta, karta ~63×62, faol holat ko'rinmaydi
- [ ] Kalit/qiymat: Figma **ikki ustun** (yorliq chapda, qiymat o'ngda) — kodda ustma-ust
- [ ] `Driver Information` sarlavhasi karta **tashqarisida** — kodda karta ichida
- [ ] Karta fon `#F6F6F6` chegarasiz `r12` — kodda oq + 1 px chegara
- [ ] Matn: Figma `Main Terminal` — kodda `Home Terminal`
- [ ] Pastki navigatsiya (`Log Report` faol qizil chip) goldenda yo'q

### M-23 Log Report — Logs — `1085-13169`
**Render:** `test_goldens/features/logs/goldens/ci/m23_log_report_logs_light_phone.png`

- [ ] App bar / segmented / sana lentasi — M-22 bilan bir xil bandlar (B-01…B-03, B-15, B-16)
- [ ] Grid soat yorliqlari **yuqorida**, `M · 1…12 · 1…11 · M` formatida — kodda `0…13` raqamlari, 24 soat sig'maydi (gorizontal overflow)
- [ ] Grid chiziqlari **och kulrang** + 15-daqiqalik mayda tirqishlar — kodda **ko'k/periwinkle** chiziqlar, tirqish yo'q
- [ ] Duty chizig'i **status rangida** (DR yashil, SB amber, ON qizil) + segment chegaralarida **hodisa nuqtalari** — kodda **qora monoxrom** chiziq, nuqta yo'q
- [ ] Jami qator: Figma `OFF 03:06` (qizil) `SB 00:00` (amber) `DR 00:00` (yashil) `ON 00:00` (cyan) — teng taqsimlangan; kodda bitta kulrang `·` bilan ajratilgan qator
- [ ] Ogohlantirish: amber **to'ldirilgan quti** `r8 pad12` — kodda fonsiz matn (yana bitta qizil violation qatori ham fonsiz)
- [ ] Jadval: Figma da `r12 #F6F6F6` karta ichida, pastida **gorizontal scroll indikatori** (amber thumb) — kodda full-bleed, karta ham, indikator ham yo'q
- [ ] Status badge: Figma `r≈6` to'ldirilgan to'rtburchak, `ON` **cyan** — kodda pill, `ON` **ko'k**, `OFF` kulrang
- [ ] Figma da **`Action` ustuni yo'q** — kodda qizil qalam ikonkali ustun bor va sarlavhasi `Actio n` bo'lib kesiladi
- [ ] Pastki navigatsiya goldenda yo'q

### M-29 Certify — `1102-397`
**Render:** `test_goldens/features/logs/goldens/ci/m29_certify_list_light_phone.png`

- [ ] App bar: fon `#C2C1CD`@20 %, chapda `<` + **`Certify` bold 18** va `(Last 8 days)` **kichikroq/yengilroq** suffiks — kodda hammasi bitta bold satr, markazlashgan, oq fon
- [ ] **«Certify Today» qatori umuman yo'q** — Figma da ro'yxat ustida alohida `345 r12` karta + o'ngda `>` chevron
- [ ] Kunlar **bitta kulrang kartaning ichida** guruhlangan (`#F6F6F6 r16`), qatorlar orasida faqat bo'shliq — kodda har qator **alohida oq karta + chegara**
- [ ] Checkbox: tanlanmagan — **qora 1.5 px kontur `r2`**; tanlangan — to'ldirilgan slate + oq belgi. Kodda och kulrang kontur, tanlangan holat ko'rinmaydi
- [ ] Badge: `Uncertified` **qizil fill + oq matn**, `Certified` **yashil fill + oq matn**, `r≈6` — kodda och tonli fon + to'q matn, pill shakl
- [ ] `Certify All` tugmasi **qora `#1C1E24`** `r8` — kodda qizil `#B7002C`
- [ ] Figma da **`Select All` matn havolasi yo'q** — kodda tugma ustida bor
- [ ] Figma da 7 qator ko'rsatilgan (8 kunlik oyna), kodda 4 — fixture ma'lumoti to'liq emas

### M-32 Add DVIR — `1089-4441`
**Render:** `test_goldens/features/dvir/goldens/ci/dvir_add_light_phone.png`
**Eng yaqin ekran — tuzilma to'liq mos.**

- [ ] App bar: fon `#C2C1CD`@20 %, chapga tekislangan sarlavha, h 48
- [ ] Figma da **`Type` (Pre-trip/Post-trip) chip qatori yo'q** — kodda qizil pill bilan bor (TZ dan; `DIFF.md` ga CR)
- [ ] Input fon: Figma **`#F7F7F8` to'ldirilgan** ingichka chegara bilan — kodda `Unit Number` **oq**
- [ ] Figma da `Trailers` maydonida **`+` yo'q** (faqat `Add Defects` maydonlarida bor) — kodda bor
- [ ] Tugmalar: `Cancel` **kulrang fill `#F2F2F5` chegarasiz**, `Next` **qora `#1C1E24`** — kodda `Cancel` oq+chegara, `Next` qizil
- [ ] Kodda `Notes` bloki tugma paneli ostida kesilib qolgan — scroll pastki paddingi tugma balandligini hisobga olmaydi
- [ ] Figma da `Odometer` qiymati birliksiz `1000` — kodda `1,000 mi` (TZ formati, ehtimol to'g'ri; tasdiqlansin)

### M-42 Chat — `1118-114`
**Render:** `test_goldens/features/chat/goldens/ci/chat_thread_light_phone.png`

- [ ] App bar: fon `#C2C1CD`@20 %, chapda `<` + chapga tekislangan `Chat` — kodda oq fon, markazlashgan, `<` yo'q
- [ ] Bubble radiusi: Figma `r16` + «dum» burchagi `r4` — kodda `StadiumBorder` (to'liq yumaloq), ko'p qatorli xabarda shakl buziladi
- [ ] Bubble maks eni ~75 %, ichki padding 12/16 — kodda kontent bo'yicha hug, padding kichik
- [ ] Yetkazish belgisi: Figma **bitta ✓** (yuborilgan) / **ikkita ✓✓** (o'qilgan) — kodda kutilayotgan holat uchun **soat ikonkasi**
- [ ] **Typing indicator bubble (`•••`) yo'q**
- [ ] Kompozitor: Figma — bitta kulrang `r24` konteyner (hint + **ichida** paper-plane) + **alohida dumaloq mikrofon tugmasi** o'ngda; kodda — chapda `+` kvadrat tugma, oq input, o'ngda dumaloq send. **Mikrofon yo'q.**
- [ ] Figma da `Beginning of the conversation` / sana ajratgichi yo'q — kodda bor (funktsional qo'shimcha, `DIFF.md` ga CR)

### M-44 Profile — `1119-445`
**Render:** `test_goldens/features/profile/goldens/ci/profile_light_phone.png`
**Ikkinchi eng yaqin ekran.**

- [ ] App bar: fon `#C2C1CD`@20 %, chapga tekislangan `Profile` + `bell/mail/refresh`, h 48
- [ ] Avatar diametri Figma ~64 — kodda ~48
- [ ] Switch: Figma yashil `#22C55E` track + to'liq oq doira thumb — kodda M3 switch (kichik konturli thumb)
- [ ] Chevron rangi Figma da ochroq/ingichkaroq
- [ ] Figma da `My devices` va `Change PIN` qatorlari yo'q — kodda bor (TZ dan; `DIFF.md` ga CR)
- [ ] Pastki navigatsiya (`Profile` faol qizil chip) goldenda yo'q

### M-45 Settings — `1131-392`
**Render:** `test_goldens/features/settings/goldens/ci/settings_light_phone.png`

- [ ] App bar: fon `#C2C1CD`@20 %, chapda `<` + chapga tekislangan `Settings`
- [ ] Figma da **atigi 2 qator**: `Diagnosis of device >` va `App updates >` — kodda `App updates` da **chevron yo'q**, o'rniga inline `Current version` / `Latest version` / status matni qo'shilgan
- [ ] Figma da **`Notifications` bo'limi (8+ toggle) yo'q** — kodda bor (TZ dan; `DIFF.md` ga CR kerak, chunki bu ekranni ~3× uzaytiradi)
- [ ] Switch uslubi (B-18). **Buzuq ko'rinish:** «Required for compliance» qatorlarida yashil track ichida **kulrang** thumb — disabled M3 switch artefakti
- [ ] Karta fon `#F6F6F6` chegarasiz `r12`

---

## D. Render infratuzilmasi

### D.1 Golden test holati
`flutter test test_goldens --update-goldens --timeout=5x` → **284/284 o'tdi, exit 0.**
Yiqilgan test yo'q; barcha PNG lar qayta generatsiya qilindi.
Yagona ogohlantirish: `dart_test.yaml` da `golden` tegi e'lon qilinmagan (`eld_screens_golden_test.dart`).

### D.2 To'liq ekran goldeni YO'Q ekranlar
`find lib/features -name "*_screen.dart"` → **38 ta ekran**. Golden testda haqiqiy `*Screen`
widgeti sifatida chiziladigani — **27 ta**. Qolgan **11 ta** ekran hech qachon render qilinmaydi:

| # | Ekran fayli | Izoh |
|---|---|---|
| 1 | `lib/features/auth/presentation/screens/login_screen.dart` | **M-02 — kanonik ekran, o'lchab bo'lmadi** |
| 2 | `lib/features/auth/presentation/screens/splash_screen.dart` | M-01 |
| 3 | `lib/features/auth/presentation/screens/pin_screen.dart` | M-04 🎨 |
| 4 | `lib/features/auth/presentation/screens/invitation_screen.dart` | M-05 🎨 |
| 5 | `lib/features/auth/presentation/screens/totp_screen.dart` | 🎨 |
| 6 | `lib/features/auth/presentation/screens/force_update_screen.dart` | 🎨 |
| 7 | `lib/features/auth/presentation/screens/sessions_screen.dart` | golden faqat `SessionsList` **sub-widgeti** uchun bor |
| 8 | `lib/features/notifications/presentation/screens/notifications_screen.dart` | golden `Scaffold` + sub-widget orqali, ekran o'zi emas (M-43) |
| 9 | `lib/features/log_edits/presentation/screens/pending_edit_detail_screen.dart` | M-27 |
| 10 | `lib/features/sync/presentation/screens/sync_conflicts_screen.dart` | 🎨 |
| 11 | `lib/features/sync/presentation/screens/sync_status_screen.dart` | 🎨 |

### D.3 Goldenlarning tizimli cheklovi
`test_goldens/features/golden_screen_host.dart` ekranni `MaterialApp(home: child)` ichida
chizadi — ya'ni `StatefulShellRoute.indexedStack` / `_MainShell` qobig'isiz.

Oqibati:
- [ ] **Pastki navigatsiya (`BNB-19`) hech bir ekran goldenida ko'rinmaydi** — Figma da esa u
      10/10 ekranda mavjud va 94 dp joy egallaydi. Bu ~11 % vertikal maydonni goldenlar
      tekshirmaydi degani.
- [ ] Ekran balandligi 852 dp da kesiladi, scroll oxiri (M-09 dagi Signature/Logs kartalari)
      goldenga tushmaydi — uzun ekranlar uchun `constraints` ni Figma freym balandligiga
      (M-09 B tartib = 1650) tenglashtirish kerak.
- [ ] Dark tema goldenlari mavjud, lekin bu audit faqat **light** ni o'lchadi.

### D.4 Etalon manbadagi nomuvofiqlik
- [ ] `png_ref/1202-9259__Home_screen_ELD_DISCONNECTED__light.jpg` — bu **drawer ochiq** (M-10)
      holati, sof Home emas. `MAP.md` §1 da M-09 «A tartib» uchun shu node ko'rsatilgan.
      M-09 ning haqiqiy etaloni — `2177-12192` (M87 bo'yicha kanonik B tartib). `MAP.md` aniqlashtirilsin.
