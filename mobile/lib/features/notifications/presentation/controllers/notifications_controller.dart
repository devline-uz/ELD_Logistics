/// `M-43` kontrolleri — telefon (`M-43`) va planshet (`T-29`) uni ulashadi (M7).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../domain/notification_repository.dart';
import '../notification_providers.dart';

class NotificationsUiState {
  const NotificationsUiState({
    this.loading = true,
    this.loadingMore = false,
    this.page = 1,
    this.total = 0,
    this.hasMore = false,
    this.error,
    this.allReadDone = false,
  });

  final bool loading;
  final bool loadingMore;
  final int page;
  final int total;
  final bool hasMore;
  final ApiError? error;

  /// `read-all` muvaffaqiyatli tugadi — snackbar uchun bir martalik bayroq.
  final bool allReadDone;

  NotificationsUiState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    int? total,
    bool? hasMore,
    ApiError? error,
    bool? allReadDone,
    bool clearError = false,
  }) => NotificationsUiState(
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    page: page ?? this.page,
    total: total ?? this.total,
    hasMore: hasMore ?? this.hasMore,
    error: clearError ? null : (error ?? this.error),
    allReadDone: allReadDone ?? this.allReadDone,
  );
}

/// Bir sahifadagi elementlar soni (`per_page`).
const int kNotificationsPageSize = 25;

class NotificationsController extends Notifier<NotificationsUiState> {
  NotificationRepository get _repository => ref.read(notificationRepositoryProvider);

  @override
  NotificationsUiState build() {
    // `build()` tugamasdan `state` ga yozib bo'lmaydi (Riverpod 3) — birinchi
    // yuklashni mikrotaskga suramiz.
    unawaited(Future<void>.microtask(refresh));
    return const NotificationsUiState();
  }

  Future<void> refresh() async {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final NotificationPage page = await _repository.load(perPage: kNotificationsPageSize);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        loading: false,
        page: page.page,
        total: page.total,
        hasMore: page.page * kNotificationsPageSize < page.total,
        clearError: true,
      );
    } on ApiError catch (error) {
      if (ref.mounted) {
        state = state.copyWith(loading: false, error: error);
      }
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) {
      return;
    }
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final NotificationPage next = await _repository.load(
        page: state.page + 1,
        perPage: kNotificationsPageSize,
      );
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        loadingMore: false,
        page: next.page,
        total: next.total,
        hasMore: next.page * kNotificationsPageSize < next.total,
      );
    } on ApiError catch (error) {
      if (ref.mounted) {
        state = state.copyWith(loadingMore: false, error: error);
      }
    }
  }

  /// Element bosilganda: avval o'qildi, keyin deep link (navigatsiyani UI qiladi).
  Future<void> markRead(String id) => _repository.markRead(id);

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    if (ref.mounted) {
      state = state.copyWith(allReadDone: true);
    }
  }

  void acknowledgeAllRead() => state = state.copyWith(allReadDone: false);
}

final NotifierProvider<NotificationsController, NotificationsUiState>
notificationsControllerProvider = NotifierProvider<NotificationsController, NotificationsUiState>(
  NotificationsController.new,
);
