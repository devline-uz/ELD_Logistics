-- +goose Up
-- TZ A§14 (Distance by Region) `regions` jadvaliga tayanadi; jadval bo'sh
-- bo'lsa hisobot doim bo'sh qaytadi. Bu migratsiya uchta hudud to'plami uchun
-- ma'lumotnoma qatorlarini yozadi: PK (7 viloyat/hudud), UZ (14 viloyat),
-- US (50 shtat + DC, IFTA uchun).
--
-- Kodlar ISO 3166-2 formatida (masalan "US-IL", "UZ-TK", "PK-PB") — mavjud
-- test fixture'lari va DTO example'lari (`internal/domain/reports/dto`) shu
-- formatni ishlatadi.
--
-- GEOM: haqiqiy chegara poligonlari bu yerda YO'Q — ularni xotiradan taxminan
-- yozish xavfli (masofa/soliq hisobotini buzadi). Faqat bitta NAMUNA poligon
-- (UZ-TK, Toshkent shahri uchun soddalashtirilgan to'rtburchak) qo'yilgan —
-- import mexanizmini ST_Contains bilan sinash uchun, ishlab chiqarishga
-- yaroqsiz. Qolgan barcha hududlarda geom = NULL; ular
-- `FindRegionByPoint` so'rovida e'tiborga olinmaydi (`WHERE geom IS NOT
-- NULL`), ya'ni hisobot xato natija bermaydi — shunchaki o'sha hudud uchun
-- masofa hisoblanmaydi, GeoJSON import qilingunga qadar.
--
-- Rasmiy geom'larni qanday import qilish: deploy/regions/README.md.
-- +goose StatementBegin
INSERT INTO regions (code, name, country, geom) VALUES
  -- Pakistan (7) — TZ topshirig'i: Punjab, Sindh, Khyber Pakhtunkhwa,
  -- Balochistan, Gilgit-Baltistan, Azad Jammu & Kashmir, Islamabad Capital
  -- Territory.
  ('PK-PB', 'Punjab',                       'PK', NULL),
  ('PK-SD', 'Sindh',                        'PK', NULL),
  ('PK-KP', 'Khyber Pakhtunkhwa',           'PK', NULL),
  ('PK-BA', 'Balochistan',                  'PK', NULL),
  ('PK-GB', 'Gilgit-Baltistan',             'PK', NULL),
  ('PK-JK', 'Azad Jammu & Kashmir',         'PK', NULL),
  ('PK-IS', 'Islamabad Capital Territory',  'PK', NULL),

  -- O'zbekiston (14 viloyat/respublika/shahar).
  ('UZ-AN', 'Andijon',                          'UZ', NULL),
  ('UZ-BU', 'Buxoro',                           'UZ', NULL),
  ('UZ-FA', 'Farg''ona',                        'UZ', NULL),
  ('UZ-JI', 'Jizzax',                           'UZ', NULL),
  ('UZ-XO', 'Xorazm',                           'UZ', NULL),
  ('UZ-NG', 'Namangan',                         'UZ', NULL),
  ('UZ-NW', 'Navoiy',                           'UZ', NULL),
  ('UZ-QA', 'Qashqadaryo',                      'UZ', NULL),
  ('UZ-QR', 'Qoraqalpog''iston Respublikasi',   'UZ', NULL),
  ('UZ-SA', 'Samarqand',                        'UZ', NULL),
  ('UZ-SI', 'Sirdaryo',                         'UZ', NULL),
  ('UZ-SU', 'Surxondaryo',                      'UZ', NULL),
  ('UZ-TO', 'Toshkent viloyati',                'UZ', NULL),
  -- SAMPLE DATA, replace with official GeoJSON (deploy/regions/README.md).
  -- Toshkent shahri uchun soddalashtirilgan to'rtburchak (taxminiy chegara,
  -- ~69.15-69.35E, ~41.20-41.38N) — faqat ST_Contains/import mexanizmini
  -- sinash uchun, masofa hisobotida ishlatishga yaroqsiz.
  ('UZ-TK', 'Toshkent shahri', 'UZ',
   ST_Multi(ST_SetSRID(ST_GeomFromText(
     'POLYGON((69.15 41.20, 69.35 41.20, 69.35 41.38, 69.15 41.38, 69.15 41.20))'
   ), 4326))),

  -- AQSh — 50 shtat + Kolumbiya okrugi (IFTA hisoboti uchun, [MAY]).
  -- Hajm sababli (aniq shtat chegaralari GADM/Natural Earth'dan olinishi
  -- kerak) geom bu yerda NULL qoldirilgan — TODO: deploy/regions/us.geojson
  -- import qilingach ushbu kodlarga UPDATE beriladi (README ko'rsatmasi).
  ('US-AL', 'Alabama',              'US', NULL),
  ('US-AK', 'Alaska',               'US', NULL),
  ('US-AZ', 'Arizona',              'US', NULL),
  ('US-AR', 'Arkansas',             'US', NULL),
  ('US-CA', 'California',           'US', NULL),
  ('US-CO', 'Colorado',             'US', NULL),
  ('US-CT', 'Connecticut',          'US', NULL),
  ('US-DE', 'Delaware',             'US', NULL),
  ('US-FL', 'Florida',              'US', NULL),
  ('US-GA', 'Georgia',              'US', NULL),
  ('US-HI', 'Hawaii',               'US', NULL),
  ('US-ID', 'Idaho',                'US', NULL),
  ('US-IL', 'Illinois',             'US', NULL),
  ('US-IN', 'Indiana',              'US', NULL),
  ('US-IA', 'Iowa',                 'US', NULL),
  ('US-KS', 'Kansas',               'US', NULL),
  ('US-KY', 'Kentucky',             'US', NULL),
  ('US-LA', 'Louisiana',            'US', NULL),
  ('US-ME', 'Maine',                'US', NULL),
  ('US-MD', 'Maryland',             'US', NULL),
  ('US-MA', 'Massachusetts',        'US', NULL),
  ('US-MI', 'Michigan',             'US', NULL),
  ('US-MN', 'Minnesota',            'US', NULL),
  ('US-MS', 'Mississippi',          'US', NULL),
  ('US-MO', 'Missouri',             'US', NULL),
  ('US-MT', 'Montana',              'US', NULL),
  ('US-NE', 'Nebraska',             'US', NULL),
  ('US-NV', 'Nevada',               'US', NULL),
  ('US-NH', 'New Hampshire',        'US', NULL),
  ('US-NJ', 'New Jersey',           'US', NULL),
  ('US-NM', 'New Mexico',           'US', NULL),
  ('US-NY', 'New York',             'US', NULL),
  ('US-NC', 'North Carolina',       'US', NULL),
  ('US-ND', 'North Dakota',         'US', NULL),
  ('US-OH', 'Ohio',                 'US', NULL),
  ('US-OK', 'Oklahoma',             'US', NULL),
  ('US-OR', 'Oregon',               'US', NULL),
  ('US-PA', 'Pennsylvania',         'US', NULL),
  ('US-RI', 'Rhode Island',         'US', NULL),
  ('US-SC', 'South Carolina',       'US', NULL),
  ('US-SD', 'South Dakota',         'US', NULL),
  ('US-TN', 'Tennessee',            'US', NULL),
  ('US-TX', 'Texas',                'US', NULL),
  ('US-UT', 'Utah',                 'US', NULL),
  ('US-VT', 'Vermont',              'US', NULL),
  ('US-VA', 'Virginia',             'US', NULL),
  ('US-WA', 'Washington',           'US', NULL),
  ('US-WV', 'West Virginia',        'US', NULL),
  ('US-WI', 'Wisconsin',            'US', NULL),
  ('US-WY', 'Wyoming',              'US', NULL),
  ('US-DC', 'District of Columbia', 'US', NULL)
ON CONFLICT (code) DO UPDATE SET
  name       = EXCLUDED.name,
  country    = EXCLUDED.country,
  -- Kelajakda rasmiy GeoJSON import migratsiyasi shu kodlarni UPDATE qiladi;
  -- bu yerda EXCLUDED.geom har doim NULL bo'lgani uchun mavjud geom
  -- (agar allaqachon yuklangan bo'lsa) hech qachon NULL bilan ustidan
  -- yozilmaydi.
  geom       = COALESCE(EXCLUDED.geom, regions.geom),
  updated_at = now();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM regions WHERE code IN (
  'PK-PB','PK-SD','PK-KP','PK-BA','PK-GB','PK-JK','PK-IS',
  'UZ-AN','UZ-BU','UZ-FA','UZ-JI','UZ-XO','UZ-NG','UZ-NW','UZ-QA','UZ-QR',
  'UZ-SA','UZ-SI','UZ-SU','UZ-TO','UZ-TK',
  'US-AL','US-AK','US-AZ','US-AR','US-CA','US-CO','US-CT','US-DE','US-FL',
  'US-GA','US-HI','US-ID','US-IL','US-IN','US-IA','US-KS','US-KY','US-LA',
  'US-ME','US-MD','US-MA','US-MI','US-MN','US-MS','US-MO','US-MT','US-NE',
  'US-NV','US-NH','US-NJ','US-NM','US-NY','US-NC','US-ND','US-OH','US-OK',
  'US-OR','US-PA','US-RI','US-SC','US-SD','US-TN','US-TX','US-UT','US-VT',
  'US-VA','US-WA','US-WV','US-WI','US-WY','US-DC'
);
-- +goose StatementEnd
