---
name: eld-screens
description: ONEBOOK ELD mobil/planshet ekranlari registri — 58 telefon + 35 planshet ekrani, ularning ID, marshrut, modul papkasi va tz-mobile.md qator raqamlari. Ekran implementatsiya qilishdan oldin majburiy — ekran ID, marshrut va TZ qator raqamini topish uchun.
---

# Ekranlar registri (tz-mobile.md §11)

Bu fayl — **indeks**, spetsifikatsiya emas. Bu yerda ekranning **qayerdaligi** bor,
**qanday ishlashi** yo'q. Tafsilot faqat `tz-mobile.md` da.

## Ish tartibi [MUST]
1. Ekran ID sini shu registrdan top (`M-nn` yoki `T-nn`).
2. Faqat o'sha ekran qatorlarini o'qi: `sed -n '<qatorlar>p' tz-mobile.md`.
3. Qo'shimcha: `flutter-conventions` (qatlamlar) + `eld-design-system` (tokenlar, komponentlar).
4. **Butun `tz-mobile.md` ni o'qish TAQIQLANADI** (~2650 qator, kontekstni yeydi).
   `grep -n` bilan qidirish mumkin, `cat`/to'liq `Read` — yo'q.
5. Ekran ID va marshrut **aynan shu jadvaldan** olinadi; chetlashish = TZ CR talab qiladi.

