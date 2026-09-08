/// Log tahrirlash domen kontrakti (M5, M135).
library;

import 'log_edit_models.dart';

abstract interface class LogEditsRepository {
  /// `GET /log-edit-requests?status=pending` keshining lokal oqimi.
  Stream<List<LogEditRequestView>> watchPending();

  /// Bitta so'rov (`M-27`).
  Stream<LogEditRequestView?> watchById(String id);

  /// `POST /log-edit-requests/{id}/approve` — **outbox orqali** (M135).
  Future<void> approve(String id);

  /// `POST /log-edit-requests/{id}/reject` — sabab majburiy (§13.1).
  Future<void> reject({required String id, required String reason});
}
