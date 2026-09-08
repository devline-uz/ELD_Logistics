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
- [ ] **Maydonlar to'ldirilmagan**: Figma — username `abc976`, password `********` (8 ta yulduzcha, to'q matn); ilovada — ikkala maydon hamon placeholder (`Enter email address`, `Enter password`) ko'rsatadi, faqat tugma faollashgan. Golden holati «filled» ni ifodalamayapti.
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
- [ ] Halqa treki (bo'sh qismi): Figma — kulrang `#DCDCDC`, qalinligi progress bilan bir xil ~14 px; ilovada — juda och kulrang (`#F1F2F4`), progress ~10 px, ingichkaroq.
- [ ] Halqa diametri va joylashuvi: Figma ⌀≈205 px, markazi ekran kengligining markazida, tepadan ~215 px; ilovada ⌀≈250 px, tepadan ~120 px — halqa kattaroq va yuqoriroq.
- [ ] Halqa ichidagi vaqt tipografiyasi: Figma `09:00:20` — 26/28 px bold, `DRIVE` — 24 px yashil; ilovada `02:05:00` — 24 px medium, `DRIVE` — 18 px. Ikkala qator orasidagi oraliq Figma da ~4, ilovada ~8.
- [ ] Info karta foni: Figma — och yashil tint (`#E8F3E6`), ustida halqaga qaragan **uchburchak «pointer»** (halqaga ulanib turadi); ilovada — neytral kulrang (`#F1F2F4`), pointer yo'q, halqadan ~25 px uzilgan.
- [ ] Info karta qiymatlari: Figma — `02:32:02` va `342, Plot B` **bold** va to'q; ilovada — regular weight, kulrangroq. Kalit matnlar Figma da to'q kulrang (`#4A4F57`), ilovada och kulrang.
- [ ] Info karta qator balandligi: Figma qatorlar orasi ~52 px (h≈120 karta); ilovada ~30 px (h≈90).
- [ ] Sana/vaqt formati: Figma `11 MAY, 2025 11:05 PM` (bosh harflar, katta oy); ilovada `Sep 7, 2026 · 02:30 …` — format boshqa VA matn joy yetmay `…` bilan kesilgan (overflow).
- [ ] Status qatori matn o'lchami: Figma `In-motion` 15 px bold + o'ng tomonda sana 15 px bold; ilovada 14 px regular.
- [ ] AppBar: Figma `Duty Hours` sarlavhasi ostida ko'rinadigan chegara yo'q, fon `#F5F6F8`; ilovada sarlavha ostida 1px ajratgich chiziq bor.

### Mos kelgani
- Bloklar tartibi: AppBar `Duty Hours` → status qatori (yashil nuqta + `In-motion` + sana) → progress halqa (vaqt + `DRIVE`) → info karta (`Driving Time Left`, `Current Location`).
- `Driving Time Left = 02:32:xx` va `Current Location = 342, Plot B` qiymatlari.
- Halqa progress yo'nalishi (yuqoridan soat yo'nalishi bo'ylab) va bo'sh sektor pozitsiyasi.

---

## M-16 Idle prompt — golden `m16_idle_prompt_light_phone.png` ↔ figma `2181-17282__IN-DRIVE_FOCUSED__light.jpg`
Parite: 20%

### Tafovutlar
- [ ] **Asosiy: dialog umuman yo'q.** Figma — «You've been idle for 5 minutes. Are you still driving?» modal oynasi ekran markazida; ilovada golden — M-15 drive mode ekranining o'zi, hech qanday modal chiqmagan. Golden test dialogni ochmagan yoki dialog render bo'lmagan.
- [ ] Scrim yo'q: Figma — orqa fon ~50% qora scrim bilan qoraytirilgan; ilovada — scrim yo'q, ekran to'liq yorqin.
- [ ] Dialog kartasi: Figma — oq fon, r≈16, kenglik ekranning ~86% (≈400/461), padding 24, markazda vertikal ~40% balandlikda; ilovada — mavjud emas.
- [ ] Dialog ikonkasi: Figma — sariq/amber to'ldirilgan doira ⌀≈40 ichida oq `i`; ilovada — mavjud emas.
- [ ] Dialog matni: Figma 2 qator markazlashgan bold ~17 px `You've been idle for 5 minutes. Are you still driving?`; ilovada — mavjud emas.
- [ ] Dialog tugmalari: Figma — chapda `No` (oq fon + och chegara, kulrang matn), o'ngda `Yes, Driving` (`#1C1E24` fon, oq matn), ikkalasi h≈44, r≈8, o'ng tugma kengroq (~170 vs ~168); ilovada — mavjud emas.
- [ ] Yopish tugmasi: Figma — o'ng yuqori burchakda ingichka kulrang `×`; ilovada — mavjud emas.
- [ ] Fon ekran qiymati: Figma da `Current Location = 342, Plot B`; ilovada `N/A`.

### Mos kelgani
- Orqa fondagi ekran tarkibi (AppBar, status qatori, halqa, info karta) M-15 bilan bir xil — Figma da ham modal ostida shu ekran turadi.

---

## M-14 Location inaccurate — golden `m14_location_inaccurate_light_phone.png` ↔ figma `1102-2021__location_error__light.jpg`
Parite: 62%

### Tafovutlar
- [ ] **`Update Now` tugmasi matni kesilgan**: ilovada `Update N…` (overflow ellipsis); Figma da to'liq `Update Now`. Tugma kengligi yetarli emas.
- [ ] Orqa fon (scrim + host ekran) yo'q: Figma — M-05 Home ekrani ustida ~45% qora scrim; ilovada — dialog bo'sh och kulrang fonda yolg'iz (host ekran render qilinmagan).
- [ ] Dialog kengligi: Figma ekranning ~86% (≈400/461, chetlardan 30); ilovada ~78% (≈310/393, chetlardan 41).
- [ ] Dialog vertikal joylashuvi: Figma — ekranning yuqori-o'rta qismida (top ≈350/980); ilovada — aniq markazda (top ≈268/852 nisbatan pastroq markaz).
- [ ] Tugmalar o'lchami: Figma — `Cancel` w≈168, `Update Now` w≈170, h≈44, r≈8, o'ngga tekislangan juftlik; ilovada — w≈100/128, h≈40, o'ngga tekislangan lekin ancha tor.
- [ ] `Cancel` tugmasi uslubi: Figma — **oq fon + 1px och kulrang chegara**, matn kulrang; ilovada — to'ldirilgan och kulrang fon (`#F1F2F4`), chegarasiz.
- [ ] Ichki info banner: Figma — bir qator `It might take a few moments to proceed!`, h≈44, padding h=16; ilovada — ikki qatorga o'ralgan, karta tor bo'lgani uchun.
- [ ] Info banner matn rangi: Figma to'q kulrang (`#3F444C`), 13 px; ilovada och kulrang (`#9AA0A6` atrofida), 13 px — kontrast pasaygan.
- [ ] Amber ikonka: Figma — to'liq to'ldirilgan amber doira ⌀≈40, ichida oq `i`; ilovada — amber doira ichida yana bir to'q amber halqa + `i` (ikki qavat, «ring» effekti), ⌀≈36.
- [ ] `×` yopish ikonkasi: Figma — ingichka (1.5px) kulrang, o'lcham ~16; ilovada — qalin (2.5px) qora, o'lcham ~18.
- [ ] Sarlavha matni qatorga bo'linishi: Figma `It looks like your location might be / inaccurate. Want to update it?` (2 qator, kengroq); ilovada ham 2 qator, lekin uzilish nuqtasi bir xil emas — font 16 vs Figma 17.
- [ ] Dialog paddingi: Figma — top 28, side 24, bottom 24, ikonka-matn oralig'i 20, matn-banner 20, banner-tugmalar 28; ilovada — side 20, ikonka-matn 14, banner-tugmalar 16 (hammasi zichroq).

### Mos kelgani
- Bloklar tartibi: `×` → amber `i` ikonka → sarlavha 2 qator → info banner → [Cancel][Update Now].
- Matn qiymatlari bir xil: `It looks like your location might be inaccurate. Want to update it?`, `It might take a few moments to proceed!`, `Cancel`.
- `Update Now` tugmasi to'q (`#1C1E24`) fon + oq matn, r≈8.
- Dialog kartasi oq fon, katta radius (r≈16), soyasiz.
