# VERIFY — Login / Drive mode / Dialog ekranlari (light, phone)

Manba: golden PNG (`test_goldens/**/goldens/ci/`) ↔ Figma etalon (`design/figma/png_ref/`).
Juftliklar: `design/figma/VERIFY-PAIRS.md`.

---

## M-02 Login (empty) — golden `m02_login_empty_light_phone.png` ↔ figma `958-44__Login__light.jpg`
Parite: 72%

### Tafovutlar
- [ ] Logo: Figma — grafik wordmark (qizil `O` + stilizatsiyalangan `ne` bloklari, ikonka shakli) ustida `BOOK ELD`; ilovada — oddiy matnli `One` (qizil, script emas) + `BOOK ELD`. Logotip aktivi (SVG/PNG) umuman qo'yilmagan.
- [ ] Logo o'lchami/pozitsiyasi: Figma — logo bloki kenglik ~150 px, markazda, tepadan ~110 px; ilovada — matn ~180 px kenglik, tepadan ~55 px (status bar hisobga olinmaganda ham ~40 px yuqorida).
- [ ] «Forgot password?» havolasi: Figma da bu ekranda YO'Q; ilovada Login tugmasi ostida qizil `Forgot password?` markazda qo'shilgan.
- [ ] Disabled Login tugmasi: Figma — to'q kulrang to'ldirilgan fon (`#7F8189` atrofida) + **oq** matn; ilovada — juda och kulrang fon (`#F1F2F4` atrofida) + kulrang matn. Kontrast va tugma «og'irligi» mos emas.
- [ ] Tugma balandligi/radiusi: Figma — h≈48, r≈8, gorizontal margin 28; ilovada — h≈44, r≈8, margin 24.
- [ ] Input maydonlari: Figma — fon och kulrang (`#F8F9FB`) + juda yumshoq chegara, h≈44; ilovada — fon oq, ko'rinadigan kulrang chegara, h≈48.
- [ ] Parol «ko'z» ikonkasi: Figma — chiziq bilan kesilgan yupqa qalamli ko'z (custom), rangi to'q; ilovada — Material `visibility_off` ikonkasi (boshqa shakl, boshqa qalinlik).
- [ ] Info banner matn qatorlari: Figma — 2 qator, matn justify (chetlarga tekislangan), font ~13; ilovada — 3 qator, font ~12, kengligi kichikroq.
- [ ] Info banner ichki paddingi: Figma — v≈16/h≈16, ikonka va matn orasida ~12; ilovada — padding ~12, ikonka-matn oralig'i ~8.
- [ ] Footer: Figma `Copyright © 2025 OneBook ELD`; ilovada `Copyright © 2026 OneBook ELD` (yil dinamik — golden barqarorligi uchun fixed clock kerak).

### Mos kelgani
- Bloklar tartibi: logo → username label+input → password label+input → Login → info banner → footer ajratgich + copyright.
- Label matnlari: `Username or Email address`, `Password`; placeholderlar `Enter email address`, `Enter password`.
- Info banner matni va `i` ikonkasi doira ichida, och kulrang fon.
- Footer yuqorisidagi 1px ajratgich chiziq va markazlashgan copyright.

---

## M-02 Login (filled) — golden `m02_login_filled_light_phone.png` ↔ figma `1113-9176__Login_-_filled__light.jpg`
Parite: 55%

