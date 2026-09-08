/// Fon xizmati abstraksiyasi (tz-mobile §10.4, M73).
///
/// Android — `foreground service` (`location|connectedDevice`), doimiy
/// (`ongoing`) bildirishnoma: **joriy status + `Driving Time Left`**.
/// iOS — xizmat yo'q, uning o'rniga `UIBackgroundModes` + BLE state
/// restoration (`ios_background.dart`).
///
/// **M73 [MUST]:** haydash rejimida xizmat **hech qachon** to'xtatilmaydi —
/// [BackgroundService.stop] `driving` bo'lganda `false` qaytaradi.
library;

/// Doimiy bildirishnoma mazmuni.
class BackgroundNotification {
  const BackgroundNotification({required this.title, required this.body});

  /// Joriy duty status (lokalizatsiya qilingan, masalan `On Duty`).
  final String title;

  /// `Driving Time Left — 08:00` (lokalizatsiya qilingan).
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackgroundNotification && other.title == title && other.body == body;

  @override
  int get hashCode => Object.hash(title, body);

  @override
  String toString() => 'BackgroundNotification($title / $body)';
}

/// Fon xizmatini boshqarish.
abstract class BackgroundService {
  /// Xizmat ishlayaptimi.
  Future<bool> get isRunning;

  /// Xizmatni ishga tushiradi (allaqachon ishlayotgan bo'lsa yangilaydi).
  ///
  /// `false` — platforma qo'llab-quvvatlamaydi yoki ruxsat yo'q.
  Future<bool> start(BackgroundNotification notification);

  /// Bildirishnoma matnini yangilaydi (status yoki taymer o'zgarganda).
  Future<void> update(BackgroundNotification notification);

  /// **M73:** [driving] `true` bo'lsa to'xtatmaydi va `false` qaytaradi.
  Future<bool> stop({required bool driving});

  Future<void> dispose();
}

/// Testlar va iOS uchun bo'sh implementatsiya (iOS'da FGS tushunchasi yo'q).
class NoopBackgroundService implements BackgroundService {
  NoopBackgroundService();

  bool _running = false;

  /// Oxirgi ko'rsatilgan bildirishnoma — testda tekshiriladi.
  BackgroundNotification? lastNotification;

  /// `stop(driving: true)` necha marta rad etilgani (M73).
  int refusedStops = 0;

  @override
  Future<bool> get isRunning async => _running;

  @override
  Future<bool> start(BackgroundNotification notification) async {
    _running = true;
    lastNotification = notification;
    return true;
  }

  @override
  Future<void> update(BackgroundNotification notification) async {
    lastNotification = notification;
  }

  @override
  Future<bool> stop({required bool driving}) async {
    if (driving) {
      refusedStops++;
      return false; // M73
    }
    _running = false;
    return true;
  }

  @override
  Future<void> dispose() async {
    _running = false;
  }
}
