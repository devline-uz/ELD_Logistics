/// `M-37 Inspection Report` va `M-38 Begin inspection (kiosk)` kontrollerlari.
///
/// **M7:** telefon (`M-37`/`M-38`) va planshet (`T-17`/`T-20`) ayni shu
/// kontrollerlarni ulashadi — faqat `View` boshqa.
/// **M110:** kiosk rejimi faqat o'qish — bu yerda hech qanday yozuv amali yo'q.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/time/time_providers.dart';
import '../../domain/inspection_models.dart';
import '../../domain/inspection_repository.dart';
import 'inspection_providers.dart';

/// `M-37` uch amalning umumiy holati.
class InspectionActionsState {
  const InspectionActionsState({this.starting = false, this.startError, this.session});

  final bool starting;
  final ApiError? startError;

  /// `POST /inspection/begin` natijasi; oflayn bo'lsa `null` (kiosk baribir
  /// ochiladi, lokal nusxa bilan).
  final InspectionSession? session;

  InspectionActionsState copyWith({
    bool? starting,
    ApiError? startError,
    bool clearStartError = false,
    InspectionSession? session,
  }) => InspectionActionsState(
    starting: starting ?? this.starting,
    startError: clearStartError ? null : (startError ?? this.startError),
    session: session ?? this.session,
  );
}

class InspectionActionsController extends Notifier<InspectionActionsState> {
  @override
  InspectionActionsState build() => const InspectionActionsState();

  /// `Begin Inspection`. Sessiya olinmasa ham `true` qaytadi — oflayn
  /// rejimda lokal nusxa ko'rsatiladi (M-38).
  Future<bool> begin() async {
    if (state.starting) {
      return false;
    }
    state = state.copyWith(starting: true, clearStartError: true);
    try {
      final InspectionSession? session = await ref.read(inspectionRepositoryProvider).begin();
      state = InspectionActionsState(session: session);
      return true;
    } on ApiError catch (error) {
      state = InspectionActionsState(startError: error);
      return false;
    }
  }
}

final NotifierProvider<InspectionActionsController, InspectionActionsState>
inspectionActionsControllerProvider =
    NotifierProvider<InspectionActionsController, InspectionActionsState>(
      InspectionActionsController.new,
    );

/// `M-38` kiosk holati.
class InspectionKioskState {
  const InspectionKioskState({
    this.loading = true,
    this.report,
    this.error,
    this.selectedDate,
    this.expired = false,
  });

  final bool loading;
  final InspectionReport? report;
  final ApiError? error;

  /// Sana tasmasida tanlangan kun (`null` — oxirgi kun).
  final DateTime? selectedDate;

  /// Sessiya `expires_at` dan o'tdi — rejim yopiladi.
  final bool expired;

  List<InspectionDay> get days => report?.days ?? const <InspectionDay>[];

  bool get isEmpty => !loading && error == null && days.isEmpty;

  /// Tanlangan kun; tanlanmagan bo'lsa oxirgisi (bugun).
  InspectionDay? get currentDay {
    if (days.isEmpty) {
      return null;
    }
    final DateTime? selected = selectedDate;
    if (selected == null) {
      return days.last;
    }
    return report?.dayFor(selected) ?? days.last;
  }

  InspectionKioskState copyWith({
    bool? loading,
    InspectionReport? report,
    ApiError? error,
    bool clearError = false,
    DateTime? selectedDate,
    bool? expired,
  }) => InspectionKioskState(
    loading: loading ?? this.loading,
    report: report ?? this.report,
    error: clearError ? null : (error ?? this.error),
    selectedDate: selectedDate ?? this.selectedDate,
    expired: expired ?? this.expired,
  );
}

class InspectionKioskController extends Notifier<InspectionKioskState> {
  /// Sessiya muddatini tekshirish oralig'i.
  static const Duration expiryTick = Duration(seconds: 30);

  Timer? _timer;

  @override
  InspectionKioskState build() {
    ref.onDispose(() => _timer?.cancel());
    Future<void>.microtask(load);
    return const InspectionKioskState();
  }

  /// 7 kun + bugun. Onlayn — server, oflayn — lokal Drift buferi.
  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final InspectionReport report = await ref.read(inspectionRepositoryProvider).logs();
      state = state.copyWith(loading: false, report: report);
      _startExpiryWatch();
    } on ApiError catch (error) {
      state = state.copyWith(loading: false, error: error);
    }
  }

  void selectDate(DateTime date) => state = state.copyWith(selectedDate: date);

  /// Sessiya muddati tugaganini kuzatadi (M-38: `expires_at` da rejim yopiladi).
  void _startExpiryWatch() {
    _timer?.cancel();
    final InspectionSession? session = ref.read(inspectionActionsControllerProvider).session;
    if (session == null) {
      return;
    }
    _timer = Timer.periodic(expiryTick, (Timer _) => _checkExpiry(session));
    _checkExpiry(session);
  }

  void _checkExpiry(InspectionSession session) {
    if (session.isExpiredAt(ref.read(timeSourceProvider).now())) {
      _timer?.cancel();
      state = state.copyWith(expired: true);
    }
  }
}

final NotifierProvider<InspectionKioskController, InspectionKioskState>
inspectionKioskControllerProvider =
    NotifierProvider<InspectionKioskController, InspectionKioskState>(
      InspectionKioskController.new,
    );

/// `M-39` chiqish PIN'i.
class InspectionExitPinState {
  const InspectionExitPinState({
    this.pin = '',
    this.checking = false,
    this.invalid = false,
    this.locked = false,
  });

  final String pin;
  final bool checking;
  final bool invalid;
  final bool locked;

  /// PIN uzunligi (M155: 6 xona).
  static const int pinLength = 6;

  bool get canSubmit => pin.length == pinLength && !checking && !locked;

  InspectionExitPinState copyWith({String? pin, bool? checking, bool? invalid, bool? locked}) =>
      InspectionExitPinState(
        pin: pin ?? this.pin,
        checking: checking ?? this.checking,
        invalid: invalid ?? this.invalid,
        locked: locked ?? this.locked,
      );
}

class InspectionExitPinController extends Notifier<InspectionExitPinState> {
  @override
  InspectionExitPinState build() => const InspectionExitPinState();

  void setPin(String value) => state = state.copyWith(pin: value.trim(), invalid: false);

  /// `true` — chiqishga ruxsat.
  Future<bool> submit() async {
    if (!state.canSubmit) {
      return false;
    }
    state = state.copyWith(checking: true, invalid: false);
    try {
      final bool ok = await ref.read(inspectionPinVerifierProvider).verify(state.pin);
      state = state.copyWith(checking: false, invalid: !ok, pin: ok ? '' : state.pin);
      return ok;
    } on InspectionPinLocked {
      state = state.copyWith(checking: false, locked: true, invalid: true);
      return false;
    }
  }
}

final NotifierProvider<InspectionExitPinController, InspectionExitPinState>
inspectionExitPinControllerProvider =
    NotifierProvider<InspectionExitPinController, InspectionExitPinState>(
      InspectionExitPinController.new,
    );
