@Timeout(Duration(seconds: 60))
/// `M-42` repozitoriy testlari: M138 oflayn navbat, M139 fayl oqimi,
/// M141 `409 DRIVING_MODE_BLOCKED` va `DR` dan chiqqanda avtomatik yuborish,
/// §14 kursor sahifalash.
library;

import 'dart:async';

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/error/api_error.dart';
import 'package:eld_mobile/core/error/api_error_code.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/chat/data/chat_local_data_source.dart';
import 'package:eld_mobile/features/chat/data/chat_remote_data_source.dart';
import 'package:eld_mobile/features/chat/data/chat_repository_impl.dart';
import 'package:eld_mobile/features/chat/data/driving_mode_source_impl.dart';
import 'package:eld_mobile/features/chat/domain/chat_message.dart';
import 'package:eld_mobile/features/chat/domain/chat_ports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../../core/helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  const String driverId = 'drv-1';

  late AppDatabase db;
  late TimeSource time;
  late _FakeRemote remote;
  late _FakeUploader uploader;
  late InMemoryDrivingModeSource driving;
  late ChatRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
    remote = _FakeRemote();
    uploader = _FakeUploader();
    driving = InMemoryDrivingModeSource();
    repository = ChatRepositoryImpl(
      local: ChatLocalDataSource(
        dao: db.chatDao,
        outbox: OutboxRepository(db: db, time: time),
        currentDriverId: driverId,
      ),
      remote: remote,
      uploader: uploader,
      driving: driving,
      time: time,
      driverId: driverId,
    );
  });

  tearDown(() async {
    await repository.dispose();
    await driving.dispose();
    await db.close();
    await time.dispose();
  });

  Future<List<ChatMessage>> messages() => db.chatDao
      .watchMessages(limit: 500)
      .first
      .then(
        (List<ChatMessageRow> rows) => ChatLocalDataSource(
          dao: db.chatDao,
          outbox: OutboxRepository(db: db, time: time),
          currentDriverId: driverId,
        ).toDomainList(rows),
      );

  Future<List<OutboxItemRow>> outboxRows() =>
      db.select(db.outboxItems).get().then((List<OutboxItemRow> rows) => rows);

  group('M138 oflayn navbat', () {
    test('yuborilgan xabar darhol outbox + `queued` qatoriga tushadi', () async {
      remote.failWith = const ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');

      await repository.send(const ChatDraft.text('hello'));
      await pumpEventQueue();

      final List<OutboxItemRow> queue = await outboxRows();
      expect(queue.length, 1);
      expect(queue.single.kind, OutboxKind.chat.wire);
      expect(queue.single.payload, contains('"client_id"'));

      final List<ChatMessage> all = await messages();
      expect(all.single.status, ChatMessageStatus.queued);
      expect(all.single.text, 'hello');
    });

    test('onlayn: POST muvaffaqiyatli — `sent` ga o\'tadi, dublikat yo\'q', () async {
      await repository.send(const ChatDraft.text('hi'));
      await pumpEventQueue();

      final List<ChatMessage> all = await messages();
      expect(all.length, 1);
      expect(all.single.status, ChatMessageStatus.sent);
      expect(remote.sent.single.text, 'hi');
    });

    test('rad etilgan (4xx) xabar `failed` bo\'ladi va yo\'qolmaydi', () async {
      remote.failWith = const ApiError(
        code: ApiErrorCode.validationError,
        message: 'bad',
        statusCode: 422,
      );

      await repository.send(const ChatDraft.text('hi'));
      await pumpEventQueue();

      final List<ChatMessage> all = await messages();
      expect(all.single.status, ChatMessageStatus.failed);
    });
  });

  group('M141 haydash rejimi', () {
    test('mijoz tomonida DR — yuborish umuman boshlanmaydi', () async {
      driving.set(isDriving: true);
      await pumpEventQueue();

      await expectLater(
        repository.send(const ChatDraft.text('hi')),
        throwsA(isA<ChatSendBlockedException>()),
      );
      expect(await outboxRows(), isEmpty);
      expect(remote.sent, isEmpty);
    });

    test(
      'server 409 — xabar saqlanadi, `blocked` bo\'ladi, lokal status DR ga tenglashadi',
      () async {
        remote.failWith = const ApiError(
          code: ApiErrorCode.drivingModeBlocked,
          message: 'driving',
          statusCode: 409,
        );

        await repository.send(const ChatDraft.text('hi'));
        await pumpEventQueue();

        final List<ChatMessage> all = await messages();
        expect(all.single.status, ChatMessageStatus.blocked);
        expect(driving.isDriving, isTrue);
        expect(await outboxRows(), hasLength(1));
      },
    );

    test('DR dan chiqqanda bloklangan xabar avtomatik qayta yuboriladi', () async {
      remote.failWith = const ApiError(
        code: ApiErrorCode.drivingModeBlocked,
        message: 'driving',
        statusCode: 409,
      );
      await repository.send(const ChatDraft.text('hi'));
      await pumpEventQueue();
      expect((await messages()).single.status, ChatMessageStatus.blocked);

      remote.failWith = null;
      driving.set(isDriving: false);
      await pumpEventQueue();

      expect((await messages()).single.status, ChatMessageStatus.sent);
      expect(remote.sent.single.text, 'hi');
    });
  });

  group('M139 fayl xabari', () {
    test('avval fayl yuklanadi, keyin `file_key` bilan xabar ketadi', () async {
      await repository.send(const ChatDraft.image(path: '/tmp/a.jpg'), fileSizeBytes: 1024);
      await pumpEventQueue();

      expect(uploader.enqueued.single, '/tmp/a.jpg');
      expect(remote.sent, isEmpty, reason: 'fayl kaliti hali yo\'q');

      uploader.complete('file-key-1');
      await pumpEventQueue();

      expect(remote.lastFileKey, 'file-key-1');
      expect((await messages()).single.status, ChatMessageStatus.sent);
    });

    test('yuklash yiqilsa xabar `failed` bo\'ladi', () async {
      await repository.send(const ChatDraft.file(path: '/tmp/a.pdf'), fileSizeBytes: 10);
      await pumpEventQueue();

      uploader.fail();
      await pumpEventQueue();

      expect((await messages()).single.status, ChatMessageStatus.failed);
      expect(remote.sent, isEmpty);
    });
  });

  group('§14 kursor sahifalash', () {
    test('`before` kursori serverga uzatiladi va natija keshga yoziladi', () async {
      remote.page = ChatPage(
        messages: <ChatMessage>[
          ChatMessage(
            id: 'srv-1',
            kind: ChatMessageKind.text,
            side: ChatSenderSide.office,
            status: ChatMessageStatus.delivered,
            createdAt: t0.subtract(const Duration(hours: 3)),
            text: 'from dispatch',
          ),
        ],
        hasMore: true,
        nextBefore: t0.subtract(const Duration(hours: 4)),
      );

      final ChatPage first = await repository.loadPage();
      expect(remote.lastBefore, isNull);
      expect(first.hasMore, isTrue);

      await repository.loadPage(before: first.nextBefore);
      expect(remote.lastBefore, t0.subtract(const Duration(hours: 4)));
      expect((await messages()).single.id, 'srv-1');
    });
  });

  group('o\'qildi belgisi', () {
    test('server xatosi UI ni yiqitmaydi', () async {
      remote.failMarkRead = true;
      await repository.markRead('srv-1');
      expect(remote.readIds, <String>['srv-1']);
    });
  });
}

