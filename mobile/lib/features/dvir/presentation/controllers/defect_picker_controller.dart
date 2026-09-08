/// `M-33 Defect picker` kontrolleri (telefon modali va planshet modali umumiy).
///
/// Katalog **serverdan** (M105), qidiruv lokal, har nuqsonga izoh + ≤5 foto
/// (`tz.md` Q27.1). Kritik nuqson tanlanganda M106 ogohlantirishi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../data/dvir_file_repository.dart';
import '../../domain/defect_catalog.dart';
import '../../domain/dvir_models.dart';
import '../../domain/dvir_repository.dart';
import 'dvir_providers.dart';

class DefectPickerState {
  const DefectPickerState({
    this.category = DefectCategory.truck,
    this.loading = true,
    this.error,
    this.catalog = const <DefectType>[],
    this.query = '',
    this.selected = const <String, DvirDefect>{},
    this.accidentPhotoAvailable = false,
    this.accidentPhotoPaths = const <String>[],
    this.criticalPrompt,
    this.photoError,
  });

  final DefectCategory category;
  final bool loading;
  final ApiError? error;

  /// Tozalangan katalog (faqat [category] bandlari).
  final List<DefectType> catalog;

  final String query;

  /// Tanlanganlar — `DefectType.id` bo'yicha.
  final Map<String, DvirDefect> selected;

  /// M105: katalogda `Accident Photo` bandi bo'lgan — alohida blok ko'rsatiladi.
  final bool accidentPhotoAvailable;
  final List<String> accidentPhotoPaths;

  /// M106: hozirgina tanlangan kritik nuqson (ogohlantirish ko'rsatiladi).
  final DefectType? criticalPrompt;

  /// Foto biriktirishdagi xato (mavjud emas / hajm chegarasi).
  final String? photoError;

  /// Qidiruv qo'llangan ro'yxat.
  List<DefectType> get visible => filterDefects(catalog, query);

  bool isSelected(String id) => selected.containsKey(id);

  List<DvirDefect> get result => selected.values.toList(growable: false);

  DefectPickerState copyWith({
    DefectCategory? category,
    bool? loading,
    ApiError? error,
    bool clearError = false,
    List<DefectType>? catalog,
    String? query,
    Map<String, DvirDefect>? selected,
    bool? accidentPhotoAvailable,
    List<String>? accidentPhotoPaths,
    DefectType? criticalPrompt,
    bool clearCriticalPrompt = false,
    String? photoError,
    bool clearPhotoError = false,
  }) => DefectPickerState(
    category: category ?? this.category,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
    catalog: catalog ?? this.catalog,
    query: query ?? this.query,
    selected: selected ?? this.selected,
    accidentPhotoAvailable: accidentPhotoAvailable ?? this.accidentPhotoAvailable,
    accidentPhotoPaths: accidentPhotoPaths ?? this.accidentPhotoPaths,
    criticalPrompt: clearCriticalPrompt ? null : (criticalPrompt ?? this.criticalPrompt),
    photoError: clearPhotoError ? null : (photoError ?? this.photoError),
  );
}

/// Foto biriktirishdagi xato sabablari (UI matni `context.l10n` dan olinadi).
enum DefectPhotoIssue { unavailable, limit, tooLarge }

class DefectPickerController extends Notifier<DefectPickerState> {
  late final DefectCatalogRepository _catalog = ref.read(defectCatalogRepositoryProvider);
  late final DvirFileRepository _files = ref.read(dvirFileRepositoryProvider);

  @override
  DefectPickerState build() => const DefectPickerState();

  /// Ekran ochilishida chaqiriladi: kategoriya + oldingi tanlov tiklanadi.
  Future<void> open({
    required DefectCategory category,
    required List<DvirDefect> initial,
    List<String> accidentPhotoPaths = const <String>[],
    bool forceRefresh = false,
  }) async {
    state = DefectPickerState(
      category: category,
      selected: <String, DvirDefect>{for (final DvirDefect d in initial) d.type.id: d},
      accidentPhotoPaths: accidentPhotoPaths,
    );
    await reload(forceRefresh: forceRefresh);
  }

