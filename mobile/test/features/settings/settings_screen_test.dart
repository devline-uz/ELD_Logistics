@Timeout(Duration(seconds: 60))
/// **M-45 Settings** widget testlari — `Diagnosis of device`, `App updates`
/// (joriy/oxirgi versiya, `Update` tugmasi), M143 bildirishnoma toggle'lari.
library;

import 'dart:async';

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/profile/domain/app_config_info.dart';
import 'package:eld_mobile/features/settings/domain/notification_prefs.dart';
import 'package:eld_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/m11_test_harness.dart';

class _GatedConfigRepository extends FakeAppConfigRepository {
  _GatedConfigRepository(this.gate);

  final Completer<void> gate;

  @override
  Future<AppConfigInfo> load() async {
    await gate.future;
    return super.load();
  }
}

/// Figma `1131:392`: kartada faqat ikki band — versiya ma'lumoti `App updates`
/// modalida. Har test uni ochib tekshiradi.
Future<void> openAppUpdates(WidgetTester tester) async {
  await tester.tap(find.text(l10n.settingsAppUpdates));
  await settle(tester);
}

void main() {
  group('M-45 Settings', () {
    testWidgets('to\'la holat: ikki band + versiya qatorlari', (WidgetTester tester) async {
      await pumpM11Screen(tester, const SettingsScreen(), overrides: m11Overrides());

      expect(find.text(l10n.settingsDiagnosis), findsOneWidget);
      expect(find.text(l10n.settingsAppUpdates), findsOneWidget);
      // Figma: kartada versiya qatorlari yo'q — ular modalda.
      expect(find.text(l10n.settingsCurrentVersionLabel), findsNothing);

      await openAppUpdates(tester);
      expect(find.text(l10n.settingsCurrentVersionLabel), findsOneWidget);
      expect(find.text(l10n.settingsLatestVersionLabel), findsOneWidget);
      expect(find.text('1.0.0'), findsNWidgets(2));
      // Versiyalar teng — `Update` tugmasi o'rniga «up to date».
      expect(find.text(l10n.settingsUpToDate), findsOneWidget);
      expect(appButton(l10n.settingsUpdateAction), findsNothing);
    });

    testWidgets('yangi versiya bo\'lsa `Update` tugmasi chiqadi', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const SettingsScreen(),
        overrides: m11Overrides(
          config: FakeAppConfigRepository(config: const AppConfigInfo(latestVersion: '2.1.0')),
        ),
      );
      await openAppUpdates(tester);
      expect(find.text('2.1.0'), findsOneWidget);
      expect(appButton(l10n.settingsUpdateAction), findsOneWidget);
    });

    testWidgets('`latest_version` bo\'lmasa `N/A` (M92)', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const SettingsScreen(),
        overrides: m11Overrides(config: FakeAppConfigRepository(config: const AppConfigInfo())),
      );
      await openAppUpdates(tester);
      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('yuklanish: skeleton', (WidgetTester tester) async {
      final Completer<void> gate = Completer<void>();
      await pumpM11Screen(
        tester,
        const SettingsScreen(),
        overrides: m11Overrides(config: _GatedConfigRepository(gate)),
      );
      await openAppUpdates(tester);
      expect(find.byType(SkeletonBox), findsWidgets);
      gate.complete();
      await settle(tester);
      expect(find.text(l10n.settingsLatestVersionLabel), findsOneWidget);
    });

    testWidgets('xato holati: ErrorState + Retry', (WidgetTester tester) async {
      final FakeAppConfigRepository config = FakeAppConfigRepository(error: kServerError);
      await pumpM11Screen(tester, const SettingsScreen(), overrides: m11Overrides(config: config));

      await openAppUpdates(tester);
      expect(find.byType(ErrorState), findsOneWidget);
      config.error = null;
      await tester.tap(find.text(l10n.commonRetry));
      await settle(tester);
      expect(find.byType(ErrorState), findsNothing);
      expect(find.text(l10n.settingsLatestVersionLabel), findsOneWidget);
    });

    testWidgets('M143: majburiy alert turlari o\'chirilgan toggle bilan', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(tester, const SettingsScreen(), overrides: m11Overrides());

      await scrollTo(tester, find.text(l10n.settingsNotifications));
      final AlertType locked = AlertType.values.firstWhere((AlertType t) => t.isLocked);
      await scrollTo(tester, find.text(alertTypeLabel(l10n, locked)));

      final Finder row = find.ancestor(
        of: find.text(alertTypeLabel(l10n, locked)),
        matching: find.byType(Row),
      );
      // #B-18: Material `Switch` emas, `AppSwitch`.
      final AppSwitch toggle = tester.widget<AppSwitch>(
        find.descendant(of: row.first, matching: find.byType(AppSwitch)),
      );
      expect(toggle.onChanged, isNull);
      expect(find.text(l10n.settingsNotificationsLocked), findsWidgets);
    });

    testWidgets('erkin alert toggle\'i almashadi', (WidgetTester tester) async {
      await pumpM11Screen(tester, const SettingsScreen(), overrides: m11Overrides());

      final AlertType free = AlertType.values.firstWhere((AlertType t) => !t.isLocked);
      final String label = alertTypeLabel(l10n, free);
      await scrollTo(tester, find.text(label));

      final Finder toggle = find.descendant(
        of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
        matching: find.byType(AppSwitch),
      );
      final bool before = tester.widget<AppSwitch>(toggle).value;
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(tester.widget<AppSwitch>(toggle).value, isNot(before));
    });

    testWidgets('til bo\'limi: faqat English (M92)', (WidgetTester tester) async {
      await pumpM11Screen(tester, const SettingsScreen(), overrides: m11Overrides());
      await scrollTo(tester, find.text(l10n.settingsLanguage));
      expect(find.text(l10n.settingsLanguageEnglish), findsOneWidget);
      expect(find.text(l10n.settingsLanguageOnlyEnglish), findsOneWidget);
    });

    testWidgets('planshet: ikki ustunli tartib, bitta kontroller (M7)', (
      WidgetTester tester,
    ) async {
      final FakeAppConfigRepository config = FakeAppConfigRepository();
      await pumpM11Screen(
        tester,
        const SettingsScreen(),
        overrides: m11Overrides(config: config),
        surface: const Size(1366, 1024),
      );
      expect(find.text(l10n.settingsDiagnosis), findsOneWidget);
      expect(find.text(l10n.settingsNotifications), findsOneWidget);
      // Modal planshetda `TabletModal` sifatida ochiladi, kontroller bitta.
      await openAppUpdates(tester);
      expect(find.text(l10n.settingsLatestVersionLabel), findsOneWidget);
      expect(config.calls.length, 1);
    });
  });
}
