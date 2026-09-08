/// Foreground service isolate'idagi vazifa (Android).
///
/// Bu isolate **alohida** Dart konteksti: Riverpod konteyneri, Drift ulanishi
/// va `TimeSource` u yerda mavjud emas. Shu sababli vazifa faqat ikkita ish
/// qiladi:
/// 1. asosiy isolate'ga `tick` yuboradi (u telemetriya batchini yozadi);
/// 2. bildirishnoma matni uchun kelgan ma'lumotni ko'rsatadi (M73).
///
/// **Batareya (risk R6):** tik oralig'i 30 s — telemetriya nuqta-ba-nuqta
/// emas, **batch** bo'lib yoziladi.
library;

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Fon tik oralig'i — telemetriya batchi shu qadamda yig'iladi.
const Duration kEldForegroundTickInterval = Duration(seconds: 30);

/// Isolate'lar orasidagi xabar ajratgichi (matnda uchramaydi).
const String kEldTaskSeparator = '|';

/// Isolate'lar orasidagi xabar kalitlari.
abstract final class EldTaskMessage {
  const EldTaskMessage._();

  /// Fon → asosiy: navbatdagi tik (ISO-8601 UTC).
  static const String tick = 'eld.tick';

  /// Asosiy → fon: bildirishnoma matni.
  static const String notification = 'eld.notification';

  /// Fon → asosiy: xizmat qayta ishga tushdi (M74 bilan bir xil tiklanish).
  static const String restarted = 'eld.restarted';

  /// `title` va `body` ni bitta satrga yig'adi.
  static String encodeNotification(String title, String body) =>
      <String>[notification, title, body].join(kEldTaskSeparator);

  /// [encodeNotification] teskarisi; format noto'g'ri bo'lsa `null`.
  static (String title, String body)? decodeNotification(Object data) {
    if (data is! String) {
      return null;
    }
    final List<String> parts = data.split(kEldTaskSeparator);
    if (parts.length != 3 || parts.first != notification) {
      return null;
    }
    return (parts[1], parts[2]);
  }

  /// `tick` xabaridan vaqtni ajratadi.
  static DateTime? decodeTick(Object data) {
    if (data is! String) {
      return null;
    }
    final List<String> parts = data.split(kEldTaskSeparator);
    if (parts.length != 2 || parts.first != tick) {
      return null;
    }
    return DateTime.tryParse(parts[1])?.toUtc();
  }

  static String encodeTick(DateTime at) =>
      <String>[tick, at.toUtc().toIso8601String()].join(kEldTaskSeparator);
}

/// Android FGS isolate kirish nuqtasi.
///
/// `@pragma('vm:entry-point')` majburiy — AOT build'da olib tashlanmasligi
/// uchun.
@pragma('vm:entry-point')
void startEldForegroundTask() {
  FlutterForegroundTask.setTaskHandler(EldTaskHandler());
}

class EldTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    if (starter == TaskStarter.system) {
      // Tizim qayta ishga tushirdi (reboot / process death) — asosiy isolate
      // uyg'onganda oxirgi holatni Drift'dan tiklaydi.
      FlutterForegroundTask.sendDataToMain(EldTaskMessage.restarted);
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.sendDataToMain(EldTaskMessage.encodeTick(timestamp));
  }

  @override
  void onReceiveData(Object data) {
    final (String, String)? parsed = EldTaskMessage.decodeNotification(data);
    if (parsed == null) {
      return;
    }
    FlutterForegroundTask.updateService(notificationTitle: parsed.$1, notificationText: parsed.$2);
  }

  @override
  void onNotificationPressed() => FlutterForegroundTask.launchApp();

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
