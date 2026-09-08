/// `M-26`/`M-27` DI simlari va tafsilot kontrolleri (M3, M135).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/error/api_error.dart';
import '../../../../core/session/session_context.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../data/log_edits_repository_impl.dart';
import '../../domain/log_edit_models.dart';
import '../../domain/log_edit_policy.dart';
import '../../domain/log_edits_repository.dart';

final Provider<LogEditsRepository> logEditsRepositoryProvider = Provider<LogEditsRepository>(
  (Ref ref) => DriftLogEditsRepository(
    logs: ref.watch(logsDaoProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    driverId: ref.watch(sessionContextProvider).driverId,
  ),
);

/// `M-26` ro'yxati.
final StreamProvider<List<LogEditRequestView>> pendingEditsProvider =
    StreamProvider<List<LogEditRequestView>>(
      (Ref ref) => ref.watch(logEditsRepositoryProvider).watchPending(),
    );

/// `M-27` tafsiloti.
final pendingEditProvider = StreamProvider.family<LogEditRequestView?, String>(
  (Ref ref, String id) => ref.watch(logEditsRepositoryProvider).watchById(id),
);

class LogEditDetailState {
  const LogEditDetailState({
    this.reason = '',
    this.showReasonField = false,
    this.submitting = false,
    this.reasonIssue,
    this.error,
    this.done = false,
  });

  final String reason;

  /// `Reject` bosilganda sabab maydoni ochiladi (§13.3).
  final bool showReasonField;
  final bool submitting;
  final RejectReasonIssue? reasonIssue;
  final ApiError? error;

  /// Qaror qabul qilindi — ekran yopiladi.
  final bool done;

  LogEditDetailState copyWith({
    String? reason,
    bool? showReasonField,
    bool? submitting,
    RejectReasonIssue? reasonIssue,
    bool clearReasonIssue = false,
    ApiError? error,
    bool clearError = false,
    bool? done,
  }) => LogEditDetailState(
    reason: reason ?? this.reason,
    showReasonField: showReasonField ?? this.showReasonField,
    submitting: submitting ?? this.submitting,
    reasonIssue: clearReasonIssue ? null : (reasonIssue ?? this.reasonIssue),
    error: clearError ? null : (error ?? this.error),
    done: done ?? this.done,
  );
}

/// Bir vaqtda faqat bitta `M-27` ochiq bo'ladi, shuning uchun kontroller
/// family emas — so'rov id si metodga uzatiladi.
class LogEditDetailController extends Notifier<LogEditDetailState> {
  @override
  LogEditDetailState build() => const LogEditDetailState();

  /// Yangi so'rov ochilganda holatni tozalaydi.
  void reset() => state = const LogEditDetailState();

  void setReason(String value) =>
      state = state.copyWith(reason: value, clearReasonIssue: true, clearError: true);

  void startReject() => state = state.copyWith(showReasonField: true, clearError: true);

  void cancelReject() =>
      state = state.copyWith(showReasonField: false, reason: '', clearReasonIssue: true);

  /// M133/M134 tekshiruvi kontrollerda emas — `blockOfRequest` domen funksiyasi.
  Future<void> approve(String id) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await ref.read(logEditsRepositoryProvider).approve(id);
      state = state.copyWith(submitting: false, done: true);
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, error: error);
    }
  }

  Future<void> reject(String id) async {
    final RejectReasonIssue? issue = validateRejectReason(state.reason);
    if (issue != null) {
      state = state.copyWith(reasonIssue: issue);
      return;
    }
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await ref.read(logEditsRepositoryProvider).reject(id: id, reason: state.reason.trim());
      state = state.copyWith(submitting: false, done: true);
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, error: error);
    }
  }
}

final NotifierProvider<LogEditDetailController, LogEditDetailState>
logEditDetailControllerProvider = NotifierProvider<LogEditDetailController, LogEditDetailState>(
  LogEditDetailController.new,
);
