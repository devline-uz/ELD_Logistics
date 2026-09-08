/// Haydash rejimi kontrolleri (`M-15` + `M-16`, tz-mobile §9.4–§9.7).
///
/// **M7:** telefon (`M-15`) va planshet (`T-25`) ayni shu kontrollerni
/// ulashadi. Qarorlar `duty_status/domain/duty_status_rules.dart` dagi sof
/// funksiyalarda; bu yerda faqat oqim va taymerlar.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_core/sync_core.dart';

import '../../../../core/eld/eld_providers.dart';
import '../../../../core/eld/motion_detector.dart';
import '../../../../core/error/api_error.dart';
import '../../../../core/time/time_providers.dart';
import '../../../duty_status/data/duty_status_providers.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/domain/duty_status_repository.dart';
import '../../../duty_status/domain/duty_status_rules.dart';
import '../../data/drive_mode_providers.dart';
import '../../domain/idle_alert.dart';

class DriveModeState {
  const DriveModeState({
    this.status = DutyStatusValue.off,
    this.special = DutySpecial.none,
    this.statusSince,
    this.inMotion = false,
    this.promptVisible = false,
    this.promptIssuedAt,
    this.speedKmh,
    this.error,
  });

  final DutyStatusValue status;
  final DutySpecial special;

  /// Joriy statusga o'tilgan payt — katta hisoblagich shundan yuradi.
  final DateTime? statusSince;

  /// `In-motion` / `You have stopped` (M59).
  final bool inMotion;

  /// `M-16` modali ko'rinyaptimi.
  final bool promptVisible;

  /// **M60:** so'rov chiqqan payt — `ON` eventining vaqti aynan shu.
  final DateTime? promptIssuedAt;

  final double? speedKmh;
  final ApiError? error;

  /// Haydash rejimi ekrani ochiq bo'lishi kerakmi.
  bool get driving => status == DutyStatusValue.driving;

  DriveModeState copyWith({
    DutyStatusValue? status,
    DutySpecial? special,
    DateTime? statusSince,
    bool? inMotion,
    bool? promptVisible,
    DateTime? promptIssuedAt,
    bool clearPrompt = false,
    double? speedKmh,
    ApiError? error,
    bool clearError = false,
  }) => DriveModeState(
    status: status ?? this.status,
    special: special ?? this.special,
    statusSince: statusSince ?? this.statusSince,
    inMotion: inMotion ?? this.inMotion,
    promptVisible: clearPrompt ? false : (promptVisible ?? this.promptVisible),
    promptIssuedAt: clearPrompt ? null : (promptIssuedAt ?? this.promptIssuedAt),
    speedKmh: speedKmh ?? this.speedKmh,
    error: clearError ? null : (error ?? this.error),
  );
}

class DriveModeController extends Notifier<DriveModeState> {
  late final DutyStatusRepository _repository = ref.read(dutyStatusRepositoryProvider);
  late final IdleAlertNotifier _alerts = ref.read(idleAlertNotifierProvider);

  Timer? _intermediate;

  /// `M-16` ogohlantirishi uchun matnlar — `app.dart` bootstrap'i `context.l10n`
  /// dan to'ldiradi (core da lokalizatsiya konteksti yo'q).
  static String alertTitle = '';
  static String alertBody = '';

  @override
  DriveModeState build() {
    // Auto-DR (M56) va idle taymer (M62) ekran yopiq bo'lganda ham ishlashi
    // kerak — Riverpod 3 da provayderlar sukut bo'yicha auto-dispose.
    ref.keepAlive();

    final DutyStatusContext context =
        ref.watch(dutyStatusContextProvider).value ?? DutyStatusContext.empty();

    ref.listen<AsyncValue<MotionEvent>>(motionEventsProvider, (
      AsyncValue<MotionEvent>? previous,
      AsyncValue<MotionEvent> next,
    ) {
      final MotionEvent? event = next.value;
      if (event != null) {
        unawaited(_onMotion(event));
      }
    });

    ref.onDispose(_cancelIntermediate);

    return DriveModeState(
      status: context.current ?? DutyStatusValue.off,
      special: context.special,
      statusSince: context.since,
      inMotion: context.current == DutyStatusValue.driving,
    );
  }

  Future<void> _onMotion(MotionEvent event) async {
    switch (event.type) {
      case MotionEventType.movingConfirmed:
        await _onMoving(event);
      case MotionEventType.stopped:
        _cancelIntermediate();
        state = state.copyWith(inMotion: false, speedKmh: 0);
      case MotionEventType.idlePromptDue:
        await _alerts.show(title: alertTitle, body: alertBody);
        state = state.copyWith(promptVisible: true, promptIssuedAt: event.at);
      case MotionEventType.idleNoAnswer:
        // M60: event vaqti — so'rov chiqqan payt, to'xtash vaqti emas.
        await _alerts.cancel();
        await _switchToOnDuty(at: event.promptIssuedAt ?? event.at);
    }
  }

