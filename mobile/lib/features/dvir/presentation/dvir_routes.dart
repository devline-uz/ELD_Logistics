/// DVIR modulining marshrutlari (tz-mobile §11.1: M-32…M-36).
///
/// `core/router/app_router.dart` shu ro'yxatni ildizga qo'shadi — DVIR
/// oqimi tab tasmasidan tashqarida, to'liq ekranda ochiladi.
///
/// `M-36 Previous defects` — marshrut emas, modal
/// (`showPreviousDefectsDialog`), shuning uchun bu ro'yxatda yo'q.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../domain/dvir_models.dart';
import 'screens/dvir_add_screen.dart';
import 'screens/dvir_defect_picker_screen.dart';
import 'screens/dvir_details_screen.dart';
import 'screens/dvir_review_screen.dart';

abstract final class DvirRoute {
  const DvirRoute._();

  /// `M-32 Add DVIR`.
  static const String add = '/dvir/new';

  /// `M-33 Defect picker` — `?category=truck|trailer`.
  static const String defects = '/dvir/new/defects';

  /// `M-34 Review + Driver signature`.
  static const String review = '/dvir/new/confirm';

  /// `M-35 DVIR details` — `:id` bilan.
  static const String detailsPattern = '/dvir/:id';

  /// `M-35` uchun yo'l parametri nomi.
  static const String idParam = 'id';

  /// `M-33` uchun kategoriya so'rov parametri.
  static const String categoryParam = 'category';

  /// [defects] ga kategoriya bilan havola.
  static String defectsFor(DefectCategory category) => '$defects?$categoryParam=${category.wire}';

  /// [detailsPattern] ga konkret hisobot bilan havola.
  static String detailsFor(String reportId) => '/dvir/$reportId';
}

/// `GoRouter` ga qo'shiladigan DVIR marshrutlari.
final List<RouteBase> dvirRoutes = <RouteBase>[
  GoRoute(
    path: DvirRoute.add,
    builder: (BuildContext context, GoRouterState state) => const DvirAddScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: 'defects',
        builder: (BuildContext context, GoRouterState state) => DvirDefectPickerScreen(
          category: DefectCategory.fromWire(state.uri.queryParameters[DvirRoute.categoryParam]),
        ),
      ),
      GoRoute(
        path: 'confirm',
        builder: (BuildContext context, GoRouterState state) => const DvirReviewScreen(),
      ),
    ],
  ),
  // `/dvir/new` dan **keyin** e'lon qilinadi: `go_router` statik segmentni
  // `:id` dan oldin tekshiradi, aks holda `new` id sifatida o'qiladi.
  GoRoute(
    path: DvirRoute.detailsPattern,
    builder: (BuildContext context, GoRouterState state) =>
        DvirDetailsScreen(reportId: state.pathParameters[DvirRoute.idParam] ?? ''),
  ),
];
