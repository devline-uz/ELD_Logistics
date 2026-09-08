/// `M-40 Send via email` va `M-41 Send the file` kontrollerlari.
///
/// Ikkalasi ham **yozuv amali** — faqat onlayn (`swagger.json`: roadside token
/// bu endpointlarga kira olmaydi). Oflayn holatda tugma o'chadi va ekranda
/// `inspectionOnlineRequired` izohi ko'rsatiladi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../domain/inspection_models.dart';
import 'inspection_providers.dart';

/// `M-40` holati.
class InspectionEmailState {
  const InspectionEmailState({
    this.email = '',
    this.comment = '',
    this.sending = false,
    this.error,
    this.sent = false,
    this.showValidation = false,
  });

  final String email;
  final String comment;
  final bool sending;
  final ApiError? error;
  final bool sent;

  /// `Send Logs` bosilgandan keyin xato matni ko'rsatiladi.
  final bool showValidation;

  bool get isEmailValid => InspectionEmailRequest.isValidEmail(email);

  /// Tugma **o'chirilmaydi**: bosilganda validatsiya xabari ko'rsatiladi
  /// (o'chirilgan tugma sababini foydalanuvchiga tushuntirmaydi).
  bool get canSend => !sending;

  InspectionEmailState copyWith({
    String? email,
    String? comment,
    bool? sending,
    ApiError? error,
    bool clearError = false,
    bool? sent,
    bool? showValidation,
  }) => InspectionEmailState(
    email: email ?? this.email,
    comment: comment ?? this.comment,
    sending: sending ?? this.sending,
    error: clearError ? null : (error ?? this.error),
    sent: sent ?? this.sent,
    showValidation: showValidation ?? this.showValidation,
  );
}

class InspectionEmailController extends Notifier<InspectionEmailState> {
  @override
  InspectionEmailState build() => const InspectionEmailState();

  void setEmail(String value) =>
      state = state.copyWith(email: value, clearError: true, showValidation: false);

  void setComment(String value) => state = state.copyWith(comment: value);

  Future<bool> send() async {
    if (!state.isEmailValid) {
      state = state.copyWith(showValidation: true);
      return false;
    }
    if (state.sending) {
      return false;
    }
    state = state.copyWith(sending: true, clearError: true);
    try {
      await ref
          .read(inspectionRepositoryProvider)
          .sendEmail(
            InspectionEmailRequest(
              email: state.email,
              comment: state.comment.isEmpty ? null : state.comment,
            ),
          );
      state = state.copyWith(sending: false, sent: true);
      return true;
    } on ApiError catch (error) {
      state = state.copyWith(sending: false, error: error);
      return false;
    }
  }
}

final NotifierProvider<InspectionEmailController, InspectionEmailState>
inspectionEmailControllerProvider =
    NotifierProvider<InspectionEmailController, InspectionEmailState>(
      InspectionEmailController.new,
    );

/// `M-41` holati.
///
/// **M2 (kontrakt ustun):** `POST /inspection/transfer` tanasi `type`/`email`
/// maydonlarini qabul qilmaydi. Shu sababli `Email` tanlanganda ELD output
/// fayli o'rniga `POST /inspection/email` (7 kun + bugun PDF) yuboriladi.
/// Nomuvofiqlik §21 reestriga yozilishi kerak.
class InspectionTransferState {
  const InspectionTransferState({
    this.type = InspectionTransferType.webService,
    this.email = '',
    this.comment = '',
    this.sending = false,
    this.error,
    this.result,
    this.emailSent = false,
    this.showValidation = false,
  });

  final InspectionTransferType type;
  final String email;
  final String comment;
  final bool sending;
  final ApiError? error;

  /// `Web service` natijasi.
  final InspectionTransferResult? result;

  /// `Email` yo'li bilan yuborildi.
  final bool emailSent;

  final bool showValidation;

  bool get needsEmail => type == InspectionTransferType.email;

  bool get isEmailValid => InspectionEmailRequest.isValidEmail(email);

  /// [InspectionEmailState.canSend] bilan bir xil qoida.
  bool get canSend => !sending;

  bool get isDone => result != null || emailSent;

  InspectionTransferState copyWith({
    InspectionTransferType? type,
    String? email,
    String? comment,
    bool? sending,
    ApiError? error,
    bool clearError = false,
    InspectionTransferResult? result,
    bool? emailSent,
    bool? showValidation,
  }) => InspectionTransferState(
    type: type ?? this.type,
    email: email ?? this.email,
    comment: comment ?? this.comment,
    sending: sending ?? this.sending,
    error: clearError ? null : (error ?? this.error),
    result: result ?? this.result,
    emailSent: emailSent ?? this.emailSent,
    showValidation: showValidation ?? this.showValidation,
  );
}

class InspectionTransferController extends Notifier<InspectionTransferState> {
  @override
  InspectionTransferState build() => const InspectionTransferState();

  void setType(InspectionTransferType type) =>
      state = state.copyWith(type: type, clearError: true, showValidation: false);

  void setEmail(String value) =>
      state = state.copyWith(email: value, clearError: true, showValidation: false);

  void setComment(String value) => state = state.copyWith(comment: value);

  Future<bool> send() async {
    if (state.needsEmail && !state.isEmailValid) {
      state = state.copyWith(showValidation: true);
      return false;
    }
    if (state.sending) {
      return false;
    }
    state = state.copyWith(sending: true, clearError: true);
    final InspectionRepositoryFacade facade = InspectionRepositoryFacade(ref);
    try {
      if (state.needsEmail) {
        await facade.email(state.email, state.comment);
        state = state.copyWith(sending: false, emailSent: true);
      } else {
        final InspectionTransferResult result = await facade.transfer(state.comment);
        state = state.copyWith(sending: false, result: result);
      }
      return true;
    } on ApiError catch (error) {
      state = state.copyWith(sending: false, error: error);
      return false;
    }
  }
}

/// Repozitoriyga ikki xil chaqiruvni bir joyda ushlab turuvchi yupqa qobiq —
/// kontroller ichida `if` shoxlari qisqarsin.
class InspectionRepositoryFacade {
  const InspectionRepositoryFacade(this._ref);

  final Ref _ref;

  Future<void> email(String address, String comment) => _ref
      .read(inspectionRepositoryProvider)
      .sendEmail(InspectionEmailRequest(email: address, comment: comment.isEmpty ? null : comment));

  Future<InspectionTransferResult> transfer(String comment) =>
      _ref.read(inspectionRepositoryProvider).transfer(comment: comment.isEmpty ? null : comment);
}

final NotifierProvider<InspectionTransferController, InspectionTransferState>
inspectionTransferControllerProvider =
    NotifierProvider<InspectionTransferController, InspectionTransferState>(
      InspectionTransferController.new,
    );
