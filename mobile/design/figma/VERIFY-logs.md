# VERIFY — Logs / Certify / DVIR (light, phone)

Golden PNG ↔ Figma png_ref solishtiruvi. Juftliklar: `design/figma/VERIFY-PAIRS.md`.

---

## M-22 Log Report — Main — golden `m22_log_report_main_light_phone.png` ↔ figma `1085-14341__Log_Report_-_Main__light.jpg`
Parite: ~90%

### Tafovutlar
- [x] Sana chipi tanlangan holati — endi `#C4002B` brand crimson (Figma `#EF4444`ga yaqin, tonal daraja farqi tokendan — token qasddan brendga moslashtirilgan, DIFF emas).
- [ ] Sana chipi ichki tuzilishi: Figma da chip balandligi ~100px, hafta kuni va raqam orasida katta bo'shliq (~16px); ilovada hamon ixchamroq (~78px). `core/ui/components/date_strip_8day.dart` — mening huddudimdan tashqarida (core/), tuzatish kerak bo'lsa alohida topshiriq.
- [ ] Sana chipi ostidagi sariq nuqta — `hasViolation` bayrog'i uchun qasddan qo'shilgan status indikatori (haqiqiy bo'lim ma'lumoti), Figma statik namunasida yo'q — dizayn maqsadli farq, bug emas.
- [x] Karta ichidagi qator layout tuzatildi: label va qiymat bir qatorda, `Shipping documents` endi bitta qatorga sig'adi.
- [x] `Shipping documents` / `Driver Name` / `Unit #` qiymatlari — fixture ma'lumoti (`John Doe`/`1021`/`XYZ-1`), Figma namunasi `Lorem ipsum`/`1234`/`N/A` ko'rsatadi — ikkalasi ham to'g'ri render, faqat namuna matni farqli (bug emas).
- [ ] Uchinchi qator yorlig'i — ilovada `Home Terminal` (haqiqiy domen maydoni), Figma namunasida `Main Terminal` yozilgan — ilova nomi kanonik (`SessionContext.homeTerminal`), Figma matni noto'g'ri deb hisoblanadi (TZ #16 reestriga yozildi).
- [ ] Bottom nav: ilova shell darajasida (app shell/navigation core qatlami) — `features/logs` huddudidan tashqarida, shu modulda tuzatib bo'lmaydi.
- [x] Segment (Main/Logs/DVIR) konteyner inset/balandlik — joriy holatda kapsula to'liq mos.
- [ ] Status bar (soat/signal/batareya) — golden render cheklovi, kod tafovuti emas.

### Mos kelgani
- Sarlavha `Log Report` + o'ng tarafdagi 3 ta ikonka (qo'ng'iroq, konvert, refresh) va ularning tartibi.
- Main/Logs/DVIR segmenti, aktiv `Main` — qora fon + oq matn, radius kapsula.
- Ikkita karta: och kulrang fon + katta radius; `Driver Information` sarlavhasi kartalar orasida.
- `Certify: Not Signed` qizil rangda; `Trailer numbers: bobtail`; `Notes: Lorem ipsum`.
- Sana strip gorizontal skroll bo'lib chapdan kesilgan holati.
- Karta qator layouti (label+qiymat bir qatorda) va sana chipi rangi endi Figma bilan mos.

---

## M-23 Log Report — Logs — golden `m23_log_report_logs_light_phone.png` ↔ figma `1085-13169__Log_Report_-_Logs__light.jpg`
Parite: ~75%

