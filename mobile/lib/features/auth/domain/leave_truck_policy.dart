/// `Leave Truck` va to'liq `Logout` qoidalari (tz-mobile §4.8, M18).
///
/// Sof funksiyalar: tarmoq, DB va widget yo'q.
library;

/// `Leave Truck` bosilganda tasdiq modalida nima ko'rsatiladi.
enum LeaveTruckPrompt {
  /// Odatiy holat: «Your status will be set to Off-duty».
  offDutyWarning,

  /// Co-driver bor — u avtomatik faol bo'ladi, ekran Home'da qoladi.
  coDriverTakesOver,
}

/// To'liq `Logout` (drawer, `pause=false`) tasdig'i.
enum LogoutPrompt {
  /// Outbox bo'sh — oddiy tasdiq.
  plain,

  /// **M18:** «You have `<n>` unsynced records. Log out anyway?».
  unsyncedRecords,
}

/// `Leave Truck` qadamlari — kontroller aynan shu tartibda bajaradi (§4.8).
///
/// Tartib muhim: OFF eventi **avval** yoziladi (u haydovchining haqiqiy
/// statusi), keyingina ELD uziladi va sessiya pauza qilinadi.
enum LeaveTruckStep {
  /// 1. Status OFF eventi outbox'ga (odatiy duty-status eventi kabi).
  recordOffDuty,

  /// 2. BLE ulanishi uziladi, fon xizmati to'xtaydi.
  disconnectEld,

  /// 3. `POST /auth/logout {pause:true}` — refresh token TIRIK qoladi.
  pauseSession,
}

abstract final class LeaveTruckPolicy {
  const LeaveTruckPolicy._();

  static const List<LeaveTruckStep> steps = <LeaveTruckStep>[
    LeaveTruckStep.recordOffDuty,
    LeaveTruckStep.disconnectEld,
    LeaveTruckStep.pauseSession,
  ];

  /// Tasdiq modali matnini tanlaydi.
  static LeaveTruckPrompt prompt({required bool hasActiveCoDriver}) =>
      hasActiveCoDriver ? LeaveTruckPrompt.coDriverTakesOver : LeaveTruckPrompt.offDutyWarning;

  /// **M18:** outbox bo'sh bo'lmasa ogohlantiriladi.
  static LogoutPrompt logoutPrompt({required int queuedRecords}) =>
      queuedRecords > 0 ? LogoutPrompt.unsyncedRecords : LogoutPrompt.plain;
}
