/// M144 — Android `NotificationChannel` ta'riflari va M143 qulflari.
///
/// **Sof domen**: `flutter` va platforma kanaliga bog'liq emas; platforma
/// tarafiga shu ro'yxat uzatiladi (`PushGateway.ensureChannels`).
library;

import 'app_notification.dart';

/// `NotificationChannel.importance` (Android) ekvivalenti.
enum ChannelImportance {
  min('min'),
  low('low'),
  defaultImportance('default'),
  high('high');

  const ChannelImportance(this.wire);

  final String wire;
}

/// Fon xizmati kanali — `core/background` egaligida, lekin M144 jadvalining
/// bir qismi bo'lgani uchun shu yerda e'lon qilinadi.
const String kForegroundServiceChannelId = 'foreground_service';

/// Bitta kanal ta'rifi.
class NotificationChannelSpec {
  const NotificationChannelSpec({
    required this.id,
    required this.importance,
    required this.locked,
    this.sound = false,
    this.vibration = false,
  });

  final String id;
  final ChannelImportance importance;

  /// **M143**: `true` bo'lsa foydalanuvchi ilova ichidan o'chira olmaydi
  /// (toggle disabled + «Required for compliance» tooltip).
  final bool locked;

  final bool sound;
  final bool vibration;
}

/// M144 jadvalining kanonik ro'yxati (tartib — UI dagi tartib).
const List<NotificationChannelSpec> kNotificationChannels = <NotificationChannelSpec>[
  NotificationChannelSpec(
    id: 'compliance',
    importance: ChannelImportance.high,
    locked: true,
    sound: true,
    vibration: true,
  ),
  NotificationChannelSpec(
    id: 'logs',
    importance: ChannelImportance.defaultImportance,
    locked: false,
  ),
  NotificationChannelSpec(
    id: 'messages',
    importance: ChannelImportance.defaultImportance,
    locked: false,
  ),
  NotificationChannelSpec(id: 'general', importance: ChannelImportance.low, locked: false),
  NotificationChannelSpec(
    id: kForegroundServiceChannelId,
    importance: ChannelImportance.min,
    locked: true,
  ),
];

/// [PushChannel] uchun ta'rif (`foreground_service` enum'da yo'q — u
/// `core/background` tomonidan boshqariladi).
NotificationChannelSpec channelSpecOf(PushChannel channel) =>
    kNotificationChannels.firstWhere((NotificationChannelSpec s) => s.id == channel.id);

/// **M143 [MUST]** — `hos_*` va `eld_*` turlarini foydalanuvchi o'chira olmaydi.
bool isChannelLocked(PushChannel channel) => channelSpecOf(channel).locked;

/// Alert turi bo'yicha: shu bildirishnomani o'chirish mumkinmi?
bool canDisableAlert(AlertType? type) => !isChannelLocked(pushChannelOf(type));

/// Foydalanuvchi sozlamalari (lokal, `SettingsDao` da saqlanadi).
///
/// Qulflangan kanal **har doim** yoqilgan — `disabled` ga tushsa ham
/// [isEnabled] `true` qaytaradi (M143 chetlab o'tilmaydi).
class NotificationPreferences {
  const NotificationPreferences({this.disabled = const <String>{}});

  /// O'chirilgan kanal id lari.
  final Set<String> disabled;

  bool isEnabled(PushChannel channel) => isChannelLocked(channel) || !disabled.contains(channel.id);

  /// Yangi holat bilan nusxa; qulflangan kanalni o'chirishga urinish
  /// **e'tiborsiz** qoldiriladi.
  NotificationPreferences toggled(PushChannel channel, {required bool enabled}) {
    if (isChannelLocked(channel)) {
      return this;
    }
    final Set<String> next = <String>{...disabled};
    if (enabled) {
      next.remove(channel.id);
    } else {
      next.add(channel.id);
    }
    return NotificationPreferences(disabled: next);
  }

  /// `SettingsDao` uchun: vergul bilan ajratilgan id lar.
  String encode() => (disabled.toList()..sort()).join(',');

  static NotificationPreferences decode(String? raw) => NotificationPreferences(
    disabled: <String>{
      if (raw != null)
        for (final String part in raw.split(','))
          if (part.trim().isNotEmpty) part.trim(),
    },
  );
}
