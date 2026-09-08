import 'package:eld_mobile/core/device/app_version.dart';
import 'package:eld_mobile/core/device/device_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('semver taqqoslash', () {
    expect(AppVersion.compareSemver('1.0.0', '1.0.0'), 0);
    expect(AppVersion.compareSemver('1.2.0', '1.10.0'), lessThan(0));
    expect(AppVersion.compareSemver('2.0.0', '1.9.9'), greaterThan(0));
    expect(AppVersion.compareSemver('1.4.2+31', '1.4.2'), 0);
  });

  test('min_supported_version dan past bo\'lsa force update', () {
    const AppVersion version = AppVersion(
      version: '1.0.3',
      buildNumber: '12',
      packageName: 'uz.stackyard.eld_mobile',
    );

    expect(version.isBelow('1.1.0'), isTrue);
    expect(version.isBelow('1.0.0'), isFalse);
    expect(version.header, '1.0.3+12');
  });

  test('M6: 600 dp chegarasi telefon/planshetni ajratadi', () {
    expect(DeviceProfile.fromSize(const Size(390, 844)), DeviceProfile.phone);
    expect(DeviceProfile.fromSize(const Size(844, 390)), DeviceProfile.phone);
    expect(DeviceProfile.fromSize(const Size(834, 1194)), DeviceProfile.tablet);
    expect(DeviceProfile.fromSize(const Size(600, 900)), DeviceProfile.tablet);
  });
}
