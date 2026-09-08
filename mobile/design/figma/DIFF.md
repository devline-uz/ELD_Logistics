# DIFF.md — Figma ↔ `design-inventory.md` ↔ `tz-mobile.md` farqlari

Manbalar: `tokens.json` (Figma, 2026-09-07) · `design-inventory.md` A.1–A.5 (1859–1945) ·
`tz-mobile.md` §11.0.1–§11.0.3 (1008–1115).

**Qoida (`README.md`):** ziddiyatda **Figma kanonik**, TZ ga CR qilinadi. Istisno — Figma ning o'zi
ziddiyatli/to'liqsiz bo'lgan holat: unda TZ qarori saqlanadi va savol dizaynerga yuboriladi.

**Jiddiylik:** 🔴 implementatsiyani bloklaydi · 🟡 aniqlashtirish kerak · 🟢 tasdiq / past

| # | Element | Figma qiymati | Hujjat/TZ qiymati | Farq turi | Tavsiya |
|---|---|---|---|---|---|
| **D-01** 🔴 | Radius 27.25 | `Carts Dropdown` = `DROP_SHADOW`, **blurRadius 27.25**, offset y=7.79, rang `#485966` 10.1 %. Burchak radiusi umuman berilmagan | `tz-mobile.md` §11.0.3 (M86): «karta va dropdown radius — **27.25**». `design-inventory.md` A.4 ham «radius 27.25» deb noaniq yozgan | **Talqin xatosi** — soya blur radiusi burchak radiusi deb o'qilgan | **Figma kanonik → TZ ga CR.** M86 dan `27.25` burchak radiusi olib tashlanadi; soya `shadowBlur: 27.25` bo'ladi. Haqiqiy burchak radiuslari ekran freymlaridan **o'lchanadi** (`tokens.json._pending.cornerRadius`) |
| **D-02** 🔴 | `body6` / `body7` | `body6` = IBM Plex Sans Regular 20 / lineHeight **120 %**; `body7` = Regular 20 / lineHeight **150 %** | §11.0.2 M84: «bir xil (Regular 20) — `body6` qoldiriladi, `body7` **alias**». A.2 ham «Body 6 va Body 7 bir xil — takror» | **Faktik xato** — lineHeight solishtirilmagan | **Figma kanonik → TZ ga CR.** M84 bekor qilinadi; `body6` (120 %) va `body7` (150 %) **ikkalasi ham** `typography.dart` da mustaqil token bo'ladi |
| **D-03** 🟢 | Warning rangi | `State Color/Warning/2` = **`#F6BA47`** | §11.0.1 M82: `#F6BA47` kanonik. A.1: Warning ASOSIY `#F6BA47` | **Farq yo'q** | **Tasdiqlandi.** Eslatma: M82 matnidagi «RGB 246,176,71» → aslida `#F6BA47` = RGB(246,**186**,71); M82 izohidagi RGB tuzatilsin (kosmetik) |
| **D-04** 🔴 | `surface` (karta), light | `Color's/Grey Light` = **`#F5F5F5`**. Figma da `#FFFFFF` nomli paint style **umuman yo'q** | §11.0.1: `surface` light = **`#FFFFFF`**. A.1 da `Grey Light #F5F5F5` bor, «qayerda ishlatilgani — —» | **Qiymat farqi** | **Figma kanonik → TZ ga CR** (`surface` light = `#F5F5F5`). Dizaynerga tasdiq savoli: karta foni haqiqatan `#F5F5F5` mi yoki `Grey Light` boshqa maqsad uchunmi |
| **D-05** 🟡 | `sidebar`, light | Figma da faqat **bitta** `Color's/Sidebar` = `#233040` (dark uchun). Light sidebar rangi yo'q | §11.0.1: `sidebar` light = `#FFFFFF` | **Manbada yo'q** — TZ o'zi qaror qilgan | **TZ kanonik → dizaynerga savol.** Mobil drawer (M-10) light foni `#FFFFFF` mi yoki `bg` `#FCFCFD` mi — `1202:9259` freymidan o'lchanadi |
| **D-06** 🟡 | `h4` qalinligi | `h4` = IBM Plex Sans **Medium** 24 | A.2: «Heading 1–4 (48/40/32/24 **Bold**)» | **Qiymat farqi** (TZ §11.0.2 og'irliklarni sanamagan) | **Figma kanonik → `design-inventory.md` A.2 tuzatiladi.** `h4` = Medium 24 |
| **D-07** 🟡 | `Color's/Light` `#EFF4FB` | Mavjud paint style | §11.0.1 tokenlar jadvalida **yo'q**. A.1: «Light `#EFF4FB` — qayerda ishlatilgani —» | **TZ da yetishmayapti** | **Dizaynerga savol** — semantikasi aniqlangach `tokens.dart` ga qo'shiladi (ehtimol `infoBg` / tanlangan holat foni) |
| **D-08** 🟡 | Decorative 7 rang | `pink #EE4E68` · `teal #30B0C7` · `green #47BB75` · `purple #7E5EF7` · `orange #F5693D` · `yellow #F7CB46` · `blue #466FF7` | §11.0.1 da faqat `blue #466FF7` (HOS shift) bor; qolgan **6 tasi jadvalda yo'q** (M81 ularni eslatadi, lekin qiymatsiz) | **TZ da yetishmayapti** | **Figma kanonik → TZ ga CR.** Barcha 7 rang `tokens.dart` da `decorative.*` sifatida; M81 ga qiymatlar jadvali qo'shiladi |
| **D-09** 🟡 | Neutral shkalasi | **11 pog'ona** (`#FCFCFD` … `#18191D`) | §11.0.1 faqat 4 tasini ishlatadi (N1, N5, N6, N9); qolgan 7 tasi tokenlar jadvalida yo'q | **TZ da yetishmayapti** | **Figma kanonik → TZ ga CR.** To'liq 11 pog'ona `tokens.dart` ga; TZ jadvali semantik alias sifatida qoladi |
| **D-10** 🔴 | `lineHeight` | Har bir darajada aniq: barchasi **120 %**, yagona istisno `body7` = **150 %** | §11.0.2 lineHeight ni **umuman eslatmaydi**; A.2 ham yo'q | **TZ da yetishmayapti** | **Figma kanonik → TZ ga CR.** `typography.dart` da har token uchun `height` majburiy (`1.2`, `body7` → `1.5`) |
| **D-11** 🔴 | Text style lar | Figma faylda **0 ta lokal text style**. Shkala faqat `Typography` seksiyasidagi (`14:543`) namuna matn tugunlaridan o'qilgan | A.2 buni qayd etgan; §11.0.2 esa shkalani tayyor deb qabul qiladi | **Manba riski** | **Risk sifatida qayd etiladi.** Shkala hech qanday ekranga biriktirilmagan → ekran freymlaridagi haqiqiy `fontSize` **shkalaga mos kelmasligi mumkin**. Har ekran chiqarilganda matn tugunlari o'lchamlari shkalaga solishtiriladi; chetlashish topilsa — dizaynerga |
| **D-12** 🔴 | Burchak radiuslari (tugma/input/chip) | Figma da **hech qayerda berilmagan** (`_pending.cornerRadius`) | §11.0.3 M86: tugma `12`, input `12`, chip `999` — «boshqa qiymatlar dizaynda yo'q → shu to'plam kanonik» | **Tasdiqlanmagan taxmin** | **Ekran freymlaridan o'lchash MAJBURIY.** O'lchashgacha M86 ning `12/12/999` qismi «taxmin» maqomida qoladi; o'lchov natijasi Figma kanonik bo'ladi |
| **D-13** 🟡 | Spacing shkalasi | Figma da berilmagan (`_pending.spacing`); A.3 ham «prezentatsiyada ko'rsatilmagan» | §11.0.3: **4 pt bazasi** `4/8/12/16/24/32/48` qabul qilingan | **TZ qarori, manba yo'q** | **TZ kanonik → ekran freymlaridan tekshiriladi.** Auto-layout `padding`/`itemSpacing` qiymatlari 4 ga karrali bo'lmasa — dizaynerga savol |
| **D-14** 🟡 | Dark tema soyasi | **Bitta** effekt uslubi (`Carts Dropdown`, opacity 10.1 %). Dark uchun alohida soya uslubi yo'q | §11.0.3: «dark temada opacity **2× pasaytiriladi**» | **TZ qarori, manba yo'q** | **TZ kanonik → dizaynerga savol.** Dark ekran freymlaridagi haqiqiy soya opacity si o'lchanadi; farq bo'lsa Figma kanonik |
| **D-15** 🟡 | Shaffof variantlar | `tokens.json` da **yo'q** | A.1: Neutral 10 `#1C1E24` 35 % · Neutral 8 `#353945` 40 % · Red `#E2464A` 30 % · Green `#2FA766` 30 % | **Ekstraksiya bo'shlig'i** | **Qayta chiqarish kerak** (`figma-extractor`): overlay/scrim va badge fonlari uchun zarur (modal barrier, M-14/M-16 dialoglari) |
| **D-16** 🟢 | Gradientlar | `tokens.json` da yo'q | A.1: 3 uslub (`L`, `l`, `lll`), barchasi `GRADIENT_LINEAR` | **Ekstraksiya bo'shlig'i, past ta'sir** | **Mobil ekranlarda ishlatilmasa — e'tibordan qoladi.** Splash (M-01) fonida gradient bo'lsa — qayta chiqariladi |
| **D-17** 🟡 | Grid / margin | A.3 da faqat **admin (1440 dp)** gridlari; mobil 393 dp uchun margin/gutter **yo'q** (`_pending.grid`) | §11.0 da mobil grid umuman yo'q | **Manbada yo'q** | **Ekran freymlaridan o'lchash.** 393 dp uchun gorizontal margin (ehtimol 16 yoki 24 dp) `eld-design-system` ga yoziladi |
| **D-18** 🟡 | Token tizimi | A.5: **1 ta** variable collection, 1 mode, **1 ta o'zgaruvchi** — token tizimi qurilmagan; ranglar paint style orqali | §11.0.1 tokenlarni tayyor deb qabul qiladi | **Manba riski** | **Risk sifatida qayd etiladi.** Figma variable lar yo'qligi sababli light/dark almashuvi dizaynda **avtomatik emas** — har ekran ikki nusxada chizilgan (`MAP.md` §1). Kod tomonda `tokens.dart` yagona haqiqat manbai bo'ladi |
| **D-19** 🟢 | `surfaceAlt` (dark) | `Color's/Sidebar` = `#233040` | §11.0.1: `surfaceAlt` dark = `#233040` **va** `sidebar` dark = `#233040` | **Farq yo'q, semantik ikkilanish** | **Tasdiqlandi.** Bitta hex ikki semantik rolda — `tokens.dart` da ikkala nom ham saqlanadi, qiymat bitta |
| **D-20** 🟡 | Product Sans | `display1`/`display2` = **Product Sans** Bold 48/40 | §11.0.2 M83: litsenziya bo'lmasa IBM Plex Sans Bold bilan almashtiriladi ❓ | **Ochiq savol (TZ da belgilangan)** | **Huquqiy tekshiruv kerak.** Product Sans — Google ning yopiq shrifti, uchinchi tomon ilovalarida ishlatib bo'lmaydi → **IBM Plex Sans Bold** amalda kanonik bo'lishi ehtimoli yuqori |
| **D-21** 🟢 | `primary`, `bg`, `stroke`, matn ranglari, Success/Error triadalari, HOS `shift` | `#B7002C` · `#FCFCFD`/`#1B222C` · `#E5E7EB`/`#52565F` · N9 `#23262F`/N1 `#FCFCFD` · N6 `#777E90`/N5 `#B1B5C3` · `#2FA766`/`#C5EFD8`/`#103923` · `#E2464A`/`#F9DADB`/`#5A1C1E` · `#466FF7` | §11.0.1 bilan **qatorma-qator bir xil** | **Farq yo'q** | **Tasdiqlandi** — o'zgartirish talab qilinmaydi |

---

## Yakun

| Jiddiylik | Soni | Raqamlar |
|---|---|---|
| 🔴 Bloklovchi | **6** | D-01, D-02, D-04, D-10, D-11, D-12 |
| 🟡 Aniqlashtirish kerak | **11** | D-05…D-09, D-13…D-15, D-17, D-18, D-20 |
| 🟢 Tasdiq / past ta'sir | **4** | D-03, D-16, D-19, D-21 |
| **Jami** | **21** | |

## Harakatlar

**TZ ga CR (Figma kanonik):** D-01 (M86 radius), D-02 (M84 bekor), D-04 (`surface` light `#F5F5F5`),
D-08 (7 decorative rang), D-09 (11 neutral pog'ona), D-10 (lineHeight tokenlari).

**Dizaynerga savol:** D-04 tasdig'i, D-05 (light sidebar), D-07 (`#EFF4FB` semantikasi),
D-14 (dark soya), D-20 (Product Sans litsenziyasi) + `MAP.md` §5 dagi 10 savol.

**O'lchash kerak (keyingi ekstraksiya):** D-01/D-12 burchak radiuslari, D-13 spacing,
D-15 shaffof variantlar, D-17 mobil grid margin, D-11 ekranlardagi haqiqiy fontSize lar.

**`design-inventory.md` tuzatiladi:** A.2 `h4` = Medium (D-06); A.2 «Body 6 = Body 7» bandi (D-02);
A.4 «radius 27.25» → «soya blur radiusi 27.25» (D-01).

---

## O'lchangan qiymatlar (M1F-2) — D-12 va spacing savoli yopildi

**Usul:** 10 ta kanonik ekran freymi (`1202:9259` Home, `958:44` Login, `1085:14341` Log Report Main,
`1085:13169` Log Report Logs, `1119:445` Profile, `1083:10550` Change Status, `1089:4441` Add DVIR,
`1118:114` Chat, `1156:7135` Notification, `1131:392` Settings) ichidagi **barcha** tugunlarning
`cornerRadius`, auto-layout `padding`/`itemSpacing` va `strokeWeight` chastota taqsimoti.

| # | Element | Figma o'lchovi (chastota) | TZ qiymati | Jiddiylik | Tavsiya |
|---|---|---|---|---|---|
| **D-22** | **Burchak radiusi** | `8` ×56 · `4` ×30 · `24` ×25 · `6` ×18 · `10` ×18 · `12` ×4 · `200` (pill) ×6. **`27.25` — 0 marta** | §11.0.3: karta/dropdown `27.25`, tugma `12`, input `12`, chip `999` | 🔴 | **Figma kanonik.** Token: `sm=4`, `md=8`, `lg=12`, `xl=24`, `pill=200`. Dominant `8`. D-01 ni tasdiqlaydi — `27.25` soya blur radiusi. TZ M86 ga CR |
| **D-23** | **Spacing bazasi** | gap: `10` ×193 · `5` ×113 · `15` ×53 · `8` ×46 · `20` ×18 · `25` ×18 · `4` ×14 | §11.0.3: «dizaynda berilmagan → **4 pt** bazasi qabul qilinadi» | 🔴 | **5 pt baza**, 4 emas. Shkala: `5/10/15/20/25/30/40`. TZ dagi taxmin xato — CR kerak |
| **D-24** | Ekran gorizontal padding | `16` ×46 (eng ko'p ishlatilgan yaxlit qiymat); `15.74` ×60 va `25.5` ×40 — piksel-siljigan qiymatlar | TZ da yo'q | 🟡 | `screenPaddingH = 16`. `15.74`/`25.5`/`13.41` — dizaynda tekislanmagan qiymatlar, dizaynerga savol |
| **D-25** | Stroke qalinligi | `1` ×164 · `2` ×22 · `1.5` ×13 | TZ da yo'q | 🟢 | default `1`, urg'u `2`. `1.5` — tasodifiy, ishlatilmaydi |

Barchasi `tokens.json` ning `radius`, `spacing`, `stroke` bo'limlariga yozildi (histogramlari bilan).

---

## 🔴 KRITIK: dizayn ichki nomuvofiqligi (M1F-3, 67 ekran JSON tahlilidan)

Ekranlarning **haqiqiy tugun daraxti** (67 light ekran, 2 869 matn tuguni, 6 812 rang ishlatilishi)
uslub qo'llanmasi (`Branding & Color`) bilan solishtirildi. Natija: **ekranlar uslub qo'llanmasiga amal qilmaydi.**

### D-26 🔴 Shriftlar — qo'llanmada 2 ta, ekranlarda 10+

Qo'llanma: **IBM Plex Sans** (hamma matn) + **Product Sans** (faqat Display).
Ekranlarda haqiqatda:

| Shrift oilasi | Matn tugunlari | Ulush |
|---|---|---|
| **Plus Jakarta Sans** (Medium/Bold/SemiBold/Regular/ExtraBold/Italic) | 1 439 | **50%** |
| **Product Sans** (Regular/Bold/Medium) | 511 | 18% |
| **Satoshi Variable** (Bold/Regular/Medium) | 439 | 15% |
| **Inter** (Medium/Regular/SemiBold/Bold) | 333 | 12% |
| MIXED (bitta tugunda bir necha shrift) | 88 | 3% |
| **IBM Plex Sans** — qo'llanmadagi asosiy shrift | **67** | **2%** |
| DM Sans · Roboto · Avenir Heavy · Rethink Sans · Microsoft Sans Serif | 25 | <1% |

**Ta'sir:** «UI Figma bilan piksel darajasida bir xil» talabini bajarib bo'lmaydi —
qaysi shrift kanonik ekani noma'lum. Satoshi va Plus Jakarta Sans **litsenziya** talab qiladi.
`Microsoft Sans Serif` va `Avenir` — tasodifiy (nusxa-joylashtirish izlari).

**Tavsiya:** dizaynerdan **bitta** matn shrifti tanlashini so'rash. Amaliy nomzod — **Plus Jakarta Sans**
(50% ishlatilgan, SIL Open Font License, bepul). Qaror chiqmaguncha `core/ui/typography.dart`
`Plus Jakarta Sans` bilan quriladi va `TODO(D-26)` qo'yiladi.

### D-27 🔴 O'lchamlar shkalasi qo'llanmadagidan farq qiladi

Qo'llanma: `48/40/32/26/24/20/18/16/14/12/10`.
Ekranlarda haqiqatda: **14** (1 365 ×) · **12** (691) · **16** (488) · **10** (150) · 18 (52) · 19/17/22/20 (kam).
`26`, `24`, `32`, `40`, `48` — mobil ekranlarda **deyarli umuman ishlatilmagan**.

**Tavsiya:** mobil tipografika shkalasi amalda 4 pog'onali: `10 / 12 / 14 / 16` (+ 18 kamdan-kam).
`body1…body5` (26–20 pt) mobil ekranlarda kerak emas — planshet uchun qoldiriladi.

### D-28 🔴 lineHeight ning yarmi `AUTO`

`AUTO`: 1 557 · `20`: 569 · `24`: 175 · `18.76`: 156 · `22`: 146 · `16`: 100 · `120%`: 85.
Qo'llanmadagi «hamma joyda 120%» qoidasi ekranlarda **85 marta** ishlatilgan (3%).
`18.76` — hisoblangan qiymat (Inter 14 × 1.34), tekislanmagan.

**Tavsiya:** `AUTO` → Flutter `height: null`; aniq qiymatlar `height: lh/fontSize` bilan beriladi.
Piksel-parite uchun har matn uchun JSON dagi aniq `lh` ishlatiladi, umumiy qoida emas.

### D-29 🟡 Ranglarning 37% i tokenlarda yo'q

6 812 rang ishlatilishidan **4 312 (63%)** tokenlarga mos, **2 500 (37%)** mos emas.
71 xil hex qiymat vs tokenlardagi 36 ta. Eng ko'p uchraydigan token bo'lmagan ranglar:

| Hex | Marta | Izoh |
|---|---|---|
| `#000314` | 600 | deyarli qora — `#1C1E24` (Neutral 10) o'rniga ishlatilgan? |
| `#FFFFFF` | 390 | sof oq — tokenlarda `bgLight #FCFCFD` bor, `#FFFFFF` yo'q (D-04 bilan bog'liq) |
| `#000000` | 253 | sof qora — token emas |
| `#358D0C` | 140 | yashil — `success #2FA766` dan farq qiladi |
| `#D9D9D9` · `#C2C1CD` · `#F6F6F6` | 286 | kulranglar — Neutral shkalasida yo'q |
| `#36454F` | 132 | ko'kimtir kulrang |
| `#0086FF` · `#007AFF` | 139 | ikki xil ko'k (iOS tizim ko'ki) — `#466FF7` dan farqli |
| `#D97D28` · `#FFBF00` | 142 | to'q sariq/sariq — `warning #F6BA47` dan farqli |

**Tavsiya:** token bo'lmagan ranglar dizaynerga ro'yxat sifatida beriladi: har biri uchun
«bu token bo'lishi kerakmi yoki xatomi?». Qaror chiqmaguncha `screen-implementer` ekran JSON'idagi
**aniq hex** ni ishlatadi va `TODO(D-29)` qo'yadi — tokenga majburan tortmaydi.

## M1 implementatsiya qarorlari (`core/ui/tokens.dart`, 2026-09-07)

Bosqich M1 da quyidagi ochiq bandlar **kodda vaqtinchalik hal qilindi**; dizayner javobidan keyin
token qiymati bir joyda (`AppPalette`) o'zgaradi, komponentlar tegilmaydi.

| # | Band | M1 dagi qaror | Kutilayotgan javob |
|---|---|---|---|
| **D-04** 🔴 | `surface` light: Figma `#F5F5F5` ↔ TZ `#FFFFFF` | **Ikkalasi ham token qilindi.** `surface` = `#FFFFFF` (karta — TZ), `surfaceMuted` = `#F5F5F5` (Figma `Color's/Grey Light`), `surfaceAlt` = `#F2F4F7` (jadval sarlavhasi — TZ/`GREY`). Kartalarda `surface` ishlatiladi | Dizayner karta fonini tasdiqlasin: `#FFFFFF` mi, `#F5F5F5` mi. Agar `#F5F5F5` bo'lsa — faqat `AppColors.light.surface` `AppPalette.greyLight` ga o'zgaradi |
| **D-05** 🟡 | Light sidebar Figma da yo'q | `sidebar` light = `#FFFFFF` (TZ qarori saqlandi) | M-10 drawer freymi o'lchansin |
| **D-07** 🟡 | `Color's/Light` `#EFF4FB` semantikasi | `primaryLight` sifatida qabul qilindi; `StatusBadge(tone: accent)` va `NavigationBar` indikator foni | Semantika tasdiqlansin |
| **D-12** 🔴 | Tugma/input/chip radiusi Figma da o'lchanmagan | `Radii.button` = `Radii.input` = **12** (`lg`, histogrammada mavjud), `chip`/`badge` = **200** (`pill`, Figma da 6 marta uchraydi). `999` emas — Figma `200` beradi | Ekran freymlaridan o'lchansin (D-12 ochiq) |
| **D-13** 🟡 | Spacing bazasi | **5 pt** (Figma o'lchovi) qabul qilindi: `5/10/15/20/25/30/40`; ekran padding **16**. TZ dagi 4 pt shkalasi ishlatilmaydi | TZ §11.0.3 ga CR |
| **D-14** 🟡 | Dark soya | `ShadowSpec.opacityDark = opacityLight / 2` (TZ qarori) | Dark freymlardan o'lchansin |
| **D-15** 🟡 | Shaffof variantlar | `scrim` = Neutral 10 @ 35 % (A.1 dan) `tokens.dart` da; qolgan 3 tasi qo'shilmadi — kerak bo'lganda qayta chiqariladi | Qayta ekstraksiya |
| **D-20** 🟡 | Product Sans | `kFontFamilyDisplay = kFontFamilyBase` (IBM Plex Sans Bold), `TODO(M83)` bilan | Huquqiy tekshiruv |

**Yangi band — D-22 🔴 `assets/fonts/` bo'sh:** IBM Plex Sans (`.ttf`) fayllari repoda **yo'q**.
`pubspec.yaml` dagi `fonts:` bo'limi tayyor holda izohda turibdi; fayllar qo'shilmaguncha ilova
platforma standart shriftida chiziladi va **golden etalonlari qayta yaratilishi kerak**
(`flutter test test_goldens --update-goldens`). IBM Plex Sans — SIL OFL 1.1, yuklab olish mumkin.

---

## O'lchangan javoblar (M1F-4, 2026-09-08) — D-27 / D-28 / D-29 yopildi

**Metodika farqi:** D-26…D-29 ning avvalgi raqamlari `screens/*.json` dagi **hamma** tugunni sanagan
(`hidden:true` freymlar ham). Quyidagi raqamlar **faqat ko'rinadigan** tugunlarni sanaydi
(`hidden` shoxlar butunlay tashlab yuborilgan) — ya'ni ekranda **haqiqatan render bo'ladigan** narsa.
67 ekran · **1 656 ko'rinadigan TEXT tuguni** · **5 348 rang ishlatilishi**.

### D-27 ✅ YOPILDI — amaldagi fontSize shkalasi

| fontSize | Marta | Ulush |
|---|---|---|
| **14** | 640 | **38.9 %** |
| **12** | 425 | **25.9 %** |
| **16** | 307 | **18.7 %** |
| **10** | 129 | 7.8 % |
| 5 | 64 | 3.9 % (mikro-belgilar, HOS grid) |
| 18 | 40 | 2.4 % |
| 19 | 15 | 0.9 % |
| 17 | 7 | 0.4 % |
| 4 · 48 | 4 · 2 | 0.4 % |
| 11.14 / 12.38 / 12.41 / 12.53 / 13.92 / 13.97 / 15.75 / 22.06 / 22.47 | 1–2 har biri | **butun bo'lmagan — 11 ta tugun, transform natijasi** |

**Javob:** 19 xil aniq o'lcham; ammo **`10/12/14/16` to'rttasi 91.3 %** ni beradi.
Qo'llanmadagi **20–48 pt shkalasi (20, 24, 26, 32, 40) mobil ekranlarda 0 marta** ishlatilgan;
`48` atigi 2 marta (splash/xato ekranidagi katta raqam). **D-27 tavsiyasi tasdiqlandi:**
mobil shkala = `10 / 12 / 14 / 16` + `18` (kam) + `5` (HOS grid mikro-yorliqlari).
`body1…body5` (20–26 pt) mobilda kerak emas.

⚠️ Yangi: **11 ta matn tuguni butun bo'lmagan fontSize** ga ega (11.14, 12.38, 13.97, 22.06 …) —
bu masshtablangan (scale-transform qilingan) freymlar belgisi. `screen-implementer` ularni
eng yaqin butun songa yaxlitlaydi; dizaynerga tozalash so'rovi.

### D-28 ✅ YOPILDI — `AUTO` ning aniq piksel qiymati

Ko'rinadigan matnlar: **`AUTO` = 998 (60.3 %)**, aniq son = 658 (39.7 %).
`AUTO` = shriftning o'z metrikasi. Bir qatorli `AUTO` tugunlarning **modal balandligi** o'lchandi:

| Shrift | fontSize → balandlik (o'lchangan) | Nisbat |
|---|---|---|
| **Plus Jakarta Sans** (barcha weight) | 10→13 · 12→15 · 14→18 · 16→20 · 18→23 | **1.26** |
| **Satoshi Variable** | 12→16 · 14→19 · 18→24 | **1.34** |
| **Product Sans** | 14→17 · 16→19 | **1.19** |
| Roboto | 4→5 | 1.25 |

**Plus Jakarta Sans uchun aniq nisbat = `1.26`** (shrift metrikasi: ascender 1000, descender −260,
unitsPerEm 1000 → (1000+260)/1000 = 1.26). Piksel qiymati = **`round(fontSize × 1.26)`**:

```
10 → 13   12 → 15   14 → 18   16 → 20   18 → 23   20 → 26   24 → 31
```

Bu **`h1.26` emas, `round()` bilan** — Figma butun pikselga yaxlitlaydi. Flutter da piksel-parite uchun
`height: null` **yetarli emas** (Flutter Plus Jakarta Sans metrikasidan boshqa qiymat chiqarishi mumkin);
`screen-implementer` `AUTO` uchun **`height: round(fs*1.26)/fs`** beradi.

Aniq `lh` qiymatlari orasida eng ko'p: `14/20` (×176, nisbat 1.429) · `16/24` (×63, 1.5) ·
`14/18.76` (×58, 1.34 — Inter hisoblangani, tekislanmagan) · `16/20` (×47, 1.25) · `12/16` (×28, 1.333).
Yagona `fs=5, lh=22` (×64) — HOS grid ustun yorliqlari, nisbat 4.4 (ataylab).

### D-29 ✅ YOPILDI — token bo'lmagan ranglar ro'yxati

Ko'rinadigan tugunlarda **64 xil hex** (fill + stroke), **5 348 ishlatilish**.
`tokens.json` da **37 hex**. Ulardan **23 tasi ishlatiladi, 14 tasi umuman ishlatilmaydi**:
`#1B222C` `#233040` `#EFF4FB` `#F2F4F7` `#52565F` `#18191D` `#C5EFD8` `#103923` `#7B5D24`
`#F9DADB` `#5A1C1E` `#7E5EF7` `#F5693D` `#485966`.

**41 hex tokenlarda yo'q.** Eng ko'p uchraydigan 10 tasi va tavsiya:

| # | Hex | Marta | Kontekst (o'lchangan) | Token bo'lsinmi? |
|---|---|---|---|---|
| 1 | `#000314` | **1 085** | 1 036 tasi `VECTOR` fill/stroke (`iconoir:*`, `weui:*` ikonkalar) | ✅ **HA — `icon.default`.** Eng ko'p ishlatilgan rang, tokensiz. Alfa variantlari ham bor: `/0.40` (13), `/0.39` (10), `/0.21` (5), `/0.50` (3) → `icon.muted` |
| 2 | `#FFFFFF` | 275 | karta/modal foni (`RECTANGLE`, `FRAME`) | ✅ **HA — `surface`.** D-04 bilan bog'liq: token `bgLight` = `#FCFCFD`, lekin ekranlarda `#FFFFFF` ham 275 marta. Ikkalasi ham kerak |
| 3 | `#000000` | 241 | **hammasi `VECTOR`** (`iconoir:refresh` ×46, `pepicons-pencil:leave` ×36, `weui:back-outlined` ×33) | ❌ **XATO.** Bu ikonkalar `#000314` bo'lishi kerak edi — dizaynda ikki xil ikonka rangi aralashgan. Dizaynerga tuzatish so'rovi |
| 4 | `#358D0C` | 102 | `ELLIPSE` + `TEXT` — duty-status indikatori (yashil) | ✅ **HA — `status.driving` / `success`.** Token `success` `#2FA766` dan farq qiladi (D-29 avvalgi qaydi) |
| 5 | `#C2C1CD` | 76 | 73 tasi `/0.20` alfa bilan — ajratgich/skrim | ✅ **HA — `divider` (`#C2C1CD` @20 %)** |
| 6 | `#F6F6F6` | 67 | `FRAME` foni | ⚠️ **XATO ehtimoli.** Token `surfaceLight` = `#F5F5F5`. 1 birlik farq — **drift**, `#F5F5F5` ga birlashtirilsin |
| 7 | `#D9D9D9` | 58 | **hammasi `ELLIPSE`, «25%» freymida** | ❌ **XATO — Figma standart to'ldirish rangi** (placeholder). Haqiqiy rang qo'yilmagan joylar |
| 8 | `#36454F` | 58 | **hammasi `TEXT`, «25%» freymida** | ⚠️ Token `surfaceDark` = `#303E4B` ga yaqin, lekin farqli. `#D9D9D9` bilan bir xil freymda → o'sha tugallanmagan blok |
| 9 | `#007AFF` | 48 | iOS tizim ko'ki — `VECTOR` + `ELLIPSE`/`TEXT` («25%») | ❌ **Token emas** — iOS status bar maketi. Ilovada ishlatilmaydi |
| 10 | `#D97D28` | 47 | `ELLIPSE`/`TEXT` («25%») + `RECTANGLE` (`track-and-stop`) | ✅ **HA — `status.onDuty` / `warning2`.** Token `warning` `#F6BA47` dan farqli |

Qolgan 31 hex birgalikda **~180 ishlatilish** (har biri ≤19): `#BE2928` (19), `#667085` (18),
`#EAECF0` (18), `#D2D2D2`/`#2B2B2B`/`#514F4F`/`#D30202` (10 ×4), `#424242` (9), qolgani ≤8.

⚠️ **«25%» nomli freym** — `#D9D9D9` + `#36454F` + `#007AFF` + `#D97D28` + `#358D0C` ning katta qismi
o'sha bitta nomlanmagan blokda. Bu **tugallanmagan/vaqtinchalik** dizayn bloki bo'lishi mumkin;
`screen-implementer` undan token chiqarmasin. Dizaynerga savol.

### B-62 ✅ TASDIQLANDI — `1107:2310` da ikonkalar almashib ketgan

`screens/1107-2310__permission.json` dan o'lchandi (`Frame 1321317367` satrlari):

| Satr matni | Biriktirilgan ikonka | To'g'rimi |
|---|---|---|
| Location | `proicons:location` | ✅ |
| Location always | `hugeicons:location-08` | ✅ |
| Bluetooth | `proicons:bluetooth` | ✅ |
| Notifications | `iconamoon:notification-light` | ✅ |
| **Turn on GPS** | **`la:bluetooth`** | ❌ **ALMASHGAN** |
| **Turn on bluetooth** | **`solar:gps-linear`** | ❌ **ALMASHGAN** |

**Xulosa:** ha, aynan ikkita pastki harakat satrida ikonkalar almashgan. Yuqoridagi to'rt ruxsat satri to'g'ri.
`screen-implementer` **to'g'rilangan** holda yozadi (GPS→location ikonkasi, Bluetooth→bluetooth ikonkasi);
Figma da tuzatish — dizaynerga.

### B-63 ❌ RAD ETILDI — `1122:319` tugmasi `#1C1E24`

`screens/1122-319__check_Network.json`: `Button` (FRAME, 305×39, `cornerRadius 5.5`, matn «Check Network»)
→ `fill: ["#1C1E24"]`. Shu ekranda `#1C1E24` 14 marta, **`#1F2126` 0 marta**.
Qo'shimcha: `1122:63` (ikkinchi check Network freymi) — ayni `#1C1E24`.

**`#1F2126` butun 67 ekran JSON'ida umuman uchramaydi.** B-63 yopiladi: tugma rangi = **`#1C1E24`**
(bu `tokens.json` dagi mavjud token). `#1F2126` qayerdan kelgani noma'lum — ehtimol ekran suratidan
ko'z bilan olingan (JPEG artefakti).

### B-123 ✅ YOPILDI — planshet etaloni endi bor

Planshet freymlari **chizilgan** (148 light + 149 dark, hammasi 1366×1024) — ilgari skanerlanmagan edi.
To'liq T-ID xaritasi: `MAP.md` §7. **58 planshet etalon rasmi** `png_ref/` ga eksport qilindi.
Qolgan bo'shliqlar (T-05, T-06, T-13, T-16, T-17, T-30 chizilmagan; T-25/T-26 faqat dark;
T-08 faqat light) — `MAP.md` §7.4 da dizaynerga savol sifatida.
