/// Chat port'i — `presentation` shu interfeysga bog'lanadi, `data` uni bajaradi.
library;

import 'chat_message.dart';

abstract class ChatRepository {
  /// Lokal keshdagi xabarlar (eskidan yangiga). Oflayn ham to'ladi (§5.2:
  /// oxirgi 500 xabar / 30 kun).
  Stream<List<ChatMessage>> watchMessages();

  /// Kursor sahifasi (`GET /chat/threads/{driver_id}/messages?before&limit`).
  ///
  /// [before] `null` — eng yangi sahifa. Natija lokal keshga yoziladi.
  Future<ChatPage> loadPage({DateTime? before, int limit = 50});

  /// M138: darhol navbatga yoziladi va `queued` holatida ko'rinadi.
  ///
  /// Onlayn bo'lsa darhol `POST` qilinadi; `409 DRIVING_MODE_BLOCKED` bo'lsa
  /// xabar **yo'qolmaydi**, `blocked` ga o'tadi (M141).
  Future<void> send(ChatDraft draft, {int? fileSizeBytes});

  /// Rad etilgan yoki bloklangan xabarni qayta navbatga qo'yish.
  Future<void> retry(String clientId);

  /// M141 3-band: `DR` dan chiqqanda barcha `blocked` xabarlar qayta yuboriladi.
  Future<void> resendBlocked();

  /// `POST /chat/messages/{id}/read`.
  Future<void> markRead(String messageId);

  /// M140: duty status `DR` mi. Kiritish qatori shunga qarab bloklanadi.
  Stream<bool> watchDrivingMode();

  /// Navbatdagi (`queued`) xabarlar soni — oflayn banneri uchun.
  Stream<int> watchQueuedCount();
}
