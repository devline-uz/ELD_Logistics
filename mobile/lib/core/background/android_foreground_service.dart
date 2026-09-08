/// Android foreground service (tz-mobile §10.4, M73).
///
/// `flutter_foreground_task` ustidagi yupqa qatlam. Xizmat turi
/// **`location|connectedDevice`** (Android 14+ da deklaratsiya majburiy) —
/// `AndroidManifest.xml` dagi `<service … android:foregroundServiceType>` bilan
/// bir xil bo'lishi shart.
///
/// Bildirishnoma `ongoing`: kanal importance `LOW` (ovozsiz), `onlyAlertOnce`,
/// foydalanuvchi surib o'chira olmaydi (`stopWithTask = false`).
library;

import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'background_service.dart';
import 'eld_task_handler.dart';

/// Bildirishnoma kanali (Android 8+).
const String kEldServiceChannelId = 'onebook_eld_service';

/// Xizmat ID si — bildirishnoma ID si sifatida ham ishlatiladi.
const int kEldServiceId = 4201;

class AndroidForegroundService implements BackgroundService {
  AndroidForegroundService({required this._channelName, required this._channelDescription});

  final String _channelName;
  final String _channelDescription;

  bool _initialized = false;

  @override
  Future<bool> get isRunning async =>
      Platform.isAndroid && await FlutterForegroundTask.isRunningService;

  @override
  Future<bool> start(BackgroundNotification notification) async {
    if (!Platform.isAndroid) {
      return false;
    }
    _init();
    if (await FlutterForegroundTask.isRunningService) {
      await update(notification);
      return true;
    }
    final ServiceRequestResult result = await FlutterForegroundTask.startService(
      serviceId: kEldServiceId,
      // §10.4: FOREGROUND_SERVICE_LOCATION + FOREGROUND_SERVICE_CONNECTED_DEVICE.
      serviceTypes: <ForegroundServiceTypes>[
        ForegroundServiceTypes.location,
        ForegroundServiceTypes.connectedDevice,
      ],
      notificationTitle: notification.title,
      notificationText: notification.body,
      callback: startEldForegroundTask,
    );
    return result is ServiceRequestSuccess;
  }

  @override
  Future<void> update(BackgroundNotification notification) async {
    if (!Platform.isAndroid || !await FlutterForegroundTask.isRunningService) {
      return;
    }
    await FlutterForegroundTask.updateService(
      notificationTitle: notification.title,
      notificationText: notification.body,
    );
  }

  @override
  Future<bool> stop({required bool driving}) async {
    // M73 [MUST]: haydash rejimida fon xizmati to'xtatilmaydi.
    if (driving) {
      return false;
    }
    if (!Platform.isAndroid) {
      return true;
    }
    final ServiceRequestResult result = await FlutterForegroundTask.stopService();
    return result is ServiceRequestSuccess;
  }

  @override
  Future<void> dispose() async {}

  void _init() {
    if (_initialized) {
      return;
    }
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: kEldServiceChannelId,
        channelName: _channelName,
        channelDescription: _channelDescription,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(kEldForegroundTickInterval.inMilliseconds),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
        // M73: ilova task listidan olib tashlansa ham xizmat davom etadi.
        allowAutoRestart: true,
        stopWithTask: false,
      ),
    );
    _initialized = true;
  }
}
