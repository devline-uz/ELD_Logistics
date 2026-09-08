/// `M-48 Give feedback` domeni (tz-mobile §11.8).
///
/// Validatsiya qoidasi **shu yerda** — widget yoki provayder ichida emas.
library;

import 'package:meta/meta.dart';

/// Formadagi xato sabablari.
enum FeedbackValidationError {
  /// Baho tanlanmagan (1–5 majburiy).
  ratingRequired,
}

@immutable
class FeedbackDraft {
  const FeedbackDraft({this.rating, this.text = ''});

  /// 1…5 yulduz. `null` — hali tanlanmagan.
  final int? rating;

  /// «What new features…» javobi; ixtiyoriy.
  final String text;

  static const int minRating = 1;
  static const int maxRating = 5;

  FeedbackDraft copyWith({int? rating, String? text}) =>
      FeedbackDraft(rating: rating ?? this.rating, text: text ?? this.text);

  List<FeedbackValidationError> validate() => <FeedbackValidationError>[
    if (rating == null || rating! < minRating || rating! > maxRating)
      FeedbackValidationError.ratingRequired,
  ];

  bool get isValid => validate().isEmpty;

  /// `POST /feedback` tanasi (`FeedbackCreate`).
  Map<String, Object?> toPayload() => <String, Object?>{'app_rating': rating, 'text': text.trim()};

  @override
  bool operator ==(Object other) =>
      other is FeedbackDraft && other.rating == rating && other.text == text;

  @override
  int get hashCode => Object.hash(rating, text);
}
