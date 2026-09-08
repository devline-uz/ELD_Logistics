/// **M146** — server ishtirokisiz tug'iladigan bildirishnomalar.
///
/// Domen faqat **nima** ko'rsatilishini biladi; matn `presentation` da
/// `AppLocalizations` orqali qo'yiladi (hard-coded matn taqiq).
library;

import 'app_notification.dart';
import 'notification_deeplink.dart';

/// Lokal ogohlantirish turlari (tz-mobile §15.3, M146).
enum LocalAlertKind {
  /// M50 — HOS chegarasiga yaqinlashish (30/15 daqiqa).
  hosWarning,

  /// Limit oshib ketdi.
  hosViolation,

  /// M62 — 5 daqiqa to'xtab turish.
  idlePrompt,

  /// ELD 30 s ulanmadi.
  eldDisconnected,

  /// Malfunction kodi ko'tarildi.
  eldMalfunction,

  /// Sync konflikti — foydalanuvchi aralashuvi kerak.
  syncConflict,
}

/// Bildirishnoma so'rovi: tur + parametr. **Sof qiymat obyekti.**
class LocalAlertRequest {
  const LocalAlertRequest({required this.kind, this.minutesLeft, this.malfunctionCode});

  final LocalAlertKind kind;

  /// [LocalAlertKind.hosWarning] uchun qolgan daqiqalar.
  final int? minutesLeft;

  /// [LocalAlertKind.eldMalfunction] uchun kod (`P`, `E`, `T`, …).
  final String? malfunctionCode;

  /// Bir xil turdagi bildirishnoma **almashtiriladi**, dublikat yaratilmaydi:
  /// platforma id si turdan barqaror hisoblanadi.
  int get notificationId => 9000 + kind.index;

  /// M144: kanal turdan kelib chiqadi.
  PushChannel get channel => pushChannelOf(alertType);

  /// M145: bosilganda ochiladigan ekran.
  String? get deepLink => switch (kind) {
    LocalAlertKind.hosWarning || LocalAlertKind.hosViolation => NotificationTarget.logs,
    LocalAlertKind.idlePrompt => NotificationTarget.dutyChange,
    LocalAlertKind.eldDisconnected || LocalAlertKind.eldMalfunction => NotificationTarget.eld,
    LocalAlertKind.syncConflict => NotificationTarget.syncConflicts,
  };

  /// Serverdagi `alert_type` ekvivalenti (kanal va ikonka uchun).
  ///
  /// `syncConflict` uchun server enum'ida mos qiymat yo'q — u `general`
  /// kanaliga tushadi; `idlePrompt` esa M144 bo'yicha `compliance` da.
  AlertType? get alertType => switch (kind) {
    LocalAlertKind.hosWarning || LocalAlertKind.idlePrompt => AlertType.hosWarning,
    LocalAlertKind.hosViolation => AlertType.hosViolation,
    LocalAlertKind.eldDisconnected => AlertType.eldDisconnected,
    LocalAlertKind.eldMalfunction => AlertType.eldMalfunction,
    LocalAlertKind.syncConflict => null,
  };
}
