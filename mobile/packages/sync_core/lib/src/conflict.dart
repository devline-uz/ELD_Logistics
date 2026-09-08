/// Push result handling and conflict reason → UI mapping (§5.6, M29).
library;

import 'package:meta/meta.dart';

/// Per-item verdict returned by `POST /sync/push`.
enum PushResultKind {
  accepted('accepted'),
  duplicate('duplicate'),
  rejected('rejected');

  const PushResultKind(this.wire);

  final String wire;

  static PushResultKind fromWire(String wire) {
    for (final PushResultKind kind in PushResultKind.values) {
      if (kind.wire == wire) {
        return kind;
      }
    }
    throw ArgumentError.value(wire, 'wire', 'unknown push result');
  }
}

/// Rejection reasons of §5.6. Unknown server values map to [unknown].
enum RejectReason {
  timeInFuture('time_in_future'),
  timeOutOfRange('time_out_of_range'),
  logLocked('log_locked'),
  superseded('superseded'),
  invalidPayload('invalid_payload'),
  pcNotAllowed('pc_not_allowed'),
  ymNotAllowed('ym_not_allowed'),
  sleeperBerthUnavailable('sleeper_berth_unavailable'),
  driveNotManual('drive_not_manual'),
  autoDrive('auto_drive'),
  yardMoveEnded('yard_move_ended'),
  unknown('unknown');

  const RejectReason(this.wire);

  final String wire;

  /// Never throws: unrecognised reasons degrade to [unknown] so a new server
  /// reason can never crash the client.
  static RejectReason fromWire(String? wire) {
    if (wire == null) {
      return RejectReason.unknown;
    }
    for (final RejectReason reason in RejectReason.values) {
      if (reason.wire == wire) {
        return reason;
      }
    }
    return RejectReason.unknown;
  }
}

/// Follow-up offered on `M-55` for a rejected item (§5.6, last column).
enum ConflictAction {
  /// Retry after the user fixes the device clock.
  resend,

  /// Read-only entry.
  viewOnly,

  /// `Contact support` link.
  contactSupport,

  /// Informational only — the entry stays in history.
  informational,

  /// Offer "send to diagnostics".
  sendDiagnostics,

  /// Hide the PC / YM toggle for this company.
  hideToggle,

  /// Disable the Sleeper Berth button for this unit.
  disableSleeperBerth,

  /// No action.
  none,
}

/// Localisation key + English fallback for one reason.
@immutable
class ConflictPresentation {
  const ConflictPresentation({
    required this.reason,
    required this.messageKey,
    required this.fallbackText,
    required this.action,
  });

  final RejectReason reason;

  /// ARB key in `lib/l10n/app_en.arb`; the app resolves it via `context.l10n`.
  final String messageKey;

  /// English text of §5.6 — used only in logs and diagnostics, never in the UI.
  final String fallbackText;

  final ConflictAction action;
}

