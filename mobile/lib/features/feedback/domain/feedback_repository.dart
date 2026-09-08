/// `M-48` domen shartnomasi.
library;

import '../../profile/domain/submit_outcome.dart';
import 'feedback_draft.dart';

abstract interface class FeedbackRepository {
  /// `POST /feedback`. Oflayn bo'lsa outbox'ga qo'yadi va
  /// [SubmitOutcome.queued] qaytaradi.
  Future<SubmitOutcome> submit(FeedbackDraft draft);
}
