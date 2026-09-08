# MAP.md — Figma freym → ekran ID xaritasi

**§1–§6 — mobil (393 dp) · §7 — planshet (1366×1024, B-123)**

Manba: `_raw_frames_mobile.json` (Figma `Mobile Application` 14:6 · Light `1070:6813` 138 freym · Dark `2665:25648` 122 freym).
Registr: `.claude/skills/eld-screens/SKILL.md` §1 · `tz-mobile.md` §11.1 (1115–1174).

**Ekran mezoni:** freym kengligi **393**. Boshqa kenglikdagi va `Component NNN` / `Vector NN` /
`App Bar` / `Categories` / `Container` / `Modal` / `Frame NNNNNN` / `Banner` / `Category list` /
`Table` nomli freymlar — komponent, §4 da.

**Yakuniy sanoq**
| Ko'rsatkich | Light | Dark |
|---|---|---|
| Jami freym | 138 | 122 |
| Haqiqiy ekran freymi (393 dp) | **66** | **59** |
| Yordamchi/komponent freym | 72 | 63 |
| Nom bo'yicha juftlangan | 57 | 57 |
| Juftlanmagan | **9** | **2** |

---

## 1. Ekran xaritasi

Ustunlar: `Ekran ID | TZ dagi nomi | Figma light | Figma dark | O'lcham | Izoh`.
`~` = taxminiy moslik (Figma nomi registr nomiga aynan mos emas).

