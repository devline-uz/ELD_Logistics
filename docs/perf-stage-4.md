# 4-bosqich — Performans o'lchovi (vazifa 4.12)

**Sana:** 2026-09-07 · **Branch:** `feat/stage-2-fleet` · **Build:** `npm run build` (Vite, production)
**Manba byudjetlar:** TZ §14.3 (Performans) va §15 (NFR jadvali).

---

## 1. Bundle byudjetlari

Barcha o'lchovlar `admin/dist/assets/` dan olingan; `gzip` — `gzip -c <fayl> | wc -c`.
KB bu yerda **KiB (1024 bayt)** — shuning uchun raqamlar `vite build` konsolidagi o'nlik kB dan
bir oz kichik ko'rinadi (masalan `index`: 121,15 kB o'nlik = 118,2 KiB).

| Ko'rsatkich (TZ §14.3) | Byudjet | O'lchangan | Holat |
|---|---|---|---|
| Boshlang'ich JS (gzip, xaritasiz) | ≤ 250 KB | **118,2 KB gzip** (`index-CDigMEe3.js`, raw 377,3 KB) | ✅ |
| Route chunk (o'rtacha) | ≤ 80 KB | **3,5 KB gzip** (o'rtacha), raw 9,8 KB; eng kattasi `LogViewPage` — 11,2 KB gzip | ✅ |
| Xarita chunk (lazy) | ≤ 400 KB | **212,5 KB gzip** (`maplibre-gl-CVBayumW.js`, raw 784,7 KB) | ✅ |

Izohlar:

- Byudjet jadvalida "Boshlang'ich JS" **gzip** deb belgilangan, shuning uchun xarita chunk'i uchun
  ham asosiy o'lchov gzip qilib olingan (212,5 KB ≤ 400 KB). Raw (minified, siqilmagan) qiymat
  784,7 KB — u ham hisobotda ko'rsatilgan, chunki `vite build` konsolida aynan shu raqam chiqadi.
  Tarmoq orqali haqiqatda uzatiladigan hajm gzip/brotli bo'ladi.
- Route chunk o'rtachasi 25 ta `*Page-*.js` chunk bo'yicha hisoblangan (jami 86,5 KB gzip / 246,2 KB raw).
  Bu faqat ekranning o'z kodi; umumiy `useListParams`, `schemas`, `useDateFormat` kabi bo'lishilgan
  chunk'lar alohida keladi va bir necha ekran o'rtasida qayta ishlatiladi.
- Boshlang'ich CSS: `index-CGNCvfwp.css` — 5,7 KB gzip (raw 25,4 KB).

## 2. Lazy-lik dalili (F165 / F223)

Har bir chunk'da `maplibre-gl` **statik** importi bor-yo'qligi tekshirildi:

```
$ grep -o 'import[^;]\{0,80\}from"\./maplibre-gl-[^"]*\.js"' dist/assets/<chunk>.js | wc -l
index-BvI06DvB.js            0   ✅ asosiy bundle maplibre'ni tortmaydi
LogViewPage-CUu5no61.js      0   ✅
RouteListPage-DGCTwsJi.js    0   ✅ (tuzatishdan oldin — 1, pastga qarang)
TrackOnMapPage-CVDEyMdm.js   0   ✅ (4.13 ko'rigidan keyin — 1, pastga qarang)
RouteDirectionsMap-*.js      1   ✅ kutilgan — bu aynan lazy xarita bloki
TrackingMapPanel-*.js        1   ✅ kutilgan — bu aynan lazy xarita bloki
```

Ya'ni **hech bir ekran chunk'i** maplibre'ni statik tortmaydi: u faqat lazy xarita
panellari (`TrackingMapPanel`, `TripMapPanel`, `RouteDirectionsMap`) orqali yuklanadi.

`dist/index.html` da faqat bitta modul va bitta stylesheet bor, **hech qanday `modulepreload` yo'q**,
demak maplibre navigatsiya paytida oldindan yuklanmaydi:

```html
<script type="module" crossorigin src="/assets/index-CDigMEe3.js"></script>
<link rel="stylesheet" crossorigin href="/assets/index-CGNCvfwp.css">
```