const Map<RejectReason, ConflictPresentation> _presentations = <RejectReason, ConflictPresentation>{
  RejectReason.timeInFuture: ConflictPresentation(
    reason: RejectReason.timeInFuture,
    messageKey: 'conflictTimeInFuture',
    fallbackText:
        'This entry was recorded ahead of server time and was not accepted. '
        'Check your device clock.',
    action: ConflictAction.resend,
  ),
  RejectReason.timeOutOfRange: ConflictPresentation(
    reason: RejectReason.timeOutOfRange,
    messageKey: 'conflictTimeOutOfRange',
    fallbackText: 'This entry is outside the accepted time range.',
    action: ConflictAction.viewOnly,
  ),
  RejectReason.logLocked: ConflictPresentation(
    reason: RejectReason.logLocked,
    messageKey: 'conflictLogLocked',
    fallbackText: 'That day is already certified. Ask your fleet manager for a log edit.',
    action: ConflictAction.contactSupport,
  ),
  RejectReason.superseded: ConflictPresentation(
    reason: RejectReason.superseded,
    messageKey: 'conflictSuperseded',
    fallbackText: 'Another device recorded a status at the same time. The other entry was kept.',
    action: ConflictAction.informational,
  ),
  RejectReason.invalidPayload: ConflictPresentation(
    reason: RejectReason.invalidPayload,
    messageKey: 'conflictInvalidPayload',
    fallbackText: 'This entry could not be saved (invalid data).',
    action: ConflictAction.sendDiagnostics,
  ),
  RejectReason.pcNotAllowed: ConflictPresentation(
    reason: RejectReason.pcNotAllowed,
    messageKey: 'conflictSpecialNotAllowed',
    fallbackText: 'Personal Conveyance / Yard Move is disabled for your company.',
    action: ConflictAction.hideToggle,
  ),
  RejectReason.ymNotAllowed: ConflictPresentation(
    reason: RejectReason.ymNotAllowed,
    messageKey: 'conflictSpecialNotAllowed',
    fallbackText: 'Personal Conveyance / Yard Move is disabled for your company.',
    action: ConflictAction.hideToggle,
  ),
  RejectReason.sleeperBerthUnavailable: ConflictPresentation(
    reason: RejectReason.sleeperBerthUnavailable,
    messageKey: 'conflictSleeperBerthUnavailable',
    fallbackText: 'Sleeper Berth is not available on this unit.',
    action: ConflictAction.disableSleeperBerth,
  ),
  RejectReason.driveNotManual: ConflictPresentation(
    reason: RejectReason.driveNotManual,
    messageKey: 'conflictDriveNotManual',
    fallbackText: 'Driving status is set automatically and cannot be changed by hand.',
    action: ConflictAction.none,
  ),
  RejectReason.autoDrive: ConflictPresentation(
    reason: RejectReason.autoDrive,
    messageKey: 'conflictDriveNotManual',
    fallbackText: 'Driving status is set automatically and cannot be changed by hand.',
    action: ConflictAction.none,
  ),
  RejectReason.yardMoveEnded: ConflictPresentation(
    reason: RejectReason.yardMoveEnded,
    messageKey: 'conflictYardMoveEnded',
    fallbackText: 'Yard Move ended automatically — the vehicle exceeded the speed limit.',
    action: ConflictAction.none,
  ),
  RejectReason.unknown: ConflictPresentation(
    reason: RejectReason.unknown,
    messageKey: 'conflictUnknown',
    fallbackText: 'This entry was not accepted by the server.',
    action: ConflictAction.sendDiagnostics,
  ),
};

/// UI presentation of [reason]; total function, never returns `null`.
ConflictPresentation presentationFor(RejectReason reason) =>
    _presentations[reason] ?? _presentations[RejectReason.unknown]!;

/// Terminal state an outbox item must be moved to after a push response.
enum OutboxOutcome {
  /// Item is done: `accepted`, `duplicate`, or `superseded` (M29).
  acked,

  /// Item goes to `M-55` with a reason.
  rejected,
}

/// Result of applying one server verdict to a queued item.
@immutable
class PushOutcome {
  const PushOutcome({required this.outcome, required this.reason, this.supersededBy});

  final OutboxOutcome outcome;

  /// `null` for plain `accepted` / `duplicate`.
  final RejectReason? reason;

  /// Server id of the winning event when [reason] is [RejectReason.superseded].
  final String? supersededBy;

  /// `superseded` is not an error — it is only surfaced as information (M29).
  bool get isError => outcome == OutboxOutcome.rejected;

  /// Whether the item must appear in the `M-55` list (7 days, M30).
  bool get showsInConflicts =>
      outcome == OutboxOutcome.rejected || reason == RejectReason.superseded;

  @override
  bool operator ==(Object other) =>
      other is PushOutcome &&
      other.outcome == outcome &&
      other.reason == reason &&
      other.supersededBy == supersededBy;

  @override
  int get hashCode => Object.hash(outcome, reason, supersededBy);

  @override
  String toString() => 'PushOutcome(${outcome.name}, ${reason?.wire}, $supersededBy)';
}

/// Maps a server verdict onto the local outbox state.
///
/// * `accepted` / `duplicate` → [OutboxOutcome.acked] (a duplicate is a success:
///   the server already has the item, `client_event_id` is the idempotency key).
/// * `rejected(superseded)` → [OutboxOutcome.acked] plus `superseded_by` (M29).
/// * any other `rejected(reason)` → [OutboxOutcome.rejected].
PushOutcome resolvePushResult({
  required PushResultKind result,
  String? reason,
  String? supersededBy,
}) {
  switch (result) {
    case PushResultKind.accepted:
    case PushResultKind.duplicate:
      return const PushOutcome(outcome: OutboxOutcome.acked, reason: null);
    case PushResultKind.rejected:
      final RejectReason parsed = RejectReason.fromWire(reason);
      if (parsed == RejectReason.superseded) {
        return PushOutcome(
          outcome: OutboxOutcome.acked,
          reason: RejectReason.superseded,
          supersededBy: supersededBy,
        );
      }
      return PushOutcome(outcome: OutboxOutcome.rejected, reason: parsed);
  }
}
