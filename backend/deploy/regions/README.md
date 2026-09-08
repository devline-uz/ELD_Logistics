# `regions` — rasmiy GeoJSON import qo'llanmasi

TZ A§14 (Distance by Region) `regions.geom` ustuniga tayanadi. Kod bazasidagi
`00027_regions_seed_data.sql` migratsiyasi faqat `code`/`name`/`country`
qatorlarini (PK 7 ta, UZ 14 ta, US 50+DC) yozadi — **haqiqiy chegara
poligonlari yo'q**, chunki ularni xotiradan taxminan yozish xavfli (masofa
hisoboti soliq/regulyator maqsadida ishlatiladi). Bitta `UZ-TK` (Toshkent
shahri) qatorida faqat sinov uchun soddalashtirilgan to'rtburchak bor —
u ishlab chiqarishga yaroqsiz va `-- SAMPLE DATA, replace with official
GeoJSON` deb belgilangan.

## 1. Rasmiy manba tanlash

| Hudud | Tavsiya etilgan manba |
|---|---|
| PK (Pokiston viloyatlari) | [GADM v4.1](https://gadm.org/download_country.html) — "Pakistan", level 1; yoki [OSM Nominatim](https://nominatim.openstreetmap.org) relation eksporti (`admin_level=4`) |
| UZ (O'zbekiston viloyatlari) | [GADM v4.1](https://gadm.org/download_country.html) — "Uzbekistan", level 1; yoki OSM Nominatim (`admin_level=4`) |
| US (50 shtat + DC) | [Natural Earth 1:10m Admin 1](https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-admin-1-states-provinces/) yoki [US Census TIGER/Line states](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html) (soddalashtirilgan/generalized versiyani oling — TIGER xom fayllari juda katta) |

GADM'dan yuklaganda **"Shapefile" emas, "GeoJSON"** formatini tanlang (yoki
`ogr2ogr -f GeoJSON out.geojson in.shp` bilan konvertatsiya qiling). Fayl
hajmi katta bo'lsa, `mapshaper` bilan soddalashtiring (masalan
`mapshaper in.geojson -simplify 10% -o out.geojson`), aks holda poligon
Postgres tranzaksiyasi va sqlc uchun keraksiz og'irlik qo'shadi.

## 2. Talab qilinadigan format

- CRS: **EPSG:4326** (lat/lng, WGS84). Boshqa CRS bo'lsa
  `ogr2ogr -t_srs EPSG:4326` bilan qayta proyeksiyalang.
- Geometriya turi: `Polygon` yoki `MultiPolygon` (ikkalasi ham qabul
  qilinadi — skript ularni `ST_Multi()` bilan `MultiPolygon`'ga normallashtiradi).
- Har feature'da bizning `regions.code` bilan mos keladigan ustun bo'lishi
  kerak. GADM uchun odatda bu `HASC_1` yoki `GID_1` emas, balki siz qo'lda
  moslaydigan xarita — shuning uchun skript `--code-field` va
  `--code-map` orqali moslashtirish imkonini beradi (pastda misol).
- Bizning kod formati **ISO 3166-2** ga mos: `PK-PB`, `UZ-TK`, `US-IL` va
  h.k. (to'liq ro'yxat — `00027_regions_seed_data.sql`).

## 3. Fayllarni joylashtirish

```
backend/deploy/regions/
  pk.geojson   # Pokiston viloyatlari, "code" property = PK-xx
  uz.geojson   # O'zbekiston viloyatlari, "code" property = UZ-xx
  us.geojson   # AQSh shtatlari, "code" property = US-xx
```

Har feature'ning `properties` ichida kamida `code` bo'lishi kerak. Agar
manba faylda boshqa nom ostida bo'lsa (masalan `iso_3166_2`, `postal`,
`NAME_1`), `geojson_to_migration.py --code-field <ustun_nomi>` bilan
ko'rsating, yoki avval `jq` bilan qayta nomlang:

```sh
jq '.features[].properties.code = .features[].properties.postal' us.geojson > us.fixed.geojson
```

## 4. Migratsiya generatsiya qilish

Migratsiyalar **forward-only** va qo'lda tahrirlanmaydi — shuning uchun
import alohida **yangi** goose migratsiyasi sifatida generatsiya qilinadi
(`ST_GeomFromGeoJSON` bilan, TZ D§1 talabiga mos). Buni qo'lda emas, ushbu
skript bilan bajaring — u GeoJSON'ni parametrlangan emas, balki to'g'ridan
literal SQL qatoriga aylantiradi (in'ektsiya xavfi yo'q, chunki migratsiya
CI/CD orqali tekshiruvdan o'tadi va foydalanuvchi kiritmaydigan statik SQL
fayl hosil qiladi — lekin baribir `geojson_to_migration.py` GeoJSON'ni
`json.dumps` bilan qat'iy escape qiladi):

```sh
cd backend
python3 deploy/regions/geojson_to_migration.py \
  --input deploy/regions/pk.geojson \
  --country PK \
  --out db/migrations/00028_regions_official_pk.sql

python3 deploy/regions/geojson_to_migration.py \
  --input deploy/regions/uz.geojson \
  --country UZ \
  --out db/migrations/00029_regions_official_uz.sql

python3 deploy/regions/geojson_to_migration.py \
  --input deploy/regions/us.geojson \
  --country US \
  --out db/migrations/00030_regions_official_us.sql
```

Har generatsiya qilingan migratsiya faylini **commit qilishdan oldin
sharhlab chiqing** (`git diff --stat`, va bir nechta qatorini ko'zdan
kechiring) — bu haqiqiy migratsiya fayli, keyin hech qachon tahrirlanmaydi.

Skript har `code` uchun quyidagi shakldagi idempotent `UPDATE` chiqaradi
(qator mavjud bo'lishi shart — `code` mos kelmasa, migratsiya `RAISE
EXCEPTION` bilan to'xtaydi, shuning uchun avval `code` mosligini
tekshiring):

```sql
UPDATE regions
SET geom = ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon",...}'), 4326)),
    updated_at = now()
WHERE code = 'PK-PB';
```

## 5. Qo'llash

```sh
cd backend
goose -dir db/migrations postgres "$DATABASE_URL" up
```

`sqlc generate` **shart emas** — bu faqat ma'lumot, sxema/query o'zgarmaydi.

## 6. Tekshirish

```sql
SELECT code, name, ST_IsValid(geom), ST_Area(geom::geography) / 1e6 AS area_km2
FROM regions WHERE country = 'PK';

-- Ma'lum bir nuqta qaysi hududda ekanini tekshirish (masalan Islamabad markazi):
SELECT code, name FROM regions
WHERE ST_Contains(geom, ST_SetSRID(ST_MakePoint(73.0479, 33.6844), 4326))
ORDER BY ST_Area(geom::geography) ASC LIMIT 1;
```

`ST_IsValid` `false` qaytarsa, import oldidan
`ST_MakeValid(geom)` bilan tuzating (skript avtomatik qo'llaydi, agar
`--make-valid` bayrog'i berilsa).
