---
name: fe-map
description: ELD Admin Panel frontendida MapLibre GL JS xarita komponenti (jonli kuzatuv, trip polyline, geofence, klasterlash) yozish yoki tahrirlashda ishlatiladi.
---

# Xarita (MapLibre GL JS)

## Texnologiya [MUST]

- **MapLibre GL JS v4** (`tz.md` B§6.2). React wrapper qo'lda yoziladi (`components/map/MapCanvas.tsx`) — `react-map-gl` qo'shimcha bog'liqlik sifatida qabul qilinmaydi (F3).
- **F164 ✅ Q1 YOPILDI (2026-09-07): tile provayderi — MapTiler Cloud (MVP), chiqish yo'li Protomaps/PMTiles self-hosting.**
  - Kalit **domen bo'yicha cheklangan** bo'lishi SHART (`eldadmin.stackyard.uz` + dev uchun `localhost`) — F9.
  - Style oilasi: kam kontrastli **basic / dataviz** (satellite yoki streets EMAS) — 500 ta duty-status markeri ustidan o'qilishi kerak.
  - CSP: `https://api.maptiler.com` → `connect-src` va `img-src` (§13).
  - Ko'chish yo'li: `VITE_MAP_STYLE_URL` + CSP hostini almashtirish, **kod o'zgarmaydi**.
  - To'liq qaror va asos: `docs/tz/16-17-registry-open-questions.md` → D-Q1.
  - Provayderga bog'liqlik qoidalari (o'zgarishsiz kuchda):
  - (a) style JSON `VITE_MAP_STYLE_URL` environment o'zgaruvchisi orqali beriladi;
  - (b) kalit domen bo'yicha cheklangan;
  - (c) kod hech bir provayderga **qattiq bog'lanmaydi** — `MapCanvas` faqat style URL qabul qiladi, provayderga xos API chaqirmaydi.
- **F165** Xarita komponenti **lazy** yuklanadi (`React.lazy`) — MapLibre ~800 KB, asosiy bundle'ga kirmaydi.

## Jonli kuzatuv [MUST]

- **Manba:** `GET /tracking/live` (dastlabki holat) + WS kanali `tracking` → `unit_last_state` hodisasi (batafsil: `fe-realtime` skill).
- **Marker:**
  - Duty status bo'yicha ikonka/rang: `DR` — strelka, `heading_deg` bo'yicha burilgan; `ON` — nuqta; `OFF` — pauza belgisi; `SB` — doira.
  - `online_status` bo'yicha halqa: online — yashil, offline — kulrang, disconnected — qizil.
