/// Sertifikatsiya domen modellari (tz-mobile §12, M-29…M-31).
library;

import 'dart:typed_data';

/// Kun holati (§12.1 jadvali).
enum CertifyStatus {
  /// `daily_logs.certification_status = uncertified`.
  uncertified,

  certified,

  /// Tahrirdan keyin (`recertify_required`) — ro'yxatda yuqorida turadi (M131).
  needsRecertify,

  /// Outbox'da (M128) — `Certified (pending sync)`.
  pendingSync,

  /// `DailyLogSummary.ready == false` (M125) — mobil o'zi hisoblamaydi.
  notReady,
}

/// `M-29` ro'yxatining bitta bandi.
class CertifyDay {
  const CertifyDay({required this.date, required this.status, this.signedAt});

  /// Home Terminal TZ dagi kun (00:00).
  final DateTime date;

  final CertifyStatus status;
  final DateTime? signedAt;

  /// M123: sertifikatlangan kun ko'rsatiladi, lekin belgilab bo'lmaydi.
  /// `Not Ready` kun ham tanlanmaydi (M125).
  bool get selectable =>
      status == CertifyStatus.uncertified || status == CertifyStatus.needsRecertify;

  /// M131: qayta sertifikatsiya kerak bo'lgan kun ro'yxat boshida.
  int get sortPriority => switch (status) {
    CertifyStatus.needsRecertify => 0,
    CertifyStatus.uncertified => 1,
    CertifyStatus.notReady => 2,
    CertifyStatus.pendingSync => 3,
    CertifyStatus.certified => 4,
  };
}

/// Imzo manbai (M127): yangi chizilgan PNG yoki saqlangan imzo.
class SignatureInput {
  const SignatureInput.drawn(Uint8List this.png, {this.save = false}) : savedSignatureId = null;

  const SignatureInput.saved(String this.savedSignatureId) : png = null, save = false;

  /// Yangi chizilgan imzo (PNG baytlari).
  final Uint8List? png;

  /// `POST /files/presign` qayta chaqirilmaydi — `signature_id` yuboriladi.
  final String? savedSignatureId;

  /// `Save my signature` checkbox'i.
  final bool save;

  bool get isEmpty => png == null && savedSignatureId == null;
}

/// Sertifikatsiya natijasi (M126: qisman muvaffaqiyat bo'lishi mumkin).
class CertifyOutcome {
  const CertifyOutcome({required this.queued, required this.failed});

  /// Muvaffaqiyatli navbatga qo'yilgan kunlar.
  final List<DateTime> queued;

  /// Rad etilgan kunlar va sabab kodi (`LOG_NOT_READY`, `log_locked`, …).
  final Map<DateTime, String> failed;

  int get total => queued.length + failed.length;

  bool get isFullSuccess => failed.isEmpty;
}
