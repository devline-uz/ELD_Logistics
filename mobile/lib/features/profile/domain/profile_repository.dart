/// `M-44` va `M-45` uchun domen shartnomasi.
library;

import 'app_config_info.dart';
import 'driver_profile.dart';

abstract interface class ProfileRepository {
  /// `GET /me` — haydovchi ma'lumotlari.
  Future<DriverProfile> load();

  /// `POST /auth/logout` — joriy sessiyani yopadi.
  Future<void> logout();
}

abstract interface class AppConfigRepository {
  /// `GET /app/config` — `latest_version`, `force_update`, `support_email`.
  Future<AppConfigInfo> load();
}
