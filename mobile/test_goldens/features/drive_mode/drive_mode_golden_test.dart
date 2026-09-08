@Timeout(Duration(seconds: 120))
/// `M-15` va `M-16` golden testlari.
library;

import 'package:eld_mobile/core/location/location_models.dart';
import 'package:eld_mobile/features/drive_mode/presentation/screens/drive_mode_screen.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/duty_status/duty_test_harness.dart';
import '../../golden_harness.dart';
import '../duty_status/m4_golden_host.dart';

void main() {
  m4GoldenMatrix(
    'm15_drive_mode',
    child: () => const DriveModeScreen(),
    overrides: () => m4Overrides(
      duty: FakeDutyStatusRepository(context: testContext(status: DutyStatusValue.driving)),
      context: testContext(status: DutyStatusValue.driving),
      place: const GeocodedPlace(label: '342, Plot B'),
    ),
  );

  m4GoldenMatrix(
    'm16_idle_prompt',
    devices: <GoldenDevice>[GoldenDevice.phone],
    child: () => const _IdlePromptGolden(),
    overrides: () => m4Overrides(
      duty: FakeDutyStatusRepository(context: testContext(status: DutyStatusValue.driving)),
      context: testContext(status: DutyStatusValue.driving),
    ),
  );
}

class _IdlePromptGolden extends StatelessWidget {
  const _IdlePromptGolden();

  @override
  Widget build(BuildContext context) => const DriveModeScreen();
}
