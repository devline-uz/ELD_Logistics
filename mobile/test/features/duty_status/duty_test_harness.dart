/// M4 ekranlari uchun umumiy test qobig'i (home · duty_status · drive_mode).
///
/// Drift, ELD va GPS ga umuman tegilmaydi — barcha repozitoriylar soxta.
library;

import 'dart:async';

import 'package:eld_mobile/core/db/daos/outbox_dao.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/eld_session.dart';
import 'package:eld_mobile/core/eld/motion_detector.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/location/location_models.dart';
import 'package:eld_mobile/core/location/location_providers.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/features/drive_mode/data/drive_mode_providers.dart';
import 'package:eld_mobile/features/drive_mode/domain/idle_alert.dart';
import 'package:eld_mobile/features/duty_status/data/duty_status_providers.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_repository.dart';
import 'package:eld_mobile/features/duty_status/domain/hos_snapshot.dart';
import 'package:eld_mobile/features/home/data/home_providers.dart';
import 'package:eld_mobile/features/home/domain/home_models.dart';
import 'package:eld_mobile/features/home/domain/home_repository.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart';
import 'package:sync_core/sync_core.dart';

/// Testlarning barqaror vaqti.
final DateTime kTestNow = DateTime.utc(2026, 9, 7, 14, 30);

/// Unit biriktirilgan haydovchi.
const DriverContext kTestDriver = DriverContext(
  driverId: 'drv-1',
  driverName: 'John Smith',
  email: 'john@example.com',
  phone: '+1 555 0100',
  licenseNumber: 'D1234567',
  licenseState: 'TX',
  unitId: 'unit-1',
  unitNumber: '1021',
  vehicleLabel: 'BMW mi7 2019',
);

DutyStatusContext testContext({
  DutyStatusValue? status = DutyStatusValue.on,
  DutySpecial special = DutySpecial.none,
  DriverContext driver = kTestDriver,
  HosPolicy? policy,
  DateTime? since,
  List<String> trailerIds = const <String>['T-880'],
  List<String> shippingDocIds = const <String>['SD-42'],
  String notes = 'Lorem Ipsum',
}) => DutyStatusContext(
  policy: policy ?? defaultPolicy(),
  driver: driver,
  current: status,
  special: special,
  since: since ?? kTestNow.subtract(const Duration(hours: 2, minutes: 5)),
  trailerIds: trailerIds,
  shippingDocIds: shippingDocIds,
  notes: notes,
);

HosSnapshot testSnapshot() => HosSnapshot(
  counters: const HosCounters(
    breakLeftMin: 480,
    driveLeftMin: 540,
    shiftLeftMin: 600,
    cycleLeftMin: 3900,
    drivingTimeLeftMin: 152,
  ),
  totals: const DayTotals(
    off: Duration(hours: 3, minutes: 6),
    sb: Duration.zero,
    drive: Duration(hours: 2),
    on: Duration(hours: 1),
  ),
  violations: const <HosViolation>[],
  policy: defaultPolicy(),
  computedAt: kTestNow,
);

class FakeDutyStatusRepository implements DutyStatusRepository {
  FakeDutyStatusRepository({DutyStatusContext? context}) : _context = context ?? testContext();

  DutyStatusContext _context;

  /// Joriy kesim (override'lar uchun).
  DutyStatusContext get current => _context;
  final StreamController<DutyStatusContext> _contexts =
      StreamController<DutyStatusContext>.broadcast();

  /// Yozilgan status o'zgarishlari (draft, origin, vaqt).
  final List<({DutyStatusDraft draft, EventOrigin origin, DateTime? at})> changes =
      <({DutyStatusDraft draft, EventOrigin origin, DateTime? at})>[];

  /// `M-11` chaqiruvlari.
  final List<({List<String> trailers, List<String> docs, String? notes})> documentUpdates =
      <({List<String> trailers, List<String> docs, String? notes})>[];

  int intermediates = 0;

  /// `changeStatus` shu xatoni tashlaydi.
  ApiError? error;

  List<HosEvent> events = <HosEvent>[];

  void emit(DutyStatusContext context) {
    _context = context;
    _contexts.add(context);
  }

  Future<void> dispose() => _contexts.close();

  @override
  Stream<DutyStatusContext> watchContext() async* {
    yield _context;
    yield* _contexts.stream;
  }

  @override
  Future<DutyStatusContext> context() async => _context;

  @override
  Future<List<HosEvent>> hosEvents({required DateTime now}) async => events;

  @override
  Future<List<HosEvent>> dayEvents({
    required DateTime dayStartUtc,
    required DateTime dayEndUtc,
  }) async => events;

  @override
  Future<DutyChangeResult> changeStatus({
    required DutyStatusDraft draft,
    required EventOrigin origin,
    DateTime? at,
    double? speedKmh,
    int? odometerM,
    double? engineHours,
  }) async {
    if (error != null) {
      throw error!;
    }
    changes.add((draft: draft, origin: origin, at: at));
    return DutyChangeResult(clientEventId: 'evt-${changes.length}', eventTime: at ?? kTestNow);
  }

