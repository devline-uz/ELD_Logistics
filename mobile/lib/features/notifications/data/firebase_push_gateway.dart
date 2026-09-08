/// ❓**M184 (bloklovchi)** — Firebase loyihasi va APNs sertifikatlari hali
/// buyurtmachidan olinmagan.
///
/// Shu sababli `firebase_core`/`firebase_messaging` paketlari ilovaga
/// **ulanmagan**: ular bo'lmasa `google-services.json` /
/// `GoogleService-Info.plist` ham talab qilinmaydi va butun M9 mantiqi
/// ([PushGateway] porti orqali) [MockPushGateway] bilan sinovdan o'tadi.
///
/// Bu fayl — ulash nuqtasining hujjatlashtirilgan «rozetkasi». Sertifikatlar
/// kelgach faqat shu sinf to'ldiriladi va `pushGatewayProvider` shunga
/// almashtiriladi; boshqa hech qayerda o'zgarish kerak emas.
library;

import '../domain/notification_channels.dart';
import '../domain/push_gateway.dart';

/// Firebase yoqilganmi (build-time bayroq). `false` bo'lganda ilova
/// [MockPushGateway] bilan ishlaydi va push funksiyalari sukut saqlaydi.
const bool kFirebasePushEnabled = bool.fromEnvironment('ENABLE_FIREBASE_PUSH');

/// TODO(M184): `firebase_messaging` ulangach shu sinf implementatsiya qilinadi:
///  * `Firebase.initializeApp()` bootstrap'da (main.dart);
///  * `FirebaseMessaging.instance.getToken()` → [token];
///  * `onTokenRefresh` → [tokenRefresh];
///  * `requestPermission()` → [requestPermission] (iOS + Android 13+);
///  * `onMessage` / `onMessageOpenedApp` / `getInitialMessage` → oqimlar;
///  * `flutter_local_notifications` → [ensureChannels] va [showLocal].
class FirebasePushGateway implements PushGateway {
  const FirebasePushGateway();

  Never _notWired() => throw UnsupportedError(
    'FirebasePushGateway M184 hal bo\'lguncha ulanmagan — MockPushGateway ishlatiladi',
  );

  @override
  Future<void> ensureChannels(List<NotificationChannelSpec> channels) async => _notWired();

  @override
  Future<String?> token() async => _notWired();

  @override
  Stream<String> tokenRefresh() => _notWired();

  @override
  Future<PushPermissionStatus> permissionStatus() async => _notWired();

  @override
  Future<PushPermissionStatus> requestPermission() async => _notWired();

  @override
  Future<void> openSystemSettings() async => _notWired();

  @override
  Stream<PushMessage> messages() => _notWired();

  @override
  Stream<PushMessage> opened() => _notWired();

  @override
  Future<PushMessage?> initialMessage() async => _notWired();

  @override
  Future<void> showLocal(LocalNotification notification) async => _notWired();

  @override
  Future<void> deleteToken() async => _notWired();
}
