/// `M-42` uchun tashqi bog'liqlik portlari (domen → data yo'nalishi).
///
/// Bu yerda **faqat interfeys** turadi; implementatsiya `data/` da (M5).
library;

/// M140/M141: haydash rejimi manbai.
///
/// Haqiqiy manba — `features/duty_status` (joriy duty status `DR` mi).
/// TODO(M-12): `duty_status` moduli tayyor bo'lgach `DutyStatusDrivingModeSource`
/// yoziladi va `chatDrivingModeSourceProvider` shunga override qilinadi.
abstract class DrivingModeSource {
  /// Joriy qiymat (`true` — `DR`).
  bool get isDriving;

  /// O'zgarishlar oqimi; birinchi element — joriy qiymat.
  Stream<bool> watch();

  /// M141 4-band: server `409 DRIVING_MODE_BLOCKED` qaytardi — lokal status
  /// **darhol** `DR` ga tenglashtiriladi (server haqiqat).
  void forceDriving();
}

/// Fayl yuklash jarayonining bitta bandi (M139/M149).
class ChatUploadHandle {
  const ChatUploadHandle({required this.queueId, required this.progress, required this.fileKey});

  /// `files_queue.id`.
  final int queueId;

  /// 0…1. Oxirgi element har doim `1`.
  final Stream<double> progress;

  /// Yuklash tugagach `presign` qaytargan `key`. Xatoda `Future` xato beradi.
  final Future<String> fileKey;
}

/// M139: chat biriktirmasi avval `files_queue` orqali yuklanadi, `file_key`
/// olingandan **keyingina** xabar yuboriladi.
abstract class ChatFileUploader {
  /// Faylni navbatga qo'yadi (oflayn ham ishlaydi — M149).
  Future<ChatUploadHandle> enqueue({
    required String localPath,
    required String contentType,
    required int sizeBytes,
  });
}
