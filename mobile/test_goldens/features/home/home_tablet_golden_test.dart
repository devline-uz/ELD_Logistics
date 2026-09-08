@Timeout(Duration(seconds: 120))
/// `T-01 Home / Full screen` goldenlari — **1366×1024** landshaft,
/// light + dark (tz-mobile §3, M120).
///
/// `m09_home` goldenlari `home_golden_test.dart` da; bu yerda planshetning
/// co-driver bilan va co-driver'siz varianti qotiriladi (M10).
///
/// Yangilash: `flutter test test_goldens --update-goldens`.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/auth/session_test_fakes.dart';
import '../../../test/features/duty_status/duty_test_harness.dart';
import '../../golden_harness.dart';
import '../duty_status/m4_golden_host.dart';

void main() {
  setUpAll(() => SkeletonConfig.animationsEnabled = false);
  tearDownAll(() => SkeletonConfig.animationsEnabled = true);

  m4GoldenMatrix(
    't01_home_tablet',
    devices: <GoldenDevice>[GoldenDevice.tablet],
    child: () => const HomeScreen(),
    overrides: () => <Override>[
      ...m4Overrides(
        duty: FakeDutyStatusRepository(),
        home: FakeHomeRepository(certifyDays: testCertifyDays(), pendingEdits: 2),
      ),
      sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
    ],
  );

  m4GoldenMatrix(
    't01_home_tablet_co_driver',
    devices: <GoldenDevice>[GoldenDevice.tablet],
    child: () => const HomeScreen(),
    overrides: () => <Override>[
      ...m4Overrides(
        duty: FakeDutyStatusRepository(),
        home: FakeHomeRepository(certifyDays: testCertifyDays()),
      ),
      sessionManagerProvider.overrideWith(() => FakeSessionManager(pairedSession())),
    ],
  );
}
