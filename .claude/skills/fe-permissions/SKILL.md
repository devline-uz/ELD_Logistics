---
name: fe-permissions
description: ELD Admin Panel uchun permission kalitlari manbai, usePermission()/PermissionGate API'si, scope (company/branch/self) mantiqi, 403 vs 404 farqi va to'liq navigatsiya/marshrutlar tuzilishi (kanonik nomlar bilan). Router, nav menyu, route guard yoki ruxsat tekshiruvi yozishdan oldin yuklanadi (fe-architect, screen-implementer agentlari uchun).
---

# fe-permissions — Ruxsatlar va navigatsiya

## 1. Permission kalitlari manbai **[MUST]**

- Haqiqiy manba: `admin/openapi/swagger.json` dagi `x-permission` maydonlari (**104 kalit**, 28 guruh);
  o'qish uchun qulay ko'rinish — **`docs/api/permissions.md`** (endpoint → kalit jadvali bilan).
  Ish vaqtida Roles ekrani `GET /permissions` dan ham shu ro'yxatni oladi.
- ⚠️ TZ §4.1 dagi «**105 kalit**» — **eskirgan**. Backend yakuniy tozalashda 4 ta o'lik kalitni
  olib tashladi (`tracking.read`, `tracking.history`, `trips.read`, `support.update`) va
  `drivers.license.view` ni qo'shdi. **To'g'ri son — 104.**
- Frontendda kalitlar `src/lib/permissions.ts` da **konstanta sifatida** takrorlanadi (typo'ni kompilyatsiya vaqtida topish uchun):

```ts
export const PERM = {
  unitsRead: 'units.read', unitsCreate: 'units.create', … } as const;
export type Permission = typeof PERM[keyof typeof PERM];
```

- CI testi `src/lib/permissions.catalog.test.ts` `PERM` ni `swagger.json` bilan **ikki tomonlama**
  solishtiradi (swagger'da bor-katalogda yo'q = 0, katalogda bor-swagger'da yo'q = 0) va sonni 104 deb tasdiqlaydi.
- 28 modul guruhiga bo'lingan (Add/Edit Role ekrani checkbox ro'yxati uchun ham shu manba ishlatiladi — dizayndagi go'zallik saloni domeni matni (`Salons`, `Clients`, …) e'tiborga olinmaydi, faqat struktura: `Role Name *` + guruhlangan checkbox).

## 1.1 Marshrut prefiksi ≠ permission kaliti **[MUST]**

Kalitni marshrut/endpoint nomidan **taxmin qilib bo'lmaydi** — har doim `docs/api/permissions.md`
jadvalidan tekshiring. Ma'lum tuzoqlar:

