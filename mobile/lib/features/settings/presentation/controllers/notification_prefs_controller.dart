/// `M-45` bildirishnoma sozlamalari kontrolleri (M143).
///
/// **Vaqtinchalik in-memory saqlash** — `core/ui/theme_controller.dart` bilan
/// bir xil yondashuv. `kv_settings` jadvali tayyor bo'lgach `build()` Drift'dan
/// o'qiydi va har o'zgarishda yozadi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/notification_prefs.dart';

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() {
    // TODO(M11-5): kv_settings dan o'qish (`notification_prefs`).
    return const NotificationPrefs();
  }

  void setEnabled(AlertType type, {required bool enabled}) {
    // TODO(M11-5): kv_settings ga yozish.
    state = state.setEnabled(type, enabled: enabled);
  }
}

final NotifierProvider<NotificationPrefsController, NotificationPrefs> notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
      NotificationPrefsController.new,
    );
