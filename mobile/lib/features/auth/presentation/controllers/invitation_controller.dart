/// `M-05 Accept invitation` kontrolleri (§4.1, `POST /auth/invitation/accept`).
///
/// PIN ochiq matnda faqat holatda turadi va yuborilgandan keyin **darhol**
/// tozalanadi (M159); lokal hash `AuthRepository` ichida yoziladi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_policies.dart';
import 'form_status.dart';

class InvitationState {
  const InvitationState({
    this.token = '',
    this.password = '',
    this.passwordConfirm = '',
    this.pin = '',
    this.pinConfirm = '',
    this.consentGiven = false,
    this.obscure = true,
    this.showFieldErrors = false,
    this.status = const FormStatus(),
  });

  /// Deep link tokeni (`onebookeld://invite?token=…`, M162).
  final String token;

  final String password;
  final String passwordConfirm;
  final String pin;
  final String pinConfirm;
  final bool consentGiven;
  final bool obscure;
  final bool showFieldErrors;
  final FormStatus status;

  /// «Bo'sh» holat — token yo'q.
  bool get tokenMissing => token.isEmpty;

  PasswordStrength get strength => PasswordPolicy.strength(password);

  PasswordPairIssue? get passwordIssue => showFieldErrors
      ? PasswordPairPolicy.validate(password: password, confirm: passwordConfirm)
      : null;

  PinPairIssue? get pinIssue =>
      showFieldErrors ? PinPairPolicy.validate(pin: pin, confirm: pinConfirm) : null;

  PinFormatIssue? get pinFormatIssue =>
      showFieldErrors && pin.isNotEmpty ? PinPolicy.validate(pin) : null;

  bool get canSubmit =>
      !status.isSubmitting &&
      InvitationFormPolicy.canSubmit(
        token: token,
        password: password,
        passwordConfirm: passwordConfirm,
        pin: pin,
        pinConfirm: pinConfirm,
        consentGiven: consentGiven,
      );

  InvitationState copyWith({
    String? token,
    String? password,
    String? passwordConfirm,
    String? pin,
    String? pinConfirm,
    bool? consentGiven,
    bool? obscure,
    bool? showFieldErrors,
    FormStatus? status,
  }) => InvitationState(
    token: token ?? this.token,
    password: password ?? this.password,
    passwordConfirm: passwordConfirm ?? this.passwordConfirm,
    pin: pin ?? this.pin,
    pinConfirm: pinConfirm ?? this.pinConfirm,
    consentGiven: consentGiven ?? this.consentGiven,
    obscure: obscure ?? this.obscure,
    showFieldErrors: showFieldErrors ?? this.showFieldErrors,
    status: status ?? this.status,
  );
}

class InvitationController extends Notifier<InvitationState> {
  @override
  InvitationState build() => const InvitationState();

  void setToken(String value) {
    if (state.token != value) {
      state = state.copyWith(token: value);
    }
  }

  void setPassword(String value) =>
      state = state.copyWith(password: value, status: const FormStatus());

  void setPasswordConfirm(String value) =>
      state = state.copyWith(passwordConfirm: value, status: const FormStatus());

  void setPin(String value) => state = state.copyWith(pin: value, status: const FormStatus());

  void setPinConfirm(String value) =>
      state = state.copyWith(pinConfirm: value, status: const FormStatus());

  void toggleObscure() => state = state.copyWith(obscure: !state.obscure);

  void setConsent(bool value) => state = state.copyWith(consentGiven: value);

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(showFieldErrors: true);
      return;
    }
    state = state.copyWith(showFieldErrors: true, status: const FormStatus.submitting());
    try {
      await ref
          .read(authRepositoryProvider)
          .acceptInvitation(token: state.token, password: state.password, pin: state.pin);
      // Sirlar holatdan darhol o'chiriladi (M159).
      state = state.copyWith(
        password: '',
        passwordConfirm: '',
        pin: '',
        pinConfirm: '',
        status: const FormStatus.success(),
      );
    } on ApiError catch (error) {
      state = state.copyWith(status: FormStatus.failure(error));
    }
  }
}

final NotifierProvider<InvitationController, InvitationState> invitationControllerProvider =
    NotifierProvider<InvitationController, InvitationState>(InvitationController.new);
