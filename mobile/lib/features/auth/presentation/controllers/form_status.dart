/// Auth formalarining umumiy holat mashinasi.
///
/// Har ekran **4 holat** ko'rsatadi (C.3 DoD):
/// `idle` (bo'sh/to'la forma) · `submitting` (yuklanish) · `failure` (xato) ·
/// `success` (natija). Xato matni bu yerda emas — faqat `ApiError` kodi
/// saqlanadi, tarjimasi `core/error/api_error_messages.dart` da (M159: backend
/// matni foydalanuvchiga ko'rsatilmaydi).
library;

import '../../../../core/error/api_error.dart';

enum FormPhase { idle, submitting, success, failure }

class FormStatus {
  const FormStatus({this.phase = FormPhase.idle, this.errorCode, this.retryAfter});

  const FormStatus.submitting() : this(phase: FormPhase.submitting);

  const FormStatus.success() : this(phase: FormPhase.success);

  FormStatus.failure(ApiError error)
    : this(phase: FormPhase.failure, errorCode: error.code, retryAfter: error.retryAfter);

  final FormPhase phase;

  /// `ApiErrorCode` dan biri; `null` — xato yo'q.
  final String? errorCode;

  /// `RATE_LIMITED` / `PIN_LOCKED` uchun kutish muddati.
  final Duration? retryAfter;

  bool get isSubmitting => phase == FormPhase.submitting;

  bool get isSuccess => phase == FormPhase.success;

  bool get isFailure => phase == FormPhase.failure;
}
