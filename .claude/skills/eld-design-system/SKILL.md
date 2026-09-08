---
name: eld-design-system
description: ONEBOOK ELD mobil dizayn tizimi — ranglar, tipografika, spacing/radius, komponentlar kutubxonasi, navigatsiya, sana formatlari, telefon/planshet profillari. Ekran yoki UI komponent yozayotganda majburiy.
---

# ELD Mobil — dizayn tizimi (tz-mobile §11.0, §3 · design-inventory A.1–A.8)

Manba: `core/ui/tokens.dart`, `core/ui/typography.dart`, `core/ui/components/`. Dizaynda 0 ta Figma text style — token tizimi **shu skillda** qurilgan.

## 1. Ranglar — `core/ui/tokens.dart`
| Token | Light | Dark |
|---|---|---|
| `primary` | `#B7002C` | `#B7002C` |
| `primaryLight` | `#EFF4FB` | `#EFF4FB` |
| `bg` | `#FCFCFD` | `#1B222C` |
| `surface` (karta) | `#FFFFFF` | `#303E4B` |
| `surfaceAlt` (jadval sarlavhasi) | `#F2F4F7` | `#233040` |
| `sidebar` / `drawer` | `#FFFFFF` | `#233040` |
| `stroke` | `#E5E7EB` | `#52565F` |
| `textPrimary` | `#23262F` (Neutral 9) | `#FCFCFD` (Neutral 1) |
| `textSecondary` | `#777E90` (Neutral 6) | `#B1B5C3` (Neutral 5) |
| `textDisabled` | `#B1B5C3` | `#777E90` |
| `success` / `successBg` / `successDark` | `#2FA766` / `#C5EFD8` / `#103923` | bir xil |
| `warning` / `warningBg` / `warningDark` | `#F6BA47` / `#FCEAC8` / `#7B5D24` | bir xil |
| `error` / `errorBg` / `errorDark` | `#E2464A` / `#F9DADB` / `#5A1C1E` | bir xil |
| `hosBreak` / `hosDrive` / `hosShift` / `hosCycle` | `#F6BA47` / `#2FA766` / `#466FF7` / `#B7002C` | bir xil |
| `gridLine` (log grid) | `#466FF7` | bir xil |
| `deco*` (7 ta) | Pink `#EE4E68` · Teal `#30B0C7` · Green `#47BB75` · Purple `#7E5EF7` · Orange `#F5693D` · Yellow `#F7CB46` · Blue `#466FF7` | bir xil |
| `scrim` | `#1C1E24` @ 35 % | bir xil |

