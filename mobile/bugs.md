# ONEBOOK ELD — mobil ilova nuqsonlar reestri

**Manba:** M4–M11 subagent hisobotlari, M6/M7/M8 kod ko'rigi va core-arxitektura ishi (2026-09-07/08).
**Oxirgi tekshiruv:** `flutter analyze` 0 issue · `flutter test` **605/605** · `check_forbidden.sh` toza.
**Belgilar:** 🔴 bloklovchi · 🟡 muhim · 🟢 kichik · ⬜ ochiq · 🔄 ishlanmoqda · ✅ yopilgan · ❓ qaror kutilmoqda

> Yangi nuqson topilsa shu faylga qo'shiladi. Yopilgan bandlar **o'chirilmaydi**, ✅ ga o'tkaziladi.

---

## 1. Bloklovchilar

| ID | Holat | Muammo | Egasi |
|---|---|---|---|
| B-01 | ✅ | **Ekranlar ilovaga ulanmagan.** `logsRoutes · certifyRoutes · logEditsRoutes · unidentifiedRoutes · inspectionRoutes · eldDeviceRoutes · diagnosticsRoutes · homeRoutes · dutyStatusRoutes · driveModeRoutes · chatRoutes · notificationsRoutes` — hech biri `lib/core/router/app_router.dart` da yo'q. `/logs` va `/home` hamon `_placeholderBranch`. `inspection_report_screen.dart:37` `context.push(InspectionRoute.kiosk)` runtime'da yiqiladi. | flutter-architect |
| B-02 | ✅ | **Lokal DB shifrlanmagan.** **Yopildi:** `sqlcipher_flutter_libs` 0.7.0+eol bo'sh paket ekan — olib tashlandi; `pubspec.yaml` → `hooks: user_defines: sqlite3: source: sqlcipher`. `PRAGMA cipher_version` = 4.18.0 community bilan tasdiqlandi. Kalit 32 bayt `Random.secure()`, `flutter_secure_storage`. | flutter-architect |
| B-03 | ✅ | **`DioSyncTransport` yo'q** — `sync_providers.dart` prod muhitida ham `MockSyncTransport` beradi, ilova serverga hech narsa yubormaydi. | flutter-architect |
| B-04 | ✅ | **Sertifikatsiya serverga yetmaydi.** `PushRequest` da faqat `{events, telemetry, dvir, chat}` bucket'lari; `sync_transport.dart:44` dagi `other` bucket'ining kontraktda ekvivalenti yo'q. `core/files/` (`POST /files/presign`) moduli umuman yozilmagan → imzo yuklanmaydi, `signature_local_path` → `signature_key` almashinuvi bo'lmaydi. Oflayn sertifikatsiya (M128) ishlamaydi. | flutter-architect |
| B-05 | ✅ | **`warnings`/`violations` o'lik kod.** `logs_repository_impl.dart:232-233` ularni `daily_logs.totals` JSON dan o'qiydi, `logs_dto.DayTotals` esa faqat `{off_min, sb_min, drive_min, on_min}` beradi — bu maydonlar hech qachon kelmaydi. To'g'ri manba: `GET /violations`. **Core tarafi tayyor:** `schemaVersion 2` + `violations` jadvali + pull'da `GET /violations`. **Qolgan:** `logs_repository_impl.dart` ni yangi jadvaldan o'qishga o'tkazish. | keyingi agent |
| B-06 | ✅ | **Test to'plami kompilyatsiya bo'lmasdi** — `connection.dart` `package:sqlite3/open.dart` ni import qilardi, pinlangan `sqlite3 3.5.2` da bunday kutubxona yo'q; keyin `dio_sync_transport.dart:274` `ClockVerdict.fromJson` yo'qligidan yiqildi. Parallel agentlar tuzatdi, lekin `open.overrideFor(...)` yechimi qayta ko'rilishi kerak. | — |
| B-07 | ✅ | **19 auth testi yiqilardi** — `find.byType(AppButton)` hech qachon topmaydi (fabrika konstruktorlari yopiq subklass qaytaradi). `find.bySubtype<AppButton>()` ga o'tildi. | — |
| B-08 | ✅ | **`sync_screens_test.dart` osilib qolardi** — drift `watch()` oqimini `testWidgets` tanasida `await …first` qilish `fakeAsync` zonasida deadlock beradi, `--timeout` ham qutqarmaydi. CI hech qachon tugamasdi. `tester.runAsync(...)` ga o'tildi. | — |

