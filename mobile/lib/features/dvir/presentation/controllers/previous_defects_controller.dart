/// `M-36 Previous defects certification` kontrolleri (🎨, `tz.md` §7.2).
///
/// Pre-trip DVIR boshlanishida `GET /dvir-reports/pending-certification`
/// tekshiriladi; bo'sh bo'lmasa modal ko'rsatiladi va haydovchi imzosi bilan
/// `POST /dvir-reports/{id}/certify` yuboriladi. Oflayn — outbox, yangi DVIR
/// **bloklanmaydi**.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_code.dart';
import '../../domain/dvir_models.dart';
import '../../domain/dvir_repository.dart';
import 'dvir_providers.dart';

enum PreviousDefectsOutcome { none, certified, queued, alreadyCertified }

class PreviousDefectsState {
  const PreviousDefectsState({
    this.loading = true,
    this.reports = const <DvirReport>[],
    this.loadError,
    this.signaturePath,
    this.submitting = false,
    this.submitError,
    this.outcome = PreviousDefectsOutcome.none,
  });

  final bool loading;

  /// Sertifikatsiya kutayotgan hisobotlar (`repaired`).
  final List<DvirReport> reports;
  final ApiError? loadError;

  final String? signaturePath;
  final bool submitting;
  final ApiError? submitError;
  final PreviousDefectsOutcome outcome;

  /// Modal ko'rsatiladimi — faqat kutayotgan hisobot bo'lsa.
  bool get isVisible => !loading && reports.isNotEmpty;

  DvirReport? get current => reports.isEmpty ? null : reports.first;

  bool get canConfirm => signaturePath != null && !submitting;

  PreviousDefectsState copyWith({
    bool? loading,
    List<DvirReport>? reports,
    ApiError? loadError,
    bool clearLoadError = false,
    String? signaturePath,
    bool? submitting,
    ApiError? submitError,
    bool clearSubmitError = false,
    PreviousDefectsOutcome? outcome,
  }) => PreviousDefectsState(
    loading: loading ?? this.loading,
    reports: reports ?? this.reports,
    loadError: clearLoadError ? null : (loadError ?? this.loadError),
    signaturePath: signaturePath ?? this.signaturePath,
    submitting: submitting ?? this.submitting,
    submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    outcome: outcome ?? this.outcome,
  );
}

class PreviousDefectsController extends Notifier<PreviousDefectsState> {
  late final DvirRepository _repository = ref.read(dvirRepositoryProvider);

  @override
  PreviousDefectsState build() {
    Future<void>.microtask(load);
    return const PreviousDefectsState();
  }

  Future<void> load({String? unitId}) async {
    state = state.copyWith(loading: true, clearLoadError: true);
    try {
      final List<DvirReport> reports = await _repository.pendingCertification(unitId: unitId);
      state = state.copyWith(loading: false, reports: reports);
    } on ApiError catch (error) {
      // Oflayn/xato — modal ko'rsatilmaydi, yangi DVIR bloklanmaydi.
      state = state.copyWith(loading: false, loadError: error, reports: const <DvirReport>[]);
    }
  }

  void setSignaturePath(String path) => state = state.copyWith(signaturePath: path);

  /// Imzo PNG'ini `files_queue` ga qo'yadi (fayl mantiqi widgetda emas).
  Future<void> saveSignature(List<int> pngBytes) async {
    state = state.copyWith(submitting: true, clearSubmitError: true);
    try {
      final String path = await ref.read(dvirFileRepositoryProvider).enqueueSignature(pngBytes);
      state = state.copyWith(submitting: false, signaturePath: path);
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, submitError: error);
    }
  }

  Future<void> certify() async {
    final DvirReport? report = state.current;
    final String? signature = state.signaturePath;
    if (report == null || signature == null || state.submitting) {
      return;
    }
    state = state.copyWith(submitting: true, clearSubmitError: true);
    try {
      final DvirSubmitResult result = await _repository.certify(
        reportId: report.id,
        signatureKey: signature,
      );
      state = state.copyWith(
        submitting: false,
        reports: _without(report.id),
        signaturePath: null,
        outcome: result.queued ? PreviousDefectsOutcome.queued : PreviousDefectsOutcome.certified,
      );
    } on ApiError catch (error) {
      // `DVIR_INVALID_TRANSITION` — allaqachon sertifikatlangan, ro'yxat yangilanadi.
      if (error.code == ApiErrorCode.dvirInvalidTransition) {
        state = state.copyWith(
          submitting: false,
          reports: _without(report.id),
          outcome: PreviousDefectsOutcome.alreadyCertified,
        );
        return;
      }
      state = state.copyWith(submitting: false, submitError: error);
    }
  }

  List<DvirReport> _without(String id) => <DvirReport>[
    for (final DvirReport r in state.reports)
      if (r.id != id) r,
  ];
}

final NotifierProvider<PreviousDefectsController, PreviousDefectsState>
previousDefectsControllerProvider =
    NotifierProvider<PreviousDefectsController, PreviousDefectsState>(
      PreviousDefectsController.new,
    );
