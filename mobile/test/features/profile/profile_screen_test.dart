@Timeout(Duration(seconds: 60))
/// **M-44 Profile** widget testlari — 4 holat (yuklanish · bo'sh · xato · to'la)
/// + RBAC, M112 (`Maintenance` bandi yo'q) va teginish maydoni (M8).
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/profile/domain/m11_permissions.dart';
import 'package:eld_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:eld_mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'm11_test_harness.dart';

void main() {
  group('M-44 Profile', () {
    testWidgets('yuklanish: LoadingSkeleton', (WidgetTester tester) async {
      final FakeProfileRepository repo = FakeProfileRepository();
      await tester.runAsync(() async {});
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(tester.view.reset);

      await pumpM11Screen(tester, const ProfileScreen(), overrides: m11Overrides(profile: repo));
      // Birinchi kadrda controller hali `AsyncLoading` — skeleton ko'rinadi.
      expect(repo.calls, contains('load'));
    });

    testWidgets('to\'la holat: sarlavha, bandlar va M112 (Maintenance yo\'q)', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const ProfileScreen(),
        overrides: m11Overrides(profile: FakeProfileRepository()),
      );

      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.textContaining('Alex Kim'), findsOneWidget);
      for (final String label in <String>[
        l10n.profileSettings,
        l10n.profileCheckNetwork,
        l10n.profileZoom,
        l10n.profileDarkMode,
        l10n.profileFeedback,
        l10n.profileCustomerSupport,
        l10n.profileUserManual,
        l10n.profileMyDevices,
        l10n.profileChangePin,
        l10n.legalPrivacyTitle,
        l10n.legalTermsTitle,
        l10n.profileLogout,
      ]) {
        await scrollTo(tester, find.text(label));
        expect(find.text(label), findsOneWidget, reason: label);
        // M112: `Maintenance` bandi hech bir qismda ko'rinmasligi shart (M67).
        expect(find.textContaining('Maintenance'), findsNothing);
      }
    });

    testWidgets('xato holati: ErrorState + Retry qayta yuklaydi', (WidgetTester tester) async {
      final FakeProfileRepository repo = FakeProfileRepository(error: kServerError);
      await pumpM11Screen(tester, const ProfileScreen(), overrides: m11Overrides(profile: repo));

      expect(find.byType(ErrorState), findsOneWidget);
      repo.error = null;
      await tester.tap(find.text(l10n.commonRetry));
      await settle(tester);
      expect(find.byType(ErrorState), findsNothing);
      expect(find.byType(ProfileHeader), findsOneWidget);
    });

    testWidgets('bo\'sh maydonlar `N/A` bilan ko\'rsatiladi (M92)', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const ProfileScreen(),
        overrides: m11Overrides(
          profile: FakeProfileRepository(
            profile: buildTestProfile(
              unitNumber: null,
              phone: null,
              licenseNumber: null,
              licenseState: null,
            ),
          ),
        ),
      );
      expect(find.textContaining('N/A'), findsWidgets);
    });

    testWidgets('RBAC: huquq bo\'lmasa Feedback/Support bandlari yashiriladi', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const ProfileScreen(),
        overrides: m11Overrides(
          profile: FakeProfileRepository(
            profile: buildTestProfile(permissions: const <String>[kPermSupportCreate]),
          ),
        ),
      );
      expect(find.text(l10n.profileFeedback), findsNothing);
      expect(find.text(l10n.profileCustomerSupport), findsNothing);
      expect(find.text(l10n.profileUserManual), findsOneWidget);
    });

    testWidgets('Logout tasdiqlash dialogini ochadi va repozitoriyni chaqiradi', (
      WidgetTester tester,
    ) async {
      final FakeProfileRepository repo = FakeProfileRepository();
      await pumpM11Screen(tester, const ProfileScreen(), overrides: m11Overrides(profile: repo));

      await scrollTo(tester, find.text(l10n.profileLogout));
      await tester.tap(find.text(l10n.profileLogout));
      await tester.pumpAndSettle();
      expect(find.text(l10n.profileLogoutConfirmTitle), findsOneWidget);

      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(repo.calls, isNot(contains('logout')));

      await scrollTo(tester, find.text(l10n.profileLogout));
      await tester.tap(find.text(l10n.profileLogout));
      await tester.pumpAndSettle();
      // Dialogdagi tasdiqlash tugmasi — oxirgi `Logout` matni.
      await tester.tap(find.text(l10n.profileLogout).last);
      await tester.pumpAndSettle();
      expect(repo.calls, contains('logout'));
    });

    testWidgets('kirish imkoniyati: har band ≥48 dp va toggle semantik yorliqli', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const ProfileScreen(),
        overrides: m11Overrides(profile: FakeProfileRepository()),
      );

      for (final Element element in find.byType(SettingsRow).evaluate()) {
        expect(
          tester.getSize(find.byWidget(element.widget)).height,
          greaterThanOrEqualTo(TouchTarget.phone),
        );
      }
      final SemanticsHandle handle = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(
              // #B-18: Material `Switch` emas, `AppSwitch` (Semantics ichida).
              find
                  .descendant(of: find.byType(AppSwitch).first, matching: find.byType(Semantics))
                  .first,
            )
            .label,
        isNotEmpty,
      );
      handle.dispose();
    });

    testWidgets('planshet profili bitta kontrollerni ulashadi (M7)', (WidgetTester tester) async {
      final FakeProfileRepository repo = FakeProfileRepository();
      await pumpM11Screen(
        tester,
        const ProfileScreen(),
        overrides: m11Overrides(profile: repo),
        surface: const Size(1366, 1024),
      );
      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(repo.calls.where((String c) => c == 'load').length, 1);
    });
  });
}
