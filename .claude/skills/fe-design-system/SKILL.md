---
name: fe-design-system
description: ELD Admin Panel frontend uchun dizayn tizimi (ranglar, tipografika, spacing, radius/soyalar, ikonkalar, UI komponentlar ro'yxati, tema) va i18n/sana-vaqt/birlik konvertatsiya qoidalari. Yangi UI komponent yozishda, Tailwind token qo'shishda, sana/vaqt yoki masofa/tezlik/harorat/hajm/og'irlik qiymatini formatlashda yoki i18n kalit yaratishda shu skill'ni ishlat.
---

# FE Design System — ELD Admin Panel

Manba ustuvorligi: `design-inventory.md` A bo'limi (Figma o'lchovlari) → `tz.md` §1.2. Farq bo'lsa — inventar ustun, farq §16 (nomuvofiqliklar registri) da qayd etiladi.

## 1. Ranglar [MUST]

### Brend va fon
| Token | HEX | Ishlatilishi |
|---|---|---|
| `primary` | `#B7002C` | brend panel, asosiy tugma, faol nav + ostki chiziq, HOS CYCLE halqasi, faol sahifa raqami |
| `primary-hover` | `#9A0025` | hover (primary −10% lightness) |
| `bg` | `#FCFCFD` | asosiy fon |
| `surface` | `#FFFFFF` | kartalar, jadval satrlari |
| `surface-muted` | `#F2F4F7` | jadval sarlavhasi foni |
| `stroke` | `#E5E7EB` | chegaralar |
| `light` | `#EFF4FB` | yumshoq aksent fon |

### Neutral (11 pog'ona)
`50 #FCFCFD` · `100 #F4F5F6` · `200 #E6E8EC` · `300 #D6D8E0` · `400 #B1B5C3` · `500 #777E90` · `600 #3F4352` · `700 #353945` · `800 #23262F` · `900 #1C1E24` · `950 #18191D`

### Holat ranglari (fon / asosiy / to'q)
| Holat | `-bg` | `-base` | `-dark` |
|---|---|---|---|
| Success | `#C5EFD8` | `#2FA766` | `#103923` |
| Warning | `#FCEAC8` | `#F6BA47` | `#7B5D24` |
| Error | `#F9DADB` | `#E2464A` | `#5A1C1E` |

**Muhim:** Warning asosiy rang **`#F6BA47`** (dizaynda `#F9B385` yozilgan bo'lsa ham — RGB `246,176,71` = `#F6BA47`, xato hex yozuvi). Kontrast uchun matnda `warning-dark` ishlatiladi, `warning-base` oq fonda matn uchun yetarli emas (bog'liq: fe-a11y F217).

### Dekorativ (7 rang — badge, diagramma)
Pink `#EE4E68` · Teal `#30B0C7` · Green `#47BB75` · Purple `#7E5EF7` · Orange `#F5693D` · Yellow `#F7CB46` · Blue `#466FF7`

### Semantik rang xaritasi (kodda to'g'ridan-to'g'ri hex ishlatilmaydi — faqat token)
| Ma'no | Token |
|---|---|
| Duty status `DR` / DRIVE halqasi | `success-base` |
| Duty status `OFF` | `neutral-500` |
| Duty status `SB` | `decorative-purple` |
| Duty status `ON` | `warning-base` |
| `OFF (PC)` | `neutral-500` + shtrix pattern |
| `ON (YM)` | `warning-base` + shtrix pattern |
| BREAK halqasi | `warning-base` |
| SHIFT halqasi / log grid chizig'i | `decorative-blue #466FF7` |
| CYCLE halqasi | `primary` |
| `Online` · `Completed` · `Certified` · `Signed` | `success-*` |
| `Offline` · `N/A` | `neutral-400` |
| `Disconnected` · `Malfunction` · `Violation` · `Not Signed` · `Overdue` · `Not Found` | `error-*` |
| `Warning` satri · `Ongoing` · `Due` | `warning-*` |
| KPI: Total Drivers ko'k / Total Units to'q sariq / Disconnected ELD kulrang / Violations qizil / Status kartasi sariq | `decorative-blue` / `decorative-orange` / `neutral-500` / `error-base` / `warning-base` |

