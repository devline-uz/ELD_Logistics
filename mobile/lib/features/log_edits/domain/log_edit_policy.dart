/// **M133/M134 — `Approve` bloklash qoidalari.** Sof domen mantiq:
/// widget faqat natijani ko'rsatadi, qoidani o'zi hisoblamaydi.
library;

import 'log_edit_models.dart';

/// `Approve` nima uchun bloklangan.
enum LogEditBlock {
  /// M133: avtomatik yozilgan `DR` qisqartirilgan yoki boshqa statusga
  /// o'zgartirilgan. Ruxsat etilgan istisno — `DR → PC` / `DR → YM`.
  drivingImmutable,

  /// M134: `intermediate`, `power_on/off`, `malfunction`, `diagnostic`
  /// eventlari umuman tahrirlanmaydi (`EVENT_IMMUTABLE`).
  eventImmutable,
}

/// M134 dagi tahrirlanmaydigan event turlari.
const Set<String> kImmutableEventTypes = <String>{
  'intermediate',
  'power_on',
  'power_off',
  'malfunction',
  'diagnostic',
};

/// Maxsus rejimga o'tish (`pc`/`ym`) — M133 istisnosi.
bool _isSpecialTarget(String special) => special == 'pc' || special == 'ym';

/// Bitta o'zgarish uchun bloklash sababi (`null` — ruxsat etilgan).
LogEditBlock? blockOfChange(LogEditChange change) {
  if (kImmutableEventTypes.contains(change.eventType)) {
    return LogEditBlock.eventImmutable;
  }
  final bool touchesAutoDriving =
      change.currentStatus == 'DR' &&
      (change.currentOrigin == null || change.currentOrigin == 'auto');
  if (touchesAutoDriving && !_isSpecialTarget(change.proposedSpecial)) {
    return LogEditBlock.drivingImmutable;
  }
  return null;
}

/// So'rov bo'yicha yakuniy bloklash sababi — bitta o'zgarish bloklansa,
/// butun so'rov `Approve` uchun yopiladi.
LogEditBlock? blockOfRequest(LogEditRequestView request) {
  LogEditBlock? result;
  for (final LogEditChange change in request.changes) {
    final LogEditBlock? block = blockOfChange(change);
    if (block == LogEditBlock.eventImmutable) {
      return block;
    }
    result ??= block;
  }
  return result;
}

/// M-27: `Reject` sababi majburiy va ≤200 belgi.
const int kRejectReasonMaxLength = 200;

/// `null` — sabab yaroqli.
enum RejectReasonIssue { empty, tooLong }

RejectReasonIssue? validateRejectReason(String reason) {
  final String trimmed = reason.trim();
  if (trimmed.isEmpty) {
    return RejectReasonIssue.empty;
  }
  if (trimmed.length > kRejectReasonMaxLength) {
    return RejectReasonIssue.tooLong;
  }
  return null;
}
