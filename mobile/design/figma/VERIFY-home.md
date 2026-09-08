# VERIFY — Home / Drawer / Documents / Change Status / Quick notes

Usul: golden PNG ↔ `design/figma/png_ref/*.jpg` yonma-yon o'qish.
Etalonlar: `1202-9259__Home_screen_ELD_DISCONNECTED__light.jpg` (menyu ochiq holat — home qisman ko'rinadi),
`2230-20627__Home_screen_ELD_DISCONNECTED__light.jpg` (Documents modal — home to'liq fon),
`2697-33817__Menu__dark.jpg` (menyu, light varianti mavjud emas),
`1083-10550__Change_Status__light.jpg`, `1170-2313__notes__light.jpg`.

---

## M-09 Home (qisqa) — golden `m09_home_light_phone.png` ↔ figma `1202-9259` + `2230-20627`
Parite: 55%

### Tafovutlar
- [ ] ELD banneri: Figma — to'liq kenglikdagi **to'q qizil to'ldirilgan** blok (`r12`), chapda oq doira ichida signal ikonkasi, oq matn `ELD not connected`; ilovada — och ko'k-kulrang fon (`#EEF2FA`), qizil-kulrang matn `ELD · Connected`, ikonka doira ichida emas.
- [ ] Duty status kartasi: Figma da karta pastida **quyuqroq teal footer polosa** bor va unda taymer `10:45²³` (soniya superscript); ilovada footer polosa yo'q, taymer `02h 05m 00s` ko'rinishida karta ichida oddiy matn.
- [ ] Duty status ikonkasi: Figma — pauza (`||`) belgisi oq doira ichida, holat `Off-duty`; ilovada — yuk mashinasi ikonkasi, `On Duty`. Ikonka holatga bog'liq bo'lishi kerak (pause = Off-duty).
- [ ] OFF/SB/ON pill qatori: Figma etalonining ochiq qismida duty kartadan keyin darhol **Trip Details** kartasi keladi — hech qanday pill qatori yo'q; ilovada 3 ta pill (`OFF`/`SB`/`ON`) + almashtirish ikonkasi qo'shilgan.
- [ ] HOS bloki: Figma — 4 ta **alohida** o'ralgan karta (oq fon + `#E5E5E5` chegara, `r12`) 2×2 setkada, har birida rangli sarlavha (`BREAK`/`DRIVE`/`SHIFT`/`CYCLE`), qiymat chipi va **ikonkali** slayder tugmasi; `1202-9259` da esa **doiraviy ring gauge** (`65:00` + `CYCLE` ring ichida). Ilovada — bitta kulrang karta, ichida `Hours of Service` sarlavhasi + almashtirish ikonkasi, 4 ta tekis slayder, tugmalari ikonkasiz oddiy doira. Figma da `Hours of Service` sarlavhasi ham, o'rab turuvchi karta ham yo'q.
- [ ] Slayder qiymati: Figma — chip ichida `10:45 23` (soat:daqiqa + kichik soniya); ilovada — `08:00` ko'rinishida, soniya yo'q.
- [ ] AppBar: Figma da gamburger ikonkasi ustida **qizil nuqta badge** bor (o'qilmagan/diqqat belgisi); ilovada yo'q.
- [ ] Pastki navigatsiya 2-tab: Figma — qalam/status ikonkasi (`Status`); ilovada — hujjat ikonkasi. 3-tab: Figma — hujjat (Logs); ilovada — chat pufagi. Ya'ni tab to'plami va tartibi mos emas.

### Mos kelgani
- AppBar tuzilishi: gamburger + `OneBook ELD` logotip (`One` qizil) + 3 ta o'ng ikonka (qo'ng'iroq, konvert, yangilash).
- Sana/haydovchi kartasi: doira ichida kun raqami · `Mon, ...` · doira ichida `1021` · `John Smith, BMW mi7 …` — tuzilma va tartib bir xil.
- Duty status kartasi teal fon, oq matn, markazda ikonka, `r12` radius.
- HOS ranglari: BREAK sariq/to'q sariq, DRIVE yashil, SHIFT ko'k, CYCLE qizil.
- Pastki navigatsiyada aktiv `Home` — qizil to'ldirilgan yumaloq kvadrat + tagida yozuv.

---

## M-09 Home (to'liq) — golden `m09_home_full_light_phone.png` ↔ figma `1202-9259` + `2230-20627`
Parite: 50%

### Tafovutlar
- [ ] Yuqoridagi M-09 (qisqa) tafovutlarining hammasi shu goldenga ham tegishli.
- [ ] Tez amallar qatori (`Inspection Report`, `Log Report`, `Co-driver`, `Leave Truck` gorizontal skroll kartalari): Figma home etalonlarida umuman yo'q — bu elementlar Figma da **menyuda** joylashgan. Ilovada ortiqcha blok (bundan tashqari oxirgi karta `Leave Truc…` deb kesilgan).
- [ ] Trip Details tahrirlash tugmasi: Figma — kartaning o'ng pastki burchagida **oq doira + soya** ko'rinishidagi FAB (qalam ikonkasi, karta chetiga chiqib turadi); ilovada — karta sarlavhasi qatorida tekis qalam ikonkasi.
- [ ] `Pending edits (2)` sariq banneri (`#FFF3D6` fon + sariq chegara + `>` chevron): Figma etalonlarining hech birida yo'q — ortiqcha blok.
- [ ] Logs kartasi: Figma da duty setkasi ostida rangli jami qiymatlar (OFF/SB/DR/ON bo'yicha) ko'rsatiladi; ilovada faqat bo'sh setka, rangli jamilar yo'q.
- [ ] Signature/Certify bloki: Figma etalonlarida ko'rinadigan qismda yo'q — joylashuvi va mavjudligi Figma node bo'yicha tasdiqlanishi kerak.

### Mos kelgani
- Umumiy vertikal tartib: appbar → banner → sana kartasi → duty status → HOS → trip/hujjatlar → loglar → pastki navigatsiya.
- Kartalar uslubi: kulrang `#F5F5F5` fon, `r12`, gorizontal padding taxminan bir xil.
- Trip Details maydonlari (Shipping Document / Trailer Number / Notes) ikonka + kulrang label + qora qiymat sxemasi.

---

## M-10 Drawer — golden `m10_drawer_light_phone.png` ↔ figma `1202-9259` (light) / `2697-33817` (dark)
Parite: 20%

### Tafovutlar
- [ ] Menyu sarlavhasi: Figma — yuqorida markazlashgan **ONEBOOK ELD logotipi** (qizil belgi + `BOOK ELD` wordmark), foydalanuvchi ma'lumoti yo'q; ilovada — avatar + `John Smith` + `1021` + email + telefon + `D1234567 · TX` bloki va ajratuvchi chiziq. Logotip umuman yo'q.
- [ ] Punktlar to'plami mos emas. Figma (7 ta, shu tartibda): `Inspection Report`, `Switch to Co-driver`, `Permissions`, `User Manual`, `Leave the Truck`, `Privacy Policy`, `Terms of Use`. Ilovada (10 ta): `Permissions`, `Check Network`, `Diagnosis of Device`, `App Updates`, `Zoom`, `Dark mode`, `Feedback`, `Customer Support`, `User Manual`, `Logout`.
- [ ] Figma da yo'q, ilovada bor: `Check Network`, `Diagnosis of Device`, `App Updates`, `Zoom` (toggle), `Dark mode` (toggle), `Feedback`, `Customer Support`.
- [ ] Figma da bor, ilovada yo'q: `Inspection Report`, `Switch to Co-driver`, `Leave the Truck`.
- [ ] `Permissions` punkti: Figma da matndan keyin **qizil doira ichida `!` badge** bor; ilovada badge yo'q.
- [ ] `Privacy Policy` va `Terms of Use`: Figma da oddiy menyu punktlari (ikonka + qora matn, ro'yxat ichida); ilovada — ekran pastida ikkita qizil havola qatori, ikonkasiz, `Terms of U…` kesilgan holda.
- [ ] `Logout`: Figma da ekranning eng pastida (ro'yxatdan uzoqda, katta bo'sh joydan keyin); ilovada ro'yxatning oxirgi punkti sifatida `User Manual` ostida darhol keladi.
- [ ] Qator balandligi/zichligi: Figma — punktlar orasi ~69 px, ikonka 24 px, matn ~17 px; ilovada ~56 px zichroq qadam.
- [ ] Panel kengligi: Figma — ekran kengligining ~66% (qolgan qismda scrim orqali home ko'rinadi); ilovada ~75%.

### Mos kelgani
- Chapdan chiqadigan panel + o'ng tomonda scrim.
- Punkt qatori sxemasi: chapda 24 px kontur (outline) ikonka, undan keyin matn.
- `Logout` qizil rangda, chapida chiqish ikonkasi.
- `Permissions` va `User Manual` punktlari va ularning ikonkalari mos.

---

## M-11 Edit Documents — golden `m11_edit_documents_light_phone.png` ↔ figma `2230-20627`
Parite: 60%

### Tafovutlar
- [ ] Konteyner turi: Figma — ekran markazida **modal dialog** (oq, `r16`, chap/o'ng chetdan ~30 px, orqa fon scrim bilan xiralashgan); ilovada — pastdan chiqadigan **bottom sheet**, to'liq kenglikda, yuqorida drag-handle chizig'i.
- [ ] Sarlavha: Figma — `Documents` **chapga tekislangan**, o'ng burchakda `×` yopish tugmasi; ilovada — markazlashgan sarlavha, `×` tugmasi yo'q.
- [ ] Chip tekislanishi: Figma — `Bobtail ×` / `N/A ×` chiplari maydonning **chap chetida**; ilovada — `T-880 ×` / `SD-42 ×` maydon markazida.
- [ ] `Note` maydoni: Figma — label qora, maydon bo'sh, ichida `Add Note` placeholder, balandligi ~1 qator; ilovada — label kulrang, ichida `Lorem Ipsum` qiymati, maydon ~2 barobar balandroq.
- [ ] `Cancel` tugmasi: Figma — oq fon + och kulrang chegara (`r8`); ilovada — kulrang to'ldirilgan fon, chegara yo'q.
- [ ] Tugmalar kengligi: Figma — `Cancel` va `Save` deyarli teng (Save biroz kengroq), ikkalasi dialog kengligini bo'lib oladi; ilovada `Cancel` sezilarli tor, o'ng chetda Save kengroq.

### Mos kelgani
- Maydonlar tartibi: Trailer Number → Shipping Document → Note.
- Chip uslubi: och kulrang fon + qora matn + qizil `×`.
- `Save` — qora to'ldirilgan tugma, oq matn, `r8`.
- Sarlavha `Documents`, qalin, qora.

---

## M-12 Change Duty Status — golden `m12_change_duty_status_light_phone.png` ↔ figma `1083-10550`
Parite: 72%

### Tafovutlar
- [ ] Ring gauge yozuvi: Figma — `BREAK`/`DRIVE`/`SHIFT`/`CYCLE` yozuvi **ring ichida**, qiymat ostida (ikki qatorli markaz); ilovada — yozuv ring **tashqarisida**, doiradan pastda.
- [ ] Ring o'lchami/qalinligi: Figma — diametr ~80 px, stroke ~6 px; ilovada — diametr ~90 px, stroke ~5 px, ranglar ochroq (BREAK Figma da to'q sariq `#C8621E` tusda, ilovada sariq/amber).
- [ ] `Yard move` toggle qatori: Figma kartasida yo'q — `On Duty/Sleep/Off Duty` tugmalaridan keyin darhol `Location` keladi; ilovada ortiqcha toggle qatori qo'shilgan.
- [ ] Chip tekislanishi: Figma — `Bobtail ×`, `N/A ×` maydon **chap chetida**; ilovada — `T-880 ×`, `SD-42 ×` markazda.
- [ ] `Cancel` tugmasi: Figma — oq fon + och kulrang chegara; ilovada — kulrang to'ldirilgan fon, chegarasiz.
- [ ] `Save` holati: Figma — qora, faol; ilovada — o'chirilgan (och kulrang fon, kulrang matn). Golden boshlang'ich holatni oladi, lekin Figma etaloni faol holatni ko'rsatadi.
- [ ] Pastki navigatsiya: Figma da ekran pastida 4 tabli bar bor (aktiv `Status` — qizil qalam ikonkasi + yozuv); goldenda umuman yo'q.
- [ ] AppBar: Figma da sarlavha ostidagi appbar fon kulrang `#F0F0F0` polosa sifatida ajralib turadi va ekran foni oq; ilovada appbar va sahifa fon farqi deyarli sezilmaydi.

### Mos kelgani
- Ekran tuzilishi: appbar `Change Duty Status` + 3 ta ikonka → 4 ta ring qatori → kulrang karta.
- Duty tugmalari: `On Duty` (teal to'ldirilgan, oq yuk mashinasi ikonkasi + oq matn), `Sleep` (oq, sariq oy), `Off Duty` (oq, qizil power) — tartib va uslub bir xil.
- Maydonlar tartibi: Location → Notes (o'ngda `+`) → Trailer Number → Shipping Document → tugmalar.
- Input uslubi: oq fon, och chegara, `r8`, kulrang placeholder (`Enter Location`, `Enter Notes`).
- Karta: kulrang fon, `r12`, ichki padding.

---

## M-13 Quick notes — golden `m13_quick_notes_light_phone.png` ↔ figma `1170-2313`
Parite: 70%

### Tafovutlar
- [ ] Konteyner turi: Figma — markazdagi **modal dialog** (oq, `r16`, yon chetlardan ~28 px, scrim); ilovada — drag-handle bilan **bottom sheet**, to'liq kenglikda.
- [ ] Sarlavha: Figma — `Quick notes` chapga tekislangan + o'ngda `×` yopish tugmasi; ilovada — markazlashgan, `×` yo'q.
- [ ] Yorliq matnlari: Figma — `Dropoff`, `Checkin`, `Checkout` (bir so'z); ilovada — `Drop off`, `Check in`, `Check out` (ikki so'z).
- [ ] Qator zichligi: Figma — checkbox qatorlari qadami ~40 px, checkbox ~22 px; ilovada — qadam ~56 px, checkbox ~20 px, natijada ro'yxat sezilarli uzunroq.
- [ ] Checkbox chap paddingi: Figma — checkbox dialog chetidan ~25 px, matn ~90 px dan; ilovada — checkbox ~35 px, matn ~80 px dan (matn/checkbox oralig'i kengroq).
- [ ] `Add Notes` tugmasi: Figma — qora to'ldirilgan, oq matn (faol); ilovada — o'chirilgan (och kulrang fon + kulrang matn).
- [ ] `Cancel` tugmasi: Figma — oq fon + och kulrang chegara; ilovada — kulrang to'ldirilgan, chegarasiz.

### Mos kelgani
- 10 ta punkt va ularning tartibi: PTI, Hook, Pickup, Drop off, Delivery, Inspection, Check in, Fueling, Check out, Other.
- Checkbox uslubi: kvadrat kontur, kichik radius, kulrang chegara, belgilanmagan holat.
- Ma'lumot polosasi: och kulrang fon, `r8`, chapda `ⓘ` ikonka + `Notes field has max 60 character limit` matni — joylashuvi va matni bir xil.
- Tugmalar qatori: chapda `Cancel`, o'ngda `Add Notes`, `r8`.
