/// M139/§14.3: biriktirma va lokatsiya manbalari (portlar).
///
/// TODO(P12): `image_picker` / `file_picker` / `geolocator` paketlari hali
/// `pubspec.yaml` da yo'q (litsenziya ko'rigi arxitektor zimmasida) — shuning
/// uchun UI faqat shu portga bog'lanadi, implementatsiya keyin qo'shiladi.
library;

/// Foydalanuvchi tanlagan fayl.
class PickedAttachment {
  const PickedAttachment({required this.path, required this.contentType, required this.sizeBytes});

  /// `app_support/pending_files/` ichidagi lokal nusxa (M149).
  final String path;
  final String contentType;
  final int sizeBytes;
}

/// Biriktirma turi — `+` menyusidagi bandlar.
enum ChatAttachmentKind { photo, file, location }

abstract class ChatAttachmentPicker {
  /// `null` — foydalanuvchi bekor qildi yoki manba mavjud emas.
  Future<PickedAttachment?> pick(ChatAttachmentKind kind);
}

/// GPS nuqtasi (§14.3) — xaritasiz, faqat koordinata.
class ChatLocationFix {
  const ChatLocationFix({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

abstract class ChatLocationSource {
  Future<ChatLocationFix?> current();
}
