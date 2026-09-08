// Port of backend/internal/hos/split.go (Q10.6).
import 'package:meta/meta.dart';

import 'policy.dart';

/// One continuous run of OFF/SB segments (PC counts as OFF).
@immutable
class RestPeriod {
  const RestPeriod({
    this.start,
    this.end,
    this.total = Duration.zero,
    this.longestSb = Duration.zero,
  });

  final DateTime? start;
  final DateTime? end;
  final Duration total;

  /// Longest uninterrupted SB run inside the rest.
  final Duration longestSb;

  /// Go: `RestPeriod.IsDailyRest` — the rest alone resets SHIFT and DRIVE
  /// (Q10.3).
  bool isDailyRest(HosPolicy p) => total >= p.dailyRest;

  RestPeriod copyWith({DateTime? start, DateTime? end, Duration? total, Duration? longestSb}) =>
      RestPeriod(
        start: start ?? this.start,
        end: end ?? this.end,
        total: total ?? this.total,
        longestSb: longestSb ?? this.longestSb,
      );

  @override
  String toString() => 'RestPeriod(total: $total, longestSb: $longestSb)';
}

/// Go: `splitEnabled` — may sleeper split be applied at all (Q4.3, Q10.6)?
bool splitEnabled(HosPolicy p) => p.sleeperSplitEnabled && p.sleeperBerthAvailable;

/// Go: `IsSplitLong` — can the rest act as the long part of a sleeper split,
/// i.e. at least 7h of uninterrupted sleeper berth (Q10.6)?
bool isSplitLong(RestPeriod r, HosPolicy p) {
  if (!splitEnabled(p)) return false;
  return r.longestSb >= const Duration(minutes: splitMinSleeperMin);
}

/// Go: `IsSplitShort` — can the rest act as the short part, i.e. at least 2h of
/// OFF/SB but less than a full daily rest (Q10.6)?
bool isSplitShort(RestPeriod r, HosPolicy p) {
  if (!splitEnabled(p)) return false;
  return r.total >= const Duration(minutes: splitMinPartnerMin) && r.total < p.dailyRest;
}

/// Go: `SplitPairQualifies` — are two rest periods together equivalent to a
/// daily rest: total >= `daily_rest_min`, one part >= 7h SB, the other >= 2h.
/// This covers the 7/3 and 8/2 combinations (Q10.6). Order does not matter.
bool splitPairQualifies(RestPeriod a, RestPeriod b, HosPolicy p) {
  if (!splitEnabled(p)) return false;
  const partner = Duration(minutes: splitMinPartnerMin);
  if (a.total < partner || b.total < partner) return false;
  if (a.total + b.total < p.dailyRest) return false;
  const sleeper = Duration(minutes: splitMinSleeperMin);
  return a.longestSb >= sleeper || b.longestSb >= sleeper;
}
