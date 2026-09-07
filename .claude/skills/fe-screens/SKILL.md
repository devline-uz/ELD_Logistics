---
name: fe-screens
description: ELD Admin Panel umumiy UI patternlari (ro'yxat ekrani, forma, modal, tasdiqlash dialogi, bo'sh/yuklanish/xato holatlari, toast, inline ogohlantirish) va har bir modul uchun ekran spetsifikatsiyasi fayllari ro'yxati. Yangi ekran yoki modul ustida ishlashdan oldin — avval umumiy patternlarni, keyin faqat kerakli modul faylini o'qi.
---

# FE Screens — umumiy patternlar va ekran spetsifikatsiyalari

## 1. Ro'yxat-ekran patterni [MUST]

Barcha ro'yxat ekranlari bitta tuzilma bo'yicha:

```
┌ Breadcrumb (ichki ekranlarda)
├ Sahifa sarlavhasi (H3)                          [Asosiy amal tugmasi]
├ Tablar (Active / Inactive / …)                   ← ixtiyoriy
├ Filtr paneli: [🔍 Search…] [Sana] [Select…]  … [Export ▾] [Import] [⚙ Ustunlar]
├ Jadval: kulrang sarlavha · oq satrlar · 1px ajratgich · oxirgi ustun `···`
└ Sahifalash: [Rows per page: 25 ▾]              [Previous  1 2 3  Next]
```

| Element | Qoida |
|---|---|
| Sahifa sarlavhasi | i18n kalit, breadcrumb bilan mos |
| Asosiy amal | `PermissionGate` bilan o'ralgan |
| Qidiruv | debounce 400ms, `search` query paramiga |
| Filtrlar | **URL'da**; faol filtrlar soni tugmada badge bilan; «Clear all» |
| Ustun tanlash | `⚙` → `Select All` + har ustun checkbox; tanlov `localStorage`da `columns:<screen>` kaliti bilan; barcha ro'yxatlarga qo'llanadi |
| Saralash | faqat ruxsat etilgan maydonlar; sarlavhada `↑/↓` |
| Eksport | server-side eksport bo'lgan joyda (`/units/export`, `/drivers/export`) darhol fayl, qolganida `export-jobs` |
| Satr bosilishi | `View` ekraniga; `···` menyusi `stopPropagation` bilan |
| Amal menyusi (`···`) | `View · Edit · Activate/Deactivate · Delete · <modulga xos>` — har biri o'z ruxsati bilan |
| Bo'sh holat | §5 |
| Yuklanish | skeleton — jadval sarlavhasi ko'rinadi, 5 skeleton satr |
| Xato | `ErrorState` jadval o'rnida, filtrlar qoladi |

Qoida: jadval **hech qachon** sahifani gorizontal scroll qilmaydi — jadval konteyneri `overflow-x: auto`, birinchi ustun `sticky left-0`. 10+ ustunli jadvallarda (Maintenance History, Logs kengaytirilgan) default'da ustunlarning bir qismi yashirin.

## 2. Forma patterni [MUST]

```ts
const schema = z.object({ unit_number: z.string().min(1).max(32), … });
const form = useForm({ resolver: zodResolver(schema), mode: 'onBlur' });
```

Validatsiya **ikki qatlam**: (1) zod — TZ §18.3 cheklovlari (Notes ≤ 60, Username 4–32 `[a-z0-9._]`, Parol ≥ 10 harf+raqam, VIN 17 belgi, `per_page` 10/25/50); (2) server — `VALIDATION_ERROR.details[]` maydonlarga bog'lanadi.

Server xatosini bog'lash:
```ts
onError: (e) => { const {fields, message} = normalizeError(e);
  Object.entries(fields).forEach(([f,m]) => form.setError(f as never, {message: m}));
  if (!Object.keys(fields).length) setFormError(message); }
```
Noma'lum `field` nomi (formada yo'q) → forma tepasidagi umumiy alert'ga tushadi, **yo'qolmaydi**.