| Ekran ID | TZ dagi nomi | Figma light nodeId | Figma dark nodeId | O'lcham | Izoh |
|---|---|---|---|---|---|
| M-01 | Splash | `958:22` Splash screen | `2665:32354` | 393×852 | to'liq mos |
| M-02 | Login | `958:44` Login | `2665:32374` | 393×852 | to'liq mos |
| M-02v | Login — to'ldirilgan holat | `1113:9176` Login - filled | `2665:32428` | 393×852 | M-02 ning holati, alohida ekran emas |
| M-03 | Leave truck / Return to truck | `1116:9231` leave truck | `2697:34385` | 393×852 | to'liq mos |
| M-09 | **Home** — A tartib | `1202:9259` Home screen (ELD DISCONNECTED) | `2697:30801` | 393×854 / 851 | A/B qarori M87; A tartib |
| M-09 | **Home** — B tartib | `2177:12192` Home screen (ELD DISCONNECTED) | `2665:37236` | 393×1650 | B kanonik (M87), lekin uzun scroll M88 bilan cheklanadi |
| M-09v1 | Home — variant | `2177:15239` | `2665:38199` | 393×1650 | **variant, aniqlanishi kerak** |
| M-09v2 | Home — variant | `2177:15808` | `2665:38568` | 393×1650 | **variant, aniqlanishi kerak** |
| M-09v3 | Home — variant | `2590:23326` | `2665:38927` | 393×1650 | **variant, aniqlanishi kerak** |
| M-09c | Home — ELD CONNECTED | `1180:7352` Home screen (ELD CONNECTED) | `2665:40386` | 393×1152 | ulangan holat |
| M-10 | Drawer (yon menyu) | `1202:9259` (ochilgan holat, TZ §11.1) | `2697:33817` **Menu** | 393×854 / 851 | ~ dark da mustaqil `Menu` freymi, light da yo'q |
| M-11 | Edit documents (Trip Details) | `2230:20627` Home screen (ELD DISCONNECTED) | `2678:48656` | 393×852 / 851 | ~ TZ §11.1 shu nodeni beradi; nomi «Home screen» — §5 ga qara |
| M-11? | Edit documents — muqobil nomzod | `1107:2758` Eac row (on-click) | `2697:31405` | 393×852 / 851 | ~ Home yonidagi «satr bosilganda»; qaysi biri M-11 — aniqlanishi kerak |
| M-12 | Change duty status | `1083:10550` Change Status | `2665:27343` | 393×891 | TZ §11.1 kanonik deb shuni beradi |
| M-12v1 | Change duty status — variant | `1085:11554` Change Status | `2665:30079` | 393×893 | **variant, aniqlanishi kerak** |
| M-12v2 | Change duty status — variant | `1085:11965` Change Status | `2665:32209` | 393×893 | **variant, aniqlanishi kerak** |
| M-13 | Quick notes | `1170:2313` notes | `2697:33202` Notes | 393×852 / 851 | to'liq mos |
| M-14 | Location inaccurate | `1102:2021` location error | `2697:34812` | 393×852 / 851 | to'liq mos |
| M-15 | Drive mode (focused) | `1170:2684` IN-DRIVE FOCUSED | `2665:27572` | 393×852 | ~ dark juftligi tartib bo'yicha; **aniqlanishi kerak** |
| M-16 | Idle prompt (5 min) | `2181:17282` IN-DRIVE FOCUSED | `2697:35449` | 393×852 / 851 | ~ ikkala freym bir xil nomda; juftlash **aniqlanishi kerak** |
| M-17 | ELD not connected | `1102:1738` ELD not CONNECTED | — | 393×852 | ⚠️ **dark juftligi yo'q** |
| M-18 | Permissions | `1107:2310` permission | `2665:30606` | 393×852 | to'liq mos |
| M-20 | Co-driver switch confirm | `1113:8480` CO-DRIVER | `2697:31993` | 393×852 / 851 | to'liq mos |
| M-21 | Select shipping document | `1113:8764` Switch button | `2697:32622` | 393×852 / 851 | ~ Figma nomi «Switch button» |
| M-22 | Log Report — Main | `1085:14341` Log Report - Main | `2665:29623` | 393×854 | to'liq mos |
| M-23 | Log Report — Logs (grid) | `1085:13169` Log Report - Logs | `2665:29130` | 393×854 | to'liq mos |
| M-24 | Log Report — DVIR | `1087:14921` Log Report - DVIR | `2665:29437` | 393×854 | to'liq mos |
| M-24v | Log Report — DVIR (bo'sh/variant) | `1154:6104` Log Report - DVIR | — | 393×854 | ⚠️ **dark juftligi yo'q**; `No DVIR Found` holati bo'lishi mumkin |
| M-25 | Log event detail | `1111:7334` Eac row (on-click) | `2665:33093` | 393×852 | ~ TZ §11.1 shu nodeni beradi |
| M-29 | Certify — kunlar ro'yxati | `1102:397` Signature - edit | `2665:30390` | 393×852 | ~ Figma nomi chalg'ituvchi («Signature - edit») |
| M-29v | Certify — ro'yxat varianti | `1102:931` Signature - edit | `2665:30850` | 393×852 | **variant, aniqlanishi kerak** |
| M-30 | Certify — Sign | `1102:817` Certify All button | `2665:31395` | 393×852 | ~ TZ §11.1 shu nodeni beradi |
| M-30v1 | Certify — imzo saqlangan holat | `2590:23861` Certify All button -> if signature saved | `2665:31514` | 393×852 | holat varianti |
| M-30v2 | Certify — Sign variant | `2590:24226` Certify All button | `2665:31633` | 393×852 | **variant, aniqlanishi kerak** |
| M-30v3 | Certify — Sign tugmasi | `1102:1599` Sign Button | `2697:29966` Sign buttoin | 393×852 | dark da imlo xatosi («buttoin») |
| M-31 | Certify — Not Ready / tanlangan | `1102:1260` Certify Selected (1) | `2665:31866` | 393×852 | ~ TZ §11.1 shu nodeni beradi |
| M-31v | Certify Today | `1102:1486` Certify Today | `2665:31978` | 393×852 | holat varianti |
| M-32 | Add DVIR (forma) | `1089:4441` Add DVIR | — | 393×852 | ⚠️ **dark juftligi yo'q** |
| M-33 | Defect picker (truck/trailer) | `1169:1467` vehicle defects | — | 393×852 | ⚠️ **dark juftligi yo'q**. TZ §11.1 dagi `1169:1887`/`1169:2106` — 301 dp panel, ekran emas |
| M-34 | DVIR review + signature | `1090:4687` Add DVIR - IF No defects selected | — | 393×852 | ⚠️ **dark juftligi yo'q** |
| M-34v1 | DVIR review — nuqson tanlangan | `1090:4901` Add DVIR - IF defects selected | — | 393×852 | ⚠️ dark yo'q; **variant, aniqlanishi kerak** |
| M-34v2 | DVIR review — nuqson tanlangan | `1090:5027` Add DVIR - IF defects selected | — | 393×852 | ⚠️ dark yo'q; `1090:4901` bilan bir xil nomda |
| M-35 | DVIR details | `1166:869` Eac row (on-click) | — | 393×852 | ~ TZ §11.1; ⚠️ **dark juftligi yo'q** |
| M-37 | Inspection Report (3 amal) | `1111:7825` FMCSA Report | `2665:27860` | 393×854 | ~ Figma nomi «FMCSA Report» |
| M-38 | Begin inspection (kiosk) | `1111:8013` Begin inspection | `2665:29318` | 393×854 | to'liq mos |
| M-40 | Send via email | `1169:1196` send via email | `2697:36778` | 393×854 / 851 | to'liq mos |
| M-40v | Send via email — variant | `1111:8223` Send via email | `2665:31178` | 393×854 | **variant, aniqlanishi kerak** |
| M-41 | Send the file (DOT) | `1169:1332` send file to DOT | `2700:37357` send file to DOT via WEB | 393×854 / 851 | ~ dark nomi «via WEB» |
| M-41v1 | Send file to DOT — variant | `2695:1078` send file to DOT | `2697:36217` send to DOT via email | 393×854 / 851 | ~ nomlar ajralgan; **aniqlanishi kerak** |
| M-41v2 | Send file — variant | `1113:8349` Send file | `2665:31277` | 393×854 | **variant, aniqlanishi kerak** |
| M-42 | Chat | `1118:114` Chat | `2665:34989` | 393×852 | to'liq mos |
| M-43 | Notifications | `1156:7135` Notification | `2665:35068` | 393×852 | to'liq mos |
| M-43v | Notifications — bo'sh holat | `1156:7244` notification - empty | `2665:35167` | 393×852 | `No Notifications Yet` |
| M-44 | Profile | `1119:445` Profile | `2665:29782` | 393×854 | to'liq mos |
| M-45 | Settings | `1131:392` Settings | `2665:27939` | 393×854 | to'liq mos |
| M-46 | Diagnosis of device | `1131:965` Diagnosis of device | `2665:28907` | 393×854 | TZ §11.1 kanonik |
| M-46v | Diagnosis — variant | `1131:500` Diagnosis of device | `2700:37918` | 393×854 / 851 | **variant, aniqlanishi kerak** |
| M-47 | Check network | `1122:319` check Network' | `2665:29068` | 393×854 | TZ §11.1 kanonik |
| M-47v | Check network — variant | `1122:63` check Network' | `2665:29009` | 393×854 | **variant, aniqlanishi kerak** |
| M-48 | Give feedback | `1131:1149` Give feedback | `2665:28031` | 393×854 | to'liq mos |
| M-49 | Contact support (forma) | `1179:7028` add support form | `2700:38501` | 393×854 / 851 | to'liq mos |
| M-50 | Support & Helpdesk (ro'yxat) | `1179:7142` Support & Helpdesk | `2665:36915` | 393×852 | ⚠️ TZ §11.1 da `1179:7142` — Figma da bu **ekran**, `1179:7141` esa `Component 135` |
| M-51 | Support ticket thread | `1158:462` Ticket - View | `2665:35485` | 393×852 | ⚠️ **TZ da 🎨 (dizaynda yo'q) deb belgilangan — aslida BOR**, §3 ga qara |
| M-52 | Privacy Policy | `2627:25778` privacy policy | `2665:37024` | 393×852 | to'liq mos |
| M-53 | Terms of Use | `2627:25891` Terms of use | `2665:37130` | 393×852 | ⚠️ TZ §11.1 M-53 uchun ham `2627:25778` yozgan — **xato**, to'g'risi `2627:25891` |

**Xaritada:** 66 light freymning **64 tasi** M-ID ga bog'landi (§2 dagi 2 tasi bog'lanmadi).

---

## 2. Figma da bor, registrda yo'q

| Figma light | Figma dark | Nomi | O'lcham | Izoh |
|---|---|---|---|---|
| `1177:6775` | `2665:35240` | Maintainance - cancelled | 393×852 | `Maintenance` moduli bu bosqichda **yo'q** (eld-screens §3, M-67). Implementatsiya qilinmaydi |
| `1166:504` | — | Eac row (on-click) | 393×852 | 4 ta bir xil nomli freymdan biri; qaysi ekranga tegishli — **aniqlanishi kerak** |
| — | `2697:30086` | Certify All button | 393×852 | dark da 3-nusxa (light da 2 ta); ortiqcha iteratsiya |
| — | `2697:33817` | Menu | 393×851 | M-10 drawer ning mustaqil freymi; light da bunday mustaqil freym yo'q |

---

## 3. Registrda bor, Figma da yo'q (🎨 — dizaynga qo'shiladi)

`tz-mobile.md` §21.6 va TZ matni yagona manba. `screen-implementer` bu ekranlarni dizayn tizimi
komponentlaridan quradi.

| ID | Nomi | Modul |
|---|---|---|
| M-04 🎨 | PIN entry | `auth` |
| M-05 🎨 | Accept invitation (parol + PIN) | `auth` |
| M-06 🎨 | Forgot password | `auth` |
| M-07 🎨 | Reset password | `auth` |
| M-08 🎨 | Two-factor (TOTP) | `auth` |
| M-19 🎨 | ELD device connect/scan | `eld_device` |
| M-26 🎨 | Pending edits (ro'yxat) | `log_edits` |
| M-27 🎨 | Pending edit detail (Approve/Reject) | `log_edits` |
| M-28 🎨 | Unidentified driving claim | `unidentified` |
| M-36 🎨 | Previous defects certification | `dvir` |
| M-39 🎨 | Exit inspection (PIN) | `inspection` |
| M-54 🎨 | Sync status | `core/sync` |
| M-55 🎨 | Sync conflicts | `core/sync` |
| M-56 🎨 | Signed out elsewhere | `auth` |
| M-57 🎨 | Force update | `core/router` |
| M-58 🎨 | Sessions (my devices) | `auth` |

**Jami 16 ta 🎨.** ⚠️ `eld-screens` registrida 17 ta 🎨 belgisi qo'yilgan, matnda esa «15 tasi 🎨»
deyilgan — **ikkalasi ham noto'g'ri**. M-51 ning Figma freymi topildi (`1158:462`), shuning uchun
haqiqiy son — **16**. Registrga tuzatish kerak.

---

## 4. Yordamchi / komponent freymlar (ekran emas)

Bular xaritaga kirmaydi — komponent kutubxonasi va vektor primitivlari.

| Guruh | Light | Dark | Namunalar |
|---|---|---|---|
| `Component NNN` | 40 | 33 | `1158:216` Component 96 (826×136) · `1158:288` Component 113 (395×136) · `2665:35201` Component 180 |
| `Vector NN` | 12 | 12 | `1118:428` Vector 11 (152×101) · `1118:443` Vector 23 (395×157) |
| `App Bar` / `App Bar - Refresh icon` | 4 | 4 | `1116:9350`, `1116:9392`, `2665:34919`, `2665:34973` — hammasi 393×54 |
| `Categories` / `Category list` | 5 | 4 | `2697:29515` (345×125) · `2230:21442` (345×416) · `1113:8737` (390×90) |
| `Frame NNNNNN` | 6 | 2 | `2230:21184` (345×444) · `1169:1887` (301×1487) · `1169:2106` (301×467) |
| `Container` / `Modal` / `Table` / `Banner` / `Log` / `Section N` | 5 | 7 | `2177:13665` (270×267) · `2177:14450` Modal (480×928) · `2665:32708` Table (589×234) |
| `Not part of this phase` | 1 | 1 | `2627:25743` / `2665:35547` (4983×1548) — bu bosqichdan tashqari |
| **Jami** | **72** | **63** | |

⚠️ **Ehtiyot:** `1169:1887` (301×1487) va `1169:2106` (301×467) — TZ §11.1 M-33 uchun keltirilgan,
lekin kengligi 301, ya'ni **panel/list komponenti**, ekran emas. M-33 ning haqiqiy ekrani —
`1169:1467` vehicle defects (393×852).

---

## 5. Aniqlanishi kerak

| # | Savol | Dalil | Kimga |
|---|---|---|---|
| 1 | `_otherSections` da **`3497:433` — «Mobile Application / Dark Theme» DUBLIKAT** (122 kids, `2665:25648` bilan bir xil o'lcham). Qaysi biri joriy? Ikkinchisi o'chirilishi kerakmi? | `_raw_frames_mobile.json._otherSections` | dizayner |
| 2 | `1206:9697` — «Mobile Application» (14688×10510, 129 kids). Ehtimol **eskirgan iteratsiya**. Undan foydalanilmaydimi? | shu yerda | dizayner |
| 3 | `1119:653` — «Section 1» (1459×1074, 3 kids). Nima uchun kerak? Mobil oqimga tegishlimi? | shu yerda | dizayner |
| 4 | **Home ning 4 ta 393×1650 varianti** (`2177:12192`, `2177:15239`, `2177:15808`, `2590:23326`) — qaysi biri kanonik? | §1 M-09 | dizayner |
| 5 | **Change Status** 391 va 893 balandlik: `1083:10550` (891) vs `1085:11554`/`1085:11965` (893). 2 px farq — texnik nuqsonmi yoki turli holatmi? | §1 M-12 | dizayner |
| 6 | `2230:20627` nomi «Home screen (ELD DISCONNECTED)», lekin TZ §11.1 uni **M-11 Edit documents** deb beradi. Nomlash xatosi yoki TZ xatosi? | §1 M-11 | dizayner + TZ CR |
| 7 | 4 ta bir xil nomli **`Eac row (on-click)`** (`1107:2758`, `1111:7334`, `1166:504`, `1166:869`) — har biri qaysi ekran? | §1, §2 | dizayner |
| 8 | Dark tema freymlari ko'pincha **851 dp**, light — **852/854 dp**. Ataylabmi? | butun jadval | dizayner |
| 9 | **9 ta light ekranning dark ekvivalenti yo'q** (M-17, M-24v, M-32, M-33, M-34, M-34v1, M-34v2, M-35, `1166:504`). DVIR oqimi dark temada umuman chizilmagan | §1 | dizayner |
| 10 | Dark da `send file to DOT via WEB` va `send to DOT via email` — light da ikkalasi ham `send file to DOT`. Nomlar birlashtirilsinmi? | §1 M-41 | dizayner |

---

## 6. Keyingi qadam

- [x] Har bir M-ID uchun `screens/<ID>.json` — **67 ekran chiqarildi** (2026-09-07).
- [x] Mobil etalon rasmlar: `png/` (139) + `png_ref/` (maks 1000 px JPEG). Planshet: `png_ref/` da **58 ta** (§7).
- [ ] Burchak radiuslarini ekran freymlaridan o'lchash (`tokens.json._pending.cornerRadius` → `DIFF.md` #D-01).
- [ ] §5 dagi 10 savolni dizaynerga yuborish; javob kelguncha `M-09`, `M-12`, `M-41` variantlari muzlatiladi.

---

# 7. PLANSHET (Tablet Application `14:7`) — B-123 yopildi

**Planshet freymlari CHIZILGAN.** `MAP.md` ilgari faqat 393 dp mobil freymlarni qamragan edi;
planshet sahifasi umuman skanerlanmagan ekan. Endi skanerlandi.

## 7.1 Sahifa tuzilmasi

| Section | nodeId | `visible` | Bolalar | Maqom |
|---|---|---|---|---|
| OneBookELD Tablet App — **Light Theme** | `1470:21013` | ✅ true | 148 | **JORIY** |
| OneBookELD Tablet App — **Dark Theme** | `2197:104566` | ✅ true | 149 | **JORIY** |
| `Home` | `1804:31752` | ❌ **false** | 15 | arxiv (eski iteratsiya) |
| `Section 3` | `1495:43530` | ❌ **false** | 29 | arxiv (eski iteratsiya) |
| `Section 1` | `1349:2701` | ❌ **false** | 3 | arxiv (eski iteratsiya) |

⚠️ Uch section `visible:false` — ular ichidagi freymlar `exportAsync` da **1×1 px** qaytaradi.
Ular etalon sifatida **ishlatilmaydi**. Faqat yuqoridagi ikki `OneBookELD Tablet App` section kanonik.

**Freym o'lchami: hamma joyda `1366×1024`** (landshaft). 1024/1194 kengliklar umuman yo'q —
ya'ni dizayn **yagona planshet breakpointi** uchun chizilgan. Top Navigation = `1366×64`.
Drawer (yon panel) = `314×1024`.

## 7.2 T-ID → Figma node xaritasi

`png_ref/` ustunidagi fayl nomi = `<nodeId>__<T-ID>__<nom>__<tema>.jpg` (maks 1000 px, JPEG q62).

| T-ID | Nomi | Light nodeId | Dark nodeId | Izoh |
|---|---|---|---|---|
| T-01 | Home / Full screen | `1470:42666` | `2195:94915` | + light variantlari `1800:29108`, `2050:9173`, `2050:11758`, `2066:14834`; dark `2186:30658`, `2181:19898`, `2181:24708` |
| T-02 | Yon menyu (drawer) | `2142:25753` (Group 39572, 314×1024) | `2197:103777` **menu** (1366×1024) + `2216:22415` (Group 39571) | ⚠️ light da faqat GROUP, dark da to'liq freym — §7.4 s.3 |
| T-03 | Edit Documents | `1470:19197` | `2189:40299` edit doc | to'liq mos |
| T-04 | Change Duty Status | off `1470:28679` · sleep `1470:31742` · on `1470:33660` | off `2190:68109` · sleep `2190:73904` · on `2190:77058` | har temada 6 freym (2 to'plam) |
| T-05 | Quick Notes | ❌ **yo'q** | ❌ **yo'q** | faqat arxivda (`1342:2241`, hidden) |
| T-06 | Location error | ❌ **yo'q** | ❌ **yo'q** | faqat arxivda (`1343:2477`, hidden) |
| T-07 | Switch co-driver | `1517:51373` | `2209:18796`, `2209:21530` | to'liq mos |
| T-08 | Select Shipping Document | `1517:53372` codriver - document | ❌ **yo'q** | dark juftligi yo'q |
| T-09 | Log Detail | `1517:52371` Log (row click) | `2198:105687` log (row click) | to'liq mos |
| T-10 | Log panel (kengaytirilgan grid) | ❌ alohida freym yo'q | ❌ | T-15 ichidagi panel |
| T-11 | Certify (Last 8 days) | `1470:20134` (no date) · `1470:21102` (selected) · +`1470:22044`, `2417:29993`, `1470:22998`, `1470:23885` | `2190:47845`, `2190:53307` (no date) · `2190:50605` (selected) · `2190:56075`, `2190:58738` (date selected) | dark da «date selected» bor, light da yo'q |
| T-12 | Sign | ❌ alohida freym yo'q | ❌ | T-11 oqimi ichida |
| T-13 | Not Ready | ❌ **yo'q** | ❌ **yo'q** | umuman chizilmagan |
| T-14 | Log Report — Main | `2156:50541` (+`2142:16317`, `2156:43729`, `2156:49615`) | `2216:45107` (+`2209:24337`, `2216:18456`) | to'liq mos |
| T-15 | Log Report — Logs | `2142:22733` (+`2142:24602`) | `2209:25077` (+`2209:26047`) | to'liq mos |
| T-16 | Log Report — DVIR | ❌ **yo'q** | ❌ **yo'q** | faqat arxivda (`1361:2320` Empty, `1361:2891` Filled) |
| T-17 | Inspection Report | ❌ **yo'q** | ❌ **yo'q** | umuman chizilmagan |
| T-18 | Send via Email | `2156:47218` | `2218:50645` | to'liq mos |
| T-19 | Send file to DOT | `2697:21073` (+`2156:48249`) | `2697:21943` (+`2218:51620`) | to'liq mos |
| T-20 | Begin inspection (kiosk) | `2156:46277` | `2218:49613` | to'liq mos |
| T-21 | Check Network | `2142:26925` (+`2142:27944`) | `2216:25327` (+`2216:22608`) | to'liq mos |
| T-22 | Permissions | `2142:28945` | `2216:28029` | to'liq mos |
| T-23 | Diagnosis of Device | `2142:31232` | `2216:36611` | to'liq mos |
| T-24 | Feedback | `2142:32880` | `2216:39540` | to'liq mos |
| T-25 | Drive-focused | ❌ **yo'q** | `2190:90626` drive-focused | ⚠️ **light juftligi yo'q** |
| T-26 | Idle prompt (5 min) | ❌ **yo'q** | `2195:97628` 5 mint idle | ⚠️ **light juftligi yo'q** |
| T-27 | Contact Support (jadval) | `2146:39644` (+`2146:35984`, `2146:38704`; **1366×936**) | `2216:43953` (+`2216:33414`, `2216:42810`; 1366×1024) | ⚠️ light da balandlik 936, dark da 1024 |
| T-28 | Add Ticket | `2146:35984` / `2146:38704` (contact support variantlari) | `2216:33414` / `2216:42810` | ~ alohida nomlanmagan |
| T-29 | Notifications | `2156:42683` (+`2150:41614`) | `2196:101073` (+`2196:100325`) | to'liq mos |
| T-30 | Add DVIR (3 qadam) | ❌ **yo'q** | ❌ **yo'q** | umuman chizilmagan |
| T-31 🎨 | PIN entry | ❌ | ❌ | oldindan ma'lum |
| T-32 🎨 | Pending edits | ❌ | ❌ | oldindan ma'lum |
| T-33 🎨 | Unidentified claim | ❌ | ❌ | oldindan ma'lum |
| T-34 🎨 | Chat | ❌ | ❌ | oldindan ma'lum |
| T-35 🎨 | Sync status / conflicts | ❌ | ❌ | oldindan ma'lum |

## 7.3 Registrda T-ID si yo'q, lekin chizilgan planshet freymlari

| Nomi | Light | Dark | O'lcham | Mobil ekvivalenti |
|---|---|---|---|---|
| Login / Email & Password | `1517:54359` | `2218:52479` | 1366×1024 | M-02 |
| Leave truck | `1311:1886` | `2218:52577` | 1366×1024 | M-03 |
| Privacy policy | `2568:25226` | `2572:20338` | light **1366×1421** / dark 1366×1024 | M-52 |
| Terms of Use | `2570:19499` | `2572:21953` | light **1366×1421** / dark 1366×1024 | M-53 |
| Hours of service (clicked) | `2156:49118` | — | 1366×1024, **`visible:false`** | T-01 holati? |

## 7.4 Planshet — dizaynerga savollar

1. **9 ta T-ko'rinish umuman chizilmagan:** T-05, T-06, T-13, T-16, T-17, T-30 (+ oldindan ma'lum T-31…T-35).
   T-16 (Log Report DVIR) va T-30 (Add DVIR) — **butun DVIR oqimi planshetda yo'q**. Chizilishi kerakmi
   yoki planshetda DVIR mobil oynasida ochiladimi?
2. **T-25 va T-26 faqat dark temada** bor (`2190:90626`, `2195:97628`); light juftligi yo'q.
   **T-08 faqat light temada** (`1517:53372`); dark juftligi yo'q.
3. **T-02 drawer light/dark assimetriyasi:** dark da `menu` mustaqil 1366×1024 freym, light da faqat
   314×1024 `Group 39572`. Light da drawer ochilgan to'liq ekran holati chizilmagan.
   Qo'shimcha: `Group 39572` ning `absoluteRenderBounds` = **1125×1024** (soya o'ngga 811 px chiqib ketgan) —
   eksport shu sababli kengaygan; kontent bounding box 314×1024.
4. **T-27 balandligi:** light `1366×936`, dark `1366×1024`. 88 px farq — ataylabmi?
5. **T-11 «Certify (date selected)»** faqat dark da (`2190:56075`, `2190:58738`); light da yo'q.
6. **Yagona breakpoint:** hamma freym 1366×1024. TZ §11.11 planshet uchun 1024/1194 ni ham ko'zda tutsa,
   ular uchun dizayn manbai **yo'q** — 1366 dan proporsional moslash kerak bo'ladi.
7. Arxiv sectionlar (`Home`, `Section 1`, `Section 3`) o'chirilsinmi? Ular `Log Report / DVIR`,
   `Change Status / Add notes`, `Location error` kabi **joriy sectionda yo'q** freymlarni saqlaydi —
   ya'ni ba'zi ekranlar chizilgan, keyin joriy iteratsiyaga ko'chirilmagan.
