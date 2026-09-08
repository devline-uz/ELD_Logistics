/// [PushGateway] ning mock implementatsiyasi.
///
/// **Firebase/APNs sozlash bu bosqichda yo'q** (TZ C.2 9-bosqich) — ilova
/// mantiqi (ro'yxatga olish, deep link, M143 banneri, M146 lokal
/// bildirishnomalari) shu mock bilan to'liq sinovdan o'tadi.
/// TODO(M0.x): `FirebasePushGateway` (`firebase_messaging`) + lokal
/// bildirishnoma plagini keyingi bosqichda qo'shiladi.
library;

import 'dart:async';

import '../domain/notification_channels.dart';
import '../domain/push_gateway.dart';

class MockPushGateway implements PushGateway {
  MockPushGateway({this._token, this._status = PushPermissionStatus.granted});

  String? _token;
  PushPermissionStatus _status;

  final StreamController<String> _tokens = StreamController<String>.broadcast();
  final StreamController<PushMessage> _messages = StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> _opened = StreamController<PushMessage>.broadcast();

  /// Test/dev uchun: ko'rsatilgan lokal bildirishnomalar tarixi.
  final List<LocalNotification> shown = <LocalNotification>[];

  /// M144: yaratilgan kanallar (test tekshiruvi uchun).
  final List<NotificationChannelSpec> channels = <NotificationChannelSpec>[];

  PushMessage? _initial;

  @override
  Future<void> ensureChannels(List<NotificationChannelSpec> specs) async {
    channels
      ..clear()
      ..addAll(specs);
  }

  @override
  Future<String?> token() async => _status == PushPermissionStatus.granted ? _token : null;

  @override
  Stream<String> tokenRefresh() => _tokens.stream;

  @override
  Future<PushPermissionStatus> permissionStatus() async => _status;

  @override
  Future<PushPermissionStatus> requestPermission() async => _status;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Stream<PushMessage> messages() => _messages.stream;

  @override
  Stream<PushMessage> opened() => _opened.stream;

  @override
  Future<PushMessage?> initialMessage() async => _initial;

  @override
  Future<void> showLocal(LocalNotification notification) async => shown.add(notification);

  @override
  Future<void> deleteToken() async => _token = null;

  // --- test boshqaruvi ----------------------------------------------------

  void setPermission(PushPermissionStatus status) => _status = status;

  void setInitialMessage(PushMessage? message) => _initial = message;

  void emitToken(String token) {
    _token = token;
    _tokens.add(token);
  }

  void emitMessage(PushMessage message) => _messages.add(message);

  void emitOpened(PushMessage message) => _opened.add(message);

  Future<void> dispose() async {
    await _tokens.close();
    await _messages.close();
    await _opened.close();
  }
}