  Future<void> reload({bool forceRefresh = false}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final List<DefectType> all = await _catalog.load(forceRefresh: forceRefresh);
      state = state.copyWith(
        loading: false,
        catalog: <DefectType>[
          for (final DefectType t in all)
            if (t.category == state.category) t,
        ],
        accidentPhotoAvailable: state.category == DefectCategory.truck,
      );
    } on ApiError catch (error) {
      state = state.copyWith(loading: false, error: error);
    }
  }

  void search(String query) => state = state.copyWith(query: query, clearCriticalPrompt: true);

  /// Belgilash/olib tashlash. Kritik nuqson tanlansa M106 ogohlantirishi.
  void toggle(DefectType type) {
    final Map<String, DvirDefect> next = <String, DvirDefect>{...state.selected};
    if (next.remove(type.id) != null) {
      state = state.copyWith(selected: next, clearCriticalPrompt: true);
      return;
    }
    next[type.id] = DvirDefect(type: type);
    state = state.copyWith(
      selected: next,
      criticalPrompt: type.isCritical ? type : null,
      clearCriticalPrompt: !type.isCritical,
    );
  }

  void dismissCriticalPrompt() => state = state.copyWith(clearCriticalPrompt: true);

  void setNote(String typeId, String note) {
    final DvirDefect? current = state.selected[typeId];
    if (current == null) {
      return;
    }
    state = state.copyWith(
      selected: <String, DvirDefect>{
        ...state.selected,
        typeId: current.copyWith(note: note),
      },
    );
  }

  /// Kamera/galereyadan foto qo'shish (≤5, `tz.md` Q27.1).
  Future<DefectPhotoIssue?> addPhoto(String typeId, {bool fromCamera = true}) async {
    final DvirDefect? current = state.selected[typeId];
    if (current == null) {
      return null;
    }
    if (!current.canAddPhoto) {
      return DefectPhotoIssue.limit;
    }
    if (!_files.isPhotoCaptureAvailable) {
      return DefectPhotoIssue.unavailable;
    }
    final String? source = await _files.capturePhoto(fromCamera: fromCamera);
    if (source == null) {
      return null;
    }
    try {
      final String stored = await _files.enqueuePhoto(source);
      state = state.copyWith(
        selected: <String, DvirDefect>{
          ...state.selected,
          typeId: current.copyWith(photoPaths: <String>[...current.photoPaths, stored]),
        },
      );
      return null;
    } on PhotoTooLargeException {
      return DefectPhotoIssue.tooLarge;
    }
  }

  void removePhoto(String typeId, String path) {
    final DvirDefect? current = state.selected[typeId];
    if (current == null) {
      return;
    }
    state = state.copyWith(
      selected: <String, DvirDefect>{
        ...state.selected,
        typeId: current.copyWith(
          photoPaths: <String>[
            for (final String p in current.photoPaths)
              if (p != path) p,
          ],
        ),
      },
    );
  }

  /// M105: `Accident Photo` — nuqson emas, alohida foto bandi.
  Future<DefectPhotoIssue?> addAccidentPhoto({bool fromCamera = true}) async {
    if (!_files.isPhotoCaptureAvailable) {
      return DefectPhotoIssue.unavailable;
    }
    final String? source = await _files.capturePhoto(fromCamera: fromCamera);
    if (source == null) {
      return null;
    }
    try {
      final String stored = await _files.enqueuePhoto(source);
      state = state.copyWith(accidentPhotoPaths: <String>[...state.accidentPhotoPaths, stored]);
      return null;
    } on PhotoTooLargeException {
      return DefectPhotoIssue.tooLarge;
    }
  }
}

final NotifierProvider<DefectPickerController, DefectPickerState> defectPickerControllerProvider =
    NotifierProvider<DefectPickerController, DefectPickerState>(DefectPickerController.new);
