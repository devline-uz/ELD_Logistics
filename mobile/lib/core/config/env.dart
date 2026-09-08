/// Kompilyatsiya vaqtidagi muhit konfiguratsiyasi.
///
/// Qiymatlar `--dart-define-from-file=env/{dev,stage,prod}.json` orqali beriladi.
/// Runtime'da o'zgarmaydi: barcha maydonlar `String.fromEnvironment` const.
library;

import 'package:flutter/foundation.dart';

import '../network/certificate_pinning.dart';

/// Ilova ishlayotgan muhit.
enum AppFlavor {
  dev,
  stage,
  prod;

  static AppFlavor fromName(String value) => switch (value) {
    'stage' => AppFlavor.stage,
    'prod' => AppFlavor.prod,
    _ => AppFlavor.dev,
  };
}

/// Muhit sozlamalari (kompilyatsiya vaqtida muzlatilgan).
abstract final class Env {
  const Env._();

  /// REST bazasi, masalan `https://eldapi.stackyard.uz/api/v1`.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// WebSocket manzili; `wss://` majburiy (M154).
  static const String wsUrl = String.fromEnvironment('WS_URL');

  /// Sentry DSN — repoda bo'sh, CI sirlaridan beriladi. Bo'sh = Sentry o'chiq.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Dev menyu. Prod build'da har doim `false` (M163).
  static const bool enableDevMenu = bool.fromEnvironment('ENABLE_DEV_MENU');

  /// Sertifikat pinning (M153). Prod'da bypass yo'q.
  static const bool enableCertPinning = bool.fromEnvironment('ENABLE_CERT_PINNING');

  /// `env/*.json` dagi `ENV_NAME`.
  static const String flavorName = String.fromEnvironment('ENV_NAME', defaultValue: 'dev');

  /// Joriy muhit (runtime'da hisoblanadi, `flavorName` dan).
  static AppFlavor get current => AppFlavor.fromName(flavorName);

  /// `true` bo'lsa dev menyu ko'rsatilishi mumkin: release build'da hech qachon.
  static bool get devMenuVisible => enableDevMenu && !kReleaseMode;

  /// Ishga tushishda chaqiriladi. Noto'g'ri konfiguratsiyada [StateError].
  static void validate() {
    final List<String> problems = <String>[];

    if (apiBaseUrl.isEmpty) {
      problems.add('API_BASE_URL berilmagan (--dart-define-from-file unutilgan?)');
    } else {
      if (!apiBaseUrl.startsWith('https://')) {
        problems.add('API_BASE_URL https:// bilan boshlanishi shart');
      }
      if (!apiBaseUrl.endsWith('/api/v1')) {
        problems.add('API_BASE_URL /api/v1 bilan tugashi shart');
      }
    }

    if (wsUrl.isEmpty) {
      problems.add('WS_URL berilmagan');
    } else if (!wsUrl.startsWith('wss://')) {
      problems.add('WS_URL wss:// bo\'lishi shart (M154)');
    }

    if (current == AppFlavor.prod) {
      if (enableDevMenu) {
        problems.add('prod muhitida ENABLE_DEV_MENU=true (M163)');
      }
      if (!enableCertPinning) {
        problems.add('prod muhitida sertifikat pinning o\'chirilgan (M153)');
      }
      if (apiBaseUrl != 'https://eldapi.stackyard.uz/api/v1') {
        problems.add('prod API_BASE_URL kutilganidan farq qiladi: $apiBaseUrl');
      }
    }

    // #B-131: pinning konfiguratsiyasi ham shu yerda tekshiriladi — ilova
    // «pinning yoqilgan» deb ko'rsatib, aslida pinsiz ishga tushmasin.
    // Prod'da `CERT_SPKI_PINS` bo'sh bo'lsa build **ataylab** to'xtaydi.
    problems.addAll(CertificatePinning.validate());

    if (problems.isNotEmpty) {
      throw StateError('Env konfiguratsiyasi noto\'g\'ri:\n - ${problems.join('\n - ')}');
    }
  }
}
