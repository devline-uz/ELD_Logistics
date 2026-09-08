/// `M-21 / T-08 Select Shipping Document` kontrolleri.
///
/// **§3.3:** trailer va shipping document har haydovchi uchun **alohida**;
/// `Switch` da haydovchi hujjatlarning kimga tegishli ekanini tanlaydi.
/// Tanlangan hujjatlar **faol** slotning trip'iga yoziladi (`M53`: status
/// o'zgarmaydi), tanlanmaganlari ikkinchi haydovchida qoladi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../duty_status/data/duty_status_providers.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../data/session_manager.dart';
import '../../domain/session_state.dart';

/// Hujjat egasi (M-21 dagi `Myself / Co-driver` tanlovi).
enum ShippingDocOwner { myself, coDriver }

class ShippingDocumentState {
  const ShippingDocumentState({
    this.documents = const <String>[],
    this.mine = const <String>{},
    this.loading = true,
    this.saving = false,
    this.saved = false,
    this.error,
  });

  /// Trip'dagi barcha shipping document raqamlari.
  final List<String> documents;

  /// Faol haydovchiga tegishli deb belgilanganlari.
  final Set<String> mine;

  final bool loading;
  final bool saving;
  final bool saved;
  final ApiError? error;

  bool get isEmpty => !loading && documents.isEmpty;

  ShippingDocOwner ownerOf(String doc) =>
      mine.contains(doc) ? ShippingDocOwner.myself : ShippingDocOwner.coDriver;

  ShippingDocumentState copyWith({
    List<String>? documents,
    Set<String>? mine,
    bool? loading,
    bool? saving,
    bool? saved,
    ApiError? error,
  }) => ShippingDocumentState(
    documents: documents ?? this.documents,
    mine: mine ?? this.mine,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    error: error,
  );
}

class ShippingDocumentController extends Notifier<ShippingDocumentState> {
  @override
  ShippingDocumentState build() {
    final AsyncValue<DutyStatusContext> duty = ref.watch(dutyStatusContextProvider);
    final DutyStatusContext context = duty.value ?? DutyStatusContext.empty();
    // Boshlang'ich taxmin: trip'dagi hamma hujjat faol haydovchiniki.
    return ShippingDocumentState(
      documents: context.shippingDocIds,
      mine: context.shippingDocIds.toSet(),
      loading: duty.isLoading,
    );
  }

  /// Ikkinchi slotdagi haydovchi nomi (radio yorlig'i uchun).
  String get coDriverName => ref.read(sessionManagerProvider).passive.driverName;

  void setOwner(String doc, ShippingDocOwner owner) {
    final Set<String> next = <String>{...state.mine};
    if (owner == ShippingDocOwner.myself) {
      next.add(doc);
    } else {
      next.remove(doc);
    }
    state = state.copyWith(mine: next, saved: false);
  }

  /// **M53:** hujjatlar statusni o'zgartirmasdan yangilanadi.
  Future<void> submit() async {
    if (state.saving) {
      return;
    }
    state = state.copyWith(saving: true);
    final DutyStatusContext context =
        ref.read(dutyStatusContextProvider).value ?? DutyStatusContext.empty();
    try {
      await ref
          .read(dutyStatusRepositoryProvider)
          .updateDocuments(
            trailerIds: context.trailerIds,
            shippingDocIds: state.documents.where(state.mine.contains).toList(growable: false),
            notes: context.notes,
          );
      state = state.copyWith(saving: false, saved: true);
    } on ApiError catch (error) {
      state = state.copyWith(saving: false, error: error);
    }
  }
}

final NotifierProvider<ShippingDocumentController, ShippingDocumentState>
shippingDocumentControllerProvider =
    NotifierProvider<ShippingDocumentController, ShippingDocumentState>(
      ShippingDocumentController.new,
    );

/// Ikki sessiya holati — modal sarlavhasida ikkinchi haydovchini ko'rsatish uchun.
final Provider<DualSessionState> shippingDocSessionProvider = Provider<DualSessionState>(
  (Ref ref) => ref.watch(sessionManagerProvider),
);
