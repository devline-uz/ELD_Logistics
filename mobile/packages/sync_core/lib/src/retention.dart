/// Retention windows and the 100 MB storage budget (§5.2, M23).
library;

import 'package:meta/meta.dart';

/// Cut-off ages per table. All values come from the §5.2 table.
@immutable
class RetentionPolicy {
  const RetentionPolicy({
    this.ackedEventAge = const Duration(days: 30),
    this.sentTelemetryAge = const Duration(hours: 48),
    this.telemetryAge = const Duration(days: 14),
    this.dailyLogAge = const Duration(days: 30),
    this.dvirReportAge = const Duration(days: 30),
    this.chatAge = const Duration(days: 30),
    this.chatMaxMessages = 500,
    this.uploadedFileAge = const Duration(days: 7),
    this.conflictAge = const Duration(days: 7),
    this.notificationAge = const Duration(days: 30),
  });

  /// `duty_events` are deleted only when `sync_state=acked` AND older than this
  /// (M23 — the "0 lost events" NFR).
  final Duration ackedEventAge;

  /// `telemetry_buffer` rows with `sent=true`.
  final Duration sentTelemetryAge;

  /// Hard floor for unsent telemetry: kept at least 14 days.
  final Duration telemetryAge;

  final Duration dailyLogAge;
  final Duration dvirReportAge;
  final Duration chatAge;
  final int chatMaxMessages;
  final Duration uploadedFileAge;

  /// `M-55` conflict list window (M30).
  final Duration conflictAge;

  final Duration notificationAge;
}

/// Concrete timestamps to delete before, computed from `now` (TimeSource).
@immutable
class RetentionPlan {
  const RetentionPlan({
    required this.ackedEventsBefore,
    required this.sentTelemetryBefore,
    required this.telemetryFloor,
    required this.dailyLogsBefore,
    required this.dvirReportsBefore,
    required this.chatBefore,
    required this.chatMaxMessages,
    required this.uploadedFilesBefore,
    required this.conflictsBefore,
    required this.notificationsBefore,
  });

  final DateTime ackedEventsBefore;
  final DateTime sentTelemetryBefore;
  final DateTime telemetryFloor;
  final DateTime dailyLogsBefore;
  final DateTime dvirReportsBefore;
  final DateTime chatBefore;
  final int chatMaxMessages;
  final DateTime uploadedFilesBefore;
  final DateTime conflictsBefore;
  final DateTime notificationsBefore;
}

/// Builds the plan for [now]; [now] must come from `TimeSource`.
RetentionPlan planRetention({
  required DateTime now,
  RetentionPolicy policy = const RetentionPolicy(),
}) {
  final DateTime utc = now.toUtc();
  return RetentionPlan(
    ackedEventsBefore: utc.subtract(policy.ackedEventAge),
    sentTelemetryBefore: utc.subtract(policy.sentTelemetryAge),
    telemetryFloor: utc.subtract(policy.telemetryAge),
    dailyLogsBefore: utc.subtract(policy.dailyLogAge),
    dvirReportsBefore: utc.subtract(policy.dvirReportAge),
    chatBefore: utc.subtract(policy.chatAge),
    chatMaxMessages: policy.chatMaxMessages,
    uploadedFilesBefore: utc.subtract(policy.uploadedFileAge),
    conflictsBefore: utc.subtract(policy.conflictAge),
    notificationsBefore: utc.subtract(policy.notificationAge),
  );
}

/// 100 MB hard budget with a 90 MB soft trigger (§5.2).
@immutable
class StorageBudget {
  const StorageBudget({
    this.maxBytes = 100 * 1024 * 1024,
    this.softLimitBytes = 90 * 1024 * 1024,
    this.trimFraction = 0.10,
  });

  final int maxBytes;
  final int softLimitBytes;

  /// Share of the oldest telemetry rows dropped per trim pass.
  final double trimFraction;

  bool isOverSoftLimit(int usedBytes) => usedBytes > softLimitBytes;

  bool isOverBudget(int usedBytes) => usedBytes > maxBytes;
}

/// What the retention job must do about the current database size.
@immutable
class BudgetVerdict {
  const BudgetVerdict({
    required this.overSoftLimit,
    required this.overBudget,
    required this.telemetryRowsToDrop,
  });

  final bool overSoftLimit;
  final bool overBudget;

  /// Oldest telemetry rows to delete. **Never** includes duty events (M23).
  final int telemetryRowsToDrop;

  bool get requiresTrim => telemetryRowsToDrop > 0;
}

/// Decides how much telemetry to drop for a database of [usedBytes].
///
/// Events, DVIRs, chat outbox and files queue are untouched: only the oldest
/// [StorageBudget.trimFraction] of `telemetry_buffer` is removed, and at least
/// one row when the soft limit is exceeded and telemetry exists.
BudgetVerdict evaluateBudget({
  required int usedBytes,
  required int telemetryRows,
  StorageBudget budget = const StorageBudget(),
}) {
  final bool soft = budget.isOverSoftLimit(usedBytes);
  if (!soft || telemetryRows <= 0) {
    return BudgetVerdict(
      overSoftLimit: soft,
      overBudget: budget.isOverBudget(usedBytes),
      telemetryRowsToDrop: 0,
    );
  }
  final int drop = (telemetryRows * budget.trimFraction).floor().clamp(1, telemetryRows);
  return BudgetVerdict(
    overSoftLimit: true,
    overBudget: budget.isOverBudget(usedBytes),
    telemetryRowsToDrop: drop,
  );
}
