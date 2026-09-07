---
name: fe-permissions
description: ELD Admin Panel uchun permission kalitlari manbai, usePermission()/PermissionGate API'si, scope (company/branch/self) mantiqi, 403 vs 404 farqi va to'liq navigatsiya/marshrutlar tuzilishi (kanonik nomlar bilan). Router, nav menyu, route guard yoki ruxsat tekshiruvi yozishdan oldin yuklanadi (fe-architect, screen-implementer agentlari uchun).
---

# fe-permissions — Ruxsatlar va navigatsiya

## 1. Permission kalitlari manbai **[MUST]**

- Haqiqiy manba: `backend/internal/auth/permissions.go` (**105 kalit**) va ish vaqtida `GET /permissions`.
- Frontendda kalitlar `src/lib/permissions.ts` da **konstanta sifatida** takrorlanadi (typo'ni kompilyatsiya vaqtida topish uchun):

```ts
export const PERM = {
  unitsRead: 'units.read', unitsCreate: 'units.create', … } as const;
export type Permission = typeof PERM[keyof typeof PERM];
```

- CI testi `src/lib/permissions.ts` dagi kalitlarni `GET /permissions` snapshot'i bilan solishtiradi (drift bo'lsa qizil).
- 26 modul guruhiga bo'lingan (Add/Edit Role ekrani checkbox ro'yxati uchun ham shu manba ishlatiladi — dizayndagi go'zallik saloni domeni matni (`Salons`, `Clients`, …) e'tiborga olinmaydi, faqat struktura: `Role Name *` + guruhlangan checkbox).

## 2. `usePermission()` API **[MUST]**

Joriy foydalanuvchi ruxsatlari `GET /me` javobidan olinadi.

```ts
const can = usePermission();
can(PERM.unitsCreate)            // boolean
can.any([PERM.unitsRead, …])     // kamida bittasi
can.all([…])                     // hammasi
```

`super_admin` — alohida bayroq (rol emas): `x-permission: super_admin` bo'lgan endpointlar faqat unga ochiq (`/companies*`).

## 3. `PermissionGate` / menyu-tugma boshqaruvi **[MUST]**

