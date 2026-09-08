/// `M-58 Sessions (my devices)` kontrolleri (tz-mobile 1524, §4.6).
///
/// M7: telefon va planshet **bitta** kontrollerni ulashadi.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../data/auth_providers.dart';
import '../../domain/driver_session.dart';

class SessionsState {
  const SessionsState({
    this.sessions = const <DriverSession>[],
    this.loading = true,
    this.revoking,
    this.error,
  });

  final List<DriverSession> sessions;
  final bool loading;

  /// Bekor qilinayotgan sessiya `id` si (satrdagi spinner uchun).
  final String? revoking;

  final ApiError? error;

  bool get isEmpty => !loading && error == null && sessions.isEmpty;

  SessionsState copyWith({
    List<DriverSession>? sessions,
    bool? loading,
    String? revoking,
    ApiError? error,
  }) => SessionsState(
    sessions: sessions ?? this.sessions,
    loading: loading ?? this.loading,
    revoking: revoking,
    error: error,
  );
}

class SessionsController extends AsyncNotifier<SessionsState> {
  @override
  Future<SessionsState> build() async => _load();

  Future<SessionsState> _load() async {
    try {
      final List<DriverSession> sessions = await ref.read(activeAuthRepositoryProvider).sessions();
      return SessionsState(sessions: sessions, loading: false);
    } on ApiError catch (error) {
      return SessionsState(loading: false, error: error);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue<SessionsState>.loading();
    state = AsyncValue<SessionsState>.data(await _load());
  }

  /// `DELETE /auth/sessions/{id}` — joriy sessiya bekor qilinmaydi.
  Future<void> revoke(String id) async {
    final SessionsState current = state.value ?? const SessionsState();
    state = AsyncValue<SessionsState>.data(current.copyWith(revoking: id));
    try {
      await ref.read(activeAuthRepositoryProvider).revokeSession(id);
      state = AsyncValue<SessionsState>.data(
        current.copyWith(
          sessions: current.sessions.where((DriverSession s) => s.id != id).toList(growable: false),
        ),
      );
    } on ApiError catch (error) {
      state = AsyncValue<SessionsState>.data(current.copyWith(error: error));
    }
  }
}

final AsyncNotifierProvider<SessionsController, SessionsState> sessionsControllerProvider =
    AsyncNotifierProvider<SessionsController, SessionsState>(SessionsController.new);
