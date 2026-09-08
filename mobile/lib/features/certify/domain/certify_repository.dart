/// Sertifikatsiya domen kontraktlari (M5).
library;

import 'dart:typed_data';

import 'certify_models.dart';

/// M124: oyna doim **8 kun**.
const int kCertificationWindowDays = 8;

abstract interface class CertifyRepository {
  /// Sertifikatsiya oynasi (M124), tartib: `needs_recertify` → `uncertified`
  /// → `not_ready` → `pending` → `certified`, ichida yangi kun birinchi.
  Stream<List<CertifyDay>> watchWindow({int days = kCertificationWindowDays});

  /// Bitta kun (M130: 8 kundan eski kun `Log Report` dan ochiladi).
  Stream<CertifyDay> watchDay(DateTime date);

  /// **M126:** bitta imzo — har kun uchun alohida `certify` outbox yozuvi.
  /// **M128:** oflaynda ham ishlaydi (fayl `files_queue` ga tushadi).
  Future<CertifyOutcome> certify({
    required List<DateTime> dates,
    required SignatureInput signature,
  });
}

/// Imzo fayllari (§16, M127/M149).
abstract interface class SignatureStore {
  /// Saqlangan imzo `signature_id` (bo'lmasa `null`).
  Future<String?> savedSignatureId();

  /// Saqlangan imzoning lokal PNG yo'li (oldindan ko'rsatish uchun).
  Future<String?> savedSignaturePath();

  /// PNG ni lokal saqlaydi va `files_queue` ga qo'yadi; lokal yo'lni qaytaradi.
  /// [remember] — `Save my signature`.
  Future<String> enqueue(Uint8List png, {required bool remember});
}
