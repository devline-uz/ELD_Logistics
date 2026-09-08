/// `M-12 Change duty status` yagona kontrolleri (M7: telefon + `T-04`).
///
/// Biznes qoidalari `domain/duty_status_rules.dart` da (sof funksiyalar);
/// bu sinf faqat holatni yig'adi va repozitoriyni chaqiradi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/location/location_models.dart';
import '../../../../core/location/location_providers.dart';
import '../../data/duty_status_providers.dart';
import '../../domain/duty_status_models.dart';
import '../../domain/duty_status_repository.dart';
import '../../domain/duty_status_rules.dart';

/// Saqlash natijasi — snackbar matni shundan tanlanadi.
enum DutySubmitOutcome { none, saved, queuedOffline }

class DutyFormState {
  const DutyFormState({
    required this.draft,
    required this.context,
    this.loading = true,
    this.saving = false,
    this.error,
    this.issues = const <DutyIssue>[],
    this.outcome = DutySubmitOutcome.none,
    this.locationBusy = false,
    this.locationError = false,
    this.notesTruncated = false,
    this.eldConnected = false,
  });

  final DutyStatusDraft draft;
  final DutyStatusContext context;

  final bool loading;
  final bool saving;

  /// Server/lokal xatosi (`ErrorState` yoki inline xabar).
  final ApiError? error;

  /// Domen validatsiyasi natijasi.
  final List<DutyIssue> issues;

  final DutySubmitOutcome outcome;

  /// `Update Now` bosilgan — GPS so'ralmoqda.
  final bool locationBusy;

  /// GPS fiksatsiyasi olinmadi (M-14 xatosi).
  final bool locationError;

  /// Oxirgi quick note qo'shilishida matn kesildi (M55).
  final bool notesTruncated;

  /// **M66:** ELD ulanmagan bo'lsa sariq banner ko'rsatiladi.
  final bool eldConnected;

  /// `M-14` dialogi kerakmi (aniqlik > 150 m).
  bool get locationInaccurate => locationNeedsConfirmation(draft.accuracyM);

  /// Tanlangan status uchun mavjud PC/YM (M64: yo'q bo'lsa yashiriladi).
  DutySpecial? get availableSpecial => availableSpecialFor(draft.status, context.policy);

  bool get canSave => !saving && !loading && issues.isEmpty;

  DutyFormState copyWith({
    DutyStatusDraft? draft,
    DutyStatusContext? context,
    bool? loading,
    bool? saving,
    ApiError? error,
    bool clearError = false,
    List<DutyIssue>? issues,
    DutySubmitOutcome? outcome,
    bool? locationBusy,
    bool? locationError,
    bool? notesTruncated,
    bool? eldConnected,
  }) => DutyFormState(
    draft: draft ?? this.draft,
    context: context ?? this.context,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    error: clearError ? null : (error ?? this.error),
    issues: issues ?? this.issues,
    outcome: outcome ?? this.outcome,
    locationBusy: locationBusy ?? this.locationBusy,
    locationError: locationError ?? this.locationError,
    notesTruncated: notesTruncated ?? this.notesTruncated,
    eldConnected: eldConnected ?? this.eldConnected,
  );
}

class DutyStatusController extends Notifier<DutyFormState> {
  late final DutyStatusRepository _repository = ref.read(dutyStatusRepositoryProvider);
  late final DutyCatalogRepository _catalog = ref.read(dutyCatalogRepositoryProvider);

  @override
  DutyFormState build() {
    final DutyStatusContext context =
        ref.watch(dutyStatusContextProvider).value ?? DutyStatusContext.empty();
    final bool loading = ref.watch(dutyStatusContextProvider).isLoading;
    final bool eldConnected = ref.watch(eldConnectedProvider);

    final DutyStatusDraft draft = _draft ?? context.toDraft();
    return _evaluate(
      DutyFormState(draft: draft, context: context, loading: loading, eldConnected: eldConnected),
    );
  }

  /// Foydalanuvchi kiritgan qoralama (kontekst yangilanganda yo'qolmaydi).
  DutyStatusDraft? _draft;

  DutyFormState _evaluate(DutyFormState next) => next.copyWith(
    issues: validateDutyDraft(draft: next.draft, context: next.context),
  );

  void _update(DutyStatusDraft draft, {bool? notesTruncated}) {
    _draft = draft;
    state = _evaluate(
      state.copyWith(
        draft: draft,
        clearError: true,
        outcome: DutySubmitOutcome.none,
        notesTruncated: notesTruncated ?? false,
      ),
    );
  }

