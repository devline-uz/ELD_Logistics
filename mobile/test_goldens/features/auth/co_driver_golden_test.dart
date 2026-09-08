@Timeout(Duration(seconds: 120))
/// `T-07 Switch co-driver` · `T-08 Select Shipping Document` ·
/// `M-56 Signed out elsewhere` · `M-58 Sessions` goldenlari.
///
/// Planshet konfiguratsiyasi **1366×1024** (light + dark), telefon 393×852.
/// Yangilash: `flutter test test_goldens --update-goldens`.
library;

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/auth/data/session_manager.dart';
import 'package:eld_mobile/features/auth/domain/driver_session.dart';
import 'package:eld_mobile/features/auth/domain/session_policy.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/sessions_controller.dart';
import 'package:eld_mobile/features/auth/presentation/controllers/shipping_document_controller.dart';
import 'package:eld_mobile/features/auth/presentation/screens/sessions_screen.dart';
import 'package:eld_mobile/features/auth/presentation/screens/signed_out_screen.dart';
import 'package:eld_mobile/features/auth/presentation/widgets/co_driver_switch_modal.dart';
import 'package:eld_mobile/features/auth/presentation/widgets/shipping_document_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/auth/session_test_fakes.dart';
import '../../golden_harness.dart';
import '../golden_screen_host.dart';

List<DriverSession> _sessions() => <DriverSession>[
  DriverSession(
    id: 'sess-1',
    deviceType: SessionDeviceType.tablet,
    status: ServerSessionStatus.active,
    ip: '203.0.113.0',
    appVersion: '1.4.2',
    lastSeenAt: DateTime.utc(2026, 9, 7, 10, 4),
    current: true,
  ),
  DriverSession(
    id: 'sess-2',
    deviceType: SessionDeviceType.phone,
    status: ServerSessionStatus.active,
    ip: '198.51.100.0',
    appVersion: '1.4.1',
    lastSeenAt: DateTime.utc(2026, 9, 6, 18, 22),
  ),
];

void main() {
  setUpAll(() => SkeletonConfig.animationsEnabled = false);
  tearDownAll(() => SkeletonConfig.animationsEnabled = true);

  screenGoldenMatrix(
    't07_switch_co_driver',
    builder: () => const Center(child: CoDriverSwitchModal()),
    overrides: () => <Override>[
      sessionManagerProvider.overrideWith(() => FakeSessionManager(pairedSession())),
    ],
  );

  screenGoldenMatrix(
    't07_switch_co_driver_empty',
    devices: <GoldenDevice>[GoldenDevice.tablet],
    builder: () => const Center(child: CoDriverSwitchModal()),
    overrides: () => <Override>[
      sessionManagerProvider.overrideWith(() => FakeSessionManager(soloSession())),
    ],
  );

  screenGoldenMatrix(
    't07_switch_co_driver_blocked',
    devices: <GoldenDevice>[GoldenDevice.tablet],
    builder: () => const Center(child: CoDriverSwitchModal()),
    overrides: () => <Override>[
      sessionManagerProvider.overrideWith(
        () => FakeSessionManager(SessionPolicy.leaveTruck(pairedSession()).state),
      ),
    ],
  );

  screenGoldenMatrix(
    't08_select_shipping_document',
    builder: () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Spacing.s20),
        child: ShippingDocumentBody(
          state: const ShippingDocumentState(
            documents: <String>['SD-42', 'SD-43', 'SD-77'],
            mine: <String>{'SD-42', 'SD-77'},
            loading: false,
          ),
          onOwnerChanged: (_, _) {},
        ),
      ),
    ),
  );

  screenGoldenMatrix(
    'm56_signed_out_elsewhere',
    builder: () => const SignedOutScreen(replacedBy: SessionDeviceType.tablet),
  );

  screenGoldenMatrix(
    'm58_sessions',
    builder: () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Spacing.s20),
        child: SessionsList(
          state: SessionsState(loading: false, sessions: _sessions()),
          onRevoke: (_) {},
        ),
      ),
    ),
  );

  screenGoldenMatrix(
    'm58_sessions_empty',
    devices: <GoldenDevice>[GoldenDevice.tablet],
    builder: () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Spacing.s20),
        child: SessionsList(state: const SessionsState(loading: false), onRevoke: (_) {}),
      ),
    ),
  );

  screenGoldenMatrix(
    'm58_sessions_error',
    devices: <GoldenDevice>[GoldenDevice.tablet],
    builder: () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Spacing.s20),
        child: SessionsList(
          state: const SessionsState(
            loading: false,
            error: ApiError(code: ApiErrorCode.internalError, message: 'boom'),
          ),
          onRevoke: (_) {},
        ),
      ),
    ),
  );
}
