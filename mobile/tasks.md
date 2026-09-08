# ONEBOOK ELD — MOBIL ILOVA ish rejasi (Flutter)

> Bu **mobil** reja. Backend rejasi — `../tasks.md` (alohida, aralashtirilmaydi).

**Manba:** `tz-mobile.md` (QISM C) · `design-inventory.md` · **Figma: `ELD Software (Copy)`** (`NLDjNYebjCuNswunequFv2`)
**Papka:** `mobile/` · **Kontrakt:** `contracts/swagger.json` (backend `v1` muzlatilgan)
**Nuqsonlar reestri:** `mobile/bugs.md` — ochiq bloklovchilar, kontrakt bo'shliqlari, qatlam buzilishi va loyiha bo'ylab tuzoqlar.
**Bajarish tartibi:** har vazifa subagent orqali; `[x]` = tugadi va tekshirildi, `[~]` = jarayonda, `[ ]` = boshlanmagan.
**Har bosqich oxirida majburiy:** `flutter-code-reviewer` + `mobile-security-auditor` + `flutter analyze` · `dart format --set-exit-if-changed` · `flutter test` · `flutter build apk --debug` yashil.

## Auditning oxirgi holati (2026-09-07 22:15)

| O'lchov | Natija |
|---|---|
| `flutter analyze` | **0 issue** ✅ |
| `dart format --output=none --set-exit-if-changed --line-length=100 lib test test_goldens packages/*` | **34 fayl formatlanmagan** ❌ (CI `format` job qizil) |
| `bash tool/check_forbidden.sh` | **9/9 OK** ✅ (M4, M5, M164 ham yashil) |
| `flutter test test test_goldens` | **287 o'tdi / 21 yiqildi** ❌ · `test/features/sync/sync_screens_test.dart` **osilib qoladi** (cheksiz kutish, `--timeout` siz `flutter test` hech qachon tugamaydi) |
| `dart test packages/hos_engine` | **129/129** ✅ (35/35 golden vektor) |
| `dart test packages/sync_core` | **79/79** ✅ |
| Hajm | `lib/` 242 Dart fayl · `lib/features/` 121 · ekran fayllari **20** · golden PNG **78** · `integration_test/` **bo'sh** |