### Tafovutlar
- [x] **Maydonlar to'ldirilmagan**: `LoginScreen` endi `TextEditingController` matnini `LoginState.username/password` bilan sinxronlaydi — golden endi haqiqiy qiymatlarni ko'rsatadi.
- [ ] Kiritilgan matn uslubi (tekshirib bo'lmadi, chunki matn yo'q): Figma — `#1C1E24`, 15/16 px, left padding 20.
- [ ] Faol Login tugmasi: Figma fon `#1C1E24`, r≈8, h≈48, matn oq bold 16; ilovada fon deyarli bir xil to'q (`#1B1D22`), lekin h≈44, matn weight yengilroq.
- [ ] «Forgot password?» havolasi Figma da yo'q, ilovada bor (yuqoridagi bilan bir xil tafovut).
- [ ] Logo — M-02 empty dagi bilan bir xil tafovut (grafik wordmark yo'q).
- [ ] Copyright yili 2025 ↔ 2026.
- [ ] Info banner 2 qator ↔ 3 qator.

### Mos kelgani
- Faol holatda tugma to'q fon + oq matnga o'tadi (rang oilasi to'g'ri).
- Boshqa barcha bloklar tartibi va matnlari empty holat bilan bir xil va Figma ga mos.

---

## M-02 Login (error) — golden `m02_login_error_light_phone.png` ↔ figma `958-44__Login__light.jpg` (xato holati uchun etalon frame yo'q)
Parite: 70% (baza ekran bo'yicha; xato bloki uchun Figma etaloni topilmadi)

### Tafovutlar
- [ ] Xato holati uchun `png_ref/` da alohida Figma frame yo'q (`VERIFY-PAIRS.md` da ham `958-44__Login__light` ko'rsatilgan) — xato matni uslubi/joylashuvi etalon bilan tasdiqlanmagan. Figma dan `Login - error` frame eksport qilinishi kerak.
- [ ] Xato ko'rsatkichi ilovada faqat **parol** maydoni ostida (`(!) Incorrect email or password.`, qizil, 12px, chapda). Odatiy ELD patterni bo'yicha ikkala maydon chegarasi ham qizil bo'lishi kerak — ilovada input chegaralari kulrangligicha qolgan.
- [ ] Xato paydo bo'lganda Login tugmasi FAOL (to'q fon) holatda; maydonlar bo'sh bo'lsa tugma disabled bo'lishi mantiqan kutiladi — holatlar ziddiyatli.
- [ ] Xato qatori qo'shilishi bilan pastdagi bloklar ~30 px pastga siljigan; Figma da bunday siljish uchun rezerv joy (fixed helper slot) ko'rsatilmagan.
- [ ] Logo / «Forgot password?» / copyright yili — M-02 empty bilan bir xil tafovutlar.

### Mos kelgani
- Xato matni qizil `(!)` doira ikonkasi bilan, parol maydoniga yaqin joylashgan.
- Ekranning qolgan barcha bloklari empty holat bilan bir xil.

---

## M-15 Drive mode — golden `m15_drive_mode_light_phone.png` ↔ figma `1170-2684__IN-DRIVE_FOCUSED__light.jpg`
Parite: 60%

