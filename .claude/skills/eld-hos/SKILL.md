---
name: eld-hos
description: Hours of Service (HOS) engine qoidalari, hos_policy parametrlari, hisoblash algoritmi, violation turlari va golden test-vektor talabi. internal/hos yoki violation kodi ustida ishlaganda majburiy.
---

# HOS engine (TZ A§3, A§4, A§12)

`internal/hos` — **sof paket**: faqat stdlib, DB/HTTP yo'q, global holat yo'q. Sabab: Flutter/Dart porti bir xil `hos-test-vectors.json` dan o'tishi shart.

## Duty statuslar
`OFF`, `SB`, `DR`, `ON` + `special`: `none | pc | ym`.
- **DR qo'lda tanlanmaydi.** Auto-DR: ECM tezligi ≥ `motion_threshold_kmh` (default 8). ECM yo'q → GPS fallback (`source=gps_fallback`).
- To'xtash: tezlik 0 va ≥3 soniya.
- Idle prompt: 5 daqiqa harakatsizlik → so'rov; `Yes, driving` → DR; `No` yoki 1 daqiqa javobsiz → **ON**, o'tish vaqti = so'rov chiqqan payt.
- Haydashda har **60 daqiqada** `intermediate` event.
- **PC** (`OFF (PC)`): harakat DR emas, OFF hisoblanadi, HOS'ga kirmaydi.
- **YM** (`ON (YM)`): ON hisoblanadi, Drive limitga kirmaydi, Shift'ga kiradi. Tezlik > `ym_max_speed_kmh` (32) → YM tugaydi → DR.
- Unit `sleeper_berth=false` → SB mavjud emas.

## hos_policy (Company darajasida, versiyalangan)
| Kalit | Default |
|---|---|
| `drive_limit_min` | 660 |
| `shift_window_min` | 840 |
| `break_required_after_drive_min` | 480 |
| `break_duration_min` | 30 |
| `break_qualifying_statuses` | `["OFF","SB","ON"]` |
| `daily_rest_min` | 600 |
| `cycle_limit_min` | 4200 |
| `cycle_days` | 8 |
| `cycle_restart_min` | 2040 (`null` = yo'q) |
| `sleeper_split_enabled` | true |
| `allow_pc` / `allow_ym` / `ym_max_speed_kmh` | true / true / 32 |
| `motion_threshold_kmh` | 8 |
| `short_haul_exception` | false (MAY) |
| `adverse_conditions_extension_min` | 120 (MAY) |
| `warning_thresholds` | drive 30, shift 60, break 30, cycle 120 (daqiqa) |

**Q10.1:** policy o'zgarsa `hos_policy_versions` ga `effective_from` bilan yangi yozuv; eski kunlar **o'sha paytdagi** policy bilan hisoblanadi (retroaktiv violation yo'q).

## Hisoblash qoidalari
- **Q10.2 Kun chegarasi:** Daily Log kuni = Home Terminal (Company) timezone'idagi 00:00–24:00. Eventlar UTC saqlanadi, kunga ajratish TZ bo'yicha. TZ kesib o'tish kunni o'zgartirmaydi.
- **Q10.3 SHIFT:** `daily_rest_min` uzluksiz OFF/SB dan keyingi birinchi ON/DR dan boshlanadi; OFF/SB 14h oynani uzaytirmaydi.
- **Q10.4 BREAK:** oxirgi ≥`break_duration_min` uzluksiz qualifying statusdan keyin yig'ilgan DR ≥ `break_required_after_drive_min` bo'lsa → keyingi DR = `break_required` violation.
- **Q10.5 CYCLE:** oxirgi `cycle_days` kun (bugun bilan) ON+DR yig'indisi; `cycle_restart_min` uzluksiz OFF/SB → 0.
- **Q10.6 Sleeper split:** SB ≥7h + OFF/SB ≥2h (yoki 8h+2h/7h+3h; jami ≥10h, biri ≥7h SB) = daily rest ekvivalenti; uzun qism 14h oynani "to'xtatadi" (pauza).
- **Q10.7 Recap:** `recap[d] = cycle_limit − Σ(ON+DR oxirgi cycle_days)`; ertaga qaytadigan soat = `cycle_days` kun oldingi kunning ON+DR.
- **Q10.9** `Driving Time Left = min(DRIVE, SHIFT, CYCLE, BREAK)`.

## Violation / warning turlari
`form_manner_trailer`, `form_manner_doc`, `drive_limit`, `shift_limit`, `break_required`, `cycle_limit`, `uncertified_log`, `unidentified_driving`, `eld_malfunction`, `missing_dvir` (MAY).
- Ikki daraja: `warning` (chegaraga yaqin) / `violation` (oshib ketgan).
- **Violation o'chmaydi** — `resolved_at` + `resolved_reason` bilan yopiladi, tarixda qoladi.
- Yopilish: `break_required` → qualifying break; `drive_limit`/`shift_limit` → daily rest; `cycle_limit` → restart yoki kun tushishi; `form_manner_*` → maydon to'ldirilib qayta sertifikatsiya.
- **Server kanonik** — violation'lar faqat serverda yaratiladi; mobil oldindan ko'rsatadi.

## Paket API (tavsiya)
```go
package hos
type Status string // OFF, SB, DR, ON
type Special string // none, pc, ym
type Event struct { Time time.Time; Status Status; Special Special; Type string }
type Policy struct { /* yuqoridagi kalitlar, daqiqada */ }
type Counters struct { DriveLeft, ShiftLeft, CycleLeft, BreakLeft time.Duration }
type DayTotals struct { Off, SB, Drive, On time.Duration }
func Compute(events []Event, p Policy, now time.Time, loc *time.Location) (Counters, error)
func DayTotalsFor(events []Event, day time.Time, loc *time.Location) DayTotals
func Violations(events []Event, p Policy, day time.Time, loc *time.Location) []Violation
func Recap(events []Event, p Policy, day time.Time, loc *time.Location) []time.Duration
```
Sof funksiyalar; `time.Now()` chaqirilmaydi (har doim parametr).

## Golden vektorlar [MUST]
`internal/hos/testdata/hos-test-vectors.json` — **≥30 ssenariy**: oddiy kun; 11h drive limit; 14h shift; 30-daq break; ON break sifatida; 34h restart; 70/8 va 60/7 cycle; sleeper split 7/3 va 8/2; PC; YM va YM→DR tezlik; TZ o'tishi; DST; kechikkan offline eventlar; admin edit; unidentified assign; qisqa kunlar; hech qanday event yo'q; policy versiyasi o'zgarishi.
Format:
```json
{"name":"drive_limit_exceeded","policy":{...},"timezone":"Asia/Karachi","now":"2026-09-06T18:00:00Z",
 "events":[{"time":"...","status":"DR"}],
 "expect":{"counters":{"drive_left_min":0,"shift_left_min":120,"cycle_left_min":3000,"break_left_min":0},
           "totals":{"off_min":0,"sb_min":0,"drive_min":660,"on_min":0},
           "violations":[{"type":"drive_limit","severity":"violation"}]}}
```
Test `TestGoldenVectors` shu faylni o'qiydi; fayl **Dart tomonida ham ishlatiladi** — shuning uchun format o'zgarsa TZ CR kerak.