| Endpoint / ekran | To'g'ri kalit | Xato taxmin |
|---|---|---|
| `GET /company/history` | `company.history.view` | ~~`audit.view`~~ |
| `GET /audit-log`, `/audit-log/tables` | `audit.view` | — |
| `POST /users/{id}/activate` va `/deactivate` | `users.update` | ~~`users.activate` / `users.deactivate`~~ (yo'q) |
| `POST /drivers/{id}/activate` va `/deactivate` | `drivers.activate` / `drivers.deactivate` (bor!) | — |
| `GET /daily-logs/{id}/pdf` | `logs.export` | ~~`logs.pdf`~~ |
| `POST /daily-logs/{id}/certify` | `logs.certify` | — |
| `GET /log-edit-requests` | `logs.read` | ~~`logs.edit_requests.read`~~ (guruh yo'q) |
| `POST /log-edit-requests/{id}/approve` \| `/reject` | `logs.approve_edit` / `logs.reject_edit` | ~~`logs.edit_requests.approve`~~ |
| `GET /tracking/live` | `tracking.view_live` | ~~`tracking.read`~~ (o'lik) |
| `GET /trips/{id}`, `GET /units/{id}/trips` | `tracking.view_history` | ~~`tracking.history`~~, ~~`trips.read`~~ (o'lik; `trips.*` guruhi umuman yo'q) |
| `PATCH /support-tickets/{id}/status` | `support.update_status` | ~~`support.update`~~ (o'lik), ~~`support.close`~~ |
| `GET /units/{id}/diagnostics` | `units.diagnostics` | ~~`units.diagnostics.read`~~ |
| `GET /drivers/{id}/license` ("Reveal") | `drivers.license.view` | — (bor, maskalangan maydon uchun) |
| `POST /routes/{id}/not-completed` | `routes.complete` | — |
| `POST /maintenance-schedule-units/{id}/cancel` | `maintenance.cancel` | — |
| `GET /company/notification-settings` | `notification_settings.read` | ~~`notifications.read`~~ (bu push bildirishnomalar) |
| `GET /company/branches` | `branches.read` | ~~`company.read`~~ |
| `GET /defect-types` | `defect_types.read` | ~~`dvir.read`~~ |
| `POST /dvir-reports/{id}/repair` | `dvir.repair` | ~~`dvir.resolve_defect`~~ |
| `POST /files/presign` | `files.upload` | — |

Mavjud bo'lmagan (avval taxmin qilingan) kalitlar: `*.include_inactive`, `violations.resolve`,
`billing.read`, `companies.*`, `notifications.update`, `logs.unassigned.*`.

Ekran bir nechta endpointdan foydalansa — nav/route guard uchun **ro'yxatni ochadigan `*.read`**
kaliti olinadi; yozuv amallari (tugmalar) o'z kalitlari bilan alohida yopiladi.

## 1.2 OR mantiq istisnolari **[MUST]**

swaggo OR sintaksisiga ega emas: swagger bitta kalit ko'rsatadi, backend ikkitasini qabul qiladi.
Bu ekranlarda UI **`can.any([...])`** ishlatishi shart (bitta kalit bilan tekshirish foydalanuvchini
nohaq to'sib qo'yadi):

| Endpoint | Swagger'da | Backend qabul qiladi | UI |
|---|---|---|---|
| `GET /unidentified-events` (Unassigned Driving) | `logs.assign_unidentified` | + `logs.read` | `can.any([PERM.logsAssignUnidentified, PERM.logsRead])` |
| `GET /permissions` (Roles ekrani) | `permissions.read` | + `roles.read` | `can.any([PERM.permissionsRead, PERM.rolesRead])` |

Istisnolar `permissions.catalog.test.ts` da ro'yxat sifatida hujjatlashtirilgan; ikkala kalit ham
katalogda bor, shuning uchun ular drift solishtiruvini buzmaydi.

## 2. `usePermission()` API **[MUST]**

Joriy foydalanuvchi ruxsatlari `GET /me` javobidan olinadi.

```ts
const can = usePermission();
can(PERM.unitsCreate)            // boolean
can.any([PERM.unitsRead, …])     // kamida bittasi
can.all([…])                     // hammasi
```

`x-permission` ning uchta qiymati **permission emas** va `PERM` da yo'q:

| Qiymat | Operatsiya | Ma'no | UI'da |
|---|---|---|---|
| `public` | 6 | auth'siz (login, parol tiklash, invitation, app config) | guard yo'q |
| `authenticated` | 7 | har qanday kirgan foydalanuvchi, kalit tekshirilmaydi (`GET /me`, sessiyalar, 2FA, logout) | faqat auth guard |
| `super_admin` | 4 | alohida bayroq, rol emas (F33) — faqat `/companies*` | `can.isSuperAdmin`, `PERM` kaliti bilan EMAS |

`createPermissionChecker` `super_admin` bilan hech qanday kalitni ochmaydi — katalogda `companies.*` kaliti yo'q.

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
- **404 NOT_FOUND** — resurs yo'q **yoki boshqa tenantga/filialga tegishli**. **Cross-tenant murojaat har doim `404` qaytaradi, `403` emas** — backend ataylab tafovut bermaydi (tenant enumeratsiyasini oldini olish). UI hech qachon «Bu boshqa kompaniyaniki» demaydi — faqat «Not found». Ya'ni 403 faqat *o'z* kompaniyangiz resursida ruxsat kaliti yetishmaganda ko'rinadi.
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
| `/tracking` | `tracking.*` | `tracking.view_live` — WS oqimi ham shu kalit bilan; trip tarixi — `tracking.view_history` |
| `/logs/by-unit`, `/logs/by-driver` | `logs.*` | `logs.read` |
| `/logs/edit-requests` | `logs.*` | Ko'rish — `logs.read`; tasdiqlash/rad etish — `logs.approve_edit` / `logs.reject_edit` (`logs.edit_requests.*` guruhi **yo'q**) |
| `/logs/unassigned` | `logs.*` | OR: `can.any([logs.assign_unidentified, logs.read])`; tayinlash — `logs.assign_unidentified`, annotatsiya — `logs.annotate_unidentified` |
| `/violations` | `violations.*` | `violations.read` — logsdan alohida modul (faqat shu bitta kalit, `violations.resolve` yo'q) |
| `/units` | `units.*` | `units.read`/`create`/`update`/`delete`, shuningdek `units.activate`, `units.deactivate`, `units.assign_driver`, `units.diagnostics`, `units.export`, `units.import` |
| `/drivers` | `drivers.*` | shu jumladan `drivers.license.view` — maskalangan maydonni ochish uchun alohida kalit |
| `/eld-devices` | `eld_devices.*` | |
| `/trailers` | `trailers.*` | |
| `/shipping-documents` | `shipping_documents.*` | |
| `/users` | `users.*` | Activate/Deactivate — **`users.update`** (alohida kalit yo'q). Export tugmasi yo'q (backend endpointi yo'q — N16) |
| `/roles` | `roles.*` | `GET /permissions` dan 104 kalit shu ekranda 28 guruhga bo'linadi; ro'yxatni ochish — `can.any([permissions.read, roles.read])` |
| `/maintenance`, `/dvir` | `maintenance.*`, `dvir.*` | Ikkalasi alohida `.read` kaliti |
| Reports flyout | `reports.*` | Barcha hisobot turlari bitta `reports.read` ostida, eksport uchun alohida yozuv kaliti |
| `/audit` | `audit.*` | `audit.view` — append-only. Kompaniya sozlamalari tarixi (`GET /company/history`) — alohida **`company.history.view`** |
| `/support` | `support.*` | `support.read`; javob yozish — `support.create`; status — **`support.update_status`** |
| `/feedback` | `feedback.*` | `feedback.read` |
| `/chat` | `chat.*` | `chat.read` |
| `/settings/profile`, `/settings/security` | shaxsiy profil, kalit talab qilmaydi (`authenticated`) | Password tabi — `Current password *` majburiy (D20) |
| `/settings/company` | `company.*` | `company.read`/`company.update`; filiallar — `branches.*`; tarix — `company.history.view` |
| `/settings/hos` | `hos_policy.*` | `hos_policy.read` / `hos_policy.update` |
| Bildirishnoma sozlamalari | `notification_settings.*` | `notifications.*` (push/ro'yxat) bilan **aralashtirilmaydi** |

Aniq kalit nomlari (`units.read` kabi to'liq satr) kod yozishda **doim** `src/lib/permissions.ts` dagi `PERM` konstantasidan olinadi — bu jadvaldagi prefikslar faqat yo'naltirish uchun, hardcode qilinmaydi.

## 9. Maskalangan maydonlar va "Reveal" patterni

Ba'zi maydonlar (masalan haydovchi litsenziya raqami) backend tomonidan maskalangan holda keladi (`license_no_masked`). To'liq qiymatni ko'rish alohida kalit talab qiladi (`drivers.license.view`):

- Kalit yo'q → "Reveal" tugmasi butunlay yashiriladi, maskalangan qiymat ko'rinadi.
- Kalit bor → "Reveal" tugmasi bosilganda alohida so'rov (`GET /drivers/{id}/license`) yuboriladi, qiymat vaqtinchalik state'da saqlanadi (URL'ga yoki keshga yozilmaydi).

## To'liq manba

- **`docs/api/permissions.md`** — 104 kalit, 28 guruh, endpoint → kalit jadvali (generatsiya: `admin/openapi/swagger.json`)
- `admin/src/lib/permissions.ts` (`PERM`) va `admin/src/lib/permissions.catalog.test.ts` (drift testi)
- `docs/tz-admin-frontend.md` §4 (Ruxsatlar va navigatsiya) — qatorlar 311–387 (§4.1 dagi «105» — xato, §16 reestrida)
- Kanonik nomlar va nomuvofiqliklar tafsiloti: `docs/tz/16-17-registry-open-questions.md` §16.1, §16.4
