/// `M-49`…`M-51` kontrollerlari — telefon va planshet ulashadi (M7).
///
/// Biznes qoidasi domenda (`TicketDraft.validate`), bu yerda faqat holat.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../../core/error/api_error.dart';
import '../../../profile/domain/submit_outcome.dart';
import '../../data/support_repository_impl.dart';
import '../../domain/support_repository.dart';
import '../../domain/support_ticket.dart';
import '../../domain/ticket_draft.dart';

/// `M-50` — tiketlar ro'yxati.
class SupportListController extends AsyncNotifier<List<SupportTicket>> {
  @override
  Future<List<SupportTicket>> build() => ref.watch(supportRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncValue<List<SupportTicket>>.loading();
    state = await AsyncValue.guard<List<SupportTicket>>(
      () => ref.read(supportRepositoryProvider).list(),
    );
  }
}

final AsyncNotifierProvider<SupportListController, List<SupportTicket>>
supportListControllerProvider = AsyncNotifierProvider<SupportListController, List<SupportTicket>>(
  SupportListController.new,
);

/// `M-51` — bitta tiket va uning xabarlari.
///
/// Riverpod 3 da oila (`family`) argumenti notifier konstruktoriga uzatiladi —
/// `FamilyAsyncNotifier` olib tashlangan.
class TicketThreadController extends AsyncNotifier<TicketThread> {
  TicketThreadController(this.ticketId);

  /// Oila argumenti — tiket identifikatori.
  final String ticketId;

  @override
  Future<TicketThread> build() => ref.watch(supportRepositoryProvider).thread(ticketId);

  Future<void> refresh() async {
    state = const AsyncValue<TicketThread>.loading();
    state = await AsyncValue.guard<TicketThread>(
      () => ref.read(supportRepositoryProvider).thread(ticketId),
    );
  }

  /// Javob yuborish; muvaffaqiyatda thread qayta yuklanadi.
  Future<SubmitOutcome> reply(String text) async {
    final SupportRepository repo = ref.read(supportRepositoryProvider);
    final SubmitOutcome outcome = await repo.reply(ticketId: ticketId, text: text);
    if (outcome == SubmitOutcome.sent) {
      await refresh();
    }
    return outcome;
  }
}

final AsyncNotifierProviderFamily<TicketThreadController, TicketThread, String>
ticketThreadControllerProvider =
    AsyncNotifierProvider.family<TicketThreadController, TicketThread, String>(
      TicketThreadController.new,
    );

/// `M-49` — yangi tiket formasi.
@immutable
class TicketFormState {
  const TicketFormState({
    this.draft = const TicketDraft(),
    this.submitting = false,
    this.showErrors = false,
    this.outcome,
    this.error,
  });

  final TicketDraft draft;
  final bool submitting;
  final bool showErrors;
  final SubmitOutcome? outcome;
  final ApiError? error;

  List<TicketValidationError> get errors => draft.validate();

  TicketFormState copyWith({
    TicketDraft? draft,
    bool? submitting,
    bool? showErrors,
    SubmitOutcome? outcome,
    ApiError? error,
    bool clearOutcome = false,
    bool clearError = false,
  }) => TicketFormState(
    draft: draft ?? this.draft,
    submitting: submitting ?? this.submitting,
    showErrors: showErrors ?? this.showErrors,
    outcome: clearOutcome ? null : (outcome ?? this.outcome),
    error: clearError ? null : (error ?? this.error),
  );
}

class TicketFormController extends Notifier<TicketFormState> {
  @override
  TicketFormState build() => const TicketFormState();

  void setChannel(ContactChannel channel) =>
      state = state.copyWith(draft: state.draft.copyWith(contactOn: channel));

  void setSubject(String value) =>
      state = state.copyWith(draft: state.draft.copyWith(subject: value), clearError: true);

  void setDescription(String value) =>
      state = state.copyWith(draft: state.draft.copyWith(description: value), clearError: true);

  Future<void> submit() async {
    if (state.submitting) {
      return;
    }
    if (!state.draft.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(submitting: true, clearError: true, clearOutcome: true);
    try {
      final SubmitOutcome outcome = await ref.read(supportRepositoryProvider).create(state.draft);
      state = state.copyWith(submitting: false, outcome: outcome);
      if (outcome == SubmitOutcome.sent) {
        await ref.read(supportListControllerProvider.notifier).refresh();
      }
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, error: error);
    }
  }
}

final NotifierProvider<TicketFormController, TicketFormState> ticketFormControllerProvider =
    NotifierProvider<TicketFormController, TicketFormState>(TicketFormController.new);

/// Holat → lokalizatsiya kaliti tanlash uchun yordamchi (M115).
extension TicketStatusX on TicketStatus {
  bool get isOpen => this == TicketStatus.newly || this == TicketStatus.inProgress;
}
