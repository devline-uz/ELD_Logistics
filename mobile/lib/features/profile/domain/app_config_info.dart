/// `GET /app/config` domen modeli — `M-45 App updates` va `M-52/M-53` uchun.
library;

import 'package:flutter/foundation.dart';

@immutable
class AppConfigInfo {
  const AppConfigInfo({
    this.latestVersion,
    this.minSupportedVersion,
    this.forceUpdate = false,
    this.supportEmail,
    this.userManualUrl,
  });

  final String? latestVersion;
  final String? minSupportedVersion;
  final bool forceUpdate;

  /// `M117` — huquqiy matn kelmaguncha placeholder shu manzilni ko'rsatadi.
  final String? supportEmail;

  /// `feature_flags` dan olingan `user_manual_url` (bo'lmasa `null`).
  final String? userManualUrl;

  /// `1.4.2` ko'rinishidagi versiyalarni sonli solishtiradi.
  bool isNewerThan(String installed) {
    final String? latest = latestVersion;
    if (latest == null) {
      return false;
    }
    return _compare(latest, installed) > 0;
  }

  static int _compare(String a, String b) {
    final List<int> left = _parts(a);
    final List<int> right = _parts(b);
    for (int i = 0; i < (left.length > right.length ? left.length : right.length); i++) {
      final int l = i < left.length ? left[i] : 0;
      final int r = i < right.length ? right[i] : 0;
      if (l != r) {
        return l > r ? 1 : -1;
      }
    }
    return 0;
  }

  static List<int> _parts(String value) => value
      .split('+')
      .first
      .split('.')
      .map((String p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList(growable: false);

  @override
  bool operator ==(Object other) =>
      other is AppConfigInfo &&
      other.latestVersion == latestVersion &&
      other.minSupportedVersion == minSupportedVersion &&
      other.forceUpdate == forceUpdate &&
      other.supportEmail == supportEmail &&
      other.userManualUrl == userManualUrl;

  @override
  int get hashCode =>
      Object.hash(latestVersion, minSupportedVersion, forceUpdate, supportEmail, userManualUrl);
}