**Yiqilgan testlar taqsimoti:** `test/features/auth/auth_screens_test.dart` **19/19** (barcha M-01…M-08, M-57 widget testlari:
`Bad state: No element`, `Found 0 widgets with type "AppButton"`, 100 ta `performLayout` assertion — auth ekranlari
test sirtida umuman layout bo'lmayapti) · `test/core/router/app_router_test.dart` **1** (`unknown holatida splash`) ·
`test/features/sync/sync_screens_test.dart` **1** (M-55 testi osilib qoladi).

> ⚠️ Audit paytida `lib/features/{dvir,logs,eld_device}` ga parallel agentlar fayl qo'shmoqda —
> quyidagi belgilar **22:15 dagi snapshot**. Bosqich yopilishidan oldin qayta o'lchash shart.

## Subagentlar (`.claude/agents/`)
`flutter-architect` · `figma-extractor` · `screen-implementer` · `hos-dart-porter` ·
`offline-sync-engineer` · `ble-integration` · `flutter-test-engineer` ·
`mobile-security-auditor` · `flutter-code-reviewer` · `release-engineer`

## Skillar (`.claude/skills/`)
`flutter-conventions` · `eld-design-system` · `eld-screens` · `flutter-drift` ·
`flutter-ble` · `hos-parity` · `mobile-security` · `flutter-testing`
Mavjudlardan: `eld-api-contract`, `eld-hos`, `eld-sync`

## Qat'iy qoidalar (C.0)
- Bitta tool chaqiruvi ≤5 daqiqa; `flutter build`, `pod install`, emulator — **fon rejimida**, natija log faylga.
- Parallel agentlar faqat **kesishmaydigan papkalarda**; `core/` ga faqat `flutter-architect` tegadi.
- `packages/hos_engine` va `packages/sync_core` — **sof Dart**, `flutter` bog'liqligi YO'Q (M4).
- Qatlam: `presentation → domain → data` (M5). `eld_api` modeli UI ga chiqmaydi.
- Taqiqlar (CI grep): `DateTime.now()` (domen/paketlarda), `print(`/`debugPrint(`, hard-coded matn, hard-coded `Color(0x…)`, `http` paketi.
- Drift `schemaVersion` forward-only; mavjud migratsiyani tahrirlash taqiq.
- **3-bosqich: 35/35 golden vektor o'tmaguncha keyingi bosqichga o'tilmaydi. Istisno yo'q.**
- TZ dan chetlashish kerak bo'lsa — avval `tz-mobile.md` ga CR, keyin kod.

---

## Bosqich M0 — Karkas, auth, API klient 🔄
**Agent:** `flutter-architect` · **Bog'liqlik:** yo'q

### M0.1 Loyiha karkasi
- [x] `mobile/` da `flutter create` (org `uz.stackyard.onebookeld`), papka tuzilmasi §2.3 bo'yicha
- [x] `packages/` monorepo: `hos_engine` ✅, `sync_core` ✅, `eld_api` ✅ (openapi-generator 7.25.0, 641 model) — uchalasi `pubspec.yaml` ga ulangan
- [x] `analysis_options.yaml` (flutter_lints + riverpod_lint, error darajasidagi qoidalar) — ⚠️ `custom_lint` olib tashlandi, CR-M01
- [x] `tool/check_forbidden.sh` — taqiqlar grep skripti (9 tekshiruv, hammasi yashil)
- [x] `env/{dev,stage,prod}.json` + `--dart-define-from-file`
- [x] `.gitignore`, `.gitattributes` (`packages/eld_api` → `linguist-generated`)

### M0.2 API klient va tarmoq
- [~] `tool/generate_api.sh` ishlatildi, `packages/eld_api` chiqarildi va `pubspec.yaml` da **yoqildi**; lekin `auth_api.dart`, `dvir_api.dart`, `profile_repository_impl.dart` hamon qo'lda yozilgan Dio chaqiruvlaridan foydalanadi — M1 [MUST] to'liq bajarilmagan
- [x] `core/config` — `Env`, 3 muhit
- [x] `core/network` — Dio, auth interceptor, **refresh mutex** (`refresh_coordinator.dart`), retry, `Idempotency-Key`, `ApiError`
- [x] `core/error` — xato kodi → xabar mapping (`api_error_code.dart`, `api_error_messages.dart`)
- [x] `core/security` — `flutter_secure_storage` vault, `device_id`
- [x] `core/device` — `DeviceProfile` (phone/tablet, M6), `app_version`
- [x] `core/router` — go_router, auth guard, `StatefulShellRoute` (4 shox; `home` va `logs` hamon `PlaceholderScreen`)
- [x] `core/i18n` — ARB karkasi, `app_en.arb` **482 kalit**, `context.l10n`

### M0.3 Auth ekranlari
- [x] Ekran fayllari to'la (M-01 Splash, M-02 Login + M-03 `leaveTruck`, M-04 PIN, M-05 Invitation, M-06/M-07 Forgot/Reset, M-08 Two-factor, M-57 Force update). **19 yiqilgan test tuzatildi** → 39/39 yashil; `totp_screen.dart` dagi haqiqiy layout bug'i ham tuzatildi
- [x] Ruxsatlar so'rovi ekrani — `features/eld_device/.../permissions_screen.dart` (`/permissions`), M6 doirasida yozildi
- [x] `GET /app/config` bootstrap + min version tekshiruvi (`auth_api.appConfig`, `splash_controller`, `force_update_controller`)
- [x] CI: `analyze`, `format`, `test`, `api-gen` diff, `build apk` (`.github/workflows/mobile-ci.yml`)
- [ ] Real backendga (`https://eldapi.stackyard.uz/api/v1`) login → `/me` tekshiruvi bajarilmadi

**Chiqish mezoni:** real backendga login → `/me` javob beradi · token refresh avtomatik · `flutter analyze` 0 issue · `packages/eld_api` git diff bo'sh

**Holat:** `analyze` 0 issue ✅ · `check_forbidden.sh` toza ✅ · `format` toza ✅ · auth testlari **39/39** ✅. Qolgan: `eld_api` ni haqiqiy chaqiruvlarga ulash, real backend login testi.
Qolgan: **auth widget testlarini tuzatish (BLOKLOVCHI)**, `eld_api` ni `pubspec.yaml` ga ulash va qo'lda yozilgan API klientlarni almashtirish, M-08 Permissions, real backend login testi.

### Ochiq qarorlar (M0 dan chiqqan — TZ §2.1 stack'iga CR nomzodlari)
| # | Masala | Holat |
|---|---|---|
| CR-M01 | `custom_lint` olib tashlandi — `riverpod_lint 3.x` native `analysis_server_plugin` (analyzer ^13), `custom_lint 0.8.1` analyzer ^8 da; birga resolve bo'lmaydi. `analyzer: plugins: - riverpod_lint` ishlatildi | texnik zarurat, tasdiqlash kerak |
| CR-M02 | `golden_toolkit` discontinued (oxirgi reliz 2023-02, `sdk <3.0.0`) — P12 ni buzadi. Nomzod: `alchemist ^0.14.0` (MIT, 2026-03) | **hal qilinmagan** — 78 golden hamon `golden_toolkit` da |
| CR-M03 | Flutter **3.44.8** pin (`meta 1.18.0`) → riverpod 3.3.2, build_runner 2.15.1, drift ^2.34.0 ga cheklov. 3.47.2 ga ko'tarilsa eng so'nggilari ochiladi | **buyurtmachi qarori** |
| CR-M04 | `sqlite3_flutter_libs` EOL — `drift_flutter` + `sqlite3 ^3.5.2` orqali keladi | qabul qilindi |
| CR-M05 | `openapi-generator` lokalda yo'q | ✅ **yopildi** — `packages/eld_api` generatsiya qilindi; endi uni `pubspec.yaml` ga ulash qoldi |
| CR-M06 | `image_picker` / `file_picker` / `url_launcher` / `geolocator` / `flutter_local_notifications` / `sqlcipher_flutter_libs` — `pubspec.yaml` da **yo'q**, kod ularsiz abstraksiya bilan yozilgan (`TODO(P12)`, `TODO(P-01)`) | M8/M9/M11 ni bloklaydi, litsenziya tekshiruvi kerak |

---

## Bosqich M1F — Figma dan piksel-aniq ekstraksiya ✅ 🎨
**Agent:** `figma-extractor` · **Bog'liqlik:** yo'q (M0 bilan parallel)
**Old shart:** Figma Desktop ochiq + `ELD Software (Copy)` fayli + `Plugins → Development → Figma Desktop Bridge` oynasi ochiq + `figma-console` MCP ulangan.

- [x] `figma_get_status` bilan ulanish tasdiqlanadi (port 9225, plugin v1.40.0, probe 3 ms)
- [x] `mobile/design/figma/tokens.json` — 40 rang stili + 23 tipografika tokeni + soya
- [x] `mobile/design/figma/MAP.md` — 66 light / 59 dark ekran; 64 tasi M-ID ga bog'landi; 16 ta 🎨 Figma da yo'q; 9 light freym dark juftisiz (butun DVIR oqimi dark temada chizilmagan)
- [x] `mobile/design/figma/DIFF.md` — **25 farq: 🔴 8 · 🟡 12 · 🟢 5**
- [x] Radius/spacing/stroke o'lchandi (10 kanonik ekran, barcha tugunlar) → `tokens.json`
- [x] **TZ ga CR qo'llandi:** CR-F01 (body6≠body7), CR-F02 (spacing 5pt baza), CR-F03 (radius — M86 bekor, `27.25` soya blur ekan)
- [ ] `mobile/design/figma/screens/<ID>.json` — ekran-ekran tugun daraxti (M4/M7 ekranlari uchun kerak bo'ladi)
- [x] `mobile/design/figma/png/` — **138 PNG @2x** (72 light + 66 dark, 17 MB) + `INDEX.md`

**Holat:** tokenlar + MAP + DIFF + 138 PNG etaloni tayyor ✅.
Qolgan: ekran-ekran tugun daraxti JSON'lari · planshet (T-01…T-35) freymlari (M10 da).

---

## Bosqich M1 — Dizayn tizimi va ikki tema ✅
**Agent:** `screen-implementer` + `flutter-architect` · **Bog'liqlik:** M0, M1F

- [x] `core/ui/tokens.dart` — ranglar, light + dark `ColorScheme` kengaytmasi (M81, M82)
- [x] `core/ui/typography.dart` — IBM Plex Sans, nomlangan shkala, `textScaler` 0.85–1.3 cheklovi (M84, M85)
- [x] `core/ui/spacing.dart`, `radius.dart`, `shadows.dart` (M86 → CR-F03)
- [x] Komponentlar (18): `AppBarPrimary`, `AppButton` ×3, `AppTextField`, `AppChip`, `StatusBadge`,
      `HosLinearIndicator`, `HosRingIndicator`, `DutyGrid24h`, `DateStrip8Day`, `EmptyState`,
      `ErrorState`, `LoadingSkeleton`, `AppBottomSheet`, `TabletModal`, `ConfirmDialog`,
      `SignaturePad`, `SyncIndicator`, `BannerStrip`
- [x] `AdaptiveScaffold` — `PhoneView`/`TabletView` ajratish (M7)
- [x] Tema almashtirish + `Zoom` toggle (M94) — `kv_settings` ga saqlanadi (`theme_mode`/`text_scale`), qayta ishga tushganda tiklanadi
- [x] Golden test infratuzilmasi (`golden_toolkit`, 4 konfiguratsiya) — **78 golden PNG**
- [x] `/dev/components` katalog ekrani (faqat debug, `Env.devMenuVisible`)

**Holat:** 18 komponent · `core/ui/` ✅ · `analyze` 0 issue · goldenlar yashil · grep toza ✅

**Ochiq:** `assets/fonts/` bo'sh — shrift `.ttf` fayllari yo'q (D-22). D-26 hal bo'lgach shriftlar qo'yiladi va **barcha 78 golden qayta yaratiladi**.
`theme_controller` persistensiyasi M2 ning `kv_settings` DAO'si bilan ulanmagan (yuqoridagi `[~]`).

---

## Bosqich M2 — Drift va oflayn karkas ✅
**Agent:** `offline-sync-engineer` · **Bog'liqlik:** M0

- [x] Drift sxemasi (§5.1) — **19 jadval** (`event_tables`, `log_tables`, `outbox_tables`, `dvir_tables`, `chat_tables`, `ref_tables`), indekslar, `schemaVersion=1`
- [x] DAO'lar (8: outbox, duty_events, logs, dvir, chat, telemetry, ref, settings) + `drift_schemas/schema_v1.sql` snapshot + `schema_snapshot_test.dart` + `migration_test.dart`
- [x] `OutboxRepository` — atomik yozuv (M24), `device_seq` atomik oshirish (M20) · `outbox_repository_test.dart`
- [x] `SyncScheduler` — trigger'lar, backoff + jitter, mutex (M26) · `sync_scheduler_test.dart`
- [x] `packages/sync_core` — batch bo'lish (M33), idempotency, retention, konflikt sabab→matn mapping · **79/79 test**, `flutter` bog'liqligi yo'q (`no_flutter_dependency_test.dart`)
- [x] Retention job (§5.2), 100 MB byudjet nazorati (`retention_service.dart`, 90 MB da telemetriyaning 10% i o'chadi) · `retention_service_test.dart`
- [x] `SQLCipher` yoqildi — `sqlcipher_flutter_libs` 0.7.0+eol **bo'sh paket** bo'lgani uchun olib tashlandi; `pubspec.yaml` → `hooks: user_defines: sqlite3: source: sqlcipher`. Test bilan tasdiqlandi: `PRAGMA cipher_version` = **4.18.0 community**. Kalit — 32 bayt `Random.secure()`, `flutter_secure_storage` da
- [x] Ekranlar: M-54 Sync status ✅, M-55 Sync conflicts ✅ — osilib qolgan widget testi tuzatildi (drift `watch()` → `tester.runAsync`)
- [x] `chaos_restart_test.dart` — ilova o'ldirilgandan keyin outbox butunligi

**Chiqish mezoni:** 1000 event → `device_seq` tartibi buzilmaydi ✅ · ilova o'ldirilib ochilganda outbox to'liq ✅ · `sync_core` coverage ≥90% ✅

**Holat:** `core/db` ✅ (`schemaVersion 2`, `violations` jadvali qo'shildi) · `core/sync` ✅ · `sync_core` 79/79 ✅. **Bosqich yopiq.**
Qolgan: SQLCipher paketini ulash (CR-M06) · **M-55 osilgan testini tuzatish (BLOKLOVCHI)** · `theme_controller` ni `settings_dao` ga ulash.

---

## Bosqich M3 — HOS Dart porti + golden vektorlar 🔒 ✅
**Agent:** `hos-dart-porter` · **Bog'liqlik:** yo'q (M0/M1/M2 bilan to'liq parallel)

- [x] `packages/hos_engine` skeleti (sof Dart, M44) + CI tekshiruvi (`purity_test.dart`)
- [x] Modellar: `DutyStatus`, `Special`, `HosEvent`, `HosPolicy`, `HosCounters`, `DayTotals`, `HosViolation`, `RecapDay`
- [x] `DefaultPolicy` + vektorlardagi `policy` override
- [x] Kun chegarasi (Home Terminal TZ, `package:timezone`), DST
- [x] `dayTotals()`, `computeCounters()` (BREAK/DRIVE/SHIFT/CYCLE + `drivingTimeLeft`)
- [x] Sleeper split (7/3, 8/2, noto'g'ri juftlik), 34h restart, PC/YM
- [x] `violations()` — 10 tur, warning/violation darajalari; `recap()`
- [x] `golden_vectors_test.dart` — **35/35**
- [x] CI job `hos-parity` (Go + Dart, hash tekshiruvi M174 — `vectors_hash_test.dart`)
- [x] Benchmark: 14 kun ≤50 ms (`benchmark_test.dart`)

**Holat:** `dart test packages/hos_engine` → **129/129 ✅**, `dart pub deps` da `flutter` yo'q ✅. **Bosqich yopiq.**

---

## Bosqich M4 — Duty status va auto-DR ✅
**Agent:** `screen-implementer` + `flutter-architect` · **Bog'liqlik:** M1, M2, M3

- [x] `core/time` — `TimeSource` (§7, ELD RTC → server → telefon), skew siyosati, `ClockVerdict` (M39), `day_boundary`, `timezone` init · `time_source_test.dart`, `day_boundary_test.dart`
- [~] `core/location` — Dart qatlami to'la (`LocationService`, aniqlik siyosati >150 m, `ReverseGeocoder` + kesh, mock). **Native tomon yo'q:** `MethodChannel('eld/location')` uchun Android/iOS handler yozilmagan (`MainActivity.kt` 5 qator, `AppDelegate.swift` 16 qator) → real GPS ishlamaydi
- [x] `DutyStatusController` — validatsiya → outbox (M24)
- [x] Motion detektor: `core/eld/motion_detector.dart` (313 q.) — `motion_threshold_kmh`, 3 s tasdiq, to'xtash
- [~] Idle taymer (5 daq + 1 daq) ✅ (M60/M61) · **lokal bildirishnoma (M62) hali yo'q** — `flutter_local_notifications` paketi `pubspec.yaml` da yo'q, `idle_alert.dart` faqat interfeys
- [x] `intermediate` event taymeri (60 daq, M63) — `duty_status_repository_impl.dart:193`
- [x] PC/YM toggle + `allow_*` (M64); `manual_no_eld` rejimi (M66)
- [x] Ekranlar: M-09 Home · M-10 Drawer · M-11 Edit documents · M-12 Change duty status · M-13 Quick notes · M-14 Location inaccurate · M-15 Drive mode · M-16 Idle prompt — **8/8**, 31 Dart fayl
- [x] Home'da HOS indikatorlari (1 s taymer / 30 s qayta hisoblash)

**Chiqish mezoni:** IT-1 o'tadi · drive mode ≤1 s · idle prompt vaqti aniq (M60) · Home scroll'siz (M88) golden

**Holat:** 8/8 ekran ✅ · 42 test + 22 golden ✅ · `core/time` ✅ · `core/location` Dart ✅ / **native handler yo'q** ❌ (`MainActivity.kt` 5 qator) · auto-DR global `ref.listen` `app.dart` da ulandi ✅
**Bu bosqich — keyingi asosiy ish.**

---

## Bosqich M5 — Sync push/pull va konfliktlar 🔄
**Agent:** `offline-sync-engineer` · **Bog'liqlik:** M2, M4

- [x] `PushWorker` — batch → barqaror `Idempotency-Key` (M33) → natijalarni qo'llash (`sync_engine.dart`)
- [x] `PullWorker` — kursor, `truncated` drenaj (M35), atomik qo'llash, tartib M36 (`pull_applier.dart`: `hos_policy` → kataloglar → `events` → `daily_logs` → …)
- [x] Konflikt natijalari → M-55 (§5.6, `conflict_messages.dart`)
- [x] `ClockVerdict` (M39) — `TimeSource.applyVerdict()`; `T` malfunction banneri `eld_malfunction_detector` da
- [~] Telemetriya: `telemetry_dao` + push payload ✅, lekin **30 s / 300 m yig'uvchi va metered chegarasi (M27) yo'q**
- [x] `413` batch bo'lish, `429` `Retry-After`, `409 IDEMPOTENCY_CONFLICT` (`sync_transport.dart`, `sync_engine.dart` retry)
- [x] `hos_policy` pull → lokal qo'llash
- [x] **`DioSyncTransport`** yozildi — `/sync/push` (4 bucket), `/sync/pull`, `Idempotency-Key`, 413/429/`Retry-After`/409, `truncated` drenaj. Env bo'yicha: dev+bo'sh `API_BASE_URL` → mock, aks holda Dio
- [ ] Chaos test 0 yo'qotish · 14 kunlik bufer ≤60 s o'lchovlari
- [ ] **Play background location arizasi topshiriladi (R1, erta boshlanadi)**

**Chiqish mezoni:** IT-2, IT-3, IT-4, IT-13 · chaos test 0 yo'qotish · 14 kunlik bufer ≤60 s · takroriy push dublikat yaratmaydi

**Holat:** sinxronlash mantiqi ✅ · **transport real** ✅ · `SyncSideChannel` (certify/claim/log_edit → o'z endpoint'lari) ✅ · `core/files/file_upload.dart` (presign → PUT → `signature_key`) ✅. Qolgan: telemetriya yig'uvchi (M27), chaos test, Play arizasi.

---

## Bosqich M6 — BLE va ELD qurilmasi 🔄
**Agent:** `ble-integration` · **Bog'liqlik:** M4, M5 · **Bloklovchi:** ❓M80 (vendor SDK)

- [x] `EldTransport` + to'liq `MockEldTransport` (248 q.)
- [x] `flutter_blue_plus` — skan, ulanish, qayta ulanish backoff (`ble_eld_transport.dart` 344 q., `eld_connection_manager.dart` 287 q.)
- [~] Handshake: firmware, VIN, RTC, odometer, engine hours; VIN mosligi — `eld_gatt_profile.dart` bor, lekin **UUID lar placeholder** (`TODO(M80)`)
- [x] Bufer o'qish + deterministik `client_event_id` (M72) — `eld_buffer_importer.dart`, `eld_client_event_id.dart`
- [~] Android foreground service — `AndroidManifest.xml` da `<service android:foregroundServiceType="location|connectedDevice">` va 18 ta `uses-permission` ✅, Dart tomoni ✅ (`android_foreground_service.dart`, `eld_task_handler.dart`); **Kotlin handler yozilmagan**
- [~] iOS `bluetooth-central` + `location` — `Info.plist` `UIBackgroundModes` ✅, `SceneDelegate.swift` ✅, `state_restoration.dart` ✅ (M73, M74); Swift kanal handler yo'q
- [x] Malfunction/diagnostic detektori (P/E/T/L/R/S/O) — `eld_malfunction_detector.dart`, `eld_codes.dart`
- [x] Ekranlar: M-17 ELD not connected · M-18 Permissions · M-19 ELD connect/scan · M-46 Diagnosis · M-47 Check network — **5/5**; 104 test + 40 golden ✅
- [ ] Real qurilmada sinov (❓M80 gacha imkonsiz)

**Chiqish mezoni:** mock bilan barcha ekranlar ishlaydi · real qurilmada ulanish→auto-DR→to'xtash→qayta ulanish ≤60 s · ekran o'chiq 30 daq uzluksiz yozuv

**Holat:** `core/eld/` ✅ · platforma konfiguratsiyasi ✅ (manifest, `Info.plist`, `minSdk 29`, iOS 15.0) · 5/5 ekran ✅ · **Kotlin/Swift kanal handlerlari yo'q** ❌ · real qurilmada sinalmagan (❓M80)
⚠️ `ble_eld_transport.dart:119` — `flutter_blue_plus >= 2.0` **BSD-3 emas**, litsenziya P12 ga zid (`TODO(P12)`); yuridik tekshiruv kerak.

---

## Bosqich M7 — Loglar, sertifikatsiya, pending edits ✅
**Agent:** `screen-implementer` · **Bog'liqlik:** M3, M4, M5

- [x] M-22/23/24 Log Report (Main/Logs/DVIR), 8 kunlik sana tasmasi (M96) · `LogDutyGrid` (PC/YM yorliqlari, event ikonkalari, M98 jamilar, Warning/Violation satrlari)
- [x] `DutyGrid24h` komponenti tayyor (M1) — PC/YM belgilari, event ikonkalari
- [x] M-25 Log event detail (origin badge, `Edited` belgisi M137, asl qiymat)
- [x] M-29 Certify · M-30 Sign (`SignaturePad`) · M-31 Not Ready
- [x] Ko'p kunlik sertifikatsiya bitta imzo bilan (M126), oflayn sertifikatsiya (M128)
- [x] M-26/27 Pending edits (Approve/Reject, `DR` bloklash M133)
- [~] Driver edit formasi — domen + repozitoriy metodi (`submitDriverEdit`, validatsiya) ✅, **UI yo'q**: M136 `Insert/Edit duty status` TZ da 🎨 va registrda ekran ID si yo'q (B-95)
- [x] M-28 Unidentified claim
- [x] Fayllar: `POST /files/presign` + imzo yuklash (§16) — `core/files/file_upload.dart`

**Chiqish mezoni:** IT-5, IT-6, IT-12 · sertifikatlangan kunga event → `log_locked` to'g'ri xabar · grid golden ×4 · oflayn sertifikatsiya server tomonidan tasdiqlanadi

**Holat:** 10/10 ekran ✅ · 36 Dart fayl · 72 test (44 widget + 28 golden) ✅. ⚠️ B-05: `warnings`/`violations` hamon `daily_logs.totals` dan o'qiladi — yangi `violations` jadvaliga o'tkazilishi kerak.

---

## Bosqich M8 — DVIR va Inspection ✅
**Agent:** `screen-implementer` · **Bog'liqlik:** M7

- [x] M-32 Add DVIR (pre/post, 248 q.), M-33 Defect picker (server katalogi M105, qidiruv, izoh — 164 q.)
- [~] Foto siqish + EXIF GPS tozalash (M147) — `exif_gps_scrubber.dart` ✅, `files_queue` ✅, lekin **`image_picker` paketi yo'q** (`dvir_file_repository.dart:31` `TODO(pubspec)`) → foto qo'shib bo'lmaydi
- [x] M-34 Review + Driver signature (`dvir_review_screen.dart`), M-35 DVIR details (`dvir_details_screen.dart`, `kind` → badge M102/M103 `dvir_badge.dart`)
- [x] M-36 Previous defects certification + kritik nuqson ogohlantirishi (M106)
- [x] M-37 Inspection Report (3 amal) · M-38 kiosk rejimi · M-39 chiqish PIN — `features/inspection/` 11 fayl
- [x] M-40 Send via email · M-41 Send the file — ⚠️ B-11: TZ `Type = Web service / Email` talab qiladi, `InspectionTransfer` esa faqat `{driver_id, date, comment}`
- [x] Inspection oflayn manba (lokal 8 kun: `logs_dao.watchRecentLogs` + `duty_events_dao.range` + `day_boundary.recentLogDates`)
- [x] `dvir_routes.dart` da M-34 (`/dvir/new/confirm`) va M-35 (`/dvir/:id`) ro'yxatga olindi

**Chiqish mezoni:** IT-7, IT-8 · katalogda `Engine` dublikati yo'q · kiosk'dan faqat PIN bilan chiqiladi · oflayn `Begin Inspection` ishlaydi

**Holat:** DVIR 4 ekran ✅ · Inspection 5 ekran ✅ · 36 test + 36 golden ✅ · foto oqimi `image_picker` siz bloklangan ❌ · DVIR/Inspection **dark maketlari Figma da yo'q** (B-61)
⚠️ `dvir_widgets.dart:5` — DVIR ekranlarining **dark maketlari Figma da yo'q**, dizaynerdan so'ralgan.

---

## Bosqich M9 — Chat va push bildirishnomalar 🔄
**Agent:** `screen-implementer` + `flutter-architect` · **Bog'liqlik:** M5 · **Bloklovchi:** ❓M184 (Firebase akkaunt)

- [ ] Firebase sozlash (Android + iOS), APNs sertifikatlari — `firebase_core`/`firebase_messaging` `pubspec.yaml` da ✅, lekin `google-services.json` va `GoogleService-Info.plist` **yo'q**, `FirebasePushGateway` yozilmagan (faqat `MockPushGateway`)
- [x] `POST /devices/push-token` + token refresh (`PushTokenRegistrar`, oflayn fallback `OutboxKind.pushToken`, token diskda hash ko'rinishida) — ⚠️ kontraktda endpoint yo'q, hozir lokal `accepted` (CR-M06)
- [x] Notification kanallari (M144, 5 kanal) + `compliance` qulfi (M143) + Android 13+ ruxsat so'rovi
- [x] M-42 Chat: kursor pagination, oflayn navbat (M138), fayl/lokatsiya (M139) — 17 fayl, ekran 214 q.
- [x] Haydash rejimida bloklash + `409 DRIVING_MODE_BLOCKED` (M141) — `chat_send_policy.dart`, `driving_mode_source_impl.dart` (`TODO(M-12)`: `duty_status` tayyor bo'lgach ulanadi)
- [x] M-43 Notifications ekrani: guruhlash, nisbiy vaqt, `Mark all as read`, o'qildi + deep link, M143 banneri, 4 holat
- [x] Deep link mapping (M145) — `notification_deeplink.dart`
- [~] Lokal bildirishnomalar: `LocalAlertRequest` (HOS warning/violation, idle, ELD uzilishi, malfunction, sync konflikt) + lokalizatsiyalangan matn ✅, **`flutter_local_notifications` paketi yo'q** → amalda ko'rsatilmaydi
- [x] `hos_*`/`eld_*` o'chirib bo'lmasligi (M143) — `notification_prefs.dart`
- [ ] `notification_prefs_controller.dart` — `kv_settings` ga saqlash (`TODO(M11-5)`, B-50)

**Chiqish mezoni:** IT-11 · push 3 holatda ×5 tur to'g'ri ekranga olib boradi · oflayn 20 xabar tartib bilan yuboriladi

**Holat:** Chat ✅ (3 haqiqiy bug tuzatildi: `build()` ichida `state` yozish, dispose'dan keyin yozish, `ChatComposer` butun ekranni egallashi) · M-43 ✅ · 73 test + 16 golden ✅ · Firebase ulanmagan (❓M184), `MockPushGateway` ishlaydi · M145 deep link ✅

---

## Bosqich M10 — Planshet va co-driver ✅
**Agent:** `screen-implementer` + `flutter-architect` · **Bog'liqlik:** M4, M6, M7, M8

- [ ] T-01 Home (uch ustunli, scroll'siz M120), `HosRingIndicator` (komponent tayyor)
- [ ] T-02…T-35 barcha planshet ko'rinishlari, `TabletModal` sarlavha qatori (M122) — komponent tayyor, ekranlar yo'q
- [ ] Ikki sessiya menejeri (M9): ikki token juftligi, alohida outbox, umumiy `device_seq`
- [ ] M-20/T-07 Switch co-driver + PIN, M-21/T-08 Select shipping document
- [~] `Leave Truck` / `Return to truck` (§4.8): `AuthRoute.paused` marshruti + `LoginScreen(mode: leaveTruck)` ✅, to'liq oqim (sessiya pauzasi, co-driver) yo'q
- [x] M-03, M-04 PIN — `pin_screen.dart` + `pin_pad.dart` (planshet klaviaturasi `AdaptiveScaffold` orqali)
- [ ] Kiosk: Android lock task mode (M169), wakelock, iOS Guided Access qo'llanmasi
- [ ] Landshaft orientatsiya qulfi, 1366×1024 golden testlari (hozircha faqat komponent goldenlari tablet profilida)
- [ ] M-58 Sessions, M-56 Signed out elsewhere

**Chiqish mezoni:** IT-9, IT-10, IT-15 · planshet golden'lari (light+dark) yashil · ikki haydovchi 8 soat, loglar aralashmaydi · biznes mantiq dublikati yo'q

**Holat:** `AdaptiveScaffold` + `TabletModal` + tablet golden infratuzilmasi ✅ · **35 planshet ekranidan 0** · co-driver sessiyasi yo'q.

---

## Bosqich M11 — Sayqal va store'ga tayyorgarlik 🔄
**Agent:** `release-engineer` + `mobile-security-auditor` · **Bog'liqlik:** M0–M10 · **Bloklovchi:** ❓M117, ❓M182, ❓M185

- [x] M-44 Profile · M-45 Settings · M-48 Feedback · M-49/M-50/M-51 Support · M-52/M-53 Legal · M-46 Diagnosis · M-47 Check network — **10/10**; 57 test + 32 golden ✅. Qolgan: **M-58 Sessions** (faqat ARB kalitlari bor, ekran yo'q)
- [~] Legal matnlari (M117) — ekran bor, kontent placeholder
- [ ] Begona kontent grep (M180) yashil
- [ ] NFR o'lchovlari (§19): cold start, drive mode, batareya (8 soat), bufer yuklash, hajm
- [ ] Batareya optimizatsiyasi (GPS adaptiv, telemetriya batch)
- [ ] Xavfsizlik auditi (§17) — **boshlandi, sessiya limiti sababli to'xtadi, qayta yuritiladi** · sertifikat pinning (M153) yo'q · `FLAG_SECURE` yo'q (M157)
- [ ] Sentry + PII filtri (M160)
- [~] Kirish imkoniyati: M11 ekranlarida ≥48 dp teginish maydoni va `Semantics` qo'yildi ✅; `core/ui/AppChip` hamon 34 dp ❌ (B-80); kontrast va TalkBack/VoiceOver tekshirilmagan
- [ ] Store: ikonka, splash, skrinshotlar, tavsif, Data safety / App Privacy, background location videosi
- [x] Android `minSdk 29` (`build.gradle.kts`), iOS `Info.plist` ruxsat matnlari · [ ] R8, AAB imzolash, target 15.0 tekshiruvi, TestFlight
- [ ] Release checklist + rollback rejasi
- [ ] `url_launcher` `pubspec.yaml` da yo'q — `User Manual`, store havolasi, tashqi havolalar ishlamaydi (B-91)

**Chiqish mezoni:** barcha NFR o'lchangan · Critical/High = 0 · 15 integration testi yashil · 35/35 HOS vektori yashil · store'ga yuborilgan

**Holat:** 10/10 profil/sozlama ekrani ✅ · Figma pariteti bo'yicha M-49/M-50/M-51/M-45/M-52/M-53 tuzatildi · qolgan hammasi ⏳

---

## Mobil yakuniy qabul mezonlari

| № | Mezon | Holat |
|---|---|---|
| A1 | 35/35 HOS golden vektori Go va Dart'da bir xil | ✅ 129/129 test, coverage 99.8% |
| A2 | 0 event yo'qotish chaos testda | 🔄 `chaos_restart_test.dart` yashil; to'liq chaos stsenariysi (transport mock) qolgan |
| A3 | Telefon va planshet bitta kodbazadan, mantiq dublikati yo'q | 🔄 `AdaptiveScaffold` ✅, telefon ekranlari planshet profilida golden bilan qoplangan; **35 planshet ekrani (T-01…T-35) yozilmagan** |
| A4 | Light va dark tema barcha ekranlarda (golden) | 🔄 **284 golden PNG** — 33 telefon ekranining hammasi light+dark × phone/tablet. ⚠️ B-60 (shrift) hal bo'lgach hammasi qayta yaratiladi |
| A5 | 15 integration stsenariysi yashil | ⏳ `integration_test/` bo'sh (0/15) |
| A6 | Barcha NFR (§19) o'lchangan | ⏳ |
| A7 | Xavfsizlik auditida Critical/High = 0 | ✅ **Critical 0 · High 0** — S-C1, S-H1…S-H6 yopildi (pauza doimiy saqlanadi, kiosk fail-closed, SSRF himoyasi, SPKI pinning, FLAG_SECURE, release imzolash, backup o'chirilgan). Medium/Low qismi qoldi |
| A6 | Barcha NFR (§19) o'lchangan | ⏳ · ⚠️ B-93: `flutter build apk` hech qachon yurgizilmagan |
| A7 | Xavfsizlik auditida Critical/High = 0 | ✅ **Critical 0 · High 0** — S-C1, S-H1…S-H6 yopildi (pauza doimiy saqlanadi, kiosk fail-closed, SSRF himoyasi, SPKI pinning, FLAG_SECURE, release imzolash, backup o'chirilgan). Medium/Low qismi qoldi |
| A10 | Play va App Store'ga yuborilgan | ⏳ |
| A11 | ❓ ochiq savollar yopilgan yoki tasdiqlangan | 🔄 CR-M05 ✅ (`eld_api` generatsiya qilindi), CR-M04 ✅ (SQLCipher yo'li topildi); ochiq: ❓M80, ❓M184, ❓M117, ❓M182/185, ❓D-26, CR-M06 |
| A12 | **UI Figma bilan piksel darajasida bir xil** | 🔄 etalonlar ✅ · M-45/M-49/M-50/M-51/M-52/M-53 Figma bo'yicha tuzatildi · qolgan: B-62 (M-18 ikonkalari), B-63 (M-47 tugma rangi), B-64 (planshetda max-width) |
| A13 | `flutter analyze` + `format` + `flutter test` + grep — hammasi yashil | ✅ **analyze 0 · 843/843 test · hos_engine 129/129 · sync_core 95/95 · format toza · grep toza · `flutter build apk` yashil** (2026-09-08) |

## CR jurnali (tz-mobile.md ga qo'llangan)
| CR | Sana | Mazmun | Manba |
|---|---|---|---|
| CR-F01 | 2026-09-07 | M84 tuzatildi: `body6` (lh 120%) va `body7` (lh 150%) **bir xil emas**, ikkalasi saqlanadi | Figma o'lchovi, DIFF #D-02 |
| CR-F02 | 2026-09-07 | Spacing bazasi **4pt → 5pt** (`5/10/15/20/25/30/40`), ekran padding 16 | Figma o'lchovi, DIFF #D-23 |
| CR-F03 | 2026-09-07 | **M86 bekor qilindi.** Radius: `4/8/12/24/pill 200`. `27.25` — soya blur radiusi, burchak radiusi emas | Figma o'lchovi, DIFF #D-01/#D-22 |
| CR-M01 | 2026-09-07 | `custom_lint` olib tashlandi (riverpod_lint 3.x analyzer nomuvofiqligi) | texnik zarurat |
| CR-M02 | 2026-09-07 | `golden_toolkit` → `alchemist` (birinchisi discontinued, P12 buzilishi) — **hali qo'llanmagan** | P12 |
| CR-M03 | 2026-09-07 | Flutter **3.44.8** da qolinadi (buyurtmachi qarori) | qaror |
| CR-M05 | 2026-09-07 | `openapi-generator` topildi, `packages/eld_api` generatsiya qilindi — **yopildi** | M1 [MUST] |
| CR-M06 | 2026-09-07 | 6 ta platforma paketi (`image_picker`, `file_picker`, `url_launcher`, `geolocator`, `flutter_local_notifications`, `sqlcipher_flutter_libs`) `pubspec.yaml` da yo'q — kod abstraksiya orqali yozilgan, funksionallik ishlamaydi | audit 2026-09-07 |
| CR-M07 | 2026-09-07 | `flutter_blue_plus >= 2.0` **BSD-3 emas** (`ble_eld_transport.dart:119`) — P12 litsenziya qoidasiga zid, yuridik qaror kerak | audit 2026-09-07 |

## Registrda topilgan xatolar (tuzatilishi kerak)
- `M-51 Ticket - View` — TZ 🎨 deb belgilagan, Figma da **bor** (`1158:462`)
- `M-53` uchun TZ §11.1 noto'g'ri node beradi (`2627:25778` → to'g'risi `2627:25891`)
- `M-33` uchun TZ `1169:1887`/`1169:2106` beradi — bular 301 dp panel, ekran emas; to'g'risi `1169:1467`
- `eld-screens` skillida «15 ta 🎨» — aslida **16 ta**
- `tasks.md` M0.3 da «M-08 Permissions» deyilgan, `eld-screens` registrida `M-08 = Two-factor`. Ruxsatlar ekrani ID si aniqlashtirilsin

## Texnik qarz reestri (audit 2026-09-07)
| # | Joy | Muammo |
|---|---|---|
| T-01 | `test/features/auth/auth_screens_test.dart` | 19/19 yiqilgan — auth ekranlari test sirtida layout bo'lmayapti (`performLayout` assertionlari, `Found 0 widgets`) |
| T-02 | `test/features/sync/sync_screens_test.dart` | M-55 testi **osilib qoladi** → `flutter test` hech qachon tugamaydi (CI hang) |
| T-03 | `test/core/router/app_router_test.dart` | `unknown holatida splash ko'rsatiladi` yiqilgan |
| T-04 | butun `lib/` | `dart format --line-length=100` da **34 fayl** o'zgaradi |
| T-05 | `pubspec.yaml` | `eld_api:` izohda — generatsiya qilingan klient ishlatilmayapti (M1 [MUST] buzilgan) |
| T-06 | `lib/core/sync/sync_providers.dart:21` | `MockSyncTransport` prod provayderda — `DioSyncTransport` yo'q |
| T-07 | `android/.../MainActivity.kt`, `ios/Runner/AppDelegate.swift` | `eld/location` va ELD kanal handlerlari yozilmagan (5 va 16 qator) |
| T-08 | `lib/core/ui/theme_controller.dart:38,43,54` | tema/zoom `kv_settings` ga saqlanmaydi |
| T-09 | `lib/core/db/connection.dart` | SQLCipher kodi bor, paket yo'q — DB shifrlanmagan |
| T-10 | `lib/features/dvir/presentation/dvir_routes.dart` | M-34/M-35 ekranlari yozilgan, lekin marshrutga ulanmagan |

## Ochiq savollar (mobil) — buyurtmachi javobi kerak
- ❓ **M80** — ELD qurilmasi vendori va SDK si (M6 ni bloklaydi; GATT UUID lari placeholder)
- ❓ **M184** — Firebase loyihasi / APNs sertifikatlari kimda (M9 ni bloklaydi)
- ❓ **M117** — Legal matnlar (Privacy Policy, Terms) manbai
- ❓ **M182 / M185** — Store akkauntlari (Play Console, App Store Connect)
- ❓ **M83** — Product Sans litsenziyasi (yo'q bo'lsa IBM Plex Sans Bold)
- ❓ **CR-M07** — `flutter_blue_plus` kommersiya litsenziyasi sotib olinadimi yoki muqobil paket?
- ❓ **Dizaynerga:** DVIR oqimi (M-32…M-35) **dark temada umuman chizilmagan** — chiziladimi yoki avtomatik moslashtiriladimi?
- ❓ **Dizaynerga:** Home ekranining 4 ta 1650 dp varianti va `Change Status` ning 891/893 varianti — qaysi biri kanonik?
- ❓ **Dizaynerga:** `15.74` / `25.5` / `13.41` kabi tekislanmagan padding qiymatlari — yaxlitlanadimi?
- ❓ **Dizaynerga:** Figma faylida **text style umuman yo'q** (0 ta) — tipografika shkalasi stil sifatida biriktiriladimi?
- 🔴 ❓ **Dizaynerga (BLOKLOVCHI, D-26):** ekranlarda **10+ shrift oilasi** ishlatilgan (Plus Jakarta Sans 50%, Product Sans 18%, Satoshi 15%, Inter 12%, IBM Plex Sans atigi **2%**), qo'llanmada esa IBM Plex Sans deyilgan. **Qaysi biri kanonik?** Nomzod: Plus Jakarta Sans (SIL OFL, bepul). Satoshi litsenziya talab qiladi.
- 🔴 ❓ **Dizaynerga (D-27):** mobil ekranlarda amalda faqat `10/12/14/16` pt ishlatilgan; qo'llanmadagi 20–48 pt shkalasi mobilda uchramaydi. Shkala qisqartiriladimi?
- 🔴 ❓ **Dizaynerga (D-28):** lineHeight ning 54% i `AUTO`, «hamma joyda 120%» qoidasi atigi 3% da. Aniq qiymatlar beriladimi?
- 🟡 ❓ **Dizaynerga (D-29):** ranglarning **37%** i tokenlarda yo'q (71 xil hex vs 36 token). `#000314` (600×), `#FFFFFF` (390×), `#000000` (253×), `#358D0C`, `#0086FF`/`#007AFF` — token bo'lishi kerakmi yoki xatomi?
