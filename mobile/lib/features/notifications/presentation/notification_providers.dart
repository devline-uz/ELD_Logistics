/// `M-43` provayderlari (DI — faqat Riverpod).
library;

import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/time/time_providers.dart';
import '../../../l10n/generated/app_localizations.dart' show lookupAppLocalizations;
import '../../auth/data/auth_providers.dart';
import '../data/mock_push_gateway.dart';
import '../data/notification_local_data_source.dart';
import '../data/notification_remote_data_source.dart';
import '../data/notification_repository_impl.dart';
import '../data/push_token_store.dart';
import '../domain/app_notification.dart';
import '../domain/device_registration.dart';
import '../domain/notification_repository.dart';
import '../domain/push_gateway.dart';
import '../domain/push_token_registrar.dart';
import 'push_coordinator.dart';

/// TODO(CORE): umumiy `dioProvider` yo'q — bootstrap override qiladi.
final Provider<Dio> notificationsDioProvider = Provider<Dio>((Ref ref) {
  throw UnimplementedError('notificationsDioProvider bootstrap da override qilinadi');
});

/// ❓**TODO(M184)**: Firebase loyihasi/APNs sertifikatlari kelgach
/// `FirebasePushGateway` bilan override qilinadi (`data/firebase_push_gateway.dart`).
/// Hozircha butun oqim mock transport ustida ishlaydi va testlar
/// `google-services.json` / `GoogleService-Info.plist` siz o'tadi.
final Provider<PushGateway> pushGatewayProvider = Provider<PushGateway>((Ref ref) {
  final MockPushGateway gateway = MockPushGateway();
  ref.onDispose(gateway.dispose);
  return gateway;
});

final Provider<NotificationRemoteDataSource> notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
      (Ref ref) => HttpNotificationRemoteDataSource(ref.watch(notificationsDioProvider)),
    );

final Provider<NotificationLocalDataSource> notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>(
      (Ref ref) => NotificationLocalDataSource(ref.watch(chatDaoProvider)),
    );

final Provider<NotificationRepository> notificationRepositoryProvider =
    Provider<NotificationRepository>(
      (Ref ref) => NotificationRepositoryImpl(
        local: ref.watch(notificationLocalDataSourceProvider),
        remote: ref.watch(notificationRemoteDataSourceProvider),
        outbox: ref.watch(outboxRepositoryProvider),
      ),
    );

/// §15.1: qurilma identifikatori (`SecureVault` + `PackageInfo`).
final Provider<DeviceIdentity> deviceIdentityProvider = Provider<DeviceIdentity>(
  (Ref ref) => VaultDeviceIdentity(
    vault: ref.watch(secureVaultProvider),
    version: () async => ref.read(appVersionProvider.future),
    platformResolver: currentPushPlatform,
  ),
);

/// Joriy platforma; test/desktop da `null` — token yuborilmaydi.
PushPlatform? currentPushPlatform() {
  if (kIsWeb) {
    return null;
  }
  if (Platform.isAndroid) {
    return PushPlatform.android;
  }
  if (Platform.isIOS) {
    return PushPlatform.ios;
  }
  return null;
}

final Provider<PushTokenStore> pushTokenStoreProvider = Provider<PushTokenStore>(
  (Ref ref) => SettingsPushTokenStore(
    dao: ref.watch(settingsDaoProvider),
    time: ref.watch(timeSourceProvider),
  ),
);

/// §15.1: login'dan keyin `start()`, logout'da `stop()` chaqiriladi.
final Provider<PushTokenRegistrar> pushTokenRegistrarProvider = Provider<PushTokenRegistrar>((
  Ref ref,
) {
  final PushTokenRegistrar registrar = PushTokenRegistrar(
    gateway: ref.watch(pushGatewayProvider),
    repository: ref.watch(notificationRepositoryProvider),
    identity: ref.watch(deviceIdentityProvider),
    store: ref.watch(pushTokenStoreProvider),
  );
  ref.onDispose(registrar.dispose);
  return registrar;
});

/// M144/M145/M146 koordinatori — bootstrap'da `start()` qilinadi.
final Provider<PushCoordinator> pushCoordinatorProvider = Provider<PushCoordinator>((Ref ref) {
  final PushCoordinator coordinator = PushCoordinator(
    gateway: ref.watch(pushGatewayProvider),
    repository: ref.watch(notificationRepositoryProvider),
    time: ref.watch(timeSourceProvider),
    l10n: lookupAppLocalizations(const Locale('en')),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// M145: router shu oqimga obuna bo'lib `context.go(route)` qiladi.
final StreamProvider<String> pushDeepLinkProvider = StreamProvider<String>(
  (Ref ref) => ref.watch(pushCoordinatorProvider).deepLinks,
);

/// Lokal keshdagi ro'yxat (oflayn ham to'la).
final StreamProvider<List<AppNotification>> notificationsProvider =
    StreamProvider<List<AppNotification>>(
      (Ref ref) => ref.watch(notificationRepositoryProvider).watch(),
    );

/// App bar qo'ng'irog'idagi badge (M89).
final StreamProvider<int> unreadNotificationsProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(notificationRepositoryProvider).watchUnreadCount(),
);

/// M143: OS darajasidagi ruxsat holati — banner shundan chiziladi.
final FutureProvider<PushPermissionStatus> pushPermissionProvider =
    FutureProvider<PushPermissionStatus>(
      (Ref ref) => ref.watch(pushGatewayProvider).permissionStatus(),
    );
