/// `M-49`…`M-51` domen shartnomasi.
library;

import '../../profile/domain/submit_outcome.dart';
import 'support_ticket.dart';
import 'ticket_draft.dart';

abstract interface class SupportRepository {
  /// `GET /support-tickets`.
  Future<List<SupportTicket>> list();

  /// `GET /support-tickets/{id}` + `GET /support-tickets/{id}/messages`.
  Future<TicketThread> thread(String id);

  /// `POST /support-tickets`. Oflayn — outbox.
  Future<SubmitOutcome> create(TicketDraft draft);

  /// `POST /support-tickets/{id}/messages`. Oflayn — outbox.
  Future<SubmitOutcome> reply({required String ticketId, required String text});
}