- **Marker kartochkasi** (dizayn o'lchami 200×217 px): haydovchi nomi · holat · `Unit #` · `Odometer` · `Location` (tashqi havola ikonkasi) · nisbiy vaqt · `View Tracking ›` havolasi.
- **F166** Pozitsiya yangilanishi **animatsiya bilan** — MapLibre `easeTo`, davomiylik **500 ms** — sakrash (jump) bo'lmaydi. **60 soniyadan** eski nuqta **50% shaffof** ko'rsatiladi.
- **F167 [MUST] Klasterlash:**
  - `unit_last_state` nuqtalari **GeoJSON source + `cluster: true`**.
  - `cluster radius`: **50 px**.
  - `clusterMaxZoom`: **14**.
  - Maqsad: **500+ unit'da ham xarita 60 fps** ushlaydi.
  - Klaster bosilganda zoom qilinadi; oxirgi zoom darajasida bir joyga to'plangan nuqtalar uchun `spiderfy` o'rniga **ro'yxat popup'i** ko'rsatiladi.
- **F168** Xarita `bounds` (ko'rinish maydoni) o'zgarganda `GET /tracking/live` **qayta chaqirilmaydi** — backend bbox filtrini bermaydi. Barcha unit'lar bir marta olinadi, ko'rinish (viewport) klient tomonda filtrlanadi.

## Trip polyline [MUST]

- **Manba:**
  - `GET /units/{id}/trips?date=` → trip segmentlari ro'yxati.
  - `GET /trips/{id}?include_polyline=true` → to'liq geometriya.
- Chiziq stili: `primary` rangda, kenglik **4 px**, `line-cap: round`; to'xtash nuqtalari raqamli markerlar bilan belgilanadi (1, 2, 3…).
- Segment tanlanganda: qolgan segmentlar **30% shaffof**ga o'tadi, xarita `fitBounds` chaqiradi, `padding: 64px`.
- **F169** `include_polyline=true` parametri **faqat kerak bo'lganda** (masalan, bitta trip tanlanganda) so'raladi; ro'yxat (list) ko'rinishi uchun `false` — chunki javob hajmi katta bo'ladi.

## Geofence va marshrut

- **F170** Route'ning `geofence_m` radiusi manzil nuqtasi atrofida **doira** (`circle` layer) sifatida chiziladi: fill **10% `success`** rang, stroke **`success`** rang. Default radius **300 m** (`tz.md` Q66).
- `GET /routes/{id}/directions` — tavsiya etilgan yo'nalish, **uzuq chiziq** (`line-dasharray`), rang `neutral-400`.

## Umumiy qoidalar

- **F171** Xarita konteyneri: `<div role="application" aria-label="…">`. Klaviatura bilan zoom/pan MapLibre'ning o'rnatilgan `keyboard` xususiyati orqali yoqiladi. Xarita **yagona** ma'lumot manbai bo'lmaydi — har xarita yonida jadval/ro'yxat ko'rinishidagi ekvivalent bo'lishi shart (a11y talabi, §14.2).
- **F172** Reverse-geocoding backendda amalga oshiriladi (`tz.md` Q9, B§7.3) — frontend geocoding API'ga **to'g'ridan-to'g'ri so'rov yubormaydi**. Backend matn (manzil) bermasa — xom `lat, lng` ko'rsatiladi.
- **Performans maqsadlari** (§14.3 bilan mos):
  - 500 marker'da xarita ≥ **30 fps** ushlab turadi (klasterlash bilan amalda 60 fps ga yaqin, F167).
  - Xarita chunk (lazy) bundle hajmi ≤ **400 KB**.
- `prefers-reduced-motion` yoqilgan bo'lsa — `easeTo` animatsiyasi (F166) o'chiriladi yoki davomiyligi 0 ga tushiriladi, marker darhol yangi joyga qo'yiladi.

## Raqamli sozlamalar — tezkor jadval

| Parametr | Qiymat | Qayerda |
|---|---|---|
| Cluster radius | 50 px | Jonli kuzatuv (F167) |
| Cluster max zoom | 14 | Jonli kuzatuv (F167) |
| Marker animatsiyasi (`easeTo`) | 500 ms | Jonli kuzatuv (F166) |
| Eskirgan nuqta shaffofligi | 60 s dan keyin 50% | Jonli kuzatuv (F166) |
| Trip polyline kengligi | 4 px, `line-cap: round` | Trip polyline |
| `fitBounds` padding | 64 px | Trip polyline |
| Segment shaffofligi (tanlanmagan) | 30% | Trip polyline |
| Geofence fill shaffofligi | 10% (`success` rang) | Geofence |
| Geofence default radius | 300 m | Geofence |
| Marker kartochkasi o'lchami | 200×217 px | Jonli kuzatuv |
| MapLibre bundle hajmi | ~800 KB (lazy chunk) | Texnologiya (F165) |
| Xarita chunk byudjeti | ≤ 400 KB | Umumiy qoidalar / §14.3 |
| 500 marker'dagi fps maqsadi | ≥ 30 fps (amalda ~60 fps) | Umumiy qoidalar |

## MapCanvas dizayn cheklovlari — amaliy eslatma

- `MapCanvas` props sifatida faqat `styleUrl` (env `VITE_MAP_STYLE_URL`dan), markerlar/GeoJSON ma'lumoti va event handler'larni qabul qiladi — hech qanday provayderga xos SDK yoki API kaliti to'g'ridan-to'g'ri komponent ichida chaqirilmaydi (F164).
- Kod yozishdan oldin tekshir: yangi qo'shilayotgan xarita xususiyati `react-map-gl` yoki boshqa wrapper kutubxonasiga bog'liq bo'lib qolmasligi kerak — faqat `maplibre-gl` ustiga qo'lda wrapper (F3).
- Jonli kuzatuv qatlami har doim GeoJSON `source` + `cluster: true` orqali qo'shiladi (raw marker'lar emas) — 500+ unit stsenariysida bu majburiy (F167).
- `bounds` o'zgarishi hech qachon qayta `GET /tracking/live` so'rovini triggerlamaydi — filtr faqat client-side (F168).
- `include_polyline=true` so'ralishi kerak bo'lgan joylarni aniqlashda qoida: faqat bitta trip ochilganda, ro'yxat/jadval ko'rinishida hech qachon (F169).

## Tekshiruv ro'yxati (implementatsiyadan oldin)

- [ ] Xarita komponenti `React.lazy` bilan o'raladimi (F165)?
- [ ] `VITE_MAP_STYLE_URL` orqali style JSON olinyaptimi, provayderga qattiq bog'liqlik yo'qmi (F164)?
- [ ] Klasterlash radius 50 px / maxZoom 14 bilan sozlanganmi (F167)?
- [ ] Marker o'tishlari `easeTo` 500 ms, `prefers-reduced-motion`da o'chadimi?
- [ ] Trip polyline faqat kerak bo'lganda `include_polyline=true` bilan so'ralyaptimi (F169)?
- [ ] Geofence doirasi to'g'ri rang/shaffoflik va default 300 m bilan chizilyaptimi (F170)?
- [ ] Reverse-geocoding frontendda emas, backend javobidan olinyaptimi (F172)?
- [ ] Xarita yonida jadval/ro'yxat ekvivalenti bormi (a11y, F171)?

## To'liq manba

`docs/tz-admin-frontend.md`, §9 «Xarita», qatorlar 1428–1463.
