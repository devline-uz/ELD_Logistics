/// Drive mode moduli DI si (M3).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/idle_alert.dart';

/// **M62:** lokal bildirishnoma. Bootstrap yoki test uni override qiladi;
/// standart implementatsiya hech narsa ko'rsatmaydi (`core` da kanal yo'q).
final Provider<IdleAlertNotifier> idleAlertNotifierProvider = Provider<IdleAlertNotifier>(
  (Ref ref) => NoopIdleAlertNotifier(),
);
