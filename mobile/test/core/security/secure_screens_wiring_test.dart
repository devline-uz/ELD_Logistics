@Timeout(Duration(seconds: 60))
/// **M157 / #B-139** — `SecureScreenMixin` haqiqiy ekranlarga ulanganmi.
///
/// Mixin'ning o'zi `screen_protection_test.dart` da tekshirilgan; bu yerda
/// aynan **ulanish** tekshiriladi: `M-30 Sign` va `M-38 Begin inspection`
/// ochilganda `FLAG_SECURE` yoqiladi va ekrandan chiqishda **majburiy**
/// o'chiriladi (aks holda butun ilova skrinshotsiz qolib ketardi).
library;

import 'package:eld_mobile/core/security/screen_protection.dart';
import 'package:eld_mobile/features/certify/presentation/screens/certify_sign_screen.dart';
import 'package:eld_mobile/features/inspection/presentation/screens/inspection_kiosk_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/inspection/inspection_test_harness.dart';
import '../../features/logs/m7_test_harness.dart';

/// `setSecure` chaqiruvlarini yozib boruvchi soxta platforma.
class _RecordingPlatform {
  _RecordingPlatform(this.channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        if (call.method == ScreenSecurityChannels.setSecure) {
          secureCalls.add(call.arguments as bool);
        }
        return null;
      },
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
  }

  final MethodChannel channel;
  final List<bool> secureCalls = <bool>[];
}

void main() {
  const MethodChannel channel = MethodChannel(ScreenSecurityChannels.method);

  testWidgets('M-30 Sign: kirishda FLAG_SECURE yoqiladi, chiqishda o\'chadi', (
    WidgetTester tester,
  ) async {
    final _RecordingPlatform platform = _RecordingPlatform(channel);
    final ScreenProtection protection = ScreenProtection(
      channel: channel,
      // Event kanali faqat iOS'da mavjud — testda obuna bo'linmaydi.
      iosEvents: false,
    );

    await pumpM7(
      tester,
      CertifySignScreen(date: DateTime(2026, 9, 7)),
      extraOverrides: <Override>[screenProtectionProvider.overrideWithValue(protection)],
    );

    expect(platform.secureCalls, contains(true), reason: 'M157: imzo ekrani himoyalanadi');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(platform.secureCalls.last, isFalse, reason: 'M157: chiqishda flag MAJBURIY tozalanadi');
  });

  testWidgets('M-38 kiosk: kirishda FLAG_SECURE yoqiladi, chiqishda o\'chadi', (
    WidgetTester tester,
  ) async {
    final _RecordingPlatform platform = _RecordingPlatform(channel);
    final ScreenProtection protection = ScreenProtection(channel: channel, iosEvents: false);

    await pumpInspectionScreen(
      tester,
      const InspectionKioskScreen(),
      repository: FakeInspectionRepository(report: buildTestInspectionReport()),
      extraOverrides: <Override>[screenProtectionProvider.overrideWithValue(protection)],
    );

    expect(platform.secureCalls, contains(true), reason: 'M157: kiosk rejimi himoyalanadi');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(platform.secureCalls.last, isFalse, reason: 'M157: chiqishda flag MAJBURIY tozalanadi');
  });
}