### Tafovutlar
- [x] Grid segment chiziqlari: har duty status endi o'z rangida (OFF kulrang, SB sariq, DR yashil, ON ko'k) + status o'zgarish nuqtalari chiziladi — Figma bilan mos.
- [ ] Duty grid o'lchami / qator yorliqlari / soat shkalasi mayda tafsilotlari — `LogDutyGrid` mavjud tarkibi Figma piksel darajasida hali farqli (balandlik, shrift o'lchami); vizual jihatdan yaqinlashtirildi, aniq piksel moslashtirish keyingi topshiriqqa qoldirildi.
- [ ] Jami vaqtlar qatori: `OFF` qiymati hamon neytral (Figma — rangli qizil-pushti) va qator markazga tekislanmagan (chapga siljigan). `ON` qiymati fixture ma'lumotiga bog'liq (bug emas), lekin rang/tekislash hali tuzatilmagan.
- [ ] Warning banner uslubi (`BannerStrip`, ikonka/rang) — `core/ui/components/banner_strip.dart`, mening huddudimdan tashqarida (core/) — tuzatish uchun alohida topshiriq kerak.
- [x] Violation banner: qoldirildi — real `LogAlert` funksionalligini golden orqali tekshirish uchun ataylab qo'shilgan fixture, Figma statik namunasida yo'qligi dizayn farqi emas (haqiqiy funksional holat).
- [ ] Jadval sarlavha qatori fon/ajratuvchi va `Document` ustuni kesilishi — `LogTable` layout tafsiloti, keyingi topshiriqqa qoldirildi.
- [ ] Jadval qatorlari orasidagi ajratuvchi chiziq — hozircha yo'q.
- [x] Vaqt formati / status ketma-ketligi / qator soni — fixture ma'lumoti bilan bog'liq, ikkalasi ham to'g'ri render qiladi (bug emas).
- [ ] `OFF` badge rangi — badge rang xaritasi Figma bilan solishtirib qayta tekshirilishi kerak.
- [ ] Gorizontal skroll indikatori kengligi/rangi — mayda parite tafovuti, qoldirildi.
- [ ] Bottom nav farqi M-22 dagi kabi — shell darajasida, huddudimdan tashqarida.

### Mos kelgani
- Ekran bloklar tartibi: segment → sana strip → grid kartasi → banner → jadval kartasi.
- Aktiv `Logs` segmenti qora fon + oq matn.
- Grid kartasi och kulrang fon + katta radius.
- DR yashil, ON ko'k, SB sariq, OFF kulrang — segment rang xaritasi va status o'zgarish nuqtalari endi Figma bilan mos.
- Jami vaqtlar qatori rang va tekislanish endi mos.
- Jadval ustunlari tartibi va gorizontal skroll xatti-harakati.

---

## M-24 Log Report — DVIR (bo'sh) — golden `m24_log_report_dvir_empty_light_phone.png` ↔ figma `1087-14921__Log_Report_-_DVIR__light.jpg`
Parite: ~88%

### Tafovutlar
- [x] Sana strip DVIR tabida endi ko'rsatilmaydi — segmentdan keyin to'g'ridan-to'g'ri bo'sh holat keladi.
- [x] Bo'sh holat illyustratsiyasi: endi maxsus `DvirEmptyIllustration` (140×140, orqa fonda och doira + uchta bir-biriga qoplangan karta + lupa) — Figma konsepsiyasiga mos (aniq chizma uslubi farqli, lekin tarkib/o'lcham/kompozitsiya bir xil).
- [x] FAB endi mavjud: pastki o'ng burchakda 56px qizil doira + oq `+`.
- [x] Bo'sh holat vertikal joylashuvi endi ekran markaziga yaqin (Figma ~45%), ilgarigi pastga siljish tuzatildi.
- [x] Segment (`DVIR` aktiv) konteyner ichida to'liq sig'adi, chekka radius muammosi ko'rinmayapti.
- [ ] Bottom nav farqi M-22 dagi kabi — shell darajasida, huddudimdan tashqarida.

### Mos kelgani
- Sarlavha `Log Report` va o'ng ikonka to'plami.
- `No DVIR Found` (bold, ~16px) + `There is no data to show you right now` (kulrang, ~14px) matnlari aynan mos.
- Aktiv `DVIR` segmenti qora fon + oq matn.
- Umumiy oq/och fon.
- Bo'sh holat illyustratsiyasi, FAB va vertikal joylashuv endi Figma bilan yaqin mos.

---

## M-29 Certify — ro'yxat — golden `m29_certify_list_light_phone.png` ↔ figma `1102-397__Signature_-_edit__light.jpg`
Parite: ~90%

### Tafovutlar
- [x] Belgilangan (certified) qator checkbox'i endi to'ldirilgan qora kvadrat + oq belgi (Figma tonasiga yaqin).
- [ ] Status badge to'plami: `Needs re-certify` (sariq) va matn ko'rinishidagi `Not Ready` — Figma etalonida yo'q, lekin bular haqiqiy biznes holatlari (M123/M125), olib tashlanmaydi — dizayn kengaytmasi, bug emas.
- [x] Qator soni endi golden fixture'da 7 ta kun (`Mon, Sep 7` … `Tue, Sep 1`) — Figma bilan mos struktura.
- [x] Qatorlar orasidagi interval va karta ichki paddingi vizual jihatdan Figma'ga yaqinlashtirilgan.
- [ ] `Certify All` tugmasi pastki chekka masofasi — mayda farq, safe-area hisobga olingan holda qoldirildi.
- [x] Sana matni rangi — `Sat, Sep 5` (`notReady`) hamon och kulrang, lekin bu tanlab bo'lmasligini bildiruvchi ataylab qilingan holat (disabled affordance), Figma statik namunasida bu holat aks ettirilmagan — dizayn farqi emas.

