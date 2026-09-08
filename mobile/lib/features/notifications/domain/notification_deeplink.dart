/// M145 — deep link mapping. **Sof funksiyalar**: `go_router` ga bog'liq emas,
/// faqat marshrut satrini qaytaradi (chaqiruvchi navigatsiyani o'zi qiladi).
///
/// Manba: tz-mobile §15.2 jadvali (`alert_type` → deep link) va §11.1 registri.
library;

import 'app_notification.dart';

/// M145: ilova sxemasi (`onebookeld://<path>`).
const String kDeepLinkScheme = 'onebookeld';

/// **M162** — universal (App Link / App Site Association) host. Boshqa
/// hostdan kelgan `https` link **ochilmaydi**.
const String kDeepLinkHost = 'eld.stackyard.uz';

/// Ekran marshrutlari — §11.1 registridan **aynan** ko'chirilgan.
abstract final class NotificationTarget {
  const NotificationTarget._();

  static const String logs = '/logs';
  static const String certify = '/certify';
  static const String eld = '/eld';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String pendingEdits = '/logs/pending-edits';

  /// M-12 — idle prompt (M62) bosilganda.
  static const String dutyChange = '/duty/change';

  /// M-55 — sync konflikti (M146).
  static const String syncConflicts = '/sync/conflicts';
}

/// `alert_type` (+ `entity_id`) → ilova ichidagi marshrut.
///
/// `null` — bandda deep link yo'q yoki bildirishnoma haydovchiga taalluqli emas
/// (§15.2 dagi ❌ satrlari).
///
/// [logDate] — `hos_*` uchun `yyyy-MM-dd`; berilmasa `/logs` ochiladi.
String? notificationDeepLink(AlertType? type, {String? entityId, String? logDate}) {
  if (type == null || !type.isDriverVisible) {
    return null;
  }
  // `entityId`/`logDate` serverdan keladi — natija oq ro'yxatdan o'tkaziladi
  // (M162: `../` yoki begona segment marshrutga tushmaydi).
  final String? route = _rawDeepLink(type, entityId: entityId, logDate: logDate);
  return isAllowedNotificationRoute(route) ? route : null;
}

String? _rawDeepLink(AlertType type, {String? entityId, String? logDate}) {
  return switch (type) {
    AlertType.hosWarning || AlertType.hosViolation =>
      logDate == null ? NotificationTarget.logs : '${NotificationTarget.logs}?date=$logDate',
    AlertType.logEditRequest =>
      entityId == null || entityId.isEmpty
          ? NotificationTarget.notifications
          : '${NotificationTarget.pendingEdits}/$entityId',
    AlertType.uncertifiedLog => NotificationTarget.certify,
    AlertType.eldDisconnected || AlertType.eldMalfunction => NotificationTarget.eld,
    AlertType.chatMessage => NotificationTarget.chat,
    // `route_*` va `maintenance_*` uchun alohida ekran yo'q (M67).
    AlertType.routeAssigned ||
    AlertType.routeCompleted ||
    AlertType.maintenanceUpcoming ||
    AlertType.maintenanceOverdue => NotificationTarget.notifications,
    _ => null,
  };
}

/// **M162 oq ro'yxati** — deep link **faqat** shu marshrutlarni ocha oladi.
///
/// Sxema tekshiruvi yetarli emas: `onebookeld://` ni istalgan ilova yoki
/// veb-sahifa yuborishi mumkin, shuning uchun natija marshrut sifatida ham
/// tekshiriladi. Ro'yxatda yo'q yo'l — `null` (router hech qayerga ketmaydi).
const Set<String> _allowedStaticRoutes = <String>{
  NotificationTarget.logs,
  NotificationTarget.certify,
  NotificationTarget.eld,
  NotificationTarget.chat,
  NotificationTarget.notifications,
  NotificationTarget.pendingEdits,
  NotificationTarget.dutyChange,
  NotificationTarget.syncConflicts,
};

/// Identifikator bilan tugaydigan marshrutlar (`/logs/pending-edits/<id>`).
const Set<String> _allowedIdRoutes = <String>{NotificationTarget.pendingEdits};

