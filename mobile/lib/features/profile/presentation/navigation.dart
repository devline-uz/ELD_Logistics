/// M11 klasteri uchun xavfsiz navigatsiya.
///
/// `Profile` va `Settings` ekranlaridagi bir necha band boshqa modullar
/// (`diagnostics` M-46/M-47, `auth` M-58 va PIN almashtirish) tomonidan
/// ro'yxatga olinadigan marshrutlarga ishora qiladi. O'sha modullar hali
/// ulanmagan bo'lsa go_router "Page not found" ekranini ko'rsatardi —
/// buning o'rniga band bosilganda `commonComingSoon` snackbar chiqadi.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n_extension.dart';

/// [location] uchun marshrut ro'yxatdan o'tganmi.
///
/// Faqat statik yo'llar tekshiriladi (`:id` kabi parametrli yo'llar bu
/// klasterda tashqi havola sifatida ishlatilmaydi).
bool isRouteRegistered(BuildContext context, String location) {
  final Set<String> paths = <String>{};
  _collect(GoRouter.of(context).configuration.routes, '', paths);
  return paths.contains(location);
}

void _collect(List<RouteBase> routes, String parent, Set<String> out) {
  for (final RouteBase route in routes) {
    String next = parent;
    if (route is GoRoute) {
      next = route.path.startsWith('/')
          ? route.path
          : '${parent == '/' ? '' : parent}/${route.path}';
      out.add(next);
    }
    _collect(route.routes, next, out);
  }
}

/// Marshrut bor bo'lsa o'tadi, aks holda snackbar ko'rsatadi.
void pushOrNotify(BuildContext context, String location) {
  if (isRouteRegistered(context, location)) {
    context.push(location);
    return;
  }
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.commonComingSoon)));
}