### Tuzatilgan nuqson — `RouteListPage` maplibre'ni statik tortardi

Oldin: `RouteListPage` → `RouteDirectionsDrawer` → `useGeofenceLayer` + `maplibregl.Marker`
(ikkalasi ham `maplibre-gl` ni statik import qiladi). Natijada oddiy ro'yxat ekraniga kirishda
803 KB (218 KB gzip) behuda yuklanardi, holbuki xarita faqat "Directions" drawer'i ochilganda kerak.

Tuzatish — `TripMapPanel`/`LazyTripMapPanel` usuli takrorlandi: drawer'ning xarita qismi
alohida lazy blokka chiqarildi.

| Fayl | O'zgarish |
|---|---|
| `admin/src/features/routes/components/RouteDirectionsMap.tsx` | **yangi** — `maplibre-gl` (Marker) + `useGeofenceLayer` + `LazyMapCanvas` shu yerda |
| `admin/src/features/routes/components/LazyRouteDirectionsMap.tsx` | **yangi** — `React.lazy` + `Suspense` (fallback: `Skeleton variant="map"`) |
| `admin/src/features/routes/components/RouteDirectionsDrawer.tsx` | `maplibre-gl`, `useGeofenceLayer`, `LazyMapCanvas`, `decodePolyline` importlari olib tashlandi; o'rniga `LazyRouteDirectionsMap` |

Natija: `RouteListPage-*.js` da maplibre statik importi **1 → 0**; ajratilgan
`RouteDirectionsMap-*.js` chunk'i atigi 1,1 KB (589 B gzip) va faqat drawer ochilganda yuklanadi.
Drawer'ning jadval ekvivalenti (F171) va `MapDataTable` o'zgarmadi — a11y regressiyasi yo'q.

### Tuzatilgan nuqson — `TrackOnMapPage` ham maplibre'ni statik tortardi

4.13 kod ko'rigi topdi: sahifa `useLiveUnitsLayer`/`useTripPolylineLayer` ni to'g'ridan-to'g'ri
import qilgani uchun `VITE_MAP_STYLE_URL` bo'sh bo'lganda ham 803 KB yuklanardi. Dastlab
"qabul qilingan" deb baholangan edi (xarita bu ekranda asosiy kontent), lekin xuddi shu
lazy-panel usuli bu yerda ham arzonga tushdi.

| Fayl | O'zgarish |
|---|---|
| `admin/src/components/map/TrackingMapPanel.tsx` | **yangi** — `useLiveUnitsLayer` + `useTripPolylineLayer` + `LazyMapCanvas` bir joyda |
| `admin/src/components/map/LazyTrackingMapPanel.tsx` | **yangi** — `React.lazy` + `Suspense` |
| `admin/src/features/tracking/pages/TrackOnMapPage.tsx` | qatlam hook'lari va `LazyMapCanvas` o'rniga bitta `LazyTrackingMapPanel`; `mapInstance` holati keraksiz bo'ldi |

Natija: `TrackOnMapPage-*.js` **1 → 0** va chunk 25,5 KB → 20,0 KB (8,3 → 6,5 KB gzip).

## 3. 500 marker / fps

O'lchov: `admin/src/components/map/liveUnitsGeoJson.perf.test.ts` (3 test — hammasi ✅).

| O'lchov | Qiymat |
|---|---|
| `buildLiveUnitsGeoJson(500 unit)` — median | **0,063 ms** |
| p95 (50 takror) | 0,078 ms |
| eng yomon holat (max / "sovuq" birinchi chaqiruv) | 0,126 ms / 0,306 ms |
| 30 fps kadr byudjeti | 33,3 ms |
| Kadr byudjetining ulushi | **~0,2 %** |

**Halol cheklov:** bu **haqiqiy GPU fps emas.** jsdom WebGL kontekstini bermaydi, shuning uchun
Vitest ichida MapLibre'ning render tsiklini o'lchab bo'lmaydi. O'lchangan narsa — klient tomonidagi
eng qimmat qadam: har WS `unit_last_state` / refetch tsiklida `source.setData()` ga uzatiladigan
GeoJSON `FeatureCollection` payload'ini qurish vaqti. Xulosa faqat shuni tasdiqlaydi: JS tomoni
kadr byudjetini yemaydi, ya'ni ≥30 fps ga erishish MapLibre GPU tomoniga bog'liq bo'lib qoladi
(klasterlash F167 — radius 50 px, `clusterMaxZoom` 14 — yoqilgan).

