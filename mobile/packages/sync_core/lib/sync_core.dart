/// Pure Dart rules of the ONEBOOK ELD offline sync layer (`tz-mobile.md` §5–§6).
///
/// No Flutter, no I/O, no `DateTime.now()`, no `Random()`: every function takes
/// its clock and entropy from the caller so the app and the tests agree.
library;

export 'src/backoff.dart';
export 'src/batch.dart';
export 'src/conflict.dart';
export 'src/idempotency.dart';
export 'src/outbox_item.dart';
export 'src/retention.dart';
export 'src/slot.dart';
export 'src/validation.dart';
