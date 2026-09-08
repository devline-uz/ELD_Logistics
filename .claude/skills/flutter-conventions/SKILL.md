---
name: flutter-conventions
description: ONEBOOK ELD mobil ilovasi uchun majburiy Flutter/Dart stack, papka tuzilmasi, qatlam qoidasi, lint taqiqlari, muhitlar, amaliy ish qoidalari va Definition of Done. Har qanday Dart/Flutter fayl yozishdan OLDIN o'qi.
---

# ELD Mobile — Flutter konventsiyalari (`tz-mobile.md` §2, C.0, C.3)

Ildiz: `eld_mobile/`. Kontrakt: `backend/docs/swagger.json` (`basePath=/api/v1`), **v1 muzlatilgan**. Bazaviy URL:
`https://eldapi.stackyard.uz/api/v1`. Xato konverti: `{"error":{"code","message","details"}}`.
**M1 [MUST]** Qo'lda yozilgan API modeli **yo'q** — `openapi-generator (dart-dio)` `swagger.json` dan
`packages/eld_api` ni chiqaradi; CI da qayta generatsiya, diff bo'lsa build yiqiladi.
**M2 [MUST]** Dizayn ↔ backend farqi har doim **backend foydasiga** hal qilinadi, §21 reestriga yoziladi.
Ustuvorlik: `swagger.json` > `tz.md` > `eld-sync`/`eld-hos` > `hos-test-vectors.json` > `design-inventory.md` > Figma.

