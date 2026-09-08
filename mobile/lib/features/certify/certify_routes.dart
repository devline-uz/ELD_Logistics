/// Certify modulining marshrutlari (eld-screens registri: M-29…M-31).
///
/// `M-31 Not Ready` alohida marshrut emas — `M-29`/`M-30` ichidagi holat.
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/certify_screen.dart';
import 'presentation/screens/certify_sign_screen.dart';

abstract final class CertifyRoute {
  const CertifyRoute._();

  /// `M-29 Certify (Last 8 days)`.
  static const String list = '/certify';

  /// `M-30 Sign` — `/certify/:date/sign` (`date` = `YYYY-MM-DD`).
  static const String signPattern = '/certify/:date/sign';

  /// Yo'l parametri nomi.
  static const String dateParam = 'date';

  /// [signPattern] ga konkret kun bilan havola.
  static String signFor(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '/certify/${date.year}-$m-$d/sign';
  }

  /// `YYYY-MM-DD` ni kunga o'giradi; noto'g'ri qiymatda [fallback] qaytadi.
  static DateTime parseDate(String? raw, {required DateTime fallback}) {
    final DateTime? parsed = raw == null ? null : DateTime.tryParse(raw);
    return parsed == null ? fallback : DateTime(parsed.year, parsed.month, parsed.day);
  }
}

/// `GoRouter` ga qo'shiladigan certify marshrutlari.
final List<RouteBase> certifyRoutes = <RouteBase>[
  GoRoute(
    path: CertifyRoute.list,
    builder: (BuildContext context, GoRouterState state) => const CertifyScreen(),
  ),
  GoRoute(
    path: CertifyRoute.signPattern,
    builder: (BuildContext context, GoRouterState state) => CertifySignScreen(
      date: CertifyRoute.parseDate(
        state.pathParameters[CertifyRoute.dateParam],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    ),
  ),
];
