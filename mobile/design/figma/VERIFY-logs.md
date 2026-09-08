# VERIFY — Logs / Certify / DVIR (light, phone)

Golden PNG ↔ Figma png_ref solishtiruvi. Juftliklar: `design/figma/VERIFY-PAIRS.md`.

---

## M-22 Log Report — Main — golden `m22_log_report_main_light_phone.png` ↔ figma `1085-14341__Log_Report_-_Main__light.jpg`
Parite: 82%

### Tafovutlar
- [ ] Sana chipi tanlangan holati: Figma `#EF4444`-ga yaqin och qizil fon; ilovada to'q qizil (`#C4002B` / brand crimson). Tanlangan chip foni tokenlari mos emas.
- [ ] Sana chipi ichki tuzilishi: Figma da chip balandligi ~100px, hafta kuni va raqam orasida katta bo'shliq (~16px), raqam markazda; ilovada chip pastroq (~78px), matnlar zich joylashgan.
- [ ] Sana chipi ostidagi sariq nuqta (status indikatori) Figma etalonida umuman yo'q; ilovada Wed/Fri/Sun ostida `#F59E0B` nuqta chiziladi.
- [ ] Karta ichidagi qator layout: Figma da label va qiymat bir qatorda, label ~50% kenglikda (`Shipping documents` bitta qatorda); ilovada label ustuni tor va `Shipping documents` ikki qatorga sinadi.
- [ ] `Shipping documents` qiymati — Figma: `N/A`; ilovada: `XYZ-1` (fixture ma'lumoti farqli, etalon bo'sh holatni ko'rsatadi).
- [ ] `Driver Name` qiymati — Figma: `Lorem ipsum`; ilovada: `John Doe`. `Unit #` — Figma `1234`, ilovada `1021`.
- [ ] Uchinchi qator yorlig'i — Figma: `Main Terminal`; ilovada: `Home Terminal`.
- [ ] Bottom nav: Figma da 4 ta tab — Home / attachment (skrepka) / Log Report (aktiv) / Profile; ilovada — Home / Logs (aktiv) / Chat (chat bubble) / Profile. Ikkinchi tab ikonkasi va aktiv tab yorlig'i (`Log Report` ↔ `Logs`) mos emas.
- [ ] Segment (Main/Logs/DVIR) konteyner: Figma da tashqi kulrang kapsula ichida to'liq inset, gorizontal padding ~16px; ilovada segment konteyneri ekran chetiga yaqinroq va balandligi pastroq.
- [ ] Status bar (soat/signal/batareya) Figma etalonida bor; golden da yo'q (bu golden render cheklovi, kod tafovuti emas — e'tibor uchun).

### Mos kelgani
- Sarlavha `Log Report` + o'ng tarafdagi 3 ta ikonka (qo'ng'iroq, konvert, refresh) va ularning tartibi.
- Main/Logs/DVIR segmenti, aktiv `Main` — qora fon + oq matn, radius kapsula.
- Ikkita karta: och kulrang fon + katta radius; `Driver Information` sarlavhasi kartalar orasida.
- `Certify: Not Signed` qizil rangda; `Trailer numbers: bobtail`; `Notes: Lorem ipsum`.
- Sana strip gorizontal skroll bo'lib chapdan kesilgan holati.

---

## M-23 Log Report — Logs — golden `m23_log_report_logs_light_phone.png` ↔ figma `1085-13169__Log_Report_-_Logs__light.jpg`
Parite: 70%

