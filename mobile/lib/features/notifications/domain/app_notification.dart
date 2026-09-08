/// `M-43` domen modeli (tz-mobile §15, `swagger.json`
/// `notifications_dto.Notification`).
///
/// `presentation` **faqat** shu modelni ko'radi (M5).
library;

/// `alert_type` enum'i — `swagger.json` bilan **aynan** bir xil (16 qiymat).
enum AlertType {
  hosWarning('hos_warning'),
  hosViolation('hos_violation'),
  routeAssigned('route_assigned'),
  routeCompleted('route_completed'),
  dvirDefects('dvir_defects'),
  dvirCritical('dvir_critical'),
  logEditRequest('log_edit_request'),
  logEditResolved('log_edit_resolved'),
  uncertifiedLog('uncertified_log'),
  unidentifiedDriving('unidentified_driving'),
  eldDisconnected('eld_disconnected'),
  eldMalfunction('eld_malfunction'),
  maintenanceUpcoming('maintenance_upcoming'),
  maintenanceOverdue('maintenance_overdue'),
  chatMessage('chat_message'),
  subscriptionExpiring('subscription_expiring');

  const AlertType(this.wire);

  final String wire;

  /// Noma'lum qiymat crash qilmaydi — `null` qaytadi va UI umumiy ikonka beradi.
  static AlertType? fromWire(String? wire) {
    for (final AlertType type in AlertType.values) {
      if (type.wire == wire) {
        return type;
      }
    }
    return null;
  }

  /// M143: `hos_*` va `eld_*` — foydalanuvchi ilova ichidan o'chira olmaydi.
  bool get isMandatory =>
      this == hosWarning ||
      this == hosViolation ||
      this == eldDisconnected ||
      this == eldMalfunction;

  /// §15.2: haydovchiga taalluqli emas (Fleet/Service Manager, Administrator).
  bool get isDriverVisible => !const <AlertType>{
    dvirDefects,
    dvirCritical,
    logEditResolved,
    unidentifiedDriving,
    subscriptionExpiring,
  }.contains(this);
}

/// Ogohlantirishning vizual og'irligi (ikonka rangi uchun).
enum AlertSeverity { info, warning, critical }

/// M144: Android `NotificationChannel` lari.
enum PushChannel {
  /// `hos_*`, `eld_*`, idle prompt — HIGH, o'chirib bo'lmaydi.
  compliance('compliance'),
  logs('logs'),
  messages('messages'),
  general('general');

  const PushChannel(this.id);

  final String id;
}

/// Bitta bildirishnoma.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.type,
    this.entityType,
    this.entityId,
  });

  final String id;

  /// Server matni (`title`/`body`) — lokalizatsiya serverda.
  final String title;
  final String body;

  /// UTC.
  final DateTime createdAt;

  final bool read;

  /// Noma'lum `alert_type` uchun `null`.
  final AlertType? type;

  final String? entityType;
  final String? entityId;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    read: read ?? this.read,
    type: type,
    entityType: entityType,
    entityId: entityId,
  );
}

/// M144: alert turi → push kanali.
PushChannel pushChannelOf(AlertType? type) => switch (type) {
  AlertType.hosWarning ||
  AlertType.hosViolation ||
  AlertType.eldDisconnected ||
  AlertType.eldMalfunction => PushChannel.compliance,
  AlertType.logEditRequest || AlertType.uncertifiedLog => PushChannel.logs,
  AlertType.chatMessage => PushChannel.messages,
  _ => PushChannel.general,
};

/// Ikonka rangi uchun og'irlik (dizaynda ranglar yo'q — §11.0.1 state ranglari).
AlertSeverity severityOf(AlertType? type) => switch (type) {
  AlertType.hosViolation ||
  AlertType.dvirCritical ||
  AlertType.eldMalfunction ||
  AlertType.maintenanceOverdue => AlertSeverity.critical,
  AlertType.hosWarning ||
  AlertType.uncertifiedLog ||
  AlertType.eldDisconnected ||
  AlertType.maintenanceUpcoming ||
  AlertType.dvirDefects ||
  AlertType.subscriptionExpiring => AlertSeverity.warning,
  _ => AlertSeverity.info,
};

/// Sana bo'yicha guruh (dizayn: `May 28, 2025` sarlavhasi).
///
/// Kirish **yangidan eskiga** tartiblangan bo'lishi kutiladi; kun chegarasi
/// [dayOf] orqali beriladi (domen Home Terminal TZ ni bilmaydi — M42).
List<NotificationDaySection> groupNotificationsByDay(
  List<AppNotification> items, {
  required DateTime Function(DateTime) dayOf,
}) {
  final List<NotificationDaySection> sections = <NotificationDaySection>[];
  for (final AppNotification item in items) {
    final DateTime day = dayOf(item.createdAt);
    if (sections.isNotEmpty && sections.last.day == day) {
      sections.last.items.add(item);
    } else {
      sections.add(NotificationDaySection(day: day, items: <AppNotification>[item]));
    }
  }
  return sections;
}

class NotificationDaySection {
  NotificationDaySection({required this.day, required this.items});

  final DateTime day;
  final List<AppNotification> items;
}

/// M91: <24 soat — nisbiy, keyin absolyut (`MMM d, hh:mm a`).
enum NotificationTimeKind { justNow, minutes, hours, absolute }

class NotificationTimeLabel {
  const NotificationTimeLabel(this.kind, {this.value = 0});

  final NotificationTimeKind kind;

  /// `minutes`/`hours` uchun son.
  final int value;

  @override
  bool operator ==(Object other) =>
      other is NotificationTimeLabel && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}

/// **Sof funksiya** — [now] chaqiruvchi tomonidan (`TimeSource`) beriladi.
NotificationTimeLabel notificationTimeLabel(DateTime createdAt, DateTime now) {
  final Duration age = now.toUtc().difference(createdAt.toUtc());
  if (age.isNegative || age.inMinutes < 1) {
    return const NotificationTimeLabel(NotificationTimeKind.justNow);
  }
  if (age.inMinutes < 60) {
    return NotificationTimeLabel(NotificationTimeKind.minutes, value: age.inMinutes);
  }
  if (age.inHours < 24) {
    return NotificationTimeLabel(NotificationTimeKind.hours, value: age.inHours);
  }
  return const NotificationTimeLabel(NotificationTimeKind.absolute);
}
