/// `M-48` kontrolleri — telefon va planshet uchun **yagona** (M7).
///
/// Biznes qoidasi (`rating` majburiy) `FeedbackDraft.validate()` da; bu yerda
/// faqat holat va repozitoriy chaqiruvi.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../profile/domain/submit_outcome.dart';
import '../../data/feedback_repository_impl.dart';
import '../../domain/feedback_draft.dart';
import '../../domain/feedback_repository.dart';

@immutable
class FeedbackFormState {
  const FeedbackFormState({
    this.draft = const FeedbackDraft(),
    this.submitting = false,
    this.showErrors = false,
    this.outcome,
    this.error,
  });

  final FeedbackDraft draft;
  final bool submitting;

  /// `Submit` bosilgandan keyingina validatsiya xatolari ko'rsatiladi.
  final bool showErrors;

  /// Muvaffaqiyatli yakun (`sent` / `queued`).
  final SubmitOutcome? outcome;

  final ApiError? error;

  List<FeedbackValidationError> get errors => draft.validate();

  FeedbackFormState copyWith({
    FeedbackDraft? draft,
    bool? submitting,
    bool? showErrors,
    SubmitOutcome? outcome,
    ApiError? error,
    bool clearOutcome = false,
    bool clearError = false,
  }) => FeedbackFormState(
    draft: draft ?? this.draft,
    submitting: submitting ?? this.submitting,
    showErrors: showErrors ?? this.showErrors,
    outcome: clearOutcome ? null : (outcome ?? this.outcome),
    error: clearError ? null : (error ?? this.error),
  );
}

class FeedbackController extends Notifier<FeedbackFormState> {
  @override
  FeedbackFormState build() => const FeedbackFormState();

  void setRating(int rating) =>
      state = state.copyWith(draft: state.draft.copyWith(rating: rating), clearError: true);

  void setText(String text) =>
      state = state.copyWith(draft: state.draft.copyWith(text: text), clearError: true);

  Future<void> submit() async {
    if (state.submitting) {
      return;
    }
    if (!state.draft.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(submitting: true, clearError: true, clearOutcome: true);
    final FeedbackRepository repo = ref.read(feedbackRepositoryProvider);
    try {
      final SubmitOutcome outcome = await repo.submit(state.draft);
      state = state.copyWith(submitting: false, outcome: outcome);
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, error: error);
    }
  }
}

final NotifierProvider<FeedbackController, FeedbackFormState> feedbackControllerProvider =
    NotifierProvider<FeedbackController, FeedbackFormState>(FeedbackController.new);
