---
name: flutter-testing
description: ONEBOOK ELD mobil ilovasi uchun test piramidasi, HOS golden vektorlar, golden (vizual) testlar, IT-1…IT-15 integration stsenariylari, chaos test, NFR o'lchovlari, CI job'lari va mock strategiyasi. Test yozayotganda yoki CI job sozlayotganda majburiy.
---

# ELD Mobile — testlash konventsiyalari (tz-mobile.md §19–§20)

Qoida: **o'lchanmagan NFR — bajarilmagan** (M172). **Bitta xato golden vektor — bosqich yopilmaydi** (M173).

## 1. Test piramidasi
| Daraja | Qamrov | Vosita | Coverage |
|---|---|---|---|
| Unit — HOS | 35/35 golden vektor `[MUST]` | `packages/hos_engine/test/golden_vectors_test.dart` | **≥95%** |
| Unit — sync | batch bo'lish, idempotency, 5 konflikt qoidasi, backoff, kursor | `packages/sync_core/test/` | **≥90%** |
| Unit — domen | TimeSource, PIN hash, fayl navbati, DVIR holat mapping (M102), duty validatsiya | `test/` | — |
| DB | drift migratsiyalari (har versiya), CRUD, outbox tranzaksiya atomikligi | in-memory SQLite | — |
| Widget | har ekran: yuklanish / bo'sh / xato / to'la holat | `flutter_test` | — |
| Golden | har asosiy ekran × {light, dark} × {phone, tablet} | `golden_toolkit` | — |
| Integration | to'liq oqimlar (IT-1…IT-15) | `integration_test` + `patrol` `[MAY]` | — |
| Chaos | tarmoq uzilishi, ilova o'ldirilishi, soat siljishi | maxsus harness | — |

Umumiy loyiha coverage **≥70%**. Widget/golden testlar coverage'ga hisoblanadi, lekin
`hos_engine` va `sync_core` chegaralarini pasaytirishga asos bo'lmaydi.

## 2. HOS golden vektorlar — eng qattiq talab
- **M173** `golden_vectors_test.dart` `backend/internal/hos/testdata/hos-test-vectors.json` ni o'qiydi
  va har 35 vektor uchun `counters`, `totals`, `violations` ni solishtiradi.
- **M174** Fayl repoga **nusxalanmaydi**: CI da backend repodan olinadi (`curl` yoki submodule),
  **SHA-256 hash** tekshiriladi. Hash mos kelmasa build ogohlantirish bilan to'xtaydi — kontrakt
  o'zgarishi CR talab qiladi.
- **M175** CI job `hos-parity`: `go test ./internal/hos` **va** `dart test packages/hos_engine`
  ikkalasi ham o'sha faylda yashil bo'lishi shart.
- `packages/hos_engine` — faqat Dart stdlib; Flutter/IO/DB import qilinmaydi (Go porti bilan parite).

## 3. Golden (vizual) testlar
**M176** Har asosiy ekran uchun **4 ta golden**: `{light, dark} × {phone 393×852, tablet 1366×1024}`.

