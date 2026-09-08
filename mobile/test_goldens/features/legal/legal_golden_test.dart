@Timeout(Duration(seconds: 60))
/// **M-52 / M-53** goldenlari — M117 placeholder holati (huquqiy matn yo'q).
library;

import 'package:eld_mobile/features/legal/presentation/screens/legal_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/profile/m11_test_harness.dart';
import '../golden_screen_host.dart';

List<Override> _overrides() => <Override>[
  ...m11Overrides(),
  legalDocumentProvider(LegalDocumentKind.privacy).overrideWith((Ref ref) async => null),
];

void main() {
  screenGoldenMatrix(
    'legal_pending',
    builder: () => const LegalScreen(document: LegalDocumentKind.privacy),
    overrides: _overrides,
  );
}
