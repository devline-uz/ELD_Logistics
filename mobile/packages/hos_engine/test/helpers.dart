import 'package:hos_engine/hos_engine.dart';
import 'package:timezone/timezone.dart' as tz;

/// RFC3339 UTC — Go test `at()`.
DateTime at(String s) => DateTime.parse(s).toUtc();

HosEvent ev(String time, DutyStatus status, {Special special = Special.none}) =>
    HosEvent(time: at(time), status: status, special: special);

tz.Location get chicago => tz.getLocation('America/Chicago');

tz.Location get karachi => tz.getLocation('Asia/Karachi');

tz.Location get utc => tz.UTC;
