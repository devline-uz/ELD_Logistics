@Timeout(Duration(seconds: 60))
/// §15.1 `PushTokenRegistrar` va M144/M145/M146 `PushCoordinator` testlari.
///
/// Firebase/APNs **kerak emas** (❓M184): butun oqim [MockPushGateway] ustida
/// ishlaydi, `google-services.json` / `GoogleService-Info.plist` talab
/// qilinmaydi.
library;

import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/notifications/data/mock_push_gateway.dart';
import 'package:eld_mobile/features/notifications/domain/app_notification.dart';
import 'package:eld_mobile/features/notifications/domain/device_registration.dart';
import 'package:eld_mobile/features/notifications/domain/local_alert.dart';
import 'package:eld_mobile/features/notifications/domain/notification_channels.dart';
import 'package:eld_mobile/features/notifications/domain/notification_repository.dart';
import 'package:eld_mobile/features/notifications/domain/push_gateway.dart';
import 'package:eld_mobile/features/notifications/domain/push_token_registrar.dart';
import 'package:eld_mobile/features/notifications/presentation/push_coordinator.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  late MockPushGateway gateway;
  late _FakeRepository repository;
  late _MemoryStore store;
  late TimeSource time;

  setUp(() {
    gateway = MockPushGateway();
    repository = _FakeRepository();
    store = _MemoryStore();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
  });

  tearDown(() async {
    await gateway.dispose();
    await time.dispose();
  });

  PushTokenRegistrar registrar({PushPlatform? platform = PushPlatform.android}) =>
      PushTokenRegistrar(
        gateway: gateway,
        repository: repository,
        identity: _FakeIdentity(platform),
        store: store,
      );

  group('§15.1 push token', () {
    test('login: token olinadi va bir marta yuboriladi', () async {
      gateway.emitToken('t-1');
      final PushTokenRegistrar sut = registrar();
      await sut.start();

      expect(repository.registered.length, 1);
      expect(repository.registered.single.token, 't-1');
      expect(repository.registered.single.platform, PushPlatform.android);
      expect(repository.registered.single.deviceId, 'device-1');

      // Qayta start — o'zgarish yo'q, takroriy POST bo'lmaydi.
      await sut.dispose();
      await registrar().start();
      expect(repository.registered.length, 1);
    });

    test('onTokenRefresh — yangi token darhol yuboriladi', () async {
      gateway.emitToken('t-1');
      final PushTokenRegistrar sut = registrar();
      await sut.start();

      gateway.emitToken('t-2');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registered.map((DeviceRegistration r) => r.token), <String>['t-1', 't-2']);
      await sut.dispose();
    });

    test('ruxsat yo\'q — token null, hech nima yuborilmaydi', () async {
      gateway
        ..emitToken('t-1')
        ..setPermission(PushPermissionStatus.denied);
      await registrar().start();
      expect(repository.registered, isEmpty);
    });

    test('noma\'lum platforma (test/desktop) — yuborilmaydi', () async {
      gateway.emitToken('t-1');
      await registrar(platform: null).start();
      expect(repository.registered, isEmpty);
    });

    test('logout: lokal token o\'chadi, server DELETE chaqirilmaydi', () async {
      gateway.emitToken('t-1');
      final PushTokenRegistrar sut = registrar();
      await sut.start();

      await sut.stop();
      expect(await gateway.token(), isNull);
      expect(store.value, isNull);
      expect(repository.registered.length, 1);
    });
  });

  group('M144/M145/M146 koordinator', () {
    late PushCoordinator coordinator;

    setUp(() {
      coordinator = PushCoordinator(
        gateway: gateway,
        repository: repository,
        time: time,
        l10n: lookupAppLocalizations(const Locale('en')),
      );
    });

    tearDown(() => coordinator.dispose());

    test('M144: bootstrap kanallarni yaratadi', () async {
      await coordinator.start();
      expect(
        gateway.channels.map((NotificationChannelSpec s) => s.id),
        kNotificationChannels.map((NotificationChannelSpec s) => s.id),
      );
    });

    test('kelgan push lokal keshga yoziladi', () async {
      await coordinator.start();
      gateway.emitMessage(
        const PushMessage(
          data: <String, String>{'notification_id': 'n1', 'alert_type': 'chat_message'},
          title: 'Dispatch',
          body: 'Call me',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(repository.ingested.single.id, 'n1');
      expect(repository.ingested.single.type, AlertType.chatMessage);
    });

    test('M145: bosilgan bildirishnoma marshrut beradi', () async {
      await coordinator.start();
      final Future<String> route = coordinator.deepLinks.first;

      gateway.emitOpened(
        const PushMessage(
          data: <String, String>{'notification_id': 'n2', 'alert_type': 'uncertified_log'},
        ),
      );

      expect(await route, '/certify');
    });

    test('M145: ilova yopiq bo\'lganda — initialDeepLink', () async {
      gateway.setInitialMessage(
        const PushMessage(
          data: <String, String>{
            'notification_id': 'n3',
            'alert_type': 'log_edit_request',
            'entity_id': 'r7',
          },
        ),
      );
      await coordinator.start();

      expect(coordinator.initialDeepLink, '/logs/pending-edits/r7');
      expect(repository.ingested.single.id, 'n3');
    });

    test('M146: lokal ogohlantirish matni lokalizatsiyalangan', () async {
      await coordinator.showLocalAlert(
        const LocalAlertRequest(kind: LocalAlertKind.hosWarning, minutesLeft: 30),
      );
      await coordinator.showLocalAlert(
        const LocalAlertRequest(kind: LocalAlertKind.eldMalfunction, malfunctionCode: 'P'),
      );

      expect(gateway.shown.first.title, 'HOS limit approaching');
      expect(gateway.shown.first.body, '30 minutes left before a violation.');
      expect(gateway.shown.first.channel, PushChannel.compliance);
      expect(gateway.shown.last.body, contains('Code P'));
      expect(gateway.shown.last.deepLink, '/eld');
    });

    test('M146: idle prompt compliance kanalida va duty ekraniga olib boradi', () async {
      await coordinator.showLocalAlert(const LocalAlertRequest(kind: LocalAlertKind.idlePrompt));
      expect(gateway.shown.single.channel, PushChannel.compliance);
      expect(gateway.shown.single.deepLink, '/duty/change');
      expect(gateway.shown.single.body, contains('5 minutes'));
    });

    test('ruxsat so\'rovi gateway ga uzatiladi', () async {
      gateway.setPermission(PushPermissionStatus.notDetermined);
      expect(await coordinator.permissionStatus(), PushPermissionStatus.notDetermined);
      expect(await coordinator.requestPermission(), PushPermissionStatus.notDetermined);
    });
  });
}

class _FakeIdentity implements DeviceIdentity {
  _FakeIdentity(this._platform);

  final PushPlatform? _platform;

  @override
  Future<String> appVersion() async => '1.4.2';

  @override
  Future<String> deviceId() async => 'device-1';

  @override
  PushPlatform? platform() => _platform;
}

class _MemoryStore implements PushTokenStore {
  String? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<bool> matches(String fingerprint) async => value == fingerprint;

  @override
  Future<void> save(String fingerprint) async => value = fingerprint;
}

class _FakeRepository implements NotificationRepository {
  final List<DeviceRegistration> registered = <DeviceRegistration>[];
  final List<AppNotification> ingested = <AppNotification>[];

  @override
  Future<void> ingest(AppNotification notification) async => ingested.add(notification);

  @override
  Future<NotificationPage> load({int page = 1, int perPage = 25}) async => NotificationPage.empty;

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> registerDevice(DeviceRegistration registration) async =>
      registered.add(registration);

  @override
  Stream<List<AppNotification>> watch() => const Stream<List<AppNotification>>.empty();

  @override
  Stream<int> watchUnreadCount() => const Stream<int>.empty();
}