---

## 2. Kontrakt bo'shliqlari (backend CR nomzodlari)

| ID | Holat | Muammo |
|---|---|---|
| B-10 | ❓ | **`GET /me` da maydonlar yo'q** — `unit_number`, `phone`, `license_*` `auth_dto.Profile` da mavjud emas, profil ekrani `N/A` ko'rsatadi. |
| B-11 | ❓ | **M-41 Send the file** — TZ `Type = Web service / Email` + `Email Address` talab qiladi, `InspectionTransfer` esa faqat `{driver_id, date, comment}`. Vaqtincha `Email` tanlansa `POST /inspection/email` ga yo'naltirilgan. |
| B-12 | ⬜ | **`log_edit_requests.changes` strukturasi swagger'da aniqlanmagan.** M7 `{changes:[{from,to,status,special,current_status,current_origin,event_type,note}]}` deb faraz qildi (M133 uchun `current_origin` shart). Backend bilan tasdiqlash kerak. |

| B-13 | ❓ | **`POST /devices/push-token` endpoint'i kontraktda YO'Q** — hozir lokal `accepted` qaytariladi (navbat o'smasin uchun). CR-M06 nomzodi. |
| B-14 | ❓ | **`GET /violations` permission = `violations.read`** — haydovchi rolining ruxsatlar ro'yxatida yo'q; 403 da jimgina o'tkazib yuboriladi. Backend tasdiqlashi kerak. |
| B-15 | ⬜ | `sync_dto.DailyLogSummary` da `driver_id` yo'q → sessiyadan to'ldiriladi; profil `GET /daily-logs/{id}.form` dan 12 soatda bir olinadi. |

> ⚠️ Eslatma: B-05 va B-04 dastlab kontrakt ziddiyati deb baholangan edi — **noto'g'ri**. `GET /violations`, `POST /files/presign`, `POST /daily-logs/{id}/certify`, `POST /unidentified-events/{id}/claim`, `POST /log-edit-requests` — hammasi kontraktda **bor**. Bu mobil taraf kamchiligi.

---

## 3. Qatlam buzilishi (feature → feature import)

| ID | Holat | Fayl | Qayerga ko'chirilsin |
|---|---|---|---|
| B-20 | ✅ | `logs/presentation/widgets/async_view.dart` (8 chaqiruv joyi) | `core/ui/async_view.dart` |
| B-21 | ✅ | `logs/data/stream_combine.dart` (certify, unidentified) | `core/util/stream_combine.dart` |
| B-22 | ✅ | `auth/data/pin_hasher.dart` (`inspection_pin_verifier.dart:14`) | `core/security/pin_hasher.dart` |
| B-23 | ✅ | `profile/presentation/widgets/{app_back_button,settings_card}.dart` (`eld_device`, `diagnostics` ishlatadi) | `core/ui/components/` |
| B-24 | ✅ | `LogsSession` → `core/session/session_context.dart`, **`SessionContext` deb nomlandi** (`features/auth` dagi `DriverSession` bilan to'qnashmasligi uchun) | `core/session/` |
| B-25 | ⬜ | `diagnostics/data/network_probe.dart` → `profile/data/api_providers.dart` | — |
| B-26 | ⬜ | `inspection/.../inspection_providers.dart` → `auth/data/auth_providers.dart` | — |

---

## 4. Dublikat kod

| ID | Holat | Muammo |
|---|---|---|
| B-30 | ✅ | 🔴 **HOS parity riski:** `logs/domain/log_models.dart:28 DutyStatusCode` — `hos_engine` dagi `DutyStatus` ning aynan nusxasi (bir xil 4 qiymat, `wire`, `fromWire`). Ikki manba ajralib ketsa Go↔Dart pariteti buziladi. |
| B-31 | ✅ | `slotOf` (`log_duty_grid.dart:38`) va `dutySlotOf` (`inspection_widgets.dart:22`) — B-30 dan kelib chiqqan ikki nusxa. |
| B-32 | ✅ | 🔴 **Vaqt mintaqasi nomuvofiqligi (M42):** `_startOfDay` (certify + logs) qurilma TZ sida hisoblaydi, `core/time/day_boundary.dart` esa Home Terminal TZ da. Kun chegarasi ikki xil chiqadi. |
| B-33 | ✅ | `DriftSignatureStore.enqueue` (`certify_repository_impl.dart:203`) va `DvirFileRepository.enqueueSignature` (`dvir_file_repository.dart:82`) — bir xil `<docs>/signatures/<uuid>.png` + `files_queue`. Ikkalasi `core/files/` ga birlashtirilsin. |
| B-34 | ✅ | 3 ta bir xil `YYYY-MM-DD` formatter → `core/time/day_boundary.dart#formatLogDate`. |

---

## 5. Ulanmagan / o'lik provayderlar

| ID | Holat | Muammo |
|---|---|---|
| B-40 | ✅ | **Android foreground service hech qachon ishga tushmaydi** — `backgroundCoordinatorProvider.start()` ni hech kim chaqirmaydi. |
| B-41 | ✅ | `background_providers.dart:31-32` bildirishnoma kanali nomi/tavsifi **hard-coded ingliz matni**; `35_eld.arb` dagi `eldServiceChannelName`/`Description` ishlatilmaydi. |
| B-42 | ✅ | `kv_settings` kalitlari hech qayerda yozilmaydi (`driver_id`, `unit_number`, `vehicle_label`, `driver_name`, `carrier_name`, `home_terminal_address`) → Home doim «No unit assigned», oflayn Inspection Log Form da `N/A`. |
| B-43 | ✅ | `logsSessionProvider` = `UnimplementedError` — bootstrap override kutmoqda. |
| B-44 | ✅ | `notificationsDioProvider`, `chatDioProvider`, `currentDriverIdProvider` — bootstrap override kutmoqda. |
| B-45 | ✅ | `drivingModeSourceProvider` = `InMemoryDrivingModeSource` — `duty_status` ning haqiqiy DR holatiga ulanmagan (M140). |
| B-46 | ⬜ | **`flutter_local_notifications` paketi `pubspec.yaml` da yo'q** → M62 idle ogohlantirishi, HOS warning, ELD uzilishi va malfunction bildirishnomalari amalda **ko'rsatilmaydi**. Matn va `LocalAlertRequest` tayyor, faqat paket va implementatsiya kerak. |
| B-47 | ✅ | `DriveModeController.alertTitle/alertBody` bo'sh — `app.dart` da `context.l10n.idleAlertTitle/idleAlertBody` bilan to'ldirilishi kerak. |
| B-48 | ✅ | **Auto-DR faqat Home ekranida ishlaydi** — `driveModeControllerProvider` ni faqat Home tinglaydi; boshqa tab'larda ishlashi uchun shell/bootstrap'da global `ref.listen` kerak. |
| B-49 | ✅ | Tema va Zoom tanlovi `kv_settings` ga saqlanmaydi (`theme_controller.dart:38,43,54`) — ilova qayta ochilganda yo'qoladi (M94). |
| B-50 | ⬜ | `NotificationPrefs` `kv_settings` ga yozilmaydi (`TODO(M11-5)`). |

---

## 6. Dizayn / Figma pariteti

| ID | Holat | Muammo |
|---|---|---|
| B-60 | 🔴❓ | **D-26 — shrift oilasi noaniq.** Ekranlarda 10+ oila: Plus Jakarta Sans 50%, Product Sans 18%, Satoshi 15%, Inter 12%, IBM Plex Sans atigi 2% — qo'llanma esa IBM Plex Sans deydi. `assets/fonts/` bo'sh. Hal bo'lgach **barcha goldenlar qayta yaratiladi**. |
| B-61 | ❓ | **DVIR va Inspection oqimlarining dark maketlari Figma da umuman yo'q** — dark tokenlar orqali hosil qilindi va goldenlar bilan qotirildi. Dizayner tasdig'i kerak. |
| B-62 | ✅ | **M-18 Permissions:** Figma `1107-2310` da har qatorda leading ikonka bor (location pin, location-target, bluetooth, bell) — implementatsiyada ikonka yo'q. |
| B-63 | ✅ | **M-47 Check Network:** Figma `1122-319` da tugma to'q `#1F2126`, implementatsiyada `AppButton.primary` (brend qizil). |
| B-64 | ✅ | **Planshetda max-width yo'q** — ekran tanasi 1366 dp bo'ylab cheklovsiz cho'ziladi (loyiha bo'ylab umumiy naqsh). |
| B-65 | ❓ | **M-50 Support:** Figma `Add Ticket` ni FAB qilib beradi, TZ «clicking button below» deydi — pastdagi to'liq kenglikdagi tugma tanlandi. |
| B-66 | ❓ | **M-43 sana formati:** dizayn `May 28, 2025`, M91 esa `EEE, MMM d` (`Mon, Sep 7`) — M91 olindi. |
| B-67 | ❓ | **M-12:** Figma telefonda ham 4 ta HOS halqasi beradi, dizayn tizimi M87 esa chiziqli indikator talab qiladi — chiziqli tanlandi. |
| B-68 | ✅ | **M65 bajarilmadi** — `core/ui/DutyGrid24h` segment ustidagi `PC`/`YM` yorliqlarini qo'llab-quvvatlamaydi. |
| B-69 | ❓ | D-27 (mobilda faqat 10/12/14/16 pt, qo'llanmadagi 20–48 pt uchramaydi) · D-28 (lineHeight ning 54% i `AUTO`) · D-29 (ranglarning 37% i tokenlarda yo'q — 71 hex vs 36 token). |
| B-70 | ✅ | `network_gauge.dart:38` bo'sh qiymat uchun `'—'`, M92 esa `N/A` (`AppFormats.orNa`) talab qiladi — o'zgartirish goldenni qayta yozadi. |

---

## 7. Kirish imkoniyati

| ID | Holat | Muammo |
|---|---|---|
| B-80 | ✅ | `core/ui/AppChip` balandligi **34 dp** — teginish o'lchami talabini (≥48 dp) buzadi. |

---

## 8. Yetishmayotgan infratuzilma

| ID | Holat | Muammo |
|---|---|---|
| B-90 | ✅ | **`eld_api` generatsiya qilinmagan** (CR-M05) — `openapi-generator` lokalda o'rnatilmagan (`brew install openapi-generator`). `pubspec.yaml` da izohda. |
| B-91 | ⬜ | `url_launcher` yo'q — `User Manual`, `Update` (store) va tashqi havolalar ishlamaydi (`TODO(M11-4)`), hozir snackbar. |
| B-92 | ✅ | iOS `Podfile` hali yaratilmagan — birinchi `flutter build ios` da paydo bo'ladi, o'shanda `platform :ios, '15.0'` qo'yilishi kerak. |
| B-93 | ✅ | `flutter build apk --debug` **yashil**. Yo'lda bloklovchi topildi va tuzatildi: `flutter_secure_storage` AAR `compileSdk ≥ 37` talab qiladi, `flutter.compileSdkVersion` 36 beradi → `build.gradle.kts` da `compileSdk = maxOf(37, …)`. ⚠️ Qolgan ogohlantirish: `firebase_core` hali KGP qo'llaydi, kelajakdagi Flutter versiyalarida yiqiladi. `build ios` yurgizilmagan (`pod install` kerak). |
| B-94 | ⬜ | **23 ta o'lik ARB kaliti** (`35_eld` 7, `40_dvir` 3, `45_inspection` 2, `60_logs` 12). Ba'zilari (`certifySignatureRequired`, `logsGridSemantics`, `inspectionKioskExpired`) **yo'q qilingan UI yoki validatsiyani** anglatishi mumkin — o'chirishdan oldin tekshirilsin. |
| B-95 | ⬜ | **M136 `Insert/Edit duty status` formasi** — TZ da 🎨, registrda ekran ID si yo'q. Domen + repozitoriy metodi yozilgan, UI yo'q: `M-23` dagi `✎` hozircha M-25 sheetini ochadi. |
| B-96 | ⬜ | `golden_toolkit` discontinued → `alchemist` ga o'tildi (CR-M02), lekin goldenlar `test_goldens/features/<mod>/goldens/ci/` ga tushdi — yagona joyda emas. |

---

## 9. Sinalmagan (haqiqiy qurilma kerak)

| ID | Holat | Muammo |
|---|---|---|
| B-100 | ❓ | **❓M80** — ELD vendori va SDK si noma'lum. `BleEldTransport` va `EldGattProfile.provisional` UUID lari **real qurilmada sinalmagan**. |
| B-101 | ❓ | **❓M184** — Firebase loyihasi / APNs sertifikatlari kimda. `firebase_core`/`firebase_messaging` ulanmagan, `MockPushGateway` ishlaydi. |
| B-102 | ⬜ | Android FGS, iOS `CBCentralManagerOptionRestoreIdentifierKey` state restoration, `permission_handler` oqimi — unit testlar `Noop`/`Mock` bilan, haqiqiy qurilmada sinalmagan. |
| B-103 | ❓ | **❓M76** — `Check Network` MVP da `GET /app/config` javob vaqti bo'yicha taxminiy (`approx.` yorlig'i); test endpoint'i uchun CR kerak. |

