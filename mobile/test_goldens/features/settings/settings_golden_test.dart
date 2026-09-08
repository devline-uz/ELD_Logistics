@Timeout(Duration(seconds: 60))
/// **M-45 Settings** goldenlari — light/dark × phone/tablet.
library;

import 'package:eld_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/profile/m11_test_harness.dart';
import '../golden_screen_host.dart';

void main() {
  screenGoldenMatrix('settings', builder: () => const SettingsScreen(), overrides: m11Overrides);
}
