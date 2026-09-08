/// `M-08 Two-factor (TOTP)` kontrolleri (§4.1, §11.2).
///
/// Ikki qadam: `setup` (`POST /auth/2fa/setup` → secret) va `verify`
/// (`POST /auth/2fa/verify` → recovery kodlar + tokenlar).
/// Secret va recovery kodlar **logga chiqmaydi** (M159).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/router/auth_state.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_models.dart';
import '../../domain/auth_policies.dart';
import 'form_status.dart';

/// Ekranning qaysi qadamda turgani.
enum TotpStep {
  /// Setup so'rovi ketmoqda / secret olinmoqda.
  loading,

  /// Secret ko'rsatilgan, kod kutilmoqda.
  setup,

  /// Faqat kod so'raladi (2FA allaqachon yoqilgan).
  verify,

  /// Yoqildi — recovery kodlar ko'rsatiladi.
  enabled,

  /// Bu hisob uchun 2FA talab qilinmaydi («bo'sh» holat).
  notRequired,
}

class TotpState {
  const TotpState({
    this.step = TotpStep.loading,
    this.code = '',
    this.setup,
    this.recoveryCodes = const <String>[],
    this.status = const FormStatus(),
    this.loadErrorCode,
  });

  final TotpStep step;
  final String code;

  /// `null` — `verify` qadami (secret ko'rsatilmaydi).
  final TotpSetup? setup;

  final List<String> recoveryCodes;
  final FormStatus status;

  /// Setup so'rovi yiqilgan bo'lsa — `ErrorState` uchun.
  final String? loadErrorCode;

  bool get canSubmit => !status.isSubmitting && TotpCodePolicy.isValid(code);

  TotpState copyWith({
    TotpStep? step,
    String? code,
    TotpSetup? setup,
    List<String>? recoveryCodes,
    FormStatus? status,
    String? loadErrorCode,
    bool clearLoadError = false,
  }) => TotpState(
    step: step ?? this.step,
    code: code ?? this.code,
    setup: setup ?? this.setup,
    recoveryCodes: recoveryCodes ?? this.recoveryCodes,
    status: status ?? this.status,
    loadErrorCode: clearLoadError ? null : (loadErrorCode ?? this.loadErrorCode),
  );
}

class TotpController extends Notifier<TotpState> {
  @override
  TotpState build() => const TotpState();

  /// Ekran ochilishida chaqiriladi. [alreadyEnabled] — `Profile.totp_enabled`.
  Future<void> start({required bool required, required bool alreadyEnabled}) async {
    if (!required && !alreadyEnabled) {
      state = const TotpState(step: TotpStep.notRequired);
      return;
    }
    if (alreadyEnabled) {
      state = const TotpState(step: TotpStep.verify);
      return;
    }
    state = const TotpState();
    try {
      final TotpSetup setup = await ref.read(authRepositoryProvider).startTotpSetup();
      state = state.copyWith(step: TotpStep.setup, setup: setup, clearLoadError: true);
    } on ApiError catch (error) {
      state = state.copyWith(step: TotpStep.setup, loadErrorCode: error.code);
    }
  }

  void setCode(String value) => state = state.copyWith(code: value, status: const FormStatus());

  Future<void> submit() async {
    if (!state.canSubmit) {
      return;
    }
    state = state.copyWith(status: const FormStatus.submitting());
    try {
      final TotpVerification result = await ref
          .read(authRepositoryProvider)
          .verifyTotp(code: state.code);
      state = state.copyWith(
        code: '',
        step: result.enabled ? TotpStep.enabled : state.step,
        recoveryCodes: result.recoveryCodes,
        status: const FormStatus.success(),
      );
      if (result.enabled) {
        ref.read(authStatusProvider.notifier).set(AuthStatus.authenticated);
      }
    } on ApiError catch (error) {
      state = state.copyWith(code: '', status: FormStatus.failure(error));
    }
  }
}

final NotifierProvider<TotpController, TotpState> totpControllerProvider =
    NotifierProvider<TotpController, TotpState>(TotpController.new);
