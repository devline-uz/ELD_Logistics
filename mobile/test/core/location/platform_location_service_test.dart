@Timeout(Duration(seconds: 30))
/// Regressiya #B-2: `MissingPluginException(No implementation found for method
/// stop on channel eld/location)` real qurilmada logout/login yo'lida ilovani
/// yiqitgan edi. Platforma kanali ro'yxatdan o'tmagan bo'lsa xizmat **jimgina
/// degrade** bo'lishi kerak.
library;

import 'package:eld_mobile/core/location/location_models.dart';
import 'package:eld_mobile/core/location/platform_location_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlatformLocationService service;

  setUp(() {
    service = PlatformLocationService(now: () => DateTime.utc(2025, 5, 28, 19, 40));
  });

  tearDown(() async {
    await service.dispose();
  });

  test('kanal yo\'q bo\'lsa start istisno tashlamaydi', () async {
    // Handler o'rnatilmagan → `invokeMethod` `MissingPluginException` beradi.
    await expectLater(service.start(LocationProfile.driving), completes);
    expect(service.unsupported, isTrue);
  });

  test('kanal yo\'q bo\'lsa stop ham istisno tashlamaydi', () async {
    await expectLater(service.stop(), completes);
    expect(service.unsupported, isTrue);
  });

  test('platforma xatosi (`PlatformException`) ham yutiladi', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      kLocationChannel,
      (MethodCall call) async => throw PlatformException(code: 'PERMISSION_DENIED'),
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kLocationChannel, null),
    );

    await expectLater(service.start(LocationProfile.driving), completes);
    // Kanal bor — faqat chaqiruv rad etilgan, degrade bayrog'i qo'yilmaydi.
    expect(service.unsupported, isFalse);
  });

  test('kanal ishlaganda start oqimga obuna bo\'ladi', () async {
    final List<String> calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      kLocationChannel,
      (MethodCall call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(kLocationChannel, null),
    );

    await service.start(LocationProfile.driving);
    await service.stop();

    expect(calls, <String>['start', 'stop']);
    expect(service.unsupported, isFalse);
  });
}