| Element | Ruxsat yo'q bo'lsa |
|---|---|
| Nav elementi / flyout punkti | Yashiriladi (DOM'da yo'q) |
| Ro'yxat sahifasi marshruti | Route guard → 403 ekrani (to'g'ridan-to'g'ri URL kiritilsa) |
| Asosiy amal tugmasi (`Add Unit`) | Yashiriladi |
| Satr amali (`Edit`, `Delete`) | Amal menyusidan olib tashlanadi |
| Tab (masalan `Inactive`) | Yashiriladi, agar `include_inactive` ruxsati yo'q bo'lsa |
| Maskalangan maydon (`license_no_masked`) | "Reveal" tugmasi yashiriladi (`drivers.license.view` yo'q) |

Qoidalar:
- "Yashirish" — **UI qulayligi, xavfsizlik emas**. Har bir amal backendda ham tekshiriladi; frontend hech qachon ruxsatga ishonib yozuv qilmaydi.
- `disabled` tugma hech qachon sababsiz qolmaydi: `title`/tooltip bilan sabab ko'rsatiladi («Requires the `units.create` permission», «Subscription is read-only»).

Tavsiya etilgan komponent shakli (TZ'da nom berilmagan, konventsiyaga mos taklif):

```tsx
<PermissionGate permission={PERM.unitsCreate} fallback={null}>
  <Button>Add Unit</Button>
</PermissionGate>
```

## 4. `scope` ta'siri **[MUST]**

| `scope` | UI |
|---|---|
| `company` | Filiallar filtri ko'rinadi (`branch_id`), "All branches" default |
| `branch` | Filial filtri **yashiriladi va o'zgartirilmaydi** — backend avtomatik filtrlaydi. Sarlavha ostida `Branch: <nom>` yorlig'i. `POST/PATCH` formalarida `branch_id` maydoni yashirin va o'z filiali bilan to'ldiriladi |
| `self` | Driver roli — web admin panelga **kirmaydi**: login muvaffaqiyatli bo'lsa ham `/login` da xato («This account can only be used in the driver app») |

`scope=branch` foydalanuvchisi boshqa filialning yozuviga URL orqali kirsa — backend **404** qaytaradi, UI "Not found" ko'rsatadi.

## 5. 403 va 404 farqi **[MUST]**

Ikki holat qat'iy ajratiladi:

- **403 FORBIDDEN** — resurs mavjud va sizning kompaniyangizniki, lekin ruxsat kaliti yo'q. UI: «You do not have permission…» + qaysi kalit kerakligi (dev rejimda).
- **404 NOT_FOUND** — resurs yo'q **yoki boshqa tenantga tegishli**. Backend ataylab tafovut bermaydi (tenant enumeratsiyasini oldini olish). UI hech qachon «Bu boshqa kompaniyaniki» demaydi — faqat «Not found».
- WebSocket'da ham xuddi shunday: `filter.unit_ids` begona unit'ni nomlasa — `NOT_FOUND`, `FORBIDDEN` emas.

## 6. Navigatsiya tuzilishi **[MUST]** (kanonik nomlar)

**QATLAM 1 — brend panel** (`#B7002C`): logotip `ONEBOOK ELD` · global qidiruv · bildirishnomalar qo'ng'irog'i (o'qilmaganlar soni) · profil avatari.
**QATLAM 2 — navigatsiya** (oq fon): faol element qizil + ostida 2 px qizil chiziq.
**QATLAM 3 — breadcrumb** (ichki ekranlarda).

| Nav elementi | Marshrut | Flyout punktlari | Ko'rinish sharti |
|---|---|---|---|
| Dashboard | `/` | — | `dashboard.read` |
| Tracking | `/tracking` | — | `tracking.view_live` |
| Logs ⌄ | — | Logs By Unit `/logs/by-unit` · Logs By Driver `/logs/by-driver` · Log Edit Requests `/logs/edit-requests` · Unassigned Driving `/logs/unassigned` · Violations `/violations` | `logs.read` (Violations — `violations.read`) |
| **Fleet Management** ⌄ | — | Unit Management `/units` · Driver Management `/drivers` · ELD Devices `/eld-devices` · Trailers `/trailers` · Shipping Documents `/shipping-documents` · Users `/users` · Roles & Permissions `/roles` | har punkt o'z `*.read` kaliti bilan |
| Maintenance ⌄ | `/maintenance` | Schedule · Due · History (tab sifatida) · DVIR `/dvir` | `maintenance.read` / `dvir.read` |
| **Reports** ⌄ | — | Activity Report · Distance by Region · Regulator Export · DVIR Report · Uncertified Logs · Export Jobs | `reports.read` |
| **Support & History** ⌄ | — | Histories `/audit` · Contact Support `/support` · Feedback `/feedback` | `audit.view` / `support.read` / `feedback.read` |
| Chat | `/chat` | — | `chat.read` |

**Nav tashqarisidagi ekranlar:** Settings (`/settings/*`) — profil menyusi orqali; Track on Map — Tracking/Unit'dan; Log view — Logs jadvalidan; Routes (`/routes`) — Tracking flyout'i ostida yoki Dashboard'dan.

**Kanonik nomlash qoidasi:** dizayndagi `Fleet Operations`, `Report`, `Histories` variantlari **ishlatilmaydi** — kanonik nomlar: **Fleet Management**, **Reports**, **Support & History** (ichida `Histories` punkti bor).

Flyout punktlarining tavsif matnlari (dizaynda `lorem ipsum` qolgan joylar — haqiqiy matn bilan almashtiriladi):

| Modul | Tavsiflar |
|---|---|
| Logs | View logs by unit for a single day · View logs by driver over a date range · Review and approve driver log edit requests · Assign unidentified driving to drivers · HOS warnings and violations |
| Reports | Driving time and odometer by driver or unit · Distance travelled per region · Regulator export for roadside inspections · DVIR history and export · Logs that are still uncertified · Your export downloads |
| Support & History | Full audit trail of every change · Driver support tickets · App ratings and comments from drivers |

Brend paneldagi global qidiruv (dizaynda `Search Driver`) — MVP'da haydovchi va unit bo'yicha tez o'tish: `GET /drivers?search=` + `GET /units?search=` parallel, natijalar ikki guruh bilan dropdown'da (backendda global search endpointi yo'q — bu frontend kompozitsiyasi).

## 7. Route guard shakli (konventsiyaga mos taklif)

`router.tsx` da har bir himoyalangan route `loader`/wrapper orqali permission tekshiradi, to'g'ridan-to'g'ri URL kiritilganda 403 ekraniga yo'naltiradi:

```tsx
{
  path: 'units',
  element: (
    <RouteGuard permission={PERM.unitsRead}>
      <UnitListPage />
    </RouteGuard>
  ),
}
```

`RouteGuard` mantiqi:
1. `can(permission)` false → `<ForbiddenScreen requiredPermission={permission} />` render qiladi (dev rejimda kalit nomi ko'rsatiladi, prod'da yo'q).
2. Resurs backend'dan 404 qaytarsa (masalan boshqa filial/tenant yozuvi) — component darajasida `<NotFoundScreen />`, `RouteGuard` bilan aralashtirilmaydi (403 — kirish darajasida, 404 — ma'lumot darajasida).
3. `scope=self` (Driver) foydalanuvchisi umuman admin router'iga kirmaydi — `AuthLayout` darajasida rad etiladi, login xatosi bilan.

## 8. Nav elementi → permission kaliti xaritasi (kengaytirilgan)

Yuqoridagi jadvaldagi har bir marshrut uchun kutilayotgan backend permission prefiksi (kalit nomlarining aniq ro'yxati `GET /permissions` dan olinadi, bu yerda faqat modul prefiksi):

| Marshrut | Modul prefiksi | Izoh |
|---|---|---|
| `/` | `dashboard.*` | KPI kartalar, grafik — barchasi `dashboard.read` bilan bitta ruxsat |
| `/tracking` | `tracking.*` | `tracking.view_live` — WS oqimi ham shu kalit bilan himoyalanadi |
| `/logs/by-unit`, `/logs/by-driver` | `logs.*` | `logs.read` |
| `/logs/edit-requests` | `logs.edit_requests.*` | Ko'rish `logs.read`, tasdiqlash alohida yozuv kaliti (`logs.edit_requests.approve` kabi) |
| `/logs/unassigned` | `logs.*` | `logs.read`, tayinlash uchun yozuv kaliti kerak |
| `/violations` | `violations.*` | `violations.read` — logsdan alohida modul |
| `/units` | `units.*` | `units.read`/`units.create`/`units.update`/`units.delete` |
| `/drivers` | `drivers.*` | shu jumladan `drivers.license.view` — maskalangan maydonni ochish uchun alohida kalit |
| `/eld-devices` | `eld_devices.*` | |
| `/trailers` | `trailers.*` | |
| `/shipping-documents` | `shipping_documents.*` | |
| `/users` | `users.*` | Export tugmasi yo'q (backend endpointi yo'q — N16) |
| `/roles` | `roles.*` | `GET /permissions` dan 105 kalit shu ekranda guruhlanadi |
| `/maintenance`, `/dvir` | `maintenance.*`, `dvir.*` | Ikkalasi alohida `.read` kaliti |
| Reports flyout | `reports.*` | Barcha hisobot turlari bitta `reports.read` ostida, eksport uchun alohida yozuv kaliti |
| `/audit` | `audit.*` | `audit.view` — append-only, yozuv/o'chirish kaliti yo'q |
| `/support` | `support.*` | `support.read` |
| `/feedback` | `feedback.*` | `feedback.read` |
| `/chat` | `chat.*` | `chat.read` |
| `/settings/*` | shaxsiy profil, kalit talab qilmaydi | Password tabi — `Current password *` majburiy (D20) |

Aniq kalit nomlari (`units.read` kabi to'liq satr) kod yozishda **doim** `src/lib/permissions.ts` dagi `PERM` konstantasidan olinadi — bu jadvaldagi prefikslar faqat yo'naltirish uchun, hardcode qilinmaydi.

## 9. Maskalangan maydonlar va "Reveal" patterni

Ba'zi maydonlar (masalan haydovchi litsenziya raqami) backend tomonidan maskalangan holda keladi (`license_no_masked`). To'liq qiymatni ko'rish alohida kalit talab qiladi (`drivers.license.view`):

- Kalit yo'q → "Reveal" tugmasi butunlay yashiriladi, maskalangan qiymat ko'rinadi.
- Kalit bor → "Reveal" tugmasi bosilganda alohida so'rov (`GET /drivers/{id}/license`) yuboriladi, qiymat vaqtinchalik state'da saqlanadi (URL'ga yoki keshga yozilmaydi).

## To'liq manba

- `docs/tz-admin-frontend.md` §4 (Ruxsatlar va navigatsiya) — qatorlar 311–387
- Kanonik nomlar va nomuvofiqliklar tafsiloti: `docs/tz/16-17-registry-open-questions.md` §16.1, §16.4