### Tafovutlar
- [ ] Duty grid o'lchami: Figma da grid balandligi kichik (~100px), 4 qator (OFF/SB/DR/ON) juda zich; ilovada grid ancha baland (~120px) va qatorlar orasi keng.
- [ ] Grid qator yorliqlari: Figma da `OFF/SB/DR/ON` juda kichik (~6-7px, kulrang, grid ichida chapda); ilovada 12-13px o'lchamda va gridan tashqarida.
- [ ] Grid segment chiziqlari: Figma da har duty status o'z rangida (OFF kulrang, SB sariq, DR yashil, ON qizil/pushti) + status o'zgarish nuqtalari (yashil doiralar); ilovada barcha chiziq bitta ko'k-yashil (teal) rangda, nuqtalar yo'q.
- [ ] Grid tepasidagi soat shkalasi: Figma da `M 1..11 N 1..11 M` juda mayda va tik chiziqlar bilan; ilovada shriftlar kattaroq va tik chiziqlar yo'q.
- [ ] Jami vaqtlar qatori (`OFF 03:06 / SB 00:00 / DR 00:00 / ON 00:00`): Figma da `OFF` qiymati ham rangli (qizil-pushti), 4 tasi ham teng oraliqda markazlashgan; ilovada `OFF 03:06` kulrang va qator chap tomonga siljigan. `ON` qiymati — Figma `00:00`, ilovada `02:00`.
- [ ] Warning banner: Figma — och sariq fon (`#FEF3C7` ga yaqin), to'q sariq matn, ikonkasiz, matn `Warning: Trailer is not set`; ilovada — to'q sariq to'ldirilgan fon (`#F59E0B`), oq matn + uchburchak ikonka, matn `Warning: Missing trailer number`.
- [ ] Violation banner (`Violation: Driving limit exceeded`, qizil to'ldirilgan) Figma etalonida umuman yo'q — ilovada qo'shimcha blok.
- [ ] Jadval sarlavha qatori: Figma da fon `#F5F5F5` va pastda 1px ajratuvchi, ustunlar `Status / Start Time / Location / Document`; ilovada sarlavha foni oq/kartaning o'zi, `Document` ustuni `Do…` bo'lib kesilgan.
- [ ] Jadval qatorlari: Figma da har qator oq fonda, orasida 1px och kulrang chiziq; ilovada qatorlar orasida ajratuvchi chiziq yo'q.
- [ ] Vaqt formati — Figma: `02:24:54 PM` (barcha qatorlarda bir xil); ilovada: `12:00:00 AM`, `06:00:00 AM`, `09:00:00 AM`. Status ketma-ketligi ham farqli (Figma: ON/DR/ON/SB; ilova: OFF/DR/ON).
- [ ] Qator soni — Figma: 4 ta; ilovada: 3 ta.
- [ ] `OFF` badge rangi — Figma da OFF status jadvalda ko'rinmaydi, ammo SB sariq (`#F59E0B`); ilovada `OFF` to'q kulrang badge — badge rang xaritasi tekshirilishi kerak.
- [ ] Gorizontal skroll indikatori: Figma da to'liq kenglikdagi och kulrang trek + ~20% to'q sariq thumb, jadval kartasi ichida pastda; ilovada thumb ~75% kenglikda va rangi och sariq.
- [ ] Bottom nav farqi M-22 dagi kabi (skrepka tab ↔ chat tab, `Log Report` ↔ `Logs`).

### Mos kelgani
- Ekran bloklar tartibi: segment → sana strip → grid kartasi → banner → jadval kartasi.
- Aktiv `Logs` segmenti qora fon + oq matn.
- Grid kartasi och kulrang fon + katta radius.
- DR yashil, ON teal/ko'k, SB sariq badge rang oilasi.
- Jadval ustunlari tartibi va gorizontal skroll xatti-harakati.

---

## M-24 Log Report — DVIR (bo'sh) — golden `m24_log_report_dvir_empty_light_phone.png` ↔ figma `1087-14921__Log_Report_-_DVIR__light.jpg`
Parite: 62%

### Tafovutlar
- [ ] Sana strip (8 kunlik chip qatori) Figma DVIR etalonida umuman yo'q — segmentdan keyin darhol bo'sh holat keladi; ilovada DVIR tabida ham sana strip ko'rsatiladi.
- [ ] Bo'sh holat illyustratsiyasi: Figma — katta chizma (uchta stacked karta + lupa, ~150x140px, och kulrang chiziqli art, orqa fonda och doira); ilovada — oddiy `inbox` konturli ikonka (~48px, `#94A3B8`).
- [ ] FAB (qo'shish tugmasi) Figma da pastki o'ng burchakda `56px` qizil doira + oq `+`; ilovada FAB umuman yo'q.
- [ ] Bo'sh holat vertikal joylashuvi: Figma da illyustratsiya markazi ekranning ~45% balandligida; ilovada ~56% da (pastroq).
- [ ] Segment (`DVIR` aktiv) o'ng chetdan padding: Figma da segment `#F5F5F5` konteyner ichida va aktiv `DVIR` element konteyner ichida to'liq sig'adi; ilovada aktiv `DVIR` qora blok konteyner chetidan chiqib turgandek ko'rinadi (o'ng chekka radius mos emas).
- [ ] Bottom nav farqi M-22 dagi kabi.

### Mos kelgani
- Sarlavha `Log Report` va o'ng ikonka to'plami.
- `No DVIR Found` (bold, ~16px) + `There is no data to show you right now` (kulrang, ~14px) matnlari aynan mos.
- Aktiv `DVIR` segmenti qora fon + oq matn.
- Umumiy oq/och fon.

---

## M-29 Certify — ro'yxat — golden `m29_certify_list_light_phone.png` ↔ figma `1102-397__Signature_-_edit__light.jpg`
Parite: 78%

### Tafovutlar
- [ ] Belgilangan (certified) qator checkbox'i: Figma — to'ldirilgan kulrang-ko'k kvadrat (`#64748B` ga yaqin) + oq belgi; ilovada — bo'sh, o'chirilgan (disabled) och kulrang kontur, belgi yo'q.
- [ ] Status badge to'plami: Figma da faqat `Uncertified` (qizil) va `Certified` (yashil); ilovada qo'shimcha `Needs re-certify` (sariq) va matn ko'rinishidagi `Not Ready` (badge fonsiz, kulrang matn) mavjud. `Not Ready` Figma da badge sifatida ham yo'q.
- [ ] Qator soni: Figma — 7 ta kun (`Tue, May 20` … `Wed, May 14`); ilovada — 4 ta (`Mon, Sep 7` … `Fri, Sep 4`). Karta balandligi shunga mos ravishda ancha qisqa.
- [ ] Qatorlar orasidagi vertikal interval: Figma ~64px; ilovada ~68px va karta ichki paddingi kattaroq.
- [ ] `Certify All` tugmasi: Figma da ekran pastida, pastki chekkadan ~28px yuqorida va nav bar yo'q; ilovada tugma pastki chekkaga yaqinroq (~32px) — safe area hisobga olinishi tekshirilsin.
- [ ] Sana matni rangi: Figma da barcha kunlar bir xil to'q rangda; ilovada `Sat, Sep 5` va `Fri, Sep 4` och kulrang (disabled) rangda.

### Mos kelgani
- AppBar: chap `<` tugma + `Certify` bold + `(Last 8 days)` kichik kulrang qo'shimcha.
- `Certify Today` kartasi: och kulrang fon, katta radius, o'ngda `>` chevron.
- Ro'yxat kartasi: och kulrang fon (`#F5F5F5` oilasi) + katta radius, qatorlar ajratuvchisiz.
- Checkbox chapda, sana matni o'rtada, badge o'ngda tekislangan.
- `Uncertified` qizil badge va `Certified` yashil badge ranglari va radius.
- `Certify All` — to'liq kenglik, to'q (deyarli qora) fon, oq matn, o'rta radius.

---

## M-30 Certify — imzo — golden `m30_certify_sign_light_phone.png` ↔ figma `1102-817__Certify_All_button__light.jpg`
Parite: 55%

### Tafovutlar
- [ ] Bloklar tartibi butunlay boshqacha. Figma: `Driver Signature` sarlavhasi va `Use my signature` tugmasi **bir qatorda** (sarlavha chapda, tugma o'ngda); ilovada tugma sarlavhadan **keyingi qatorda**, chapga tekislangan.
- [ ] Sertifikatsiya matni: Figma da imzo maydonidan **keyin**, checkbox bilan birga (`I hereby certify…` belgilangan checkbox yonida, justify tekislangan); ilovada matn ekran **tepasida**, `Driver Signature` sarlavhasidan oldin, checkbox'siz oddiy paragraf sifatida.
- [ ] `Mon, Sep 7` sana sarlavhasi Figma etalonida umuman yo'q; ilovada AppBar ostida birinchi element sifatida bor.
- [ ] Imzo maydoni: Figma — to'ldirilgan och kulrang fon (`#F5F5F5`), chegarasiz, o'ng yuqori burchakda `undo` (qaytarish) ikonkasi, placeholder matni yo'q; ilovada — oq fon + 1px och kulrang chegara, markazda `Sign inside the box` placeholder, undo ikonkasi yo'q.
- [ ] `Clear` / `Save` tugmalari juftligi Figma etalonida umuman yo'q — Figma da faqat undo ikonkasi bilan boshqariladi; ilovada imzo maydoni ostida ikkita disabled tugma.
- [ ] `Save my signature` checkbox holati: Figma — belgilangan (to'q to'ldirilgan + oq belgi); ilovada — belgilanmagan, och kulrang kontur.
- [ ] `Use my signature` tugma uslubi: Figma — to'q kulrang-binafsha to'ldirilgan fon (`#A5A9BC` ga yaqin) + oq matn, kichik radius; ilovada — juda och kulrang fon + kulrang matn, to'liq kapsula radius.
- [ ] `Confirm` tugmasi: Figma — faol, to'q (qora) fon + oq matn; ilovada — disabled, och kulrang fon + kulrang matn. `Cancel` — Figma da nozik chegarali oq fon; ilovada chegarasiz och kulrang fon.
- [ ] Pastki tugmalar kengligi: Figma da `Cancel` va `Confirm` teng emas — `Confirm` biroz kengroq (~45%/50%); ilovada ikkalasi teng kenglikda.
- [ ] AppBar: Figma da faqat `<` + `Sign`, o'ng tarafda ikonka yo'q; ilovada o'ngda 3 ta ikonka (qo'ng'iroq, konvert, refresh) qo'shilgan.

### Mos kelgani
- `Sign` sarlavhasi va chapdagi `<` tugma.
- `Driver Signature` bold sarlavha.
- Katta to'rtburchak imzo maydoni (radius ~12px) va uning taxminiy balandligi (~230px).
- `Save my signature` checkbox + yorlig'i mavjudligi.
- Pastda `Cancel` / `Confirm` juftligi, `Confirm` o'ngda.
- Sertifikatsiya matnining so'zma-so'z mazmuni (`I hereby certify that my data entries and my record of duty status for 24 hour period are true and correct`).

---

## M-16 Log Report — DVIR (to'ldirilgan) — golden `t16_log_report_dvir_light_phone.png` ↔ figma `2181-17282__IN-DRIVE_FOCUSED__light.jpg`
Parite: n/a — juftlik noto'g'ri

### Tafovutlar
- [ ] **VERIFY-PAIRS.md dagi juftlik xato.** `t16_log_report_dvir_light_phone.png` uchun ko'rsatilgan etalon `2181-17282__IN-DRIVE_FOCUSED__light.jpg` — bu butunlay boshqa ekran: `Duty Hours` (In-motion, gauge) ustida `You've been idle for 5 minutes. Are you still driving?` modal dialogi (`No` / `Yes, Driving` tugmalari). DVIR ro'yxatiga hech qanday aloqasi yo'q. Juftlikni to'g'rilash kerak.
- [ ] DVIR to'ldirilgan holat uchun Figma da alohida etalon topilmadi — mavjud yagona DVIR etaloni `1087-14921` (bo'sh holat). Dizayn manbasida DVIR ro'yxat elementi (list item) spetsifikatsiyasi yo'q.

Quyidagilar `1087-14921` (DVIR bo'sh) etalonining umumiy DVIR-tab xromi bilan solishtirishdan (parite ~65%):
- [ ] Sana strip Figma DVIR ekranida yo'q; ilovada bor (M-24 bilan bir xil tafovut).
- [ ] FAB (qizil `+` doira, pastki o'ng) Figma da bor; ilovada yo'q.
- [ ] Bottom nav farqi (skrepka tab ↔ chat tab, `Log Report` ↔ `Logs`) — M-22 bilan bir xil.
- [ ] Ro'yxat elementi uslubi tasdiqlanmagan: ilovada karta/fon yo'q, faqat 1px ajratuvchi chiziqli qatorlar (`TR-9` bold + `Type: pre_trip` kulrang, o'ngda sana-vaqt). Figma da DVIR ro'yxat kartasi `#F5F5F5` fonli bo'lishi kutiladi (M-22/M-23 kartalari bilan izchillik uchun) — dizayn tasdig'i kerak.
- [ ] `Type: pre_trip` / `post_trip` — raw enum qiymati ko'rsatilmoqda (i18n orqali lokalizatsiya qilinishi kerak).

### Mos kelgani
- AppBar `Log Report` + o'ng ikonka to'plami, aktiv `DVIR` segmenti — DVIR-tab xromi M-24 bilan izchil.
