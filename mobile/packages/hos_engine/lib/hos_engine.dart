/// Pure Dart port of the Go `backend/internal/hos` Hours of Service engine
/// (TZ A§3, A§4, A§12 · tz-mobile §8, M44).
///
/// The package is pure: no Flutter, no I/O, no global state and it never calls
/// `DateTime.now()` — the evaluation instant is always a parameter. Both
/// implementations must pass `backend/internal/hos/testdata/hos-test-vectors.json`
/// (Q10.8, M173).
///
/// The caller is responsible for initialising the IANA database once
/// (`package:timezone/data/latest.dart` → `initializeTimeZones()`); the engine
/// itself only accepts a `tz.Location` parameter and stores nothing.
library;

export 'src/compute.dart'
    show
        HosState,
        Segment,
        clampDur,
        computeCounters,
        dayTotals,
        daySegments,
        minDur,
        overlapAfter,
        sortedEvents,
        utcOf,
        walkSegments;
export 'src/cycle.dart' show RecapDay, cycleUsedAt, lastRestartEnd, recap;
export 'src/day.dart' show addDays, cycleWindowStart, dayKey, dayRange, startOfDay;
export 'src/model.dart'
    show
        DayTotals,
        DutyStatus,
        EventType,
        HosCounters,
        HosEvent,
        HosException,
        HosViolation,
        Severity,
        Special,
        ViolationType;
export 'src/policy.dart'
    show
        HosPolicy,
        WarningThresholds,
        defaultPolicy,
        parsePolicy,
        splitMinPartnerMin,
        splitMinSleeperMin;
export 'src/special.dart'
    show
        countsAsDriving,
        countsAsOnDuty,
        effectiveStatus,
        normalizeStatus,
        shouldExitYardMove,
        shouldStartDriving,
        specialAllowed;
export 'src/split.dart'
    show RestPeriod, isSplitLong, isSplitShort, splitEnabled, splitPairQualifies;
export 'src/violations.dart'
    show exceedAt, formManner, laterOf, overlapRange, reachAt, violationOrder, violations;
