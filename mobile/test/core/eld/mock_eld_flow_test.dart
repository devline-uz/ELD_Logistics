@Timeout(Duration(seconds: 60))
/// **M6 asosiy oqimi:** `MockEldTransport` bilan
/// handshake → bufer (M72) → malfunction (M77).
///
/// Ekranlar mock bilan to'liq ishlashi shart (M80, risk R2), shuning uchun
/// oqim uchidan uchiga shu yerda tekshiriladi.
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/eld/eld_buffer_importer.dart';
import 'package:eld_mobile/core/eld/eld_client_event_id.dart';
import 'package:eld_mobile/core/eld/eld_codes.dart';
import 'package:eld_mobile/core/eld/eld_connection_manager.dart';
import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/eld_transport.dart';
import 'package:eld_mobile/core/eld/mock_eld_transport.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

  late AppDatabase db;
  late TimeSource time;
  late MockEldTransport transport;
  late EldConnectionManager manager;
  late InMemoryEldDeviceStore store;

  /// Qurilma oflayn yozgan uchta event (M72).
  List<EldBufferedEvent> buffer() => <EldBufferedEvent>[
    EldBufferedEvent(
      eldSeq: 1,
      type: EldBufferedEventType.powerOn,
      recordedAt: t0.subtract(const Duration(hours: 2)),
      odometerM: 812_400_000,
      engineHours: 4820.1,
    ),
    EldBufferedEvent(
      eldSeq: 2,
      type: EldBufferedEventType.motionStart,
      recordedAt: t0.subtract(const Duration(hours: 1, minutes: 55)),
      lat: 41.311081,
      lng: 69.240562,
      speedKmh: 34,
    ),
    EldBufferedEvent(
      eldSeq: 3,
      type: EldBufferedEventType.powerOff,
      recordedAt: t0.subtract(const Duration(minutes: 30)),
      odometerM: 812_450_000,
    ),
  ];

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
    transport = MockEldTransport(
      time: time,
      buffer: buffer(),
      scanDelay: Duration.zero,
      connectDelay: Duration.zero,
    );
    store = InMemoryEldDeviceStore();
    manager = EldConnectionManager(
      transport: transport,
      time: time,
      store: store,
      autoReconnect: false,
    );
  });

  tearDown(() async {
    await manager.dispose();
    await transport.dispose();
    await db.close();
    await time.dispose();
  });

  EldBufferImporter importer() => EldBufferImporter(
    events: db.dutyEventsDao,
    outbox: OutboxRepository(db: db, time: time),
  );

  group('handshake', () {
    test('skan → ulanish → handshake maydonlari to\'liq', () async {
      await manager.start();

      final List<EldDeviceRef> found = await manager.scan().last;
      expect(found, hasLength(kMockEldDevices.length));
      expect(found.first.id, kMockEldDevices.first.id);

      final EldHandshake? handshake = await manager.connect(deviceId: found.first.id);

      expect(handshake, isNotNull);
      expect(handshake!.firmware, isNotEmpty);
      expect(handshake.vin, isNotNull);
      expect(handshake.odometerM, isNotNull);
      expect(handshake.engineHours, isNotNull);
      expect(manager.state.connection, EldConnectionState.connected);
      // Oxirgi MAC/ID keyingi sessiya uchun saqlanadi (§10.3).
      expect(await store.lastDeviceId(), found.first.id);
    });

    test('M71: RTC TimeSource ga beriladi', () async {
      // RTC `TimeSource` dan 4 daqiqa oldinda — anchor almashishi kerak.
      final MockEldTransport skewed = MockEldTransport(
        time: time,
        devices: const <MockEldDevice>[
          MockEldDevice(
            id: 'AA:BB:CC:00:00:09',
            name: 'ONEBOOK-ELD-9',
            rtcOffset: Duration(minutes: 4),
          ),
        ],
        scanDelay: Duration.zero,
        connectDelay: Duration.zero,
      );
      final EldConnectionManager skewedManager = EldConnectionManager(
        transport: skewed,
        time: time,
        store: InMemoryEldDeviceStore(),
        autoReconnect: false,
      );
      addTearDown(() async {
        await skewedManager.dispose();
        await skewed.dispose();
      });

      expect(time.source, isNot(EventTimeSource.eldRtc));
      await skewedManager.connect(deviceId: 'AA:BB:CC:00:00:09');
      expect(time.source, EventTimeSource.eldRtc);
    });

    test('VIN mos kelmasa ogohlantiradi, lekin ulanish bloklanmaydi', () async {
      manager.unitVin = '1XPBD49X1YD500000';
      final EldHandshake? handshake = await manager.connect();

      expect(handshake, isNotNull);
      expect(manager.state.connection, EldConnectionState.connected);
      expect(manager.state.vinMatch, VinMatchResult.mismatch);
    });

    test('VIN bir xil bo\'lsa match', () async {
      manager.unitVin = kMockEldDevices.first.vin;
      await manager.connect(deviceId: kMockEldDevices.first.id);
      expect(manager.state.vinMatch, VinMatchResult.match);
    });
  });

  group('bufer (M72)', () {
    test('birinchi import — hammasi yoziladi', () async {
      final EldHandshake? handshake = await manager.connect();
      final List<EldBufferedEvent> events = await manager.readBuffer();

      final EldBufferImportResult result = await importer().import(
        deviceId: handshake!.deviceId,
        events: events,
      );

      expect(result.imported, 3);
      expect(result.skipped, 0);
      expect(result.clientEventIds.toSet(), hasLength(3));
    });

    test('takroriy o\'qishda dublikat yaratilmaydi', () async {
      final EldHandshake? handshake = await manager.connect();
      final EldBufferImporter reader = importer();

      final EldBufferImportResult first = await reader.import(
        deviceId: handshake!.deviceId,
        events: await manager.readBuffer(),
      );
      // Bufer «tozalanmadi» — qayta ulanishda o'sha eventlar yana keladi.
      final EldBufferImportResult second = await reader.import(
        deviceId: handshake.deviceId,
        events: await manager.readBuffer(),
      );

      expect(transport.readBufferCalls, 2);
      expect(first.imported, 3);
      expect(second.imported, 0, reason: 'ikkinchi o\'qishda yangi event bo\'lmasligi kerak');
      expect(second.skipped, 3);
      expect(second.clientEventIds, first.clientEventIds);
    });

    test('client_event_id deterministik va urug\'ga sezgir', () {
      final EldBufferedEvent event = buffer().first;
      const String device = 'AA:BB:CC:00:00:01';

      final String a = eldClientEventId(deviceId: device, event: event);
      final String b = eldClientEventId(deviceId: device, event: event);
      final String other = eldClientEventId(deviceId: 'AA:BB:CC:00:00:02', event: event);

      expect(a, b);
      expect(a, isNot(other));
      expect(a, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-')));
    });

    test('acknowledgeBuffer transportga yetib boradi', () async {
      await manager.connect();
      final List<EldBufferedEvent> events = await manager.readBuffer();
      await manager.acknowledgeBuffer(events);
      expect(transport.acknowledged, hasLength(3));
    });
  });

  group('malfunction (M77)', () {
    test('nosozlik banner holatini malfunction ga o\'tkazadi', () async {
      await manager.start();
      await manager.connect();
      expect(manager.state.bannerState, EldConnectionState.connected);

      transport.raiseFault(EldFaultCode.power);
      await pumpEventQueue();

      expect(manager.state.faults, contains(EldFaultCode.power));
      expect(manager.state.hasMalfunction, isTrue);
      expect(manager.state.bannerState, EldConnectionState.malfunction);
      expect(manager.state.malfunctions.single.notes, 'P');
    });

    test('diagnostic malfunction dan past ustuvorlikda', () async {
      await manager.start();
      await manager.connect();

      transport.raiseFault(EldFaultCode.timing, kind: EldFaultKind.diagnostic);
      await pumpEventQueue();
      expect(manager.state.bannerState, EldConnectionState.diagnostic);

      transport.raiseFault(EldFaultCode.engineSync);
      await pumpEventQueue();
      expect(manager.state.bannerState, EldConnectionState.malfunction);
    });

    test('banner faqat holat tiklanganda yo\'qoladi (dismiss yo\'q)', () async {
      await manager.start();
      await manager.connect();
      transport.raiseFault(EldFaultCode.dataRecording);
      await pumpEventQueue();
      expect(manager.state.hasMalfunction, isTrue);

      manager.clearFault(EldFaultCode.dataRecording);
      expect(manager.state.hasMalfunction, isFalse);
      expect(manager.state.bannerState, EldConnectionState.connected);
    });

    test('bufer nosozlik eventi ham outbox\'ga tushadi', () async {
      transport.setBuffer(<EldBufferedEvent>[
        EldBufferedEvent(
          eldSeq: 7,
          type: EldBufferedEventType.malfunction,
          recordedAt: t0.subtract(const Duration(minutes: 10)),
          faultCode: EldFaultCode.power,
        ),
      ]);
      final EldHandshake? handshake = await manager.connect();
      final EldBufferImportResult result = await importer().import(
        deviceId: handshake!.deviceId,
        events: await manager.readBuffer(),
      );

      expect(result.imported, 1);
      final List<OutboxItemRow> queued = await db.outboxDao.dueItems(now: t0);
      expect(queued, hasLength(1));
      expect(queued.single.payload, contains('"P"'));
    });
  });

  group('uzilish', () {
    test('kutilmagan uzilish disconnectedSince ni belgilaydi', () async {
      await manager.start();
      await manager.connect();

      transport.dropConnection();
      await pumpEventQueue();

      expect(manager.state.connection, EldConnectionState.notConnected);
      expect(manager.state.disconnectedSince, isNotNull);
      expect(manager.state.failure, EldTransportFailure.disconnected);
    });

    test('qo\'lda uzish saqlangan ID ni o\'chirishi mumkin', () async {
      await manager.connect();
      expect(await store.lastDeviceId(), isNotNull);

      await manager.disconnect(forget: true);

      expect(await store.lastDeviceId(), isNull);
      expect(manager.state.device, isNull);
      expect(manager.state.connection, EldConnectionState.notConnected);
    });

    test('ulanish xatosi holatga chiqadi', () async {
      final MockEldTransport failing = MockEldTransport(
        time: time,
        scanDelay: Duration.zero,
        connectDelay: Duration.zero,
        failConnect: EldTransportFailure.bluetoothOff,
      );
      final EldConnectionManager m = EldConnectionManager(
        transport: failing,
        time: time,
        store: InMemoryEldDeviceStore(),
        autoReconnect: false,
      );
      addTearDown(() async {
        await m.dispose();
        await failing.dispose();
      });

      expect(await m.connect(deviceId: 'AA:BB:CC:00:00:01'), isNull);
      expect(m.state.failure, EldTransportFailure.bluetoothOff);
    });
  });

  test('reconnect backoff 2 → 5 → 15 → 60 → 60', () {
    final EldReconnectBackoff backoff = EldReconnectBackoff();
    expect(
      <Duration>[for (int i = 0; i < 5; i++) backoff.next()],
      const <Duration>[
        Duration(seconds: 2),
        Duration(seconds: 5),
        Duration(seconds: 15),
        Duration(seconds: 60),
        Duration(seconds: 60),
      ],
    );
    backoff.reset();
    expect(backoff.next(), const Duration(seconds: 2));
  });
}
