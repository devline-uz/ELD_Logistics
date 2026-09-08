@Timeout(Duration(seconds: 120))
/// `M-09`, `M-10`, `M-11` golden testlari (light/dark × phone/tablet).
///
/// Yangilash: `flutter test test_goldens --update-goldens`.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/home/domain/home_models.dart';
import 'package:eld_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:eld_mobile/features/home/presentation/widgets/edit_documents_sheet.dart';
import 'package:eld_mobile/features/home/presentation/widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/duty_status/duty_test_harness.dart';
import '../../golden_harness.dart';
import '../duty_status/m4_golden_host.dart';

void main() {
  setUpAll(() => SkeletonConfig.animationsEnabled = false);
  tearDownAll(() => SkeletonConfig.animationsEnabled = true);

  m4GoldenMatrix(
    'm09_home',
    child: () => const HomeScreen(),
    overrides: () => m4Overrides(
      duty: FakeDutyStatusRepository(),
      home: FakeHomeRepository(certifyDays: testCertifyDays(), pendingEdits: 2),
    ),
  );

  m4GoldenMatrix(
    'm10_drawer',
    devices: <GoldenDevice>[GoldenDevice.phone],
    child: () => Scaffold(
      body: HomeDrawer(driver: kTestDriver, onAction: (HomeDrawerAction _) {}),
    ),
    overrides: () => m4Overrides(duty: FakeDutyStatusRepository()),
  );

  m4GoldenMatrix(
    'm11_edit_documents',
    devices: <GoldenDevice>[GoldenDevice.phone],
    child: () => const Scaffold(
      body: EditDocumentsForm(
        trip: TripDetails(
          shippingDocs: <String>['SD-42'],
          trailers: <String>['T-880'],
          notes: 'Lorem Ipsum',
        ),
      ),
    ),
    overrides: () => m4Overrides(duty: FakeDutyStatusRepository()),
  );
}
