/// Inspection domen kontraktlari — `presentation` faqat shularni ko'radi (M5).
library;

import 'inspection_models.dart';

/// Yo'l tekshiruvi (M-37…M-41).
abstract interface class InspectionRepository {
  /// `POST /inspection/begin`. Oflayn bo'lsa `null` qaytadi — kiosk rejimi
  /// baribir ochiladi, lekin lokal (oflayn) nusxa bilan (M-38).
  Future<InspectionSession?> begin();

  /// 7 kun + bugun. Onlayn — `GET /inspection/logs`;
  /// oflayn yoki xato — lokal Drift buferi (`InspectionSource.local`).
  ///
  /// [date] — oyna langari; `null` bo'lsa bugungi kun (Home Terminal TZ).
  Future<InspectionReport> logs({DateTime? date});

  /// `POST /inspection/email` — faqat onlayn (yozuv amali).
  Future<void> sendEmail(InspectionEmailRequest request);

  /// `POST /inspection/transfer` — faqat onlayn.
  Future<InspectionTransferResult> transfer({DateTime? date, String? comment});
}

/// `M-39` chiqish PIN'i (oflayn hash — M16; kiosk odatda tarmoqsiz).
abstract interface class InspectionPinVerifier {
  /// PIN to'g'ri bo'lsa `true`. Qulflangan bo'lsa [InspectionPinLocked],
  /// PIN umuman o'rnatilmagan bo'lsa [InspectionPinNotSet] otiladi —
  /// ikkalasida ham kioskdan chiqishga **ruxsat yo'q** (S-H1, fail-closed).
  Future<bool> verify(String pin);
}

/// 5 ta ketma-ket xato urinishdan keyin.
class InspectionPinLocked implements Exception {
  const InspectionPinLocked({this.retryAfter});

  /// Blok tugashiga qolgan vaqt (mavjud bo'lsa).
  final Duration? retryAfter;
}

/// PIN o'rnatilmagan (`PIN_NOT_SET`) — kiosk rejimidan chiqish **rad etiladi**.
///
/// [InspectionPinLocked] dan meros oladi, shuning uchun mavjud
/// `on InspectionPinLocked` tutqichlari uni ham qamrab oladi (fail-closed).
class InspectionPinNotSet extends InspectionPinLocked {
  const InspectionPinNotSet();
}
