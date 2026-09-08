/// `M-49 Contact support` forma domeni.
///
/// Validatsiya qoidasi shu yerda (widget ichida emas): `subject` majburiy
/// (`TicketCreate.subject` — `required`), `attachments` ≤3 (M114).
library;

import 'package:meta/meta.dart';

import 'support_ticket.dart';

enum TicketValidationError { subjectRequired, tooManyAttachments }

@immutable
class TicketDraft {
  const TicketDraft({
    this.contactOn = ContactChannel.email,
    this.subject = '',
    this.description = '',
    this.attachments = const <String>[],
  });

  final ContactChannel contactOn;
  final String subject;
  final String description;

  /// `POST /files/presign` orqali olingan kalitlar (M114).
  final List<String> attachments;

  /// M114: biriktirmalar soni chegarasi.
  static const int maxAttachments = 3;

  TicketDraft copyWith({
    ContactChannel? contactOn,
    String? subject,
    String? description,
    List<String>? attachments,
  }) => TicketDraft(
    contactOn: contactOn ?? this.contactOn,
    subject: subject ?? this.subject,
    description: description ?? this.description,
    attachments: attachments ?? this.attachments,
  );

  List<TicketValidationError> validate() => <TicketValidationError>[
    if (subject.trim().isEmpty) TicketValidationError.subjectRequired,
    if (attachments.length > maxAttachments) TicketValidationError.tooManyAttachments,
  ];

  bool get isValid => validate().isEmpty;

  /// `TicketCreate` tanasi. `company_id` **yuborilmaydi** (M164).
  Map<String, Object?> toPayload() => <String, Object?>{
    'subject': subject.trim(),
    'description': description.trim(),
    'contact_on': contactOn.wire,
    'attachments': attachments,
  };
}
