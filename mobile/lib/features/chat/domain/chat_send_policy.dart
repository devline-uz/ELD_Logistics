/// Chat yuborish qoidalari — **sof funksiyalar**, widget/provayderda emas.
///
/// tz-mobile §14 (`text` ≤2000, fayl ≤10 MB), §14.2 M140/M141 (haydash rejimi),
/// `swagger.json` `chat_dto.MessageCreate` cheklovlari.
library;

import 'chat_message.dart';

/// Server cheklovlari (`chat_dto.MessageCreate.text.maxLength`).
const int kChatTextMaxLength = 2000;

/// §16: `kind=chat` fayl chegarasi. Server `max_bytes` kanonik (M148),
/// bu faqat oldindan tekshirish.
const int kChatFileMaxBytes = 10 * 1024 * 1024;

/// Nima uchun yuborib bo'lmaydi.
enum ChatSendRejection {
  /// Bo'sh matn — tugma umuman faol bo'lmaydi.
  emptyText,

  /// M140: duty status `DR`.
  drivingMode,

  /// ≥2000 belgi.
  textTooLong,

  /// ≥10 MB.
  fileTooLarge,

  /// `location` uchun `lat`/`lng` yo'q yoki diapazondan tashqarida.
  invalidLocation,
}

/// Tekshiruv natijasi.
class ChatSendVerdict {
  const ChatSendVerdict.allowed() : rejection = null;
  const ChatSendVerdict.rejected(ChatSendRejection reason) : rejection = reason;

  final ChatSendRejection? rejection;

  bool get isAllowed => rejection == null;
}

/// M140/M141: `DR` da yozish bloklanadi, o'qish bloklanmaydi.
///
/// [isDriving] lokal duty status'dan keladi; server `409 DRIVING_MODE_BLOCKED`
/// qaytarsa u ham shu bayroqni yoqadi (M141 4-band — server haqiqat).
ChatSendVerdict evaluateChatSend({
  required ChatDraft draft,
  required bool isDriving,
  int? fileSizeBytes,
}) {
  if (isDriving) {
    return const ChatSendVerdict.rejected(ChatSendRejection.drivingMode);
  }
  switch (draft.kind) {
    case ChatMessageKind.text:
      final String body = draft.text?.trim() ?? '';
      if (body.isEmpty) {
        return const ChatSendVerdict.rejected(ChatSendRejection.emptyText);
      }
      if (body.length > kChatTextMaxLength) {
        return const ChatSendVerdict.rejected(ChatSendRejection.textTooLong);
      }
    case ChatMessageKind.image:
    case ChatMessageKind.file:
      if (fileSizeBytes != null && fileSizeBytes > kChatFileMaxBytes) {
        return const ChatSendVerdict.rejected(ChatSendRejection.fileTooLarge);
      }
      if ((draft.text?.length ?? 0) > kChatTextMaxLength) {
        return const ChatSendVerdict.rejected(ChatSendRejection.textTooLong);
      }
    case ChatMessageKind.location:
      final double? lat = draft.lat;
      final double? lng = draft.lng;
      if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) {
        return const ChatSendVerdict.rejected(ChatSendRejection.invalidLocation);
      }
  }
  return const ChatSendVerdict.allowed();
}

/// M141 3-band: `DR` dan chiqqanda avtomatik qayta yuboriladigan xabarlar.
///
/// Faqat `blocked` holatidagi **o'z** xabarlarim; tartib `createdAt` bo'yicha
/// (M20 — navbat tartibi buzilmaydi).
List<ChatMessage> messagesToResendAfterDriving(List<ChatMessage> all) {
  final List<ChatMessage> blocked = all
      .where((ChatMessage m) => m.isMine && m.status == ChatMessageStatus.blocked)
      .toList();
  blocked.sort((ChatMessage a, ChatMessage b) => a.createdAt.compareTo(b.createdAt));
  return blocked;
}

/// Sana ajratgichlari uchun kunlar bo'yicha guruhlash (dizayn: `13:40` ustidagi
/// ajratgich). Kirish **eskidan yangiga** tartiblangan bo'lishi kutiladi.
///
/// Kun chegarasi [dayOf] orqali beriladi — Home Terminal TZ ni domen bilmaydi
/// (M42), uni chaqiruvchi beradi.
List<ChatDaySection> groupChatByDay(
  List<ChatMessage> messages, {
  required DateTime Function(DateTime) dayOf,
}) {
  final List<ChatDaySection> sections = <ChatDaySection>[];
  for (final ChatMessage message in messages) {
    final DateTime day = dayOf(message.createdAt);
    if (sections.isNotEmpty && sections.last.day == day) {
      sections.last.messages.add(message);
    } else {
      sections.add(ChatDaySection(day: day, messages: <ChatMessage>[message]));
    }
  }
  return sections;
}

/// Bitta kun bloki.
class ChatDaySection {
  ChatDaySection({required this.day, required this.messages});

  final DateTime day;
  final List<ChatMessage> messages;
}
