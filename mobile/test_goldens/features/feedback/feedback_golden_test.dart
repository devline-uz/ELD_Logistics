@Timeout(Duration(seconds: 60))
/// **M-48 Give feedback** goldenlari — light/dark × phone/tablet.
///
/// Planshet kadrida M113 bo'yicha savol matni «…with the app?» ga o'zgaradi.
library;

import 'package:eld_mobile/features/feedback/presentation/screens/feedback_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/profile/m11_test_harness.dart';
import '../golden_screen_host.dart';

void main() {
  screenGoldenMatrix('feedback', builder: () => const FeedbackScreen(), overrides: m11Overrides);
}