---

## 10. Ochiq savollar (buyurtmachi javobi kerak)

| ID | Savol |
|---|---|
| B-110 | **❓M117** — Privacy Policy / Terms matni manbai. Figma dagi matn **boshqa mahsulotdan** ("Jusoor", Saudi Arabia), ishlatilmadi; ekranda placeholder + support havolasi. |
| B-111 | **❓M182 / M185** — Play Console va App Store Connect akkauntlari. |
| B-112 | **❓M83** — Product Sans litsenziyasi (yo'q bo'lsa IBM Plex Sans Bold). B-60 bilan bog'liq. |
| B-113 | **CR-M03** — Flutter 3.44.8 da qolinadimi yoki 3.47.2 ga ko'tariladimi (riverpod/drift/build_runner versiyalarini ochadi). |

---

## 11. Loyiha bo'ylab tuzoqlar (yangi kod yozganda hisobga ol)

1. **`find.byType(AppButton)` ishlamaydi** — `AppButton.primary/secondary/text` yopiq subklass qaytaruvchi fabrika konstruktorlari. `find.bySubtype<AppButton>()` ishlat.
2. **Drift `watch()` ni `testWidgets` tanasida `await …first` qilma** — `fakeAsync` zonasida deadlock. `tester.runAsync(...)`.
3. **Riverpod 3: `AsyncValue.when` xato holatini yashiradi** — `defaultRetry` `Exception` (=`ApiError`) da retry qo'yadi → `AsyncLoading(retrying:true)` → `when` `loading()` qaytaradi, `ErrorState` hech qachon chiqmaydi. `core/ui/async_view.dart#asyncView` ishlat.
4. **`LoadingSkeleton` (ichida `ListView`) `SingleChildScrollView` ichida** «unbounded height» beradi — `SizedBox(height:)` bilan chegarala.
5. **Riverpod 3 da controller `build()` ichida `state` ga yozish** `Bad state: uninitialized provider` beradi; dispose'dan keyin yozishga `ref.mounted` gardi kerak.
6. Har test fayl boshiga **`@Timeout(Duration(seconds: 60))`** — CI osilib qolmasin.