class _FakeRemote implements ChatRemoteDataSource {
  final List<ChatDraft> sent = <ChatDraft>[];
  final List<String> readIds = <String>[];

  ApiError? failWith;
  bool failMarkRead = false;
  String? lastFileKey;
  DateTime? lastBefore;
  ChatPage page = const ChatPage(messages: <ChatMessage>[], hasMore: false);

  @override
  Future<ChatPage> fetchMessages({
    required String driverId,
    DateTime? before,
    int limit = 50,
  }) async {
    lastBefore = before;
    return page;
  }

  @override
  Future<ChatMessage> sendMessage({
    required String driverId,
    required String clientId,
    required ChatDraft draft,
    String? fileKey,
  }) async {
    if (failWith case final ApiError error) {
      throw error;
    }
    sent.add(draft);
    lastFileKey = fileKey;
    return ChatMessage(
      id: 'srv-$clientId',
      clientId: clientId,
      kind: draft.kind,
      side: ChatSenderSide.driver,
      status: ChatMessageStatus.sent,
      createdAt: DateTime.utc(2026, 9, 7, 12),
      text: draft.text,
      fileKey: fileKey,
      lat: draft.lat,
      lng: draft.lng,
    );
  }

  @override
  Future<void> markRead(String messageId) async {
    readIds.add(messageId);
    if (failMarkRead) {
      throw const ApiError(code: ApiErrorCode.clientNetwork, message: 'offline');
    }
  }
}

class _FakeUploader implements ChatFileUploader {
  final List<String> enqueued = <String>[];
  final StreamController<double> _progress = StreamController<double>.broadcast();
  Completer<String> _key = Completer<String>();

  void complete(String key) {
    _progress.add(1);
    if (!_key.isCompleted) {
      _key.complete(key);
    }
  }

  void fail() {
    if (!_key.isCompleted) {
      _key.completeError(StateError('upload failed'));
    }
  }

  @override
  Future<ChatUploadHandle> enqueue({
    required String localPath,
    required String contentType,
    required int sizeBytes,
  }) async {
    enqueued.add(localPath);
    _key = Completer<String>();
    return ChatUploadHandle(
      queueId: enqueued.length,
      progress: _progress.stream,
      fileKey: _key.future,
    );
  }
}
