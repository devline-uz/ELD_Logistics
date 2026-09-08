/// `M-42` domen modeli (tz-mobile §14, `swagger.json` `chat_dto.Message`).
///
/// `presentation` **faqat** shu modelni ko'radi; `eld_api`/Drift qatorlari
/// `data` qatlamida shu yerga o'giriladi (M5).
library;

/// Xabar turi — `chat_dto.MessageCreate.kind` enum'i bilan bir xil.
enum ChatMessageKind {
  text('text'),
  image('image'),
  file('file'),
  location('location');

  const ChatMessageKind(this.wire);

  /// Serverga va SQLite ga yoziladigan qiymat.
  final String wire;

  /// Noma'lum qiymat hech qachon crash qilmaydi — `text` ga tushadi.
  static ChatMessageKind fromWire(String? wire) {
    for (final ChatMessageKind kind in ChatMessageKind.values) {
      if (kind.wire == wire) {
        return kind;
      }
    }
    return ChatMessageKind.text;
  }
}

/// Yuborish holati.
///
/// `sent`/`delivered`/`read` — serverdan (`chat_dto.Message.status`).
/// `queued`/`blocked`/`failed` — **faqat mijozda** (M138, M141).
enum ChatMessageStatus {
  /// M138: `chat_outbox` da, push hali ketmagan.
  queued('queued'),

  /// M141: server `409 DRIVING_MODE_BLOCKED` qaytardi.
  blocked('blocked'),

  sent('sent'),
  delivered('delivered'),
  read('read'),

  /// Push rad etdi — `Retry` ko'rsatiladi.
  failed('failed');

  const ChatMessageStatus(this.wire);

  final String wire;

  static ChatMessageStatus fromWire(String? wire) {
    for (final ChatMessageStatus status in ChatMessageStatus.values) {
      if (status.wire == wire) {
        return status;
      }
    }
    return ChatMessageStatus.sent;
  }

  /// Hali serverga yetib bormagan (soat ikonkasi).
  bool get isPending => this == queued;

  /// Foydalanuvchi aralashuvi kerak (qizil `!` + `Retry`).
  bool get needsAttention => this == failed || this == blocked;
}

/// Xabarni kim yozgani. Server tomonida `sender_side`.
enum ChatSenderSide { driver, office }

/// Bitta chat xabari.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.kind,
    required this.side,
    required this.status,
    required this.createdAt,
    this.clientId,
    this.text,
    this.fileKey,
    this.lat,
    this.lng,
    this.uploadProgress,
  });

  /// Server id, yoki hali yuborilmagan xabar uchun `clientId`.
  final String id;

  /// M19/M138: qurilmada generatsiya qilingan idempotentlik kaliti.
  final String? clientId;

  final ChatMessageKind kind;
  final ChatSenderSide side;
  final ChatMessageStatus status;

  /// UTC.
  final DateTime createdAt;

  /// `text` xabar tanasi yoki boshqa turlar uchun izoh.
  final String? text;

  /// `POST /files/presign` qaytargan kalit (M139).
  final String? fileKey;

  final double? lat;
  final double? lng;

  /// M139: 0…1, fayl yuklanayotgan payt. `null` — yuklash yo'q.
  final double? uploadProgress;

  bool get isMine => side == ChatSenderSide.driver;

  /// M139: fayl hali yuklanmoqda, xabar yuborilmagan.
  bool get isUploading => uploadProgress != null && uploadProgress! < 1;

  ChatMessage copyWith({ChatMessageStatus? status, String? fileKey, double? uploadProgress}) =>
      ChatMessage(
        id: id,
        clientId: clientId,
        kind: kind,
        side: side,
        status: status ?? this.status,
        createdAt: createdAt,
        text: text,
        fileKey: fileKey ?? this.fileKey,
        lat: lat,
        lng: lng,
        uploadProgress: uploadProgress ?? this.uploadProgress,
      );

  @override
  bool operator ==(Object other) =>
      other is ChatMessage &&
      other.id == id &&
      other.status == status &&
      other.uploadProgress == uploadProgress;

  @override
  int get hashCode => Object.hash(id, status, uploadProgress);
}

/// Yuborilayotgan xabar (UI → domen).
class ChatDraft {
  const ChatDraft.text(String value)
    : kind = ChatMessageKind.text,
      text = value,
      lat = null,
      lng = null,
      localFilePath = null;

  const ChatDraft.location({required double latitude, required double longitude})
    : kind = ChatMessageKind.location,
      text = null,
      lat = latitude,
      lng = longitude,
      localFilePath = null;

  const ChatDraft.file({required String path, String? caption})
    : kind = ChatMessageKind.file,
      text = caption,
      lat = null,
      lng = null,
      localFilePath = path;

  const ChatDraft.image({required String path, String? caption})
    : kind = ChatMessageKind.image,
      text = caption,
      lat = null,
      lng = null,
      localFilePath = path;

  final ChatMessageKind kind;
  final String? text;
  final double? lat;
  final double? lng;

  /// M139/M149: `app_support/pending_files/` dagi lokal nusxa.
  final String? localFilePath;
}

/// Kursor sahifasi (`chat_dto.CursorMeta`).
class ChatPage {
  const ChatPage({required this.messages, required this.hasMore, this.nextBefore, this.unread = 0});

  static const ChatPage empty = ChatPage(messages: <ChatMessage>[], hasMore: false);

  final List<ChatMessage> messages;
  final bool hasMore;

  /// Keyingi (eskiroq) sahifa uchun `?before` qiymati.
  final DateTime? nextBefore;

  final int unread;
}