  Future<void> _onMoving(MotionEvent event) async {
    final DutyStatusContext context =
        ref.read(dutyStatusContextProvider).value ?? DutyStatusContext.empty();

    // tz-mobile §9.4: PC rejimida harakat `DR` yozmaydi.
    if (autoDriveSuppressed(context.special)) {
      state = state.copyWith(inMotion: true, speedKmh: event.speedKmh);
      return;
    }
    // YM tezlik chegarasidan oshdi — YM yopiladi, `DR` boshlanadi.
    final bool ymEnded = yardMoveExpired(
      special: context.special,
      speedKmh: event.speedKmh,
      policy: context.policy,
    );

    state = state.copyWith(
      inMotion: true,
      speedKmh: event.speedKmh,
      special: ymEnded ? DutySpecial.none : context.special,
    );
    if (state.status == DutyStatusValue.driving && !ymEnded) {
      return;
    }
    await _write(
      DutyStatusDraft(
        status: DutyStatusValue.driving,
        lat: event.lat,
        lng: event.lng,
        trailerIds: context.trailerIds,
        shippingDocIds: context.shippingDocIds,
      ),
      origin: EventOrigin.auto,
      at: event.at,
      speedKmh: event.speedKmh,
      odometerM: event.odometerM,
      engineHours: event.engineHours,
    );
    _startIntermediate();
  }

  /// `Yes, driving` — `DR` da qolamiz, taymer qayta boshlanadi (M61).
  Future<void> answerStillDriving() async {
    ref.read(motionDetectorProvider).answerStillDriving();
    await _alerts.cancel();
    state = state.copyWith(clearPrompt: true);
  }

  /// `No` — status `ON`, event vaqti = so'rov chiqqan payt (M60).
  Future<void> answerNotDriving() async {
    final DateTime? issuedAt = state.promptIssuedAt;
    ref.read(motionDetectorProvider).answerNotDriving();
    await _alerts.cancel();
    state = state.copyWith(clearPrompt: true);
    await _switchToOnDuty(at: issuedAt ?? ref.read(timeSourceProvider).now());
  }

  /// Haydash rejimida ruxsat etilgan qo'lda o'tish (M58): `Off Duty` / `On Duty`.
  Future<void> changeStatus(DutyStatusValue status) async {
    if (!status.isSelectable) {
      return;
    }
    final DutyStatusContext context =
        ref.read(dutyStatusContextProvider).value ?? DutyStatusContext.empty();
    _cancelIntermediate();
    await _write(
      DutyStatusDraft(
        status: status,
        special: normalizeSpecial(status, context.special),
        trailerIds: context.trailerIds,
        shippingDocIds: context.shippingDocIds,
      ),
      origin: dutyEventOrigin(eldConnected: ref.read(eldConnectedProvider)),
    );
  }

  Future<void> _switchToOnDuty({required DateTime at}) async {
    _cancelIntermediate();
    final DutyStatusContext context =
        ref.read(dutyStatusContextProvider).value ?? DutyStatusContext.empty();
    await _write(
      DutyStatusDraft(
        status: DutyStatusValue.on,
        trailerIds: context.trailerIds,
        shippingDocIds: context.shippingDocIds,
      ),
      origin: EventOrigin.auto,
      at: at,
    );
  }

  Future<void> _write(
    DutyStatusDraft draft, {
    required EventOrigin origin,
    DateTime? at,
    double? speedKmh,
    int? odometerM,
    double? engineHours,
  }) async {
    try {
      await _repository.changeStatus(
        draft: draft,
        origin: origin,
        at: at,
        speedKmh: speedKmh,
        odometerM: odometerM,
        engineHours: engineHours,
      );
      state = state.copyWith(
        status: draft.status,
        special: draft.special,
        statusSince: at ?? ref.read(timeSourceProvider).now(),
        inMotion: draft.status == DutyStatusValue.driving && state.inMotion,
        clearError: true,
      );
    } on ApiError catch (error) {
      state = state.copyWith(error: error);
    }
  }

  /// **M63:** haydash rejimida har 60 daqiqada `intermediate` eventi.
  void _startIntermediate() {
    _cancelIntermediate();
    _intermediate = Timer.periodic(kIntermediateInterval, (Timer _) {
      unawaited(_repository.recordIntermediate(speedKmh: state.speedKmh));
    });
  }

  void _cancelIntermediate() {
    _intermediate?.cancel();
    _intermediate = null;
  }
}

final NotifierProvider<DriveModeController, DriveModeState> driveModeControllerProvider =
    NotifierProvider<DriveModeController, DriveModeState>(DriveModeController.new);
