/// `M-42` kontrolleri — telefon va planshet **bitta** shu kontrollerni ulashadi
/// (M7: biznes mantiq dublikati taqiq).
///
/// Biznes qoidalari `domain/chat_send_policy.dart` da; bu yerda faqat holat.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../data/chat_repository_impl.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_repository.dart';
import '../../domain/chat_send_policy.dart';
import '../chat_providers.dart';

/// Kursor sahifalash va yuborish holati.
class ChatUiState {
  const ChatUiState({
    this.initialLoading = true,
    this.loadingOlder = false,
    this.hasMore = true,
    this.loadError,
    this.rejection,
    this.sendWhenStopped = true,
    this.peerTyping = false,
  });

  /// Birinchi sahifa yuklanmoqda (skeleton).
  final bool initialLoading;

  /// `Load earlier messages` bosildi.
  final bool loadingOlder;

  /// `meta.has_more`.
  final bool hasMore;

  /// Sahifa yuklashda xato — `ErrorState` + `Retry`.
  final ApiError? loadError;

  /// Oxirgi yuborish urinishi rad etildi (matn uzun, fayl katta, …).
  final ChatSendRejection? rejection;

  /// M141 2-band: `Send when stopped` — default yoqilgan.
  final bool sendWhenStopped;

  /// #B-26: suhbatdosh yozmoqda — ro'yxat oxirida `•••` pufakchasi.
  final bool peerTyping;

  ChatUiState copyWith({
    bool? initialLoading,
    bool? loadingOlder,
    bool? hasMore,
    ApiError? loadError,
    ChatSendRejection? rejection,
    bool? sendWhenStopped,
    bool? peerTyping,
    bool clearError = false,
    bool clearRejection = false,
  }) => ChatUiState(
    initialLoading: initialLoading ?? this.initialLoading,
    loadingOlder: loadingOlder ?? this.loadingOlder,
    hasMore: hasMore ?? this.hasMore,
    loadError: clearError ? null : (loadError ?? this.loadError),
    rejection: clearRejection ? null : (rejection ?? this.rejection),
    sendWhenStopped: sendWhenStopped ?? this.sendWhenStopped,
    peerTyping: peerTyping ?? this.peerTyping,
  );
}

class ChatController extends Notifier<ChatUiState> {
  ChatRepository get _repository => ref.read(chatRepositoryProvider);

  /// Eng eski ko'rilgan xabar vaqti — keyingi `?before` kursori.
  DateTime? _cursor;

  @override
  ChatUiState build() {
    // `build()` tugamasdan `state` ga yozib bo'lmaydi (Riverpod 3) — birinchi
    // yuklashni mikrotaskga suramiz.
    unawaited(Future<void>.microtask(refresh));
    return const ChatUiState();
  }

  /// Eng yangi sahifa (pull-to-refresh va birinchi ochilish).
  Future<void> refresh() async {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(initialLoading: true, clearError: true);
    try {
      final ChatPage page = await _repository.loadPage();
      _cursor = page.nextBefore ?? page.messages.firstOrNull?.createdAt;
      if (ref.mounted) {
        state = state.copyWith(initialLoading: false, hasMore: page.hasMore, clearError: true);
      }
    } on ApiError catch (error) {
      // Oflayn bo'lsa lokal kesh baribir ko'rsatiladi — xato bannerga tushadi.
      if (ref.mounted) {
        state = state.copyWith(initialLoading: false, loadError: error);
      }
    }
  }

  /// Kursor sahifalash: eskiroq xabarlar.
  Future<void> loadOlder() async {
    if (state.loadingOlder || !state.hasMore) {
      return;
    }
    state = state.copyWith(loadingOlder: true, clearError: true);
    try {
      final ChatPage page = await _repository.loadPage(before: _cursor);
      _cursor = page.nextBefore ?? page.messages.firstOrNull?.createdAt ?? _cursor;
      if (ref.mounted) {
        state = state.copyWith(loadingOlder: false, hasMore: page.hasMore);
      }
    } on ApiError catch (error) {
      if (ref.mounted) {
        state = state.copyWith(loadingOlder: false, loadError: error);
      }
    }
  }

  /// M138: darhol navbatga tushadi, UI `Queued` ko'rsatadi.
  Future<void> send(ChatDraft draft, {int? fileSizeBytes}) async {
    state = state.copyWith(clearRejection: true);
    try {
      await _repository.send(draft, fileSizeBytes: fileSizeBytes);
    } on ChatSendBlockedException catch (blocked) {
      if (ref.mounted) {
        state = state.copyWith(rejection: blocked.reason);
      }
    }
  }

  Future<void> sendText(String text) => send(ChatDraft.text(text));

  /// M138/M141: `Retry` yoki `Send when stopped` bosilganda.
  Future<void> retry(String clientId) => _repository.retry(clientId);

  /// M141 2-band toggle'i.
  void setSendWhenStopped({required bool value}) => state = state.copyWith(sendWhenStopped: value);

  /// Ekran ochilganda ko'ringan o'qilmagan kiruvchi xabarlar.
  Future<void> markVisibleRead(List<ChatMessage> messages) async {
    for (final ChatMessage message in messages) {
      if (!message.isMine && message.status != ChatMessageStatus.read) {
        await _repository.markRead(message.id);
      }
    }
  }

  /// #B-26: WS `chat.typing` hodisasi (M11-x) — hozircha faqat UI holati.
  void setPeerTyping({required bool value}) => state = state.copyWith(peerTyping: value);

  void clearRejection() => state = state.copyWith(clearRejection: true);
}

final NotifierProvider<ChatController, ChatUiState> chatControllerProvider =
    NotifierProvider<ChatController, ChatUiState>(ChatController.new);
