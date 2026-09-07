---
name: fe-security
description: ELD Admin Panel frontendida xavfsizlik ko'rigi (CSP, token saqlash, XSS, PII, tenant izolyatsiyasi, WS auth, fayl MIME tekshiruvi) o'tkazishda — ayniqsa frontend-security-reviewer agenti uchun chek-list sifatida — ishlatiladi.
---

# fe-security — ELD Admin Panel xavfsizlik chek-listi

Bu skill `docs/tz-admin-frontend.md` §13 ning siqilgan bilimi (qatorlar 1589–1620). Har band — tekshiriladigan holat: **nima qidiriladi** va **qaysi fayllarda**.

## 1. XSS **[MUST — F201]**

- **Nima qidiriladi:** `dangerouslySetInnerHTML` ishlatilishi. Bu **taqiqlangan** (ESLint `react/no-danger` error bo'lishi kerak).
- Markdown/HTML render qilish zarur bo'lsa — faqat `DOMPurify` bilan tozalangan, alohida ko'rib chiqilgan komponentda.
- Foydalanuvchi kiritgan matn (chat, notes, ticket, feedback, audit `changes`) — faqat matn tugunlari sifatida render qilinishi kerak, HTML sifatida emas.
- **Qayerda tekshiriladi:** `.eslintrc*` (`react/no-danger` qoidasi mavjudligi), chat/notes/ticket/feedback komponentlari, audit log diff ko'rsatuvchi komponentlar, `grep -r "dangerouslySetInnerHTML"` butun `src/` bo'yicha — natija bo'lsa faqat DOMPurify bilan sanitizatsiya qilingan yagona joyda bo'lishi kerak.

## 2. URL injection **[MUST — F202]**

- **Nima qidiriladi:** foydalanuvchi ma'lumotidan olingan havolalar (`Location` tashqi havolasi, `download_url`) `https?:` sxemasi bo'yicha tekshirilishi kerak; `javascript:` va `data:` sxemalari bloklanishi kerak.
- Tashqi havolalar `rel="noopener noreferrer" target="_blank"` bilan ochilishi shart.
- **Qayerda tekshiriladi:** tashqi link render qiluvchi komponentlar (masalan xarita/location linklari, fayl yuklab olish linklari, chat/notes ichidagi linklar), URL validatsiya util funksiyasi (`lib/` ichida bo'lishi kerak).

## 3. CSP va HTTP header'lar **[MUST — F203, F204]**

- **Nima qidiriladi:** `eldadmin.stackyard.uz` uchun HTTP header sifatida CSP (`<meta>` faqat zaxira sifatida). To'liq CSP:

```
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';           /* Tailwind runtime style'lari uchun */
img-src 'self' data: blob: https://api.maptiler.com;
font-src 'self';
connect-src 'self' https://eldapi.stackyard.uz wss://eldapi.stackyard.uz https://api.maptiler.com https://<storage-host>;
worker-src 'self' blob:;                     /* MapLibre worker */
frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none';
upgrade-insecure-requests
```

- Qo'shimcha header'lar (barchasi majburiy): `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: geolocation=(), camera=(), microphone=()`, `Strict-Transport-Security`.
- `script-src` da **`'unsafe-inline'` va `'unsafe-eval'` bo'lmasligi shart.** Vite prod build inline skript yaratmasin (`build.modulePreload` sozlamasi, `index.html` da inline `<script>` yo'q).
- **Qayerda tekshiriladi:** server/CDN konfiguratsiyasi (nginx/vercel/CDN header sozlamalari, deploy konfiguratsiya fayllari), `index.html`, `vite.config.ts` (`build.modulePreload`), build chiqishi (`dist/`) da inline `<script>` yo'qligi.

## 4. Token saqlash **[MUST — F205, xochilova F14]**

- **Nima qidiriladi:** `access_token` faqat JS xotirasida (Zustand store, `persist` YO'Q) saqlanishi kerak.
- `refresh_token` — faqat `sessionStorage`da, kalit `eld.rt`.
- **`localStorage`da hech qachon token bo'lmasligi shart** — na `access_token`, na `refresh_token`.
- Xotira token'i sahifa yangilanishida yo'qolib, refresh orqali tiklanishi kutiladi (bu — kutilgan xatti-harakat, xato emas).
- **Qayerda tekshiriladi:** auth store (`src/store/auth*` yoki shunga o'xshash), `zustand` persist middleware ishlatilishi (bo'lmasligi kerak `access_token` uchun), `grep -rn "localStorage" src/` — auth-bilan bog'liq hech qanday yozuv chiqmasligi kerak.

## 5. Sezgir ma'lumot (PII) **[MUST — F206]**

- **Nima qidiriladi:**
  - Haydovchi guvohnoma raqami — `license_no_masked` sifatida ko'rsatiladi; to'liq holatini ochish **alohida ruxsat + alohida so'rov + audit** talab qiladi.
  - Parol maydonlari: `type="password"`, `autocomplete="new-password"`, forma darajasida `autocomplete="off"`.
  - **Edit formasida parol ochiq matn ko'rinishi (masalan `1234john5678`) — jiddiy xato, mavjud bo'lmasligi kerak.**
  - Xato xabarlari va `console`ga token, parol, guvohnoma raqami **yozilmasligi** kerak.
  - Prod build'da `console.log` olib tashlanishi (`esbuild.drop`), `console.error` qolishi mumkin.
- **Qayerda tekshiriladi:** driver profile / license reveal komponenti (alohida so'rov + audit chaqiruvi bormi), edit forma komponentlari (parol maydoni value sifatida ko'rsatilmasligi), `vite.config.ts` yoki build sozlamalari (`esbuild.drop: ['console']` yoki teng), `grep -rn "console.log"` xato handler va auth kod bo'ylab.

## 6. Audit-muhim amallar tasdiqlanadi **[MUST — F207]**

- **Nima qidiriladi:** quyidagi amallar bosilishidan oldin tasdiqlash dialogini talab qiladi: Delete, Deactivate, Role o'zgarishi, HOS policy publish, Log edit request, Unassigned assign, DVIR certify, Ticket status, License reveal, Session revoke, Export.
- **Qayerda tekshiriladi:** har bir shu amalni bajaruvchi tugma/mutation — atrofida confirm modal (`ConfirmDialog` yoki shunga o'xshash) chaqirilishi.

## 7. Clipboard **[F208]**

- **Nima qidiriladi:** koordinata/VIN kabi qiymatlarni nusxalash faqat foydalanuvchi bosishi (masalan "Copy" tugmasi) bilan sodir bo'ladi. Avtomatik/fon clipboard yozish yo'q.
- **Qayerda tekshiriladi:** `navigator.clipboard.writeText` chaqiriluvchi joylar — har biri aniq foydalanuvchi hodisasi (`onClick`) ichida bo'lishi kerak.

## 8. Bo'sh turish (idle) taymeri **[SHOULD — F209]**

- **Nima qidiriladi:** 30 daqiqa faoliyatsizlikdan keyin ogohlantirish modali (60s countdown), javob bo'lmasa avtomatik logout. Har API so'rovi va foydalanuvchi harakati taymerni tiklaydi.
- **Qayerda tekshiriladi:** global idle-timer hook/provider (`useIdleTimer` yoki shunga o'xshash), App root darajasida ulanganligi.

## 9. Bog'liqliklar va build xavfsizligi **[MUST/SHOULD — F210, F211]**

- **Nima qidiriladi:** CI'da `npm audit` va `npm outdated` ishlaydi; `high`/`critical` zaiflik build'ni yiqitadi. Bog'liqliklar `package-lock.json` bilan pin qilingan.
- Sourcemap prod'da yuklanmaydi (yoki faqat Sentry'ga yuborilib, serverdan o'chiriladi).
- **Qayerda tekshiriladi:** CI konfiguratsiyasi (`.github/workflows/*` yoki teng), `vite.config.ts` (`build.sourcemap` sozlamasi), deploy skriptlari (sourcemap fayllarni serverdan olib tashlash qadami).

## 10. Tenant izolyatsiyasi (cross-company)

- **Nima qidiriladi:** boshqa kompaniyaga tegishli resursga so'rov `404` qaytaradi (backend xatti-harakati), va UI bu holatni oddiy "Not found" sifatida ko'rsatadi — cross-tenant ekanini fosh qiladigan farqli xabar/UI holati bo'lmasligi kerak. `X-Company-Id` header faqat `super_admin` rejimida (company middleware) yuboriladi — oddiy foydalanuvchi so'rovlarida yo'q.
- **Qayerda tekshiriladi:** `src/api/client.ts` dagi `companyMiddleware`, `NOT_FOUND` xato handling komponentlari (cross-tenant va oddiy 404 orasida UI farqi yo'qligi).

## 11. WebSocket autentifikatsiyasi

- **Nima qidiriladi:** WS ulanishi (`wss://eldapi.stackyard.uz/api/v1/ws`) access token bilan autentifikatsiya qilinadi; token yangilanganda (refresh) WS ulanishi ham yangi token bilan qayta ishlaydi; logout/session-expired holatida WS **yopiladi** (auth oqimidagi F16 qadam 2 bilan mos).
- **Qayerda tekshiriladi:** WS klient kodi (ulanish parametrlarida token uzatilishi), logout/reuse-detection handleri ichida `ws.close()` chaqirilishi.

## 12. Fayl yuklash — MIME va hajm tekshiruvi

- **Nima qidiriladi:** klient tomonda har bir `kind` uchun MIME **va** kengaytma tekshiriladi (backend enum'idan tashqari qiymat yuborilmaydi); haqiqiy hajm chegarasi `max_bytes` presign javobidan olinadi va UI'da ko'rsatiladi. SVG logotip hech qachon inline render qilinmaydi (`<img src>` orqali, `dangerouslySetInnerHTML` YO'Q — SVG ichida skript bo'lishi mumkin).
- **Qayerda tekshiriladi:** `FileUpload` komponenti va uning validatsiya logikasi, `logo` kind uchun preview komponenti (inline SVG emasligi).

## To'liq manba

`docs/tz-admin-frontend.md` §13 Xavfsizlik — qatorlar 1589–1620 (F201–F211). Token saqlash tafsilotlari uchun qo'shimcha: §3.3 (F14–F16), qatorlar 185–310.
