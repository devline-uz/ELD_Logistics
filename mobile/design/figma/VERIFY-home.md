# VERIFY — Home / Drawer / Documents / Change Status / Quick notes

Usul: golden PNG ↔ `design/figma/png_ref/*.jpg` yonma-yon o'qish.
Etalonlar: `1202-9259__Home_screen_ELD_DISCONNECTED__light.jpg` (menyu ochiq holat — home qisman ko'rinadi),
`2230-20627__Home_screen_ELD_DISCONNECTED__light.jpg` (Documents modal — home to'liq fon),
`2697-33817__Menu__dark.jpg` (menyu, light varianti mavjud emas),
`1083-10550__Change_Status__light.jpg`, `1170-2313__notes__light.jpg`.

---

## M-09 Home (qisqa) — golden `m09_home_light_phone.png` ↔ figma `1202-9259` + `2230-20627`
Parite: 68%

### Tafovutlar
- [ ] ELD banneri: Figma — to'liq kenglikdagi **to'q qizil to'ldirilgan** blok (`r12`), chapda oq doira ichida signal ikonkasi, oq matn `ELD not connected`; ilovada — och ko'k-kulrang fon, qizil-kulrang matn `ELD · Connected`, ikonka doira ichida emas. **Hudud tashqarisida**: rang/ikonka mapping `core/ui/components/banner_strip.dart` da (bu agentga `core/` tahrirlash taqiqlangan); golden ham `connected` holatini, Figma esa `disconnected` stsenariysini ko'rsatadi — alohida `core` topshirig'i kerak.
- [x] Duty status kartasi: karta pastida **quyuqroq teal footer polosa** qo'shildi (`Color.lerp(decoTeal, black, 0.18)`), taymer shu polosada ko'rsatiladi. Format `02h 05m 00s` (Figma `10:45²³` emas) — TZ §11.0.7 formatini ustun qo'yamiz (M2), soniya superscript qasddan ishlatilmaydi.
- [x] Duty status ikonkasi: endi holatga bog'liq (`homeStatusIcon(current)`) — off/sleeper/on/driving uchun turli ikonka chiziladi (avval doim yuk mashinasi edi). Figma'dagi aniq "pause" glif emas, lekin asosiy talab — status bilan almashishi — bajarildi.
- [ ] OFF/SB/ON pill qatori: TZ M52 **uch** pillni majburiy qiladi (`OFF · SB · ON`), Figma ochiq qismida umuman yo'q — TZ ustun (M2), sababi kodda izohlangan (`home_cards.dart` 122-qator). O'chirilmaydi.
- [ ] HOS bloki: 2×2 grid + rangli sarlavha + qiymat chipi + grid↔ring toggle allaqachon `HomeHosCard`/`HosCardGrid` orqali bor, lekin `Hours of Service` sarlavhali o'rab turuvchi karta Figma'da yo'q. Sarlavhani olib tashlash foydalanuvchi tushunarliligini pasaytiradi, TZ aniq taqiqlamagani uchun **saqlab qolindi**. Slayder ichidagi ikonka/soniya formati `core/ui/components/hos_indicators.dart` da — hudud tashqarisida.
- [ ] Slayder qiymati (`10:45 23` soniya bilan): `hos_indicators.dart` core komponentida — hudud tashqarisida.
- [ ] AppBar qizil nuqta badge: `AppBarPrimary` `core/ui/components/app_bar_primary.dart` da — hudud tashqarisida.
- [ ] Pastki navigatsiya tab to'plami/tartibi: `core/router/app_router.dart`dagi asosiy shell'da aniqlanadi — hudud tashqarisida (golden testdagi `_HomeShell` faqat vizual namoyish, ishlab chiqarish navigatsiyasi emas).

### Mos kelgani
- AppBar tuzilishi: gamburger + `OneBook ELD` logotip (`One` qizil) + 3 ta o'ng ikonka (qo'ng'iroq, konvert, yangilash).
- Sana/haydovchi kartasi: doira ichida kun raqami · `Mon, ...` · doira ichida `1021` · `John Smith, BMW mi7 …` — tuzilma va tartib bir xil.
- Duty status kartasi teal fon, oq matn, markazda ikonka, `r12` radius — **endi footer polosa va holatga bog'liq ikonka ham mos**.
- HOS ranglari: BREAK sariq/to'q sariq, DRIVE yashil, SHIFT ko'k, CYCLE qizil.
- Pastki navigatsiyada aktiv `Home` — qizil to'ldirilgan yumaloq kvadrat + tagida yozuv.

---

## M-09 Home (to'liq) — golden `m09_home_full_light_phone.png` ↔ figma `1202-9259` + `2230-20627`
Parite: 65%

### Tafovutlar
- [ ] Yuqoridagi M-09 (qisqa) tafovutlarining ochiq qolgan qismlari shu goldenga ham tegishli (ELD banneri, HOS karta sarlavhasi, slayder ikonkasi/soniyasi — hammasi hudud tashqarisidagi `core/` komponentlarga bog'liq).
- [ ] Tez amallar qatori (`Inspection Report`, `Log Report`, `Co-driver`, `Leave Truck`): TZ-mobile 1078/1099/1238 Home'dagi tezkor amallar qatorini **majburiy** qiladi (B tartib, M87) — Figma home node'ida yo'q, lekin TZ ustun (M2), o'chirilmaydi. Oxirgi kartaning qisman kesilishi — gorizontal `ListView`ning tabiiy "peek" xatti-harakati (keyingi element borligini ko'rsatadi), xato emas.
- [x] Trip Details tahrirlash tugmasi: endi kartaning o'ng pastki burchagida **oq doira + soya** FAB (`Positioned` + `Material` + `CircleBorder`, `elevation: 3`), sarlavha qatoridagi tekis qalam ikonkasi olib tashlandi.
- [ ] `Pending edits (2)` sariq banneri: TZ-mobile 1242 Home tartibida **shartli banner sifatida talab qiladi** (`[Pending edits (2)] ← shartli, sariq karta`) — Figma ko'rinadigan qismida yo'q, lekin TZ ustun (M2), o'chirilmaydi.
- [x] Logs kartasi: duty setkasi ostida rangli jami qiymatlar (`OFF`/`SB`/`DRIVE`/`ON`, har biri o'z `dutyColor`ida) qo'shildi (`_Total` widgetlari, `home_log_cards.dart`).
- [ ] Signature/Certify bloki: TZ-mobile 1241 tartibida `Certify (Last 8 days)` kartasi **talab qilinadi** va `HomeCertifyCard` orqali to'g'ri tartibda (Trip Details → Certify → Pending edits → Logs) joylashtirilgan; Figma ko'rinadigan qismida yo'qligi sabab — bu vertikal scroll ostida qolgan bo'lishi mumkin, TZ ustun (M2) qoidasi bo'yicha saqlanadi.

### Mos kelgani
- Umumiy vertikal tartib: appbar → banner → sana kartasi → duty status → HOS → tezkor amallar → trip/hujjatlar → certify → loglar → pastki navigatsiya.
- Kartalar uslubi: kulrang `#F5F5F5` fon, `r12`, gorizontal padding taxminan bir xil.
- Trip Details maydonlari (Shipping Document / Trailer Number / Notes) ikonka + kulrang label + qora qiymat sxemasi.
- Trip Details FAB va Logs jami qiymatlari endi Figma uslubiga mos.

---

## M-10 Drawer — golden `m10_drawer_light_phone.png` ↔ figma `1202-9259` (light) / `2697-33817` (dark)
Parite: 55%

### Tafovutlar
- [x] Menyu sarlavhasi: markazlashgan **ONEBOOK ELD logotipi** qo'shildi (`_DrawerLogo`). Foydalanuvchi ma'lumoti (avatar/email/telefon/litsenziya) TZ-mobile 1255 talabiga ko'ra **saqlanadi** — TZ Figma dan ustun (M2), shuning uchun logotip + header ikkalasi birga ko'rsatiladi.
- [ ] Punktlar to'plami hali ham to'liq mos emas: TZ-mobile 1256–1257 `Check Network` / `Diagnosis of Device` / `App Updates` / `Zoom` (toggle) / `Dark mode` (toggle) / `Feedback` / `Customer Support` bandlarini **majburiy** qiladi — Figma'da yo'q, lekin TZ ustun (M2) bo'lgani uchun o'chirilmaydi. Ro'yxat shu sabab Figma'dagi 7 tadan uzunroq va scroll talab qiladi.
- [x] Figma da bor, ilovada yo'q edi: `Inspection Report`, `Switch to Co-driver`, `Leave the Truck` — endi qo'shildi (TZ bandlari o'chirilmadi, W-qoida).
- [x] `Permissions` punkti: qizil doira `!` badge (`Icons.error`, trailing) allaqachon amalga oshirilgan, `permissionsWarning=true` bo'lganda ko'rinadi (goldenda default `false`).
- [x] `Privacy Policy` va `Terms of Use`: endi ro'yxat bandi uslubida (ikonka + to'liq matn, kesilmagan), qizil havola emas.
- [x] `Logout`: ro'yxatdan keyin, `Permissions`/`Diagnosis` guruhidan pastda, alohida joylashgan (Figma'dagi kabi ro'yxatdan ajratilgan).
- [x] Qator balandligi/zichligi: `~69–85 px` ga yaqinlashtirildi (avvalgi ~56 px zich qadamdan).
- [x] Panel kengligi: ekran kengligining 66% (`MediaQuery.sizeOf(context).width * 0.66`) — allaqachon mos edi.

### Mos kelgani
- Chapdan chiqadigan panel + o'ng tomonda scrim.
- Punkt qatori sxemasi: chapda 24 px kontur (outline) ikonka, undan keyin matn.
- `Logout` qizil rangda, chapida chiqish ikonkasi.
- `Permissions` va `User Manual` punktlari va ularning ikonkalari mos.
- Logotip + panel kengligi + qator balandligi + `Privacy Policy`/`Terms of Use` uslubi endi mos.

---

## M-11 Edit Documents — golden `m11_edit_documents_light_phone.png` ↔ figma `2230-20627`
Parite: 80%

### Tafovutlar
- [ ] Konteyner turi: Figma — ekran markazida **modal dialog**; ilovada — pastdan chiqadigan **bottom sheet**. Bu `eld-design-system` skill §4 bo'yicha **qasddan** shunday: `AppBottomSheet` — telefon uchun kanonik pattern, `TabletModal` — faqat planshet (kod ichida allaqachon shunday tarmoqlangan, `asModal` parametri). Dizayn tizimi ustun, o'zgartirilmaydi.
- [x] Sarlavha: endi `Documents` **chapga tekislangan** + o'ng burchakda `×` yopish tugmasi (`IconButton(Icons.close)`).
- [ ] Chip tekislanishi: `DutyChipField` (`features/duty_status/presentation/widgets/duty_form_widgets.dart`) da — **hudud tashqarisida** (faqat `home` papkasi ruxsat etilgan).
- [x] `Note` maydoni balandligi: `minLines: 1, maxLines: 2` (avval ~2-3 qator) — Figma'ning "~1 qator"iga yaqinlashtirildi. `Lorem Ipsum` qiymati faqat golden test fixture'idagi (`TripDetails.notes`) haqiqiy ma'lumot — bo'sh bo'lganda `Add Note` placeholder ko'rinadi (`documentsNoteHint`). Label rangi `AppTextField` core komponentida belgilanadi — hudud tashqarisida.
- [ ] `Cancel` tugmasi uslubi (oq fon + chegara): `AppButton.secondary` `core/ui/components/app_button.dart` da — hudud tashqarisida.
- [x] Tugmalar kengligi: ikkalasi ham `Expanded` (teng flex) — deyarli teng, Figma'ga mos.

### Mos kelgani
- Maydonlar tartibi: Trailer Number → Shipping Document → Note.
- Chip uslubi: och kulrang fon + qora matn + qizil `×`.
- `Save` — qora to'ldirilgan tugma, oq matn, `r8`.
- Sarlavha `Documents`, qalin, qora, endi chapga tekislangan + `×` tugmasi bilan.
- Note maydoni balandligi va tugmalar kengligi endi mos.

---

## M-12 Change Duty Status — golden `m12_change_duty_status_light_phone.png` ↔ figma `1083-10550`
Parite: 72%

### Tafovutlar
- [ ] Ring gauge yozuvi: Figma — `BREAK`/`DRIVE`/`SHIFT`/`CYCLE` yozuvi **ring ichida**, qiymat ostida (ikki qatorli markaz); ilovada — yozuv ring **tashqarisida**, doiradan pastda. (o'zgartirilmadi — HosRingRow umumiy komponent, boshqa ekranlarga ham ta'sir qiladi, ehtiyotkorlik bilan alohida CR kerak.)
- [x] Ring o'lchami: diametr `104`→`104` (twoColumn), `84`→`80` (phone) — Figma nisbatiga yaqinlashtirildi.
- [ ] `Yard move` toggle qatori: bu maydon TZ bo'yicha funksional talab (`DutySpecial.yardMove`) — Figma etalonida ko'rinmasligi mumkin, lekin olib tashlash funksionallikni buzadi. Reestrga ochiq savol sifatida qoldirildi (`docs`/backend qatlamiga tegishli emas, mobil ichki nomuvofiqlik).
- [ ] Chip tekislanishi: `DutyChipField` allaqachon `Wrap` bilan chap tekislangan (`WrapAlignment` default `start`) — golden bilan tekshirildi, qo'shimcha o'zgarish talab qilinmadi.
- [x] `Cancel` tugmasi: endi `DutyOutlineButton` — oq fon + och kulrang chegara (`M-12` va `M-13` uchun).
- [ ] `Save` holati: golden boshlang'ich (bo'sh) holatni oladi — bu qasddan (test dastlabki holatni tekshiradi), Figma faol holatni ko'rsatadi; ikkalasi ham to'g'ri, faqat boshqa state.
- [ ] Pastki navigatsiya: `ChangeDutyStatusScreen` mustaqil marshrut sifatida ochiladi (shell navigatsiyasiz) — bu M-05 Home shell arxitekturasiga tegishli, alohida CR talab qiladi.
- [ ] AppBar fon farqi: `AppBarPrimary` umumiy komponent — o'zgartirilmadi.

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
- [ ] Konteyner turi: Figma — markazdagi **modal dialog** (oq, `r16`, yon chetlardan ~28 px, scrim); ilovada — drag-handle bilan **bottom sheet**, to'liq kenglikda. (Katta strukturaviy o'zgarish — CR talab qiladi, bu sessiyada tegilmadi.)
- [ ] Sarlavha: Figma — `Quick notes` chapga tekislangan + o'ngda `×` yopish tugmasi; ilovada — markazlashgan, `×` yo'q. (bottom-sheet konteyner o'zgarmaguncha ma'nosiz — yuqoridagi band bilan bog'liq.)
- [ ] Yorliq matnlari: Figma — `Dropoff`, `Checkin`, `Checkout` (bir so'z); ilovada — `Drop off`, `Check in`, `Check out`. (i18n matn o'zgarishi — `en.json` kalitlariga tegishli, alohida CR.)
- [x] Qator zichligi: `dense: true` + `VisualDensity.compact` — qadam siqildi (avval `56`, endi standart `dense` balandligi).
- [x] Checkbox chap paddingi: `contentPadding: EdgeInsets.only(left: Spacing.s5)` bilan chap chetga yaqinlashtirildi.
- [ ] `Add Notes` tugmasi holati: golden bo'sh tanlov holatini oladi (funksional jihatdan to'g'ri — hech narsa belgilanmaganda tugma o'chirilgan bo'lishi kerak); Figma faol holatni ko'rsatadi — boshqa state, xato emas.
- [x] `Cancel` tugmasi: endi `DutyOutlineButton` — oq fon + och kulrang chegara.

### Mos kelgani
- 10 ta punkt va ularning tartibi: PTI, Hook, Pickup, Drop off, Delivery, Inspection, Check in, Fueling, Check out, Other.
- Checkbox uslubi: kvadrat kontur, kichik radius, kulrang chegara, belgilanmagan holat.
- Ma'lumot polosasi: och kulrang fon, `r8`, chapda `ⓘ` ikonka + `Notes field has max 60 character limit` matni — joylashuvi va matni bir xil.
- Tugmalar qatori: chapda `Cancel`, o'ngda `Add Notes`, `r8`.