  /// Status tugmasi (M51: `DR` tugmasi umuman yo'q).
  void selectStatus(DutyStatusValue status) {
    if (!status.isSelectable) {
      return;
    }
    _update(
      state.draft.copyWith(status: status, special: normalizeSpecial(status, state.draft.special)),
    );
  }

  /// PC/YM toggle (tz-mobile §9.8).
  void toggleSpecial({required bool enabled}) {
    final DutySpecial? available = availableSpecialFor(state.draft.status, state.context.policy);
    if (available == null) {
      return;
    }
    _update(state.draft.copyWith(special: enabled ? available : DutySpecial.none));
  }

  void setLocationText(String value) => _update(state.draft.copyWith(locationText: value));

  void setReason(String value) => _update(state.draft.copyWith(reason: value));

  void setNotes(String value) => _update(state.draft.copyWith(notes: value));

  /// `M-13` dan qaytgan tanlov: matn **qo'shiladi**, 60 belgida kesiladi (M55).
  void addQuickNotes(List<String> notes) {
    if (notes.isEmpty) {
      return;
    }
    final bool truncated = quickNotesTruncated(state.draft.notes, notes);
    _update(
      state.draft.copyWith(notes: appendQuickNotes(state.draft.notes, notes)),
      notesTruncated: truncated,
    );
  }

  void toggleTrailer(String trailerId) {
    final List<String> next = <String>[...state.draft.trailerIds];
    if (!next.remove(trailerId)) {
      next.add(trailerId);
    }
    _update(state.draft.copyWith(trailerIds: next));
  }

  void toggleShippingDoc(String docId) {
    final List<String> next = <String>[...state.draft.shippingDocIds];
    if (!next.remove(docId)) {
      next.add(docId);
    }
    _update(state.draft.copyWith(shippingDocIds: next));
  }

  Future<void> addShippingDoc(String number) async {
    final String trimmed = number.trim();
    if (trimmed.isEmpty || state.draft.shippingDocIds.contains(trimmed)) {
      return;
    }
    await _catalog.rememberShippingDoc(trimmed);
    _update(state.draft.copyWith(shippingDocIds: <String>[...state.draft.shippingDocIds, trimmed]));
  }

  /// `M-14 Update Now` — yangi GPS fiksatsiyasi va reverse geocoding.
  Future<void> refreshLocation() async {
    state = state.copyWith(locationBusy: true, locationError: false);
    try {
      final LocationFix? fix = await ref.read(locationServiceProvider).currentFix();
      if (fix == null) {
        state = state.copyWith(locationBusy: false, locationError: true);
        return;
      }
      final GeocodedPlace? place = await ref
          .read(reverseGeocoderProvider)
          .lookup(lat: fix.lat, lng: fix.lng);
      _draft = state.draft.copyWith(
        lat: fix.lat,
        lng: fix.lng,
        accuracyM: fix.accuracyM,
        locationText: place?.label ?? state.draft.locationText,
      );
      state = _evaluate(state.copyWith(draft: _draft, locationBusy: false, locationError: false));
    } on Exception {
      state = state.copyWith(locationBusy: false, locationError: true);
    }
  }

  /// Formani saqlaydi. Oflayn bo'lsa ham outbox'ga tushadi (M24).
  ///
  /// Natija — snackbar matnini tanlash uchun; [DutySubmitOutcome.none]
  /// «saqlanmadi» degani.
  Future<DutySubmitOutcome> save() async {
    final DutyFormState current = _evaluate(state);
    if (current.issues.isNotEmpty) {
      state = current;
      return DutySubmitOutcome.none;
    }
    state = current.copyWith(saving: true, clearError: true);
    try {
      await _repository.changeStatus(
        draft: current.draft,
        origin: dutyEventOrigin(eldConnected: current.eldConnected),
      );
      _draft = null;
      final DutySubmitOutcome outcome = current.eldConnected
          ? DutySubmitOutcome.saved
          : DutySubmitOutcome.queuedOffline;
      state = state.copyWith(saving: false, outcome: outcome);
      return outcome;
    } on ApiError catch (error) {
      state = state.copyWith(saving: false, error: error);
      return DutySubmitOutcome.none;
    }
  }
}

final NotifierProvider<DutyStatusController, DutyFormState> dutyStatusControllerProvider =
    NotifierProvider<DutyStatusController, DutyFormState>(DutyStatusController.new);
