/// `M-16` uchun lokal bildirishnoma abstraksiyasi (M62).
///
/// **Izoh (core so'rovi):** `core/background` da hozircha faqat Android
/// foreground service bildirishnomasi bor; yuqori ustuvorlikdagi
/// full-screen intent / critical alert kanali yo'q. Shuning uchun interfeys
/// shu modulda e'lon qilingan va `NoopIdleAlertNotifier` bilan ta'minlangan;
/// `flutter_local_notifications` ulangach implementatsiya `core` ga ko'chadi.
library;

/// Modal ekran o'chiq bo'lganda ham chiqadigan ogohlantirish (M62).
abstract class IdleAlertNotifier {
  /// Ovoz + tebranish bilan ko'rsatadi.
  Future<void> show({required String title, required String body});

  /// Foydalanuvchi javob berdi yoki taymer tugadi — olib tashlanadi.
  Future<void> cancel();
}

/// Standart (bo'sh) implementatsiya — test va desktop uchun.
class NoopIdleAlertNotifier implements IdleAlertNotifier {
  NoopIdleAlertNotifier();

  /// Ko'rsatilgan ogohlantirishlar (testlar tekshiradi).
  final List<String> shown = <String>[];

  bool get visible => _visible;
  bool _visible = false;

  @override
  Future<void> show({required String title, required String body}) async {
    shown.add(title);
    _visible = true;
  }

  @override
  Future<void> cancel() async => _visible = false;
}
