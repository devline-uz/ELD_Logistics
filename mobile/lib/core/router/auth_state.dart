/// Marshrut qo'riqchisi uchun sessiya holati.
///
/// Haqiqiy login/PIN oqimi M0.3 (`features/auth`) da amalga oshiriladi;
/// bu yerda faqat router uchun minimal holat mashinasi saqlanadi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus {
  /// Bootstrap tugamagan (splash).
  unknown,

  /// Refresh token yo'q — login kerak.
  unauthenticated,

  /// Sessiya `paused` (Leave Truck, M18) — PIN so'raladi.
  locked,

  /// To'liq ishlaydigan sessiya.
  authenticated,
}

class AuthStatusNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() => AuthStatus.unknown;

  void set(AuthStatus status) => state = status;
}

final NotifierProvider<AuthStatusNotifier, AuthStatus> authStatusProvider =
    NotifierProvider<AuthStatusNotifier, AuthStatus>(AuthStatusNotifier.new);