### Tafovutlar
- [ ] **Ortiqcha blok**: ilovada info kartadan keyin `Off Duty` / `On Duty` ikki tugmasi bor; Figma IN-DRIVE FOCUSED ekranida bu tugmalar YO'Q (ekran faqat halqa + info karta, qolgani bo'sh).
- [ ] Halqa rangi: Figma to'q o't-yashil (`#2E8B22` atrofida); ilovada emerald/yumshoq yashil (`#34A853`/`#2FB673` atrofida). Progress va matn `DRIVE` rangi ham shu farq bilan.
- [x] Halqa treki (bo'sh qismi): endi `c.strokeStrong` (to'q kulrang) ishlatiladi, stroke qalinligi `14` (avval `10`).
- [x] Halqa diametri: `205` (phone) / `280` (tablet) ga qisqartirildi (avval `240`/`320`). Joylashuv pozitsiyasi Figma bilan to'liq mos emas (layout tartibi o'zgartirilmadi).
- [~] Halqa ichidagi vaqt tipografiyasi: qatorlar orasidagi bo'shliq siqildi; aniq px (26/28 vs joriy `h4`) hali token darajasida solishtirilmagan.
- [x] Info karta foni: `c.hosDrive.withValues(alpha: 0.08)` — och yashil tint (pointer uchburchagi hali qo'shilmagan).
- [x] Info karta qiymatlari: endi bold (`FontWeight.w700`) va `textPrimary` rangda; label ham `textPrimary` ga o'tkazildi.
- [x] Info karta qator balandligi: qatorlar orasi `Spacing.s20` ga oshirildi (avval `s10`).
- [ ] Sana/vaqt formati: Figma `11 MAY, 2025 11:05 PM` uslubi ↔ ilovada `AppFormats.fullDateTime` — format o'zgartirilmadi (lokalizatsiya qatlamiga tegishli, bu hujum doirasidan tashqarida).
- [x] Status qatori matn o'lchami: `body14` + bold ga oshirildi (avval `body13` regular).
- [x] AppBar: `showDivider: false` — sarlavha ostidagi ajratgich chiziq olib tashlandi.

### Mos kelgani
- Bloklar tartibi: AppBar `Duty Hours` → status qatori (yashil nuqta + `In-motion` + sana) → progress halqa (vaqt + `DRIVE`) → info karta (`Driving Time Left`, `Current Location`).
- `Driving Time Left = 02:32:xx` va `Current Location = 342, Plot B` qiymatlari.
- Halqa progress yo'nalishi (yuqoridan soat yo'nalishi bo'ylab) va bo'sh sektor pozitsiyasi.

---

## M-16 Idle prompt — golden `m16_idle_prompt_light_phone.png` ↔ figma `2181-17282__IN-DRIVE_FOCUSED__light.jpg`
Parite: 20%

### Tafovutlar
- [x] **Asosiy: dialog umuman yo'q.** Golden test endi `IdlePromptOverlay` ni `DriveModeScreen` ustiga qatlam sifatida to'g'ridan-to'g'ri chizadi (controller taymeriga bog'liq bo'lmasdan) — dialog endi render bo'ladi.
- [x] Scrim: `ModalBarrier` orqali `c.scrim` bilan qoraytirilgan, endi goldenda ko'rinadi.
- [x] Dialog kartasi: oq fon, `Radii.modalRadius`, markazda — endi render bo'ladi (aniq px o'lchamlar hali Figma bilan to'liq solishtirilmagan).
- [x] Dialog ikonkasi: amber doira ichida `i` — mavjud va render bo'ladi.
- [x] Dialog matni: markazlashgan xabar — mavjud va render bo'ladi.
- [x] Dialog tugmalari: `No` (secondary) / `Yes, Driving` (primary) — mavjud va render bo'ladi.
- [ ] Yopish tugmasi: Figma — o'ng yuqori burchakda ingichka kulrang `×`; ilovada — hali qo'shilmagan.
- [ ] Fon ekran qiymati: Figma da `Current Location = 342, Plot B`; ilovada `N/A`.

### Mos kelgani
- Orqa fondagi ekran tarkibi (AppBar, status qatori, halqa, info karta) M-15 bilan bir xil — Figma da ham modal ostida shu ekran turadi.

---

## M-14 Location inaccurate — golden `m14_location_inaccurate_light_phone.png` ↔ figma `1102-2021__location_error__light.jpg`
Parite: 62%

### Tafovutlar
- [x] **`Update Now` tugmasi matni kesilgan**: `AppButton.primary` endi to'liq `Update Now` matnini ko'rsatadi (golden tasdiqlandi).
- [x] Orqa fon (scrim): golden endi `ModalBarrier` + `c.scrim` bilan qoraytirilgan fonda render qiladi.
- [x] Dialog kengligi: ekran kengligining `~86%` (`MediaQuery.width * 0.86`).
- [x] Dialog vertikal joylashuvi: `Alignment(0, -0.35)` — yuqori-o'rta qismga ko'chirildi.
- [x] Tugmalar o'lchami: `Expanded` + minHeight (touch target) bilan kengroq, golden tasdiqlandi.
- [x] `Cancel` tugmasi uslubi: `DutyOutlineButton` — oq fon + och chegara.
- [x] Ichki info banner bir qatorga sig'ishi: ikonka/padding/font kichraytirildi (`body16`, ikonka `s15`) — `It might take a few moments to proceed!` endi to'liq bir qatorga sig'adi.
- [x] Info banner matn rangi: `body14` + `textPrimary` (to'q).
- [x] Amber ikonka: bitta halqa (`CircleAvatar` + matn `i`), ikkinchi "ring" olib tashlandi.
- [x] `×` yopish ikonkasi: `size: Spacing.s15`, `textSecondary` rang — ingichkalashtirildi.
- [x] Sarlavha matni 2 qator markazlashgan — golden tasdiqlandi.
- [~] Dialog paddingi: `Spacing.s25` bilan kengaytirildi (avvalgidan zichroq emas), lekin Figma aniq px qiymatlari bilan bir xil emas.

### Mos kelgani
- Bloklar tartibi: `×` → amber `i` ikonka → sarlavha 2 qator → info banner → [Cancel][Update Now].
- Matn qiymatlari bir xil: `It looks like your location might be inaccurate. Want to update it?`, `It might take a few moments to proceed!`, `Cancel`.
- `Update Now` tugmasi to'q (`#1C1E24`) fon + oq matn, r≈8.
- Dialog kartasi oq fon, katta radius (r≈16), soyasiz.
