# ONEBOOK ELD — MOBIL ILOVA TEXNIK TOPSHIRIG'I (tz-mobile.md)

**Versiya:** 1.0 · **Sana:** 2026-09-07 · **Holat:** ishlab chiqishga tayyor
**Ona hujjat:** `tz.md` (v2.2). Ushbu hujjat undan **chetlashmaydi** — faqat mobil qatlamni ochib beradi.
**Dizayn manbasi:** `design-inventory.md` (bet 83–128 + ilovalar A/B/C/D).
**API kontrakti:** `backend/docs/swagger.json` — **muzlatilgan `v1`**.

**Belgilar:** `[MUST]` majburiy · `[SHOULD]` kuchli tavsiya · `[MAY]` ixtiyoriy ·
✅ qaror qabul qilingan · ❓ ochiq savol (buyurtmachiga) · 🎨 dizayn qo'shimchasi kerak.

**Raqamlash:** mobil qarorlar **`M<n>`**. `Q<n>` — `tz.md` dagi qarorga havola (o'zgartirilmaydi).
Kod bilan TZ ziddiyatida: avval CR (change request) → `tz.md`/`tz-mobile.md` yangilanadi → keyin kod.

---

## 1. Kirish

### 1.1 Maqsad
Haydovchi uchun **bitta Flutter kodbazasi** asosida ikkita ishlaydigan mahsulot:
- **telefon ilovasi** (393×852 dp referens) — haydovchining shaxsiy qurilmasi;
- **kabina plansheti** (1366×1024 dp referens) — transport vositasiga o'rnatilgan, ko'pincha kiosk rejimida.

Ilova ELD qurilmasi bilan BLE orqali ishlaydi, duty statusni yozadi, HOS hisoblagichlarini
oflayn ko'rsatadi, DVIR va sertifikatsiyani boshqaradi va yo'l tekshiruvida (roadside inspection)
inspektorga log ko'rsatadi.

### 1.2 Qamrov
| Kiradi | Kirmaydi (bu bosqichda) |
|---|---|
| Auth, sessiya, PIN, co-driver | Ro'yxatdan o'tish (ilovada signup **yo'q**) |
| Home / duty status / haydash rejimi | **Maintenance moduli** (M67, `tz.md` Q44) |
| HOS Dart engine (oflayn) | Admin funksiyalari (unit/driver/user boshqaruvi) |
| Daily log, sertifikatsiya, pending edits | Hisobotlar generatsiyasi (IFTA/FMCSA/Activity) |
| DVIR (yaratish + oldingi nuqsonni tasdiqlash) | Trip Planner, xarita ustida marshrut chizish |
| Inspection Report (kiosk + PIN) | Subscription/billing ekranlari |
| Unidentified driving claim | Guruh chat |
| Chat, bildirishnomalar, support, feedback | To'lov, offline xarita tayllari |
| Oflayn sync, telemetriya buferi | Ovozli boshqaruv, Android Auto / CarPlay |
| Light + Dark tema (ikkalasi ham **majburiy**) | Ko'p tilli UI (i18n karkasi bor, MVP faqat `en`) |

### 1.3 Backend holati
- Bazaviy URL: **`https://eldapi.stackyard.uz/api/v1`** · Driver portali: `https://eld.stackyard.uz`
- Kontrakt: `backend/docs/swagger.json` (`basePath=/api/v1`). **`v1` muzlatilgan** — mobil tomondan
  endpoint qo'shish/o'zgartirish so'rovi faqat CR orqali.
- WebSocket: `GET /api/v1/ws` (`backend/docs/websocket.md`) — **planshet uchun `[MAY]`**, telefon uchun ishlatilmaydi.
- Xato konverti bir xil: `{"error":{"code":"…","message":"…","details":[…]}}`.

**M1 [MUST]** Mobil ilova **hech qanday qo'lda yozilgan API modelidan foydalanmaydi**.
`openapi-generator` (`dart-dio`) `swagger.json` dan `packages/eld_api` paketini chiqaradi;
generatsiya CI da qayta yuritiladi va diff bo'lsa build yiqiladi.

### 1.4 Manbalar va ustuvorlik tartibi
Ziddiyat bo'lganda quyidagi tartib ishlaydi (yuqoridagi g'olib):

| № | Manba | Nima uchun kanonik |
|---|---|---|
| 1 | `backend/docs/swagger.json` + backend xatti-harakati | Ishlaydigan kontrakt |
| 2 | `tz.md` (v2.2) | Biznes qoidalari, `Q<n>` |
| 3 | `.claude/skills/eld-sync`, `.claude/skills/eld-hos` | Protokol va algoritm tafsiloti |
| 4 | `backend/internal/hos/testdata/hos-test-vectors.json` | HOS haqiqatining yagona o'lchovi |
| 5 | `design-inventory.md` | Vizual va matn manbasi |
| 6 | Figma fayli | Faqat piksel tafsiloti uchun |

**M2 [MUST]** Dizayn bilan backend orasidagi har qanday farq — **backend foydasiga** hal qilinadi,
va §21 «Nomuvofiqliklar reestri» ga yoziladi.

---

## 2. Stack va loyiha tuzilmasi

### 2.1 Stack (`tz.md` B§6.3 — o'zgartirilmaydi)
| Qatlam | Tanlov |
|---|---|
| SDK | **Flutter 3.x** (stable kanal, `flutter --version` CI da pin qilinadi), Dart 3 |
| Holat boshqaruvi | **Riverpod 2.x** (`riverpod_generator`, `riverpod_lint`) |
| Navigatsiya | **go_router** (`StatefulShellRoute.indexedStack`) |
| DI | Riverpod provayderlari (alohida `get_it` **yo'q**) |
| Lokal DB | **Drift** (SQLite), `drift_flutter`, `sqlite3_flutter_libs` |
| API klient | `dart-dio` generatsiya (`packages/eld_api`), `dio` + interceptorlar |
| BLE | `flutter_blue_plus`; vendor SDK bo'lsa — platform channel (§10.7) |
| Fon rejimi | Android: `foreground_service` (`flutter_foreground_task`); iOS: `bluetooth-central` + `location` |
| Xavfsiz saqlash | `flutter_secure_storage` (Keychain / EncryptedSharedPreferences) |
| Push | `firebase_messaging` (FCM + APNs) |
| i18n | `intl` + `flutter_localizations`, ARB (`lib/l10n/app_en.arb`) |
| Imzo | `signature` paketi yoki o'z `CustomPainter` (offline, tashqi xizmatsiz) |
| Sana/vaqt | `timezone` (IANA tzdata — Home Terminal TZ uchun **majburiy**) |
| Log | `logger` + fayl sink (PII maskalangan, §17.5) |
| Test | `flutter_test`, `mocktail`, `drift` in-memory, `integration_test`, `golden_toolkit` |

### 2.2 Nima uchun Riverpod (Bloc emas) — **M3 ✅**
1. **Sof Dart paketlar bilan kelishuv:** `hos_engine` va `sync_core` — Flutter'ga bog'liq emas;
   Riverpod provayderi ularni to'g'ridan-to'g'ri o'raydi, Bloc'da qo'shimcha event/state qatlami kerak.
2. **Kompilyatsiya vaqtida xavfsiz DI:** `get_it` kabi runtime service-locator kerak emas →
   IDOR/nul xatolari kamayadi.
3. **Drift oqimlari:** `StreamProvider` Drift `watch()` bilan to'g'ridan-to'g'ri ishlaydi;
   45+ ekran uchun Bloc boilerplate'i 2–3 barobar ko'p bo'lar edi.
4. **`keepAlive` fon kontrollerlari:** sync scheduler, BLE menejer, HOS taymer — ilova hayoti
   davomida yashaydigan provayderlar sifatida tabiiy ifodalanadi.
5. **Test:** `ProviderContainer` + `overrideWith` — har bir ekran uchun izolyatsiya oson.

**Cheklov:** biznes qoidasi **hech qachon** widget yoki provayder ichida yozilmaydi —
faqat `packages/hos_engine`, `packages/sync_core` va `lib/features/*/domain` da.

### 2.3 Papka tuzilmasi **[MUST]**

```
eld_mobile/
├─ packages/
│  ├─ hos_engine/            # sof Dart. Flutter YO'Q. HTTP/DB YO'Q. DateTime.now() YO'Q.
│  │  ├─ lib/src/{model,policy,compute,violations,recap}.dart
│  │  └─ test/golden_vectors_test.dart   # hos-test-vectors.json dan o'qiydi
│  ├─ sync_core/             # sof Dart. Konflikt/validatsiya qoidalari, batch bo'lish.
│  └─ eld_api/               # GENERATSIYA QILINADI. Qo'lda tahrirlanmaydi (.gitattributes: linguist-generated)
├─ lib/
│  ├─ main.dart              # faqat bootstrap
│  ├─ app.dart               # MaterialApp.router, tema, lokalizatsiya
│  ├─ core/
│  │  ├─ config/             # Env (dev/stage/prod), --dart-define
│  │  ├─ network/            # Dio, auth interceptor, refresh queue, retry, Idempotency-Key
│  │  ├─ db/                 # Drift schema, DAO, migratsiyalar
│  │  ├─ sync/               # outbox, scheduler, push/pull ishchi, konflikt UI mapping
│  │  ├─ time/               # TimeSource (ELD RTC → server → phone), skew, tz
│  │  ├─ eld/                # BLE menejer, ramka parseri, malfunction detektori
│  │  ├─ location/           # GPS, geocoding keshi, aniqlik siyosati
│  │  ├─ background/         # Android FGS, iOS background modes, state restoration
│  │  ├─ security/           # token vault, PIN hash, screen protection, PII maskirovka
│  │  ├─ ui/                 # dizayn tizimi: ranglar, tipografika, komponentlar, tema
│  │  ├─ router/             # go_router, guard, deep link
│  │  ├─ device/             # DeviceProfile (phone|tablet), device_id, app_version
│  │  ├─ i18n/               # intl konfiguratsiyasi
│  │  └─ error/              # ApiError → UI xabar mapping (kod bo'yicha)
│  └─ features/
│     ├─ auth/  home/  duty_status/  drive_mode/  logs/  certify/  log_edits/
│     ├─ dvir/  inspection/  unidentified/  chat/  notifications/
│     ├─ profile/  settings/  diagnostics/  support/  feedback/  legal/  eld_device/
│     └─ (har biri: data/ · domain/ · presentation/{screens,widgets,controllers})
├─ assets/{icons,images,legal}
├─ test/  ·  integration_test/  ·  test_goldens/
└─ tool/  # generate_api.sh, verify_vectors.dart, check_l10n.dart
```

**M4 [MUST]** `packages/hos_engine` va `packages/sync_core` `pubspec.yaml` da `flutter` bog'liqligi
bo'lmasligi shart. CI da tekshiriladi: `dart pub deps --json | grep flutter` bo'sh bo'lishi kerak.

**M5 [MUST]** Qatlam qoidasi: `presentation → domain → data`. `presentation` hech qachon
`eld_api` modelini to'g'ridan-to'g'ri ishlatmaydi — `data` qatlamida domen modeliga o'giriladi
(backendning `sqlc → DTO` qoidasi bilan bir xil falsafada).

### 2.4 Kod uslubi va lint
- `analysis_options.yaml`: `flutter_lints` + `riverpod_lint` + `custom_lint`, quyidagilar **error** darajasida:
  `avoid_print`, `always_declare_return_types`, `prefer_const_constructors`,
  `unawaited_futures`, `avoid_dynamic_calls`, `use_build_context_synchronously`.
- **Taqiqlar (CI grep bilan tekshiriladi) [MUST]:**
  | Taqiq | Sabab |
  |---|---|
  | `DateTime.now()` `hos_engine`, `sync_core` va domen ichida | Testlar deterministik bo'lishi kerak; vaqt `TimeSource` dan olinadi |
  | `print(` / `debugPrint(` prod kodida | PII sizishi |
  | Hard-coded matn widget ichida | i18n (`context.l10n.*`) majburiy |
  | Hard-coded rang (`Color(0x…)`) `core/ui/tokens.dart` dan tashqarida | Ikki tema |
  | `http` paketi | Yagona transport — `dio` interceptorlari |
- Formatlash: `dart format --line-length=100`, CI da `--set-exit-if-changed`.
- Kommit: Conventional Commits; PR shabloni DoD checkbox'lari bilan (§«Ish tartibi»).

### 2.5 Muhitlar
`--dart-define-from-file=env/{dev,stage,prod}.json`: `API_BASE_URL`, `WS_URL`, `SENTRY_DSN`,
`ENABLE_DEV_MENU`. Prod build'da dev menyu va sertifikat pinning bypass **yo'q**.

---

## 3. Ikki qurilma profili

**M6 [MUST]** Qurilma turi ishga tushishda bir marta aniqlanadi va `DeviceProfile` provayderiga yoziladi:

| Mezon | Natija |
|---|---|
| `shortestSide >= 600 dp` **VA** platforma Android/iOS planshet | `tablet` |
| Aks holda | `phone` |
| Qo'lda majburlash (faqat `dev`/`stage`) | `--dart-define=FORCE_DEVICE_TYPE=tablet` |

Bu qiymat `POST /auth/login` da `device_type` maydoniga (`phone` | `tablet`) yuboriladi va
sessiya siyosatiga (§4.6) ta'sir qiladi. **`web` qiymati mobil ilovada ishlatilmaydi.**

### 3.1 Farqlar jadvali

| Jihat | Telefon (`phone`) | Planshet (`tablet`) |
|---|---|---|
| Referens o'lcham | 393×852 dp | 1366×1024 dp (landshaft) |
| Orientatsiya | faqat **portret** | faqat **landshaft** |
| Navigatsiya | pastki tab (4) + drawer | **yagona ekran + modallar** + drawer |
| Bosh ekran | vertikal scroll, above-the-fold: status + HOS | uch ustunli, **scroll yo'q** |
| HOS ko'rsatkichi | 4 ta **chiziqli** indikator | 4 ta **halqa** (katta) |
| Log grid | alohida tab (`Logs`) | doim ekranning pastki qismida ko'rinadi |
| Amallar | Home'dagi tezkor amallar qatori | o'ng ustundagi `Actions` paneli |
| Modal uslubi | to'liq ekran sahifa yoki bottom-sheet | markazdagi modal, sarlavha qatori `Cancel · <sarlavha> · <amal>` |
| Tema almashtirish | `Profile › Dark mode` toggle | tepa paneldagi tema ikonkasi |
| Co-driver | qo'llab-quvvatlanadi | **asosiy stsenariy** (§3.3) |
| Kiosk rejimi | yo'q | `[SHOULD]` lock task mode (§18.3) |
| WebSocket | yo'q (faqat REST + push) | `[MAY]` `notifications` + `chat` kanallari |
| Batareya | qattiq byudjet (§19) | doimiy quvvat, byudjet yumshoq |

**M7 [MUST]** Adaptivlik **`DeviceProfile` bo'yicha**, `MediaQuery.width` bo'yicha emas.
Har bir ekran uchun bitta `Controller` (biznes mantiq) va ikkita `View` (`PhoneView`, `TabletView`)
bo'ladi; mantiq nusxalanmaydi.

**M8 [MUST]** Minimal teginish maydoni: telefon **48×48 dp**, planshet **56×56 dp**
(kabinada, tebranishda bosiladi). Haydash rejimidagi tugmalar — **≥64 dp**.

### 3.2 Kiosk rejimi (planshet) **[SHOULD]**
- `Begin Inspection` va `Drive mode` — ekrandan chiqishni bloklaydigan rejimlar;
  chiqish **6 xonali PIN** bilan (§4.5, §11.7).
- Android: `startLockTask()` platform channel orqali; qurilma device-owner bo'lsa avtomatik,
  bo'lmasa foydalanuvchi tasdig'i bilan (screen pinning).
- iOS: Guided Access — dasturiy yoqib bo'lmaydi, foydalanuvchiga **onboarding ko'rsatmasi** beriladi 🎨.
- Ekran doim yoniq: `WakelockPlus.enable()` faqat planshetda va faqat haydash/inspection rejimida.

### 3.3 Co-driver: bitta qurilmada ikki sessiya (`tz.md` Q45)
**M9 [MUST]** Planshet (va istalgan qurilma) bir vaqtda **ikkita mustaqil sessiya** ushlaydi:

```
SessionSlot.active   → active_driver   (DR shu haydovchiga yoziladi)
SessionSlot.co       → co_driver       (OFF/SB/ON; DR yozilmaydi)
```

| Qoida | Xatti-harakat |
|---|---|
| Har ikkala haydovchi **o'z paroli** bilan bir marta login qiladi | Ikki alohida access/refresh juftligi, ikkala `device_id` bir xil |
| `Switch` bosilganda | Tasdiq modali → **PIN so'raladi** (`POST /auth/pin/verify` `action=switch_driver`) → slotlar almashadi |
| Harakat aniqlanganda | `DR` **faqat** `active` slotga (`tz.md` Q45.1); co-driver statusi tegilmaydi |
| Trailer/Shipping doc | Har haydovchi uchun alohida; `Switch` da `Myself / Co-driver` tanlovi |
| Sync | **Har slot uchun alohida outbox navbati**; `device_seq` — qurilma bo'yicha **yagona monoton hisoblagich** (slotlar bo'linmaydi) |
| `Leave Truck` (active) | Active slot `paused` bo'ladi; co-driver bo'lsa **u avtomatik active** bo'ladi |
| Ikkala slot ham bo'sh | Ilova Login ekraniga qaytadi; ELD ulanishi uziladi; harakat → unidentified driving |

**M10 [MUST]** UI da faol haydovchi **doim ko'rinadi** (tepa panelda ism + avatar, ikkinchi
haydovchi kichikroq). Ikki sessiya aralashib ketmasligi uchun `ActiveDriverBanner` rangi
`Primary #B7002C` bilan ajratiladi.

**M11 [MUST]** Telefonda ham co-driver qo'llab-quvvatlanadi, lekin `Switch` tugmasi faqat
`co_driver` biriktirilgan bo'lsa ko'rinadi (`/me` → driver profili).

---

## 4. Autentifikatsiya va sessiya

### 4.1 Kirish oqimlari

| Oqim | Endpoint | Ekran |
|---|---|---|
| Login | `POST /auth/login` | `M-02 Login` |
| Taklifni qabul qilish (parol + PIN o'rnatish) | `POST /auth/invitation/accept` | `M-05 Accept invitation` |
| Parolni tiklash | `POST /auth/password/forgot` → `/auth/password/reset` | `M-06`, `M-07` |
| 2FA (rol talab qilsa) | `POST /auth/2fa/setup` → `/auth/2fa/verify` | `M-08 Two-factor` |
| Token yangilash | `POST /auth/refresh` | fon |
| PIN tekshirish | `POST /auth/pin/verify` | `M-04 PIN` |
| Chiqish / pauza | `POST /auth/logout` (`pause=true|false`) | `M-03 Leave truck` |
| Sessiyalar | `GET /auth/sessions`, `DELETE /auth/sessions/{id}` | `M-58 Sessions` |
| Bootstrap | `GET /app/config` (public) | Splash |

**M12 [MUST] Ilovada ro'yxatdan o'tish yo'q.** Login ekranida dizayndagi matn saqlanadi:
«This app does not support account registration. Please reach out to your fleet manager for assistance.»

### 4.2 Splash va bootstrap
`M-01 Splash` da ketma-ketlik (**≤3 s**, §19):
1. `GET /app/config` (public, keshlanadi) → `min_supported_version`, `latest_version`,
   `force_update`, `server_time`, `access_token_ttl_seconds`, `feature_flags`, `support_email`.
2. `force_update==true` **yoki** joriy versiya `< min_supported_version` → **`M-45 Force update`**
   bloklovchi ekrani (store havolasi; boshqa yo'l yo'q). ✅
3. `server_time` → `TimeSource` ga offset yoziladi (§7).
4. Secure storage'da refresh token bor → `POST /auth/refresh` → Home; yo'q → Login.
5. **Tarmoq yo'q bo'lsa:** oxirgi keshlangan config va lokal sessiya bilan **oflayn kiriladi**
   (`M13`). `app/config` ni olish muvaffaqiyatsizligi ilovani bloklamaydi.

**M13 [MUST] Oflayn ishga tushish:** refresh token muddati tugamagan bo'lsa va tarmoq yo'q bo'lsa,
ilova to'liq oflayn rejimda ochiladi (Home, duty status, HOS, DVIR draft — hammasi ishlaydi).
Sababi: ELD qonuniy talab, tarmoq yo'qligi haydovchini bloklab qo'ymasligi kerak.

### 4.3 Login
| Maydon | Turi | Validatsiya |
|---|---|---|
| Username or Email address | matn | bo'sh emas; trim; lowercase emas (server hal qiladi) |
| Password | parol (ko'z ikonkasi) | ≥8 belgi |
| `device_id` | avtomatik | **barqaror UUID**, birinchi ishga tushishda generatsiya, secure storage'da |
| `device_type` | avtomatik | `phone` \| `tablet` (§3) |
| `app_version` | avtomatik | `package_info_plus` |
| `totp_code` | shartli | server `TOTP_SETUP_REQUIRED` yoki 401 qaytarsa so'raladi |

Tugma bo'sh formada kulrang (o'chirilgan), to'ldirilganda `Primary`. Pastda `Copyright © 2025 OneBook ELD`.

**Xatolar mapping'i:**
| Kod | UI |
|---|---|
| `UNAUTHORIZED` | «Incorrect username or password» (qaysi biri xato — aytilmaydi) |
| `ACCOUNT_INACTIVE` | «Your account is inactive. Contact your fleet manager.» |
| `TOTP_SETUP_REQUIRED` | 2FA o'rnatish ekraniga o'tish |
| `RATE_LIMITED` | «Too many attempts. Try again in <n> s» + taymer |
| tarmoq yo'q | «No connection. Login requires internet the first time.» |

**M14 [MUST]** Login **oflayn ishlamaydi** (birinchi marta). Lekin bir marta login qilingandan
keyin — hamma narsa oflayn (M13).

### 4.4 Taklif (invitation) orqali kirish
Deep link: `onebookeld://invite?token=…` va HTTPS fallback `https://eld.stackyard.uz/invite/<token>`
(App Links / Universal Links). Ekran `M-05`:
1. Parol (2 marta, kuch indikatori), 2. **6 xonali PIN** (2 marta), 3. Huquqiy roziliklar.
`POST /auth/invitation/accept` `{token, password, pin}` → muvaffaqiyat → avtomatik login.

❓ **M15** Taklifning asosiy kanali (SMS/Email) — `tz.md` B§23 da ochiq. Mobil ikkala deep link
formatini ham qo'llab-quvvatlaydi, qaror keyinroq faqat backendga ta'sir qiladi.

### 4.5 PIN — 6 xonali **[MUST]**
| Jihat | Qoida |
|---|---|
| O'rnatish | Invitation qabul qilishda; keyinchalik `Profile › Change PIN` 🎨 |
| Uzunlik | **aynan 6 raqam** |
| Taqiq | 6 ta bir xil raqam (`111111`), ketma-ketlik (`123456`, `654321`) — mijoz tomonida ham tekshiriladi |
| Serverda | `POST /auth/pin/verify` `{pin, action}`; `action ∈ {switch_driver, return_to_truck}` |
| Lokal keshi | PIN **hech qachon ochiq saqlanmaydi**. Oflayn tekshirish uchun `Argon2id`/`PBKDF2` hash + qurilma tuzi (`salt`) secure storage'da (§17.3) |
| Xato limiti | 5 noto'g'ri urinish → 60 s blok, keyingisi 5 daq (eksponensial). Server `PIN_LOCKED` qaytarsa — uning muddati ustun |
| `PIN_NOT_SET` | PIN o'rnatish ekraniga majburiy yo'naltirish |
| Qaerda so'raladi | `Return to truck` · `Switch co-driver` · `Begin Inspection` rejimidan chiqish · Kiosk'dan chiqish |
| Qaerda **so'ralmaydi** | Ilovani odatiy ochish (ELD uzluksizligi uchun) |

**M16 [MUST] Oflayn PIN:** tarmoq yo'q bo'lsa PIN lokal hash bilan tekshiriladi va `Return to truck`
ruxsat etiladi; tarmoq qaytganda `POST /auth/pin/verify` fon rejimida yuritiladi. Server rad etsa —
sessiya darhol `paused` ga qaytariladi va haydovchiga xabar beriladi.

### 4.6 Sessiya siyosati: 1 telefon + 1 planshet (`tz.md` B§20)
- Bir user uchun bir vaqtda: **1 `web` + 1 `phone` + 1 `tablet`**.
- Xuddi shu turdagi yangi login → eskisi bekor qilinadi. `LoginResult.replaced_session == true`
  bo'lsa yangi qurilmada ma'lumot beruvchi banner ko'rsatiladi 🎨:
  «You were signed in on this device. Your other <phone|tablet> was signed out.»
- Eskisi tomonda: birinchi 401 `TOKEN_REVOKED` da **`M-44 Signed out elsewhere`** ekrani:
  «Your account was used to sign in on another <device_type>.» + `Sign in again`.
- **M17 [MUST]** Sessiya bekor qilinganda **oflayn navbat o'chirilmaydi**. Buferdagi eventlar
  saqlanadi va o'sha user qayta login qilganda yuboriladi. Boshqa user login qilsa — avvalgi
  user navbati alohida saqlanib turadi (maksimum 14 kun), aralashmaydi.
- Kabinadagi ikki haydovchi (§3.3) — bitta `device_id`, ikki `user_id`; bu **ruxsat etilgan**.

### 4.7 Token va refresh rotatsiyasi **[MUST]**
| Qoida | Tafsilot |
|---|---|
| Access TTL | `app/config.access_token_ttl_seconds` (default 900 s) |
| Yangilash | Muddat tugashiga **60 s qolganda** proaktiv `POST /auth/refresh` |
| Rotatsiya | Har refresh yangi refresh token qaytaradi — eskisi **darhol o'chiriladi** |
| Parallel 401 | **Bitta** refresh mutex; qolgan so'rovlar navbatda kutadi va yangi token bilan **bir marta** takrorlanadi |
| Refresh muvaffaqiyatsiz (`TOKEN_REVOKED`/`UNAUTHORIZED`) | Sessiya tozalanadi (outbox **saqlanadi**), `M-44` ekrani |
| Ikki slot | Har slot uchun mustaqil refresh mutex |
| Saqlash | Faqat `flutter_secure_storage`; xotirada `String` sifatida minimal umr |

### 4.8 `Leave Truck` va `Return to truck` (`tz.md` Q45.2)
```
[Leave Truck] → tasdiq modali («Your status will be set to Off-duty»)
   → status OFF eventi outbox'ga (odatiy duty-status eventi kabi)
   → BLE ulanishi uziladi, fon xizmati to'xtaydi
   → POST /auth/logout {pause:true}   → sessiya `paused` (refresh token TIRIK qoladi)
   → ekran: M-03 «Leave truck» (login formasi + `Return to truck` tugmasi)
[Return to truck] → PIN (6 xona) → POST /auth/pin/verify {action:"return_to_truck"}
   → sessiya `active`, BLE qayta ulanadi, sync darhol yuritiladi
```
- Co-driver mavjud bo'lsa: `Leave Truck` dan keyin **co-driver avtomatik `active`** bo'ladi
  va ekran Home'da qoladi (Login ekrani ko'rsatilmaydi).
