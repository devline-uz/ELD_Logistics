/// M144/M145/M146 — push oqimlarini ilova holatiga ulaydigan koordinator.
///
/// Vazifalari:
///  * bootstrap'da kanallarni yaratish (M144) va ruxsatni tekshirish;
///  * kelgan push'ni lokal keshga yozish (ro'yxat darhol yangilanadi);
///  * bosilgan bildirishnoma → **marshrut satri** (M145) — navigatsiyani
///    `core/router` bajaradi, bu sinf `go_router` ni bilmaydi;
///  * M146 lokal bildirishnomalarini ko'rsatish (matn `AppLocalizations` dan).
library;

import 'dart:async';

import '../../../core/i18n/l10n_extension.dart';
import '../../../core/time/time_source.dart';
import '../../../core/ui/formats.dart';
import '../domain/app_notification.dart';
import '../domain/local_alert.dart';
import '../domain/notification_channels.dart';
import '../domain/notification_deeplink.dart';
import '../domain/notification_repository.dart';
import '../domain/push_gateway.dart';
import '../domain/push_message_mapper.dart';

class PushCoordinator {
  PushCoordinator({
    required this._gateway,
    required this._repository,
    required this._time,
    required this._l10n,
  });

  final PushGateway _gateway;
  final NotificationRepository _repository;
  final TimeSource _time;
  final AppLocalizations _l10n;

  final StreamController<String> _deepLinks = StreamController<String>.broadcast();

  StreamSubscription<PushMessage>? _messagesSub;
  StreamSubscription<PushMessage>? _openedSub;

  /// M145: ochilishi kerak bo'lgan marshrutlar (`/logs?date=…`, `/chat`, …).
  Stream<String> get deepLinks => _deepLinks.stream;

  /// Ilova yopiq bo'lganda bosilgan bildirishnoma marshruti (bootstrap
  /// `initialLocation` uchun) — obuna boshlanishidan oldin o'qiladi.
  String? initialDeepLink;

  /// Bootstrap: kanallar → oqimlar → sovuq start deep link.
  Future<void> start() async {
    await _gateway.ensureChannels(kNotificationChannels);
    _messagesSub ??= _gateway.messages().listen(_onMessage);
    _openedSub ??= _gateway.opened().listen(_onOpened);
    final PushMessage? initial = await _gateway.initialMessage();
    if (initial != null) {
      await _cache(initial);
      initialDeepLink = deepLinkFromPayload(initial.data);
    }
  }

  /// Android 13+ `POST_NOTIFICATIONS` / iOS `requestAuthorization`.
  Future<PushPermissionStatus> requestPermission() => _gateway.requestPermission();

  Future<PushPermissionStatus> permissionStatus() => _gateway.permissionStatus();

  /// M143 banneridagi `Enable` tugmasi.
  Future<void> openSystemSettings() => _gateway.openSystemSettings();

  /// **M146** — lokal bildirishnoma; matn shu yerda lokalizatsiya qilinadi.
  Future<void> showLocalAlert(LocalAlertRequest request) => _gateway.showLocal(
    LocalNotification(
      id: request.notificationId,
      title: _title(request),
      body: _body(request),
      type: request.alertType ?? AlertType.hosWarning,
      deepLink: request.deepLink,
    ),
  );

  Future<void> dispose() async {
    await _messagesSub?.cancel();
    await _openedSub?.cancel();
    await _deepLinks.close();
  }

  // --- ichki ---------------------------------------------------------------

  void _onMessage(PushMessage message) => unawaited(_cache(message));

  void _onOpened(PushMessage message) {
    unawaited(_cache(message));
    final String? route = deepLinkFromPayload(message.data);
    if (route != null && !_deepLinks.isClosed) {
      _deepLinks.add(route);
    }
  }

  Future<void> _cache(PushMessage message) async {
    final AppNotification? notification = notificationFromPush(
      message,
      receivedAt: message.receivedAt ?? _time.now(),
    );
    if (notification != null) {
      await _repository.ingest(notification);
    }
  }

  String _title(LocalAlertRequest request) => switch (request.kind) {
    LocalAlertKind.hosWarning => _l10n.notifLocalHosWarningTitle,
    LocalAlertKind.hosViolation => _l10n.notifLocalHosViolationTitle,
    LocalAlertKind.idlePrompt => _l10n.notifLocalIdleTitle,
    LocalAlertKind.eldDisconnected => _l10n.notifLocalEldDisconnectedTitle,
    LocalAlertKind.eldMalfunction => _l10n.notifLocalEldMalfunctionTitle,
    LocalAlertKind.syncConflict => _l10n.notifLocalSyncConflictTitle,
  };

  String _body(LocalAlertRequest request) => switch (request.kind) {
    LocalAlertKind.hosWarning => _l10n.notifLocalHosWarningBody(request.minutesLeft ?? 0),
    LocalAlertKind.hosViolation => _l10n.notifLocalHosViolationBody,
    LocalAlertKind.idlePrompt => _l10n.notifLocalIdleBody,
    LocalAlertKind.eldDisconnected => _l10n.notifLocalEldDisconnectedBody,
    LocalAlertKind.eldMalfunction => _l10n.notifLocalEldMalfunctionBody(
      request.malfunctionCode ?? kEmptyValue,
    ),
    LocalAlertKind.syncConflict => _l10n.notifLocalSyncConflictBody,
  };
}
