/// ELD provayderlari (§2 qatlam qoidasi #4: BLE menejeri — `keepAlive`).
///
/// **M163:** `MockEldTransport` prod build'ga kirmasligi uchun ikki qavat
/// himoya — `--dart-define=MOCK_ELD=true` **va** `!kReleaseMode`.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/db_providers.dart';
import '../sync/sync_providers.dart';
import '../time/time_providers.dart';
import 'ble_eld_transport.dart';
import 'eld_buffer_importer.dart';
import 'eld_codes.dart';
import 'eld_connection_manager.dart';
import 'eld_malfunction_detector.dart';
import 'eld_models.dart';
import 'eld_permissions.dart';
import 'eld_session.dart';
import 'eld_transport.dart';
import 'kv_eld_device_store.dart';
import 'mock_eld_permissions.dart';
import 'mock_eld_transport.dart';
import 'motion_detector.dart';
import 'platform_eld_permissions.dart';

/// `--dart-define=MOCK_ELD=true` — dev/stage build'larda.
const bool kMockEldDefine = bool.fromEnvironment('MOCK_ELD');

/// Mock transport ruxsat etilganmi (M163: release'da **hech qachon**).
bool get mockEldEnabled => kMockEldDefine && !kReleaseMode;

/// Transport tanlovi. Test/dev menyu `overrideWithValue` bilan almashtiradi.
final Provider<EldTransport> eldTransportProvider = Provider<EldTransport>((Ref ref) {
  final EldTransport transport = mockEldEnabled
      ? MockEldTransport(time: ref.watch(timeSourceProvider))
      : BleEldTransport(time: ref.watch(timeSourceProvider));
  ref.onDispose(transport.dispose);
  return transport;
});

/// Oxirgi qurilma ID si ombori (`kv_settings`).
///
/// Testlarda [InMemoryEldDeviceStore] bilan `overrideWithValue` qilinadi.
final Provider<EldDeviceStore> eldDeviceStoreProvider = Provider<EldDeviceStore>(
  (Ref ref) => KvEldDeviceStore(
    settings: ref.watch(settingsDaoProvider),
    time: ref.watch(timeSourceProvider),
  ),
);

/// Ulanish holat mashinasi — ilova hayoti davomida yashaydi.
final Provider<EldConnectionManager> eldConnectionManagerProvider = Provider<EldConnectionManager>((
  Ref ref,
) {
  final EldConnectionManager manager = EldConnectionManager(
    transport: ref.watch(eldTransportProvider),
    time: ref.watch(timeSourceProvider),
    store: ref.watch(eldDeviceStoreProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

/// Banner va ekranlar kuzatadigan holat.
final StreamProvider<EldSessionState> eldSessionProvider = StreamProvider<EldSessionState>(
  (Ref ref) => ref.watch(eldConnectionManagerProvider).states,
);

/// Handshake oqimi — `power_on` eventi va bufer importi shundan boshlanadi.
final StreamProvider<EldHandshake> eldHandshakeProvider = StreamProvider<EldHandshake>(
  (Ref ref) => ref.watch(eldConnectionManagerProvider).handshakes,
);

/// Ruxsatlar xizmati.
final Provider<EldPermissionService> eldPermissionServiceProvider = Provider<EldPermissionService>((
  Ref ref,
) {
  final EldPermissionService service = mockEldEnabled
      ? MockEldPermissionService()
      : PlatformEldPermissionService();
  ref.onDispose(service.dispose);
  return service;
});

/// Ruxsatlar kesimi (M-18 jadvali, M69 bannerlari).
final StreamProvider<EldPermissionSnapshot> eldPermissionSnapshotProvider =
    StreamProvider<EldPermissionSnapshot>((Ref ref) async* {
      final EldPermissionService service = ref.watch(eldPermissionServiceProvider);
      yield await service.snapshot();
      yield* service.changes;
    });

/// Auto-DR detektori (M56–M62). Duty status yozish — `duty_status` moduli (M4).
final Provider<MotionDetector> motionDetectorProvider = Provider<MotionDetector>((Ref ref) {
  final MotionDetector detector = MotionDetector();
  ref.onDispose(detector.dispose);
  return detector;
});

/// Detektorni telemetriya oqimiga ulaydi.
final Provider<MotionDetectorRunner> motionRunnerProvider = Provider<MotionDetectorRunner>((
  Ref ref,
) {
  final MotionDetectorRunner runner = MotionDetectorRunner(
    detector: ref.watch(motionDetectorProvider),
    telemetry: ref.watch(eldTransportProvider).telemetry,
    now: ref.watch(timeSourceProvider).now,
  );
  ref.onDispose(runner.dispose);
  return runner;
});

/// `MotionEvent` oqimi — `duty_status` kontrolleri shu yerga obuna bo'ladi.
final StreamProvider<MotionEvent> motionEventsProvider = StreamProvider<MotionEvent>(
  (Ref ref) => ref.watch(motionRunnerProvider).events,
);

/// P/E/T/L/R/S/O detektori (sof funksiya).
final Provider<EldMalfunctionDetector> eldMalfunctionDetectorProvider =
    Provider<EldMalfunctionDetector>((Ref ref) => const EldMalfunctionDetector());

/// Bufer importi (M72) — `DutyEventsDao` (dedup) + `OutboxRepository` (yozish).
final Provider<EldBufferImporter> eldBufferImporterProvider = Provider<EldBufferImporter>(
  (Ref ref) => EldBufferImporter(
    events: ref.watch(dutyEventsDaoProvider),
    outbox: ref.watch(outboxRepositoryProvider),
  ),
);

/// Aktiv nosozliklar (banner uchun) — `EldSessionState` dan ajratilgan ko'rinish.
final Provider<List<EldFault>> eldActiveFaultsProvider = Provider<List<EldFault>>((Ref ref) {
  final EldSessionState? state = ref.watch(eldSessionProvider).value;
  if (state == null) {
    return const <EldFault>[];
  }
  return <EldFault>[...state.malfunctions, ...state.diagnosticFaults];
});
