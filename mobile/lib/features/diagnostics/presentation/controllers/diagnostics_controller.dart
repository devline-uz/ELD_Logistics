/// `M-46 Diagnosis of device` va `M-47 Check network` kontrollerlari
/// (tz-mobile §10.5, M75, M76).
///
/// M-46 — **hosila holat**: ELD sessiyasi, telefon GPS keshi va sync kursori
/// birlashtiriladi, o'z so'rovi yo'q. M-47 — foydalanuvchi bosganda ishga
/// tushadigan bir martalik o'lchov.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/eld/eld_providers.dart';
import '../../../../core/eld/eld_session.dart';
import '../../../../core/location/location_providers.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/time/time_providers.dart';
import '../../data/network_probe.dart';
import '../../domain/diagnostics_models.dart';

/// M-46 kesimi — uchta manbaning hosilasi (o'z so'rovi yo'q).
final Provider<DeviceDiagnostics> deviceDiagnosticsProvider = Provider<DeviceDiagnostics>((
  Ref ref,
) {
  final DateTime now = ref.watch(timeSourceProvider).now();

  // 1. ELD coordinates — oxirgi 60 s ichida ELD dan lat/lng keldimi.
  final EldSessionState session = ref.watch(eldSessionProvider).value ?? const EldSessionState();
  final DiagnosticState eld = session.eldPositionFresh(now)
      ? DiagnosticState.working
      : DiagnosticState.notWorking;

  // 2. GPS coordinates — telefon fiksatsiyasi bormi.
  final LocationService location = ref.watch(locationServiceProvider);
  final DiagnosticState gps = location.lastFix == null
      ? DiagnosticState.notWorking
      : DiagnosticState.working;

  // 3. Network quality — oxirgi muvaffaqiyatli push/pull kechikishi.
  final SyncCursorRow? cursor = ref.watch(syncCursorProvider).value;
  final DateTime? lastSync = _latest(cursor?.lastPushAt, cursor?.lastPullAt);
  final NetworkQuality network = NetworkQuality.fromSyncLag(
    lastSync == null ? null : now.difference(lastSync),
    online: ref.watch(syncSchedulerProvider).online,
  );

  return DeviceDiagnostics(eldCoordinates: eld, gpsCoordinates: gps, network: network);
});

DateTime? _latest(DateTime? a, DateTime? b) {
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return a.isAfter(b) ? a : b;
}

/// M-47 o'lchovi. `null` — hali o'lchanmagan (dizayndagi boshlang'ich holat).
class NetworkCheckController extends AsyncNotifier<NetworkMeasurement?> {
  @override
  Future<NetworkMeasurement?> build() async => null;

  /// `Check Network` tugmasi.
  Future<void> run() async {
    state = const AsyncValue<NetworkMeasurement?>.loading();
    state = await AsyncValue.guard<NetworkMeasurement?>(
      () => ref.read(networkProbeProvider).measure(),
    );
  }
}

final AsyncNotifierProvider<NetworkCheckController, NetworkMeasurement?>
networkCheckControllerProvider = AsyncNotifierProvider<NetworkCheckController, NetworkMeasurement?>(
  NetworkCheckController.new,
);
