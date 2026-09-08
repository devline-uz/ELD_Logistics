/// Ilova versiyasi — `GET /app/config.min_supported_version` bilan
/// solishtirish va `X-App-Version` sarlavhasi uchun (M-57 Force update).
library;

import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  const AppVersion({required this.version, required this.buildNumber, required this.packageName});

  /// Semver, masalan `1.4.2`.
  final String version;

  /// `versionCode` / `CFBundleVersion`.
  final String buildNumber;

  final String packageName;

  /// `X-App-Version` sarlavhasi qiymati.
  String get header => '$version+$buildNumber';

  static Future<AppVersion> load() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return AppVersion(
      version: info.version,
      buildNumber: info.buildNumber,
      packageName: info.packageName,
    );
  }

  /// `version` [minimum] dan past bo'lsa `true` (force update).
  bool isBelow(String minimum) => compareSemver(version, minimum) < 0;

  /// Semver taqqoslash: manfiy — [a] kichik, 0 — teng, musbat — [a] katta.
  static int compareSemver(String a, String b) {
    final List<int> left = _parts(a);
    final List<int> right = _parts(b);
    for (int i = 0; i < 3; i++) {
      final int diff = left[i] - right[i];
      if (diff != 0) {
        return diff;
      }
    }
    return 0;
  }

  static List<int> _parts(String value) {
    final List<int> parsed = value
        .split('+')
        .first
        .split('.')
        .map((String p) => int.tryParse(p.trim()) ?? 0)
        .toList();
    while (parsed.length < 3) {
      parsed.add(0);
    }
    return parsed;
  }
}