/// Har marshrut uchun ruxsat etilgan query kalitlari.
const Map<String, Set<String>> _allowedQueryKeys = <String, Set<String>>{
  NotificationTarget.logs: <String>{'date'},
};

/// Yo'l segmenti / query qiymati uchun xavfsiz belgilar.
final RegExp _safeSegment = RegExp(r'^[A-Za-z0-9_.:-]{1,64}$');

/// Marshrut oq ro'yxatdan o'tadimi (M162).
///
/// Tekshiriladi: yo'l `/` bilan boshlanadi, `//` (protokolsiz URL) va `..`
/// yo'q, yo'l ro'yxatda bor, query kalitlari ruxsat etilgan va qiymatlari
/// xavfsiz.
bool isAllowedNotificationRoute(String? route) {
  if (route == null || !route.startsWith('/') || route.startsWith('//')) {
    return false;
  }
  if (route.contains('..') || route.contains('\\')) {
    return false;
  }
  final int q = route.indexOf('?');
  final String path = q == -1 ? route : route.substring(0, q);
  final String query = q == -1 ? '' : route.substring(q + 1);

  if (!_allowedStaticRoutes.contains(path)) {
    final int slash = path.lastIndexOf('/');
    final String parent = slash <= 0 ? '' : path.substring(0, slash);
    final String id = path.substring(slash + 1);
    if (!_allowedIdRoutes.contains(parent) || !_safeSegment.hasMatch(id)) {
      return false;
    }
  }

  if (query.isEmpty) {
    return true;
  }
  final Set<String> allowedKeys =
      _allowedQueryKeys[path] ?? _allowedQueryKeys[_parentOf(path)] ?? const <String>{};
  for (final String pair in query.split('&')) {
    final int eq = pair.indexOf('=');
    final String key = eq == -1 ? pair : pair.substring(0, eq);
    final String value = eq == -1 ? '' : pair.substring(eq + 1);
    if (!allowedKeys.contains(key) || !_safeSegment.hasMatch(value)) {
      return false;
    }
  }
  return true;
}

String _parentOf(String path) {
  final int slash = path.lastIndexOf('/');
  return slash <= 0 ? path : path.substring(0, slash);
}

/// `onebookeld://logs?date=2026-09-07` → `/logs?date=2026-09-07`.
///
/// **M162:** faqat `onebookeld://` sxemasi yoki `https://eld.stackyard.uz`
/// hosti qabul qilinadi, natija esa [isAllowedNotificationRoute] oq
/// ro'yxatidan o'tishi shart. Boshqa hamma narsa — `null`.
String? parseNotificationDeepLink(Uri? uri) {
  if (uri == null) {
    return null;
  }
  final List<String> segments;
  if (uri.scheme == kDeepLinkScheme) {
    // Maxsus sxemada birinchi segment `host` sifatida ko'rinadi.
    segments = <String>[uri.host, ...uri.pathSegments];
  } else if (uri.scheme == 'https' && uri.host == kDeepLinkHost) {
    segments = uri.pathSegments;
  } else {
    return null;
  }
  final String path = segments.where((String s) => s.isNotEmpty).join('/');
  if (path.isEmpty) {
    return null;
  }
  final String query = uri.query.isEmpty ? '' : '?${uri.query}';
  final String route = '/$path$query';
  return isAllowedNotificationRoute(route) ? route : null;
}

/// Push `data` payload'idan marshrut (M145): avval `deep_link`, keyin
/// `alert_type` + `entity_id`.
String? deepLinkFromPayload(Map<String, String> data) {
  final String? raw = data['deep_link'];
  if (raw != null && raw.isNotEmpty) {
    // Push payload ishonchsiz manba: sxema, host va marshrut tekshiriladi.
    return parseNotificationDeepLink(Uri.tryParse(raw));
  }
  return notificationDeepLink(
    AlertType.fromWire(data['alert_type']),
    entityId: data['entity_id'],
    logDate: data['log_date'],
  );
}
