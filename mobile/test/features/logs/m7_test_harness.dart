/// M7 (logs · certify · log_edits · unidentified) ekranlari uchun umumiy
/// test qobig'i: soxta repozitoriylar + tema/l10n bilan `pumpWidget`.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:eld_mobile/core/session/session_context.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/core/ui/theme.dart';
import 'package:eld_mobile/features/certify/domain/certify_models.dart';
import 'package:eld_mobile/features/certify/domain/certify_repository.dart';
import 'package:eld_mobile/features/certify/presentation/controllers/certify_providers.dart';
import 'package:eld_mobile/features/log_edits/domain/log_edit_models.dart';
import 'package:eld_mobile/features/log_edits/domain/log_edits_repository.dart';
import 'package:eld_mobile/features/log_edits/presentation/controllers/log_edits_controllers.dart';
import 'package:eld_mobile/features/logs/domain/day_timeline.dart';
import 'package:eld_mobile/features/logs/domain/log_models.dart';
import 'package:eld_mobile/features/logs/domain/logs_repository.dart';
import 'package:eld_mobile/features/logs/presentation/controllers/logs_providers.dart';
import 'package:eld_mobile/features/unidentified/domain/unidentified_models.dart';
import 'package:eld_mobile/features/unidentified/presentation/controllers/unidentified_controller.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus;

import '../../core/helpers/test_clock.dart';

/// Testlardagi qat'iy "hozir".
final DateTime t0 = DateTime(2026, 9, 7, 12);

/// Hech qachon qiymat bermaydigan oqim — yuklanish holati uchun.
Stream<T> pendingStream<T>() => Stream<T>.fromFuture(Completer<T>().future);

class FakeLogsRepository implements LogsRepository {
  FakeLogsRepository({
    this.strip = const <LogDayRef>[],
    this.day,
    this.dvir = const <DvirListItem>[],
    this.loading = false,
    this.failing = false,
  });

  List<LogDayRef> strip;
  LogDayView? day;
  List<DvirListItem> dvir;
  bool loading;
  bool failing;

  final List<DriverLogEdit> submitted = <DriverLogEdit>[];

  Stream<T> _wrap<T>(T value) {
    if (loading) {
      return pendingStream<T>();
    }
    if (failing) {
      return Stream<T>.error(StateError('boom'));
    }
    return Stream<T>.value(value);
  }

  @override
  Stream<List<LogDayRef>> watchStrip({int days = 8}) => _wrap<List<LogDayRef>>(strip);

  @override
  Stream<LogDayView> watchDay(DateTime date) =>
      _wrap<LogDayView>(day ?? LogDayView(date: date, certification: DayCertification.uncertified));

  @override
  Stream<List<DvirListItem>> watchDvir({int limit = 50}) => _wrap<List<DvirListItem>>(dvir);

  @override
  Future<void> submitDriverEdit(DriverLogEdit edit) async => submitted.add(edit);
}

class FakeCertifyRepository implements CertifyRepository {
  FakeCertifyRepository({this.days = const <CertifyDay>[], this.loading = false});

  List<CertifyDay> days;
  bool loading;
  final List<List<DateTime>> certified = <List<DateTime>>[];
  CertifyOutcome outcome = const CertifyOutcome(queued: <DateTime>[], failed: <DateTime, String>{});

  @override
  Stream<List<CertifyDay>> watchWindow({int days = kCertificationWindowDays}) =>
      loading ? pendingStream<List<CertifyDay>>() : Stream<List<CertifyDay>>.value(this.days);

  @override
  Stream<CertifyDay> watchDay(DateTime date) => Stream<CertifyDay>.value(
    days.firstWhere(
      (CertifyDay d) => d.date == date,
      orElse: () => CertifyDay(date: date, status: CertifyStatus.uncertified),
    ),
  );

  @override
  Future<CertifyOutcome> certify({
    required List<DateTime> dates,
    required SignatureInput signature,
  }) async {
    certified.add(dates);
    return outcome;
  }
}

class FakeSignatureStore implements SignatureStore {
  FakeSignatureStore({this.id});

  String? id;

  @override
  Future<String?> savedSignatureId() async => id;

  @override
  Future<String?> savedSignaturePath() async => null;

  @override
  Future<String> enqueue(Uint8List png, {required bool remember}) async => '/tmp/sig.png';
}

class FakeLogEditsRepository implements LogEditsRepository {
  FakeLogEditsRepository({this.items = const <LogEditRequestView>[], this.loading = false});

  List<LogEditRequestView> items;
  bool loading;
  final List<String> approved = <String>[];
  final Map<String, String> rejected = <String, String>{};

  @override
  Stream<List<LogEditRequestView>> watchPending() => loading
      ? pendingStream<List<LogEditRequestView>>()
      : Stream<List<LogEditRequestView>>.value(items);

  @override
  Stream<LogEditRequestView?> watchById(String id) =>
      watchPending().map((List<LogEditRequestView> list) {
        for (final LogEditRequestView item in list) {
          if (item.id == id) {
            return item;
          }
        }
        return null;
      });

