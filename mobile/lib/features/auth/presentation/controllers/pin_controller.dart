/// `M-04 PIN entry` kontrolleri (tz-mobile §4.5, §17.3 · mobile-security §4).
///
/// PIN **hech qachon** log/analytics ga chiqmaydi (M159); solishtirish va
/// hashlash `data/pin_hasher.dart` da, blok qoidasi `PinLockoutPolicy` da.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_code.dart';
import '../../../../core/router/auth_state.dart';
import '../../../../core/time/time_providers.dart';
import '../../data/auth_providers.dart';
import '../../domain/auth_models.dart';
import '../../domain/auth_policies.dart';
import '../../domain/auth_repository.dart';
import 'form_status.dart';

class PinState {
  const PinState({
    this.entered = '',
    this.action = PinAction.returnToTruck,
    this.status = const FormStatus(),
    this.lockout = const PinLockoutState(),
    this.lockRemaining = Duration.zero,
    this.formatIssue,
    this.verifiedOffline = false,
  });

  /// Kiritilgan raqamlar (maks. [PinPolicy.length]).
  final String entered;

  final PinAction action;
  final FormStatus status;
  final PinLockoutState lockout;

  /// Ekranda ko'rsatiladigan qolgan blok vaqti (taymer yangilaydi).
  final Duration lockRemaining;

  /// Lokal format xatosi (uzunlik / takror / ketma-ketlik).
  final PinFormatIssue? formatIssue;

  /// M16: lokal hash bilan tasdiqlandi, server keyin tekshiradi.
  final bool verifiedOffline;

  bool get isLocked => lockRemaining > Duration.zero;

  bool get isComplete => entered.length == PinPolicy.length;

  int get attemptsLeft => PinLockoutPolicy.attemptsLeft(lockout);

  /// Blok bo'lmagan va urinish ketmayotgan holatda raqam kiritish mumkin.
  bool get canType => !isLocked && !status.isSubmitting;

  PinState copyWith({
    String? entered,
    PinAction? action,
    FormStatus? status,
    PinLockoutState? lockout,
    Duration? lockRemaining,
    PinFormatIssue? formatIssue,
    bool clearFormatIssue = false,
    bool? verifiedOffline,
  }) => PinState(
    entered: entered ?? this.entered,
    action: action ?? this.action,
    status: status ?? this.status,
    lockout: lockout ?? this.lockout,
    lockRemaining: lockRemaining ?? this.lockRemaining,
    formatIssue: clearFormatIssue ? null : (formatIssue ?? this.formatIssue),
    verifiedOffline: verifiedOffline ?? this.verifiedOffline,
  );
}

class PinController extends Notifier<PinState> {
  @override
  PinState build() {
    // Blok holati secure storage'da — ilova qayta ochilganda ham saqlanadi.
    unawaited(_loadLockout());
    return const PinState();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  DateTime get _now => ref.read(timeSourceProvider).now();

  Future<void> _loadLockout() async {
    final PinLockoutState lockout = await _repo.pinLockout();
    state = state.copyWith(lockout: lockout, lockRemaining: lockout.remaining(_now));
  }

  /// Amalni ekran ochilishida beradi (`return_to_truck` / `switch_driver`).
  void setAction(PinAction action) {
    if (state.action != action) {
      state = state.copyWith(action: action);
    }
  }

  /// Blok taymerini bir soniyaga suradi (ekrandagi `Ticker`).
  void tick() {
    if (!state.isLocked) {
      return;
    }
    state = state.copyWith(lockRemaining: state.lockout.remaining(_now));
  }

  void push(String digit) {
    if (!state.canType || state.entered.length >= PinPolicy.length) {
      return;
    }
    final String next = state.entered + digit;
    state = state.copyWith(entered: next, clearFormatIssue: true, status: const FormStatus());
    if (next.length == PinPolicy.length) {
      unawaited(submit());
    }
  }

  void backspace() {
    if (!state.canType || state.entered.isEmpty) {
      return;
    }
    state = state.copyWith(
      entered: state.entered.substring(0, state.entered.length - 1),
      clearFormatIssue: true,
      status: const FormStatus(),
    );
  }

  void clear() =>
      state = state.copyWith(entered: '', clearFormatIssue: true, status: const FormStatus());

  Future<void> submit() async {
    if (state.isLocked || state.status.isSubmitting) {
      return;
    }
    final PinFormatIssue? issue = PinPolicy.validate(state.entered);
    if (issue != null) {
      state = state.copyWith(formatIssue: issue, entered: '');
      return;
    }
    state = state.copyWith(status: const FormStatus.submitting());
    try {
      final PinVerification result = await _repo.verifyPin(
        pin: state.entered,
        action: state.action,
      );
      final PinLockoutState cleared = await _repo.pinLockout();
      state = state.copyWith(
        entered: '',
        status: const FormStatus.success(),
        lockout: cleared,
        lockRemaining: Duration.zero,
        verifiedOffline: result.offline,
      );
      if (result.verified && state.action == PinAction.returnToTruck) {
        ref.read(authStatusProvider.notifier).set(AuthStatus.authenticated);
      }
    } on ApiError catch (error) {
      final PinLockoutState lockout = await _repo.pinLockout();
      state = state.copyWith(
        entered: '',
        status: FormStatus.failure(error),
        lockout: lockout,
        lockRemaining: error.code == ApiErrorCode.pinLocked
            ? (error.retryAfter ?? lockout.remaining(_now))
            : lockout.remaining(_now),
      );
    }
  }
}

final NotifierProvider<PinController, PinState> pinControllerProvider =
    NotifierProvider<PinController, PinState>(PinController.new);
