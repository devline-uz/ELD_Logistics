/// DVIR domen kontraktlari (`presentation` faqat shularni ko'radi, M5).
library;

import 'dvir_models.dart';

/// Nuqson katalogi (M105): serverdan, oflayn — lokal keshdan.
abstract interface class DefectCatalogRepository {
  /// Tozalangan (sanitize qilingan) katalog. Server javobi bo'lmasa keshdan,
  /// u ham bo'lmasa dizayn fallback ro'yxatidan.
  Future<List<DefectType>> load({bool forceRefresh = false});
}

/// Trailer raqamlari (`GET /trailers` keshi).
abstract interface class TrailerRepository {
  Future<List<TrailerRef>> search(String query);
}

/// `GET /trailers` bandi.
class TrailerRef {
  const TrailerRef({required this.id, required this.number});

  final String id;
  final String number;
}

/// DVIR yaratish/o'qish (`/dvir-reports`).
abstract interface class DvirRepository {
  /// Joriy haydovchi konteksti — `M-32` `Driver Information` bloki.
  Future<DvirContext> currentContext();

  /// `POST /dvir-reports`. Oflayn bo'lsa outbox'ga yoziladi va
  /// [DvirSubmitResult.queued] qaytadi (`Idempotency-Key` = `clientId`).
  Future<DvirSubmitResult> submit(DvirDraft draft);

  /// `GET /dvir-reports/{id}` (oflayn — lokal `dvir_reports`).
  Future<DvirReport?> byId(String id);

  /// `GET /dvir-reports/pending-certification` (M-36).
  Future<List<DvirReport>> pendingCertification({String? unitId});

  /// `POST /dvir-reports/{id}/certify`. Oflayn — outbox.
  Future<DvirSubmitResult> certify({required String reportId, required String signatureKey});

  /// `GET /dvir-reports/{id}/pdf` — faqat onlayn; lokal fayl yo'li qaytadi.
  Future<String> downloadPdf(String id);
}

/// Yuborish natijasi.
class DvirSubmitResult {
  const DvirSubmitResult({required this.queued, this.report});

  /// `true` — oflayn, outbox'da navbatda (`M-34` xabari boshqacha).
  final bool queued;

  /// Onlayn yuborilgan bo'lsa — server javobi.
  final DvirReport? report;
}

/// Foto va imzo fayllari (§16, M147, M149).
abstract interface class DvirFileRepository {
  /// Foto tanlash mavjudmi (kamera/galereya plagini ulanganmi).
  bool get isPhotoCaptureAvailable;

  /// Kamera yoki galereyadan foto oladi; bekor qilinsa `null`.
  Future<String?> capturePhoto({required bool fromCamera});

  /// Fotoni siqadi, EXIF GPS ni tozalaydi (M147) va `files_queue` ga qo'yadi.
  /// Qaytadi: lokal fayl yo'li.
  Future<String> enqueuePhoto(String sourcePath);

  /// Imzo PNG ini saqlaydi va `files_queue` ga qo'yadi; lokal yo'l qaytadi.
  Future<String> enqueueSignature(List<int> pngBytes);
}