  @override
  Future<DutyChangeResult> updateDocuments({
    required List<String> trailerIds,
    required List<String> shippingDocIds,
    String? notes,
  }) async {
    documentUpdates.add((trailers: trailerIds, docs: shippingDocIds, notes: notes));
    return DutyChangeResult(clientEventId: 'doc-1', eventTime: kTestNow);
  }

  @override
  Future<DutyChangeResult> recordIntermediate({
    double? lat,
    double? lng,
    int? odometerM,
    double? engineHours,
    double? speedKmh,
  }) async {
    intermediates++;
    return DutyChangeResult(clientEventId: 'int-$intermediates', eventTime: kTestNow);
  }
}

class FakeDutyCatalogRepository implements DutyCatalogRepository {
  FakeDutyCatalogRepository({
    this.quickNotes = const <QuickNoteOption>[],
    this.trailers = const <TrailerOption>[],
  });

  List<QuickNoteOption> quickNotes;
  List<TrailerOption> trailers;
  final List<String> remembered = <String>[];

  @override
  Stream<List<QuickNoteOption>> watchQuickNotes() =>
      Stream<List<QuickNoteOption>>.value(quickNotes);

  @override
  Stream<List<TrailerOption>> watchTrailers() => Stream<List<TrailerOption>>.value(trailers);

  @override
  Future<List<String>> recentShippingDocs() async => const <String>[];

  @override
  Future<void> rememberShippingDoc(String number) async => remembered.add(number);
}

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.certifyDays = const <CertifyDay>[],
    this.pendingEdits = 0,
    this.unidentified = 0,
    this.segments = const <DutyDaySegment>[],
  });

  List<CertifyDay> certifyDays;
  int pendingEdits;
  int unidentified;
  List<DutyDaySegment> segments;

  @override
  Stream<List<CertifyDay>> watchCertifyDays({int days = 8}) =>
      Stream<List<CertifyDay>>.value(certifyDays);

  @override
  Stream<int> watchPendingEditCount() => Stream<int>.value(pendingEdits);

  @override
  Stream<int> watchUnidentifiedCount() => Stream<int>.value(unidentified);

  @override
  Future<List<DutyDaySegment>> todaySegments({required DateTime now}) async => segments;
}

/// 8 kunlik sertifikatsiya nuqtalari (5 tasi imzolangan).
List<CertifyDay> testCertifyDays() => <CertifyDay>[
  for (int i = 0; i < 8; i++)
    CertifyDay(
      date: kTestNow.subtract(Duration(days: i)),
      certified: i.isEven,
    ),
];

/// Barcha M4 provayderlarini soxta manbalarga ulaydi.
List<Override> m4Overrides({
  required FakeDutyStatusRepository duty,
  FakeDutyCatalogRepository? catalog,
  FakeHomeRepository? home,
  HosSnapshot? snapshot,
  DutyStatusContext? context,
  bool contextLoading = false,
  EldConnectionState eld = EldConnectionState.connected,
  EldSessionState? session,
  int queued = 0,
  Stream<MotionEvent>? motion,
  IdleAlertNotifier? alerts,
  GeocodedPlace? place,
  TimeSource? time,
}) => <Override>[
  timeSourceProvider.overrideWithValue(time ?? TimeSource(wallClock: () => kTestNow)),
  dutyStatusRepositoryProvider.overrideWithValue(duty),
  dutyCatalogRepositoryProvider.overrideWithValue(catalog ?? FakeDutyCatalogRepository()),
  homeRepositoryProvider.overrideWithValue(home ?? FakeHomeRepository()),
  dutyStatusContextProvider.overrideWith(
    (Ref ref) => contextLoading
        ? const Stream<DutyStatusContext>.empty()
        : Stream<DutyStatusContext>.value(context ?? duty.current),
  ),
  hosSnapshotProvider.overrideWith((Ref ref) async => snapshot ?? testSnapshot()),
  secondTickProvider.overrideWith((Ref ref) => Stream<DateTime>.value(kTestNow)),
  eldSessionProvider.overrideWith(
    (Ref ref) => Stream<EldSessionState>.value(session ?? EldSessionState(connection: eld)),
  ),
  outboxStatsProvider.overrideWith(
    (Ref ref) => Stream<OutboxQueueStats>.value(
      OutboxQueueStats(
        pendingByKind: <OutboxKind, int>{OutboxKind.event: queued},
        inflight: 0,
        rejected: 0,
        unseenRejected: 0,
      ),
    ),
  ),
  motionEventsProvider.overrideWith((Ref ref) => motion ?? const Stream<MotionEvent>.empty()),
  idleAlertNotifierProvider.overrideWithValue(alerts ?? NoopIdleAlertNotifier()),
  currentPlaceProvider.overrideWith((Ref ref) async => place),
];

/// Ekranni to'liq ilova kontekstida ko'taradi.
Future<void> pumpM4(
  WidgetTester tester, {
  required Widget child,
  required List<Override> overrides,
  Size surface = const Size(393, 852),
  Brightness brightness = Brightness.light,
}) async {
  // `setSurfaceSize` faqat layout o'lchamini o'zgartiradi — `MediaQuery` esa
  // `view.physicalSize` dan keladi, shuning uchun `DeviceProfile` (M7) noto'g'ri
  // aniqlanadi. Ikkalasini ham to'g'rilaymiz.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.of(brightness),
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}