## Stack (o'zgartirish MUMKIN EMAS)
| Qatlam | Tanlov |
|---|---|
| SDK | Flutter 3.x stable (CI da pin), Dart 3 |
| Holat | **Riverpod 2.x** (`riverpod_generator`, `riverpod_lint`) — **M3** |
| Navigatsiya / DI | `go_router` (`StatefulShellRoute.indexedStack`) · DI = Riverpod provayderlari (`get_it` YO'Q) |
| Lokal DB | **Drift** (SQLite) + `drift_flutter`, `sqlite3_flutter_libs` |
| API | `packages/eld_api` (dart-dio generatsiya) + `dio` interceptorlar |
| BLE / Fon | `flutter_blue_plus` (vendor SDK bo'lsa platform channel, §10.7) · Android `flutter_foreground_task`, iOS `bluetooth-central` + `location` |
| Saqlash / Push | `flutter_secure_storage` (Keychain / EncryptedSharedPreferences) · `firebase_messaging` |
| i18n / Imzo | `intl` + `flutter_localizations`, ARB (`lib/l10n/app_en.arb`) · `signature` yoki `CustomPainter` (oflayn) |
| Vaqt / Log | `timezone` (IANA tzdata, Home Terminal TZ majburiy) · `logger` + fayl sink, PII maskalangan (§17.5) |
| Test | `flutter_test`, `mocktail`, Drift in-memory, `integration_test`, `golden_toolkit` |

## Papka tuzilmasi [MUST]
```
eld_mobile/
├─ packages/
│  ├─ hos_engine/     # sof Dart. Flutter/HTTP/DB/DateTime.now() YO'Q
│  │  lib/src/{model,policy,compute,violations,recap}.dart · test/golden_vectors_test.dart
│  ├─ sync_core/      # sof Dart. Konflikt/validatsiya, batch bo'lish
│  └─ eld_api/        # GENERATSIYA. Qo'lda tahrirlanmaydi (linguist-generated)
├─ lib/
│  ├─ main.dart  # bootstrap  ·  app.dart  # MaterialApp.router, tema, lokalizatsiya
│  ├─ core/
│  │  ├─ network/   # Dio, auth interceptor, refresh queue, retry, Idempotency-Key
│  │  ├─ sync/      # outbox, scheduler, push/pull ishchi, konflikt UI mapping
│  │  ├─ time/      # TimeSource: ELD RTC → server → telefon, skew, tz
│  │  ├─ security/  # token vault, PIN hash, screen protection, PII mask
│  │  ├─ error/     # ApiError → UI xabar mapping · ui/ # dizayn tokenlari, tema
│  │  └─ config/ db/ eld/ location/ background/ router/ device/ i18n/
│  └─ features/
│     ├─ auth/ home/ duty_status/ drive_mode/ logs/ certify/ log_edits/ dvir/ inspection/
│     ├─ unidentified/ chat/ notifications/ profile/ settings/ diagnostics/ support/ feedback/ legal/ eld_device/
│     └─ (har biri: data/ · domain/ · presentation/{screens,widgets,controllers})
└─ assets/{icons,images,legal} · test/ · integration_test/ · test_goldens/
   tool/  # generate_api.sh, verify_vectors.dart, check_l10n.dart
```

## Qatlam qoidalari [MUST]
1. **M4** — `hos_engine`/`sync_core` `pubspec.yaml` da `flutter` bog'liqligi **yo'q**;
   CI: `dart pub deps --json | grep flutter` bo'sh bo'lishi kerak.
2. **M5** — `presentation → domain → data`. `presentation` **hech qachon** `eld_api` modelini ishlatmaydi;
   `data` qatlamida domen modeliga o'giriladi (backenddagi `sqlc → DTO` falsafasi bilan bir xil).
3. Biznes qoidasi **hech qachon** widget/provayder ichida emas — faqat `hos_engine`, `sync_core`, `features/*/domain`.
4. Vaqt faqat `core/time/TimeSource` orqali; `keepAlive` provayderlar: sync scheduler, BLE menejer, HOS taymer.

## Lint va TAQIQLAR
`analysis_options.yaml`: `flutter_lints` + `riverpod_lint` + `custom_lint`; **error** darajasida: `avoid_print`,
`always_declare_return_types`, `prefer_const_constructors`, `unawaited_futures`, `avoid_dynamic_calls`,
`use_build_context_synchronously`.

| Taqiq (CI grep bilan tekshiriladi) | Sabab |
|---|---|
| `DateTime.now()` — `hos_engine`, `sync_core`, domen ichida | Testlar deterministik; vaqt `TimeSource` dan |
| `print(` / `debugPrint(` prod kodida | PII sizishi |
| Hard-coded matn widget ichida | i18n majburiy (`context.l10n.*`) |
| Hard-coded rang `core/ui/tokens.dart` dan tashqarida | Ikki tema (light + dark majburiy) |
| `http` paketi | Yagona transport — `dio` interceptorlari |
| `packages/eld_api` ni qo'lda tahrirlash | Generatsiya; kerak bo'lsa wrapper |

Formatlash: `dart format --line-length=100`, CI da `--set-exit-if-changed`. Kommit: Conventional Commits.

## Muhitlar
`--dart-define-from-file=env/{dev,stage,prod}.json` → `API_BASE_URL`, `WS_URL`, `SENTRY_DSN`, `ENABLE_DEV_MENU`.
Prod build'da dev menyu va sertifikat pinning bypass **yo'q**.

## Amaliy ish qoidalari (C.0, P1–P12) [MUST]
- **P1/P2** Bitta tool chaqiruvi ≤5 daqiqa: `flutter build`, `pod install`, `openapi-generator`, emulator — `run_in_background`; natija log faylga, keyin `grep`/`tail` bilan o'qiladi (butun log kontekstga tortilmaydi).
- **P3** Parallel agentlar faqat kesishmaydigan fayllarda; bir vaqtda bitta agent bitta `lib/features/<x>/` da. `core/` ga faqat arxitektor tegadi.
- **P4/P5** Har bosqich oxirida majburiy yashil: `flutter analyze` · `dart format --set-exit-if-changed` · `flutter test` · `flutter build apk --debug`. 3-bosqichda **35/35 golden vektor** o'tmaguncha keyingi bosqichga o'tilmaydi (istisno yo'q).
- **P6/P7** Bitta `Write` ≤400 qator (katta fayl `Edit` bilan to'ldiriladi); generatsiya qilingan kod qo'lda tahrirlanmaydi — wrapper yoziladi.
- **P8/P9** Har PR da DoD checkbox'lari to'ldirilgan; TZ dan chetlashish kerak bo'lsa — avval `tz-mobile.md` ga CR, keyin kod.
- **P10** Drift `schemaVersion` migratsiyasi forward-only; mavjudini tahrirlash **taqiq**.
- **P11/P12** Har bosqich oxirida `flutter-code-reviewer` + `mobile-security-auditor`; yangi paket — litsenziya (MIT/BSD/Apache) va oxirgi 12 oyda yangilanganligi tekshiriladi.

## Definition of Done (C.3) — har vazifa
**Kod:** `flutter analyze` 0 issue (info ham) · `dart format` o'zgarishsiz · taqiqlar grepi yashil · qatlam
qoidasi (M5) buzilmagan · generatsiya qilingan kod tegilmagan.
**Test:** yangi biznes mantiqqa unit test · yangi ekranga widget test (yuklanish/bo'sh/xato/to'la) · yangi asosiy
ekranga golden ×4 (light/dark × phone/tablet) · `flutter test` yashil, coverage pasaymagan · HOS/sync tegilsa
`hos-parity` va `sync_core` testlari yashil.
**UX:** ikkala tema (skrinshot PR da) · ikkala qurilma profili · oflayn xatti-harakati sinovdan o'tgan ·
bo'sh/xato/yuklanish holatlari · barcha matn `app_en.arb` da · sana/vaqt formati §11.0.7 ga mos.
**Kontrakt:** faqat `swagger.json` dagi endpoint/maydonlar · xato kodlari `core/error` mappingida ·
`Idempotency-Key` kerakli joyda · `company_id` so'rov tanasiga **qo'yilmagan** (M164).
**Hujjat/Ko'rik:** `tz-mobile.md` bilan ziddiyat yo'q (yoki CR) · yangi qaror `M<n>` bilan TZ da · PR tavsifida
ekran/qaror, testlar, skrinshotlar · `flutter-code-reviewer` · auth/token/PIN/fayl/permission tegilsa `mobile-security-auditor`.

## tz-mobile.md xaritasi (kerakli bo'limni `sed` bilan o'qi, butun faylni emas)
| Qatorlar | Mazmun |
|---|---|
| 69–170 | §2 stack, papka, lint |
| 170–243 | §3 ikki qurilma profili, co-driver |
| 243–368 | §4 auth, PIN, sessiya, Leave Truck |
| 368–506 | §5 oflayn-first, Drift, outbox |
| 506–605 | §6 sync push/pull |
| 605–650 | §7 vaqt yaxlitligi |
| 650–751 | §8 HOS Dart porti |
| 751–892 | §9 duty status oqimi |
| 892–1008 | §10 ELD/BLE |
| 1008–1115 | §11.0 dizayn tizimi |
| 1115–1183 | §11.1 mobil ekranlar registri |
| 1183–1528 | §11.2–11.10 ekranlar spetsifikatsiyasi |
| 1528–1606 | §11.11 planshet ekranlari registri |
| 1606–1675 | §12 sertifikatsiya |
| 1675–1731 | §13 log tahrirlash |
| 1731–1780 | §14 chat |
| 1780–1831 | §15 push |
| 1831–1868 | §16 fayllar |
| 1868–1938 | §17 xavfsizlik |
| 1938–2000 | §18 platforma cheklovlari |
| 2000–2026 | §19 NFR |
| 2026–2098 | §20 test |
| 2098–2241 | §21 nomuvofiqliklar reestri |
| 2241–2658 | QISM C ish tartibi |
