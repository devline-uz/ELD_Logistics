@Timeout(Duration(seconds: 90))
/// M7 ekranlarining goldenlari: `light`/`dark` × `phone`/`tablet`.
///
/// M-22/M-23 (`logs`), M-26 (`log_edits`), M-28 (`unidentified`),
/// M-29/M-30 (`certify`).
library;

import 'package:eld_mobile/core/session/session_context.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/certify/domain/certify_models.dart';
import 'package:eld_mobile/features/certify/presentation/controllers/certify_providers.dart';
import 'package:eld_mobile/features/certify/presentation/screens/certify_screen.dart';
import 'package:eld_mobile/features/certify/presentation/screens/certify_sign_screen.dart';
import 'package:eld_mobile/features/log_edits/domain/log_edit_models.dart';
import 'package:eld_mobile/features/log_edits/presentation/controllers/log_edits_controllers.dart';
import 'package:eld_mobile/features/log_edits/presentation/screens/pending_edits_screen.dart';
import 'package:eld_mobile/features/logs/domain/log_models.dart';
import 'package:eld_mobile/features/logs/presentation/controllers/logs_providers.dart';
import 'package:eld_mobile/features/logs/presentation/screens/log_report_screen.dart';
import 'package:eld_mobile/features/unidentified/domain/unidentified_models.dart';
import 'package:eld_mobile/features/unidentified/presentation/controllers/unidentified_controller.dart';
import 'package:eld_mobile/features/unidentified/presentation/screens/unidentified_screen.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hos_engine/hos_engine.dart' show DutyStatus, ViolationType;

import '../../../test/core/helpers/test_clock.dart';
import '../../../test/features/logs/m7_test_harness.dart';
import '../golden_screen_host.dart';

/// Golden'da soat deterministik bo'lishi uchun har build'da yangi manba.
List<Override> _overrides({
  FakeLogsRepository? logs,
  FakeCertifyRepository? certify,
  FakeSignatureStore? signatures,
  FakeLogEditsRepository? edits,
  FakeUnidentifiedRepository? unidentified,
}) {
  final TimeSource time = buildTestTimeSource(t0).time;
  return <Override>[
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
    unidentifiedRepositoryProvider.overrideWithValue(unidentified ?? FakeUnidentifiedRepository()),
  ];
}

final List<LogDayRef> _strip = <LogDayRef>[
  for (int i = 7; i >= 0; i--)
    LogDayRef(
      date: DateTime(2026, 9, 7).subtract(Duration(days: i)),
      certification: i.isEven ? DayCertification.certified : DayCertification.uncertified,
    ),
];

void main() {
  screenGoldenMatrix(
    'm22_log_report_main',
    builder: () => const LogReportScreen(),
    overrides: () => _overrides(
      logs: FakeLogsRepository(day: sampleDay(), strip: _strip),
    ),
  );

  screenGoldenMatrix(
    'm23_log_report_logs',
    builder: () => const LogReportScreen(initialTab: 'logs'),
    overrides: () => _overrides(
      logs: FakeLogsRepository(
        strip: _strip,
        day: sampleDay(
          events: <LogEventView>[
            sampleEvent(status: DutyStatus.off, hour: 0),
            sampleEvent(id: 'e2', status: DutyStatus.dr, hour: 6),
            sampleEvent(id: 'e3', status: DutyStatus.on, hour: 9, edited: true),
          ],
          alerts: const <LogAlert>[
            LogAlert(level: LogAlertLevel.warning, type: ViolationType.formMannerTrailer),
            LogAlert(level: LogAlertLevel.violation, type: ViolationType.driveLimit),
          ],
        ),
      ),
    ),
  );

  screenGoldenMatrix(
    'm24_log_report_dvir_empty',
    builder: () => const LogReportScreen(initialTab: 'dvir'),
    overrides: () => _overrides(logs: FakeLogsRepository(strip: _strip)),
  );

  // `T-16 Log Report — DVIR` (tz-mobile 1550): planshetda ikki ustunli grid,
  // telefonda oddiy ro'yxat — bir xil ma'lumot, ikki tartib.
  screenGoldenMatrix(
    't16_log_report_dvir',
    builder: () => const LogReportScreen(initialTab: 'dvir'),
    overrides: () => _overrides(
      logs: FakeLogsRepository(
        strip: _strip,
        dvir: <DvirListItem>[
          DvirListItem(
            id: 'd1',
            createdAt: DateTime(2026, 9, 7, 7, 30),
            type: 'pre_trip',
            trailerNumber: 'TR-9',
          ),
          DvirListItem(
            id: 'd2',
            createdAt: DateTime(2026, 9, 7, 18, 5),
            type: 'post_trip',
            trailerNumber: 'TR-9',
          ),
          DvirListItem(id: 'd3', createdAt: DateTime(2026, 9, 6, 7, 15), type: 'pre_trip'),
        ],
      ),
    ),
  );

  screenGoldenMatrix(
    'm26_pending_edits',
    builder: () => const PendingEditsScreen(),
    overrides: () => _overrides(
      edits: FakeLogEditsRepository(
        items: <LogEditRequestView>[
          LogEditRequestView(
            id: 'req-1',
            logDate: '2026-09-07',
            createdAt: DateTime(2026, 9, 7, 9),
            source: LogEditSource.adminEdit,
            requestedBy: 'Dispatch',
            changes: <LogEditChange>[
              LogEditChange(
                from: DateTime(2026, 9, 7, 13),
                to: DateTime(2026, 9, 7, 15),
                proposedStatus: 'ON',
                currentStatus: 'OFF',
                note: 'Wrong status recorded',
              ),
            ],
          ),
        ],
      ),
    ),
  );

  screenGoldenMatrix(
    'm28_unidentified',
    builder: () => const UnidentifiedScreen(),
    overrides: () => _overrides(
      unidentified: FakeUnidentifiedRepository(
        blocks: <UnidentifiedBlock>[
          UnidentifiedBlock(
            id: 'u1',
            unitId: '1021',
            start: DateTime(2026, 9, 7, 8),
            end: DateTime(2026, 9, 7, 9, 30),
            distanceM: 48280,
            status: UnidentifiedStatus.pending,
          ),
        ],
      ),
    ),
  );

  screenGoldenMatrix(
    'm29_certify_list',
    builder: () => const CertifyScreen(),
    overrides: () => _overrides(
      certify: FakeCertifyRepository(
        days: <CertifyDay>[
          CertifyDay(date: DateTime(2026, 9, 7), status: CertifyStatus.needsRecertify),
          CertifyDay(date: DateTime(2026, 9, 6), status: CertifyStatus.uncertified),
          CertifyDay(date: DateTime(2026, 9, 5), status: CertifyStatus.notReady),
          CertifyDay(date: DateTime(2026, 9, 4), status: CertifyStatus.certified),
        ],
      ),
    ),
  );

  screenGoldenMatrix(
    'm30_certify_sign',
    builder: () => CertifySignScreen(date: DateTime(2026, 9, 7)),
    overrides: () => _overrides(
      certify: FakeCertifyRepository(
        days: <CertifyDay>[
          CertifyDay(date: DateTime(2026, 9, 7), status: CertifyStatus.uncertified),
        ],
      ),
      signatures: FakeSignatureStore(id: 'sig-1'),
    ),
  );
}
