@Timeout(Duration(seconds: 60))
/// Inspection ekranlarining goldenlari (M-37…M-41) — light/dark × phone/tablet.
///
/// ⚠️ Dark maketlar Figma da yo'q; dark variant tokenlar orqali hosil bo'ladi.
library;

import 'package:eld_mobile/features/inspection/presentation/controllers/inspection_providers.dart';
import 'package:eld_mobile/features/inspection/presentation/screens/inspection_kiosk_screen.dart';
import 'package:eld_mobile/features/inspection/presentation/screens/inspection_report_screen.dart';
import 'package:eld_mobile/features/inspection/presentation/widgets/exit_pin_dialog.dart';
import 'package:eld_mobile/features/inspection/presentation/widgets/send_email_sheet.dart';
import 'package:eld_mobile/features/inspection/presentation/widgets/send_file_sheet.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/inspection/inspection_test_harness.dart';
import '../golden_screen_host.dart';

List<Override> _overrides() => <Override>[
  inspectionRepositoryProvider.overrideWithValue(FakeInspectionRepository()),
  inspectionPinVerifierProvider.overrideWithValue(FakeInspectionPinVerifier()),
];

void main() {
  screenGoldenMatrix(
    'inspection_report',
    builder: () => const InspectionReportScreen(),
    overrides: _overrides,
  );

  screenGoldenMatrix(
    'inspection_kiosk',
    builder: () => const InspectionKioskScreen(),
    overrides: _overrides,
  );

  screenGoldenMatrix(
    'inspection_send_email',
    builder: () => sheetHost(const SendEmailSheet()),
    overrides: _overrides,
  );

  screenGoldenMatrix(
    'inspection_send_file',
    builder: () => sheetHost(const SendFileSheet()),
    overrides: _overrides,
  );

  screenGoldenMatrix(
    'inspection_exit_pin',
    builder: () => const ExitPinDialog(),
    overrides: _overrides,
  );
}