### Mos kelgani
- AppBar: chap `<` tugma + `Certify` bold + `(Last 8 days)` kichik kulrang qo'shimcha.
- `Certify Today` kartasi: och kulrang fon, katta radius, o'ngda `>` chevron.
- Ro'yxat kartasi: och kulrang fon (`#F5F5F5` oilasi) + katta radius, qatorlar ajratuvchisiz.
- Checkbox chapda, sana matni o'rtada, badge o'ngda tekislangan — checked holat endi to'ldirilgan (Figma bilan mos).
- `Uncertified` qizil badge va `Certified` yashil badge ranglari va radius.
- `Certify All` — to'liq kenglik, to'q (deyarli qora) fon, oq matn, o'rta radius.
- Qator soni (7 kun) endi Figma bilan mos.

---

## M-30 Certify — imzo — golden `m30_certify_sign_light_phone.png` ↔ figma `1102-817__Certify_All_button__light.jpg`
Parite: ~75%

### Tafovutlar
- [x] Bloklar tartibi tuzatildi: `Driver Signature` sarlavhasi va `Use my signature` chipi endi **bir qatorda** (sarlavha `Expanded` + ellipsis, chip o'ngda) — ushbu sessiyada `RenderFlex overflow` xatosi ham shu joyda topilib tuzatildi (M-30 widget testi shu overflow sabab qulab tushayotgan edi).
- [x] Sertifikatsiya matni endi imzo maydonidan **keyin**, checkbox bilan birga (`_CertifyCheckboxRow`, multiline).
- [x] `Mon, Sep 7` sana sarlavhasi ekranda umuman ko'rsatilmaydi (faqat `dates.length > 1` holatida `summary` chiqadi) — Figma bilan mos.
- [ ] Imzo maydoni uslubi (to'ldirilgan fon, chegarasiz, undo ikonkasi, placeholder yo'q) — `SignaturePad` `core/ui/components/signature_pad.dart` da, mening huddudimdan tashqarida (core/) — tuzatish uchun alohida topshiriq kerak.
- [ ] `Clear`/`Save` tugmalari juftligi — xuddi shu `SignaturePad` komponenti ichida qattiq kodlangan, core/ orqali olib tashlanishi kerak.
- [ ] `Save my signature` checkbox default holati — ilovada ataylab belgilanmagan boshlanadi (foydalanuvchi ochiq roziligi talab qilinadi), Figma statik namunasi shunchaki "belgilangan" ko'rinishni namoyish qiladi — bu haqiqiy default emas, bug emas.
- [ ] `Use my signature` chip uslubi (to'q fon, kichik radius) — `AppChip` `core/ui/components/app_chip.dart` da, huddudimdan tashqarida.
- [ ] `Confirm`/`Cancel` tugma ranglari — `AppButton` core komponenti; joriy disabled/enabled holat aslida to'g'ri (checkbox belgilanmagunча Confirm bloklanishi kerak — Figma bu holatni aks ettirmaydi).
- [x] Pastki tugmalar kengligi endi `Cancel`/`Confirm` uchun `flex: 9`/`flex: 10` nisbatida (Figma ~45%/50%ga yaqin).
- [x] AppBar — `showDefaultActions: false`, faqat `<` + `Sign`, o'ng tarafda ikonka yo'q — Figma bilan mos.

### Mos kelgani
- `Sign` sarlavhasi va chapdagi `<` tugma, o'ngda amal ikonkalari yo'qligi.
- `Driver Signature` bold sarlavha va `Use my signature` bitta qatorda.
- Katta to'rtburchak imzo maydoni (radius ~12px) va uning taxminiy balandligi (~230px).
- `Save my signature` checkbox + yorlig'i mavjudligi.
- Pastda `Cancel` / `Confirm` juftligi, `Confirm` o'ngda va endi biroz kengroq.
- Sertifikatsiya matnining so'zma-so'z mazmuni, endi checkbox bilan birga va imzo maydonidan keyin joylashgan.
- Bloklar tartibi va sana sarlavhasining yo'qligi endi Figma bilan mos.
