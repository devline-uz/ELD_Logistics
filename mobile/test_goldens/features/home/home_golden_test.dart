@Timeout(Duration(seconds: 120))
/// `M-09`, `M-10`, `M-11` golden testlari (light/dark × phone/tablet).
///
/// Yangilash: `flutter test test_goldens --update-goldens`.
library;

import 'package:eld_mobile/core/device/device_profile.dart';
import 'package:eld_mobile/core/i18n/l10n_extension.dart';
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

  // #B-06: Figma freymida pastki navigatsiya bor — u `_MainShell` da yashaydi,
  // shuning uchun goldenda ham shell bilan birga chiziladi.
  m4GoldenMatrix(
    'm09_home',
    child: () => const _HomeShell(),
    overrides: () => m4Overrides(
      duty: FakeDutyStatusRepository(),
      home: FakeHomeRepository(certifyDays: testCertifyDays(), pendingEdits: 2),
    ),
  );

  // Figma freymi 393x1650 — telefon ekranidan uzun. To'liq sahifa pariteti
  // (Signature va Logs kartalari) shu goldenda tekshiriladi.
  m4GoldenMatrix(
    'm09_home_full',
    devices: <GoldenDevice>[GoldenDevice.phone],
    size: const Size(393, 1650),
    child: () => const _HomeShell(),
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

/// `_MainShell` ning golden ekvivalenti (`core/router` ga tegmasdan).
class _HomeShell extends StatelessWidget {
  const _HomeShell();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: const HomeScreen(),
    // Pastki tab navigatsiyasi — **faqat telefon** profilida (M6).
    bottomNavigationBar: DeviceProfile.of(context).isTablet
        ? null
        : AppNavBar(
            currentIndex: 0,
            onSelected: (int _) {},
            items: <AppNavItem>[
              AppNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: context.l10n.navHome,
              ),
              AppNavItem(
                icon: Icons.article_outlined,
                selectedIcon: Icons.article,
                label: context.l10n.navLogs,
              ),
              AppNavItem(
                icon: Icons.chat_bubble_outline,
                selectedIcon: Icons.chat_bubble,
                label: context.l10n.navChat,
              ),
              AppNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: context.l10n.navProfile,
              ),
            ],
          ),
  );
}
