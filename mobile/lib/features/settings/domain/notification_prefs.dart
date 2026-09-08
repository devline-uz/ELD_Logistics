/// `M-45` bildirishnoma sozlamalari domeni (tz-mobile §15, **M143**).
///
/// Biznes qoidasi shu yerda: `hos_*` va `eld_*` turlarini foydalanuvchi
/// **o'chira olmaydi** — ular sozlamalarda ko'rinadi, lekin toggle o'chirilgan
/// holatda va ostida «Required for compliance» izohi turadi.
///
/// Bu sozlama **qurilma darajasida** saqlanadi: `PATCH /company/notification-settings`
/// kompaniya darajasidagi endpoint bo'lib, `notification_settings.update`
/// huquqi haydovchida yo'q (`contracts/permissions.md`).
library;

import 'package:meta/meta.dart';

/// Push turlari (tz-mobile §15 jadvali, haydovchiga tegishlilari).
enum AlertType {
  hosWarning('hos_warning'),
  hosViolation('hos_violation'),
  eldDisconnected('eld_disconnected'),
  eldMalfunction('eld_malfunction'),
  uncertifiedLog('uncertified_log'),
  logEditResolved('log_edit_resolved'),
  dvirDefects('dvir_defects'),
  chatMessage('chat_message');

  const AlertType(this.wire);

  /// Backend/push `type` qiymati.
  final String wire;

  /// **M143 [MUST]** — `hos_*` va `eld_*` o'chirilmaydi.
  bool get isLocked => wire.startsWith('hos_') || wire.startsWith('eld_');
}

@immutable
class NotificationPrefs {
  const NotificationPrefs({this.disabled = const <AlertType>{}});

  /// Foydalanuvchi o'chirgan turlar. `AlertType.isLocked` bo'lganlar bu
  /// to'plamga **hech qachon** tushmaydi.
  final Set<AlertType> disabled;

  bool isEnabled(AlertType type) => type.isLocked || !disabled.contains(type);

  /// Qulflangan turni o'zgartirish urinishi e'tiborsiz qoldiriladi (M143).
  NotificationPrefs setEnabled(AlertType type, {required bool enabled}) {
    if (type.isLocked) {
      return this;
    }
    final Set<AlertType> next = <AlertType>{...disabled};
    if (enabled) {
      next.remove(type);
    } else {
      next.add(type);
    }
    return NotificationPrefs(disabled: next);
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationPrefs && _sameSet(other.disabled, disabled);

  @override
  int get hashCode => Object.hashAllUnordered(disabled);

  static bool _sameSet(Set<AlertType> a, Set<AlertType> b) =>
      a.length == b.length && a.every(b.contains);
}
