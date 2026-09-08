/// `M-42` testlari uchun umumiy soxta repozitoriy (widget + golden).
library;

import 'dart:async';

import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/features/chat/domain/chat_message.dart';
import 'package:eld_mobile/features/chat/domain/chat_repository.dart';

class FakeChatRepository implements ChatRepository {
  final StreamController<List<ChatMessage>> _messages =
      StreamController<List<ChatMessage>>.broadcast();
  final StreamController<bool> _driving = StreamController<bool>.broadcast();
  final StreamController<int> _queued = StreamController<int>.broadcast();
  final Completer<void> _gate = Completer<void>();

  List<ChatMessage> _latest = const <ChatMessage>[];
  bool _isDriving = false;
  int _queuedCount = 0;

  bool hold = false;
  bool failLoad = false;

  void emit(List<ChatMessage> messages) {
    _latest = messages;
    if (_messages.hasListener) {
      _messages.add(messages);
    }
  }

  void setDriving({required bool isDriving}) {
    _isDriving = isDriving;
    if (_driving.hasListener) {
      _driving.add(isDriving);
    }
  }

  void setQueued(int count) {
    _queuedCount = count;
    if (_queued.hasListener) {
      _queued.add(count);
    }
  }

  void release() {
    if (!_gate.isCompleted) {
      _gate.complete();
    }
  }

  void dispose() {
    release();
    unawaited(_messages.close());
    unawaited(_driving.close());
    unawaited(_queued.close());
  }

  @override
  Stream<List<ChatMessage>> watchMessages() async* {
    yield _latest;
    yield* _messages.stream;
  }

  @override
  Stream<bool> watchDrivingMode() async* {
    yield _isDriving;
    yield* _driving.stream;
  }

  @override
  Stream<int> watchQueuedCount() async* {
    yield _queuedCount;
    yield* _queued.stream;
  }

  @override
  Future<ChatPage> loadPage({DateTime? before, int limit = 50}) async {
    if (hold) {
      await _gate.future;
    }
    if (failLoad) {
      throw const ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');
    }
    return ChatPage(messages: _latest, hasMore: false);
  }

  @override
  Future<void> markRead(String messageId) async {}

  @override
  Future<void> resendBlocked() async {}

  @override
  Future<void> retry(String clientId) async {}

  @override
  Future<void> send(ChatDraft draft, {int? fileSizeBytes}) async {}
}
