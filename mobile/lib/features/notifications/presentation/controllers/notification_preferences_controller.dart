/// **M143/M144** — kanal sozlamalari kontrolleri (telefon + planshet umumiy).
///
/// Qulflangan kanalni o'chirish urinishi domen darajasida bloklanadi
/// ([NotificationPreferences.toggled]) — UI ga ishonilmaydi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/daos/settings_dao.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/time/time_providers.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_channels.dart';

/// `settings` kaliti.
const String kNotificationPrefsKey = 'notifications.disabled_channels';

class NotificationPreferencesController extends AsyncNotifier<NotificationPreferences> {
  SettingsDao get _dao => ref.read(settingsDaoProvider);

  @override
  Future<NotificationPreferences> build() async =>
      NotificationPreferences.decode(await _dao.get(kNotificationPrefsKey));

  Future<void> toggle(PushChannel channel, {required bool enabled}) async {
    final NotificationPreferences current = state.value ?? const NotificationPreferences();
    final NotificationPreferences next = current.toggled(channel, enabled: enabled);
    if (next.disabled.length == current.disabled.length &&
        next.disabled.containsAll(current.disabled)) {
      // M143: qulflangan kanal — o'zgarish yo'q.
      return;
    }
    state = AsyncData<NotificationPreferences>(next);
    await _dao.put(
      key: kNotificationPrefsKey,
      value: next.encode(),
      now: ref.read(timeSourceProvider).now(),
    );
  }
}

final AsyncNotifierProvider<NotificationPreferencesController, NotificationPreferences>
notificationPreferencesProvider =
    AsyncNotifierProvider<NotificationPreferencesController, NotificationPreferences>(
      NotificationPreferencesController.new,
    );
