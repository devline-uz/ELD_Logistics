---
name: hos-parity
description: Go `internal/hos` va Dart `hos_engine` orasidagi bit-to-bit moslik shartlari — sof Dart paket qoidalari, API mos kelish jadvali, golden vektor formati, 35/35 talabi va hos-parity CI job. packages/hos_engine yoki golden vektorlar ustida ishlaganda majburiy.
---

# HOS parity: Go ↔ Dart (tz-mobile §8, §20.2)

**Manba:** `tz-mobile.md` §7.3, §8, §20.2 · `.claude/skills/eld-hos/SKILL.md` (algoritm) · `backend/internal/hos/`.
Algoritm qoidalari (Q10.x, Q4.x, policy kalitlari) **`eld-hos`** da — bu skill faqat **moslik** haqida.

## 1. Paketning qat'iy shartlari — M44 [MUST]
`packages/hos_engine` — **sof Dart paket**:
- `pubspec.yaml` da `flutter` bog'liqligi **YO'Q** (`dart pub deps` da ham chiqmasligi kerak — CI tekshiradi)
- `dart:io`, `dart:ui` YO'Q; HTTP/DB/fayl I/O YO'Q; global holat YO'Q
- **`DateTime.now()` YO'Q** — hisoblash payti har doim parametr (`DateTime now`). Go tomonda ham `time.Now()` chaqirilmaydi
- Yagona ruxsat etilgan tashqi paket: `package:timezone` (IANA `Location`, Flutter'ga bog'liq emas)
- Barcha funksiyalar **sof**: bir xil kirish → bir xil chiqish; kirish ro'yxati mutatsiya qilinmaydi
  (Go `TestOutOfOrderEventsAreNotMutated` ning Dart ekvivalenti bo'lishi shart)

### Fayl tuzilmasi
```
packages/hos_engine/
├─ pubspec.yaml                    # flutter YO'Q; dependencies: timezone
├─ analysis_options.yaml           # avoid_dynamic_calls, no DateTime.now() lint
├─ lib/
│  ├─ hos_engine.dart              # yagona public export
│  └─ src/
│     ├─ model.dart                # DutyStatus, Special, HosEvent, HosCounters, DayTotals, HosViolation, RecapDay
│     ├─ policy.dart               # HosPolicy, defaultPolicy(), parsePolicy() (override mexanizmi)
│     ├─ day.dart                  # startOfDay/dayRange/dayKey — Home Terminal TZ, DST
│     ├─ compute.dart              # segmentlar, holat mashinasi, computeCounters()
│     ├─ split.dart                # sleeper split 7/3, 8/2
│     ├─ cycle.dart                # cycle oyna, restart, recap()
│     ├─ special.dart              # PC / YM semantikasi
│     └─ violations.dart           # violations(), FormManner ekvivalenti
└─ test/
   ├─ golden_vectors_test.dart     # 35/35 — hos-test-vectors.json dan o'qiydi (M173)
   ├─ day_boundary_test.dart, split_test.dart, cycle_test.dart, special_test.dart
   └─ benchmark_test.dart          # 14 kun eventlari ≤50 ms
```

## 2. API mos kelish jadvali (Go → Dart)
Nomlar tilga xos (Go `PascalCase`, Dart `lowerCamelCase`), lekin **semantika va JSON kalitlari bir xil**.

| Go (`backend/internal/hos`) | Dart (`hos_engine`) | Izoh |
|---|---|---|
| `type Status string` (`OFF`/`SB`/`DR`/`ON`) | `enum DutyStatus { off, sb, dr, on }` | JSON qiymati **doim** `"OFF","SB","DR","ON"` |
| `type Special string` (`none`/`pc`/`ym`) | `enum Special { none, pc, ym }` | JSON: `"none","pc","ym"`; bo'sh satr = `none` |
| `type EventType string` | `String? type` | `status_change` va bo'sh qiymat duty mashinasiga ta'sir qiladi |
| `Event{Time,Status,Special,Type}` | `HosEvent(time,status,special,type)` | `time` — **doim UTC** |
| `Policy` (daqiqada, `CycleRestartMin *int`) | `HosPolicy` (`int? cycleRestartMin`) | `swagger.json` `sync_dto.HosPolicy` bilan 1:1 |
| `DefaultPolicy()` | `defaultPolicy()` | 70/8: 660/840/480/30/600/4200/8/2040 |
| `ParsePolicy([]byte)` | `parsePolicy(Map<String,dynamic>)` | **defaultlar ustiga override** — qisman hujjat default saqlaydi |
| `Counters{BreakLeft,DriveLeft,ShiftLeft,CycleLeft,DrivingTimeLeft}` — `time.Duration` | `HosCounters(breakLeftMin,driveLeftMin,shiftLeftMin,cycleLeftMin,drivingTimeLeftMin)` — `int` daqiqa | **Go `Duration` → Dart `int` daqiqa**; solishtirish daqiqada |
| `DayTotals{Off,SB,Drive,On}` | `DayTotals(offMin,sbMin,driveMin,onMin)` | `total()` DST kunlarida 23h/25h |
| `Violation{Type,Severity,At}` | `HosViolation(type,severity,occurredAt)` | `type`/`severity` satrlari **aynan** bir xil |
| `RecapDay{Date,OnDuty,Available,GainedNext}` | `RecapDay(date,onDutyMin,availableMin,gainedNextMin)` | Q10.7 |
| `Compute(events,p,now,loc) (Counters,error)` | `computeCounters(events,p,now,tz)` | xato → `HosException` (`ErrUnknownStatus` ekvivalenti) |
| `DayTotalsFor(events,day,loc)` / `DayTotalsWith` | `dayTotals(events,day,tz)` | |
| `Violations(events,p,day,loc)` | `violations(events,p,day,tz)` | |
| `Recap(events,p,day,loc)` | `recap(events,p,day,tz)` | |
| `FormManner(hasTrailer,hasDoc,certified)` | `formManner(...)` | `form_manner_trailer`, `form_manner_doc` |
| `StartOfDay/DayRange/DayKey` | `startOfDay/dayRange/dayKey` | `*time.Location` → `tz.Location` |
| `EffectiveStatus/CountsAsDriving/CountsAsOnDuty` | `effectiveStatus/countsAsDriving/countsAsOnDuty` | PC/YM (Q4.1, Q4.2) |
| `ShouldStartDriving/ShouldExitYardMove` | `shouldStartDriving/shouldExitYardMove` | tezlik chegaralari |
| `IsSplitLong/IsSplitShort/SplitPairQualifies` | `isSplitLong/isSplitShort/splitPairQualifies` | Q10.6 |

Yangi Go funksiyasi qo'shilsa — Dart ekvivalenti **o'sha bosqichda** qo'shiladi, aks holda parity buziladi.

## 3. Golden vektor fayli
**Yagona manba:** `backend/internal/hos/testdata/hos-test-vectors.json` — **35 ta vektor**, `version: 1`.
**M45/M174 [MUST]:** fayl `packages/` ichiga **nusxalanmaydi** — CI da backend repodan `curl`/submodule/symlink bilan olinadi va **SHA-256 hash** tekshiriladi. Hash o'zgargan bo'lsa build **ogohlantirish bilan to'xtaydi**: format ikkala tomonning kontrakti, o'zgarishi **CR talab qiladi**.

```jsonc
{
  "version": 1,
  "vectors": [{
    "name": "drive_limit_violation",          // unikal, snake_case
    "policy": {},                             // DefaultPolicy ustiga override (bo'sh = default)
    "timezone": "America/Chicago",            // IANA, Home Terminal TZ
    "now": "2026-01-16T00:00:00Z",            // RFC3339 UTC — hisoblash payti
    "day": "2026-01-15",                      // ixtiyoriy; yo'q bo'lsa = now ning lokal kuni
    "events": [ {"time":"2026-01-15T12:00:00Z","status":"DR","special":"none","type":"status_change"} ],
    "expect": {
      "counters":  {"break_left_min":0,"drive_left_min":0,"shift_left_min":120,
                    "cycle_left_min":3000,"driving_time_left_min":0},
      "totals":    {"off_min":0,"sb_min":0,"drive_min":660,"on_min":0},
      "violations":[{"type":"drive_limit","severity":"violation"}]
    }
  }]
}
```
Qoidalar: `counters`/`totals` — **butun daqiqa**, aniq tenglik (tolerance YO'Q). `violations` — **tartibi bilan**, `type`+`severity` juftligi. Vektorda ko'rsatilmagan maydon tekshirilmaydi, lekin ko'rsatilgani **majburiy**.

## 4. 35/35 va P5 qoidasi
**M173 [MUST]** `packages/hos_engine/test/golden_vectors_test.dart` har 35 vektor uchun `counters`, `totals`, `violations` ni solishtiradi.
**P5 [MUST]** 3-bosqich: **35/35 golden vektor o'tmaguncha keyingi bosqichga o'tilmaydi. Istisno yo'q.** 34/35 — bosqich yopilmagan. Vektorni o'chirish/`skip` qilish orqali yashil qilish **taqiqlanadi**; nomuvofiqlik topilsa avval qaysi tomon noto'g'ri ekani aniqlanadi (Go kanonik), keyin tuzatiladi.
Alohida test qilinadigan chegaraviy vektorlar (M46): `out_of_order_events`, `open_status_from_previous_day`, `empty_day_no_events`, `consecutive_identical_statuses`, `status_change_at_local_midnight`, `policy_null_cycle_restart`, `no_sleeper_berth_unit`, `dst_spring_forward_23h_day`, `dst_fall_back_25h_day`.

## 5. CI job `hos-parity` — M175 [MUST]
```yaml
hos-parity:
  # 1) vektor faylini backenddan ol (nusxa emas) va hash tekshir — M174
  - fetch backend/internal/hos/testdata/hos-test-vectors.json
  - sha256sum -c hos-vectors.sha256      # farq → build STOP + "kontrakt o'zgardi, CR kerak"
  - go test ./internal/hos               # Go tomoni yashil
  - dart test packages/hos_engine        # Dart tomoni AYNAN shu faylda yashil
  - dart pub deps | grep -q flutter && exit 1   # M44 tekshiruvi
```
Ikkalasi ham yashil bo'lmasa job **fail**. Job PR bloklovchi (required check).

## 6. Kun chegarasi va timezone — M42 [MUST]
- Log kuni = **Home Terminal (Company) TZ** 00:00–24:00 (Q10.2); eventlar UTC saqlanadi.
- **Qurilma TZ hech qachon** kun chegarasi uchun ishlatilmaydi; haydovchi TZ kesib o'tsa kun o'zgarmaydi.
- Mobil TZ ni `/me` → company profili yoki `daily_logs[].timezone` dan oladi, `kv_settings.home_terminal_tz` ga keshlaydi.
- DST kunlari 23/25 soat — `tz.Location` bilan hisoblanadi, `Duration` qo'shish orqali **emas** (`startOfDay` lokal kalendar bo'yicha).
- **M43 [SHOULD]** UI da vaqtlar Home Terminal TZ da; qurilma TZ farq qilsa sarlavhada «Times shown in \<TZ abbr\>».

## 7. Server — kanonik, mobil — ko'rsatuvchi
- **M47 [MUST]** Onlayn holatda `GET /drivers/{id}/hos-summary?date=` javobi **ustun**; ko'rsatiladigan qiymat serverga tenglashtiriladi. Lokal hisob server bilan **>2 daqiqa** farq qilsa — Sentry'ga `hos_drift` hodisasi yoziladi, foydalanuvchiga xato ko'rsatilmaydi.
- **M48 [MUST]** Mobil **violation yaratmaydi**. Oflayn faqat **warning**: «You are approaching your 11-hour driving limit (00:22 left)». Serverdan kelgan `violations[]` aynan `severity` bilan ko'rsatiladi.
- **M50 [MUST]** Lokal warning push: `drive_left ≤ 30`, `shift_left ≤ 60`, `break_left ≤ 30`, `cycle_left ≤ 120` (policy `warning_thresholds` dan). Har chegara **kuniga bir marta**, `hos_state.warned_flags` bilan.
- **Q10.1** Eski kunlar **o'sha paytdagi policy** bilan hisoblanadi — retroaktiv violation yo'q.

## 8. Chastota, benchmark, coverage
| Rejim | To'liq qayta hisoblash |
|---|---|
| Home ekrani ochiq | taymer 1 s, to'liq hisob **30 s** |
| Haydash rejimi | taymer 1 s, to'liq hisob **15 s** |
| Fon | **60 s** (faqat warning chegarasi) |
| Status o'zgarishi / `sync/pull` dan keyin | **darhol** |

- **M49 [SHOULD]** Event soni >2000 bo'lsa to'liq hisob `Isolate.run` (compute isolate) da — UI jerk bermasin.
- **Benchmark [MUST]:** 14 kun eventlarini qayta hisoblash **≤50 ms** (`test/benchmark_test.dart`, CI da o'lchanadi).
- **Coverage [MUST]:** `hos_engine` **≥95%** (umumiy mobil ≥70%, `sync_core` ≥90%).

## Bosqich chiqish mezoni (qattiq)
✅ 35/35 vektor yashil · ✅ coverage ≥95% · ✅ `dart pub deps` da `flutter` yo'q · ✅ `hos-parity` CI yashil (Go va Dart **bir xil** fayldan) · ✅ benchmark ≤50 ms.
