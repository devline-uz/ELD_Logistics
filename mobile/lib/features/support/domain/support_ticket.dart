/// `M-49`…`M-51` domen modellari (`contracts/swagger.json` → `Ticket`,
/// `TicketMessage`).
///
/// `data` qatlami API javobini shu tiplarga o'giradi — API modeli
/// `presentation` ga chiqmaydi (M5).
library;

import 'package:meta/meta.dart';

/// **M115 ✅** Kanonik holatlar: `New` · `In Progress` · `Resolved`
/// (+ backend qaytaradigan `Closed`). Haydovchi holatni **o'zgartira olmaydi**.
enum TicketStatus {
  newly('new'),
  inProgress('in_progress'),
  resolved('resolved'),
  closed('closed');

  const TicketStatus(this.wire);

  final String wire;

  static TicketStatus fromWire(String? wire) {
    for (final TicketStatus s in TicketStatus.values) {
      if (s.wire == wire) {
        return s;
      }
    }
    return TicketStatus.newly;
  }
}

/// `Contact On` — `TicketCreate.contact_on` enum'i.
enum ContactChannel {
  email('email'),
  phone('phone'),
  sms('sms'),
  inApp('in_app');

  const ContactChannel(this.wire);

  final String wire;

  /// `M-49` formada faqat ikkita variant ko'rsatiladi (Figma `1179:7028`).
  static const List<ContactChannel> selectable = <ContactChannel>[
    ContactChannel.email,
    ContactChannel.phone,
  ];

  static ContactChannel fromWire(String? wire) {
    for (final ContactChannel c in ContactChannel.values) {
      if (c.wire == wire) {
        return c;
      }
    }
    return ContactChannel.email;
  }
}

@immutable
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.status,
    required this.subject,
    this.number,
    this.description = '',
    this.contactOn,
    this.createdAt,
    this.messageCount = 0,
    this.attachments = const <String>[],
  });

  final String id;

  /// Figma dagi qisqa raqam (`#122546`). Backend bermasa `id` ning oxirgi
  /// bo'lagi ishlatiladi.
  final String? number;

  final TicketStatus status;
  final String subject;
  final String description;
  final ContactChannel? contactOn;
  final DateTime? createdAt;
  final int messageCount;
  final List<String> attachments;

  /// Ro'yxatda ko'rsatiladigan raqam.
  String get displayNumber => number ?? (id.length > 6 ? id.substring(id.length - 6) : id);
}

@immutable
class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.text,
    this.senderName,
    this.createdAt,
    this.attachments = const <String>[],
  });

  final String id;
  final String text;
  final String? senderName;
  final DateTime? createdAt;
  final List<String> attachments;
}

/// `M-51` ekrani holati: tiket + xabarlar.
@immutable
class TicketThread {
  const TicketThread({required this.ticket, required this.messages});

  final SupportTicket ticket;
  final List<SupportMessage> messages;
}
