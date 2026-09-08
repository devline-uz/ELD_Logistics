@Timeout(Duration(seconds: 60))
/// **M-44 Profile** goldenlari — light/dark × phone/tablet.
library;

import 'package:eld_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/profile/m11_test_harness.dart';
import '../golden_screen_host.dart';

void main() {
  screenGoldenMatrix('profile', builder: () => const ProfileScreen(), overrides: m11Overrides);
}
