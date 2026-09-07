---
name: fe-testing
description: ELD Admin Panel frontendida testlar (Vitest, Testing Library, MSW, Playwright e2e) yozish yoki qamrov/performans byudjetlarini tekshirishda ishlatiladi.
---

# Sifat — testlar va performans

## Test piramidasi [MUST]

| Daraja | Vosita | Qamrov |
|---|---|---|
| Unit | Vitest | `lib/*` (format, units, errors, permissions, hos) — **100% branch** |
| Komponent | Vitest + Testing Library | `components/ui/*` — har biri; `components/data/DataTable` |
| Integratsiya | Vitest + **MSW** (`swagger.json` dan mock) | har modul uchun asosiy ekran: yuklanish → ro'yxat → filtr → forma → xato |
| E2E | Playwright | quyidagi 8 oqim (§14.4) |

## Qamrov chegaralari [MUST] — F212

| Qamrov sohasi | Minimal foiz |
|---|---|
| `lib/` | **100%** (branch) |
| `components/ui/` | **≥ 90%** |
| Umumiy (statements) | **≥ 70%** |

CI'da tekshiriladi — chegaradan pastga tushsa build muvaffaqiyatsiz bo'ladi.

## Nima test qilinadi / qilinmaydi

**Test qilinadi (majburiy):**
- `lib/*` — format, units (metric/imperial konversiya), errors, permissions, HOS hisob-kitob mantig'i — to'liq branch qamrovi bilan.
- `components/ui/*` — har bir komponent alohida (variant, holat, a11y attributlari).
- `components/data/DataTable` — sortlash, sahifalash, bo'sh holat, xato holati.
- Har modul uchun asosiy integratsiya oqimi: yuklanish → ro'yxat → filtr → forma → xato (MSW orqali mock qilingan backend bilan).
- **F214 [MUST] Permission testlari** — har modul uchun «ruxsat yo'q» ssenariysi: tugma ko'rinmaydi, marshrut `403` qaytaradi, jadval satr amali yo'q. Bu `usePermission` hook'idagi regressiyadan himoya qiladi.
- **F215** Konvertatsiya testlari **majburiy**: `metric ↔ imperial` va `generic ↔ us_fmcsa` — chegaraviy qiymatlar bilan (0, manfiy son, juda katta odometer qiymati).

**Test qilinmaydi (piramida chegarasidan tashqarida):**
- Uchinchi tomon kutubxonalarining o'z ichki mantig'i (masalan MapLibre render mexanikasi) — faqat bizning integratsiya qatlamimiz test qilinadi.
- Vizual pixel-perfect solishtirish (snapshot faqat struktura/qiymat darajasida, screenshot-diff emas — quyidagi golden testlar bo'limiga qarang).

## MSW handler tashkil etish [MUST] — F213

- MSW handler'lari `openapi/swagger.json` dan generatsiya qilinadi (`msw-auto-mock` yoki qo'lda yozilgan handler), lekin **tiplar har doim `schema.d.ts` dan** olinadi.
- Maqsad: mock va real API bir xil shaklda (shape) bo'lishi — swagger o'zgarsa, mock ham tip xatosi orqali darhol aniqlanadi.
- Har modul uchun handler alohida faylda (masalan `mocks/handlers/units.ts`) va integratsiya testida shu modulga xos handler to'plami import qilinadi — global handler faylini shishirmaslik kerak.
- E2E ham xuddi shu handler infratuzilmasidan yoki test-backenddan foydalanadi (F226) — ikkita alohida mock manbasi bo'lmasligi kerak.

## Golden / snapshot testlar

- Konvertatsiya funksiyalari (`metric ↔ imperial`, `generic ↔ us_fmcsa`) uchun chegaraviy qiymatlar bilan golden testlar yoziladi: `0`, manfiy son, juda katta odometer — kutilgan natija qat'iy tenglik bilan tekshiriladi (F215).
- Format funksiyalari (`lib/*` ichidagi sana/vaqt/raqam formatlash) uchun ham kirish → kutilgan chiqish juftliklari sifatida saqlanadi, real snapshot fayllar emas — qiymatlar testda aniq yozilgan bo'ladi (o'zgarishni ko'rish oson bo'lishi uchun).

## Playwright E2E — 8 oqim [MUST] — §14.4

