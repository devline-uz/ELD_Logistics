/// `M-32 → M-33 → M-34` yagona kontrolleri.
///
/// **M7:** telefon va planshet (T-30) **ayni shu kontrollerni** ulashadi —
/// faqat `View` boshqa. Biznes qoidalari (kritik nuqson ogohlantirishi,
/// `Next`/`Confirm` shartlari, oflayn navbat) shu yerda, widget ichida emas.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/api_error.dart';
import '../../domain/dvir_models.dart';
import '../../domain/dvir_repository.dart';
import 'dvir_providers.dart';

/// Yuborish natijasi — `M-34` xabari shundan tanlanadi.
enum DvirSubmitOutcome { none, sent, queued }

class DvirFormState {
  const DvirFormState({
    required this.draft,
    this.context,
    this.loading = false,
    this.loadError,
    this.submitting = false,
    this.submitError,
    this.outcome = DvirSubmitOutcome.none,
    this.trailerNumbers = const <String, String>{},
  });

  /// Boshlang'ich (yuklanish) holati.
  factory DvirFormState.loading(String clientId) => DvirFormState(
    draft: DvirDraft(clientId: clientId, unitId: '', type: DvirType.preTrip),
    loading: true,
  );

  final DvirDraft draft;
  final DvirContext? context;

  /// `Driver Information` bloki yuklanmoqda.
  final bool loading;

  /// Kontekst yuklanmadi — `ErrorState` + `Retry`.
  final ApiError? loadError;

  final bool submitting;
  final ApiError? submitError;
  final DvirSubmitOutcome outcome;

  /// Tanlangan trailer `id → number` (UI ko'rsatishi uchun; domenda faqat id).
  final Map<String, String> trailerNumbers;

  /// Ko'rsatish uchun trailer raqamlari ro'yxati.
  List<String> get trailerLabels => <String>[
    for (final String id in draft.trailerIds) trailerNumbers[id] ?? id,
  ];

  /// M-32 `Next`: unit aniqlangan bo'lishi shart (ELD/GPS yoki `/me` dan).
  bool get canProceed => !loading && draft.unitId.isNotEmpty;

  /// M-34 `Confirm`: imzo majburiy (`SignaturePad`).
  bool get canConfirm => draft.isSignable && !submitting;

  /// M106: tanlanganlar orasida `is_critical=true` bor.
  bool get showCriticalWarning => draft.hasCriticalDefect;

  DvirFormState copyWith({
    DvirDraft? draft,
    DvirContext? context,
    bool? loading,
    ApiError? loadError,
    bool clearLoadError = false,
    bool? submitting,
    ApiError? submitError,
    bool clearSubmitError = false,
    DvirSubmitOutcome? outcome,
    Map<String, String>? trailerNumbers,
  }) => DvirFormState(
    draft: draft ?? this.draft,
    context: context ?? this.context,
    loading: loading ?? this.loading,
    loadError: clearLoadError ? null : (loadError ?? this.loadError),
    submitting: submitting ?? this.submitting,
    submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    outcome: outcome ?? this.outcome,
    trailerNumbers: trailerNumbers ?? this.trailerNumbers,
  );
}

class DvirFormController extends Notifier<DvirFormState> {
  /// Test uchun almashtiriladigan `client_id` generatori (M19).
  static String Function() idFactory = const Uuid().v4;

  late final DvirRepository _repository = ref.read(dvirRepositoryProvider);

  @override
  DvirFormState build() {
    final DvirFormState initial = DvirFormState.loading(idFactory());
    Future<void>.microtask(load);
    return initial;
  }

  /// `Driver Information` (Time / Location / Odometer) + Unit Number.
  Future<void> load() async {
    state = state.copyWith(loading: true, clearLoadError: true);
    try {
      final DvirContext context = await _repository.currentContext();
      state = state.copyWith(
        loading: false,
        context: context,
        draft: state.draft.copyWith(unitId: context.unitId, unitNumber: context.unitNumber),
      );
    } on ApiError catch (error) {
      state = state.copyWith(loading: false, loadError: error);
    }
  }

  void setType(DvirType type) => state = state.copyWith(draft: state.draft.copyWith(type: type));

  void setNotes(String? notes) => state = state.copyWith(draft: state.draft.copyWith(notes: notes));

  /// Trailer chipini almashtirish (ko'p tanlovli).
  void toggleTrailer(String trailerId, {String? number}) {
    final List<String> next = <String>[...state.draft.trailerIds];
    if (!next.remove(trailerId)) {
      next.add(trailerId);
    }
    state = state.copyWith(
      draft: state.draft.copyWith(trailerIds: next),
      trailerNumbers: <String, String>{...state.trailerNumbers, trailerId: ?number},
    );
  }

  /// `M-33` natijasi: bitta kategoriya nuqsonlari to'liq almashtiriladi.
  void applyDefects(DefectCategory category, List<DvirDefect> defects) {
    state = state.copyWith(
      draft: category == DefectCategory.truck
          ? state.draft.copyWith(truckDefects: defects)
          : state.draft.copyWith(trailerDefects: defects),
    );
  }

  /// M105: `Accident Photo` — nuqson emas, alohida bo'lim.
  void setAccidentPhotos(List<String> paths) =>
      state = state.copyWith(draft: state.draft.copyWith(accidentPhotoPaths: paths));

  /// `SignaturePad` saqlagan lokal PNG yo'li.
  void setSignaturePath(String path) =>
      state = state.copyWith(draft: state.draft.copyWith(signaturePath: path));

  /// `M-34`: imzo PNG'ini `files_queue` ga qo'yadi va qoralamaga bog'laydi.
  ///
  /// Fayl mantiqi widget ichida emas — shu yerda (M5).
  Future<void> saveSignature(List<int> pngBytes) async {
    state = state.copyWith(submitting: true, clearSubmitError: true);
    try {
      final String path = await ref.read(dvirFileRepositoryProvider).enqueueSignature(pngBytes);
      state = state.copyWith(submitting: false, draft: state.draft.copyWith(signaturePath: path));
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, submitError: error);
    }
  }

  /// Yuborilgandan keyin oqim yopiladi — keyingi `M-32` toza qoralama bilan
  /// ochiladi (`clientId` yangi, M19 idempotentligi buzilmaydi).
  void reset() {
    state = DvirFormState.loading(idFactory());
    Future<void>.microtask(load);
  }

  /// `POST /dvir-reports`; oflayn bo'lsa outbox (`queued`).
  Future<void> submit() async {
    if (!state.canConfirm) {
      return;
    }
    state = state.copyWith(submitting: true, clearSubmitError: true);
    try {
      final DvirSubmitResult result = await _repository.submit(state.draft);
      state = state.copyWith(
        submitting: false,
        outcome: result.queued ? DvirSubmitOutcome.queued : DvirSubmitOutcome.sent,
      );
    } on ApiError catch (error) {
      state = state.copyWith(submitting: false, submitError: error);
    }
  }
}

final NotifierProvider<DvirFormController, DvirFormState> dvirFormControllerProvider =
    NotifierProvider<DvirFormController, DvirFormState>(DvirFormController.new);
