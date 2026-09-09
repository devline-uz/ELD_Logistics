# ELD Admin Panel — deploy (statik SPA)

Vazifalar 9.9 (CSP + xavfsizlik header'lari), 9.11 (deploy, SPA fallback,
gzip, cache), 9.12 (sourcemap serverdan olib tashlanadi).

Maqsad muhit: **`https://eldadmin.stackyard.uz`** — nginx, statik build,
backend bilan bir domenda EMAS (API `eldapi.stackyard.uz`).

Konfiguratsiya fayllari repoda: [`admin/deploy/`](../admin/deploy/)

| Fayl                            | Nima uchun                                              |
| ------------------------------- | ------------------------------------------------------- |
| `deploy/nginx.conf`             | server bloki: TLS, SPA fallback, cache, `.map` → 404     |
| `deploy/csp.conf`               | `$eld_csp` o'zgaruvchisi (CSP manbalari + izohlar)       |
| `deploy/security-headers.conf`  | CSP, HSTS, nosniff, Referrer/Permissions-Policy         |

---

## 1. Build

```bash
cd admin
cp .env.example .env.production      # prod qiymatlarini to'ldiring
npm ci
npm run build                        # tsc -b --noEmit + vite build -> dist/
npm run bundle:budget                # byudjet + inline-script + console.* darvozasi
```

`.env.production` da to'ldirilishi shart:

| O'zgaruvchi               | Prod qiymati                                             |
| ------------------------- | -------------------------------------------------------- |
| `VITE_API_BASE_URL`       | `https://eldapi.stackyard.uz/api/v1`                     |
| `VITE_WS_URL`             | `wss://eldapi.stackyard.uz/api/v1/ws`                    |
| `VITE_MAP_STYLE_URL`      | MapTiler style JSON — **kalit domen bo'yicha cheklangan** |
| `VITE_FILES_BASE_URL`     | fayl hostining `https://` bazasi                          |
| `VITE_FILES_UPLOAD_HOST`  | presign `upload_url` uchun host oq ro'yxati               |
| `VITE_SENTRY_DSN`         | ixtiyoriy (§5)                                            |

> `DOCS_TOKEN` **hech qachon** prod env'ga qo'yilmaydi — u faqat dev vaqtida
> `npm run api` uchun kerak va bundle'ga tushmaydi.

Bundle tarkibini ko'rish kerak bo'lsa:

```bash
npm run build:analyze     # -> docs/bundle-stats.html (gitignored)
```

## 2. Fayllarni serverga ko'chirish

```bash
rsync -av --delete \
      --exclude '*.map' \
      admin/dist/ deploy@eldadmin.stackyard.uz:/var/www/eldadmin/
```

