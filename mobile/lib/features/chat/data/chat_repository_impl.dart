/// `ChatRepository` implementatsiyasi — oflayn navbat (M138), fayl yuklash
/// (M139/M149) va haydash rejimi bloki (M140/M141) shu yerda birlashadi.
///
/// **Qatlam:** `presentation` bu sinfni ko'rmaydi, faqat [ChatRepository] ni.
library;

import 'dart:async';

import '../../../core/error/api_error.dart';
import '../../../core/error/api_error_code.dart';
import '../../../core/time/time_source.dart';
import '../domain/chat_message.dart';
import '../domain/chat_ports.dart';
import '../domain/chat_repository.dart';
import '../domain/chat_send_policy.dart';
import 'chat_local_data_source.dart';
import 'chat_remote_data_source.dart';

/// Yuborish qoidasi rad etganda ko'tariladi (`presentation` uni matnga o'giradi).
class ChatSendBlockedException implements Exception {
  const ChatSendBlockedException(this.reason);

  final ChatSendRejection reason;

  @override
  String toString() => 'ChatSendBlockedException(${reason.name})';
}

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this._local,
    required this._remote,
    required this._uploader,
    required this._driving,
    required this._time,
    required this._driverId,
  }) {
    // M141 3-band: `DR` dan chiqqanda bloklangan xabarlar avtomatik ketadi.
    _drivingSub = _driving.watch().listen((bool isDriving) {
      final bool was = _wasDriving;
      _wasDriving = isDriving;
      if (was && !isDriving) {
        unawaited(resendBlocked());
      }
    });
  }

  final ChatLocalDataSource _local;
  final ChatRemoteDataSource _remote;
  final ChatFileUploader _uploader;
  final DrivingModeSource _driving;
  final TimeSource _time;
  final String _driverId;

  /// M139: `client_id` → 0…1 yuklash progressi (faqat xotirada).
  final Map<String, double> _uploads = <String, double>{};
  final StreamController<void> _uploadsTick = StreamController<void>.broadcast();

  StreamSubscription<bool>? _drivingSub;
  bool _wasDriving = false;

  Future<void> dispose() async {
    await _drivingSub?.cancel();
    await _uploadsTick.close();
  }

  // --- o'qish -------------------------------------------------------------

  @override
  Stream<List<ChatMessage>> watchMessages() {
    // Kontroller obunachi bekor qilganda (`onCancel`) ichki obunalarni yopadi
    // va axlatga chiqadi; `onCancel` ichidan `close()` chaqirish rekursiyaga
    // olib keladi, shuning uchun lint bostiriladi.
    // ignore: close_sinks
    late StreamController<List<ChatMessage>> controller;
    StreamSubscription<List<ChatMessage>>? rows;
    StreamSubscription<void>? ticks;
    List<ChatMessage> latest = const <ChatMessage>[];

    void emit() {
      if (!controller.isClosed) {
        controller.add(_withProgress(latest));
      }
    }

    controller = StreamController<List<ChatMessage>>(
      onListen: () {
        rows = _local.watchMessages().listen((List<ChatMessage> value) {
          latest = value;
          emit();
        }, onError: controller.addError);
        ticks = _uploadsTick.stream.listen((void _) => emit());
      },
      onCancel: () async {
        await rows?.cancel();
        await ticks?.cancel();
      },
    );
    return controller.stream;
  }

  List<ChatMessage> _withProgress(List<ChatMessage> messages) {
    if (_uploads.isEmpty) {
      return messages;
    }
    return <ChatMessage>[
      for (final ChatMessage m in messages)
        if (_uploads[m.clientId] case final double p) m.copyWith(uploadProgress: p) else m,
    ];
  }

  @override
  Future<ChatPage> loadPage({DateTime? before, int limit = 50}) async {
    final ChatPage page = await _remote.fetchMessages(
      driverId: _driverId,
      before: before,
      limit: limit,
    );
    for (final ChatMessage message in page.messages) {
      await _local.upsert(message);
    }
    return page;
  }

  @override
  Stream<bool> watchDrivingMode() => _driving.watch();

  @override
  Stream<int> watchQueuedCount() => _local.watchQueuedCount();

  // --- yozish -------------------------------------------------------------

  @override
  Future<void> send(ChatDraft draft, {int? fileSizeBytes}) async {
    final ChatSendVerdict verdict = evaluateChatSend(
      draft: draft,
      isDriving: _driving.isDriving,
      fileSizeBytes: fileSizeBytes,
    );
    if (!verdict.isAllowed) {
      throw ChatSendBlockedException(verdict.rejection!);
    }

    final DateTime now = _time.now();
    final String? path = draft.localFilePath;
    if (path == null) {
      final String clientId = await _local.enqueue(draft: draft, createdAt: now);
      unawaited(_push(clientId: clientId, draft: draft));
      return;
    }

    // M139/M149: avval fayl navbatga, keyin xabar.
    final ChatUploadHandle handle = await _uploader.enqueue(
      localPath: path,
      contentType: _contentTypeOf(draft),
      sizeBytes: fileSizeBytes ?? 0,
    );
    final String clientId = await _local.enqueue(draft: draft, createdAt: now);
    _uploads[clientId] = 0;
    _uploadsTick.add(null);
    handle.progress.listen((double value) {
      _uploads[clientId] = value.clamp(0, 1);
      _uploadsTick.add(null);
    });
    unawaited(_awaitUpload(clientId: clientId, draft: draft, handle: handle));
  }

  Future<void> _awaitUpload({
    required String clientId,
    required ChatDraft draft,
    required ChatUploadHandle handle,
  }) async {
    try {
      final String key = await handle.fileKey;
      _uploads.remove(clientId);
      _uploadsTick.add(null);
      await _push(clientId: clientId, draft: draft, fileKey: key);
    } on Object {
      _uploads.remove(clientId);
      _uploadsTick.add(null);
      await _setStatus(clientId, ChatMessageStatus.failed);
    }
  }

  /// To'g'ridan-to'g'ri `POST`. Muvaffaqiyatsizlikda xabar **yo'qolmaydi** —
  /// `outbox` da qoladi va `SyncEngine` keyin uriniladi (M138).
  Future<void> _push({required String clientId, required ChatDraft draft, String? fileKey}) async {
    try {
      final ChatMessage sent = await _remote.sendMessage(
        driverId: _driverId,
        clientId: clientId,
        draft: draft,
        fileKey: fileKey,
      );
      // Server javobida `client_id` yo'q (`chat_dto.Message`) — uni o'zimiz
      // bog'laymiz, aks holda optimistik qator dublikat bo'lib qoladi.
      await _local.upsert(_linked(sent, clientId));
      await _local.ackOutbox(clientId);
    } on ApiError catch (error) {
      await _onPushError(clientId, error);
    }
  }

  Future<void> _onPushError(String clientId, ApiError error) async {
    if (error.code == ApiErrorCode.drivingModeBlocked) {
      // M141: lokal status darhol `DR` ga tenglashadi (server haqiqat).
      _driving.forceDriving();
      await _setStatus(clientId, ChatMessageStatus.blocked);
      return;
    }
    if (error.isOffline || error.isRetryable) {
      // `queued` bo'lib qoladi — outbox pushi qayta uradi.
      return;
    }
    await _setStatus(clientId, ChatMessageStatus.failed);
  }

  @override
  Future<void> retry(String clientId) async {
    final ChatMessage? message = await _find(clientId);
    if (message == null) {
      return;
    }
    await _local.setStatus(message, ChatMessageStatus.queued);
    await _push(clientId: clientId, draft: _draftOf(message), fileKey: message.fileKey);
  }

  @override
  Future<void> resendBlocked() async {
    final List<ChatMessage> all = await _local.watchMessages().first;
    for (final ChatMessage message in messagesToResendAfterDriving(all)) {
      await retry(message.clientId ?? message.id);
    }
  }

  @override
  Future<void> markRead(String messageId) async {
    try {
      await _remote.markRead(messageId);
    } on ApiError {
      // O'qildi belgisi kritik emas — keyingi `pull` da tiklanadi.
    }
  }

  // --- yordamchi ----------------------------------------------------------

  Future<ChatMessage?> _find(String clientId) async {
    final List<ChatMessage> all = await _local.watchMessages().first;
    for (final ChatMessage m in all) {
      if (m.clientId == clientId || m.id == clientId) {
        return m;
      }
    }
    return null;
  }

  Future<void> _setStatus(String clientId, ChatMessageStatus status) async {
    final ChatMessage? message = await _find(clientId);
    if (message != null) {
      await _local.setStatus(message, status);
    }
  }

  ChatMessage _linked(ChatMessage sent, String clientId) => ChatMessage(
    id: sent.id,
    clientId: clientId,
    kind: sent.kind,
    side: ChatSenderSide.driver,
    status: sent.status,
    createdAt: sent.createdAt,
    text: sent.text,
    fileKey: sent.fileKey,
    lat: sent.lat,
    lng: sent.lng,
  );

  ChatDraft _draftOf(ChatMessage message) => switch (message.kind) {
    ChatMessageKind.text => ChatDraft.text(message.text ?? ''),
    ChatMessageKind.location => ChatDraft.location(
      latitude: message.lat ?? 0,
      longitude: message.lng ?? 0,
    ),
    ChatMessageKind.image => ChatDraft.image(path: '', caption: message.text),
    ChatMessageKind.file => ChatDraft.file(path: '', caption: message.text),
  };

  static String _contentTypeOf(ChatDraft draft) =>
      draft.kind == ChatMessageKind.image ? 'image/jpeg' : 'application/octet-stream';
}