1. Login → dashboard → logout.
2. Unit yaratish → tahrirlash → deaktivatsiya → o'chirish (tasdiq dialoglari bilan).
3. Driver yaratish → invitation → license reveal (ruxsat bilan va ruxsatsiz).
4. Logs By Driver → Log view → **log edit request yuborish** (haydovchi tasdig'i kutilishi tekshiriladi).
5. Tracking → Track on Map → trip tanlash.
6. Maintenance: schedule yaratish → due → mark as complete (invoice yuklash bilan).
7. Report: Distance by Region → export job → download.
8. Permission: cheklangan rol bilan kirish → yashirilgan menyular va `403`/`404` ekranlari.

**F226** E2E **MSW yoki test-backend** ga qarshi ishlaydi, prod ma'lumotiga hech qachon tegmaydi.

### E2E login strategiyasi — `storageState` qayta ishlatiladi [MUST]

Login rate limit **5 so'rov/daqiqa/IP** (fe-api §1). 8 oqimning har biri o'z ichida qayta login qilsa, parallel/ketma-ket ishlaydigan Playwright loyihasi tezda `429` ga uchraydi. Shuning uchun:

- Login **bitta marta**, alohida `global setup` loyihasida bajariladi (`playwright.config.ts` → `projects: [{ name: 'setup', testMatch: /global\.setup\.ts/ }]`), natija `playwright/.auth/user.json` ga (`page.context().storageState({ path })`) yoziladi.
- Qolgan 7 oqim shu faylni `use: { storageState: 'playwright/.auth/user.json' }` orqali **o'qiydi** — har test faylida qaytadan `/login` formasini to'ldirmaydi.
- Faqat 1-oqim (Login → dashboard → logout) haqiqiy login formasi bilan ishlaydi; qolganlari darhol autentifikatsiyalangan holatda boshlanadi.
- Turli rol/ruxsat ssenariylari (masalan 8-oqim — cheklangan rol) uchun **alohida** `storageState` fayli (`playwright/.auth/<rol>.json`), har biri o'z `global setup` loyihasida — baribir har rol uchun bitta login, testlar ichida emas.
- `storageState` fayli faqat `sessionStorage`dagi refresh token va cookie'larni saqlaydi (Playwright `storageState` ikkalasini ham qamrab oladi); access token xotirada bo'lgani uchun (fe-security §4) sahifa qayta ochilganda ilova uni **refresh oqimi** orqali tiklaydi — bu haqiqiy foydalanuvchi tajribasiga mos, qo'shimcha moslashtirish shart emas.
- CI'da `storageState` fayli git'ga commit qilinmaydi (`playwright/.auth/` — `.gitignore`); har CI ishga tushishida `setup` loyihasi qayta login qiladi (bitta so'rov — limitga urilmaydi).

## Performans byudjetlari [SHOULD] — §14.3

| Ko'rsatkich | Maqsad |
|---|---|
| Lighthouse Performance (desktop, `/`) | ≥ 90 |
| Lighthouse Accessibility | ≥ 95 |
| Lighthouse Best Practices | ≥ 95 |
| LCP | ≤ 2.0 s |
| CLS | ≤ 0.05 |
| INP | ≤ 200 ms |
| Boshlang'ich JS (gzip, xaritasiz) | ≤ **250 KB** |
| Route chunk (o'rtacha) | ≤ **80 KB** |
| Xarita chunk (lazy) | ≤ **400 KB** |

**F223 [MUST]** Har route — `React.lazy` + `Suspense`. MapLibre, PDF ko'ruvchi, `recharts` — har biri alohida chunk.

**F224** `rollup-plugin-visualizer` bilan bundle hisoboti CI artefakti sifatida saqlanadi; chegara oshsa CI ogohlantirish beradi.

**F225** 50 satrli jadval virtualizatsiyasiz ishlaydi (`per_page ≤ 50`). Virtualizatsiya faqat chat va audit oqimida (`@tanstack/react-virtual`) **[MAY]** — majburiy emas.

### O'lchash usuli

- **Bundle hajmi:** build vaqtida `rollup-plugin-visualizer` chiqargan hisobot CI artefakti sifatida saqlanadi; har route/chunk hajmi jadvaldagi byudjet bilan solishtiriladi (F224).
- **Lighthouse ballari va Core Web Vitals (LCP/CLS/INP):** CI'da Lighthouse CI (yoki teng vosita) `/` sahifasida desktop profilida ishga tushiriladi, natija yuqoridagi maqsad qiymatlar bilan solishtiriladi.
- **Route chunk va xarita chunk hajmi:** build chiqishi (`dist/assets/*.js` hajmlari) visualizer hisobotidan olinadi, alohida route/xarita chunk'lari nazorat qilinadi.

## To'liq manba

`docs/tz-admin-frontend.md`, §14.1 «Testlar» (qatorlar 1621–1636), §14.3 «Performans» va §14.4 «E2E oqimlari» (qatorlar 1647–1679).