**`--exclude '*.map'` majburiy (F211 / TD8).** `vite.config.ts` da
`build.sourcemap: 'hidden'` — brauzer sourcemap'ni **so'ramaydi** (bundle'da
`//# sourceMappingURL` izohi yo'q), lekin `.map` fayllari `dist/` da
yaratiladi. Ular serverga chiqsa, manba kodi (biznes mantiqi, ruxsat
kalitlari, ichki endpoint nomlari) ochiq bo'lib qoladi. Ikkinchi qatlam
himoya — nginx `location ~* \.map$ { return 404; }`.

Sourcemap'lar **build mashinasida saqlanadi** va faqat xato monitoringiga
(Sentry release artefakti) qo'lda yuklanadi — §5.

`--delete` eski hash'li chunk'larni tozalaydi. Agar zero-downtime kerak
bo'lsa, avval yangi assetlarni `--delete` siz yuklang, keyin `index.html` ni
almashtiring, so'ng ikkinchi o'tishda `--delete` bilan tozalang.

## 3. nginx konfiguratsiyasi

```bash
sudo mkdir -p /etc/nginx/eld
sudo cp admin/deploy/csp.conf              /etc/nginx/eld/csp.conf
sudo cp admin/deploy/security-headers.conf /etc/nginx/eld/security-headers.conf
sudo cp admin/deploy/nginx.conf            /etc/nginx/sites-available/eldadmin.conf
sudo ln -sf /etc/nginx/sites-available/eldadmin.conf /etc/nginx/sites-enabled/

# csp.conf `http {}` konteksida bo'lishi kerak (unda `map` direktivalari bor):
#   /etc/nginx/nginx.conf -> http { include /etc/nginx/eld/csp.conf; ... }

sudo nginx -t && sudo systemctl reload nginx
```

TLS sertifikati: `sudo certbot --nginx -d eldadmin.stackyard.uz`.

### Nima yoqilgan

- **SPA fallback** — `try_files $uri $uri/ /index.html`; `/units/42` kabi
  chuqur havolalar to'g'ridan-to'g'ri ochiladi, 404 ni React Router beradi.
- **`index.html` → `no-cache, must-revalidate`** — yangi deploy'dan keyin
  foydalanuvchi eski HTML'ni olib, o'chirilgan chunk'ni so'ramaydi.
- **`/assets/*` → `public, max-age=31536000, immutable`** — fayl nomida
  content-hash bor, revalidatsiya kerak emas.
- **gzip** — `nginx.conf` boshidagi izohli blok `http {}` ga ko'chiriladi.
  **Brotli** (tavsiya): `libnginx-mod-brotli` + `brotli_static on`; shunda
  build'dan keyin `find dist -type f \( -name '*.js' -o -name '*.css' \)
  -exec brotli -kf {} \;` qilinadi va nginx `.br` fayllarni beradi.

## 4. CSP rollout (ikki bosqich)

CSP xatosi ekranni **jimgina** buzadi (xarita yuklanmaydi, WS ulanmaydi),
shuning uchun avval kuzatuv bosqichi.

**1-bosqich — Report-Only (kamida 48 soat, ikkala fleet turi bilan):**
`security-headers.conf` da `Content-Security-Policy-Report-Only` satrini
yoqing, bloklovchi `Content-Security-Policy` ni izohga oling.

Quyidagi oqimlarni qo'lda bosib chiqing va DevTools → Console'da CSP
ogohlantirishlari **yo'qligini** tekshiring:

- [ ] Login → dashboard (API + WS ulanishi)
- [ ] Tracking xaritasi: tile yuklanishi, marker klasteri, popup
- [ ] Trip xaritasi: polyline, `fitBounds`
- [ ] DVIR: foto/imzo ko'rish (fayl hosti `img-src`)
- [ ] Fayl yuklash: presign → `PUT` (fayl hosti `connect-src`)
- [ ] Eksport: PDF/CSV `blob` yuklab olish
- [ ] Driver QR kod (`data:` URL `img-src`)
- [ ] Har bir ekranning chop etish/eksport dialogi

**2-bosqich — bloklovchi:** ogohlantirish 0 bo'lsa, satrlarni almashtiring
va `nginx -t && systemctl reload nginx`.

> `report-uri`/`report-to` qo'shilmagan: hisobotlarni yig'adigan endpoint
> hozircha yo'q. Sentry ulangach `report-uri <sentry-csp-endpoint>` qo'shish
> tavsiya etiladi (§5).

## 5. Sentry (ixtiyoriy, 9.12)

SDK **ulangan**, lekin **o'chirilgan holatda keladi**: `VITE_SENTRY_DSN`
bo'sh bo'lsa `@sentry/react` chunk'i umuman so'ralmaydi (`src/lib/sentry.ts`
dagi dinamik `import()`; SDK ga yagona statik havola —
`src/lib/sentry.client.ts`, u faqat `init` + `captureException` ni import
qiladi, Session Replay/tracing bundle'ga kirmaydi), bundle byudjetiga ta'sir yo'q va ilova xuddi
avvalgidek ishlaydi.

### Yoqish

1. `.env.production` (yoki CI env) da `VITE_SENTRY_DSN` ni to'ldiring.
2. **CSP ni yangilang** — bu qadam majburiy, aks holda hodisalar bloklanadi.
   DSN quyidagi ko'rinishda bo'ladi:

   ```
   https://<public-key>@<ORG_ID>.ingest.<REGION>.sentry.io/<project-id>
   ```

   `connect-src` ga `https://<ORG_ID>.ingest.<REGION>.sentry.io` origin'i
   qo'shiladi — `admin/deploy/csp.conf` dagi `$eld_csp_connect` map bloki:

   ```nginx
   map $host $eld_csp_connect {
       default "https://eldapi.stackyard.uz wss://eldapi.stackyard.uz https://api.maptiler.com https://files.stackyard.uz https://o0000000.ingest.de.sentry.io";
   }
   ```

   Self-hosted Sentry bo'lsa — o'sha o'rnatmaning to'liq origin'i.
   `nginx -t && systemctl reload nginx`, so'ng brauzer konsolida
   `Refused to connect` xatosi yo'qligini tekshiring.
3. **Sourcemap yuklash (ixtiyoriy).** Build muhitida quyidagilar berilsa
   `@sentry/vite-plugin` avtomatik faollashadi:

   ```bash
   SENTRY_AUTH_TOKEN=...   # CI secret, `VITE_` prefiksi YO'Q -> bundle'ga tushmaydi
   SENTRY_ORG=...
   SENTRY_PROJECT=...
   SENTRY_RELEASE=$(git rev-parse --short HEAD)
   npm run build
   ```

   Plagin `.map` fayllarini yuklab, so'ng `dist/` dan **o'chiradi**
   (`sourcemaps.filesToDeleteAfterUpload`). Token bo'lmasa plagin build'ga
   umuman ulanmaydi. `rsync --exclude '*.map'` va nginx `.map -> 404`
   ikkinchi himoya sifatida qoladi (TD8).

### PII kafolati (F206)

`src/lib/sentry.scrub.ts` dagi `beforeSend`/`beforeBreadcrumb` har hodisani
tozalaydi:

- `request.cookies` butunlay olib tashlanadi;
- `Authorization`, `Cookie`, `X-Api-Key` header'lari -> `••••••`;
- `access_token`/`refresh_token`/`token`/`code` — obyekt maydoni sifatida
  ham, URL query parametri sifatida ham maskalanadi;
- parol, `secret`, `otp/totp`, `license_no` — `lib/sensitive.ts` dagi umumiy
  sezgir maydon ro'yxati orqali;
- haydovchi/foydalanuvchi ismi, email, telefon, manzil, VIN, davlat raqami;
- `user` obyektidan faqat `id` qoladi;
- `sendDefaultPii: false`.

Yangi sezgir maydon paydo bo'lsa — `PII_FIELD_PATTERN` ga qo'shing va
`src/lib/sentry.test.ts` ga holat yozing.

## 6. Deploy'dan keyingi tekshiruv

```bash
curl -sI https://eldadmin.stackyard.uz/ | grep -i \
  'content-security-policy\|strict-transport\|x-content-type\|referrer\|permissions'

curl -sI https://eldadmin.stackyard.uz/assets/ -o /dev/null -w '%{http_code}\n'
curl -s  -o /dev/null -w '%{http_code}\n' https://eldadmin.stackyard.uz/units/42   # 200 (SPA fallback)
curl -s  -o /dev/null -w '%{http_code}\n' https://eldadmin.stackyard.uz/assets/x.map # 404
```

- [ ] <https://securityheaders.com/?q=eldadmin.stackyard.uz> → **A** yoki **A+**
- [ ] <https://csp-evaluator.withgoogle.com/> — `script-src` da
      `'unsafe-inline'`/`'unsafe-eval'` yo'q
- [ ] <https://www.ssllabs.com/ssltest/> → **A**
- [ ] `curl` bilan `.map` fayl 404 qaytaradi
- [ ] Chuqur havola (`/units/42`) to'g'ridan-to'g'ri ochiladi
- [ ] `index.html` javobida `Cache-Control: no-cache`
- [ ] `/assets/*.js` javobida `immutable, max-age=31536000` va
      `Content-Encoding: gzip` (yoki `br`)

## 7. Rollback

Har release'ni sanali papkaga chiqarib, `current` symlink'ini almashtirish
tavsiya etiladi:

```
/var/www/eldadmin-releases/2026-09-09T10-00/
/var/www/eldadmin -> eldadmin-releases/2026-09-09T10-00
```

Rollback = symlink'ni oldingi papkaga qaytarish + `nginx -s reload`.
`index.html` keshlanmagani uchun qaytish darhol kuchga kiradi.
