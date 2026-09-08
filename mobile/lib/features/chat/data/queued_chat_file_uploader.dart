/// M139/M149: chat biriktirmasi `files_queue` orqali yuklanadi.
///
/// Bu sinf **faqat navbatni** boshqaradi: yozuvni qo'yadi va `state` o'zgarishini
/// kuzatadi. Haqiqiy `presign` → `PUT` ishini umumiy fayl ishchisi bajaradi.
/// TODO(CORE): `core/files/file_upload_worker.dart` hali yo'q — u paydo
/// bo'lgach shu port o'zgarmaydi (holat `files_queue` da yozilaveradi).
library;

import 'dart:async';

import 'package:drift/drift.dart' show Value;

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/dvir_dao.dart';
import '../domain/chat_ports.dart';

/// `files_queue.kind` — §16 jadvalidagi `chat`.
const String kChatFileKind = 'chat';

class QueuedChatFileUploader implements ChatFileUploader {
  QueuedChatFileUploader({required this._dao, required this._now});

  final DvirDao _dao;
  final DateTime Function() _now;

  @override
  Future<ChatUploadHandle> enqueue({
    required String localPath,
    required String contentType,
    required int sizeBytes,
  }) async {
    final int id = await _dao.enqueueFile(
      FilesQueueCompanion.insert(
        localPath: localPath,
        kind: kChatFileKind,
        contentType: contentType,
        sizeBytes: sizeBytes,
        createdAt: _now(),
        state: const Value<String>('pending'),
      ),
    );

    final Completer<String> key = Completer<String>();
    final StreamController<double> progress = StreamController<double>.broadcast();
    StreamSubscription<List<FileQueueRow>>? sub;

    Future<void> finish() async {
      await sub?.cancel();
      await progress.close();
    }

    sub = _dao.watchPendingFiles().listen((List<FileQueueRow> rows) {
      final FileQueueRow? row = _rowById(rows, id);
      if (row == null) {
        // Navbatdan chiqdi = yuklandi (`watchPendingFiles` faqat tugamaganini beradi).
        unawaited(_complete(id: id, key: key, progress: progress, finish: finish));
        return;
      }
      progress.add(_progressOf(row.state));
      if (row.state == 'failed') {
        if (!key.isCompleted) {
          key.completeError(const ChatFileUploadException());
        }
        unawaited(finish());
      }
    });

    return ChatUploadHandle(queueId: id, progress: progress.stream, fileKey: key.future);
  }

  Future<void> _complete({
    required int id,
    required Completer<String> key,
    required StreamController<double> progress,
    required Future<void> Function() finish,
  }) async {
    if (key.isCompleted) {
      return;
    }
    final List<FileQueueRow> uploaded = await _dao.uploadedBefore(
      _now().add(const Duration(days: 1)),
    );
    final FileQueueRow? row = _rowById(uploaded, id);
    final String? presigned = row?.presignedKey;
    if (!progress.isClosed) {
      progress.add(1);
    }
    if (presigned == null) {
      key.completeError(const ChatFileUploadException());
    } else {
      key.complete(presigned);
    }
    await finish();
  }

  static FileQueueRow? _rowById(List<FileQueueRow> rows, int id) {
    for (final FileQueueRow row in rows) {
      if (row.id == id) {
        return row;
      }
    }
    return null;
  }

  static double _progressOf(String state) => switch (state) {
    'uploading' => 0.5,
    'uploaded' => 1,
    _ => 0,
  };
}

/// Fayl yuklanmadi — xabar `failed` ga o'tadi va `Retry` ko'rsatiladi.
class ChatFileUploadException implements Exception {
  const ChatFileUploadException();

  @override
  String toString() => 'ChatFileUploadException';
}