---

## 12. Xavfsizlik auditi (2026-09-08, `mobile-security-auditor`)

**A7 mezoni bajarilmayapti: Critical = 1, High = 6.**

| ID | Holat | Muammo · `fayl:qator` | Nega xavfli |
|---|---|---|---|
| S-C1 | ✅ | **Leave Truck PIN qulfi RAM da** — `auth_repository_impl.dart:43,178` (`bool _paused`) saqlanmaydi; `:100` bootstrap `_paused=false` ko'radi → `splash_screen.dart:60` to'g'ri `home` ga | «Leave Truck» dan keyin ilovani o'ldirib qayta ochish **PIN ni butunlay chetlab o'tadi** (M18 / §4.8) |
| S-H1 | ✅ | **Kiosk chiqish PIN i fail-open** — `inspection_pin_verifier.dart:37-40`: `readPin()==null` → istalgan PIN uchun `true` | Inspektor kiosk'dan chiqib butun ilovaga kiradi |
| S-H2 | ✅ | **`upload_url` validatsiyasiz** — `core/files/file_upload.dart:107-109`: `Uri.parse` + interceptorsiz `Dio()` | Buzilgan presign javobi imzo PNG va DVIR fotolarini ixtiyoriy hostga yuboradi (SSRF + PII) |
| S-H3 | ✅ | **Release APK debug kalit bilan imzolanadi** — `android/app/build.gradle.kts:34` | Repackaging, soxta yangilanish |
| S-H4 | ✅ | **`allowBackup` cheklanmagan** — `AndroidManifest.xml:51-54` | Auto Backup imzo, foto va DB ni Google Drive'ga chiqaradi (MASVS STORAGE-8) |
| S-H5 | ✅ | **`FLAG_SECURE` / snapshot himoyasi** — platforma tomoni ✅ (Kotlin `MethodChannel` + iOS `ScreenSecurityPlugin` blur overlay). **Dart tomoni qolgan:** kanal `uz.stackyard.eld_mobile/screen_security`, `setSecure(bool)`→`null` (argument to'g'ridan-to'g'ri bool), `isSecure()`→`bool`; iOS event kanali `…/screen_security_events` → `screenshotTaken`/`screenRecordingStarted`/`screenRecordingStopped`. Wrapper `core/security/screen_protection.dart`; `setSecure(true)` M-04/M-05/M-08/M-30/M-38 `initState` da, `false` `dispose` da | M-04 PIN, M-08 2FA, M-30 Sign skrinshot va app-switcher snapshot'ida qoladi (M157/M158) |
| S-H6 | ✅ | **Pinning bayrog'i yolg'on** — `core/config/env.dart:39,75`: prod `ENABLE_CERT_PINNING=true`, lekin kodda ishlatuvchi yo'q | Konfiguratsiya himoya bor deb ko'rsatadi, aslida pinning yo'q (M153) |
| S-M1 | ✅ | SQLCipher bayrog'i tekshiruvdan **oldin** yoziladi — `core/db/database_bootstrap.dart:74` | Cipher-siz build `cipher_ready='1'` qoldiradi → migratsiya bo'lmaydi, cipher'li build `SQLITE_NOTADB` bilan yiqiladi |
| S-M2 | ✅ | Imzo/DVIR fayllari `getApplicationDocumentsDirectory()` da — `dvir_file_repository.dart:43` (§17.1 `app_support` talab qiladi) | iCloud backup'ga tushadi |
| S-M3 | ✅ | Deep link marshrut oq ro'yxati yo'q — `notification_deeplink.dart:63-75`; manifestda `android:host` yo'q (`AndroidManifest.xml:81`) | M162 |
| S-M4 | ✅ | Logout lokal bazani to'liq tozalamaydi — `secure_vault.dart:191-195`; `chat_dao`/`dvir_dao`/`files_queue` `driver_id` bo'yicha filtrlanmagan | Boshqa haydovchi oldingi ma'lumotni ko'radi |
| S-M5 | ✅ | Ortiqcha ruxsatlar — `SCHEDULE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`, `RECEIVE_BOOT_COMPLETED` (receiver e'lon qilinmagan) | Play siyosati |
| S-M6 | ✅ | `usesCleartextTraffic="false"`, `networkSecurityConfig`, iOS ATS bloki yo'q | §17.7 |
| S-M7 | ✅ | `packages/eld_api/lib/src/api.dart:42,54` o'z `Dio` ini quradi → `core/network` interceptorlarini chetlab o'tadi | Auth, maskalash, idempotentlik yo'qoladi |
| S-M8 | ⬜ | Sentry ulanmagan, `Env.sentryDsn` ishlatilmaydi → `beforeSend` PII filtri yo'q (M160) | — |
| S-L1 | ✅ | Kichik: `location_models.dart:49` `toString()` to'liq aniqlikda lat/lng (M159: 1 kasr) · `logging_interceptor.dart:22` `X-Device-Id` maskalanmaydi · `sync_side_channel.dart:130` payload o'zgartirilmasdan (mass-assignment) · `database_bootstrap.dart:120` ochiq matnli fayl oddiy `delete` · M147 foto siqish (≤1600 px, JPEG 80, Isolate) bajarilmagan | — |

**Tekshirilgan va toza:** `print`/`debugPrint` 0 · `http` paketi yo'q · hard-coded sir yo'q · access token faqat RAM · refresh rotatsiyasi va slot-mutex to'g'ri · PIN PBKDF2-SHA256 100k + 32-bayt salt + constant-time · lockout secure storage'da · `Idempotency-Key`/`client_id` = `Random.secure()` UUIDv4 · `company_id` hech bir DTO da yo'q (M164) · EXIF GPS tozalash qo'llanadi · `eld_api` da `validateCertificate:false` yo'q · router `redirect` deep link'ni ham qo'riqlaydi.

**MASVS L1:** STORAGE ❌ · CRYPTO ✅ · AUTH ❌ · NETWORK 🔄 · PLATFORM ❌ · CODE ❌

---

## 13. Ikki sessiya (co-driver) — M10 dan chiqqan

| ID | Holat | Muammo |
|---|---|---|
| B-120 | ✅ | **Outbox `session_slot` bo'yicha filtrlanmaydi** — `OutboxDao.dueItems`/`dueRecords` slotni hisobga olmaydi, push ishchisi **ikkala haydovchining yozuvlarini bitta (faol) token bilan** yuboradi. Slot bo'yicha guruhlash va har guruhni `RequestExtra.slot` bilan yuborish kerak. |
| B-121 | ✅ | `OutboxRepository.enqueue*` `sessionSlot: 0` standart qiymati bilan chaqiriladi — faol slotni `activeSlotHolderProvider` dan olishi kerak. |
| B-122 | ✅ | `device_seq` (`settingsDao.nextDeviceSeq`) qurilma bo'yicha yagona — TZ talabiga mos, o'zgarish kerak emas. |
| B-123 | ❓ | **Figma da planshet freymlari eksport qilinmagan** — `MAP.md` faqat 393 dp mobil freymlarni qamraydi; `png_ref/` da `1470:*`, `1517:*`, `2142:*` yo'q. T-01/T-07/T-08 `tz-mobile.md` §11.11 ASCII sxemasi asosida qurildi. **A12 planshet uchun tasdiqlanmaydi** — dizaynerdan planshet eksporti kerak. |
| B-124 | ❓ | **Co-driver kontrakt cheklovi** — `/me` javobida co-driver maydoni yo'q; `GET /drivers/{id}/co-drivers` `drivers.read` talab qiladi (haydovchida bo'lmasligi mumkin). M-20 butunlay sessiya slotlariga qurildi (§3.3 modeli); M11 dagi «`co_driver` biriktirilgan bo'lsa» sharti server ma'lumotisiz tekshirilmaydi. |
| B-125 | ⬜ | **Kiosk (M169) bajarilmadi** — Android lock task (`startLockTask` platform channel + `MainActivity.kt`) va iOS Guided Access onboarding. Dart tarafi ham yo'q. |