**Qaror:** `Ongoing` → `warning` (sariq, dizaynda xato qizil chizilgan edi), `not_completed` → `error`, `completed` → `success`, `cancelled` → `neutral`.

## 2. Tipografika [MUST]

- **IBM Plex Sans** — asosiy (400/500/600/700). **Product Sans** — faqat Display darajasi (litsenziya ochiq savol — mavjud bo'lmasa fallback **IBM Plex Sans 700**).
- Shriftlar **lokal `woff2`** (`public/fonts/`), `font-display: swap`. Tashqi CDN so'rovi yo'q (CSP).

| Daraja | O'lcham / og'irlik | Ishlatilishi |
|---|---|---|
| Display 1 / 2 | 48 / 40 Product Sans Bold | login sahifasi, bo'sh holat sarlavhalari |
| Heading 1–4 | 48 / 40 / 32 / 24 Bold | H3 (32) — sahifa sarlavhasi, H4 (24) — modal sarlavhasi |
| Body-lg | 16 / 400 | asosiy matn |
| Body | 14 / 400 | jadval satri, forma qiymati |
| Body-sm | 12 / 400 | yordamchi matn, jadval sarlavhasi (uppercase), badge |
| Body-xs | 10 / 400 | tooltip, timeline belgilari |

Shkala shu 7 darajaga normallashtirilgan (Figma'dagi `Body 6`/`Body 7` dublikatlari yo'q qilingan).
Jadval sarlavhasi: `Body-sm`, `font-medium`, `uppercase`, `tracking-wide`, `neutral-500`, fon `surface-muted`.

## 3. Spacing va grid [MUST]

- Grid: **12 ustun, gutter 24px, maksimal kontent kengligi 1440px, sahifa padding 40px**.
- Spacing shkala (4pt): `0 · 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64` (Tailwind default bilan mos).
- `Dashboard with Sidebar` gridi (280px sidebar) **eskirgan** — amaldagi panelda sidebar yo'q, ishlatilmaydi.

## 4. Radius va soyalar [MUST]

| Token | Qiymat | Izoh |
|---|---|---|
| `shadow-card` | `0 4px 27.25px rgba(28,30,36,0.08)` | dizayndagi `Carts Dropdown` blur qiymati |
| `shadow-dropdown` | `0 8px 27.25px rgba(28,30,36,0.12)` | flyout, amal menyusi |
| `shadow-modal` | `0 20px 48px rgba(28,30,36,0.20)` | modal |
| `radius-sm` | 4px | badge, checkbox |
| `radius-md` | 8px | input, tugma, select |
| `radius-lg` | 12px | karta, jadval konteyneri |
| `radius-xl` | 16px | modal, KPI kartasi |
| `radius-full` | 9999px | avatar, halqa, status nuqtasi |

## 5. Ikonkalar [MUST]

`lucide-react` — line uslub, 24×24 grid, `stroke-width 1.5`. Tree-shaking bilan bundle'ga faqat ishlatilgan ikonkalar kiradi. Quyosh/oy (tema almashtirgich) ikonkasi olib tashlanadi (§7).

## 6. Komponent kutubxonasi [MUST] (`src/components/ui/`)

| Komponent | Variantlar / holatlar |
|---|---|
| `Button` | `primary`·`secondary`(oq+stroke)·`ghost`·`danger`; `sm/md/lg`; `loading`, `disabled`, `iconLeft/iconRight`, `fullWidth` |
| `IconButton` | kvadrat, `aria-label` majburiy |
| `Input` | `text/number/password/search`; prefix/suffix ikonka, `error`, `hint`, `required`, `disabled`, `readOnly`, `maxLength` hisoblagichi |
| `Textarea` | belgilar hisoblagichi (Notes ≤ 60) |
| `Select` | bitta tanlov, qidiruv bilan (combobox), `clearable`, async yuklash |
| `MultiSelect` | `Select All`, chip'lar bilan (IFTA States, Truck Defects) |
| `Checkbox` / `Radio` / `Switch` | label + tavsif satri |
| `DatePicker` | bitta sana; `regulation_profile` formati |
| `DateRangePicker` | `Start date – End date`, presetlar (Today, Last 7/8 days, This month, Last quarter) |
| `TimePicker` | `HH:mm:ss` — Insert duty status uchun |
| `Table` (`DataTable`) | saralash, ustun ko'rsatish/yashirish, satr bosilishi, sticky sarlavha, gorizontal scroll |
| `Pagination` | `Rows per page: 10/25/50` + `Previous · <sahifalar> · Next` |
| `Modal` | `sm/md/lg/xl`; sarlavha+kontent+footer(Cancel/Save); Esc va backdrop bilan yopilish (o'zgargan bo'lsa tasdiq) |
| `ConfirmDialog` | sarlavha `Are you absolutely sure?` + matn + Cancel/Confirm; `variant: danger` |
| `Drawer` | o'ng paneldan chiquvchi (Track on Map yon paneli) |
| `Tabs` | pastki chiziqli, klaviatura bilan boshqariladigan (`role="tablist"`) |
| `Badge` | `success/warning/error/neutral/info`; `dot` variant (Online/Offline) |
| `StatusChip` | duty status (`OFF/SB/DR/ON/PC/YM`) — rang + qisqartma |
| `Toast` | `success/error/warning/info`; 5s, `error` qo'lda yopiladi; stack maks 3 |
| `Tooltip` | klaviatura fokusida ham ochiladi |
| `EmptyState` | ikonka/illyustratsiya + sarlavha + tavsif + ixtiyoriy amal |
| `ErrorState` | xato ikonkasi + kod + «Try again» |
| `Skeleton` | `text/line/card/table-row/map` |
| `Spinner` | inline va to'liq ekranli |
| `Avatar` | initsiallar fallback bilan |
| `Breadcrumb` | havola zanjiri, oxirgi element — matn |
| `Card` | sarlavha + amal + kontent |
| `KpiCard` | qiymat + label + ikonka + kesim matni + pastki rangli chiziq |
| `FileUpload` | drag&drop, progress, `accept`, hajm chegarasi |
| `SignaturePreview` | imzo rasmi (faqat ko'rish — admin imzo qo'ymaydi) |
| `PermissionGate` | `<PermissionGate perm="units.create">…</PermissionGate>` |

Har bir `ui/` komponenti uchun majburiy: (a) TypeScript props interfeysi, (b) Vitest testi (render + asosiy interaksiya + a11y roli), (c) `en.json` da hech qanday matn hardcode qilinmaydi.

## 7. Tema [MUST]

**MVP — faqat light tema.** Header'dagi tema almashtirgich (quyosh ikonkasi) olib tashlanadi (admin panelda dark tema uchun ekran chizilmagan — faqat mobil/planshet uchun bor).

Texnik tayyorgarlik saqlanadi: barcha ranglar CSS o'zgaruvchilari orqali (`--color-bg`, `--color-surface`, …), `:root[data-theme]` selektoriga ulanadi. Dark tema kelajakda faqat token qo'shish bilan yoqiladi (`#1B222C` bg, `#233040` sidebar, `#303E4B` karta, `#52565F` stroke — 2-bosqich, [MAY]).

## 8. Tailwind konfiguratsiyasi [MUST]

`tailwind.config.ts` da `theme.extend` orqali yuqoridagi barcha tokenlar e'lon qilinadi; komponentlarda **xom hex, xom px yoki `style={{}}` ishlatilmaydi** (istisno: xarita marker pozitsiyalari). ESLint `no-restricted-syntax` bilan tekshiriladi.

## 9. i18n [MUST]

- `react-i18next`, `src/locales/en.json` — birinchi kundan. MVP faqat inglizcha, lekin hech qanday matn kodda hardcode qilinmaydi.
- **Kalit tuzilishi:** `<modul>.<ekran>.<element>` — masalan `units.list.title`, `units.form.unit_number.label`, `common.actions.save`, `errors.VALIDATION_ERROR`, `enums.duty_status.DR`.
- Barcha backend `enum` qiymatlari uchun i18n kaliti bo'ladi (`enums.*`) — xom `snake_case` qiymat ekranga chiqmaydi.
- Ko'plik — `i18next` `_one`/`_other`; o'zgaruvchilar `{{count}}`, `{{name}}` orqali. **String konkatenatsiyasi taqiqlanadi.**
- Kelajakda RTL (Urdu) uchun: `dir` atributi `<html>` da, Tailwind `rtl:` variantlari, `ms-`/`me-` (logical) `ml-`/`mr-` o'rniga — MVP'da majburiy emas, lekin yangi kodda logical property ishlatiladi.
- `i18next-parser` bilan `npm run i18n:extract`; CI'da yetishmayotgan kalit = xato.

## 10. Sana va vaqt [MUST]

Format `regulation_profile` ga bog'liq (dizayndagi 6 xil variant shu 2 taga qisqartirilgan):

| Kontekst | `generic` | `fmcsa_us` |
|---|---|---|
| Sana | `DD/MM/YYYY` (`17/12/2025`) | `MM/DD/YYYY` (`12/17/2025`) |
| Sana + hafta kuni | `Fri, 17/12/2025` | `Fri, 12/17/2025` |
| Vaqt | 24 soat (`14:05`) | 12 soat (`02:05 PM`) |
| Sana + vaqt | `17/12/2025 14:05` | `12/17/2025 02:05 PM` |
| Davomiylik | `HH:MM` yoki `HH:MM:SS` | bir xil |
| Nisbiy | `2 hours ago` (< 24 soat) | bir xil |

**Timezone [MUST]:** Backend hamma narsani **ISO 8601 UTC** da beradi. Ko'rsatish — **Company Home Terminal timezone** ida (`GET /me` → `company.timezone`), **brauzer TZ da emas** (log kuni chegarasi Home Terminal TZ bo'yicha — boshqacha ko'rsatish auditni buzadi).

Har sana/vaqt yonida (jadval hujayrasi tooltip'ida) TZ qisqartmasi ko'rsatiladi (`14:05 CST`). Foydalanuvchi brauzer TZ si kompaniyanikidan farq qilsa — sahifada bir marta izoh: «Times are shown in the company time zone (America/Chicago)».

`lib/format.ts` da yagona funksiyalar: `formatDate`, `formatTime`, `formatDateTime`, `formatDuration`, `formatRelative`. Komponentlarda `date-fns` bevosita chaqirilmaydi (ESLint bilan cheklanadi).

## 11. Birliklar [MUST]

Backend **SI da qaytaradi**: masofa — metr (`odometer_m`, `distance_m`), tezlik — km/h (`speed_kmh`), engine hours — soat. Backend hech qanday konvertatsiya qilmaydi — **barcha konvertatsiya frontendda**.

| Qiymat | `metric` | `imperial` | Formula |
|---|---|---|---|
| Masofa | km | mi | `m / 1000` · `m / 1609.344` |
| Tezlik | km/h | mph | `kmh` · `kmh / 1.609344` |
| Harorat | °C | °F | `c` · `c * 9/5 + 32` |
| Hajm (yoqilg'i) | L | gal | `l` · `l / 3.785411784` |
| Og'irlik | kg | lb | `kg` · `kg * 2.20462262` |

`lib/units.ts`: `formatDistance(m)`, `formatSpeed(kmh)`, `formatVolume(l)`, `formatTemperature(c)` — hammasi `useUnitSystem()` orqali `company.unit_system` ni o'qiydi. Yaxlitlash: masofa 1 xona, tezlik 0 xona, harorat 0 xona.

**Kiritishda teskari konvertatsiya [MUST]:** foydalanuvchi `imperial` da `2000 miles` kiritsa — API'ga **metrda** yuboriladi (ayniqsa Maintenance formasida muhim: `Maintenance Frequency`, `Set Reminder`, `Last service value`). Konvertatsiya `parseDistance(value, unitSystem)` orqali, bitta joyda.

Birlik yorlig'i (`Miles`/`Km`) input yonida **doim ko'rinadi**. Dizayndagi `mph`/`miles`/`°F` faqat `imperial` rejimda — **default `metric`**.

## To'liq manba

- TZ §5 (Dizayn tizimi), `docs/tz-admin-frontend.md` qatorlar 388–539
- TZ §12 (i18n, sana/vaqt, birliklar), `docs/tz-admin-frontend.md` qatorlar 1542–1588