- Tarmoq yo'q bo'lsa `logout(pause)` outbox'ga tushadi, lokal holat darhol `paused` bo'ladi.
- **M18 [MUST]** `Leave Truck` — **`Log out` emas**. To'liq chiqish faqat drawer'dagi qizil
  `Logout` bandida (`pause=false`), va u **outbox bo'sh bo'lmasa ogohlantiradi**:
  «You have <n> unsynced records. Log out anyway?» → `Cancel` / `Log out`.
---

## 5. Oflayn-first arxitektura

**Asos:** `tz.md` B§1 (Q-B1.1 … Q-B1.4), `.claude/skills/eld-sync/SKILL.md`.
**Prinsip:** *ilova hech qachon tarmoqni kutmaydi*. Har bir foydalanuvchi amali avval **lokal DB**ga
yoziladi va UI darhol yangilanadi; tarmoq — fon detali.

### 5.1 Drift sxemasi **[MUST]**

Barcha vaqtlar **UTC** (`DateTime` UTC, `INTEGER` epoch ms). Kunga ajratish faqat Home Terminal TZ da.

| Jadval | Maqsad | Kalit maydonlar |
|---|---|---|
| `outbox_items` | **Universal chiqish navbati** | `id` PK, `kind` (`event`/`telemetry`/`dvir`/`chat`/`certify`/`claim`/`log_edit`/`push_token`/`feedback`/`support`), `payload` (JSON), `client_id` UUID, `device_seq` INT, `session_slot`, `user_id`, `created_at`, `attempts`, `next_attempt_at`, `state` (`pending`/`inflight`/`acked`/`rejected`), `reject_reason`, `reject_seen` BOOL |
| `duty_events` | Duty status eventlari (lokal ko'zgu + navbat) | `client_event_id` UUID **UNIQUE**, `server_id`, `event_type`, `status`, `special`, `event_time`, `time_source`, `time_unverified`, `clock_skew_sec`, `device_seq`, `origin`, `lat`, `lng`, `gps_accuracy_m`, `location_text`, `odometer_m`, `engine_hours`, `speed_kmh`, `notes`, `unit_id`, `eld_device_id`, `trailer_ids` (JSON), `shipping_doc_ids` (JSON), `sync_state`, `superseded_by`, `locked` |
| `telemetry_buffer` | ECM/GPS nuqtalari | `ts` (UNIQUE bilan `unit_id`), `lat`, `lng`, `speed_kmh`, `heading_deg`, `odometer_m`, `engine_hours`, `ignition`, `fuel_pct`, `coolant_*`, `oil_level_pct`, `battery_*`, `diagnostics` (JSON), `disconnected`, `duty_status`, `driver_id`, `sent` BOOL |
| `daily_logs` | Kunlik loglar ko'zgusi (14 kun) | `log_date`, `driver_id`, `timezone`, `certification_status`, `signed_at`, `distance_m`, `totals` (JSON), `ready`, `updated_at` |
| `hos_state` | Oxirgi hisoblangan hisoblagichlar keshi | `driver_id`, `computed_at`, `counters` (JSON), `recap` (JSON), `policy_version_id` |
| `hos_policy` | Joriy va oldingi policy versiyalari | `version_id`, `effective_from`, `payload` (JSON) |
| `dvir_drafts` | DVIR qoralamalari | `client_id`, `unit_id`, `type`, `defects` (JSON), `trailer_ids`, `notes`, `driver_signature_key`, `local_photo_paths` (JSON), `state` (`draft`/`queued`/`sent`) |
| `dvir_reports` | Serverdan olingan DVIR'lar (14 kun) | `id`, `status`, `kind`, `type`, `unit_id`, `created_at`, `has_critical_defect`, `out_of_service`, JSON |
| `chat_outbox` / `chat_messages` | Chat navbati va tarixi | `client_id`, `kind`, `text`, `file_key`, `lat`, `lng`, `status` (`queued`/`sent`/`delivered`/`read`/`failed`) |
| `log_edit_requests` | Pending edits | `id`, `daily_log_id`, `log_date`, `changes` (JSON), `source`, `status`, `created_at`, `local_decision` |
| `unidentified_events` | Claim uchun kutayotgan bloklar | `id`, `unit_id`, `start_at`, `end_at`, `distance_m`, `status`, `dismissed_local` |
| `notifications` | Bildirishnomalar keshi | `id`, `alert_type`, `title`, `body`, `entity_type`, `entity_id`, `read`, `created_at` |
| `files_queue` | Yuklanmagan fayllar (foto/imzo) | `local_path`, `kind`, `content_type`, `size_bytes`, `presigned_key`, `upload_url`, `expires_at`, `state`, `attempts` |
| `ref_defect_types` / `ref_quick_notes` / `ref_trailers` | Katalog keshlari | `sync/pull` dan yangilanadi |
| `sync_cursor` | Kursor va statistika | `next_since`, `last_push_at`, `last_pull_at`, `last_error` |
| `kv_settings` | Tema, zoom, til, oxirgi tanlangan trailer | `key`, `value` |

**M19 [MUST]** `duty_events.client_event_id` — **`UUID v4`, qurilmada generatsiya qilinadi va
hech qachon o'zgarmaydi**. Bu — idempotentlikning yagona kaliti.

**M20 [MUST]** `device_seq` — **qurilma bo'yicha yagona, monoton o'suvchi `INTEGER`**;
`kv_settings` da atomik `UPDATE … RETURNING` bilan oshiriladi; ilova qayta o'rnatilsa
`device_id` ham yangilanadi (seq 0 dan boshlanadi — konflikt yo'q).

**M21 [MUST]** Drift migratsiyalari **forward-only** (`schemaVersion` oshadi, `MigrationStrategy`
har qadamni yozadi). Ishlab chiqilgan migratsiyani tahrirlash **taqiqlanadi** (backend goose qoidasi bilan bir xil).

**M22 [MUST]** Drift `drift_dev/schema` snapshotlari repoda saqlanadi va
`drift_dev schema verify` CI da yuritiladi.

### 5.2 Saqlash muddati va hajm
| Ma'lumot | Minimal saqlash | Tozalash |
|---|---|---|
| `duty_events` | **≥14 kun** (`tz.md` Q-B1.3) | 30 kundan eskisi, `sync_state=acked` bo'lsa |
| `telemetry_buffer` | 14 kun yoki `sent=true` gacha | `sent=true` va >48 soat |
| `daily_logs`, `dvir_reports` | 14 kun (sertifikatsiya oynasi 8 kun + zaxira) | 30 kun |
| `chat_messages` | oxirgi 500 xabar / 30 kun | LRU |
| Fayllar (foto/imzo) | yuklanguncha + 7 kun | yuklangandan keyin |
| **Umumiy byudjet** | **≤100 MB** | 90 MB dan oshsa telemetriya eng eski 10% o'chadi (**eventlar hech qachon o'chmaydi**) |

**M23 [MUST] Eventlar hech qanday sharoitda avtomatik o'chirilmaydi** — faqat server `accepted`
yoki `duplicate` javobi bergandan **va** 30 kun o'tgandan keyin. «0 event yo'qotish» NFR shundan keladi.

### 5.3 Outbox patterni
```
Foydalanuvchi amali / ELD hodisasi
        │
        ├─► domen validatsiyasi (sof funksiya, sync_core)
        ├─► TRANSAKSIYA: [domen jadvali yozuvi] + [outbox_items yozuvi]   ← atomik
        └─► UI darhol yangilanadi (optimistik)
                    │
             SyncScheduler (fon)
                    │
        ┌───────────┴────────────┐
     push (batch)            pull (kursor)
        │                        │
   element natijalari       server o'zgarishlari
   accepted/duplicate/rejected   (kanonik) → lokal qayta qurish
```
**M24 [MUST]** Yozuv **har doim** bitta Drift tranzaksiyasida: domen jadvali + `outbox_items`.
Ikkisidan biri yiqilsa — ikkalasi ham qaytariladi (event yo'qolmaydi/ikkilanmaydi).

**M25 [MUST]** Tartib kafolati: `outbox_items` **`device_seq` bo'yicha o'sish tartibida** yuboriladi.
Bitta batch ichida ham tartib saqlanadi. `rejected` element navbatni **bloklamaydi** — u
`state=rejected` bo'lib chetga chiqadi va foydalanuvchiga ko'rsatiladi (§5.6).

### 5.4 Sync scheduler
| Trigger | Xatti-harakat |
|---|---|
| Ilova foreground'ga chiqdi | Darhol push+pull |
| Tarmoq paydo bo'ldi (`connectivity_plus`) | Darhol push+pull (2 s debounce) |
| Doimiy taymer | Onlayn: **60 s**; haydash rejimida: **30 s**; oflayn: urinmaydi |
| Kritik event (`certify`, `dvir`, `duty_status`, `claim`) | Darhol push urinishi |
| Fon xizmati (Android FGS) | Ekran o'chiq bo'lsa ham 60 s |
| Qo'lda | Tepa paneldagi **`Refresh`** ikonkasi (dizaynda bor) |

**Backoff [MUST]:** `1 s → 2 s → 5 s → 15 s → 60 s → 300 s` (maksimum **5 daqiqa**), har urinishga
**±20% jitter**. `429 RATE_LIMITED` kelsa — `Retry-After` sarlavhasi ustun. Muvaffaqiyatdan keyin backoff nolga tushadi.

**M26 [MUST]** Faqat **bitta** sync sikli bir vaqtda ishlaydi (mutex). Ikkinchi trigger navbatga
qo'yiladi, parallel push yuborilmaydi (`Idempotency-Key` takrorlanishining oldini oladi).

**M27 [SHOULD]** Telemetriya push'i alohida, past ustuvorlikli navbatda: metered (mobil) tarmoqda
batch **≤1000 nuqta**, Wi-Fi da **≤5000**. Eventlar **hech qachon** kechiktirilmaydi.

### 5.5 Sync holati UI da
Tepa panelda kichik indikator (**🎨** dizaynga qo'shiladi — dizaynda yuklanish/sync holati **umuman yo'q**, A.8):

| Holat | Ko'rinish | Tafsilot ekrani |
|---|---|---|
| `synced` | Kulrang bulut ✓ + «Synced <nisbiy vaqt>» | — |
| `pending` | Aylanuvchi ikonka + «<n> pending» | `M-54 Sync status` |
| `offline` | Uzilgan bulut + «Offline — <n> queued» | `M-54` |
| `conflict` | **Qizil nuqta** + «<n> need attention» | `M-55 Conflicts` |

**M28 [MUST]** `M-54 Sync status` ekrani 🎨: oxirgi push/pull vaqti, navbatdagi elementlar soni
turlari bo'yicha, oxirgi xato kodi, `Retry now` tugmasi, `next_since` kursori (diagnostika uchun).

### 5.6 Konflikt natijalarini ko'rsatish **[MUST]**
Server har element uchun `accepted | duplicate | rejected(reason)` qaytaradi.

| `reason` | UI xabari (en) | Foydalanuvchi amali |
|---|---|---|
| `time_in_future` | «This entry was recorded ahead of server time and was not accepted. Check your device clock.» | `M-55` da qayta yuborish (vaqt tuzatilgandan keyin) |
| `time_out_of_range` | «This entry is outside the accepted time range.» | Faqat ko'rish |
| `log_locked` | «That day is already certified. Ask your fleet manager for a log edit.» | `Contact support` havolasi |
| `superseded` | «Another device recorded a status at the same time. The other entry was kept.» | Faqat ma'lumot; event tarixda qoladi |
| `invalid_payload` | «This entry could not be saved (invalid data).» | Diagnostikaga jo'natish |
| `pc_not_allowed` / `ym_not_allowed` | «Personal Conveyance / Yard Move is disabled for your company.» | Toggle yashiriladi |
| `sleeper_berth_unavailable` | «Sleeper Berth is not available on this unit.» | SB tugmasi o'chadi |
| `drive_not_manual` / `auto_drive` | «Driving status is set automatically and cannot be changed by hand.» | — |
| `yard_move_ended` | «Yard Move ended automatically — the vehicle exceeded <n> km/h.» | Toast + logda ko'rinadi |

**M29 [MUST]** `superseded` natija — **xato emas**. Element `accepted` deb belgilanadi,
`superseded_by` yoziladi, lokal log server qayta qurilishidan keyin yangilanadi.

**M30 [MUST] `M-55 Sync conflicts` ekrani 🎨:** rad etilgan/almashtirilgan elementlar ro'yxati
(sana, tur, sabab, asl qiymat). Har element `reject_seen=false` bo'lsa qizil nuqta beradi;
foydalanuvchi ko'rgandan keyin `true`. Ro'yxat **7 kun** saqlanadi.

**M31 [MUST]** Server kanonik (`eld-sync` konflikt qoidasi #2). `sync/pull` dagi `events`
lokal ko'zguni **to'liq qayta quradi**: server versiyasi ustun, lokal faqat hali `acked` bo'lmagan
outbox elementlarini qo'shib ko'rsatadi (optimistik qatlam).

---

## 6. Sync protokoli — `/sync/push` va `/sync/pull`

**Manba:** `.claude/skills/eld-sync/SKILL.md` + `swagger.json` (`sync_dto.*`).

### 6.1 `POST /api/v1/sync/push`
**Sarlavhalar [MUST]:** `Authorization: Bearer …` · **`Idempotency-Key: <uuid v4>`** (majburiy) ·
`Content-Type: application/json` · `User-Agent: ONEBOOK-ELD/<ver> (<os> <osver>; <phone|tablet>)`.

**So'rov (`sync_dto.PushRequest`):**
| Maydon | Turi | Izoh |
|---|---|---|
| `device_id` **(majburiy)** | uuid | Barqaror qurilma identifikatori |
| `unit_id` | uuid | Joriy biriktirilgan unit |
| `app_version` | string | `1.2.0` |
| `clock` | `{phone, eld_rtc}` | ISO-8601 UTC; ELD yo'q bo'lsa `eld_rtc` **yuborilmaydi** |
| `events[]` | `EventPush` | ≤**500** |
| `telemetry[]` | `TelemetryPoint` | ≤**5000** |
| `dvir[]` | `{client_id}` | ≤**100** |
| `chat[]` | `{client_id}` | ≤**500** |

**`EventPush` majburiy maydonlari:** `client_event_id`, `event_time`, `event_type`.
Qo'shimcha: `device_seq`, `status`, `special`, `origin` (`auto`|`driver`|`manual_no_eld`),
`lat`, `lng`, `gps_accuracy_m`, `location_text`, `odometer_m`, `engine_hours`, `speed_kmh`,
`notes`, `trailer_ids[]`, `shipping_doc_ids[]`, `eld_device_id`.

**M32 [MUST]** `event_type` uchun **faqat** quyidagi qiymatlar yuboriladi (swagger enum):
`status_change`, `duty_status`, `intermediate`, `login`, `logout`, `power_on`, `power_off`,
`engine_on`, `engine_off`, `malfunction`, `diagnostic`, `certification`, `yard_moves`, `personal_use`.
Duty status o'zgarishi uchun **`status_change`** ishlatiladi.

**Javob (`PushResponse`):**
```
{ server_time, clock: {source, clock_skew_sec, time_unverified, warning, malfunction_code},
  events: [{client_event_id, result, reason?, superseded_by?, field?}],
  telemetry: {accepted, duplicate, rejected, distance_m},
  dvir: [...], chat: [...] }
```

**M33 [MUST] Batch bo'lish algoritmi (`sync_core`, sof funksiya, test bilan qoplangan):**
1. `outbox_items` dan `state=pending`, `next_attempt_at <= now` bo'lganlarini `device_seq` bo'yicha o'qi.
2. Chegaralar: `events ≤500`, `telemetry ≤5000`, `dvir ≤100`, `chat ≤500`, **jami JSON ≤4 MB**.
3. Batch elementlarini `state=inflight` qil, bitta **barqaror** `Idempotency-Key` generatsiya qil
   va uni batch bilan birga **saqla**.
4. Yubor. Timeout **30 s** (haydash rejimida 15 s).
5. Javob kelsa: har element natijasini yoz, `inflight → acked|rejected`.
6. Javob kelmasa (timeout/tarmoq): elementlarni `pending` ga qaytar, **lekin `Idempotency-Key` ni
   saqlab qol** — keyingi urinishda **aynan o'sha kalit** bilan yuboriladi (server 24 soat replay qiladi).
7. `409 IDEMPOTENCY_CONFLICT` → kalit boshqa payload bilan ishlatilgan: **yangi kalit** generatsiya
   qilinadi va batch qayta yig'iladi (bu holat faqat mijoz xatosida bo'ladi — Sentry'ga yoziladi).

**Xato holatlari:**
| Status/kod | Mobil xatti-harakati |
|---|---|
| `400 BAD_REQUEST` (`Idempotency-Key` yo'q) | Bug — Sentry, kalit qo'shib qayta yuborish |
| `401` | Refresh → bitta qayta urinish → bo'lmasa `M-44` |
| `403 ACCOUNT_INACTIVE` | Sessiya tozalanadi, outbox **saqlanadi** |
| `409 IDEMPOTENCY_CONFLICT` | M33.7 |
| `413 PAYLOAD_TOO_LARGE` / batch chegarasi | Batchni **ikkiga bo'l** va qayta urin (rekursiv, min 1 element) |
| `422 VALIDATION_ERROR` | Elementlar `rejected` deb belgilanadi, `M-55` ga chiqadi |
| `429 RATE_LIMITED` | `Retry-After` kutiladi |
| `5xx` / tarmoq | Backoff, cheksiz qayta urinish (ma'lumot yo'qolmaydi) |

**M34 [MUST]** Mobil **hech qachon** `403 FORBIDDEN` ni qayta urinish bilan «bombardimon» qilmaydi:
3 ta ketma-ket `403` dan keyin push 15 daqiqaga to'xtaydi va foydalanuvchiga banner ko'rsatiladi.

### 6.2 `GET /api/v1/sync/pull?since=<ts>&unit_id=<uuid>`
Javob (`PullResponse`): `events[]`, `daily_logs[]`, `log_edit_requests[]`, `unidentified_events[]`,
`hos_policy`, `defect_types[]`, `quick_notes[]`, `chat[]`, `next_since`, `server_time`, `truncated`.

**M35 [MUST] Kursor qoidalari:**
- Birinchi pull: `since` **yuborilmaydi** → server boshlang'ich oynani beradi (14 kun).
- Keyingilar: `since = sync_cursor.next_since` (server bergan qiymat, **mijoz hisoblamaydi**).
- `truncated == true` → **darhol** yangi `next_since` bilan qayta pull (drenaj sikli),
  maksimum **20 iteratsiya**, keyin keyingi siklga qoldiriladi.
- Kursor **faqat** pull to'liq lokal tranzaksiyaga yozilgandan keyin yangilanadi.
- Pull tranzaksiyasi atomik: `applyPull()` bitta Drift `transaction` ichida.

**M36 [MUST] Pull qo'llash tartibi:** `hos_policy` → `defect_types`/`quick_notes` →
`events` → `daily_logs` → `log_edit_requests` → `unidentified_events` → `chat` → kursor.
HOS policy avval qo'llanadi, chunki hisoblagichlar unga bog'liq.

**M37 [MUST]** Pull kelgan `events` uchun: `client_event_id` bo'yicha mos lokal yozuv topilsa —
u **server versiyasi bilan almashtiriladi** (`server_id`, `locked`, `superseded_by`, `origin` bilan);
topilmasa — yangi yozuv (boshqa qurilmada yoki admin tomonidan yaratilgan).

### 6.3 Sync jarayonining to'liq sikli
```
1. TimeSource'ni yangila (server_time offset)
2. push (agar outbox bo'sh bo'lmasa)   → element natijalarini yoz
3. pull (since kursori bilan)          → truncated bo'lsa drenaj
4. HOS'ni qayta hisobla (lokal, hos_engine)
5. Bildirishnoma/banner holatini yangila (pending edits, unidentified, conflicts)
6. sync_cursor.last_* ni yoz
```
**M38 [MUST]** Ushbu 6 qadam **shu tartibda**. Push'dan oldin pull qilinmaydi — aks holda
lokal event server qayta qurishida yo'qolishi mumkin.

---

## 7. Vaqt yaxlitligi

**Manba:** `tz.md` Q-B1.2, `eld-sync` §Vaqt yaxlitligi, `sync_dto.ClockVerdict`.

### 7.1 Manba ustuvorligi **[MUST]**
```
1) ELD RTC   (GPS bilan sinxron)     → time_source = "eld_rtc"
2) Server vaqti (oxirgi sync offset) → time_source = "server"
3) Telefon soati                     → time_source = "phone", time_unverified = true
```
`TimeSource` — yagona sinf; **`DateTime.now()` butun kodbazada faqat shu sinf ichida** chaqiriladi
(§2.4 taqiqi). U monoton soat (`Stopwatch`/`elapsedRealtime`) + oxirgi ishonchli nuqtaga tayanadi,
shuning uchun foydalanuvchi telefon soatini o'zgartirsa ham event vaqti sakramaydi.

### 7.2 Skew (farq) siyosati
| Farq `|phone − reference|` | Xatti-harakat |
|---|---|---|
| ≤ 2 daq | Normal. `clock_skew_sec` eventga yoziladi (informativ) |
| > **2 daq** | ⚠️ Sariq banner: «Your device clock is off by <n> min. Times may be adjusted.» + eventda `clock_skew_sec`, `time_unverified` shartli |
| > **10 daq** | 🔴 **`T` (timing) malfunction banneri**: «ELD timing malfunction — keep paper logs.» + `event_type=malfunction` (kod `T`) outbox'ga |

**M39 [MUST]** Server javobidagi `PushResponse.clock` (`ClockVerdict`) — **kanonik verdikt**.
Mobil o'z hisobini u bilan almashtiradi: `source`, `clock_skew_sec`, `time_unverified`, `warning`,
`malfunction_code`. Mahalliy hisob faqat oflayn holatda ishlatiladi.

**M40 [MUST]** ELD ulanmagan holda qo'lda status: `origin=manual_no_eld`, `time_source=phone`,
`time_unverified=true` (`tz.md` Q7.1). Bunday event UI da **sariq nuqta** bilan belgilanadi va
tooltip'da «Recorded without ELD connection» yoziladi.

**M41 [MUST]** `event_time > server_time + 5 daq` bo'lishi mumkin bo'lgan holatni mijoz **oldindan
oldini oladi**: outbox'ga yozishdan oldin `TimeSource` bilan tekshiriladi; ehtimoliy kelajak vaqt
bo'lsa server offseti qo'llanadi. Shunga qaramay server `time_in_future` bilan rad etsa — §5.6.

### 7.3 Kun chegarasi
**M42 [MUST]** Daily log kuni — **Home Terminal (Company) timezone**idagi 00:00–24:00
(`tz.md` Q10.2). Mobil bu TZ ni `/me` → company profili yoki `daily_logs[].timezone` dan oladi va
`kv_settings.home_terminal_tz` ga keshlaydi. Qurilma TZ **hech qachon** kun chegarasi uchun ishlatilmaydi.
Haydovchi vaqt zonasini kesib o'tsa ham kun o'zgarmaydi. DST kunlari 23/25 soat bo'ladi —
`hos_engine` buni golden vektorlar bilan tekshiradi (`dst_spring_forward_23h_day`, `dst_fall_back_25h_day`).

**M43 [SHOULD]** UI da vaqtlar **Home Terminal TZ** da ko'rsatiladi; qurilma TZ farq qilsa,
sarlavhada kichik izoh: «Times shown in <TZ abbr>».

---

## 8. HOS engine (Dart porti)

**Manba:** `.claude/skills/eld-hos/SKILL.md`, `tz.md` §4, `backend/internal/hos/`.

### 8.1 Asosiy shart
**M44 [MUST]** `packages/hos_engine` — **sof Dart paket**: `flutter` yo'q, `dart:io` yo'q, HTTP/DB yo'q,
global holat yo'q, **`DateTime.now()` yo'q** (vaqt har doim parametr).

**M45 [MUST]** `hos_engine` **`backend/internal/hos` bilan bit-to-bit bir xil natija beradi.**
O'lchov — `backend/internal/hos/testdata/hos-test-vectors.json` (**35 ta vektor**).
Fayl **nusxalanmaydi** — CI da backend repodan olinadi yoki submodule/symlink bilan bog'lanadi;
format o'zgarsa **CR majburiy** (fayl ikkala tomonning kontrakti).

### 8.2 Paket API (Go `internal/hos` ga parallel)
```dart
enum DutyStatus { off, sb, dr, on }        // JSON: "OFF","SB","DR","ON"
enum Special    { none, pc, ym }           // JSON: "none","pc","ym"

class HosEvent { final DateTime time; final DutyStatus status; final Special special;
                 final String? type; }     // time — UTC

class HosPolicy {                          // hammasi daqiqada; swagger `sync_dto.HosPolicy` bilan 1:1
  final int driveLimitMin, shiftWindowMin, breakRequiredAfterDriveMin, breakDurationMin,
            dailyRestMin, cycleLimitMin, cycleDays; final int? cycleRestartMin;
  final List<DutyStatus> breakQualifyingStatuses;
  final bool sleeperSplitEnabled, allowPc, allowYm, shortHaulException;
  final double ymMaxSpeedKmh, motionThresholdKmh;
  final int adverseConditionsExtensionMin;
  final int warnDriveMin, warnShiftMin, warnBreakMin, warnCycleMin;
  final String? versionId; final DateTime? effectiveFrom;
}

class HosCounters { final int driveLeftMin, shiftLeftMin, cycleLeftMin, breakLeftMin,
                              drivingTimeLeftMin; }
class DayTotals   { final int offMin, sbMin, driveMin, onMin; }
class HosViolation{ final String type, severity; final DateTime occurredAt; final int? limitMin, remainingMin; }
class RecapDay    { final DateTime date; final int onDutyMin, availableMin, gainedNextMin; }

HosCounters computeCounters(List<HosEvent> e, HosPolicy p, DateTime now, Location tz);
DayTotals   dayTotals(List<HosEvent> e, DateTime day, Location tz);
List<HosViolation> violations(List<HosEvent> e, HosPolicy p, DateTime day, Location tz);
List<RecapDay>     recap(List<HosEvent> e, HosPolicy p, DateTime day, Location tz);
```
`Location` — `package:timezone` dan (IANA). Sof paket `timezone` ga bog'lanishi mumkin
(u Flutter'ga bog'liq emas).

### 8.3 Qoidalar (Go implementatsiyasi bilan bir xil)
| № | Qoida |
|---|---|
| Q10.2 | Kun = Home Terminal TZ 00:00–24:00; eventlar UTC |
| Q10.3 | **SHIFT**: `daily_rest_min` uzluksiz OFF/SB dan keyingi birinchi ON/DR dan boshlanadi; OFF/SB 14h oynani uzaytirmaydi |
| Q10.4 | **BREAK**: oxirgi ≥`break_duration_min` uzluksiz qualifying statusdan keyin yig'ilgan DR ≥ `break_required_after_drive_min` → keyingi DR = violation |
| Q10.5 | **CYCLE**: oxirgi `cycle_days` kun ON+DR yig'indisi; `cycle_restart_min` uzluksiz OFF/SB → 0. `cycle_restart_min == null` → restart yo'q |
| Q10.6 | **Sleeper split**: SB ≥7h + OFF/SB ≥2h (yoki 8/2, 7/3); jami ≥10h, biri ≥7h SB; uzun qism 14h oynani pauza qiladi |
| Q10.7 | **Recap**: `available = cycle_limit − Σ(ON+DR, cycle_days)`; `gained_next = cycle_days` kun oldingi kunning ON+DR |
| Q10.9 | **`Driving Time Left = min(DRIVE, SHIFT, CYCLE, BREAK)`** |
| Q4.1 | **PC** — harakat DR emas, OFF hisoblanadi, HOS'ga kirmaydi |
| Q4.2 | **YM** — ON hisoblanadi, DRIVE limitiga kirmaydi, SHIFT'ga kiradi; tezlik > `ym_max_speed_kmh` → YM tugaydi → DR |
| Q4.3 | Unit `sleeper_berth=false` → SB mavjud emas |
| Q10.1 | Policy versiyalangan: **eski kunlar o'sha paytdagi policy bilan** hisoblanadi (retroaktiv violation yo'q) |

**M46 [MUST] Chegaraviy holatlar** (golden vektorlarda bor, alohida test qilinadi):
tartibsiz kelgan eventlar (`out_of_order_events`), oldingi kundan ochiq qolgan status
(`open_status_from_previous_day`), eventsiz kun (`empty_day_no_events`), ketma-ket bir xil status
(`consecutive_identical_statuses`), aniq yarim tundagi o'zgarish (`status_change_at_local_midnight`),
`policy_null_cycle_restart`, `no_sleeper_berth_unit`.

### 8.4 Server — kanonik, mobil — ko'rsatuvchi **[MUST]**
| Kim | Nima qiladi |
|---|---|
| **Server** | Violation'larni **yaratadi** (`/violations`, `daily_logs.violations`), `hos-summary` beradi |
| **Mobil** | Oflayn hisoblab **ko'rsatadi** va **oldindan ogohlantiradi** (warning) |

**M47 [MUST]** Onlayn bo'lganda mobil `GET /drivers/{id}/hos-summary?date=` javobini
**ustun** deb biladi va ko'rsatiladigan qiymatni server javobiga tenglaydi.
Agar lokal hisob server bilan **>2 daqiqa** farq qilsa — Sentry'ga `hos_drift` hodisasi
yoziladi (haqiqiy nomuvofiqlikni erta topish uchun), lekin foydalanuvchiga xato ko'rsatilmaydi.

**M48 [MUST]** Mobil **violation yaratmaydi** va «Violation» so'zini o'zi hisoblab yozmaydi.
Oflayn holatda faqat **warning** darajasidagi ogohlantirish beriladi:
«You are approaching your 11-hour driving limit (00:22 left)».
Serverdan kelgan `violations[]` esa aynan `severity` bilan ko'rsatiladi.

### 8.5 Hisoblagichlarni yangilash chastotasi
| Rejim | Qayta hisoblash |
|---|---|
| Home ekrani ochiq | Har **1 s** (faqat ko'rsatiladigan taymer), to'liq qayta hisoblash har **30 s** |
| Haydash rejimi | Taymer har 1 s, to'liq qayta hisoblash har **15 s** |
| Fon | Har 60 s (faqat warning chegarasini tekshirish uchun) |
| Har status o'zgarishida / pull'dan keyin | Darhol |

**M49 [SHOULD]** To'liq qayta hisoblash **`compute` isolate**da (`Isolate.run`) yuritiladi,
agar event soni >2000 bo'lsa — UI jerk bermasligi uchun.

### 8.6 Warning bildirishnomalari (lokal)
**M50 [MUST]** Mobil lokal push chiqaradi (server kutmasdan, oflayn ham ishlaydi):
`drive_left ≤ warn_drive_min` (30), `shift_left ≤ warn_shift_min` (60),
`break_left ≤ warn_break_min` (30), `cycle_left ≤ warn_cycle_min` (120).
Har chegara **kuniga bir marta** (takroriy spam yo'q), `hos_state` da `warned_flags` bilan.
---

## 9. Duty status oqimi

### 9.1 Statuslar va tugmalar
| Kod | UI matni (kanonik) | Qo'lda tanlanadimi |
|---|---|---|
| `OFF` | **Off Duty** | ha |
| `SB` | **Sleeper Berth** (qisqa: `SB`) | ha (unit `sleeper_berth=true` bo'lsa) |
| `DR` | **Driving** | **YO'Q** — avtomatik (`tz.md` Q4) |
| `ON` | **On Duty** | ha |
| `OFF (PC)` | **Personal Conveyance** | `OFF` ostidagi toggle, `allow_pc` bo'lsa |
| `ON (YM)` | **Yard Move** | `ON` ostidagi toggle, `allow_ym` bo'lsa |

**M51 [MUST]** `DR` tugmasi UI da **umuman mavjud emas** (dizayndagi kabi). Dizayndagi
`Drive mode (automaticlly)` komponent nomi — imlo xatosi (C bo'limi), kodda `driveModeAuto`.

**M52 [MUST]** Bosh ekranda **3 ta status tugmasi** ko'rsatiladi: `Off Duty` · `Sleeper Berth` · `On Duty`
(A tartibidagi kabi). B tartibidagi 2 ta tugma (`SB`/`OFF`) — **rad etiladi** (nomuvofiqlik #B-13, §21).
Unit'da sleeper berth bo'lmasa `SB` **o'chirilgan** (kulrang + tooltip), yashirilmaydi.

### 9.2 Status o'zgartirish formasi (`M-10` / `T-04`)
| Maydon | Turi | Qoida |
|---|---|---|
| Status | 3 ta tanlov + PC/YM toggle | Majburiy |
| **Location** | matn, avtomatik to'ldiriladi | Reverse geocoding, formatda `"12 km NE of Lahore"` (`tz.md` Q9). Qo'lda tuzatish mumkin. Aniqlik >150 m → ⚠️ ikonka + `M-12 Location error` dialogi |
| **Notes** | matn, **≤60 belgi** | Hisoblagich `n/60` ko'rsatiladi; `+` tugmasi → `M-11 Quick notes` |
| **Trailer Number** | ko'p tanlovli (chip'lar) | `GET /trailers` keshidan; qo'lda kiritish ham mumkin; `Bobtail` — maxsus qiymat |
| **Shipping Document** | ko'p tanlovli (chip'lar) | Bo'sh bo'lsa `N/A` |

Tugmalar: telefon — `Cancel` / `Save`; planshet — sarlavha qatori `Cancel · Change Duty Status · Save`.
Formaning yuqorisida HOS indikatorlari takrorlanadi (dizayndagi kabi).

**M53 [MUST]** Trailer/Doc'ni statusni o'zgartirmasdan yangilash mumkin (`tz.md` Q7):
alohida `Edit Documents` modali (`M-09` / `T-03`) → `TRAILER_CHANGE`/`DOC_CHANGE` semantikasi
`event_type=status_change` + o'zgargan `trailer_ids`/`shipping_doc_ids` bilan, status o'zgarmaydi.
Dizayndagi «Please change your status to update trailer and document.» matni **olib tashlanadi**
(nomuvofiqlik #B-30, §21) — u eskirgan cheklovni aks ettiradi.

### 9.3 Quick notes (`M-11` / `T-05`)
**M54 ✅** Kanonik to'plam — **10 bandli variant A** (`1170:2313`), 8 bandli variant B (`Break, Shower…`)
**rad etiladi**. Kanonik yozilishi (mobil/planshet farqi yo'q qilinadi):

`PTI` · `Hook` · `Pickup` · `Drop off` · `Delivery` · `Inspection` · `Check in` · `Fueling` · `Check out` · `Other`

**M55 [MUST]** Ro'yxat **serverdan** keladi: `sync/pull → quick_notes[]`. Yuqoridagi 10 ta —
**fallback** (birinchi pull'gacha). Server ro'yxati kelsa u ustun.
Bosilganda matn `Notes` maydoniga qo'shiladi (almashtirmaydi), 60 belgidan oshsa kesiladi va ogohlantiriladi.

### 9.4 Avtomatik `DR` (auto-drive) **[MUST]**
```
ECM tezligi ≥ hos_policy.motion_threshold_kmh (default 8 km/h)
   ├─ 3 soniya davomida uzluksiz  → status = DR (origin=auto), haydash rejimi ekrani ochiladi (≤1 s)
   └─ ECM mavjud emas (malfunction) → GPS tezligi fallback, eventda source belgisi bilan
```
| Qoida | Qiymat |
|---|---|
| Harakat chegarasi | `motion_threshold_kmh` (8 km/h ≈ 5 mph) |
| Harakat tasdig'i | ≥3 s uzluksiz (soxta ijobiy signalning oldini olish) |
| **To'xtash** | tezlik **0** va **≥3 soniya** (`tz.md` Q5.1) → haydash rejimidan chiqiladi, status `DR` da qoladi |
| Manba ustuvorligi | ELD/ECM → GPS fallback |
| PC rejimida | Harakat `DR` yozilmaydi (OFF qoladi) |
| YM rejimida | Tezlik > `ym_max_speed_kmh` (32) → YM tugaydi → `DR` (event `yard_moves` yopiladi) |
| Login qilinmagan | **Unidentified driving** (§11.9), qurilma o'zi yozadi |

**M56 [MUST]** Auto-DR event `origin=auto`, `speed_kmh` bilan yuboriladi. Foydalanuvchi uni
qo'lda o'zgartira olmaydi (`DR_IMMUTABLE`/`drive_not_manual`). Faqat `DR → PC/YM` o'tishi
haydovchi tomonidan, sabab bilan (`tz.md` Q17.1).

**M57 [MUST]** Haydash rejimiga o'tish **≤1 s** (§19). Buning uchun ekran oldindan tayyorlanadi
(`precache`), animatsiya 200 ms dan oshmaydi.

### 9.5 Haydash rejimi ekrani (`M-13 IN-DRIVE FOCUSED` / `T-13`)
Ekran to'liq band bo'ladi. Elementlar (dizayndan):
| Element | Manba |
|---|---|
| `Duty Hours` sarlavhasi | statik |
| `In-motion` + sana/vaqt | `TimeSource`, Home Terminal TZ |
| Katta hisoblagich `09:00:20` + `DRIVE` | joriy statusda o'tgan vaqt |
| **`Driving Time Left 02:32:02`** | `min(DRIVE, SHIFT, CYCLE, BREAK)` (Q10.9) |
| `Current Location` | oxirgi GPS + geocoding |

**M58 [MUST] Haydash rejimida bloklanadi:** chat yozish (§14), DVIR yaratish, sertifikatsiya,
sozlamalar, support formasi, log tahrirlash. Ruxsat etiladi: **PC/YM toggle**, `Off Duty`/`On Duty`
ga o'tish (haydovchi to'xtaganda), favqulodda qo'ng'iroq (`[MAY]`), idle so'roviga javob.

**M59 [MUST]** Haydash rejimi **avtomatik yopilmaydi** — to'xtash aniqlangandan keyin ham
haydovchi statusni o'zgartirmaguncha `DR` qoladi; ekran «You have stopped» holatiga o'tadi
va idle taymeri boshlanadi (§9.6).

### 9.6 Idle (harakatsizlik) so'rovi (`M-14` / `T-14`) **[MUST]**
```
t=0     tezlik 0 va ≥3 s → to'xtash aniqlandi
t=5 daq → modal: «You've been idle for 5 minutes. Are you still driving?»
          [No]  [Yes, driving]
          ├─ "Yes, driving"  → DR da qoladi, taymer qayta boshlanadi
          ├─ "No"            → status ON, event vaqti = SO'ROV CHIQQAN PAYT
          └─ 1 daqiqa javob yo'q → status ON, event vaqti = SO'ROV CHIQQAN PAYT
```
**M60 [MUST]** O'tish vaqti — **so'rov chiqqan payt** (5 daqiqa oldingi to'xtash vaqti **emas**).
FMCSA 5+1 = 6 daqiqa qoidasi (`tz.md` Q6).

**M61 ✅** Tugma matnining kanonik yozilishi — **`Yes, driving`** (planshetdagi variant).
Mobil `Yes, Driving` **rad etiladi** (nomuvofiqlik #B-8).

**M62 [MUST]** Modal ekran o'chiq bo'lsa ham chiqadi: yuqori ustuvorlikdagi **lokal bildirishnoma**
(full-screen intent / critical alert) + ovoz + tebranish. Foydalanuvchi javob bermasa 1 daqiqadan
keyin `ON` eventi baribir yoziladi (fon xizmatida).

### 9.7 Intermediate eventlar
**M63 [MUST]** Haydash rejimida har **60 daqiqada** `event_type=intermediate` eventi yoziladi
(`tz.md` Q5.2): joriy lat/lng, odometer, engine hours. Bu eventlar **tahrirlanmaydi** va
grid ustida ikonka bilan ko'rsatilmaydi (faqat kengaytirilgan jadvalda).

### 9.8 PC / YM toggle
| Rejim | Kirish | Chiqish |
|---|---|---|
| **Personal Conveyance** | `Off Duty` tanlanganda «Personal conveyance» toggle 🎨 + **sabab matni majburiy** (≤60) | Haydovchi qo'lda; yoki `ON`/`DR` ga o'tganda |
| **Yard Move** | `On Duty` tanlanganda «Yard move» toggle 🎨 + sabab (ixtiyoriy) | Haydovchi qo'lda; yoki **avtomatik** tezlik > 32 km/h |

**M64 [MUST]** `allow_pc`/`allow_ym` `false` bo'lsa toggle **ko'rsatilmaydi** (yashiriladi,
o'chirilgan holatda emas). Server `pc_not_allowed`/`ym_not_allowed` rad etsa — policy keshi eskirgan,
darhol `sync/pull` yuritiladi.

**M65 [MUST]** PC va YM logda maxsus belgi bilan ko'rinadi: grid'da `OFF` chizig'i ustida `PC` yorlig'i,
`ON` chizig'i ustida `YM` yorlig'i (dizaynda yo'q — 🎨 qo'shiladi).

### 9.9 ELD ulanmagan holda qo'lda kiritish
**M66 [MUST]** ELD `Not connected` bo'lsa ham status o'zgartirish **mumkin** (`tz.md` Q7.1).
Bunday event: `origin=manual_no_eld`, `time_source=phone`, `time_unverified=true`.
UI da forma tepasida sariq banner: «ELD not connected — this entry will be marked as manual.»
`odometer_m`/`engine_hours` bo'sh qoladi (server `null` qabul qiladi).

### 9.10 Maintenance moduli — **bu bosqichda YO'Q**
**M67 ✅ [MUST]** `tz.md` Q44 va dizayn izohi (`Not part of this phase`) bo'yicha:
- Mobil ilovada **Maintenance ekrani, ro'yxati, formasi yoki menyu bandi YO'Q**.
- Eskirgan Figma qatlamidagi `Profile › Maintenance` bandi (`1206:14181`) **implementatsiya qilinmaydi**.
- Haydovchiga **faqat bildirishnoma** boradi: `maintenance_upcoming`, `maintenance_overdue`
  (§15). Bosilganda **hech qayerga o'tmaydi** — bildirishnoma tafsiloti (title+body) ko'rsatiladi xolos.
- Dizayndagi `Invocie` yuklash formasi (imlo xatosi, C bo'limi) — **implementatsiya qilinmaydi**.

---

## 10. ELD qurilmasi va BLE

### 10.1 Holatlar
| Holat | Banner | Rang |
|---|---|---|
| `Connected` | `ELD · Connected` | Success `#2FA766` |
| `Connecting` | `ELD · Connecting…` | Warning |
| `Not connected` | `ELD · Not connected` | Error `#E2464A` |
| `Malfunction` | `ELD malfunction — keep paper logs` + kod | Error, doimiy |
| `Diagnostic` | `ELD diagnostic event` | Warning |

**M68 ✅** Kanonik matn — **`ELD · Not connected`**. Dizayndagi uchta variant
(`ELD . Connected`, `ELD . Not connected`, `ELD not connected`) birlashtiriladi (#B-31).

### 10.2 Ruxsatlar oqimi (`M-08 Permissions`)
Ketma-ketlik **[MUST]** (birinchi login'dan keyin, onboarding sifatida):
```
1. Notifications  → 2. Bluetooth (Android 12+: BLUETOOTH_SCAN/CONNECT)
3. Location (When in use) → 4. Location (Always)  ← alohida ekranda, ta'rif bilan
5. Android 13+: POST_NOTIFICATIONS · Android: battery optimization istisnosi
```
Ekran dizayndagi jadval bilan bir xil:
| Ruxsat | Holat qiymatlari |
|---|---|
| Location | `Allowed` / `Not allowed` |
| Location always | `Allowed` / `Not allowed` |
| Bluetooth | `Allowed` / `Not allowed` |
| Notifications | `Allowed` / `Not allowed` |
| Turn on GPS | toggle (tizim sozlamasiga o'tkazadi) |
| Turn on bluetooth | toggle (tizim sozlamasiga o'tkazadi) |

**M69 [MUST]** Ruxsat rad etilsa — ilova **bloklanmaydi**, lekin drawer'dagi `Permissions`
bandida **qizil ogohlantirish belgisi** turadi (dizayndagi kabi) va Home'da banner ko'rinadi.
«Don't ask again» bosilgan bo'lsa — `openAppSettings()` ga yo'naltiriladi.

**M70 [MUST]** ELD ga ulanish uchun ruxsatlar yetishmasa dizayndagi dialog:
«In order to connect to the ELD, you must allow all the permissions.» — `Cancel` / `Allow Permissions`.

### 10.3 Ulanish oqimi
```
Sessiya active + unit biriktirilgan (/me → driver.unit)
   → oxirgi ma'lum ELD MAC/ID (kv_settings) bo'lsa: to'g'ridan-to'g'ri reconnect
   → bo'lmasa: skan (filtr: xizmat UUID + qurilma nomi prefiksi) → tanlash ro'yxati 🎨
   → juftlash/autentifikatsiya (vendor protokoli) → handshake: firmware, VIN, RTC, odometer
   → VIN unit VIN bilan solishtiriladi → mos kelmasa ogohlantirish 🎨
   → holat: Connected; `power_on` eventi yoziladi
```
| Parametr | Qiymat |
|---|---|
| Skan timeout | 20 s |
| Qayta ulanish | Eksponensial `2 s → 5 s → 15 s → 60 s` (maksimum 60 s), cheksiz |
| Ulanish uzilishi | 30 s ichida tiklanmasa `Disconnected` banneri + telemetriyada `disconnected=true` |
| RSSI chegarasi | < −90 dBm da ogohlantirish `[MAY]` |

**M71 [MUST]** ELD dan olingan **RTC vaqti** har handshake'da `TimeSource` ga beriladi (§7.1).

**M72 [MUST]** ELD buferi: qurilma oflayn yozgan eventlarni (`power_on/off`, harakat) ulanishda
o'qib olish va **`client_event_id` bilan deduplikatsiya qilib** outbox'ga qo'shish.
Vendor buferidagi ID barqaror bo'lmasa — `sha256(device_id + eld_seq + ts)` dan
deterministik UUID v5 generatsiya qilinadi (takroriy o'qishda dublikat bo'lmasligi uchun).

### 10.4 Fon rejimi
| Platforma | Yechim |
|---|---|
| **Android** | `foreground service` (`FOREGROUND_SERVICE_LOCATION` + `FOREGROUND_SERVICE_CONNECTED_DEVICE`), doimiy bildirishnoma: joriy status + `Driving Time Left`. Doze istisnosi so'raladi (`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`) |
| **iOS** | `UIBackgroundModes`: `bluetooth-central`, `location`. `CBCentralManager` **state restoration** (`CBCentralManagerOptionRestoreIdentifierKey`) — ilova o'ldirilsa tizim uni BLE hodisasida qayta uyg'otadi. `allowsBackgroundLocationUpdates = true`, `pausesLocationUpdatesAutomatically = false` |

**M73 [MUST]** Fon xizmati **haydash rejimida hech qachon to'xtatilmaydi**. Android'da
foydalanuvchi bildirishnomani o'chira olmaydi (`ongoing`).

**M74 [MUST]** iOS'da `state restoration` ishlagach ilova **darhol** sync scheduler'ni ishga tushiradi
va oxirgi holatni Drift'dan tiklaydi.

### 10.5 Diagnostika (`M-36 Diagnosis of device`)
| Ko'rsatkich | Qiymatlar | Manba |
|---|---|---|
| `ELD coordinates` | `Working` / `Not working` | Oxirgi 60 s ichida ELD dan lat/lng keldimi |
| `GPS coordinates` | `Working` / `Not working` | Telefon GPS fix bormi |
| `Network quality` | `Good` / `Fair` / `Poor` / `Offline` | Oxirgi sync kechikishi |

`M-37 Check Network`: yarim doira o'lchagich, shkala `0 · 20 · 30 · 50 · 75 · 100`, birlik `mbps`,
tugma `Check Network`. **M75 [MUST]** O'lchov **backendning kichik test faylini** yuklab olish
orqali bajariladi (tashqi speedtest xizmatlari **ishlatilmaydi** — PII va sertifikat pinning sababli).
❓ **M76** Test fayli endpoint'i `v1` da yo'q — CR kerak yoki `GET /app/config` javob vaqti
asosidagi taxminiy o'lchov ishlatiladi (MVP: taxminiy o'lchov, «approx.» yorlig'i bilan).

### 10.6 Malfunction va diagnostic kodlari **[MUST]**
FMCSA Appendix A kodlari (`tz.md` §10.5):
| Kod | Ma'nosi | Mobil xatti-harakati |
|---|---|---|
| `P` | Power compliance | Doimiy qizil banner |
| `E` | Engine synchronization | Banner + `origin=manual_no_eld` rejimiga tayyorlik |
| `T` | **Timing** (>10 daq skew) | Banner (§7.2), `TimeSource` `phone` ga tushadi |
| `L` | Positioning | Banner; location qo'lda kiritish majburiy bo'ladi |
| `R` | Data recording | Banner + «Free up device storage» maslahati |
| `S` | Data transfer | Banner: «Logs have not been transferred for <n> days» |
| `O` | Other | Banner |

**M77 [MUST]** Har malfunction → `event_type=malfunction` (kod `notes` da yoki `diagnostics[]` da
telemetriya nuqtasida) outbox'ga. Banner matni: **«ELD malfunction (<kod>) — keep paper logs»**.
Banner **yopilmaydi** (dismiss yo'q), faqat holat tiklanganda yo'qoladi.

**M78 [SHOULD]** `S` (data transfer) kodi mobil tomonidan ham chiqariladi: agar **8 kundan**
ortiq muvaffaqiyatli push bo'lmagan bo'lsa.

### 10.7 Vendor SDK
**M79 [MAY]** Tanlangan ELD modelida Flutter paketi bo'lmasa — `platform channel` (Kotlin/Swift)
yoziladi: `MethodChannel('eld/device')` + `EventChannel('eld/stream')`.
Interfeys **abstraksiya ortida**: `abstract class EldTransport` — `flutter_blue_plus`
implementatsiyasi va vendor implementatsiyasi almashtiriladigan bo'ladi.
Baholashga **1–2 hafta** ajratiladi (`tz.md` B§22).

❓ **M80** ELD qurilma modeli hali tanlanmagan (`tz.md` B§23). Shu sababli 6-bosqich
(BLE) rejasida **mock transport** birinchi bo'lib yoziladi va ekranlar u bilan to'liq ishlaydi.
---

## 11. Ekranlar spetsifikatsiyasi

### 11.0 Dizayn tizimi va umumiy qoidalar

#### 11.0.1 Ranglar (`design-inventory.md` A.1) — `core/ui/tokens.dart`
| Token | Light | Dark |
|---|---|---|
| `primary` | `#B7002C` | `#B7002C` (o'zgarmaydi) |
| `bg` | `#FCFCFD` | `#1B222C` |
| `surface` (karta) | `#FFFFFF` | `#303E4B` |
| `surfaceAlt` (jadval sarlavhasi) | `#F2F4F7` | `#233040` |
| `sidebar` | `#FFFFFF` | `#233040` |
| `stroke` | `#E5E7EB` | `#52565F` |
| `textPrimary` | Neutral 9 `#23262F` | Neutral 1 `#FCFCFD` |
| `textSecondary` | Neutral 6 `#777E90` | Neutral 5 `#B1B5C3` |
| `success` / `successBg` / `successDark` | `#2FA766` / `#C5EFD8` / `#103923` | bir xil |
| `warning` / `warningBg` / `warningDark` | `#F6BA47` / `#FCEAC8` / `#7B5D24` | bir xil |
| `error` / `errorBg` / `errorDark` | `#E2464A` / `#F9DADB` / `#5A1C1E` | bir xil |
| HOS: `break` sariq · `drive` yashil · `shift` ko'k `#466FF7` · `cycle` primary | bir xil | bir xil |

**M81 [MUST]** State (Success/Warning/Error), Decorative va HOS ranglari **ikkala temada bir xil**
(`design-inventory.md` bet 125–126). Faqat fon, sirt, matn va chegara ranglari almashadi.

**M82 [MUST]** Warning rangi bo'yicha dizayndagi nomuvofiqlik (`#F9B385` yozilgan, RGB `246,176,71`)
— **`#F6BA47` kanonik** (RGB qiymati to'g'ri), #C-16.

#### 11.0.2 Tipografika
- **IBM Plex Sans** — barcha matn. **Product Sans** — faqat Display darajasi (splash logotipi;
  litsenziya bo'lmasa IBM Plex Sans Bold bilan almashtiriladi ❓ **M83**).
- Shkala `core/ui/typography.dart` da **nomlangan token** sifatida (`display1`, `h1…h4`, `body1…body17`).
- **M84 [MUST] — CR-F01 (2026-09-07, Figma o'lchovi bilan tuzatildi)** `Body 6` va `Body 7` **bir xil emas**:
  ikkalasi ham IBM Plex Sans Regular 20, lekin `body6` lineHeight = **120%**, `body7` = **150%**.
  Ikkalasi ham saqlanadi, alias qilinmaydi. Avvalgi «dublikat» qarori Figma faylida tasdiqlanmadi
  (`mobile/design/figma/DIFF.md` #D-02). **Barcha token'larda lineHeight 120%, yagona istisno `body7` = 150%.**
- **M85 [MUST]** `MediaQuery.textScaler` hurmat qilinadi (0.85–1.3 oraliqda cheklanadi);
  1.3 dan yuqorida layout buzilmasligi golden testda tekshiriladi.

#### 11.0.3 Spacing, radius, effekt
- **Spacing — CR-F02 (2026-09-07, o'lchovdan)** Dizayn **5 pt bazasida**: `5/10/15/20/25/30/40`.
  Chastota (10 kanonik ekran, barcha auto-layout tugunlari): gap `10`×193 · `5`×113 · `15`×53 · `8`×46 · `20`×18 · `25`×18.
  Ekran gorizontal padding — `16`. Avvalgi «4 pt bazasi» **taxmin** edi va o'lchov bilan rad etildi (#D-23).
- **Radius — CR-F03 (2026-09-07, o'lchovdan) — avvalgi M86 BEKOR QILINDI.**
  O'lchangan chastota: `8`×56 · `4`×30 · `24`×25 · `6`×18 · `10`×18 · `12`×4 · pill `200`×6.
  **`27.25` qiymati ekranlarda umuman uchramaydi** — u `Carts Dropdown` **soyasining blur radiusi**,
  burchak radiusi emas. Kanonik to'plam: `sm=4`, `md=8` (dominant), `lg=12`, `xl=24`, `pill=200` (#D-01, #D-22).
- Soya: `Carts Dropdown` (`DROP_SHADOW`) — blur **27.25**, offset `(0, 7.79)`, rang `#485966` opacity `10.1%`;
  dark temada opacity 2× pasaytiriladi.
- Stroke: default `1`, urg'u `2` (o'lchovdan, #D-25).

> **Manba ustuvorligi:** `mobile/design/figma/tokens.json` — Figma dan to'g'ridan-to'g'ri o'lchangan qiymatlar,
> **kanonik**. Ushbu bo'lim bilan ziddiyat bo'lsa `tokens.json` g'olib; farqlar `mobile/design/figma/DIFF.md` da.

#### 11.0.4 Umumiy patternlar
| Pattern | Qoida |
|---|---|
| **Yuklanish holati** | Dizaynda **umuman yo'q** (A.8). 🎨 Qo'shiladi: skeleton (ro'yxatlar), inline spinner (tugmalar), pull-to-refresh |
| **Xato holati** | Dizaynda umumiy xato ekrani yo'q. 🎨 Qo'shiladi: `ErrorState` widget (ikonka + xabar + `Retry`) |
| **Bo'sh holat** | Dizayndagilar saqlanadi: `No DVIR Found` / `There is no data to show you right now`; `No Notifications Yet` / «Stay tuned!…»; `No Ticket Added Yet` / «Start to add your first ticket…» |
| **Tasdiqlash modali** | Sarlavha + savol + `Cancel` / `Confirm` |
| **Snackbar/Toast** | 3 s, pastda; haydash rejimida **ko'rsatilmaydi** (diqqatni chalg'itmaslik) |
| **Offline banner** | Tepada 32 dp, kulrang: «Offline — <n> records queued» |

#### 11.0.5 Navigatsiya — bosh ekran **A/B qarori**

**M87 ✅ QAROR: B tartib (pastki tab navigatsiya) kanonik, A tartibning HOS halqalari planshetga o'tadi.**

| Nima olinadi | Qayerdan | Sabab |
|---|---|---|
| **Pastki tab bar (4 bo'lim)** | B | Bir teginishda Logs/Chat; A da drawer → 2 teginish. Haydovchi qo'lqopda, tebranishda ishlaydi |
| **Katta joriy status + taymer** | B | Haydovchining №1 ma'lumoti; A da u kichik matn |
| **Tezkor amallar qatori** (`Inspection Report · Log Report · Co-driver · Leave Truck`) | B | Planshetdagi `Actions` paneli bilan **bitta mental model** |
| **3 ta status tugmasi** (`Off Duty·Sleeper Berth·On Duty`) | A | B dagi 2 tugma yetarli emas (M52) |
| **Chiziqli HOS indikatorlari** telefonda | B | 393 dp kenglikda 4 halqa juda kichik bo'ladi |
| **Halqasimon HOS indikatorlari** planshetda | A | 1366 dp da halqa o'qilishi yaxshi, dizaynda planshet allaqachon halqali |
| Drawer (hamburger) | A | Ikkilamchi bandlar: Profile, Permissions, Diagnosis, Support, Legal, Logout |

**Rad etilgan:** A tartibning yagona-drawer navigatsiyasi; B ning 393×1650 uzun scroll'i
(above-the-fold talabi bilan cheklanadi, M88).

**M88 [MUST]** Home ekranida **scroll'siz ko'rinishi shart**: ELD banneri · joriy status + taymer ·
4 ta HOS indikatori · status tugmalari. Qolganlari (Trip Details, Certify, log grid) — scroll ostida.

**M89 ✅ Pastki tab bar — 4 bo'lim:**
| Tab | Ikonka | Marshrut | Badge |
|---|---|---|---|
| **Home** | uy | `/home` | — |
| **Logs** | hujjat/grid | `/logs` (`Main`·`Logs`·`DVIR` sub-tablari) | sertifikatlanmagan kunlar soni |
| **Chat** | xabar | `/chat` | o'qilmagan xabarlar |
| **Profile** | avatar | `/profile` | ruxsat ogohlantirishi (qizil nuqta) |

`Notifications` — tepa paneldagi qo'ng'iroq ikonkasi (dizayndagi kabi), tab emas.
`Inspection`, `Co-driver`, `Leave Truck` — Home'dagi tezkor amallar qatorida.

#### 11.0.6 Tepa panel (app bar)
Telefon: `hamburger` · **`OneBook ELD`** · `qo'ng'iroq (badge)` · `xat/chat` · `yangilash (sync)`.
Planshet: chapda `ELD · Connected`, markazda logotip, o'ngda `xat` · `qo'ng'iroq` · `yangilash` · `tema`.

**M90 [MUST]** Brend nomi hamma joyda **`OneBook ELD`** (bitta so'z + probel + ELD). Dizayndagi
`OneBookELD` (planshet qatlam nomi) va `ONEBOOK ELD` variantlari birlashtiriladi.

#### 11.0.7 Sana/vaqt formatlari — **M91 ✅ (dizayndagi 6 xil variant birlashtiriladi, #B-19/#C-14)**
| Kontekst | Format | Namuna |
|---|---|---|
| Sana tasmasi (8 kun) | `EEE dd` | `Fri 07` |
| Ro'yxat sarlavhasi / guruh | `EEE, MMM d` | `Tue, May 20` |
| To'liq sana-vaqt | `MMM d, yyyy · hh:mm a` | `May 28, 2025 · 02:24 PM` |
| Log event vaqti | `hh:mm:ss a` | `02:03:23 AM` |
| Davomiylik / hisoblagich | `HH:mm:ss` | `22:02:21` |
| HOS indikatori | `HH:mm` | `08:00` |
| Bildirishnoma vaqti | **nisbiy** <24h (`2h ago`), keyin `MMM d, hh:mm a` | `2h ago` / `May 28, 10:04 AM` |
| Koordinata | `.` (nuqta) o'nlik ajratgich | `23.97464553778` |

**M92 [MUST]** Barcha formatlar `intl` orqali, `en_US` lokali bilan. Hafta kunlari **3 harfli**
(`Mon Tue Wed Thu Fri Sat Sun`) — dizayndagi `Tues`/`Thurs` **rad etiladi** (#B-11).
Bo'sh qiymat hamma joyda **`N/A`** (`na` rad etiladi, #B-10).

---

### 11.1 Ekranlar registri — mobil (telefon)

| ID | Ekran | Marshrut | Modul | Figma |
|---|---|---|---|---|
| M-01 | Splash | `/` | Auth | `958:22` |
| M-02 | Login | `/login` | Auth | `958:44 · 1113:9176` |
| M-03 | Leave truck / Return to truck | `/paused` | Auth | `1116:9231` |
| M-04 | PIN entry | `/pin` | Auth | 🎨 |
| M-05 | Accept invitation (parol + PIN) | `/invite` | Auth | 🎨 |
| M-06 | Forgot password | `/forgot` | Auth | 🎨 |
| M-07 | Reset password | `/reset` | Auth | 🎨 |
| M-08 | Two-factor (TOTP) | `/2fa` | Auth | 🎨 |
| M-09 | **Home** | `/home` | Home | `2177:12192` (B) + `1202:9259` (A) |
| M-10 | Drawer (yon menyu) | — | Home | `1202:9259` |
| M-11 | Edit documents (Trip Details) | modal | Home | `2230:20627` |
| M-12 | Change duty status | `/duty/change` | Duty | `1083:10550` |
| M-13 | Quick notes | modal | Duty | `1170:2313` |
| M-14 | Location inaccurate | dialog | Duty | `1102:2021` |
| M-15 | Drive mode (focused) | `/drive` | Duty | `1170:2684` |
| M-16 | Idle prompt (5 min) | dialog | Duty | `2181:17282` |
| M-17 | ELD not connected | dialog | ELD | `1102:1738` |
| M-18 | Permissions | `/permissions` | ELD | `1107:2310` |
| M-19 | ELD device connect/scan | `/eld` | ELD | 🎨 |
| M-20 | Co-driver switch confirm | dialog | Co-driver | `1113:8480` |
| M-21 | Select shipping document (Myself/Co-driver) | modal | Co-driver | `1113:8764` |
| M-22 | Log Report — Main | `/logs?tab=main` | Logs | `1085:14341` |
| M-23 | Log Report — Logs (grid) | `/logs?tab=logs` | Logs | `1085:13169` |
| M-24 | Log Report — DVIR | `/logs?tab=dvir` | Logs | `1087:14921 · 1154:6104` |
| M-25 | Log event detail | bottom-sheet | Logs | `1111:7334` |
| M-26 | **Pending edits** (ro'yxat) | `/logs/pending-edits` | Logs | 🎨 |
| M-27 | **Pending edit detail** (Approve/Reject) | `/logs/pending-edits/:id` | Logs | 🎨 |
| M-28 | **Unidentified driving claim** | `/unidentified` | Logs | 🎨 |
| M-29 | Certify — kunlar ro'yxati | `/certify` | Certify | `1102:397` |
| M-30 | Certify — Sign | `/certify/:date/sign` | Certify | `1102:817` |
| M-31 | Certify — Not Ready | holat | Certify | `1102:1260` |
| M-32 | Add DVIR (forma) | `/dvir/new` | DVIR | `1089:4441` |
| M-33 | Defect picker (truck/trailer) | `/dvir/new/defects` | DVIR | `1169:1887 · 1169:2106` |
| M-34 | DVIR review + signature | `/dvir/new/confirm` | DVIR | `1090:4687 · 1090:4901` |
| M-35 | DVIR details | `/dvir/:id` | DVIR | `1166:869` |
| M-36 | **Previous defects certification** | dialog | DVIR | 🎨 |
| M-37 | Inspection Report (3 amal) | `/inspection` | Inspection | `1111:7825` |
| M-38 | Begin inspection (kiosk) | `/inspection/view` | Inspection | `1111:8013` |
| M-39 | Exit inspection (PIN) | dialog | Inspection | 🎨 |
| M-40 | Send via email | modal | Inspection | `1169:1196` |
| M-41 | Send the file (DOT) | modal | Inspection | `1169:1332` |
| M-42 | Chat | `/chat` | Chat | `1118:114` |
| M-43 | Notifications | `/notifications` | Notif | `1156:7135 · 1156:7244` |
| M-44 | Profile | `/profile` | Profil | `1119:445` |
| M-45 | Settings | `/profile/settings` | Profil | `1131:392` |
| M-46 | Diagnosis of device | `/profile/diagnosis` | Profil | `1131:965` |
| M-47 | Check network | `/profile/network` | Profil | `1122:319` |
| M-48 | Give feedback | `/profile/feedback` | Profil | `1131:1149` |
| M-49 | Contact support (forma) | `/support/new` | Support | `1179:7028` |
| M-50 | Support & Helpdesk (ro'yxat) | `/support` | Support | `1179:7142` |
| M-51 | Support ticket thread | `/support/:id` | Support | 🎨 |
| M-52 | Privacy Policy | `/legal/privacy` | Huquqiy | `2627:25778` |
| M-53 | Terms of Use | `/legal/terms` | Huquqiy | `2627:25778` |
| M-54 | **Sync status** | `/sync` | Tizim | 🎨 |
| M-55 | **Sync conflicts** | `/sync/conflicts` | Tizim | 🎨 |
| M-56 | **Signed out elsewhere** | `/signed-out` | Tizim | 🎨 |
| M-57 | **Force update** | `/update` | Tizim | 🎨 |
| M-58 | Sessions (my devices) | `/profile/sessions` | Auth | 🎨 |

**Jami: 58 ta mobil ekran** (dizayndagi 73 light ekran — variantlar va tema nusxalarini
birlashtirgandan keyin 58 mantiqiy ekran; 15 ta yangi 🎨 ekran qo'shildi).

---

### 11.2 Auth modulining ekranlari

**M-01 Splash** — logotip, matn yo'q. Bootstrap (§4.2). Maksimum ko'rinish vaqti 3 s;
undan uzoq bo'lsa progress ko'rsatiladi. Dark: fon `#1B222C`, logotip oq variant.

**M-02 Login**
| Jihat | Tafsilot |
|---|---|
| Maydonlar | `Username or Email address`, `Password` (ko'z ikonkasi) |
| Amallar | `Login`, `Forgot password?` 🎨 |
| Holatlar | bo'sh (tugma o'chirilgan) · to'ldirilgan · yuborilmoqda (spinner) · xato (inline qizil matn) |
| Matn | «This app does not support account registration. Please reach out to your fleet manager for assistance.» |
| Footer | `Copyright © 2025 OneBook ELD` (yil dinamik) |
| Oflayn | Tugma o'chirilgan + banner «Login requires an internet connection» |
| Dark | Fon `#1B222C`, input `#303E4B`, chegara `#52565F` |

**M-03 Leave truck / Return to truck** — login formasining nusxasi + **`Return to truck`** tugmasi.
`Return to truck` → `M-04 PIN`. Ekranning yuqorisida pauza qilingan haydovchi ismi ko'rsatiladi.
**M93 ✅** Kanonik nom — **`Leave Truck`** (drawer'dagi `Leave the Truck` rad etiladi, #B-6).

**M-04 PIN entry** 🎨 — 6 xonali, katta raqamli klaviatura (planshetda ham),
xato hisoblagichi, blok taymeri. `Forgot PIN?` → parol bilan kirish (`M-02`).

**M-05 Accept invitation** 🎨 — parol (2×) + PIN (2×) + `Privacy Policy` / `Terms of Use` roziligi.
Parol kuchi indikatori. `POST /auth/invitation/accept`.

**M-08 Two-factor** 🎨 — QR + secret (setup) yoki 6 xonali kod (verify).
Faqat rol talab qilsa ko'rsatiladi (`Profile.totp_enabled`, `requires_totp_setup`).

---

### 11.3 Home moduli

**M-09 Home** (`/home`) — kanonik tartib (M87):
```
┌ App bar: ☰  OneBook ELD  🔔 ✉ ⟳ ──────────────┐
│ [ELD · Not connected]            ← banner (holatga qarab rang)
│ [⚠ Offline — 12 records queued]  ← shartli
│ [⚠ ELD malfunction (T) — keep paper logs] ← shartli, yopilmaydi
├─ Sana: 19 / Mon, November        (Home Terminal TZ)
├─ Unit: 1021 · John Smith · BMW mi7 2019
├─ JORIY STATUS:  On Duty          10h 45m 32s     [Off Duty][SB][On Duty]
├─ HOURS OF SERVICE (4 chiziqli indikator)
│    BREAK 08:00 · DRIVE 09:00 · SHIFT 10:00 · CYCLE 65:00
├─ Tezkor amallar: [Inspection Report][Log Report][Co-driver][Leave Truck]
│ ───────────── scroll chegarasi (M88) ─────────────
├─ Trip Details kartasi (Shipping Doc · Trailer Number · Notes)   [✎]
├─ Certify (Last 8 days) kartasi — `Not Signed` (qizil ramka)
├─ [Pending edits (2)]  ← shartli, sariq karta
├─ [Unidentified driving (3)] ← shartli, sariq karta
└─ Log bloki: 24h grid + jami + warning/violation satrlari + eventlar jadvali
```
| Jihat | Tafsilot |
|---|---|
| Ma'lumot manbai | Lokal Drift (darhol) → keyin `sync/pull` yangilaydi |
| Yangilanish | Taymer 1 s (hisoblagich), to'liq 30 s |
| Offline | To'liq ishlaydi; banner ko'rinadi |
| Bo'sh holat | Unit biriktirilmagan bo'lsa: «No unit assigned. Contact your fleet manager.» |
| Xato | Sync xatosi banner sifatida, ekran bloklanmaydi |
| Dark | Kartalar `#303E4B`, HOS indikator ranglari o'zgarmaydi |

**M-10 Drawer** — avatar + ism + unit №, email + telefon, litsenziya + shtat. Bandlar:
`Permissions (!)` · `Check Network` · `Diagnosis of Device` · `App Updates` · `Zoom` (toggle) ·
`Dark mode` (toggle) · `Feedback` · `Customer Support` · `User Manual` · **`Logout`** (qizil).
Pastda `Terms of Use · Privacy Policy`.
**M94 [MUST]** `Zoom` toggle — ilova ichidagi matn kattalashtirish (×1.0 ↔ ×1.25), `kv_settings` da saqlanadi.
**M95 [MUST]** Drawer'da **`Maintenance` bandi yo'q** (M67).

**M-11 Edit documents** (modal) — `Trailer Number` (chip'lar, `×` bilan), `Shipping Document`
(chip'lar), `Note`. `Cancel` / `Save`. Saqlanganda status o'zgarmaydi (M53).

---

### 11.4 Logs moduli

**M-22/23/24 Log Report** — tepada 3 sub-tab: `Main` · `Logs` · `DVIR`;
ostida **8 kunlik sana tasmasi** (`Fri 07 … Fri 14`), joriy kun **qizil**, sertifikatlangan kun
yashil nuqta bilan, sertifikatlanmagan — kulrang.

**M96 ✅** Sana tasmasi formati — **`EEE dd`** (`Fri 07`), planshetda ham **bir xil**
(planshetdagi `07 Jan` rad etiladi, #B-17).

**`Main` tabi:**
| Blok | Maydonlar |
|---|---|
| Kun ma'lumoti | `Shipping documents`, `Trailer numbers`, `Certify` (`Signed`/`Not Signed`), `Notes` |
| `Driver Information` | `Driver Name`, `Unit #`, **`Home Terminal`** |
**M97 ✅** Dizayndagi `Main Terminal` → kanonik **`Home Terminal`** (`tz.md` va backend
`home_terminal_address` bilan mos), #B-yangi.

**`Logs` tabi:**
- 24 soatlik grid: 4 qator `OFF` / `SB` / `DR` / `ON`, ko'k chiziq `#466FF7`,
  PC/YM belgilari (M65), event ikonkalari (`pti`, `fuel`, `certify`, `malfunction`).
- Jamilar: **`OFF 03:06 · SB 00:00 · DR 00:00 · ON 00:00`**.
  **M98 ✅** Kanonik format — **qisqartma + `HH:mm`** (mobil varianti). Planshetdagi
  `Off - 00:00` **rad etiladi** (#B-9) — ikkala klientda bir xil.
- Ogohlantirish satrlari: sariq `Warning: …`, qizil `Violation: …` (serverdan; §8.4).
- Jadval: `Status` · `Start Time` · `Location` · `Document`; kengaytirilganda + `Trailers` · `Notes` · `Action`.
  **M99 ✅** Oxirgi ustun nomi — **`Action`** (mobil), planshetdagi `Edit` rad etiladi (#B-16).
  Ustun ichida: `✎` (tahrirlash mumkin bo'lsa) yoki `🔒` (`locked=true`).

**M-25 Log event detail** (bottom-sheet): `Status`, `Start`, `Duration`, `Location`, `Odometer`,
`Engine hours`, `Notes`, `Origin` badge (`Auto`/`Driver`/`Admin edit`/`Assigned`/`Manual (no ELD)`),
`Edited` belgisi + asl qiymat (§13.4).

**Offline xatti-harakati (barcha Logs ekranlari):** oxirgi 14 kun to'liq lokal; 14 kundan eskisi
uchun «Connect to the internet to load older logs» + `Retry`.

**`DVIR` tabi:** ro'yxat — `Trailer Number` · `Type` · `Created At`.
Bo'sh: `No DVIR Found` + `There is no data to show you right now`. FAB: `+ Add DVIR`.

---

### 11.5 Unidentified driving (`M-28`) 🎨

**M100 [MUST]** Login qilingandan keyin va har `sync/pull` dan keyin: agar shu unit uchun
`unidentified_events[]` da `status=pending` bo'lsa — Home'da sariq karta:
«There are **N** unidentified driving events on this vehicle.» → `Review`.

Ekran: har blok uchun `Start`, `End`, `Duration`, `Distance`, `Unit #`, mini-xarita `[MAY]`.
Amallar: **`This was me`** (`POST /unidentified-events/{id}/claim`) · **`Not mine`** (lokal
`dismissed_local=true`, serverga hech narsa yuborilmaydi — admin hal qiladi).

| Holat | UI |
|---|---|
| `409 ALREADY_ASSIGNED` | «This block was already assigned to another driver.» + ro'yxatdan olib tashlash |
| Oflayn | Claim outbox'ga tushadi (`kind=claim`), karta «Pending sync» holatida |
| Claim qabul qilinganda | Eventlar `origin=assigned` bilan logga tushadi, kun `needs_recertify` bo'lishi mumkin |

**M101 [MUST]** Claim **qaytarilmaydi** (undo yo'q) — tasdiqlash modali majburiy:
«Claiming adds this driving time to your log. This cannot be undone.»

---

### 11.6 DVIR moduli

#### 11.6.1 Holat mashinasi va mobil 3 turi — **nomuvofiqlikni hal qilish**

**Backend haqiqat** (`swagger.json` `DvirReport.status`):
```
draft → submitted_no_defects
draft → submitted_defects_found → repaired → certified
                                 └────────→ closed_no_certification
```
Backend qo'shimcha **derived** maydon beradi: `DvirReport.kind ∈
{no_defects, defects_not_fixed, defects_fixed, defects_uncertified}`.

**M102 ✅ [MUST] Mobil 3 turi backenddan quyidagicha hosil bo'ladi** (#B-20 hal qilindi):

| `status` (backend) | `kind` (backend) | Mobil badge | Rang |
|---|---|---|---|
| `draft` (faqat lokal) | — | `Draft` | kulrang |
| `submitted_no_defects` | `no_defects` | **`No defects`** | Success |
| `submitted_defects_found` | `defects_not_fixed` | **`Defects – not fixed`** | Error |
| `repaired` | `defects_uncertified` | **`Defects – fixed`** + kichik `Awaiting certification` | Warning |
| `certified` | `defects_fixed` | **`Defects – fixed`** | Success |
| `closed_no_certification` | `defects_fixed` | **`Defects – fixed`** + `Closed` | kulrang |

**M103 [MUST]** Mobil badge'ni **`kind` maydonidan** oladi va **hech qachon o'zi hisoblamaydi**.
`status` — faqat tafsilot ekranida (`M-35`) qo'shimcha satr sifatida ko'rsatiladi.

**M104 ✅ [MUST] Dizayndagi 3-variant («Defects fixed» + Mechanic Signature) haydovchi oqimidan
OLIB TASHLANADI.** Sabab: `repaired` holatiga o'tish **`POST /dvir-reports/{id}/repair`** orqali
va u **`dvir.repair` permissioniga** ega Service Manager tomonidan bajariladi — haydovchida bu
permission yo'q. Haydovchi mexanik imzosini qo'ya olmaydi (admin «Paste signature» taqiqi bilan
bir xil mantiq, `tz.md` Q26/Q31).
O'rniga haydovchida **`M-36 Previous defects certification`** bo'ladi (quyida).

#### 11.6.2 Yaratish oqimi
```
M-32 Add DVIR  →  M-33 Defect picker  →  M-34 Review + Driver Signature  →  yuborish
```
**M-32 Add DVIR:**
| Maydon | Turi | Manba |
|---|---|---|
| `Type` | **`Pre-trip` / `Post-trip`** toggle 🎨 (`tz.md` §7.1) | majburiy |
| `Unit Number` | avtomatik | `/me` → driver.unit |
| `Trailers` | ko'p tanlovli chip | `GET /trailers` keshi |
| `Truck Defects` | `Add Defects` + `+` | `M-33` |
| `Trailer Defects` | `Add Defects` + `+` | `M-33` |
| `Driver Information` | avtomatik: `Time`, `Location`, `Odometer` | ELD/GPS |
| `Notes` | matn | ixtiyoriy |
Tugmalar `Cancel` / `Next`.

**M-33 Defect picker:** ikki ro'yxat (`Truck defects` / `Trailer defects`), qidiruv maydoni 🎨.
Har nuqsonga: belgilash + **izoh** + **foto (≤5)** (`tz.md` Q27.1).
**M105 ✅** Nuqsonlar ro'yxati **serverdan** (`GET /defect-types` yoki `sync/pull → defect_types[]`),
`category ∈ {truck, trailer}`, `is_critical`, `sort_order` bilan.
Dizayndagi 44 bandli statik ro'yxat **fallback**, va undan:
- **`Engine` dublikati olib tashlanadi** (#B-12) → 43 band;
- **`Refresh` bandi olib tashlanadi** (nuqson emas, #B-12);
- `Accident Photo` — nuqson emas, **alohida foto yuklash bandi** sifatida ajratiladi 🎨.

**M106 [MUST]** `is_critical=true` nuqson tanlansa — ogohlantirish 🎨:
«This is a critical defect. The unit may be placed out of service.» (`tz.md` Q27.2).

**M-34 Review + Signature:** tanlangan nuqsonlar xulosasi + **`Driver Signature`** (chizish yoki
saqlangan imzo). Tugmalar `Cancel` / `Confirm`.
Dizayndagi tanlov matnlari (`Selected defects needs to be fixed` / `Selected defects fixed`)
**olib tashlanadi** — u `repaired` holatini haydovchiga bergani uchun (M104).

**Yuborish:** `POST /dvir-reports` `{unit_id, type, trailer_ids[], defects[], driver_signature_key, notes}`.
Nuqson yo'q bo'lsa → server `submitted_no_defects`; bor bo'lsa → `submitted_defects_found`.

#### 11.6.3 `M-36 Previous defects certification` 🎨 **[MUST]**
`tz.md` §7.2 «✅ `certified`: keyingi pre-trip DVIR'da shu Unit uchun tizim
"Previous defects repaired?" so'raydi → haydovchi imzosi».

```
Pre-trip DVIR boshlanishida:
  GET /dvir-reports/pending-certification
    └─ bo'sh bo'lmasa → modal: "Defects were repaired on unit 1021 on <date>.
                               Confirm the repairs are satisfactory."
       [Nuqsonlar ro'yxati + mexanik izohi + invoice havolasi]
       → Driver signature → POST /dvir-reports/{id}/certify {signature_key}
```
| Holat | UI |
|---|---|
| Oflayn | Modal ko'rsatiladi, sertifikatsiya outbox'ga; yangi DVIR bloklanmaydi |
| `DVIR_INVALID_TRANSITION` | «This report was already certified.» + ro'yxatni yangilash |
| 7 kun ichida DVIR bo'lmasa | Server `closed_no_certification` qiladi (`tz.md` Q30.1) — mobil hech nima qilmaydi |

**M-35 DVIR details:** `Time`, `Location`, `Odometer`, `Type` (pre/post), holat badge (M102),
`Truck defects` va `Trailer defects` ro'yxatlari (izoh + fotolar), `Driver Signature`,
`Mechanic Signature` (agar bor bo'lsa, **faqat ko'rish**), `Invoice` havolasi (agar bor bo'lsa),
`PDF` yuklab olish (`GET /dvir-reports/{id}/pdf`, faqat onlayn).

**M107 [MUST]** Haydovchi **DVIR ni o'chira/tahrirlay olmaydi**. Yuborilgan DVIR — o'zgarmas.
Xato bo'lsa: yangi DVIR + support tiketi.

---

### 11.7 Inspection moduli (yo'l tekshiruvi)

**M-37 Inspection Report** — dizayndagi **uch mustaqil amal**:
| № | Matn | Tugma | Endpoint |
|---|---|---|---|
| 1 | «Review the logs for the past 7 days + today» / «Click "Begin Inspection" button, and hand your device to the officer.» | `Begin Inspection` | `POST /inspection/begin` |
| 2 | «Send the logs for the past 7 days + today via email» / «Email your logs to the officer if they request a paper copy.» | `Send via email` | `POST /inspection/email` |
| 3 | «Send the ELD output file to the **DOT officer**» / «Send your ELD Output file for the inspection if the officer requests.» | `Send the file` | `POST /inspection/transfer` |

**M108 ✅** 3-band matni — **planshet varianti kanonik** («to the DOT officer»).
Mobildagi «to the **Insection** officer» — imlo xatosi (#C-5) va noto'g'ri atama (#B-18).

**M-38 Begin inspection (kiosk rejimi)** **[MUST]**:
- Ekran soddalashadi: **faqat** sana tasmasi (7 kun + bugun) + log grid + eventlar jadvali +
  Log Form shapkasi (Driver, Carrier, Home Terminal, Unit, Trailers, Docs, Distance).
- Navigatsiya **butunlay olib tashlanadi**: app bar, tab bar, drawer, back tugmasi.
- Android: back tugmasi bloklanadi (`PopScope(canPop:false)`) + lock task mode (planshet).
- Chiqish: kichik `Exit` tugmasi → **`M-39` PIN** → `POST /auth/pin/verify` (yoki oflayn hash, M16).
- Sessiya: `POST /inspection/begin` → `InspectionSession {token, expires_at}`; `expires_at` da
  rejim avtomatik yopiladi.
- **Ma'lumot manbai:** onlayn — `GET /inspection/logs?driver_id&date`; oflayn — **lokal Drift**
  (14 kunlik bufer yetarli). Oflayn holatda ekranda kichik izoh: «Offline copy — last synced <vaqt>».

**M109 [MUST]** Inspection rejimida ilova **hech qanday push bildirishnoma ko'rsatmaydi**
(chat, HOS warning — hammasi to'xtatiladi), chunki inspektor qurilmani ushlab turadi.
Rejim tugagach navbatdagilar ko'rsatiladi.

**M110 [MUST]** Inspection rejimida **hech narsa tahrirlanmaydi** — faqat o'qish.

**M-40 Send via email:** `Email Address` (`Enter email address`), ixtiyoriy `Comment`.
`Cancel` / `Send Logs`. `POST /inspection/email {email, date, driver_id, comment}`.

**M-41 Send the file:** `Type` — **`Web service` / `Email`**; `Email Address` (faqat `Email` tanlanganda);
`Comment` (`Write output file comment`). `Cancel` / `Send`.
`POST /inspection/transfer` → `InspectionTransferResult {format, file_key, regulation_profile, size_bytes}`.
`format`: `fmcsa_eld_output` (profil `us_fmcsa`) yoki `csv_pdf_zip` (`generic`) — mobil natijani
ko'rsatadi: «Output file sent (<format>, <size>)».

**M111 [MUST]** Ikkala yuborish amali **onlayn talab qiladi**. Oflayn bo'lsa tugmalar o'chiriladi
va izoh: «Requires an internet connection. Use "Begin Inspection" to show logs on screen.»
`503` kelsa: «The transfer service is unavailable. Show the logs on screen instead.»
---

### 11.8 Profil, sozlamalar, support

**M-44 Profile** — avatar (bosh harflar), ism + unit №, email + telefon, litsenziya № + shtat.
Bandlar: `Settings ›` · `Check network ›` · `Zoom` (toggle) · `Dark mode` (toggle) ·
`Feedback ›` · `Customer support ›` · `User Manual ›` · `My devices ›` 🎨 · `Change PIN ›` 🎨.
**M112 [MUST]** `Maintenance` bandi **yo'q** (M67).

**M-45 Settings** — ikki band: `Diagnosis of device ›` · `App updates ›`.
`App updates`: joriy versiya, `latest_version` (`app/config` dan), `Update` tugmasi (store havolasi).

**M-46 Diagnosis of device** — §10.5 jadvali. `Run diagnostics` tugmasi 🎨.
**M-47 Check network** — §10.5, yarim doira o'lchagich, `mbps`.

**M-48 Give feedback** — «Share your experience to help us improve.»
1) «How would you rate your overall experience with the mobile app?» — 1–5 yulduz.
2) «What new features or improvements would you like to see in the mobile app?» — matn (`Write here..`).
`Submit` → `POST /feedback {app_rating, text}`.
**M113 ✅** Planshetda matn **«…with the app?»** ga o'zgaradi (dizayndagi «mobile app» xatosi tuzatiladi).
Oflayn: outbox'ga, «Will be sent when you're back online».

**M-49 Contact support (forma)** — `Contact On` (`Email address` / `Phone number`),
`Subject` (`Add ticket subject`), `Ticket description` (`Description`), fayl biriktirish (≤3).
`Cancel` / `Confirm` → `POST /support-tickets {subject, description, contact_on, attachments[]}`.
**M114 [MUST]** `attachments` — `POST /files/presign` (`kind=chat`) orqali olingan kalitlar (§16).

**M-50 Support & Helpdesk** — tiketlar ro'yxati: sana-vaqt, holat badge, `#122546`, `Subject`,
tavsif, `Contact On`. Haydovchi holatni **o'zgartira olmaydi**.
**M115 ✅** Holat matnlari kanonik: **`New` · `In Progress` · `Resolved`**
(planshetdagi `In-Progress` defisli variant rad etiladi, #B-7).
Bo'sh holat: `No Ticket Added Yet` + «Start to add your first ticket by clicking button below.» + `Add Ticket`.

**M-51 Support ticket thread** 🎨 — `GET/POST /support-tickets/{id}/messages` (`tz.md` §15 [SHOULD]).

**M-52/53 Privacy Policy / Terms of Use** — bo'lim sarlavhasi + uzun matn.
**M116 ✅ [MUST] Dizayndagi matn TO'LIQ OLIB TASHLANADI** — u boshqa mahsulotga tegishli
(«Jusoor», «ONTime Log», «OnTime ELD», Saudiya biznes platformasi kontenti, #B.3).
❓ **M117** Haqiqiy matn buyurtmachidan olinadi. MVP gacha: ekran `GET /app/config` dagi
havolalar orqali WebView ochadi yoki `assets/legal/{privacy,terms}_en.md` dan placeholder
ko'rsatadi: «Legal text pending. Contact <support_email>.» Store'ga chiqishdan oldin **majburiy** to'ldiriladi.

---

### 11.9 Chat va bildirishnomalar ekranlari

**M-42 Chat** — bitta thread («Dispatch»). Xabar pufakchalari, `sent/delivered/read` belgilari,
sana ajratgichlari, fayl/rasm/lokatsiya. Pastda kiritish qatori + `+` (rasm/fayl/lokatsiya).
**M118 ✅ [MUST] Dizayndagi demo xabarlar OLIB TASHLANADI** («Hi-FI wireframes for flora app design»,
dizayn jarayoni haqidagi matnlar, #B.3). Bo'sh holat: «No messages yet» + «Messages from your
dispatcher will appear here.» 🎨

**M-43 Notifications** — sana bo'yicha guruhlangan (`May 28, 2025`), har birida nisbiy vaqt (`2h ago`).
Bo'sh: `No Notifications Yet` + «Stay tuned! Important updates and alerts will appear here.»
`Mark all as read` (`POST /notifications/read-all`), har biri bosilganda `PATCH /notifications/{id}/read`.
**M119 ✅** Vaqt formati **ikkala klientda bir xil** (M91): <24 soat — nisbiy, keyin absolyut
(planshetdagi faqat-absolyut variant rad etiladi, #B-18/vaqt).

---

### 11.10 Tizim ekranlari 🎨

| Ekran | Mazmun |
|---|---|
| **M-54 Sync status** | Oxirgi push/pull vaqti, navbat (turlar bo'yicha), oxirgi xato kodi, `Retry now`, kursor |
| **M-55 Sync conflicts** | §5.6 jadvali bo'yicha rad etilgan/almashtirilgan elementlar |
| **M-56 Signed out elsewhere** | «Your account was used to sign in on another <device>.» + `Sign in again` |
| **M-57 Force update** | Bloklovchi; `latest_version`, store tugmasi; `Back` yo'q |
| **M-58 Sessions** | `GET /auth/sessions` — qurilma turi, IP, oxirgi faollik, `current` badge; `DELETE /auth/sessions/{id}` |

---

### 11.11 Ekranlar registri — planshet (kabina)

Planshet **bitta asosiy ekran + modallar** modelida ishlaydi (`design-inventory.md` bet 108).
Barcha biznes mantiq telefon bilan **bir xil** (`Controller` umumiy, M7) — faqat `View` boshqa.

| ID | Ko'rinish | Turi | Figma | Telefondagi ekvivalenti |
|---|---|---|---|---|
| T-01 | **Home / Full screen** | ekran | `1470:42666` | M-09 |
| T-02 | Yon menyu (drawer) | panel | `2142:25753` | M-10 |
| T-03 | Edit Documents | modal | `1470:19197` | M-11 |
| T-04 | Change Duty Status | modal | `1470:28679` | M-12 |
| T-05 | Quick Notes | modal | `1470:30704` | M-13 |
| T-06 | Location error | modal | `1470:29713` | M-14 |
| T-07 | Switch co-driver | modal | `1517:51373` | M-20 |
| T-08 | Select Shipping Document | modal | `1517:53372` | M-21 |
| T-09 | Log Detail | modal | `1517:52371` | M-25 |
| T-10 | Log panel (kengaytirilgan grid) | panel | `2142:15234` | M-23 |
| T-11 | Certify (Last 8 days) | modal | `1470:20134` | M-29 |
| T-12 | Sign | modal | `1470:22044` | M-30 |
| T-13 | Not Ready | holat | `1470:22998` | M-31 |
| T-14 | Log Report — Main | ekran | `2142:16317` | M-22 |
| T-15 | Log Report — Logs | ekran | `2142:22733` | M-23 |
| T-16 | Log Report — DVIR | ekran | — | M-24 |
| T-17 | Inspection Report | ekran | `2156:46277` | M-37 |
| T-18 | Send via Email | modal | `2156:47218` | M-40 |
| T-19 | Send file to DOT | modal | `2156:48249` | M-41 |
| T-20 | Begin inspection (kiosk) | ekran | — | M-38 |
| T-21 | Check Network | modal | `2142:26925` | M-47 |
| T-22 | Permissions | modal | `2142:28945` | M-18 |
| T-23 | Diagnosis of Device | modal | `2142:31232` | M-46 |
| T-24 | Feedback | modal | `2142:32880` | M-48 |
| T-25 | Drive-focused | ekran | `2190:90626` | M-15 |
| T-26 | Idle prompt (5 min) | modal | `2195:97628` | M-16 |
| T-27 | Contact Support (jadval) | ekran | `2146:35984` | M-50 |
| T-28 | Add Ticket | modal | `2146:39644` | M-49 |
| T-29 | Notifications | modal/panel | `2150:41614` | M-43 |
| T-30 | Add DVIR (3 qadam) | modal | — | M-32…M-34 |
| T-31 | PIN entry | modal | 🎨 | M-04 |
| T-32 | Pending edits | modal | 🎨 | M-26/27 |
| T-33 | Unidentified claim | modal | 🎨 | M-28 |
| T-34 | Chat | panel | 🎨 | M-42 |
| T-35 | Sync status / conflicts | modal | 🎨 | M-54/55 |

**Jami: 35 ta planshet ko'rinishi** (dizayndagi 52 light ekran — variantlar birlashtirilgandan keyin).

#### T-01 Home / Full screen — uch ustunli layout
```
┌ Tepa panel: [ELD · Connected]        (logotip)        ✉ 🔔 ⟳ ☀/🌙  ☰ ─┐
├──────────────┬────────────────────────────┬──────────────────────────┤
│ HOURS OF     │  DUTY STATUS               │  ACTIONS                 │
│ SERVICE      │  On Duty   10:45:23        │  [FMCSA / Inspection     │
│ ◍ BREAK 08:00│  [Sleeper Berth][Off Duty] │   Report]                │
│ ◍ DRIVE 09:00│                            │  [Co-driver]             │
│ ◍ SHIFT 10:00│  TRIP DETAILS        [✎]   │  [Leave Truck]           │
│ ◍ CYCLE 65:00│  Shipping Doc · Trailer №  │                          │
│              │  · Notes                   │  CERTIFY      Not Signed │
│              │                            │  (qizil ramka)           │
├──────────────┴────────────────────────────┴──────────────────────────┤
│ 24h LOG GRID (OFF/SB/DR/ON)   jami: OFF 11:03 · SB 00:00 · DR 05:30 · ON 00:00 │
│ [Violation: …] (qizil)   [Warning: …] (sariq)                        │
│ Status · Start Time · Location · Document · Trailers · Notes · Action │
└──────────────────────────────────────────────────────────────────────┘
```
**M120 [MUST]** Planshet Home ekrani **scroll qilinmaydi** (1366×1024 da hammasi sig'adi).
Faqat log jadvali ichki scroll'ga ega.

**M121 [MUST]** Planshetdagi `Search Item ...` qidiruvi (dizaynda Duty Status paneli tepasida) —
**olib tashlanadi**: ekranda qidiriladigan narsa yo'q, u eskirgan iteratsiya qoldig'i. 🎨

**M122 [MUST]** Modal sarlavha qatori: `Cancel` · **sarlavha** · `<amal>` (`Save`/`Confirm`/`Send`) —
dizayndagi pattern saqlanadi. Telefonda esa pastda ikki tugma.

**M123 ✅** Certify modalida (T-11) sertifikatlangan kunlar ham checkbox bilan ko'rsatiladi
(planshet varianti), lekin **belgilash o'chirilgan** (qayta sertifikatsiya faqat `needs_recertify` da).
Mobil `M-29` ham shu xatti-harakatga keltiriladi — ikkala klient bir xil.

---

## 12. Log sertifikatsiyasi

**Manba:** `tz.md` §6 (Q19–Q26.1), `POST /daily-logs/{id}/certify`.

### 12.1 Oyna va holatlar
**M124 ✅ [MUST]** Sertifikatsiya oynasi — **8 kun** (`certification_window_days = 8`, `tz.md` Q19).
Dizayndagi **`Certify (Last 11 days)`** ekrani (`1102:931`) **implementatsiya qilinmaydi** (#B-15).
Sarlavha har doim: **`Certify (Last 8 days)`**.

| Kun holati | Badge | Manba |
|---|---|---|
| `certified` | `Certified` (yashil) | `daily_logs.certification_status` |
| `uncertified` | `Uncertified` (kulrang) | — |
| `needs_recertify` | **`Needs re-certify`** (sariq) 🎨 | tahrirdan keyin |
| Tayyor emas | **`Not Ready`** | `DailyLogSummary.ready == false` |

**M125 ✅** `Not Ready` sharti (dizaynda ko'rsatilmagan, #141-4) — **serverning `ready` maydoni**
(`DailyLogSummary.ready`). Mobil bu shartni **o'zi hisoblamaydi**. `tz.md` Q25 bo'yicha
`Not Ready` = kun hali yopilmagan / imzoga tayyor emas. `LOG_NOT_READY` xato kodi ham shundan.

### 12.2 Ekran oqimi
```
M-29 Certify (Last 8 days)
  ├─ Yuqorida: [Certify Today]
  ├─ Kunlar ro'yxati (checkbox + sana + badge)
  └─ Pastdagi tugma tanlovga qarab:
       tanlov yo'q      → [Certify All]
       n kun tanlangan  → [Certify Selected (n)]
       bugungi kun      → [Certify Today]
  → M-30 Sign
```
**M-30 Sign:**
| Element | Qoida |
|---|---|
| `Driver Signature` | Chizish maydoni (`CustomPainter`), tozalash tugmasi |
| `Use my signature` | Saqlangan imzoni qo'llash (agar bor bo'lsa) |
| `Save my signature` | Checkbox — imzo keyingi safar uchun saqlanadi |
| **Huquqiy matn** | «I hereby certify that my data entries and my record of duty status for 24 hour period are true and correct» |
| Tugmalar | `Cancel` / `Confirm` (planshet: `Cancel · <sana> · Save`) |

**M126 [MUST]** Bir nechta kun tanlangan bo'lsa — **bitta imzo** olinadi va har kun uchun
alohida `POST /daily-logs/{id}/certify` yuboriladi (ketma-ket, bitta `signature_key` bilan).
Qisman muvaffaqiyat bo'lsa: muvaffaqiyatlilar `Certified`, qolganlari xato bilan ro'yxatda qoladi.

**M127 [MUST]** So'rov tanasi (`logs_dto.CertifyRequest`): `{signature_key, signature_id?, device_id}`.
`signature_key` — `POST /files/presign` (`kind=signature`) orqali yuklangan PNG kaliti (§16).
Saqlangan imzo ishlatilsa — `signature_id` yuboriladi, qayta yuklash shart emas.

**M128 [MUST] Oflayn sertifikatsiya:** imzo lokal saqlanadi (`files_queue`), sertifikatsiya
outbox'ga (`kind=certify`) tushadi, UI da kun `Certified (pending sync)` holatida ko'rinadi.
Tarmoq qaytganda: avval fayl yuklanadi → keyin `certify` chaqiriladi.
Server rad etsa (`LOG_NOT_READY`, `log_locked`) — kun `Uncertified` ga qaytariladi va `M-55` da sabab ko'rsatiladi.

**M129 [MUST]** **Admin haydovchi nomidan sertifikatlamaydi** (`tz.md` Q26). Mobil UI da
«certified by admin» kabi holat **umuman yo'q**.

**M130 [SHOULD]** 8 kundan eskirgan sertifikatlanmagan kun ro'yxatda ko'rinmaydi, lekin
`Log Report` dan istalgan kunni ochib imzolash mumkin (`tz.md` Q19.1) — kun ekranida
`Certify this day` tugmasi.

### 12.3 Qayta sertifikatsiya
**M131 [MUST]** Kun tahrirlangandan keyin `certification_status = needs_recertify` bo'ladi
(`tz.md` Q18). Mobil:
- Home'da va Logs tabida sariq badge;
- Push bildirishnoma (server `uncertified_log`/`log_edit_resolved` orqali);
- Certify ro'yxatida kun **`Needs re-certify`** bilan yuqorida turadi.

---

## 13. Log tahrirlash — taklif/tasdiq modeli

**Manba:** `tz.md` §5.3 (Q17–Q18), `swagger.json` `/log-edit-requests*`.

### 13.1 Oqim
```
Admin "Insert/Edit duty status" → POST /log-edit-requests (pending)
   → push: log_edit_request  →  mobil: Home'da sariq karta "Pending edits (n)"
   → M-26 ro'yxat → M-27 tafsilot
        ├─ [Approve] → POST /log-edit-requests/{id}/approve
        │      → yangi eventlar origin=admin_edit, asl eventlar superseded_by bilan qoladi
        │      → kun certification_status = needs_recertify
        └─ [Reject]  → POST /log-edit-requests/{id}/reject {reason}   ← SABAB MAJBURIY
```
**M132 [MUST]** Haydovchi tasdiqlamaguncha log **o'zgarmaydi**. Admin hech qachon logni
bevosita o'zgartirmaydi.

### 13.2 `M-26 Pending edits` (ro'yxat) 🎨
Har satr: `Log date`, `Requested by`, `Created at`, o'zgarishlar soni, `source` badge
(`Admin edit` / `Unidentified assign`). Bo'sh holat: «No pending edits» 🎨.
Ma'lumot: `GET /log-edit-requests?status=pending` + `sync/pull → log_edit_requests[]`.

### 13.3 `M-27 Pending edit detail` (Approve/Reject) 🎨
| Blok | Mazmun |
|---|---|
| Sarlavha | `Proposed change to your log for <date>` |
| Har o'zgarish (`LogEditChange`) | `From` – `To`, yangi `Status` (+`special`), **`Note`** (admin sababi) |
| **Asl qiymat** | Yonma-yon ko'rsatiladi: `Current: DR 13:00–15:00` → `Proposed: ON 13:00–15:00` |
| Vizual | Mini-grid: joriy va taklif qilingan holat ustma-ust (🎨) |
| Amallar | `Approve` (tasdiq modali bilan) · `Reject` (**sabab matni majburiy**, ≤200 belgi) |

**M133 [MUST] `DR` bloklangan:** agar taklifda avtomatik yozilgan `DR` vaqti qisqartirilsa yoki
`DR` boshqa statusga o'zgartirilsa — mobil `Approve` tugmasini **o'chiradi** va izoh ko'rsatadi:
«Automatically recorded driving time cannot be changed. Contact your fleet manager.»
Backend ham buni `DR_IMMUTABLE` bilan rad etadi (`tz.md` Q17.1) — mobil faqat oldindan bloklaydi.
Ruxsat etilgan istisno: `DR → PC` yoki `DR → YM` (haydovchi tomonidan, sabab bilan).

**M134 [MUST]** `intermediate`, `power_on/off`, `malfunction`, `diagnostic` eventlari
tahrirlanmaydi — bunday taklif kelsa ham `Approve` bloklanadi (`EVENT_IMMUTABLE`).

**M135 [MUST] Oflayn:** Approve/Reject outbox'ga tushadi (`kind=log_edit`), UI darhol yangilanadi,
so'rov `Pending sync` holatida ko'rinadi. Server `409` (allaqachon hal qilingan) qaytarsa —
lokal holat server bilan tenglashtiriladi va foydalanuvchiga xabar beriladi.

### 13.4 Haydovchining o'z tahriri
**M136 [MUST]** Haydovchi o'z logini o'zi tahrirlashi mumkin (`tz.md` Q17):
`POST /daily-logs/{id}/events` `{from, to, status, special, note, unit_id}` — **`note` majburiy**.
Bu **darhol** qo'llanadi (`origin=driver_edit`), asl event `superseded_by` bilan saqlanadi.
UI: `M-23 Logs` tabida `Action` ustunidagi `✎` → `M-27` ga o'xshash forma (`Insert / Edit duty status` 🎨).
Cheklovlar bir xil: `DR` o'zgartirilmaydi, `locked=true` kun — faqat edit-request orqali (`log_locked`).

**M137 [MUST]** Tahrirlangan event logda **`✎`** belgisi bilan; bosilganda asl qiymat, kim va
qachon o'zgartirgani ko'rsatiladi (`tz.md` Q17.2). `LogEvent.edited` va `origin` maydonlaridan.

---

## 14. Chat

**Manba:** `tz.md` §15.4, `swagger.json` `/chat/*`, `websocket.md` `chat` kanali.

| Jihat | Qoida |
|---|---|
| Kanal | **1:1** — haydovchi ↔ ofis («Dispatch»). Guruh chat yo'q |
| Xabar turlari | `text` (≤2000), `image`, `file` (≤10 MB), `location` |
| Holatlar | `sent` → `delivered` → `read` (`chat_dto.Message.status`) |
| Yuborish | `POST /chat/threads/{driver_id}/messages` (`driver_id` = o'zi) |
| O'qish | `GET /chat/threads/{driver_id}/messages?before&limit` (kursor) |
| O'qildi belgisi | `POST /chat/messages/{id}/read` |
| Transport | Telefon: **REST + push**. Planshet: `[MAY]` WS `chat` kanali |
| Saqlash | Serverda 1 yil; lokal oxirgi 500 xabar / 30 kun |

### 14.1 Oflayn navbat **[MUST]**
**M138** Yuborilgan xabar darhol `chat_outbox` ga (`client_id` UUID bilan) va UI da
**`Queued`** (soat ikonkasi) holatida ko'rinadi. Sync push'da `chat[]` massivida `client_id`
yuboriladi; `accepted` bo'lgach `sent` ga o'tadi. `rejected` bo'lsa qizil `!` + `Retry`.

**M139 [MUST]** Fayl/rasm xabari: avval fayl `files_queue` orqali yuklanadi (`kind=chat`),
`file_key` olingandan keyingina xabar yuboriladi. Yuklanish davomida progress ko'rsatiladi.

### 14.2 Haydash rejimida bloklash **[MUST]**
**M140** `DR` statusida chat **yozish bloklanadi** (`tz.md` §15.4, driver distraction).
| Holat | UI |
|---|---|
| Chat tabi | Ochiladi, tarix **o'qish mumkin** (yoki M141 bo'yicha bloklanadi) |
| Kiritish qatori | O'chirilgan + izoh: **«Messaging is disabled while driving.»** |
| Push kelganda | Bildirishnoma **ko'rsatiladi**, lekin ochilganda kiritish bloklangan |
| Ovozli o'qish | `[MAY]` — 2-bosqich |

**M141 [MUST] Server `409 DRIVING_MODE_BLOCKED` ni qanday ko'rsatish:**
Agar mijoz tomonidagi blok chetlab o'tilsa (masalan status server tomonda `DR` bo'lib,
mobilda hali yangilanmagan bo'lsa) va server `409 DRIVING_MODE_BLOCKED` qaytarsa:
1. Xabar `chat_outbox` da **saqlanadi** (yo'qotilmaydi) va `blocked` holatiga o'tadi;
2. UI: xabar pufakchasi kulrang, ostida qizil matn **«Not sent — messaging is blocked while driving»**
   va **`Send when stopped`** tugmasi (default: yoqilgan);
3. Mobil status `DR` dan chiqqanda (`OFF`/`ON`/`SB`) **avtomatik** qayta yuboriladi;
4. Lokal duty status darhol `DR` ga tenglashtiriladi (server haqiqat) — kiritish qatori bloklanadi.

**M142 [MUST]** Haydash rejimi ekranida (`M-15`) chat ikonkasi **umuman ko'rsatilmaydi**.

### 14.3 Lokatsiya ulashish
`kind=location` + `lat`/`lng`. Joriy GPS nuqtasi, tasdiq bilan. Xaritada emas — matn + koordinata
+ «Open in maps» havolasi (tashqi ilova).

---

## 15. Bildirishnomalar (push)

### 15.1 Ro'yxatga olish **[MUST]**
```
Login muvaffaqiyatli → FCM/APNs token olinadi
   → POST /devices/push-token {token, platform, device_id, app_version}
   → token yangilanganda (onTokenRefresh) qayta yuboriladi
   → logout(pause=false) da token serverdan o'chirilmaydi (v1 da DELETE yo'q) —
     mobil FCM tokenni lokal o'chiradi va `deleteToken()` chaqiradi
```
`platform ∈ {android, ios}`. Oflayn bo'lsa — outbox (`kind=push_token`).

### 15.2 Alert turlari (`swagger.json` enum) va haydovchiga taalluqlisi
| `alert_type` | Haydovchiga | Deep link |
|---|---|---|
| `hos_warning` / `hos_violation` | ✅ | `/logs?date=<d>` |
| `route_assigned` / `route_completed` | ✅ | `/notifications` (marshrut ekrani yo'q) |
| `dvir_defects` / `dvir_critical` | ❌ (Service/Fleet Manager) | — |
| `log_edit_request` | ✅ | `/logs/pending-edits/<id>` |
| `log_edit_resolved` | ❌ (admin) | — |
| `uncertified_log` | ✅ | `/certify` |
| `unidentified_driving` | ❌ (admin) | — |
| `eld_disconnected` / `eld_malfunction` | ✅ | `/eld` |
| `maintenance_upcoming` / `maintenance_overdue` | ✅ (**faqat xabar**, M67) | `/notifications` |
| `chat_message` | ✅ | `/chat` |
| `subscription_expiring` | ❌ (Administrator) | — |

**M143 [MUST] O'chirib bo'lmaydigan bildirishnomalar** (`tz.md` Q89): `hos_*` va `eld_*`
turlarini foydalanuvchi ilova ichidan **o'chira olmaydi**. Sozlamalarda ular ko'rsatiladi,
lekin toggle o'chirilgan holatda + tooltip: «Required for compliance».
Tizim darajasida (OS) o'chirilsa — ilova buni aniqlaydi va Home'da banner ko'rsatadi:
«Notifications are disabled. HOS and ELD alerts require notifications.» + `Enable`.

**M144 [MUST]** Push kanallari (Android `NotificationChannel`):
| Kanal | Muhimlik | Turlari |
|---|---|---|
| `compliance` | HIGH (ovoz + tebranish, o'chirib bo'lmaydi) | `hos_*`, `eld_*`, idle prompt |
| `logs` | DEFAULT | `log_edit_request`, `uncertified_log` |
| `messages` | DEFAULT | `chat_message` |
| `general` | LOW | `route_*`, `maintenance_*` |
| `foreground_service` | MIN (doimiy) | fon xizmati bildirishnomasi |

**M145 [MUST]** Deep link `onebookeld://<path>` va `data` payload'idagi `entity_type`/`entity_id`
orqali. Ilova yopiq bo'lsa — bootstrap tugagandan keyin navigatsiya bajariladi
(`go_router` `initialLocation` orqali, autentifikatsiya guard'idan keyin).

**M146 [MUST]** Lokal (server bo'lmagan) bildirishnomalar: HOS warning chegaralari (M50),
idle prompt (M62), sync konflikt, ELD uzilishi (30 s dan keyin), malfunction.

---

## 16. Fayllar

**Oqim [MUST]:**
```
1. POST /files/presign {kind, content_type, size_bytes, filename}
      → {upload_url, method, key, headers, expires_at, max_bytes}
2. PUT <upload_url> (headers bilan) — to'g'ridan-to'g'ri object storage'ga
3. Domen so'roviga faqat `key` yuboriladi (dvir photo, signature_key, attachments, file_key)
```

| `kind` | Ishlatilishi | Cheklov |
|---|---|---|
| `dvir_photo` | DVIR nuqson fotolari | **≤5 ta foto**, har biri **≤5 MB** (`tz.md` Q27.1) |
| `signature` | Sertifikatsiya va DVIR imzosi | PNG, ≤1 MB |
| `chat` | Chat va support biriktirmalari | ≤10 MB (chat), support ≤3 fayl |
| `invoice` | Mobilda **ishlatilmaydi** (M67) | — |

**M147 [MUST]** Foto siqish: uzun tomoni **≤1600 px**, JPEG sifat **80** → odatda ≤1 MB.
Siqish `Isolate` da. EXIF: GPS **olib tashlanadi** (PII), yo'nalish saqlanadi.

**M148 [MUST]** Server `max_bytes` va `413 FILE_TOO_LARGE` — kanonik. Mijoz oldindan tekshiradi,
lekin server javobiga bo'ysunadi.

**M149 [MUST] Oflayn navbat:** fayl lokal papkaga saqlanadi (`app_support/pending_files/`),
`files_queue` ga yozuv. Tarmoq qaytganda: presign → PUT → `key` domen so'roviga qo'yiladi.
`expires_at` o'tib ketgan bo'lsa — **qayta presign** qilinadi.
Fayl yuklanmaguncha bog'liq domen so'rovi (DVIR, certify, chat) **yuborilmaydi** — navbat tartibi
`files_queue` → `outbox_items` bog'liqligi bilan ta'minlanadi.

**M150 [MUST]** Imzo — vektor nuqtalaridan **PNG** ga render qilinadi (shaffof fon, 600×200 px,
qora chiziq). Saqlangan imzo `flutter_secure_storage` da emas, oddiy fayl sifatida saqlanadi,
lekin `signature_id` server tomonda (`signatures` jadvali, shifrlangan).

**M151 [MUST]** Fayl yuklanishi haydash rejimida **kechiktiriladi** (batareya + tarmoq),
faqat to'xtaganda yoki Wi-Fi da yuklanadi. Istisno: hech qanday fayl haydash paytida yaratilmaydi.
---

## 17. Xavfsizlik

**Manba:** `tz.md` B§ xavfsizlik, `.claude/skills/eld-security`, OWASP MASVS.

### 17.1 Token saqlash **[MUST]**
| Ma'lumot | Qayerda |
|---|---|
| `access_token` | Faqat **xotirada** (diskka yozilmaydi) |
| `refresh_token` | `flutter_secure_storage` — iOS Keychain (`first_unlock_this_device`), Android EncryptedSharedPreferences (Keystore, `StrongBox` bo'lsa) |
| `device_id` | Secure storage (barqaror) |
| PIN hash + salt | Secure storage |
| Drift DB | **SQLCipher** bilan shifrlanadi `[SHOULD]`; kalit Keystore/Keychain'da (`sqlcipher_flutter_libs`) |
| Imzo fayllari, DVIR fotolari | Ilova sandbox'i (`getApplicationSupportDirectory`), tashqi xotiraga **hech qachon** yozilmaydi |

**M152 [MUST]** Token **hech qachon** URL'da, log'da, analytics'da, crash reportda ko'rinmaydi.
Dio interceptor `Authorization` sarlavhasini log'da `***` bilan almashtiradi.

### 17.2 Transport
- **HTTPS only**, TLS ≥1.2. Cleartext taqiqlanadi (`android:usesCleartextTraffic="false"`,
  iOS ATS istisnosiz).
- **M153 [MAY] Sertifikat pinning:** `eldapi.stackyard.uz` uchun SPKI pin (asosiy + zaxira).
  Ikkita pin majburiy (rotatsiya uchun). Pin muvaffaqiyatsiz → so'rov bloklanadi va
  `M-55` da xato: «Secure connection could not be verified.»
  **Muddat:** 11-bosqichda (store review'dan oldin), chunki noto'g'ri pin ilovani o'ldiradi.
- **M154 [MUST]** WS (planshet) — faqat `wss://`, token **URL'da emas**, handshake header yoki
  birinchi `auth` freymida (`websocket.md` §1).

### 17.3 PIN xavfsizligi
**M155 [MUST]** PIN lokal `Argon2id` (yoki `PBKDF2-HMAC-SHA256`, ≥100 000 iteratsiya) bilan
hashlanadi, **qurilmaga xos 32-baytli tasodifiy salt** bilan. PIN ochiq matnda hech qayerda saqlanmaydi.
Solishtirish **doimiy vaqtda** (`constant-time compare`).
**M156 [MUST]** Server javobi ustun: `PIN_LOCKED` kelsa lokal urinishlar ham bloklanadi.

### 17.4 Ekran himoyasi
**M157 [MAY→SHOULD]** `FLAG_SECURE` (Android) / `isSecureTextEntry` overlay (iOS) quyidagi
ekranlarda yoqiladi: `M-04 PIN`, `M-05 Invite`, `M-08 2FA`, `M-30 Sign`, `M-38 Begin inspection`.
Sabab: PIN va imzo — huquqiy ahamiyatga ega. Boshqa ekranlarda o'chiriladi (support screenshot uchun).

**M158 [SHOULD]** Ilova fon rejimiga o'tganda (`AppLifecycleState.inactive`) app-switcher
ko'rinishi **xiralashtiriladi** (blur overlay) — PII ko'rinmasligi uchun.

### 17.5 PII maskalash va telemetriya
**M159 [MUST]** Log fayllari va Sentry'ga **hech qachon** yozilmaydi: token, parol, PIN,
to'liq email/telefon, aniq lat/lng, imzo tasviri, chat matni.
Maskalash: `j***e@example.com`, `+92 *** ** 88`, koordinata `31.5, 74.3` (1 kasr).
**M160 [MUST]** Crash reporting (Sentry) `beforeSend` filtri bilan; foydalanuvchi ID sifatida
faqat `user_id` (UUID), ism/email **yuborilmaydi**.

### 17.6 Root/jailbreak va boshqalar
- **M161 [MAY]** Root/jailbreak aniqlash — **bloklamaydi**, faqat serverga `X-Device-Integrity`
  sarlavhasi bilan xabar beradi (audit uchun).
- **M162 [MUST]** Deep link'lar tekshiriladi: faqat `onebookeld://` sxemasi va
  `eld.stackyard.uz` hosti; boshqa host'lardan kelgan link **ochilmaydi**.
- **M163 [MUST]** Debug rejimi, dev menyu, mock transport — **prod build'da kompilyatsiyaga kirmaydi**
  (`kReleaseMode` + `--dart-define` guard).
- **M164 [MUST]** `company_id` mobil tomondan **hech qachon** so'rov tanasiga qo'yilmaydi —
  u tokendan olinadi (backend qoidasi bilan bir xil). Login'dagi `company_id` — faqat
  ko'p-kompaniyali super-admin uchun, haydovchi ilovasida **ishlatilmaydi**.

### 17.7 Ruxsatlar (permissions) va UI
**M165 [MUST]** UI element `Profile.permissions[]` massiviga qarab ko'rsatiladi/yashiriladi.
Lekin bu **xavfsizlik chegarasi emas** — haqiqiy tekshiruv serverda. Mobil faqat
foydalanuvchini keraksiz xatodan saqlaydi.
Haydovchi uchun kutilgan permission to'plami: `logs.read`, `logs.certify`, `logs.add_event`,
`logs.approve_edit`, `logs.reject_edit`, `logs.claim_unidentified`, `dvir.create`, `dvir.read`,
`dvir.certify`, `inspection.*`, `chat.read`, `chat.send`, `notifications.read`, `files.upload`,
`support.create`, `support.read`, `feedback.create`, `trailers.read`, `defect_types.read`.

---

## 18. Platforma cheklovlari va risklar

**Manba:** `tz.md` B§22.

### 18.1 Android
| Talab | Tafsilot | Risk |
|---|---|---|
| Foreground service | `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `FOREGROUND_SERVICE_CONNECTED_DEVICE`; `foregroundServiceType="location|connectedDevice"` | Android 14+ da tur deklaratsiyasi majburiy |
| Doze / battery optimization | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` so'raladi (onboarding'da tushuntirish bilan) | Foydalanuvchi rad etsa BLE uzilishi mumkin |
| **Background location** | `ACCESS_BACKGROUND_LOCATION` | **Google Play review: 1–3 hafta.** Video demo + yozma asos majburiy. ELD — qabul qilinadigan holat, lekin ariza matni ehtiyotkorlik bilan tayyorlanadi |
| Bluetooth | `BLUETOOTH_SCAN` (`neverForLocation` **qo'yilmaydi** — biz location ishlatamiz), `BLUETOOTH_CONNECT` | Android 12+ |
| Exact alarm | Idle prompt uchun `SCHEDULE_EXACT_ALARM` `[SHOULD]` | Android 13+ da cheklangan |
| OEM cheklovlari | Xiaomi/Huawei/Oppo autostart | Onboarding'da qo'llanma 🎨 |
| Min SDK | **API 29 (Android 10)** | `tz.md` NFR |

**M166 [MUST]** Play Console uchun tayyorlanadigan materiallar 11-bosqichda:
background location demo videosi, Data safety formasi, Privacy Policy URL,
`ELD compliance` tushuntirishi. **Buferi: 3 hafta.**

### 18.2 iOS
| Talab | Tafsilot |
|---|---|
| Background modes | `bluetooth-central`, `location` (`Info.plist` → `UIBackgroundModes`) |
| BLE state restoration | `CBCentralManagerOptionRestoreIdentifierKey` — ilova o'ldirilsa tizim BLE hodisasida uyg'otadi |
| Location | `NSLocationAlwaysAndWhenInUseUsageDescription` + `NSLocationWhenInUseUsageDescription` — matn ELD sababini aniq aytadi |
| Bluetooth | `NSBluetoothAlwaysUsageDescription` |
| Kamera / foto | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` (DVIR fotolari) |
| App Review | «Why always location» matni: HOS yozuvlari uzluksiz bo'lishi shart (federal talab) |
| Min OS | **iOS 15+** |

**M167 [MUST]** iOS'da fon rejimida ishlash `Significant Location Change` + BLE restoration
kombinatsiyasi bilan; `background fetch` ga tayanilmaydi (kafolatsiz).

**M168 [SHOULD]** App Review uchun demo hisob + test ELD (mock) rejimi tayyorlanadi
(`--dart-define=REVIEW_MODE=true` bilan emas — **alohida TestFlight build**, prodda mock yo'q).

### 18.3 Planshet kiosk
**M169 [SHOULD]** Android lock task mode: eng ishonchli variant — qurilma **device owner**
sifatida provisioning qilinadi (MDM yoki `dpm set-device-owner`). Bu bo'lmasa —
`startLockTask()` screen pinning rejimida ishlaydi (foydalanuvchi tasdig'i bilan).
**M170** iOS'da dasturiy kiosk **yo'q** — Guided Access qo'lda yoqiladi (onboarding qo'llanmasi 🎨).

### 18.4 Vendor SDK
**M171** ELD vendor SDK Flutter'da bo'lmasa — platform channel (§10.7).
**Baholash: 1–2 hafta**, 6-bosqich boshida. Agar SDK yopiq/cheklangan bo'lsa — CR va
timeline qayta ko'riladi.

### 18.5 Risk registri
| № | Risk | Ehtimol | Ta'sir | Yumshatish |
|---|---|---|---|---|
| R1 | Play background location review rad etadi | O'rta | Yuqori | Erta ariza (5-bosqichda), video + huquqiy asos, zaxira: faqat foreground rejim |
| R2 | ELD modeli tanlanmagan (M80) | Yuqori | Yuqori | Mock transport + `EldTransport` abstraksiyasi; ekranlar SDK'siz to'liq ishlaydi |
| R3 | Vendor SDK Flutter'da yo'q | O'rta | O'rta | Platform channel, 2 hafta bufer |
| R4 | HOS Dart porti Go bilan farq qiladi | O'rta | **Kritik** | 35 golden vektor CI'da; farq bo'lsa bosqich yopilmaydi |
| R5 | iOS BLE fon rejimida uzilish | O'rta | Yuqori | State restoration + ELD lokal buferi (M72) |
| R6 | Batareya >25% (NFR) | O'rta | O'rta | Telemetriya batchlash, GPS chastotasini adaptiv qilish, profiling 11-bosqichda |
| R7 | Huquqiy matn (Privacy/Terms) yo'q | Yuqori | O'rta | Store'ga chiqishdan oldin buyurtmachidan olish (M117) — bloklovchi |
| R8 | Planshet kiosk device-owner talab qiladi | O'rta | Past | MDM tavsiyasi, screen pinning fallback |
| R9 | `v1` muzlatilgan, kerakli endpoint yo'q (M76) | Past | Past | CR jarayoni; MVP'da taxminiy yechim |

---

## 19. Nofunksional talablar (NFR)

**Manba:** `tz.md` B§21.

| Ko'rsatkich | Talab | Qanday o'lchanadi |
|---|---|---|
| Ilova ishga tushishi (cold start → Home) | **≤3 s** | Firebase Performance / `TimelineTask`, o'rta darajali qurilmada (Pixel 4a / iPhone 11) |
| Haydash rejimiga o'tish | **≤1 s** harakat aniqlangandan | Integration test + real qurilmada o'lchov |
| Batareya (BLE + GPS, 8 soat, ekran o'chiq) | **≤25%** | Battery Historian (Android), Xcode Energy Log (iOS) |
| 14 kunlik oflayn bufer yuklash | **≤60 s** (4G) | Sun'iy bufer bilan integration test |
| **Ma'lumot yo'qotish** | **0 event** | Chaos test: 1000 event + tasodifiy tarmoq uzilishi/ilova o'ldirilishi |
| Status o'zgartirish → UI javobi | ≤200 ms (lokal yozuv) | — |
| HOS qayta hisoblash (14 kun eventlari) | ≤50 ms | Benchmark testi |
| Ro'yxat scroll | 60 fps, jank <1% | `flutter run --profile` + DevTools |
| Ilova hajmi | ≤60 MB (Android AAB), ≤80 MB (IPA) | CI o'lchovi |
| Lokal DB | ≤100 MB (14 kun) | §5.2 |
| Mobil OS | **Android 10+ (API 29)**, **iOS 15+** | — |
| Ekran o'lchamlari | Telefon 360–430 dp kenglik; planshet 600+ dp | Golden testlar |
| Tarmoqsiz ishlash | To'liq funksional (login'dan tashqari) | Integration test |
| Kirish imkoniyati | Kontrast ≥4.5:1, teginish ≥48 dp, TalkBack/VoiceOver asosiy oqimlarda `[SHOULD]` | `flutter_test` semantics |

**M172 [MUST]** NFR ko'rsatkichlari **11-bosqichda o'lchanadi va hisobotga yoziladi**.
O'lchanmagan NFR — bajarilmagan hisoblanadi.

---

## 20. Sifat va testlash

### 20.1 Test piramidasi
| Daraja | Qamrov | Vosita |
|---|---|---|
| **Unit — HOS** | **35/35 golden vektor [MUST]** | `packages/hos_engine/test/golden_vectors_test.dart` |
| **Unit — sync** | Batch bo'lish, idempotency, 5 konflikt qoidasi, backoff, kursor | `packages/sync_core/test/` |
| **Unit — domen** | TimeSource, PIN hash, fayl navbati, DVIR holat mapping (M102), duty validatsiya | `test/` |
| **DB** | Drift migratsiyalari (har versiya), CRUD, outbox tranzaksiya atomikligi | in-memory SQLite |
| **Widget** | Har bir ekran: yuklanish/bo'sh/xato/to'la holat | `flutter_test` |
| **Golden** | Har asosiy ekran × **{light, dark}** × **{phone, tablet}** | `golden_toolkit` |
| **Integration** | To'liq oqimlar (20.3) | `integration_test` + `patrol` `[MAY]` |
| **Chaos** | Tarmoq uzilishi, ilova o'ldirilishi, soat o'zgarishi | Maxsus test harness |

### 20.2 HOS golden vektorlar — **eng qattiq talab**
**M173 [MUST]** `packages/hos_engine/test/golden_vectors_test.dart`
`backend/internal/hos/testdata/hos-test-vectors.json` faylini o'qiydi va **har 35 vektor uchun**
`counters`, `totals`, `violations` ni solishtiradi. **Bitta ham xato — bosqich yopilmaydi.**

**M174 [MUST]** Fayl **nusxalanmaydi**: CI da backend repodan olinadi (`curl`/submodule) va
SHA-256 hash tekshiriladi. Hash o'zgargan bo'lsa build **ogohlantirish bilan to'xtaydi** —
kontrakt o'zgarishi CR talab qiladi.

**M175 [MUST]** CI job `hos-parity`: Go testi (`go test ./internal/hos`) va Dart testi
(`dart test packages/hos_engine`) **ikkalasi ham** o'sha faylda yashil bo'lishi shart.

### 20.3 Integration testlar (majburiy stsenariylar)
| № | Stsenariy |
|---|---|
| IT-1 | `login → ELD ulanish (mock) → auto-DR → to'xtash → idle prompt → ON → certify` |
| IT-2 | `oflayn: 200 event yaratish → onlayn → push → hamma accepted → 0 yo'qotish` |
| IT-3 | `konflikt: bir vaqtda ikki event → superseded → M-55 da ko'rinadi` |
| IT-4 | `log_locked: sertifikatlangan kunga event → rejected → UI xabari` |
| IT-5 | `pending edit → Approve → kun needs_recertify → qayta certify` |
| IT-6 | `pending edit DR ni o'zgartiradi → Approve bloklangan (M133)` |
| IT-7 | `DVIR: defects bilan → submitted_defects_found → keyingi pre-trip da certification modali` |
| IT-8 | `inspection: Begin → kiosk → PIN bilan chiqish` |
| IT-9 | `co-driver: ikki login → switch (PIN) → DR faqat active driverga` |
| IT-10 | `Leave Truck → paused → Return to truck (PIN) → sessiya tiklandi` |
| IT-11 | `chat: haydash rejimida bloklanish + 409 DRIVING_MODE_BLOCKED → qayta yuborish` |
| IT-12 | `unidentified: claim → logga qo'shildi` |
| IT-13 | `soat siljishi: +15 daq → T malfunction banneri` |
| IT-14 | `force update: min_supported_version > joriy → bloklovchi ekran` |
| IT-15 | `sessiya almashishi: boshqa telefonda login → M-56` |

### 20.4 Golden (vizual) testlar
**M176 [MUST]** Har asosiy ekran uchun **4 ta golden**: `{light, dark} × {phone 393×852, tablet 1366×1024}`.
Minimal ro'yxat: Login, Home, Change duty status, Drive mode, Log Report (3 tab), Certify, Sign,
Add DVIR, DVIR details, Inspection, Chat, Notifications, Profile, Permissions, Pending edits, Sync conflicts.
Shrift — repoga qo'shilgan (`loadAppFonts`), tizim shriftiga tayanilmaydi.

### 20.5 CI (GitHub Actions)
```yaml
jobs:
  analyze:   flutter analyze --fatal-infos  +  dart format --set-exit-if-changed
  api-gen:   openapi-generator → git diff --exit-code   # generatsiya eskirgan bo'lsa yiqiladi
  l10n:      ARB kalitlari to'liqligi + kodda hard-coded matn yo'qligi
  test:      flutter test --coverage        # coverage ≥70% umumiy, hos_engine ≥95%, sync_core ≥90%
  hos-parity: go test ./internal/hos  +  dart test packages/hos_engine   # 35/35
  golden:    flutter test --tags golden
  build:     flutter build apk --release  +  flutter build ios --no-codesign
  integration: (nightly) flutter test integration_test/ Firebase Test Lab
```
**M177 [MUST]** `main` branch'ga merge faqat barcha job'lar yashil bo'lganda.

### 20.6 Kuzatuv (production)
**M178 [SHOULD]** Sentry (crash + performance), maxsus hodisalar:
`sync_conflict`, `hos_drift` (M47), `eld_disconnect`, `push_rejected`, `clock_skew_high`,
`battery_drain_high`. Hammasi PII'siz (§17.5).

---

## 21. Nomuvofiqliklar reestri va ochiq savollar

### 21.1 Nomlash nomuvofiqliklari — **31 ta, hammasi hal qilingan**

**Qaror qoidasi:** ①`tz.md` §1.3 kanonik nomlar → ②backend (`swagger.json`) nomlari →
③mobil dizayn varianti → ④planshet dizayn varianti.

| № | Nomuvofiqlik (dizaynda) | **QAROR (kanonik)** | Mobilga taalluqli | Qaror № |
|---|---|---|---|---|
| B-1 | `Fleet Operations` vs `Fleet Management` | `Fleet Management` | ❌ admin | — |
| B-2 | `Reports` vs `Report` | `Reports` | ❌ admin | — |
| B-3 | `Support & History` vs `Histories` | `Support & History` (menyu), `Histories` (ekran) | ❌ admin | — |
| B-4 | `Inspection Report` vs `DOT Report` | **`Inspection Report`** | ✅ | M108 |
| B-5 | `Unit Diagnostics` vs `Unit Inspection` | `Unit Diagnostics` | ❌ admin | — |
| B-6 | `Leave the Truck` vs `Leave Truck` | **`Leave Truck`** | ✅ | M93 |
| B-7 | `In Progress` vs `In-Progress` | **`In Progress`** (probel bilan) | ✅ | M115 |
| B-8 | `Yes, Driving` vs `Yes, driving` | **`Yes, driving`** | ✅ | M61 |
| B-9 | `OFF 03:06` vs `Off - 00:00` | **`OFF 03:06`** (qisqartma + `HH:mm`) | ✅ | M98 |
| B-10 | `na` vs `N/A` | **`N/A`** | ✅ | M92 |
| B-11 | `Tues`/`Thurs` vs `Fri`/`Mon` | **3 harfli** (`Tue`, `Thu`) | ✅ | M92 |
| B-12 | Truck defects: `Engine` dublikati, `Refresh` nuqson emas | Serverdan `defect_types`; dublikat va `Refresh` **olib tashlanadi** (43 band) | ✅ | M105 |
| B-13 | Bosh ekran status tugmalari: 3 ta (A) vs 2 ta (B) | **3 ta** (`Off Duty · Sleeper Berth · On Duty`) | ✅ | M52 |
| B-14 | Quick notes: 10 bandli vs 8 bandli to'plam | **10 bandli variant A**, serverdan (`quick_notes[]`) | ✅ | M54, M55 |
| B-15 | `Certify (Last 8 days)` vs `(Last 11 days)` | **8 kun** | ✅ | M124 |
| B-16 | Log jadvali oxirgi ustuni: `Edit` (planshet) vs `Action` (mobil) | **`Action`** | ✅ | M99 |
| B-17 | Sana tasmasi: `Fri 07` (mobil) vs `07 Jan` (planshet) | **`Fri 07`** ikkala klientda | ✅ | M96 |
| B-18 | Bildirishnoma vaqti: nisbiy (mobil) vs absolyut (planshet) | **<24h nisbiy, keyin absolyut** — ikkala klientda | ✅ | M91, M119 |
| B-19 | ELD output matni: «to the DOT officer» vs «to the Insection officer» | **«to the DOT officer»** | ✅ | M108 |
| B-20 | Sana/vaqt formati — 6 xil variant | **§11.0.7 jadvali** (7 ta kontekst formati) | ✅ | M91 |
| B-21 | **DVIR: mobil 3 tur vs admin 7 holat** | **Backend holat mashinasi haqiqat**; mobil badge `kind` dan (§11.6.1 jadvali) | ✅ | **M102–M104** |
| B-22 | `Dropoff`/`Checkout` vs `Drop off`/`Check out` | **`Drop off`, `Check out`, `Check in`** (ikki so'z) | ✅ | M54 |
| B-23 | `Notify co-driver` vs `Notify Co-driver` | `Notify co-driver` | ❌ admin (Maintenance) | M67 |
| B-24 | Dark/Light tugun nomlari (`Edit Documents` → `edit doc`) | **Light nomlari kanonik**; dark nusxalar Figma qatlam nomi xolos | ✅ | M179 |
| B-25 | `Main Terminal` (mobil) vs `Home Terminal Address` (backend) | **`Home Terminal`** | ✅ | M97 |
| B-26 | ELD banneri: `ELD . Connected` / `ELD . Not connected` / `ELD not connected` | **`ELD · Connected` / `ELD · Not connected`** | ✅ | M68 |
| B-27 | `OneBook ELD` / `OneBookELD` / `ONEBOOK ELD` | **`OneBook ELD`** | ✅ | M90 |
| B-28 | Feedback matni: planshetda ham «mobile app» | Planshetda **«the app»** | ✅ | M113 |
| B-29 | Bo'sh holat matnlari: `No Data Found` vs `No DVIR Found` vs `No Ticket Added Yet` | **Kontekstga xos matn saqlanadi** (§11.0.4) | ✅ | — |
| B-30 | «Please change your status to update trailer and document.» | **Olib tashlanadi** — trailer/doc statusdan mustaqil yangilanadi | ✅ | M53 |
| B-31 | Planshetdagi `Search Item ...` maydoni | **Olib tashlanadi** (eskirgan qoldiq) | ✅ | M121 |

**M179 [MUST]** Figma tugun nomlaridagi farqlar (`edit doc`, `Home/Full screen..`, `Selecetd`) —
**faqat dizayn fayli metama'lumoti**; kodga hech qanday ta'siri yo'q. Kod nomlari
`core/ui` va marshrut konstantalaridan olinadi.

### 21.2 Imlo xatolari — **16 ta**

| № | Dizaynda | To'g'risi | Mobilga taalluqli | Qaror |
|---|---|---|---|---|
| C-1 | `Maintainance` | `Maintenance` | ❌ (M67 — modul yo'q) | Kodda hech qayerda ishlatilmaydi |
| C-2 | `Invocie` | `Invoice` | ❌ (M67) | — |
| C-3 | `Grese` | `Grease` | ❌ admin | — |
| C-4 | `0verdue` (nol) | `Overdue` | ❌ (M67); bildirishnoma matni serverdan | Server matni ishlatiladi |
| C-5 | **`Insection`** | **`Inspection`** | ✅ | M108 — matn tuzatiladi |
| C-6 | `Drivers Mangement` | `Drivers Management` | ❌ admin | — |
| C-7 | `Selecetd` | `Selected` | ✅ (planshet ekran nomi) | Figma metama'lumot; kodda `Certify Selected (n)` |
| C-8 | `easr avon` | `East Avon` | ✅ (namuna qiymat) | Demo ma'lumot — kodga o'tmaydi; location serverdan |
| C-9 | `GET BTY` | `GET BY` | ❌ admin (IFTA) | — |
| C-10 | `Last Address *` | `Last Name` | ❌ admin | — |
| C-11 | `cManagement - Inactive` | `Driver Management - Inactive` | ❌ admin | — |
| C-12 | **`Drive mode (automaticlly)`** | `automatically` | ✅ | M51 — kodda `driveModeAuto` |
| C-13 | **`5 mint idle`** | `5 min idle` | ✅ | Ekran nomi `idlePrompt`; UI matni «You've been idle for 5 minutes.» |
| C-14 | `23,97464553778` (vergul) | `23.97464553778` (nuqta) | ✅ | M91 — koordinata formati `.` bilan, `en_US` lokali |
| C-15 | `XT` (IFTA shtat kodi) | AQSh shtat kodi emas | ❌ admin | — |
| C-16 | Warning `#F9B385` yozilgan, RGB `246,176,71` | **`#F6BA47`** | ✅ | M82 |

### 21.3 Begona kontent va demo matnlar — **olib tashlanadi [MUST]**

| № | Nima | Qayerda | Qaror |
|---|---|---|---|
| X-1 | **Privacy Policy / Terms of Use** — «Jusoor», «ONTime Log», «OnTime ELD», Saudiya biznes platformasi kontenti | mobil `2627:25778`, planshet `2568:25226` | **To'liq olib tashlanadi.** Haqiqiy matn buyurtmachidan (❓ M117). MVP: placeholder + support havolasi |
| X-2 | **Chat demo xabarlari** — «Hi-FI wireframes for flora app design» va dizayn jarayoni matnlari | mobil `1118:114` | **Olib tashlanadi.** Bo'sh holat matni bilan almashtiriladi (M118) |
| X-3 | Muqova sarlavhasi «Seamless Healthcare Access Mobile App Design» | `2142:16231` | **Olib tashlanadi** — Figma metama'lumot |
| X-4 | Rolli ruxsatlar — go'zallik saloni domeni (`Salons`, `Clients`, `Employees`) | `330:45466` | ❌ admin; mobil permission ro'yxati §17.7 dan |
| X-5 | `Lorem ipsum` placeholder'lari (Notes, Main Terminal, DVIR location) | ko'p ekranda | **Barchasi olib tashlanadi.** Bo'sh maydon → `N/A` yoki bo'sh holat matni |
| X-6 | Demo qiymatlar: `abc976`, `abc@gmail.com`, `+92 3345677788`, `BMW mi7 2019`, `Abdullah Khan`, `1123456788 . California` | Login, Profile, Home | **Faqat placeholder sifatida**; real qiymatlar `/me` va `GET /company` dan |
| X-7 | Bildirishnoma namunalari («Admin has added a new route», «Maintenance was due 2 days ago») | `1156:7135` | Matn **serverdan** keladi (`Notification.title/body`); mobil o'zi matn yozmaydi |
| X-8 | Eskirgan qatlamlar: `Universal ELD` (`14:4`), TailAdmin shabloni (`14:10`), proytecto-MC (`14:8`), planshet `Section 3` (`1495:43530`) | Figma | **Implementatsiya qilinmaydi** |
| X-9 | Eskirgan `Profile › Maintenance` bandi (`1206:14181`) | mobil | **Implementatsiya qilinmaydi** (M67) |

**M180 [MUST]** CI da grep tekshiruvi: `lorem`, `ipsum`, `Jusoor`, `ONTime`, `flora app`,
`abc@gmail`, `Abdullah Khan`, `BMW mi7` — prod kodda va ARB fayllarida **topilmasligi shart**.

### 21.4 Dizaynda aniqlanmagan nuqtalar — mobil uchun hal qilinganlari

| Bet 141 № | Savol | **Qaror** |
|---|---|---|
| 1 | HOS formulalari, `65:00` yoki `70:00` | `hos_policy` serverdan (`cycle_limit_min`); UI qiymatni qattiq yozmaydi (§8) |
| 2 | `Recap` hisobi | `RecapDay {available_min, gained_next_min}` serverdan + lokal `recap()` (Q10.7) |
| 3 | Sertifikatsiya oynasi 8 yoki 11 kun | **8 kun** (M124) |
| 4 | `Not Ready` sharti | Serverning `ready` maydoni (M125) |
| 5 | Harakat chegarasi va manbai | `motion_threshold_kmh` (8), ELD/ECM → GPS fallback (M56) |
| 6 | Idle `No` javobidan keyingi status; javobsizlik | **`ON`**, vaqt = so'rov chiqqan payt (M60) |
| 7 | Joylashuv aniqligi chegarasi | **>150 m** → «location might be inaccurate» (`tz.md` Q9) |
| 8 | Warning qachon Violation'ga aylanadi | `hos_policy.warning_thresholds`; **server hal qiladi** (§8.4) |
| 9 | DVIR holat o'tishlarini kim boshqaradi | §11.6.1 jadvali; `certified` — **haydovchi**, `repaired` — Service Manager (M104) |
| 10 | Marshrut `Ongoing → Completed` | ❌ mobilda marshrut ekrani yo'q |
| 11 | Inactive unit/driver loglari | `403 ACCOUNT_INACTIVE` → sessiya tozalanadi, outbox saqlanadi (M17) |
| 12 | Rolli ruxsatlar mazmuni | §17.7 permission ro'yxati |
| 13 | ELD qurilma modellari | ❓ M80 — hali tanlanmagan |
| 14 | `Alert Type` / `Delivery Method` | ❌ admin (Maintenance) |
| 15 | Sana/vaqt formati (6 xil) | §11.0.7 (M91) |
| 16 | Export/Import formatlari | Inspection: `fmcsa_eld_output` / `csv_pdf_zip` (M-41) |

### 21.5 Ochiq savollar ❓

| № | Savol | Kimga | Bloklaydimi | Muddat |
|---|---|---|---|---|
| ❓ M15 | Invitation asosiy kanali (SMS / Email) | Buyurtmachi | Yo'q (ikkalasi qo'llab-quvvatlanadi) | 0-bosqich |
| ❓ M76 | Tarmoq tezligini o'lchash uchun endpoint (`v1` da yo'q) | Backend jamoasi (CR) | Yo'q (taxminiy o'lchov) | 11-bosqich |
| ❓ M80 | ELD qurilma modeli va SDK | Buyurtmachi | **Ha, 6-bosqichni** | 5-bosqich oxiri |
| ❓ M83 | Product Sans litsenziyasi (Display darajasi) | Buyurtmachi | Yo'q (IBM Plex fallback) | 1-bosqich |
| ❓ M117 | Privacy Policy / Terms of Use haqiqiy matni | Buyurtmachi (yuridik) | **Ha, store review'ni** | 10-bosqich |
| ❓ M181 | `User Manual` mazmuni va joylashuvi (PDF / URL / ilova ichida) | Buyurtmachi | Yo'q | 9-bosqich |
| ❓ M182 | Ilova ikonkasi, splash logotipi, store skrinshotlari, brend materiallari | Dizayner | **Ha, store review'ni** | 10-bosqich |
| ❓ M183 | Planshet MDM/device-owner provisioning strategiyasi (kiosk) | Buyurtmachi/IT | Yo'q (screen pinning fallback) | 10-bosqich |
| ❓ M184 | Push uchun Firebase loyihasi va APNs sertifikatlari | Buyurtmachi | **Ha, 9-bosqichni** | 8-bosqich |
| ❓ M185 | App Store / Play Console hisoblari va huquqiy shaxs | Buyurtmachi | **Ha, 11-bosqichni** | 9-bosqich |

### 21.6 Dizayn qo'shimchalari ro'yxati 🎨 (dizaynerdan so'raladi)

| № | Nima | Ustuvorlik |
|---|---|---|
| 🎨1 | Yuklanish (skeleton/spinner) va umumiy xato holati komponentlari | Yuqori |
| 🎨2 | Sync indikatori (app bar) + `M-54 Sync status` + `M-55 Sync conflicts` | Yuqori |
| 🎨3 | `M-26/27 Pending edits` (ro'yxat + Approve/Reject, asl vs taklif) | Yuqori |
| 🎨4 | `M-28 Unidentified driving claim` | Yuqori |
| 🎨5 | PC / YM toggle status formasida + logdagi belgilar | Yuqori |
| 🎨6 | DVIR `Pre-trip` / `Post-trip` toggle | Yuqori |
| 🎨7 | `M-36 Previous defects certification` modali | Yuqori |
| 🎨8 | `M-04 PIN` ekrani (telefon + planshet) | Yuqori |
| 🎨9 | `M-39` inspection'dan chiqish PIN modali | O'rta |
| 🎨10 | `M-05 Invitation`, `M-06/07` parol tiklash, `M-08` 2FA | O'rta |
| 🎨11 | `M-56 Signed out elsewhere`, `M-57 Force update`, `M-58 Sessions` | O'rta |
| 🎨12 | ELD skan/ulanish ekrani (`M-19`) | O'rta |
| 🎨13 | Chat bo'sh holati + `blocked` xabar ko'rinishi | O'rta |
| 🎨14 | Support ticket thread (`M-51`) | Past |
| 🎨15 | Defect picker qidiruv + foto/izoh bloklari | O'rta |
| 🎨16 | Android OEM autostart / battery optimization onboarding | Past |
| 🎨17 | `needs_recertify` badge uslubi | O'rta |
---
---

# QISM C — CLAUDE CODE UCHUN ISH TARTIBI

Ushbu bo'lim — **bajarish rejasi**. Har bosqich: qamrov · bog'liqlik · chiqish mezoni · checkbox.
Bosqich yopilmaguncha keyingisiga o'tilmaydi.

## C.0 Umumiy amaliy qoidalar **[MUST]**

| № | Qoida |
|---|---|
| P1 | **Bitta tool chaqiruvi ≤5 daqiqa.** `flutter build`, `pod install`, `openapi-generator`, emulator — **fon rejimida** (`run_in_background`) |
| P2 | Uzoq buyruq natijasi log faylga yoziladi, keyin `grep`/`tail` bilan o'qiladi — butun log kontekstga tortilmaydi |
| P3 | **Parallel agentlar faqat kesishmaydigan fayllarda.** Bir vaqtda bitta agent bitta `lib/features/<x>/` papkasida ishlaydi; `core/` ga tegish faqat arxitektor agentida |
| P4 | Har bosqich oxirida **majburiy yashil**: `flutter analyze` · `dart format --set-exit-if-changed` · `flutter test` · `flutter build apk --debug` |
| P5 | **3-bosqich: 35/35 golden vektor o'tmaguncha keyingi bosqichga o'tilmaydi.** Istisno yo'q |
| P6 | Fayl yozishda bo'lak-bo'lak: bitta `Write` ≤400 qator; katta fayl bir necha `Edit` bilan to'ldiriladi |
| P7 | Generatsiya qilingan kod (`packages/eld_api`) **qo'lda tahrirlanmaydi**; kerak bo'lsa wrapper yoziladi |
| P8 | Har PR: DoD checkbox'lari to'ldirilgan bo'lishi shart (C.3) |
| P9 | TZ dan chetlashish kerak bo'lsa — **avval `tz-mobile.md` ga CR**, keyin kod |
| P10 | Migratsiya (Drift `schemaVersion`) — forward-only, mavjudini tahrirlash **taqiq** |
| P11 | Har bosqich oxirida `flutter-code-reviewer` + `mobile-security-auditor` yuritiladi |
| P12 | Yangi paket qo'shishdan oldin: litsenziya (MIT/BSD/Apache) va oxirgi 12 oyda yangilanganligi tekshiriladi |

## C.1 Tavsiya etilgan subagentlar (`.claude/agents/`)

| Agent | Vazifasi | Skillari |
|---|---|---|
| **`flutter-architect`** | Karkas, `core/*`, tema, router, DI, CI, env; qatlam qoidalarini qo'riqlaydi | `flutter-conventions`, `eld-api-contract` |
| **`hos-dart-porter`** | `packages/hos_engine` — Go `internal/hos` porti va golden vektorlar | `eld-hos`, `hos-parity` |
| **`offline-sync-engineer`** | Drift sxemasi, outbox, scheduler, `packages/sync_core`, konflikt UI mapping | `eld-sync`, `flutter-drift` |
| **`ble-integration`** | `core/eld`, BLE, fon xizmati, malfunction/diagnostic, platform channel | `flutter-ble`, `eld-device` |
| **`screen-implementer`** | `lib/features/*` ekranlari (dizayn tizimi bo'yicha), ikki profil, ikki tema | `eld-design-system`, `flutter-conventions` |
| **`flutter-test-engineer`** | Unit/widget/golden/integration testlar, CI job'lari, chaos testlar | `flutter-testing` |
| **`mobile-security-auditor`** | Token saqlash, PIN, pinning, PII, permission, MASVS chek-list | `mobile-security` |
| **`flutter-code-reviewer`** | Qatlam buzilishi, dublikat, i18n, hard-coded rang/matn, DoD tekshiruvi | `flutter-conventions` |
| **`release-engineer`** | Store metadata, imzolash, Play/App Store review materiallari | `store-release` |

### Yangi skillar (`.claude/skills/`)
| Skill | Mazmuni |
|---|---|
| `flutter-conventions` | Stack, papka tuzilmasi, qatlamlar, lint, taqiqlar (§2), DoD |
| `eld-design-system` | Ranglar/tipografika/spacing tokenlari, komponentlar, ikki tema, ikki profil (§11.0) |
| `flutter-drift` | Drift sxema konventsiyalari, migratsiya qoidalari, outbox patterni (§5) |
| `flutter-ble` | BLE ulanish, fon rejimi, state restoration, malfunction kodlari (§10) |
| `hos-parity` | Golden vektor formati, Go↔Dart taqqoslash, CI job (§8, §20.2) |
| `mobile-security` | §17 chek-listi, MASVS L1 |
| `flutter-testing` | Test piramidasi, golden test sozlamalari, integration stsenariylari (§20) |
| **Mavjudlaridan foydalaniladi** | `eld-sync`, `eld-hos`, `eld-api-contract` (o'zgartirilmaydi) |

---

## C.2 Bosqichlar

### Bosqich 0 — Karkas, auth, API klient
**Qamrov:** loyiha karkasi, `core/*` skeleti, `eld_api` generatsiyasi, auth oqimi, `app/config`, CI.
**Bog'liqlik:** yo'q. **Agent:** `flutter-architect`.

- [ ] `flutter create` + papka tuzilmasi (§2.3), `packages/` monorepo (`melos` yoki path bog'liqlik)
- [ ] `analysis_options.yaml` + taqiqlar grep skripti (`tool/check_forbidden.sh`)
- [ ] `tool/generate_api.sh` → `packages/eld_api` (`openapi-generator` `dart-dio`), `.gitattributes`
- [ ] `core/config` (Env, `--dart-define-from-file`), 3 muhit
- [ ] `core/network`: Dio, auth interceptor, **refresh mutex**, retry, `Idempotency-Key`, xato → `ApiError`
- [ ] `core/error`: kod → xabar mapping jadvali (`UNAUTHORIZED`, `ACCOUNT_INACTIVE`, `RATE_LIMITED`, …)
- [ ] `core/security`: `flutter_secure_storage` vault, `device_id` generatsiyasi
- [ ] `core/device`: `DeviceProfile` (phone/tablet, M6)
- [ ] `core/router`: go_router, auth guard, `StatefulShellRoute` skeleti
- [ ] `core/i18n`: ARB karkasi, `app_en.arb`, `context.l10n`
- [ ] Ekranlar: M-01 Splash, M-02 Login, M-05, M-06, M-07, M-08, M-57 Force update
- [ ] `GET /app/config` bootstrap + min version tekshiruvi
- [ ] CI: `analyze`, `format`, `test`, `api-gen` diff, `build apk`

**Chiqish mezoni:**
- ✅ Real backendga (`https://eldapi.stackyard.uz/api/v1`) login qilinadi, `/me` javob beradi
- ✅ Token refresh avtomatik ishlaydi (901 s kutish testi yoki qo'lda muddat qisqartirish)
- ✅ `flutter analyze` 0 issue, CI yashil
- ✅ `packages/eld_api` generatsiya qilingan va `git diff` bo'sh

---

### Bosqich 1 — Dizayn tizimi va ikki tema
**Qamrov:** `core/ui` to'liq, ikki tema, ikki qurilma profili, golden test karkasi.
**Bog'liqlik:** 0. **Agent:** `screen-implementer` + `flutter-architect`.

- [ ] `tokens.dart` — ranglar (§11.0.1), light + dark `ColorScheme` kengaytmasi
- [ ] `typography.dart` — IBM Plex Sans, nomlangan shkala (§11.0.2), `textScaler` cheklovi
- [ ] `spacing.dart`, `radius.dart`, `shadows.dart` (§11.0.3)
- [ ] Komponentlar: `AppBarPrimary`, `AppButton` (3 variant), `AppTextField`, `AppChip`,
      `StatusBadge`, `HosLinearIndicator`, `HosRingIndicator`, `DutyGrid24h`, `DateStrip8Day`,
      `EmptyState`, `ErrorState`, `LoadingSkeleton`, `AppBottomSheet`, `TabletModal`,
      `ConfirmDialog`, `SignaturePad`, `SyncIndicator`, `BannerStrip` (warning/violation/eld)
- [ ] `AdaptiveScaffold` — `PhoneView`/`TabletView` ajratish mexanizmi (M7)
- [ ] Tema almashtirish: telefon `Profile › Dark mode`, planshet app bar ikonkasi; `kv_settings` da saqlanadi
- [ ] `Zoom` toggle (M94)
- [ ] Golden test infratuzilmasi (`golden_toolkit`, 4 ta konfiguratsiya)

**Chiqish mezoni:**
- ✅ Komponentlar katalogi (`/dev/components` ekrani, faqat debug) ikkala temada to'g'ri
- ✅ Har komponent uchun golden ×4 (light/dark × phone/tablet)
- ✅ Hard-coded rang/matn grep tekshiruvi yashil

---

### Bosqich 2 — Drift va oflayn karkas
**Qamrov:** lokal DB, outbox, sync scheduler skeleti (server chaqiruvsiz), retention.
**Bog'liqlik:** 0. **Agent:** `offline-sync-engineer`.

- [ ] Drift sxemasi (§5.1) — barcha jadvallar, indekslar, `schemaVersion=1`
- [ ] DAO'lar + `drift_dev schema dump` snapshot
- [ ] `OutboxRepository`: atomik yozuv (M24), `device_seq` atomik oshirish (M20)
- [ ] `SyncScheduler`: trigger'lar, backoff + jitter, mutex (M26)
- [ ] `packages/sync_core`: batch bo'lish (M33), retention siyosati, konflikt sabab→matn mapping
- [ ] Retention job (§5.2), 100 MB byudjet nazorati
- [ ] `SQLCipher` integratsiyasi `[SHOULD]`
- [ ] Ekranlar: M-54 Sync status, M-55 Sync conflicts

**Chiqish mezoni:**
- ✅ 1000 ta soxta event yoziladi va `device_seq` tartibi buzilmaydi (test)
- ✅ Ilova o'ldirilib qayta ochilganda outbox to'liq saqlanadi (chaos test)
- ✅ Migratsiya testi: v1 → v1 (kelajakda har qadam)
- ✅ `sync_core` coverage ≥90%

---

### Bosqich 3 — **HOS Dart porti + golden vektorlar** 🔒
**Qamrov:** `packages/hos_engine` to'liq.
**Bog'liqlik:** yo'q (0 dan mustaqil, parallel bajarilishi mumkin). **Agent:** `hos-dart-porter`.

- [ ] `packages/hos_engine` skeleti (sof Dart, M44) + CI tekshiruvi (`flutter` bog'liqligi yo'q)
- [ ] Modellar: `DutyStatus`, `Special`, `HosEvent`, `HosPolicy`, `HosCounters`, `DayTotals`,
      `HosViolation`, `RecapDay` (§8.2) — JSON serializatsiya `swagger.json` bilan 1:1
- [ ] `DefaultPolicy` + vektorlardagi `policy` override mexanizmi
- [ ] Kun chegarasi (Home Terminal TZ, `package:timezone`), DST bilan
- [ ] `dayTotals()` — OFF/SB/DR/ON, ochiq status, tartibsiz eventlar, yarim tun
- [ ] `computeCounters()` — BREAK / DRIVE / SHIFT / CYCLE + `drivingTimeLeft = min(...)`
- [ ] Sleeper split (7/3, 8/2, noto'g'ri juftlik)
- [ ] 34h restart, `cycle_restart_min == null`
- [ ] PC / YM semantikasi
- [ ] `violations()` — 10 tur, warning/violation darajalari
- [ ] `recap()` (Q10.7)
- [ ] `golden_vectors_test.dart` — `hos-test-vectors.json` dan **35/35**
- [ ] CI job `hos-parity` (Go + Dart, hash tekshiruvi M174)
- [ ] Benchmark: 14 kun eventlari ≤50 ms

**Chiqish mezoni (qattiq):**
- ✅ **35/35 vektor yashil.** 34/35 — bosqich yopilmagan
- ✅ `hos_engine` coverage ≥95%
- ✅ `dart pub deps` da `flutter` yo'q
- ✅ `hos-parity` CI job yashil (Go va Dart bir xil faylda)

---

### Bosqich 4 — Duty status va auto-DR
**Qamrov:** status oqimi, forma, quick notes, drive mode, idle prompt, PC/YM, Home ekrani.
**Bog'liqlik:** 1, 2, 3. **Agent:** `screen-implementer` + `flutter-architect`.

- [ ] `core/time`: `TimeSource` (§7), skew siyosati, `timezone` init
- [ ] `core/location`: GPS, aniqlik siyosati (>150 m), reverse geocoding + kesh
- [ ] `DutyStatusController`: status o'zgartirish → validatsiya → outbox (M24)
- [ ] Motion detektor: `motion_threshold_kmh`, 3 s tasdiq, to'xtash (0 va ≥3 s) — **mock manba bilan**
- [ ] Idle taymer (5 daq + 1 daq), lokal bildirishnoma (M62)
- [ ] `intermediate` event taymeri (60 daq)
- [ ] PC / YM toggle + `allow_*` tekshiruvi
- [ ] `manual_no_eld` rejimi (M66)
- [ ] Ekranlar: M-09 Home, M-10 Drawer, M-11 Edit documents, M-12 Change duty status,
      M-13 Quick notes, M-14 Location error, M-15 Drive mode, M-16 Idle prompt
- [ ] HOS indikatorlari Home'da (`hos_engine` bilan), 1 s taymer / 30 s qayta hisoblash

**Chiqish mezoni:**
- ✅ IT-1 (mock harakat manbai bilan) o'tadi
- ✅ Haydash rejimiga o'tish ≤1 s (o'lchangan)
- ✅ Idle prompt vaqti aniq: so'rov chiqqan payt (M60) — unit test
- ✅ Home ekrani scroll'siz ko'rinishi (M88) — golden test

---

### Bosqich 5 — Sync push/pull va konfliktlar
**Qamrov:** haqiqiy `/sync/push`, `/sync/pull`, idempotency, 5 konflikt qoidasi, telemetriya.
**Bog'liqlik:** 2, 4. **Agent:** `offline-sync-engineer`.

- [ ] `PushWorker`: batch → `Idempotency-Key` (barqaror, M33) → natijalarni qo'llash
- [ ] `PullWorker`: kursor, `truncated` drenaj, atomik qo'llash, tartib (M36)
- [ ] Konflikt natijalari → `M-55` (§5.6 jadvali)
- [ ] `ClockVerdict` qo'llash (M39), `T` malfunction banneri
- [ ] Telemetriya buferi va yuborish (30 s / 300 m, metered chegarasi M27)
- [ ] `413`/batch bo'lish, `429` `Retry-After`, `409 IDEMPOTENCY_CONFLICT`
- [ ] `hos_policy` pull → lokal qo'llash → hisoblagichlar yangilanishi
- [ ] Play background location arizasi topshiriladi (**R1**, erta boshlanadi)

**Chiqish mezoni:**
- ✅ IT-2 (200 event, 0 yo'qotish), IT-3 (superseded), IT-4 (log_locked), IT-13 (soat siljishi)
- ✅ Chaos test: tarmoq 50% paket yo'qotish + ilova o'ldirilishi → 0 event yo'qolmaydi
- ✅ 14 kunlik bufer yuklash ≤60 s (4G simulyatsiyasi)
- ✅ Takroriy push bir xil `Idempotency-Key` bilan → server `duplicate`, dublikat yaratilmaydi

---

### Bosqich 6 — BLE va ELD qurilmasi
**Qamrov:** `EldTransport` abstraksiyasi, mock + real, fon rejimi, malfunction.
**Bog'liqlik:** 4, 5. **Bloklovchi ochiq savol:** ❓M80. **Agent:** `ble-integration`.

- [ ] `abstract class EldTransport` + `MockEldTransport` (barcha stsenariylar: harakat, to'xtash, malfunction)
- [ ] `flutter_blue_plus` implementatsiyasi: skan, ulanish, qayta ulanish backoff
- [ ] Handshake: firmware, VIN, RTC, odometer, engine hours; VIN mosligi tekshiruvi
- [ ] ELD buferini o'qish + deterministik `client_event_id` (M72)
- [ ] Android foreground service (`location|connectedDevice`), doimiy bildirishnoma
- [ ] iOS `bluetooth-central` + `location` + **state restoration** (M73, M74)
- [ ] Malfunction/diagnostic detektori (P/E/T/L/R/S/O) + banner (M77)
- [ ] Ekranlar: M-17, M-18 Permissions, M-19 ELD connect, M-46 Diagnosis, M-47 Check network
- [ ] Ruxsatlar oqimi (§10.2), OEM onboarding 🎨

**Chiqish mezoni:**
- ✅ Mock transport bilan barcha ekranlar to'liq ishlaydi
- ✅ Real qurilma bilan: ulanish → auto-DR → to'xtash → qayta ulanish (uzilishdan keyin ≤60 s)
- ✅ Ekran o'chiq holda 30 daqiqa uzluksiz yozuv (Android va iOS)
- ✅ Batareya o'lchovi boshlang'ich nuqta sifatida qayd etilgan

---

### Bosqich 7 — Loglar, sertifikatsiya, pending edits
**Qamrov:** Log Report (3 tab), grid, event detali, certify, pending edits, driver edit.
**Bog'liqlik:** 3, 4, 5. **Agent:** `screen-implementer`.

- [ ] M-22/23/24 Log Report (Main / Logs / DVIR), 8 kunlik sana tasmasi (M96)
- [ ] `DutyGrid24h` — PC/YM belgilari, event ikonkalari, warning/violation satrlari
- [ ] M-25 Log event detail (origin badge, edited belgisi M137)
- [ ] M-29 Certify ro'yxati, M-30 Sign (`SignaturePad`, saqlangan imzo), M-31 Not Ready
- [ ] Ko'p kunlik sertifikatsiya bitta imzo bilan (M126), oflayn sertifikatsiya (M128)
- [ ] M-26/27 Pending edits (Approve/Reject, `DR` bloklash M133, asl vs taklif)
- [ ] Driver edit formasi (`POST /daily-logs/{id}/events`, note majburiy)
- [ ] `needs_recertify` oqimi (M131)
- [ ] M-28 Unidentified claim (§11.5)
- [ ] Fayllar: `POST /files/presign` + imzo yuklash (§16)

**Chiqish mezoni:**
- ✅ IT-5, IT-6, IT-12 o'tadi
- ✅ Sertifikatlangan kunga event → `log_locked` → UI to'g'ri xabar
- ✅ Grid golden testlari ×4, 14 kunlik ma'lumot bilan
- ✅ Oflayn sertifikatsiya → onlayn → server tasdiqlaydi

---

### Bosqich 8 — DVIR va Inspection
**Qamrov:** DVIR yaratish, nuqson katalogi, fotolar, previous-defects certification, inspection kiosk.
**Bog'liqlik:** 7. **Agent:** `screen-implementer`.

- [ ] M-32 Add DVIR (pre/post toggle), M-33 Defect picker (server katalogi M105, qidiruv, foto, izoh)
- [ ] Foto siqish + EXIF GPS tozalash (M147), `files_queue`
- [ ] M-34 Review + Driver signature → `POST /dvir-reports`
- [ ] M-35 DVIR details, `kind` → badge mapping (M102, M103)
- [ ] M-36 Previous defects certification (`pending-certification` → `certify`)
- [ ] Kritik nuqson ogohlantirishi (M106)
- [ ] M-37 Inspection Report (3 amal), M-38 kiosk rejimi, M-39 chiqish PIN
- [ ] M-40 Send via email, M-41 Send the file (`fmcsa_eld_output` / `csv_pdf_zip`)
- [ ] Inspection oflayn manba (lokal 14 kun, M-38)

**Chiqish mezoni:**
- ✅ IT-7, IT-8 o'tadi
- ✅ Nuqson katalogida `Engine` dublikati va `Refresh` yo'q (B-12 tekshiruvi)
- ✅ Kiosk rejimidan faqat PIN bilan chiqiladi (Android back, gesture, recent apps — hammasi bloklangan)
- ✅ Oflayn `Begin Inspection` ishlaydi va «Offline copy» izohi ko'rinadi

---

### Bosqich 9 — Chat va push bildirishnomalar
**Qamrov:** chat, oflayn navbat, haydash bloki, FCM/APNs, deep link, notification ekrani.
**Bog'liqlik:** 5. **Bloklovchi:** ❓M184. **Agent:** `screen-implementer` + `flutter-architect`.

- [ ] Firebase sozlash (Android + iOS), APNs sertifikatlari
- [ ] `POST /devices/push-token` ro'yxatga olish + token refresh
- [ ] Notification kanallari (M144), ruxsat so'rovi (Android 13+)
- [ ] M-42 Chat: kursor pagination, oflayn navbat (M138), fayl/lokatsiya (M139)
- [ ] Haydash rejimida bloklash + `409 DRIVING_MODE_BLOCKED` oqimi (M141)
- [ ] M-43 Notifications: guruhlash, o'qildi, `read-all`
- [ ] Deep link mapping (M145), ilova yopiq holatdan ochish
- [ ] Lokal bildirishnomalar (HOS warning M50, idle M62, ELD uzilishi, malfunction)
- [ ] `hos_*`/`eld_*` o'chirib bo'lmasligi (M143) + OS darajasida o'chirilgan holat banneri

**Chiqish mezoni:**
- ✅ IT-11 o'tadi
- ✅ Push ilova yopiq / fonda / ochiq holatda kelib, to'g'ri ekranga olib boradi (3 holat ×5 tur)
- ✅ Oflayn yozilgan 20 xabar tarmoq qaytganda tartib bilan yuboriladi

---

### Bosqich 10 — Planshet va co-driver
**Qamrov:** planshet layouti, modallar, kiosk, ikki sessiya, Leave Truck / Return to truck.
**Bog'liqlik:** 4, 6, 7, 8. **Agent:** `screen-implementer` + `flutter-architect`.

- [ ] T-01 Home (uch ustunli, scroll'siz M120), `HosRingIndicator`
- [ ] T-02…T-35 barcha planshet ko'rinishlari (§11.11), `TabletModal` sarlavha qatori (M122)
- [ ] Ikki sessiya menejeri (M9): ikki token juftligi, alohida outbox, umumiy `device_seq`
- [ ] M-20/T-07 Switch co-driver + PIN, M-21/T-08 Select shipping document
- [ ] `Leave Truck` / `Return to truck` to'liq oqimi (§4.8), co-driver avtomatik faollashishi
- [ ] M-03, M-04 PIN (planshet klaviaturasi)
- [ ] Kiosk: Android lock task mode (M169), wakelock, iOS Guided Access qo'llanmasi
- [ ] Landshaft orientatsiya qulfi, 1366×1024 golden testlari
- [ ] M-58 Sessions, M-56 Signed out elsewhere

**Chiqish mezoni:**
- ✅ IT-9, IT-10, IT-15 o'tadi
- ✅ Planshetda barcha golden testlar (light + dark) yashil
- ✅ Bitta qurilmada ikki haydovchi 8 soat ishlaydi, loglar aralashmaydi (integration + qo'lda test)
- ✅ Bir xil biznes mantiq (`Controller`) telefon va planshetda — kod dublikati yo'q (reviewer tasdiqlaydi)

---

### Bosqich 11 — Sayqal va store'ga tayyorgarlik
**Qamrov:** profil/support/legal ekranlari, NFR o'lchovlari, xavfsizlik, store materiallari.
**Bog'liqlik:** 0–10. **Bloklovchi:** ❓M117, ❓M182, ❓M185. **Agent:** `release-engineer` + `mobile-security-auditor`.

- [ ] M-44…M-53 Profil, Settings, Feedback, Support (forma + ro'yxat + thread), Legal
- [ ] Legal matnlari (M117) yoki placeholder + support havolasi
- [ ] Begona kontent grep tekshiruvi (M180) yashil
- [ ] **NFR o'lchovlari** (§19): cold start, drive mode, batareya (8 soat), bufer yuklash, hajm
- [ ] Batareya optimizatsiyasi: GPS chastotasi adaptiv, telemetriya batchlash
- [ ] Xavfsizlik auditi (§17 chek-listi), sertifikat pinning (M153)
- [ ] Sentry + PII filtri (M160), maxsus hodisalar (M178)
- [ ] Kirish imkoniyati: kontrast, teginish o'lchami, TalkBack/VoiceOver asosiy oqimlarda
- [ ] Store: ikonka, splash, skrinshotlar (telefon + planshet, light + dark), tavsif,
      Data safety / App Privacy formalari, background location videosi va asosi
- [ ] Android: `minSdk 29`, `targetSdk` eng yangi, R8, AAB imzolash
- [ ] iOS: `deployment target 15.0`, `Info.plist` matnlari, TestFlight
- [ ] Release checklist + rollback rejasi

**Chiqish mezoni:**
- ✅ Barcha NFR o'lchangan va hisobotda (M172)
- ✅ `mobile-security-auditor` hisobotida **Critical/High = 0**
- ✅ Play va App Store'ga yuborilgan (review holatidan qat'i nazar bosqich yopiladi)
- ✅ Barcha 15 integration testi yashil
- ✅ 35/35 HOS vektori hali ham yashil (regressiya yo'q)

---

## C.3 Definition of Done (har vazifa uchun) **[MUST]**

Vazifa **faqat** quyidagilar bajarilganda yopiladi:

**Kod**
- [ ] `flutter analyze` — 0 issue (info ham)
- [ ] `dart format --line-length=100` — o'zgarishsiz
- [ ] Taqiqlar grep (§2.4) — yashil: `DateTime.now()`, `print`, hard-coded matn/rang, `http`
- [ ] Qatlam qoidasi buzilmagan (`presentation → domain → data`, M5)
- [ ] Generatsiya qilingan kod qo'lda tahrirlanmagan

**Test**
- [ ] Yangi biznes mantiq uchun unit test bor
- [ ] Yangi ekran uchun widget test (yuklanish/bo'sh/xato/to'la) bor
- [ ] Yangi asosiy ekran uchun golden ×4 (light/dark × phone/tablet) bor
- [ ] `flutter test` yashil; coverage pasaymagan
- [ ] HOS yoki sync tegilgan bo'lsa: `hos-parity` / `sync_core` testlari yashil

**UX / mahsulot**
- [ ] Ekran **ikkala temada** to'g'ri (skrinshot PR ga qo'shilgan)
- [ ] Ekran **ikkala qurilma profilida** to'g'ri (agar ikkalasida bo'lsa)
- [ ] **Oflayn xatti-harakati** aniq va sinovdan o'tgan
- [ ] Bo'sh holat, xato holati, yuklanish holati bor
- [ ] Barcha matn ARB da (`app_en.arb`), hard-coded emas
- [ ] Sana/vaqt formati §11.0.7 ga mos

**Kontrakt**
- [ ] Faqat `swagger.json` dagi endpoint va maydonlar ishlatilgan
- [ ] Xato kodlari `core/error` mapping'iga qo'shilgan
- [ ] `Idempotency-Key` talab qilinadigan joyda berilgan
- [ ] `company_id` so'rov tanasiga qo'yilmagan (M164)

**Hujjat**
- [ ] `tz-mobile.md` bilan ziddiyat yo'q; bo'lsa — CR qilingan
- [ ] Yangi qaror bo'lsa `M<n>` raqami bilan TZ ga qo'shilgan
- [ ] PR tavsifida: qaysi ekran/qaror, qaysi testlar, skrinshotlar

**Ko'rik**
- [ ] `flutter-code-reviewer` o'tkazgan
- [ ] Auth/token/PIN/fayl/permission tegilgan bo'lsa — `mobile-security-auditor` o'tkazgan

---

## C.4 Bosqichlar xaritasi (bog'liqliklar)

```
0 (karkas/auth) ──┬──► 1 (dizayn tizimi) ──┐
                  ├──► 2 (Drift/oflayn) ───┼──► 4 (duty/auto-DR) ──► 5 (sync) ──┬──► 6 (BLE)
3 (HOS porti) ────────────────────────────-┘                                    ├──► 7 (loglar/certify)
   (mustaqil, parallel)                                                         │        │
                                                                                │        ▼
                                                                                │    8 (DVIR/inspection)
                                                                                ▼        │
                                                                            9 (chat/push)│
                                                                                └────────┴──► 10 (planshet/co-driver) ──► 11 (sayqal/store)
```

**Parallellashtirish tavsiyasi:**
- **3-bosqich** (`hos-dart-porter`) — 0/1/2 bilan **to'liq parallel** (kesishmaydigan papka: `packages/hos_engine`)
- **1 va 2** — parallel (`core/ui` vs `core/db` + `core/sync`)
- **6 va 7** — parallel (`core/eld` vs `lib/features/logs`), lekin ikkalasi ham 5 dan keyin
- **9** — 7/8 bilan parallel bo'lishi mumkin (`lib/features/chat` alohida)

---

## C.5 Yakuniy qabul mezonlari (mobil MVP)

| № | Mezon |
|---|---|
| A1 | **35/35 HOS golden vektori** Go va Dart'da bir xil natija beradi |
| A2 | **0 event yo'qotish** chaos testda (1000 event, tarmoq uzilishi, ilova o'ldirilishi) |
| A3 | Telefon va planshet **bitta kodbazadan** quriladi; biznes mantiq dublikati yo'q |
| A4 | Light va dark tema **barcha ekranlarda** (golden testlar bilan tasdiqlangan) |
| A5 | 15 ta integration stsenariysi yashil |
| A6 | Barcha NFR (§19) o'lchangan va talabga javob beradi |
| A7 | Xavfsizlik auditida Critical/High = 0 |
| A8 | Dizayndagi **31 nomlash nomuvofiqligi** va **16 imlo xatosi** reestr bo'yicha hal qilingan |
| A9 | Begona kontent va demo matnlar **yo'q** (M180 grep yashil) |
| A10 | Ilova Google Play va App Store'ga yuborilgan; Data safety / App Privacy to'ldirilgan |
| A11 | Barcha ❓ ochiq savollar yopilgan yoki qayd etilgan holda buyurtmachi tasdig'i olingan |
| A12 | `tz-mobile.md` va kod o'rtasida chetlashish yo'q (yoki har biri CR bilan hujjatlangan) |

---

**Hujjat oxiri.** O'zgartirishlar faqat CR orqali. Har CR: sabab · ta'sirlangan `M<n>` qarorlari ·
ta'sirlangan bosqichlar · testlarga ta'siri.