🎨 = dizaynda **yo'q**, TZ da yangi qo'shilgan ekran (Figma referensi yo'q, §21.6 dan quriladi).

⚠️ TZ ning §9/§10 bo'limlarida eski ID lar uchraydi (`M-10`, `M-13`, `M-14`, `M-36 Diagnosis`).
**Kanonik ID — faqat §11.1 registri**, ya'ni quyidagi jadval.

## 1. Mobil (telefon) ekranlari — 58 ta

| ID | Nomi | Modul (`lib/features/...`) | go_router marshruti | tz-mobile.md qatorlari |
|---|---|---|---|---|
| M-01 | Splash | `auth` | `/` | 1185–1187 |
| M-02 | Login | `auth` | `/login` | 1188–1198 |
| M-03 | Leave truck / Return to truck | `auth` | `/paused` | 1199–1202 · 216–248 |
| M-04 🎨 | PIN entry | `auth` | `/pin` | 1203–1205 · 1895–1908 |
| M-05 🎨 | Accept invitation (parol + PIN) | `auth` | `/invite` | 1206–1208 |
| M-06 🎨 | Forgot password | `auth` | `/forgot` | 249–252 |
| M-07 🎨 | Reset password | `auth` | `/reset` | 249–252 |
| M-08 🎨 | Two-factor (TOTP) | `auth` | `/2fa` | 1209–1213 |
| M-09 | **Home** | `home` | `/home` | 1216–1243 |
| M-10 | Drawer (yon menyu) | `home` | — (Scaffold drawer) | 1244–1250 |
| M-11 | Edit documents (Trip Details) | `home` | modal | 1251–1253 |
| M-12 | Change duty status | `duty_status` | `/duty/change` | 751–787 |
| M-13 | Quick notes | `duty_status` | modal | 788–797 |
| M-14 | Location inaccurate | `duty_status` | dialog | 770–787 |
| M-15 | Drive mode (focused) | `drive_mode` | `/drive` | 821–838 |
| M-16 | Idle prompt (5 min) | `drive_mode` | dialog | 839–857 |
| M-17 | ELD not connected | `eld_device` | dialog | 894–905 · 876–881 |
| M-18 | Permissions | `eld_device` | `/permissions` | 906–929 · 1927–1937 |
| M-19 🎨 | ELD device connect/scan | `eld_device` | `/eld` | 930–964 |
| M-20 | Co-driver switch confirm | `auth` (co-driver) | dialog | 216–248 |
| M-21 | Select shipping document (Myself/Co-driver) | `auth` (co-driver) | modal | 216–248 |
| M-22 | Log Report — Main | `logs` | `/logs?tab=main` | 1258–1272 |
| M-23 | Log Report — Logs (grid) | `logs` | `/logs?tab=logs` | 1273–1283 |
| M-24 | Log Report — DVIR | `logs` | `/logs?tab=dvir` | 1290–1294 |
| M-25 | Log event detail | `logs` | bottom-sheet | 1284–1289 |
| M-26 🎨 | **Pending edits** (ro'yxat) | `log_edits` | `/logs/pending-edits` | 1692–1696 · 1679–1691 |
| M-27 🎨 | **Pending edit detail** (Approve/Reject) | `log_edits` | `/logs/pending-edits/:id` | 1697–1730 |
| M-28 🎨 | **Unidentified driving claim** | `unidentified` | `/unidentified` | 1296–1316 |
| M-29 | Certify — kunlar ro'yxati | `certify` | `/certify` | 1626–1636 |
| M-30 | Certify — Sign | `certify` | `/certify/:date/sign` | 1637–1665 |
| M-31 | Certify — Not Ready | `certify` | holat (M-29 ichida) | 1610–1625 |
| M-32 | Add DVIR (forma) | `dvir` | `/dvir/new` | 1355–1366 · 1319–1354 |
| M-33 | Defect picker (truck/trailer) | `dvir` | `/dvir/new/defects` | 1367–1378 |
| M-34 | DVIR review + signature | `dvir` | `/dvir/new/confirm` | 1379–1386 |
| M-35 | DVIR details | `dvir` | `/dvir/:id` | 1405–1414 |
| M-36 🎨 | **Previous defects certification** | `dvir` | dialog | 1387–1404 |
| M-37 | Inspection Report (3 amal) | `inspection` | `/inspection` | 1417–1426 |
| M-38 | Begin inspection (kiosk) | `inspection` | `/inspection/view` | 1427–1443 · 1974–1979 |
| M-39 🎨 | Exit inspection (PIN) | `inspection` | dialog | 1427–1443 · 1895–1900 |
| M-40 | Send via email | `inspection` | modal | 1444–1446 |
| M-41 | Send the file (DOT) | `inspection` | modal | 1447–1457 |
| M-42 | Chat | `chat` | `/chat` | 1502–1507 · 1731–1779 |
| M-43 | Notifications | `notifications` | `/notifications` | 1508–1515 · 1780–1830 |
| M-44 | Profile | `profile` | `/profile` | 1460–1464 |
| M-45 | Settings | `settings` | `/profile/settings` | 1465–1467 |
| M-46 | Diagnosis of device | `diagnostics` | `/profile/diagnosis` | 1468 · 965–996 |
| M-47 | Check network | `diagnostics` | `/profile/network` | 1469–1470 · 965–977 |
| M-48 | Give feedback | `feedback` | `/profile/feedback` | 1471–1477 |
| M-49 | Contact support (forma) | `support` | `/support/new` | 1478–1482 |
| M-50 | Support & Helpdesk (ro'yxat) | `support` | `/support` | 1483–1488 |
| M-51 🎨 | Support ticket thread | `support` | `/support/:id` | 1489–1490 |
| M-52 | Privacy Policy | `legal` | `/legal/privacy` | 1491–1499 |
| M-53 | Terms of Use | `legal` | `/legal/terms` | 1491–1499 |
| M-54 🎨 | **Sync status** | `core/sync` + `settings` | `/sync` | 1516–1521 |
| M-55 🎨 | **Sync conflicts** | `core/sync` + `settings` | `/sync/conflicts` | 1516–1521 |
| M-56 🎨 | **Signed out elsewhere** | `auth` | `/signed-out` | 1522 |
| M-57 🎨 | **Force update** | `core/router` | `/update` | 1523 |
| M-58 🎨 | Sessions (my devices) | `auth` | `/profile/sessions` | 1524 |

**Jami: 58 ekran, shundan 15 tasi 🎨** (M-04…M-08, M-19, M-26…M-28, M-36, M-39, M-51, M-54…M-58 —
ro'yxatda 🎨 belgisi bilan; Figma ID lari faqat §11.1 jadvalida, 1119–1174 qatorlar).

## 2. Planshet (kabina) ko'rinishlari — 35 ta

Planshet = **bitta asosiy ekran + modallar**. `Controller`/`domain` telefon bilan **umumiy** (M7),
faqat `View` boshqa (`presentation/screens/tablet/`). Umumiy qoidalar: 1530–1533, 1571–1605.

| ID | Nomi | Turi | Mobil ekvivalenti | tz-mobile.md qatorlari |
|---|---|---|---|---|
| T-01 | Home / Full screen | ekran | M-09 | 1571–1596 |
| T-02 | Yon menyu (drawer) | panel | M-10 | 1536 |
| T-03 | Edit Documents | modal | M-11 | 1537 |
| T-04 | Change Duty Status | modal | M-12 | 1538 |
| T-05 | Quick Notes | modal | M-13 | 1539 |
| T-06 | Location error | modal | M-14 | 1540 |
| T-07 | Switch co-driver | modal | M-20 | 1541 |
| T-08 | Select Shipping Document | modal | M-21 | 1542 |
| T-09 | Log Detail | modal | M-25 | 1543 |
| T-10 | Log panel (kengaytirilgan grid) | panel | M-23 | 1544 |
| T-11 | Certify (Last 8 days) | modal | M-29 | 1545 · 1599–1602 |
| T-12 | Sign | modal | M-30 | 1546 |
| T-13 | Not Ready | holat | M-31 | 1547 |
| T-14 | Log Report — Main | ekran | M-22 | 1548 |
| T-15 | Log Report — Logs | ekran | M-23 | 1549 |
| T-16 | Log Report — DVIR | ekran | M-24 | 1550 |
| T-17 | Inspection Report | ekran | M-37 | 1551 |
| T-18 | Send via Email | modal | M-40 | 1552 |
| T-19 | Send file to DOT | modal | M-41 | 1553 |
| T-20 | Begin inspection (kiosk) | ekran | M-38 | 1554 · 1974–1979 |
| T-21 | Check Network | modal | M-47 | 1555 |
| T-22 | Permissions | modal | M-18 | 1556 |
| T-23 | Diagnosis of Device | modal | M-46 | 1557 |
| T-24 | Feedback | modal | M-48 | 1558 |
| T-25 | Drive-focused | ekran | M-15 | 1559 |
| T-26 | Idle prompt (5 min) | modal | M-16 | 1560 |
| T-27 | Contact Support (jadval) | ekran | M-50 | 1561 |
| T-28 | Add Ticket | modal | M-49 | 1562 |
| T-29 | Notifications | modal/panel | M-43 | 1563 |
| T-30 | Add DVIR (3 qadam) | modal | M-32…M-34 | 1564 |
| T-31 🎨 | PIN entry | modal | M-04 | 1565 |
| T-32 🎨 | Pending edits | modal | M-26 / M-27 | 1566 |
| T-33 🎨 | Unidentified claim | modal | M-28 | 1567 |
| T-34 🎨 | Chat | panel | M-42 | 1568 |
| T-35 🎨 | Sync status / conflicts | modal | M-54 / M-55 | 1569 |

**Jami: 35 ko'rinish, shundan 5 tasi 🎨** (T-31…T-35).

## 3. Modul → papka → bosqich xaritasi

| Modul papkasi | Ekranlar | Bosqich (`tz-mobile.md` C.2) |
|---|---|---|
| `lib/features/auth` | M-01…M-08, M-20, M-21, M-56, M-58 | 0 (auth), 10 (co-driver) — 2293–2318 |
| `lib/core/ui` | (ekran yo'q — tokenlar, tema, profillar) | 1 — 2319–2341 |
| `lib/core/db`, `lib/core/sync` | M-54, M-55 | 2 va 5 — 2342–2362, 2415–2435 |
| `packages/hos_engine` | (ekran yo'q) | 3 🔒 — 2363–2390 |
| `lib/features/home` | M-09, M-10, M-11 | 4 — 2391–2414 |
| `lib/features/duty_status`, `drive_mode` | M-12…M-16 | 4 — 2391–2414 |
| `lib/features/eld_device` | M-17, M-18, M-19 | 6 — 2436–2457 |
| `lib/features/diagnostics` | M-46, M-47 | 6 — 2436–2457 |
| `lib/features/logs` | M-22…M-25 | 7 — 2458–2480 |
| `lib/features/certify` | M-29, M-30, M-31 | 7 — 2458–2480 |
| `lib/features/log_edits` | M-26, M-27 | 7 — 2458–2480 |
| `lib/features/unidentified` | M-28 | 7 — 2458–2480 |
| `lib/features/dvir` | M-32…M-36 | 8 — 2481–2502 |
| `lib/features/inspection` | M-37…M-41 | 8 — 2481–2502 |
| `lib/features/chat` | M-42 | 9 — 2503–2523 |
| `lib/features/notifications` | M-43 | 9 — 2503–2523 |
| planshet (`screens/tablet/`) | T-01…T-35 | 10 — 2524–2545 |
| `lib/features/profile`, `settings`, `support`, `feedback`, `legal` | M-44, M-45, M-48…M-53 | 11 — 2546–2572 |
| `lib/core/router` | M-57 | 0 / 11 |

**M-67:** `Maintenance` moduli bu bosqichda **yo'q** (drawer'da ham bandi yo'q) — 882–891.

## 4. Ekran yozishdan oldingi chek-list
- [ ] ID topildi, marshrut jadvaldan aynan ko'chirildi (yangi marshrut ixtiro qilinmadi).
- [ ] `sed -n '<qatorlar>p' tz-mobile.md` bilan **faqat o'sha ekran** o'qildi.
- [ ] 🎨 ekran bo'lsa — Figma yo'q, §21.6 (2217–2245) va TZ matni yagona manba.
- [ ] `presentation → domain → data` qatlam qoidasi buzilmadi (`flutter-conventions`).
- [ ] Telefon + planshet ekvivalenti bor bo'lsa — `Controller` umumiy, faqat `View` ajratildi.
- [ ] Ikki tema (light/dark) + golden test qo'shildi.
