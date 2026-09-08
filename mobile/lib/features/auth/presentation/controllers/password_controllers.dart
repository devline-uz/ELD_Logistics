/// `M-06 Forgot password` va `M-07 Reset password` kontrollerlari (§4.1).
///
/// Qoidalar `domain/auth_policies.dart` da; bu yerda faqat holat va chaqiruv.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_policies.dart';
import 'form_status.dart';

// --------------------------------------------------------------- M-06

class ForgotPasswordState {
  const ForgotPasswordState({
    this.login = '',
    this.showFieldErrors = false,
    this.status = const FormStatus(),
  });

  final String login;
  final bool showFieldErrors;
  final FormStatus status;

  bool get canSubmit => !status.isSubmitting && ForgotPasswordFormPolicy.canSubmit(login);

  LoginFieldIssue? get loginIssue =>
      showFieldErrors ? LoginFormPolicy.validateUsername(login) : null;

  ForgotPasswordState copyWith({String? login, bool? showFieldErrors, FormStatus? status}) =>
      ForgotPasswordState(
        login: login ?? this.login,
        showFieldErrors: showFieldErrors ?? this.showFieldErrors,
        status: status ?? this.status,
      );
}

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  void setLogin(String value) => state = state.copyWith(login: value, status: const FormStatus());

  Future<void> submit() async {
    if (!ForgotPasswordFormPolicy.canSubmit(state.login)) {
      state = state.copyWith(showFieldErrors: true);
      return;
    }
    state = state.copyWith(showFieldErrors: true, status: const FormStatus.submitting());
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(login: ForgotPasswordFormPolicy.normalize(state.login));
      state = state.copyWith(status: const FormStatus.success());
    } on ApiError catch (error) {
      state = state.copyWith(status: FormStatus.failure(error));
    }
  }
}

final NotifierProvider<ForgotPasswordController, ForgotPasswordState>
forgotPasswordControllerProvider = NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
  ForgotPasswordController.new,
);

// --------------------------------------------------------------- M-07

class ResetPasswordState {
  const ResetPasswordState({
    this.token = '',
    this.password = '',
    this.passwordConfirm = '',
    this.obscure = true,
    this.showFieldErrors = false,
    this.status = const FormStatus(),
  });

  /// Deep link'dan kelgan token (`onebookeld://reset?token=…`, M162).
  final String token;

  final String password;
  final String passwordConfirm;
  final bool obscure;
  final bool showFieldErrors;
  final FormStatus status;

  /// «Bo'sh» holat — token yo'q, forma ko'rsatilmaydi.
  bool get tokenMissing => token.isEmpty;

  PasswordStrength get strength => PasswordPolicy.strength(password);

  PasswordPairIssue? get pairIssue => showFieldErrors
      ? PasswordPairPolicy.validate(password: password, confirm: passwordConfirm)
      : null;

  bool get canSubmit =>
      !status.isSubmitting &&
      ResetPasswordFormPolicy.canSubmit(
        token: token,
        password: password,
        passwordConfirm: passwordConfirm,
      );

  ResetPasswordState copyWith({
    String? token,
    String? password,
    String? passwordConfirm,
    bool? obscure,
    bool? showFieldErrors,
    FormStatus? status,
  }) => ResetPasswordState(
    token: token ?? this.token,
    password: password ?? this.password,
    passwordConfirm: passwordConfirm ?? this.passwordConfirm,
    obscure: obscure ?? this.obscure,
    showFieldErrors: showFieldErrors ?? this.showFieldErrors,
    status: status ?? this.status,
  );
}

class ResetPasswordController extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  void setToken(String value) {
    if (state.token != value) {
      state = state.copyWith(token: value);
    }
  }

  void setPassword(String value) =>
      state = state.copyWith(password: value, status: const FormStatus());

  void setPasswordConfirm(String value) =>
      state = state.copyWith(passwordConfirm: value, status: const FormStatus());

  void toggleObscure() => state = state.copyWith(obscure: !state.obscure);

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(showFieldErrors: true);
      return;
    }
    state = state.copyWith(showFieldErrors: true, status: const FormStatus.submitting());
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(token: state.token, password: state.password);
      state = state.copyWith(password: '', passwordConfirm: '', status: const FormStatus.success());
    } on ApiError catch (error) {
      state = state.copyWith(status: FormStatus.failure(error));
    }
  }
}

final NotifierProvider<ResetPasswordController, ResetPasswordState>
resetPasswordControllerProvider = NotifierProvider<ResetPasswordController, ResetPasswordState>(
  ResetPasswordController.new,
);