---

## 14. Ulanmagan qoldiqlar (agentlar hududidan tashqarida qolgan)

| ID | Holat | Muammo |
|---|---|---|
| B-130 | ✅ | **`SessionDataCleaner` hech qayerdan chaqirilmaydi** — `features/auth/data/session_manager.dart` da `signIn` (yangi `driver_id` ma'lum bo'lgach) va `signOut` da `await cleaner.switchDriver(driverId: ...)` kerak. Ulanmaguncha boshqa haydovchi oldingi haydovchining loglarini/chatini ko'radi (S-M4 amalda ishlamaydi). |
| B-131 | ✅ | `core/config/env.dart` da `Env.validate()` ga `CertificatePinning.validate()` qo'shilmagan va `env/prod.json` da `CERT_SPKI_PINS` yo'q → **prod build ataylab `StateError` bilan to'xtaydi**. Pin qiymatlari sertifikatdan olinishi kerak. |
| B-132 | ✅ | `AndroidManifest.xml` da `android:host="eld.stackyard.uz"` va iOS associated domains yo'q (deep link Dart tomoni tayyor). |
| B-133 | ✅ | `core/ui` da `modalPane()` helperi yo'q — `TabletModal` da `Material` ajdodi bo'lmagani uchun 7 ta modal faylida bir xil o'ram takrorlanadi. |
| B-134 | ❓ | **M122 to'liq emas** — planshet modallari sarlavhasida `Cancel` bor, o'ngdagi asosiy amal tugmasi tana ichida qolgan. Qat'iy M122 uchun `TabletModal` ga amal `VoidCallback` ni ko'taruvchi API kerak. |
| B-135 | ❓ | TZ noaniqligi: registrda T-* «modal» deb yozilgan, lekin M-46/M-47/M-18 §11.1 da to'liq marshrutli ekran. Ikkalasi ham saqlandi — qaysi biri kanonik ekani aytilmagan. |
| B-136 | ✅ | `slotTokenProbeProvider` o'z `SecureVault()` nusxasini quradi; `main.dart` da bir qatorlik override bilan umumiy vault'ga bog'lash tavsiya etiladi. |
| B-137 | ⬜ | Pull faqat faol slot nomidan ketadi — co-driver ko'zgusi u faol bo'lgunicha yangilanmaydi (M31 bo'yicha xavfsiz, lekin ikki slotli pull kerak bo'lishi mumkin). |
| B-138 | ✅ | `lib/l10n/generated/*` `dart format` dan o'tmagan holda generatsiya qilinadi → CI `format` job'i vaqti-vaqti bilan qizaradi. `merge_arb.sh` yoki gen qadamidan keyin format chaqirilsin. |
| B-139 | ✅ | M-30 Sign (`certify`) va M-38 kiosk (`inspection`) ekranlariga `SecureScreenMixin` ulanmagan (wrapper tayyor, DI da). |
