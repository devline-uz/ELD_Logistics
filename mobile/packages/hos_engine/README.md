# hos_engine

Go `backend/internal/hos` paketining **sof Dart** porti (tz-mobile §8, M44).
Natija Go bilan bit-ma-bit bir xil: ikkala tomon ham
`backend/internal/hos/testdata/hos-test-vectors.json` dagi **35 ta** golden
vektordan o'tadi (Q10.8, M173).

## Qat'iy shartlar
- `flutter` bog'liqligi **yo'q** (`dependencies`: faqat `meta`, `timezone`).
- `dart:io` / `dart:ui` / HTTP / DB / fayl I/O **yo'q**, global holat **yo'q**.
- `DateTime.now()` **yo'q** — hisoblash payti har doim parametr.
- Barcha funksiyalar sof: kirish ro'yxati hech qachon o'zgartirilmaydi.
- Kun chegarasi — Home Terminal TZ (`package:timezone`), DST bilan (23h/25h).

Chaqiruvchi IANA bazasini bir marta ishga tushiradi:
```dart
import 'package:timezone/data/latest.dart' as tzdata;
tzdata.initializeTimeZones();
final loc = tz.getLocation('America/Chicago');
```

## Eksport API (Go → Dart)
| Go | Dart |
|---|---|
| `Status` / `Special` / `EventType` | `DutyStatus` / `Special` / `EventType` |
| `Event` | `HosEvent` (`fromJson`, `fromDutyStatusEventJson`) |
| `Policy`, `DefaultPolicy`, `ParsePolicy` | `HosPolicy`, `defaultPolicy()`, `parsePolicy()` |
| `Counters`, `DayTotals`, `Violation`, `RecapDay` | `HosCounters`, `DayTotals`, `HosViolation`, `RecapDay` |
| `Compute` | `computeCounters(events, policy, now, location)` |
| `DayTotalsFor` / `DayTotalsWith` | `dayTotals(events, day, location, {policy})` |
| `Violations` | `violations(events, policy, day, location)` |
| `Recap` | `recap(events, policy, day, location)` |
| `CycleUsedAt` / `LastRestartEnd` | `cycleUsedAt` / `lastRestartEnd` |
| `StartOfDay` / `DayRange` / `DayKey` / `CycleWindowStart` | `startOfDay` / `dayRange` / `dayKey` / `cycleWindowStart` |
| `EffectiveStatus` / `CountsAsDriving` / `CountsAsOnDuty` | bir xil, `lowerCamelCase` |
| `ShouldStartDriving` / `ShouldExitYardMove` / `SpecialAllowed` | bir xil |
| `IsSplitLong` / `IsSplitShort` / `SplitPairQualifies` | bir xil |
| `FormManner` | `formManner(hasTrailer:, hasDoc:, certified:)` |
| `ErrUnknownStatus` / `ErrUnknownSpecial` | `HosException` |

JSON kalitlari `contracts/swagger.json` bilan 1:1:
`duty_dto.Counters`, `duty_dto.DayTotals`, `duty_dto.RecapDay`,
`duty_dto.Violation`, `company_dto.HosPolicyDoc`.

## Skriptlar
```
tool/sync_vectors.sh       # vektor faylini olib keladi + SHA-256 qulfi (M174)
tool/check_no_flutter.sh   # M44 tekshiruvi
tool/bench.dart            # 14 kunlik to'liq qayta hisoblash vaqti (<=50 ms)
tool/ci_hos_parity.sh      # CI job `hos-parity` ning Dart yarmi
```
