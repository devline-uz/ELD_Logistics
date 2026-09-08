@Timeout(Duration(seconds: 60))
/// **S-H5 / M157 / M158** — ekran himoyasi wrapper'i.
///
/// Tekshiriladi: kanal nomi va argument shakli (map emas, sof `bool`),
/// `INVALID_ARGUMENT` xatosining yutilishi, iOS event kanali va Android'da
/// unga **obuna bo'linmasligi**, hamda mixin `initState`/`dispose` shartnomasi
/// (M157: chiqishda flag majburiy tozalanadi).
library;

import 'package:eld_mobile/core/security/screen_protection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kanal chaqiruvlarini yozib boradigan soxta platforma.
class _FakePlatform {
  _FakePlatform(this.channel) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        calls.add(call);
        switch (call.method) {
          case ScreenSecurityChannels.setSecure:
            if (call.arguments is! bool) {
              throw PlatformException(
                code: ScreenSecurityChannels.invalidArgument,
                message: 'setSecure kutilgan argument: bool',
              );
            }
            secure = call.arguments as bool;
            return null;
          case ScreenSecurityChannels.isSecure:
            return secure;
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
  final List<MethodCall> calls = <MethodCall>[];
  bool secure = false;
}

/// Mixin'ni tekshirish uchun eng kichik ekran.
class _GuardedScreen extends ConsumerStatefulWidget {
  const _GuardedScreen();

  @override
  ConsumerState<_GuardedScreen> createState() => _GuardedScreenState();
}

class _GuardedScreenState extends ConsumerState<_GuardedScreen>
    with SecureScreenMixin<_GuardedScreen> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(ScreenSecurityChannels.method);

  test('kanal nomlari platforma kodi bilan bir xil', () {
    expect(ScreenSecurityChannels.method, 'uz.stackyard.eld_mobile/screen_security');
    expect(ScreenSecurityChannels.events, 'uz.stackyard.eld_mobile/screen_security_events');
  });

  test('setSecure argumentni sof bool sifatida yuboradi (map emas)', () async {
    final _FakePlatform platform = _FakePlatform(channel);
    final ScreenProtection protection = ScreenProtection(channel: channel);

    await protection.setSecure(true);
    expect(await protection.isSecure(), isTrue);
    await protection.setSecure(false);
    expect(await protection.isSecure(), isFalse);

    expect(platform.calls.first.method, ScreenSecurityChannels.setSecure);
    expect(platform.calls.first.arguments, isA<bool>());
    expect(platform.calls.first.arguments, true);
    expect(protection.lastError, isNull);
  });

  test('kanal yo\'q bo\'lsa ilova yiqilmaydi', () async {
    final ScreenProtection protection = ScreenProtection(
      channel: const MethodChannel('uz.stackyard.eld_mobile/missing_channel'),
    );

    await expectLater(protection.setSecure(true), completes);
    expect(await protection.isSecure(), isFalse);
  });

  test('platforma xatosi lastError da qoladi, istisno tashlanmaydi', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async =>
          throw PlatformException(code: ScreenSecurityChannels.invalidArgument, message: 'bad arg'),
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final ScreenProtection protection = ScreenProtection(channel: channel);

    await protection.setSecure(true);

    expect(protection.lastError?.code, ScreenSecurityChannels.invalidArgument);
  });

  test('Android: event kanaliga obuna bo\'linmaydi (kanal mavjud emas)', () async {
    final ScreenProtection protection = ScreenProtection(channel: channel, iosEvents: false);

    expect(await protection.captureEvents().isEmpty, isTrue);
  });

  test('iOS eventlari enum ga o\'giriladi', () {
    expect(ScreenCaptureEvent.parse('screenshotTaken'), ScreenCaptureEvent.screenshotTaken);
    expect(
      ScreenCaptureEvent.parse('screenRecordingStarted'),
      ScreenCaptureEvent.screenRecordingStarted,
    );
    expect(
      ScreenCaptureEvent.parse('screenRecordingStopped'),
      ScreenCaptureEvent.screenRecordingStopped,
    );
    expect(ScreenCaptureEvent.parse('boshqa'), isNull);
  });

  testWidgets('M157: mixin kirishda yoqadi, chiqishda MAJBURIY o\'chiradi', (
    WidgetTester tester,
  ) async {
    final _FakePlatform platform = _FakePlatform(channel);
    final ScreenProtection protection = ScreenProtection(channel: channel);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[screenProtectionProvider.overrideWithValue(protection)],
        child: const MaterialApp(home: _GuardedScreen()),
      ),
    );
    await tester.pump();

    expect(platform.secure, isTrue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[screenProtectionProvider.overrideWithValue(protection)],
        child: const MaterialApp(home: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    expect(platform.secure, isFalse);
  });
}