Neutral (11 pog'ona): `#FCFCFD · #F4F5F6 · #E6E8EC · #D6D8E0 · #B1B5C3 · #777E90 · #3F4352 · #353945 · #23262F · #1C1E24 · #18191D`.
**M81 [MUST]** State, Decorative va HOS ranglari **ikkala temada bir xil**; faqat `bg`, `surface`,
`surfaceAlt`, `sidebar`, `stroke`, `text*` almashadi (status badge, HOS halqa, `Violation:` satri — o'zgarmas).
**M82 [MUST]** Warning = **`#F6BA47`** kanonik; dizayndagi `#F9B385` yozuvi xato (RGB 246,176,71), #C-16.

## 2. Tipografika — `core/ui/typography.dart`
**IBM Plex Sans** barcha matn; **Product Sans** faqat `display1`/`display2` (splash logotipi).

| Token | Shrift · weight | px |
|---|---|---|
| `display1` / `display2` | Product Sans Bold | 48 / 40 |
| `h1` · `h2` · `h3` · `h4` | IBM Plex Sans Bold | 48 · 40 · 32 · 24 |
| `body1` · `body2` | SemiBold · Medium | 26 |
| `body3` · `body4` | Bold · Regular | 24 |
| `body5` · `body6` | Bold · Regular | 20 |
| `body8` · `body9` · `body10` | Bold · Medium · Regular | 18 |
| `body11` · `body12` · `body13` | Bold · Medium · Regular | 16 |
| `body14` / `body15` | Medium / Regular | 14 |
| `body16` / `body17` | Regular / Regular | 12 / 10 |

**M83 ❓** Product Sans litsenziyasi bo'lmasa `display1/2` → IBM Plex Sans Bold (`_displayFamily` konstantasi).
**M84 [MUST]** `body7` = `body6` (Regular 20, dublikat) — **`body6` kanonik**, `body7` faqat
`@Deprecated` alias, yangi kodda ishlatilmaydi.
**M85 [MUST]** `MediaQuery.textScaler` `clamp(0.85, 1.3)`; 1.3 da layout buzilmasligi **golden testda** tekshiriladi.

## 3. Spacing, radius, soya
- **Spacing** (4 pt bazasi): `4 · 8 · 12 · 16 · 24 · 32 · 48` dp. Ekran padding: telefon `16`, planshet `24`; kartalar orasi `12`.
- **Radius**: karta va dropdown — **27.25**; tugma — `12`; input — `12`; chip/badge — `999` (stadion).
- **Soya**: bitta uslub `Carts Dropdown` (`DROP_SHADOW`); dark temada opacity **2× pasaytiriladi**.
- ✅ **M86** — shu to'plam kanonik; o'zboshimcha radius/spacing qiymati qo'shish taqiqlanadi.

## 4. Komponentlar — `core/ui/components/`
| Komponent | Qoida |
|---|---|
| `AppBarPrimary` | Sarlavha markazda `OneBook ELD`, fon `surface`, ostida 1 px `stroke`; balandligi 56 dp |
| `AppButton.primary` | Fon `primary`, matn oq, radius 12, balandlik telefon 48 / planshet 56, haydash rejimida ≥64 |
| `AppButton.secondary` | Fon `surface`, 1 px `stroke` chegara, matn `textPrimary`, radius 12 |
| `AppButton.text` | Fonsiz, matn `primary`, minimal teginish maydoni baribir 48×48 dp |
| `AppTextField` | Radius 12, 1 px `stroke`, fokusda `primary`, xato holatida `error` + ostida `body16` xabar |
| `AppChip` | Radius 999, `body16`, tanlanganda fon `primary` + oq matn, aks holda `surfaceAlt` |
| `StatusBadge` | Radius 999, fon `*Bg`, matn `*Dark` (success/warning/error), `body16` Medium |
| `HosLinearIndicator` | **Telefonda** 4 ta: BREAK/DRIVE/SHIFT/CYCLE, rang `hos*`, o'ng tomonda `HH:mm` |
| `HosRingIndicator` | **Planshetda** 4 ta halqa, markazda `HH:mm`, ostida bo'lim nomi; chiziq qalinligi 12 dp |
| `DutyGrid24h` | 24 soatlik duty grid, chiziq rangi `gridLine` `#466FF7`, gorizontal scroll ichida |
| `DateStrip8Day` | 8 kun, format `EEE dd`, faol kun `primary` fon + oq matn, radius 12 |
| `EmptyState` | Illyustratsiya + sarlavha + tavsif (+ ixtiyoriy amal tugmasi); matnlar dizayndan olinadi |
| `ErrorState` | 🎨 Ikonka + xabar + `Retry` tugmasi; barcha yuklash xatolarida yagona widget |
| `LoadingSkeleton` | 🎨 Ro'yxat/karta uchun shimmer; tugmalarda inline spinner; sahifada pull-to-refresh |
| `AppBottomSheet` | **Faqat telefonda**; radius yuqori burchaklarda 27.25, drag handle 4×32 dp |
| `TabletModal` | **Faqat planshetda**; markazda, tepa qatori `Cancel · <sarlavha> · <amal>` |
| `ConfirmDialog` | Sarlavha + savol matni + `Cancel` / `Confirm`; destruktiv amalda `Confirm` rangi `error` |
| `SignaturePad` | Imzo maydoni, `Clear` / `Save`; chiqish PNG + `signed_at`; balandlik ≥200 dp |
| `SyncIndicator` | App bar'dagi yangilash ikonkasi; holatlar: idle / syncing (aylanish) / error (`error` nuqta) |
| `BannerStrip` | Tepada 32 dp bir qatorli banner (offline, ELD uzilgan, sertifikatlanmagan kunlar) |

## 5. Umumiy patternlar
| Pattern | Qoida |
|---|---|
| Yuklanish | Dizaynda yo'q → `LoadingSkeleton` (ro'yxat), tugmada inline spinner, pull-to-refresh |
| Xato | Dizaynda umumiy xato ekrani yo'q → `ErrorState` (ikonka + xabar + `Retry`) |
| Bo'sh holat | Dizayn matnlari saqlanadi: `No DVIR Found` / `There is no data to show you right now`; `No Notifications Yet` / `Stay tuned! Important updates and alerts will appear here.`; `No Ticket Added Yet` / `Start to add your first ticket by clicking button below.` |
| Tasdiqlash modali | Sarlavha (`Are you absolutely sure?`) + savol + `Cancel` / `Confirm` |
| Snackbar/Toast | 3 s, ekran pastida; **haydash rejimida ko'rsatilmaydi** |
| Offline banner | Tepada 32 dp, kulrang (`surfaceAlt`): `Offline — <n> records queued` |
| Ro'yxat ekrani | Sarlavha + asosiy amal → tab qatori → filtr paneli → ro'yxat → sahifalash |

## 6. Navigatsiya
**M87 ✅** **B tartib (pastki tab navigatsiya) kanonik**; A ning HOS halqalari planshetga o'tadi.
Telefonda chiziqli indikator (393 dp da halqa kichik), planshetda halqa. Status tugmalari A dan **3 ta**
(`Off Duty · Sleeper Berth · On Duty`) — B ning 2 tugmasi yetarli emas (M52).
Drawer (hamburger) — faqat ikkilamchi bandlar: Profile, Permissions, Diagnosis, Support, Legal, Logout.
**M88 [MUST]** Home **scroll'siz** ko'rinishi shart: ELD banneri · status + taymer · 4 ta HOS indikatori · status tugmalari (Trip Details, Certify, log grid — scroll ostida).

**M89 ✅ Pastki tab bar — 4 bo'lim:**
| Tab | Ikonka | Marshrut | Badge |
|---|---|---|---|
| Home | uy | `/home` | — |
| Logs | hujjat/grid | `/logs` (`Main` · `Logs` · `DVIR` sub-tab) | sertifikatlanmagan kunlar soni |
| Chat | xabar | `/chat` | o'qilmagan xabarlar |
| Profile | avatar | `/profile` | ruxsat ogohlantirishi (qizil nuqta) |

`Notifications` — app bar'dagi qo'ng'iroq ikonkasi, **tab emas**. Tezkor amallar qatori (Home):
`Inspection Report · Log Report · Co-driver · Leave Truck`.
**M90 [MUST]** Brend nomi hamma joyda **`OneBook ELD`**; `OneBookELD` / `ONEBOOK ELD` ishlatilmaydi.

**App bar tarkibi:**
- Telefon: `hamburger` · **`OneBook ELD`** · `qo'ng'iroq (badge)` · `xat/chat` · `yangilash (sync)`.
- Planshet: chapda `ELD · Connected`, markazda logotip, o'ngda `xat` · `qo'ng'iroq` · `yangilash` · `tema`.
- Co-driver faol bo'lsa `ActiveDriverBanner` (`primary`) — faol haydovchi ismi doim ko'rinadi (M10).

## 7. Sana/vaqt formatlari
| Kontekst | Format | Namuna |
|---|---|---|
| Sana tasmasi (8 kun) | `EEE dd` | `Fri 07` |
| Ro'yxat sarlavhasi / guruh | `EEE, MMM d` | `Tue, May 20` |
| To'liq sana-vaqt | `MMM d, yyyy · hh:mm a` | `May 28, 2025 · 02:24 PM` |
| Log event vaqti | `hh:mm:ss a` | `02:03:23 AM` |
| Davomiylik / hisoblagich | `HH:mm:ss` | `22:02:21` |
| HOS indikatori | `HH:mm` | `08:00` |
| Bildirishnoma vaqti | nisbiy <24 h, keyin `MMM d, hh:mm a` | `2h ago` / `May 28, 10:04 AM` |
| Koordinata | `.` o'nlik ajratgich | `23.97464553778` |

**M91 ✅** Dizayndagi 6 xil variant shu jadvalga birlashtiriladi (#B-19 / #C-14).**M92 [MUST]** Barcha formatlar `intl` + **`en_US`**; hafta kunlari 3 harfli (`Mon…Sun`, `Tues`/`Thurs` rad, #B-11);
bo'sh qiymat — **`N/A`** (#B-10).

## 8. Ikki qurilma profili
**M6/M7 [MUST]** Adaptivlik **`DeviceProfile`** bo'yicha (`shortestSide >= 600 dp` → `tablet`), `MediaQuery.width`
bo'yicha **emas**. Har ekranda 1 ta `Controller` + 2 ta `View` (`PhoneView`, `TabletView`).

| Jihat | Telefon (`phone`) | Planshet (`tablet`) |
|---|---|---|
| Referens o'lcham | 393×852 dp | 1366×1024 dp (landshaft) |
| Orientatsiya | faqat portret | faqat landshaft |
| Navigatsiya | pastki tab (4) + drawer | yagona ekran + modallar + drawer |
| Bosh ekran | vertikal scroll, above-the-fold: status + HOS | uch ustunli, scroll yo'q |
| HOS ko'rsatkichi | 4 ta `HosLinearIndicator` | 4 ta `HosRingIndicator` (katta) |
| Log grid | alohida `Logs` tabi | doim ekran pastida |
| Amallar | Home'dagi tezkor amallar qatori | o'ng ustundagi `Actions` paneli |
| Modal | to'liq ekran sahifa yoki `AppBottomSheet` | `TabletModal` (markazda) |
| Tema almashtirish | `Profile › Dark mode` toggle | app bar'dagi tema ikonkasi |
| Teginish maydoni (M8) | ≥48×48 dp | ≥56×56 dp; haydash rejimida ≥64 dp |
| Kiosk rejimi | yo'q | `[SHOULD]` lock task mode, chiqish 6 xonali PIN bilan |

## 9. Qat'iy taqiqlar
1. **Hard-coded rang YO'Q** — `Color(0x…)` / `Colors.*` faqat `core/ui/tokens.dart` ichida; boshqa joyda `context.colors.<token>` (grep bilan tekshiriladi).
2. **Hard-coded matn YO'Q** — foydalanuvchiga ko'rinadigan har matn `context.l10n.*` (ARB).
3. **Hard-coded `TextStyle` YO'Q** — faqat `context.text.<token>` (`body13`, `h4`, …).
4. Spacing/radius uchun sehrli raqam yo'q — `Spacing.s16`, `Radii.card`.
5. Qurilma turi `MediaQuery.size` dan aniqlanmaydi — faqat `DeviceProfile` (M7).
6. Dark tema uchun alohida widget nusxasi yozilmaydi — faqat token almashadi.