- Majburiy maydonlar `*` bilan **va** `aria-required`.
- `Cancel` — o'zgarish bo'lsa `ConfirmDialog` («Discard unsaved changes?»); `Save`/`Update` — `loading`, ikki marta bosish bloklanadi, `Idempotency-Key` o'zgarmaydi.
- Yuborilgandan keyin: modal yopiladi → `queryClient.invalidateQueries(['<modul>'])` → success toast. Ro'yxat qayta yuklanadi, sahifa/filtrlar saqlanadi.
- Optimistik yangilash faqat "yengil" amallarda (bildirishnoma o'qilgan deb belgilash, chat xabari). CRUD'da — yo'q.

## 3. Modal [MUST]

- Add/Edit formalari **modal** (orqa fonda ro'yxat ko'rinadi). Uzun formalar (Driver — 18 maydon, Maintenance Add multiple) — modal ichida vertikal scroll, sarlavha va footer `sticky`.
- Fokus tuzoq (`focus trap`), ochilganda birinchi maydonga fokus, yopilganda chaqirgan tugmaga qaytadi. `Esc` — yopadi (Cancel tasdig'i bilan). `aria-modal="true"`, `aria-labelledby`.
- Modal marshrutga bog'lanmaydi (URL o'zgarmaydi), **istisno**: `View` ekranlari — ular alohida marshrut (`/units/:id`), chunki ulashiladi.

## 4. Tasdiqlash dialogi [MUST]

Matnlar aynan saqlanadi:
| Amal | Sarlavha | Matn | Tugmalar |
|---|---|---|---|
| Deactivate | `Are you absolutely sure?` | «Are you sure you want to deactivate the {entity}?» | `Cancel` / `Confirm` |
| Delete | `Are you absolutely sure?` | «This action cannot be undone. Are you sure you want to delete the {entity}?» | `Cancel` / `Confirm` (danger) |

Qaytarib bo'lmaydigan va audit-muhim amallar (Delete, Deactivate, Log edit request, HOS policy publish, Role delete, Ticket status) **har doim** tasdiq dialogi orqali. Delete — `danger` variant.

## 5. Bo'sh holat [MUST]

| Kontekst | Sarlavha | Matn |
|---|---|---|
| Umumiy (default) | `No Data Found` | «There is no data to show you right now» |
| Filtr natijasi bo'sh | `No results` | «No records match your filters» + `Clear filters` tugmasi |
| Logs By Driver — haydovchi tanlanmagan | `Select a driver` | «Select driver first, to display the data in the table.» |
| Ruxsat yo'q | `No access` | «You do not have permission to view this data» |

Bo'sh holatda **jadval sarlavhasi va sahifalash ko'rinib turadi**. «Filtr natijasi bo'sh» va «umuman ma'lumot yo'q» farqlanadi.

## 6. Yuklanish holati [MUST]

| Kontekst | Ko'rinish |
|---|---|
| Ro'yxat (birinchi yuklash) | Jadval skeleton: sarlavha + 5 satr |
| Ro'yxat (sahifa/filtr almashishi) | Mavjud ma'lumot qoladi (`keepPreviousData`) + yarim shaffof overlay + yupqa progress chiziq |
| Karta / KPI | `Skeleton` blok |
| Modal forma (ma'lumot yuklanishi) | Skeleton maydonlar |
| Tugma amali | Tugma ichida spinner, matn qoladi, `aria-busy` |
| Xarita | Xarita konteyneri + markazda spinner |
| PDF/eksport | Progress + «Preparing your file…» |

Skeleton **500ms dan tez** javob kelsa ko'rsatilmaydi — `useDelayedLoading(500)`.

## 7. Xato holati [MUST]

Uch daraja:
1. **Global** — ilova yuklanmadi (`GET /me` yiqildi): to'liq ekranli `ErrorState` + «Try again» + «Sign out».
2. **Ekran ichi** — ro'yxat/karta yuklanmadi: blok o'rnida `ErrorState`, qolgan sahifa ishlaydi.
3. **Amal** — mutation yiqildi: toast + forma ochiq qoladi, ma'lumot yo'qolmaydi.

React `ErrorBoundary` — har route atrofida; yiqilish `console.error` va (yoqilgan bo'lsa) Sentry'ga; foydalanuvchi oq ekran ko'rmaydi.

## 8. Toast [MUST]

Pozitsiya — o'ng yuqori (header ostida). `success` 4s, `info/warning` 6s, `error` — qo'lda yopiladi. Bir vaqtda maks 3 ta, ortiqchasi navbatda. `role="status"` (success/info) va `role="alert"` (error).

Toast matni — **nima bo'lgani + obyekt**: «Unit 101 created», «Log edit request sent to John Smith», emas «Success».

## 9. Inline ogohlantirish satrlari [MUST]

`Violation: <matn>` (qizil) va `Warning: <matn>` (sariq) satrlari — Log view'da grid ostida, Logs jadvallarida ustun ichida.

Manba — `GET /daily-logs/{id}` javobidagi `violations[]` va `GET /violations`. Har satr: ikonka + `severity` prefiksi + `type` ning i18n matni + vaqt + (agar `resolved_at` bo'lsa) «Resolved at …» kulrang. **Violation o'chmaydi** — hal qilingani `resolved` badge bilan ko'rsatiladi.

## 10. Yozuv formati va umumiy qoidalar (§7.0) [MUST]

Har ekran uchun spetsifikatsiya quyidagi tartibda yoziladi: **maqsad · marshrut · ruxsat · endpointlar (`METHOD /path`) · ustunlar/maydonlar · filtrlar · amallar · holatlar · bo'sh/xato holati**.

- **Minimal kenglik — 1280px.** Dizayn 1440px uchun. 1280–1439px: sahifa padding 40→24px, KPI kartalari 4→2 ustun, jadval gorizontal scroll bilan. `<1280px`: «This panel requires a screen at least 1280 px wide» xabari + o'lchamni o'zgartirish taklifi. Planshet/telefon uchun web admin qo'llab-quvvatlanmaydi.
- Har ekran `<title>` va `h1` — i18n kalitidan; breadcrumb marshrut ierarxiyasidan.
- Barcha `id` — UUID. URL'da UUID ko'rinadi; foydalanuvchiga esa **inson o'qiy oladigan identifikator** (Unit #, Ticket #, Driver name) ko'rsatiladi.

## 11. Ekran spetsifikatsiyalari — modul fayllari

TZ §7 modul bo'yicha alohida fayllarga bo'lingan. **Faqat o'zi ishlayotgan modul faylini o'qi** — hammasini birdan o'qima.

| Modul | Fayl |
|---|---|
| Auth (login, 2FA, parol tiklash, invitation) | `docs/tz/07-0-auth.md` |
| Dashboard | `docs/tz/07-2-dashboard.md` |
| Fleet (units, drivers, eld, trailers, docs, users, roles) | `docs/tz/07-3-fleet.md` |
| Logs va HOS | `docs/tz/07-4-logs.md` |
| DVIR va Maintenance | `docs/tz/07-5-dvir-maintenance.md` |
| Tracking va Routes | `docs/tz/07-7-tracking-routes.md` |
| Reports | `docs/tz/07-8-reports.md` |
| Chat, Support, Feedback, Audit, Notifications | `docs/tz/07-9-chat-support-audit.md` |
| Settings, Inspection, Super Admin | `docs/tz/07-13-settings-admin.md` |
| §16 nomuvofiqliklar + §17 ochiq savollar | `docs/tz/16-17-registry-open-questions.md` |

## To'liq manba

- TZ §6 (Umumiy patternlar), `docs/tz-admin-frontend.md` qatorlar 540–658
- TZ §7.0 (yozuv formati), `docs/tz-admin-frontend.md` qatorlar 659–671
- Modul spetsifikatsiyalari — yuqoridagi jadvaldagi `docs/tz/*.md` fayllar
