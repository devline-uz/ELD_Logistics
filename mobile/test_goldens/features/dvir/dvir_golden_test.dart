@Timeout(Duration(seconds: 60))
/// DVIR ekranlarining goldenlari (M-32…M-36) — light/dark × phone/tablet.
///
/// ⚠️ Figma da DVIR oqimining **dark maketi yo'q** — dark variant faqat
/// `core/ui` tokenlari almashuvidan hosil bo'ladi (M81).
library;

import 'package:eld_mobile/features/dvir/domain/dvir_models.dart';
import 'package:eld_mobile/features/dvir/presentation/controllers/dvir_providers.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_add_screen.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_defect_picker_screen.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_details_screen.dart';
import 'package:eld_mobile/features/dvir/presentation/screens/dvir_review_screen.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/dvir/dvir_test_harness.dart';
import '../golden_screen_host.dart';

List<Override> _overrides({DvirReport? report}) => <Override>[
  dvirRepositoryProvider.overrideWithValue(FakeDvirRepository(report: report)),
  defectCatalogRepositoryProvider.overrideWithValue(FakeDefectCatalogRepository()),
  trailerRepositoryProvider.overrideWithValue(FakeTrailerRepository()),
  dvirFileRepositoryProvider.overrideWithValue(FakeDvirFileRepository()),
];

void main() {
  screenGoldenMatrix('dvir_add', builder: () => const DvirAddScreen(), overrides: _overrides);

  screenGoldenMatrix(
    'dvir_defect_picker',
    builder: () => const DvirDefectPickerScreen(category: DefectCategory.truck),
    overrides: _overrides,
  );

  screenGoldenMatrix('dvir_review', builder: () => const DvirReviewScreen(), overrides: _overrides);

  screenGoldenMatrix(
    'dvir_details',
    builder: () => const DvirDetailsScreen(reportId: 'r1'),
    overrides: () => _overrides(report: buildTestReport()),
  );
}
