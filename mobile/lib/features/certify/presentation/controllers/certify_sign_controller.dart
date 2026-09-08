/// `M-30 Sign` kontrolleri (M126: bir nechta kun — bitta imzo).
library;

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../domain/certify_models.dart';
import 'certify_providers.dart';

class CertifySignState {
  const CertifySignState({
    this.dates = const <DateTime>[],
    this.png,
    this.useSaved = false,
    this.savedSignatureId,
    this.remember = false,
    this.submitting = false,
    this.outcome,
    this.error,
  });

  /// Imzolanadigan kunlar (M126).
  final List<DateTime> dates;

  /// Chizilgan imzo PNG i.
  final Uint8List? png;

  /// `Use my signature` — saqlangan imzo ishlatiladi.
  final bool useSaved;

  final String? savedSignatureId;

  /// `Save my signature` checkbox'i.
  final bool remember;

  final bool submitting;
  final CertifyOutcome? outcome;
  final ApiError? error;

  bool get hasSavedSignature => savedSignatureId != null;

  bool get canConfirm =>
      !submitting && dates.isNotEmpty && (png != null || (useSaved && hasSavedSignature));

  CertifySignState copyWith({
    List<DateTime>? dates,
    Uint8List? png,
    bool clearPng = false,
    bool? useSaved,
    String? savedSignatureId,
    bool? remember,
    bool? submitting,
    CertifyOutcome? outcome,
    ApiError? error,
    bool clearError = false,
  }) => CertifySignState(
    dates: dates ?? this.dates,
    png: clearPng ? null : (png ?? this.png),
    useSaved: useSaved ?? this.useSaved,
    savedSignatureId: savedSignatureId ?? this.savedSignatureId,
    remember: remember ?? this.remember,
    submitting: submitting ?? this.submitting,
    outcome: outcome ?? this.outcome,
    error: clearError ? null : (error ?? this.error),
  );
}

class CertifySignController extends Notifier<CertifySignState> {
  @override
  CertifySignState build() {
    ref.listen<AsyncValue<String?>>(savedSignatureIdProvider, (
      AsyncValue<String?>? _,
      AsyncValue<String?> next,
    ) {
      final String? id = next.value;
      if (id != null) {
        state = state.copyWith(savedSignatureId: id);
      }
    }, fireImmediately: true);
    return const CertifySignState();
  }

  void setDates(List<DateTime> dates) {
    if (state.dates.length != dates.length ||
        !state.dates.every((DateTime d) => dates.contains(d))) {
      state = state.copyWith(dates: dates);
    }
  }

  void setSignature(Uint8List png) =>
      state = state.copyWith(png: png, useSaved: false, clearError: true);

  void clearSignature() => state = state.copyWith(clearPng: true, clearError: true);

  void toggleUseSaved() => state = state.copyWith(
    useSaved: !state.useSaved,
    clearPng: !state.useSaved,
    clearError: true,
  );

  void toggleRemember() => state = state.copyWith(remember: !state.remember);

  /// M126/M128: bitta imzo — har kun uchun alohida outbox yozuvi.
  Future<CertifyOutcome?> confirm() async {
    if (!state.canConfirm) {
      return null;
    }
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final SignatureInput signature = state.useSaved && state.savedSignatureId != null
          ? SignatureInput.saved(state.savedSignatureId!)
          : SignatureInput.drawn(state.png!, save: state.remember);
      final CertifyOutcome outcome = await ref
          .read(certifyRepositoryProvider)
          .certify(dates: state.dates, signature: signature);
      state = state.copyWith(submitting: false, outcome: outcome);
      return outcome;
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, error: error);
      return null;
    }
  }
}

final NotifierProvider<CertifySignController, CertifySignState> certifySignControllerProvider =
    NotifierProvider<CertifySignController, CertifySignState>(CertifySignController.new);