  @override
  Future<void> approve(String id) async => approved.add(id);

  @override
  Future<void> reject({required String id, required String reason}) async => rejected[id] = reason;
}

class FakeUnidentifiedRepository implements UnidentifiedRepository {
  FakeUnidentifiedRepository({this.blocks = const <UnidentifiedBlock>[], this.loading = false});

  List<UnidentifiedBlock> blocks;
  bool loading;
  ClaimOutcome outcome = ClaimOutcome.queued;
  final List<String> claimed = <String>[];
  final List<String> dismissed = <String>[];

  @override
  Stream<List<UnidentifiedBlock>> watchClaimable() => loading
      ? pendingStream<List<UnidentifiedBlock>>()
      : Stream<List<UnidentifiedBlock>>.value(blocks);

  @override
  Future<ClaimOutcome> claim(String id) async {
    claimed.add(id);
    return outcome;
  }

  @override
  Future<void> dismiss(String id) async => dismissed.add(id);
}

/// Ekranni tema + l10n + DI bilan ko'taradi.
Future<void> pumpM7(
  WidgetTester tester,
  Widget child, {
  FakeLogsRepository? logs,
  FakeCertifyRepository? certify,
  FakeSignatureStore? signatures,
  FakeLogEditsRepository? edits,
  FakeUnidentifiedRepository? unidentified,
  Size surface = const Size(393, 852),
  Brightness brightness = Brightness.light,
  List<Override> extraOverrides = const <Override>[],
}) async {
  // `setSurfaceSize` bu versiyada `MediaQuery` ni o'zgartirmaydi — `view`
  // to'g'ridan-to'g'ri sozlanadi, aks holda profil planshet deb aniqlanadi (M7).
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = surface;
  addTearDown(tester.view.reset);

  final TimeSource time = buildTestTimeSource(t0).time;
  addTearDown(time.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        timeSourceProvider.overrideWithValue(time),
        sessionContextProvider.overrideWithValue(
          const SessionContext(
            driverId: 'drv-1',
            driverName: 'John Doe',
            unitId: 'unit-1',
            unitNumber: '1021',
            homeTerminal: '5432 Lorem Ipsum',
          ),
        ),
        logsRepositoryProvider.overrideWithValue(logs ?? FakeLogsRepository()),
        certifyRepositoryProvider.overrideWithValue(certify ?? FakeCertifyRepository()),
        signatureStoreProvider.overrideWithValue(signatures ?? FakeSignatureStore()),
        logEditsRepositoryProvider.overrideWithValue(edits ?? FakeLogEditsRepository()),
        unidentifiedRepositoryProvider.overrideWithValue(
          unidentified ?? FakeUnidentifiedRepository(),
        ),
        ...extraOverrides,
      ],
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
  // `pumpAndSettle` emas: skelet shimmer cheksiz animatsiya beradi.
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// Namuna event.
LogEventView sampleEvent({
  String id = 'e1',
  DutyStatus status = DutyStatus.on,
  int hour = 8,
  bool edited = false,
  bool locked = false,
  LogEventOrigin origin = LogEventOrigin.driver,
}) => LogEventView(
  clientEventId: id,
  status: status,
  start: DateTime(2026, 9, 7, hour),
  end: DateTime(2026, 9, 7, hour + 2),
  location: '3.40 mi West of Avon, NY',
  document: 'XYZ-1',
  odometerM: 324543,
  engineHours: 333.22,
  notes: 'Lorem ipsum',
  origin: origin,
  edited: edited,
  originalSummary: edited ? 'DR 13:00-15:00' : null,
  locked: locked,
);

/// Namuna kun.
LogDayView sampleDay({
  List<LogEventView>? events,
  DayCertification certification = DayCertification.uncertified,
  List<LogAlert> alerts = const <LogAlert>[],
  bool available = true,
}) => _sampleDay(events ?? <LogEventView>[sampleEvent()], certification, alerts, available);

LogDayView _sampleDay(
  List<LogEventView> events,
  DayCertification certification,
  List<LogAlert> alerts,
  bool available,
) => LogDayView(
  date: DateTime(2026, 9, 7),
  certification: certification,
  ready: true,
  events: events,
  spans: buildDaySpans(dayStart: DateTime(2026, 9, 7), events: events, until: DateTime(2026, 9, 8)),
  totals: <DutyStatus, Duration>{
    DutyStatus.off: const Duration(hours: 3, minutes: 6),
    DutyStatus.sb: Duration.zero,
    DutyStatus.dr: Duration.zero,
    DutyStatus.on: const Duration(hours: 2),
  },
  alerts: alerts,
  shippingDocuments: const <String>['XYZ-1'],
  trailerNumbers: const <String>['bobtail'],
  notes: 'Lorem ipsum',
  driver: const DriverDayInfo(
    driverName: 'John Doe',
    unitNumber: '1021',
    homeTerminal: '5432 Lorem Ipsum',
  ),
  available: available,
);
