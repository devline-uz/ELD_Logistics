@Timeout(Duration(seconds: 120))
/// `M-12`, `M-13`, `M-14` golden testlari.
library;

import 'package:eld_mobile/features/duty_status/presentation/screens/change_duty_status_screen.dart';
import 'package:eld_mobile/features/duty_status/presentation/widgets/location_inaccurate_dialog.dart';
import 'package:eld_mobile/features/duty_status/presentation/widgets/quick_notes_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/duty_status/duty_test_harness.dart';
import '../../golden_harness.dart';
import 'm4_golden_host.dart';

void main() {
  m4GoldenMatrix(
    'm12_change_duty_status',
    child: () => const ChangeDutyStatusScreen(),
    overrides: () => m4Overrides(duty: FakeDutyStatusRepository()),
  );

  m4GoldenMatrix(
    'm13_quick_notes',
    devices: <GoldenDevice>[GoldenDevice.phone],
    child: () => const Scaffold(body: QuickNotesPicker()),
    overrides: () => m4Overrides(duty: FakeDutyStatusRepository()),
  );

  m4GoldenMatrix(
    'm14_location_inaccurate',
    devices: <GoldenDevice>[GoldenDevice.phone],
    child: () => const Scaffold(body: Center(child: LocationInaccurateDialog())),
    overrides: () => m4Overrides(duty: FakeDutyStatusRepository()),
  );
}