```dart
// test/flutter_test_config.dart
Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    testAppFonts(testMain);            // loadAppFonts() — repodagi shriftlar

const phone  = Device(name: 'phone',  size: Size(393, 852),   devicePixelRatio: 3.0);
const tablet = Device(name: 'tablet', size: Size(1366, 1024), devicePixelRatio: 2.0);
final goldenDevices = [
  phone,  phone.copyWith(name: 'phone_dark',  brightness: Brightness.dark),
  tablet, tablet.copyWith(name: 'tablet_dark', brightness: Brightness.dark),
];
```
Qoidalar:
- `loadAppFonts()` majburiy — **tizim shriftiga tayanilmaydi** (CI da Ahem chiqadi).
- Test `@Tags(['golden'])` bilan belgilanadi (CI da `flutter test --tags golden`).
- Vaqt/UUID/animatsiya deterministik: `TimeSource` mock, `pumpAndSettle`, `Animate.restartOnHotReload=false`.
- Golden fayl nomi: `goldens/<screen>_<light|dark>_<phone|tablet>.png`.
- Alohida `textScaler` chegara testi: `TextScaler.linear(1.3)` (va `2.0` — overflow yo'qligi)
  Home, Change duty status, Drive mode, Log Report ekranlarida — matn kesilmaydi/toshmaydi.

Minimal ro'yxat (har biri 4 golden): Login · Home · Change duty status · Drive mode ·
Log Report (3 tab) · Certify · Sign · Add DVIR · DVIR details · Inspection · Chat ·
Notifications · Profile · Permissions · Pending edits · Sync conflicts.

## 4. Integration stsenariylari (IT-1…IT-15) — hammasi majburiy
| № | Stsenariy |
|---|---|
| IT-1 | login → ELD ulanish (mock) → auto-DR → to'xtash → idle prompt → ON → certify |
| IT-2 | oflayn: 200 event yaratish → onlayn → push → hammasi accepted → 0 yo'qotish |
| IT-3 | konflikt: bir vaqtda ikki event → superseded → M-55 da ko'rinadi |
| IT-4 | log_locked: sertifikatlangan kunga event → rejected → UI xabari |
| IT-5 | pending edit → Approve → kun needs_recertify → qayta certify |
| IT-6 | pending edit DR ni o'zgartiradi → Approve bloklangan (M133) |
| IT-7 | DVIR: defects bilan → submitted_defects_found → keyingi pre-trip da certification modali |
| IT-8 | inspection: Begin → kiosk → PIN bilan chiqish |
| IT-9 | co-driver: ikki login → switch (PIN) → DR faqat active driverga |
| IT-10 | Leave Truck → paused → Return to truck (PIN) → sessiya tiklandi |
| IT-11 | chat: haydash rejimida bloklanish + 409 DRIVING_MODE_BLOCKED → qayta yuborish |
| IT-12 | unidentified: claim → logga qo'shildi |
| IT-13 | soat siljishi: +15 daq → T malfunction banneri |
| IT-14 | force update: min_supported_version > joriy → bloklovchi ekran |
| IT-15 | sessiya almashishi: boshqa telefonda login → M-56 |

Har IT alohida test faylida: `integration_test/it_<n>_<nom>_test.dart`.

## 5. Chaos testlar
- **1000 event + tasodifiy tarmoq uzilishi/ilova o'ldirilishi → 0 event yo'qotish** (NFR).
- Uzilish nuqtalari: outbox yozuvidan keyin/push'dan oldin, push jo'natilgan lekin javob kelmagan
  (idempotency kaliti bo'yicha takror), javob qabul qilingan lekin kursor yangilanmagan.
- Ilova o'ldirilishi: `process.kill` yoki `patrol` orqali; qayta ochilganda outbox tiklanadi.
- Soat o'zgarishi: TimeSource'ga ±15 daq / ±2 soat siljish beriladi → T malfunction, event vaqti buzilmaydi.
- Har chaos yugurish `seed` bilan takrorlanadigan bo'lsin (log'da seed chiqadi).

## 6. NFR o'lchov jadvali (11-bosqichda o'lchanadi, hisobotga yoziladi — M172)
| Ko'rsatkich | Talab | O'lchov usuli |
|---|---|---|
| Cold start → Home | **≤3 s** | Firebase Performance / `TimelineTask`, Pixel 4a / iPhone 11 |
| Haydash rejimiga o'tish | **≤1 s** harakat aniqlangandan | integration test + real qurilma |
| Batareya (BLE+GPS, 8 soat, ekran o'chiq) | **≤25%** | Battery Historian / Xcode Energy Log |
| 14 kunlik oflayn bufer yuklash | **≤60 s** (4G) | sun'iy bufer bilan integration test |
| Ma'lumot yo'qotish | **0 event** | chaos test (1000 event) |
| Status o'zgartirish → UI javobi | **≤200 ms** | lokal yozuv o'lchovi |
| HOS qayta hisoblash (14 kun) | **≤50 ms** | `dart test` benchmark |
| Ro'yxat scroll | **60 fps, jank <1%** | `flutter run --profile` + DevTools |
| Ilova hajmi | **≤60 MB (AAB), ≤80 MB (IPA)** | CI o'lchovi |
| Lokal DB | **≤100 MB (14 kun)** | drift o'lcham testi |
| Kontrast / teginish | **≥4.5:1 / ≥48 dp** | `flutter_test` semantics |

## 7. CI job'lari (GitHub Actions) — M177: merge faqat hammasi yashil bo'lganda
| Job | Buyruq |
|---|---|
| `analyze` | `flutter analyze --fatal-infos` |
| `format` | `dart format --set-exit-if-changed .` |
| `api-gen` | `openapi-generator` → `git diff --exit-code` (generatsiya eskirsa yiqiladi) |
| `l10n` | ARB kalitlari to'liqligi + kodda hard-coded matn yo'qligi |
| `test` | `flutter test --coverage` (≥70% / hos_engine ≥95% / sync_core ≥90%) |
| `hos-parity` | `go test ./internal/hos` + `dart test packages/hos_engine` (35/35) |
| `golden` | `flutter test --tags golden` |
| `build` | `flutter build apk --release` + `flutter build ios --no-codesign` |
| `integration` | (nightly) `flutter test integration_test/` — Firebase Test Lab |

## 8. Mock strategiyasi
- Kutubxona: **`mocktail`** (kod generatsiyasiz). `build_runner` mock uchun ishlatilmaydi.
- `MockEldTransport implements EldTransport` — BLE o'rniga: ulanish/uzilish, frame oqimi,
  `emitFrames(...)`, sun'iy kechikish va CRC xatosi. Real BLE testda **hech qachon** ishlatilmaydi.
- Drift: `NativeDatabase.memory()` — har testda toza DB; migratsiya testlarida versiyama-versiya.
- Motion manbai: `MockMotionSource` — tezlik/harakat profilini beradi (auto-DR, idle prompt, drive mode).
- `TimeSource` — soat siljishi va monotonik vaqtni boshqarish uchun mock (real `DateTime.now()` taqiq).
- Tarmoq: `MockApiClient` yoki `http` MockClient — 200/409/422/429/timeout stsenariylari.
- Har mock `test/mocks/` da bir joyda; `registerFallbackValue` `setUpAll` da.

## 9. Kuzatuv (production) — M178 `[SHOULD]`
Sentry (crash + performance). Maxsus hodisalar: `sync_conflict`, `hos_drift` (M47),
`eld_disconnect`, `push_rejected`, `clock_skew_high`, `battery_drain_high`. Hammasi **PII'siz** (§17.5).

## 10. Definition of Done — test checklisti
- [ ] `flutter analyze --fatal-infos` va `dart format` toza
- [ ] Yangi/o'zgargan domen logikasiga unit test bor
- [ ] Yangi ekranga widget test (4 holat) + **4 golden** (light/dark × phone/tablet) bor
- [ ] Golden'lar `loadAppFonts()` bilan, `@Tags(['golden'])` qo'yilgan
- [ ] `textScaler` 1.3 chegara testi o'tadi (overflow yo'q)
- [ ] HOS tegilgan bo'lsa: 35/35 golden vektor yashil, `hos-parity` yashil, JSON hash tekshirilgan
- [ ] Sync tegilgan bo'lsa: idempotency + 5 konflikt qoidasi + backoff testi bor
- [ ] DB sxema tegilgan bo'lsa: migratsiya testi (eski versiyadan yangiga) bor
- [ ] Tegishli IT-stsenariy yangilangan yoki qo'shilgan
- [ ] Coverage chegaralari pasaymagan (70 / 95 / 90)
- [ ] Testlarda real tarmoq, real BLE, real `DateTime.now()` yo'q
- [ ] Loglar/analitika PII'siz