## 4. Qolgan ish — haqiqiy fps o'lchovi (Playwright/qo'lda)

Quyidagi qadamlar 9-bosqichda (CI) yoki qo'lda bajariladi:

1. **Ekran:** `/tracking/map` (Track on Map) — jonli kuzatuv qatlami, klasterlash yoqilgan holatda.
2. **Sinov ma'lumoti:** MSW handler `GET /tracking/live` uchun 500 ta `LiveUnit` qaytaradi —
   generator sifatida perf testidagi `buildUnits(500)` mantiqi ishlatiladi (4 duty status,
   3 online status, ~1° × 1° maydonga tarqatilgan, `heading_deg` har xil). Klasterlash haqiqatan
   sinovdan o'tishi uchun nuqtalarning bir qismi zich (bitta shahar ustida) bo'lishi shart.
   Qo'shimcha: har 1 s da WS orqali 50 ta `unit_last_state` yuborib, yangilanish yuki ham tekshiriladi.
3. **O'lchash usuli:** Playwright + CDP (`Page.startScreencast` yoki
   `client.send('Overlay.setShowFPSCounter')` o'rniga ishonchliroq yo'l) — `requestAnimationFrame`
   asosidagi sanagichni sahifaga inject qilib, 5 soniyalik uzluksiz pan + zoom (`map.panBy`,
   `map.zoomTo`) davomida kadrlar sonini yig'ish; hisobot: o'rtacha fps, 1% low, eng uzun kadr.
4. **Qabul mezoni:** o'rtacha ≥ 30 fps va 1% low ≥ 20 fps (TZ §15: "Xarita 500 unit bilan —
   ≥ 30 fps pan/zoom"). Muhit: desktop Chrome, 1280 px, GPU yoqilgan (headless `--use-gl=angle`).
5. **Joylashuv:** `admin/e2e/tracking-map.perf.spec.ts` (Playwright to'plami 4-bosqichda hali yo'q).

## 5. F224 — bundle hisoboti CI artefakti sifatida

**Holat: ochiq.** `rollup-plugin-visualizer` `admin/vite.config.ts` da sozlanmagan va
`package.json` da yo'q. Bu vazifada u **ataylab o'rnatilmadi** — yangi dependency qo'shilmadi.

Sabab va reja: F224 ning mohiyati — hisobotni **CI artefakti** qilish va chegara oshganda
ogohlantirish berish, ya'ni u CI pipeline'i bilan birga keladi. Shuning uchun **9-bosqichga
(CI/CD)** qoldirildi: o'sha yerda `rollup-plugin-visualizer` qo'shiladi (`stats.html` artefakt),
va yuqoridagi 1-bo'lim jadvalidagi uchta byudjet CI qadamiga aylantiriladi (chegara oshsa — ⚠️).
Hozircha byudjet nazorati qo'lda: `vite build` chiqishi + shu hisobotdagi `gzip -c` o'lchovlari.

---

## Xulosa

| Tekshiruv | Natija |
|---|---|
| Boshlang'ich JS ≤ 250 KB gzip | ✅ 118,2 KB |
| Route chunk o'rtacha ≤ 80 KB | ✅ 3,5 KB gzip / 9,8 KB raw |
| Xarita chunk ≤ 400 KB | ✅ 212,5 KB gzip (raw 784,7 KB) |
| Maplibre asosiy bundle'da yo'q (F165) | ✅ |
| `RouteListPage` maplibre'ni tortmaydi | ✅ (tuzatildi: 1 → 0) |
| 500 marker payload qurish ≪ kadr byudjeti | ✅ 0,063 ms / 33,3 ms |
| Haqiqiy ≥30 fps o'lchovi | ⏳ Playwright — 4-bo'limdagi qadamlar |
| F224 bundle hisoboti CI'da | ⏳ ochiq — 9-bosqich |
