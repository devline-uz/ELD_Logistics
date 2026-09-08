/// `M-28 Unidentified driving claim` kontrolleri va DI simlari (M3).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_code.dart';
import '../../../../core/session/session_context.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../data/unidentified_repository_impl.dart';
import '../../domain/unidentified_models.dart';

final Provider<UnidentifiedRepository> unidentifiedRepositoryProvider =
    Provider<UnidentifiedRepository>(
      (Ref ref) => DriftUnidentifiedRepository(
        db: ref.watch(appDatabaseProvider),
        logs: ref.watch(logsDaoProvider),
        outbox: ref.watch(outboxRepositoryProvider),
        driverId: ref.watch(sessionContextProvider).driverId,
      ),
    );

/// `M-28` ro'yxati va Home'dagi sariq karta hisoblagichi (M100).
final StreamProvider<List<UnidentifiedBlock>> unidentifiedBlocksProvider =
    StreamProvider<List<UnidentifiedBlock>>(
      (Ref ref) => ref.watch(unidentifiedRepositoryProvider).watchClaimable(),
    );

class UnidentifiedState {
  const UnidentifiedState({this.busyId, this.alreadyAssigned = false, this.error});

  /// Hozir qayta ishlanayotgan blok.
  final String? busyId;

  /// `409 ALREADY_ASSIGNED` — foydalanuvchiga xabar ko'rsatiladi.
  final bool alreadyAssigned;

  final ApiError? error;

  UnidentifiedState copyWith({
    String? busyId,
    bool clearBusy = false,
    bool? alreadyAssigned,
    ApiError? error,
    bool clearError = false,
  }) => UnidentifiedState(
    busyId: clearBusy ? null : (busyId ?? this.busyId),
    alreadyAssigned: alreadyAssigned ?? this.alreadyAssigned,
    error: clearError ? null : (error ?? this.error),
  );
}

class UnidentifiedController extends Notifier<UnidentifiedState> {
  @override
  UnidentifiedState build() => const UnidentifiedState();

  void acknowledge() => state = state.copyWith(alreadyAssigned: false, clearError: true);

  Future<void> claim(String id) async {
    state = state.copyWith(busyId: id, clearError: true, alreadyAssigned: false);
    try {
      final ClaimOutcome outcome = await ref.read(unidentifiedRepositoryProvider).claim(id);
      state = state.copyWith(
        clearBusy: true,
        alreadyAssigned: outcome == ClaimOutcome.alreadyAssigned,
      );
    } on ApiError catch (error) {
      state = state.copyWith(
        clearBusy: true,
        alreadyAssigned: error.code == ApiErrorCode.alreadyAssigned,
        error: error.code == ApiErrorCode.alreadyAssigned ? null : error,
      );
    }
  }

  Future<void> dismiss(String id) async {
    state = state.copyWith(busyId: id, clearError: true);
    await ref.read(unidentifiedRepositoryProvider).dismiss(id);
    state = state.copyWith(clearBusy: true);
  }
}

final NotifierProvider<UnidentifiedController, UnidentifiedState> unidentifiedControllerProvider =
    NotifierProvider<UnidentifiedController, UnidentifiedState>(UnidentifiedController.new);
