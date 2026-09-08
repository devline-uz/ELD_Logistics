@Timeout(Duration(seconds: 60))
/// `M-42` domen testlari: yuborish qoidasi (§14, M140), M141 navbat tartibi,
/// kun ajratgichlari va `ChatDraft` fabrikalari.
library;

import 'package:eld_mobile/features/chat/domain/chat_message.dart';
import 'package:eld_mobile/features/chat/domain/chat_send_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('§14 yuborish qoidasi', () {
    test('oddiy matn ruxsat etiladi', () {
      expect(
        evaluateChatSend(draft: const ChatDraft.text('hi'), isDriving: false).isAllowed,
        isTrue,
      );
    });

    test('bo\'sh yoki faqat probel — emptyText', () {
      expect(
        evaluateChatSend(draft: const ChatDraft.text('   '), isDriving: false).rejection,
        ChatSendRejection.emptyText,
      );
    });

    test('2000 belgidan uzun — textTooLong', () {
      final String long = 'a' * (kChatTextMaxLength + 1);
      expect(
        evaluateChatSend(draft: ChatDraft.text(long), isDriving: false).rejection,
        ChatSendRejection.textTooLong,
      );
      expect(
        evaluateChatSend(
          draft: ChatDraft.text('a' * kChatTextMaxLength),
          isDriving: false,
        ).isAllowed,
        isTrue,
      );
    });

    test('M140: DR statusida har qanday xabar bloklanadi', () {
      expect(
        evaluateChatSend(draft: const ChatDraft.text('hi'), isDriving: true).rejection,
        ChatSendRejection.drivingMode,
      );
      expect(
        evaluateChatSend(
          draft: const ChatDraft.location(latitude: 1, longitude: 2),
          isDriving: true,
        ).rejection,
        ChatSendRejection.drivingMode,
      );
    });

    test('10 MB dan katta fayl — fileTooLarge', () {
      expect(
        evaluateChatSend(
          draft: const ChatDraft.file(path: '/tmp/a.pdf'),
          isDriving: false,
          fileSizeBytes: kChatFileMaxBytes + 1,
        ).rejection,
        ChatSendRejection.fileTooLarge,
      );
      expect(
        evaluateChatSend(
          draft: const ChatDraft.image(path: '/tmp/a.jpg'),
          isDriving: false,
          fileSizeBytes: kChatFileMaxBytes,
        ).isAllowed,
        isTrue,
      );
    });

    test('§14.3: noto\'g\'ri koordinata — invalidLocation', () {
      expect(
        evaluateChatSend(
          draft: const ChatDraft.location(latitude: 91, longitude: 0),
          isDriving: false,
        ).rejection,
        ChatSendRejection.invalidLocation,
      );
      expect(
        evaluateChatSend(
          draft: const ChatDraft.location(latitude: 41.31, longitude: 69.24),
          isDriving: false,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('M141 qayta yuborish navbati', () {
    test('faqat o\'z bloklangan xabarlarim, createdAt tartibida', () {
      final List<ChatMessage> all = <ChatMessage>[
        _m('c', DateTime.utc(2026, 9, 7, 12), status: ChatMessageStatus.blocked),
        _m('a', DateTime.utc(2026, 9, 7, 10), status: ChatMessageStatus.blocked),
        _m('q', DateTime.utc(2026, 9, 7, 11)),
        _m(
          'in',
          DateTime.utc(2026, 9, 7, 9),
          status: ChatMessageStatus.blocked,
          side: ChatSenderSide.office,
        ),
      ];
      expect(messagesToResendAfterDriving(all).map((ChatMessage m) => m.id), <String>['a', 'c']);
    });

    test('bloklangan xabar yo\'q — bo\'sh ro\'yxat', () {
      expect(messagesToResendAfterDriving(<ChatMessage>[_m('q', DateTime.utc(2026))]), isEmpty);
    });
  });

  group('sana ajratgichlari', () {
    test('bir kundagi xabarlar bitta bo\'limda', () {
      final List<ChatDaySection> sections = groupChatByDay(<ChatMessage>[
        _m('a', DateTime.utc(2026, 9, 6, 22)),
        _m('b', DateTime.utc(2026, 9, 7, 8)),
        _m('c', DateTime.utc(2026, 9, 7, 9)),
      ], dayOf: (DateTime d) => DateTime.utc(d.year, d.month, d.day));
      expect(sections.length, 2);
      expect(sections.last.messages.map((ChatMessage m) => m.id), <String>['b', 'c']);
    });
  });

  group('ChatDraft fabrikalari', () {
    test('turlar va wire qiymatlari', () {
      expect(const ChatDraft.text('x').kind, ChatMessageKind.text);
      expect(const ChatDraft.image(path: '/a.jpg').localFilePath, '/a.jpg');
      expect(const ChatDraft.file(path: '/a.pdf').kind, ChatMessageKind.file);
      expect(const ChatDraft.location(latitude: 1, longitude: 2).lat, 1);
      expect(ChatMessageStatus.queued.wire, 'queued');
      expect(ChatMessageStatus.blocked.needsAttention, isTrue);
      expect(ChatMessageStatus.failed.needsAttention, isTrue);
      expect(ChatMessageStatus.sent.needsAttention, isFalse);
    });
  });
}

ChatMessage _m(
  String id,
  DateTime createdAt, {
  ChatMessageStatus status = ChatMessageStatus.queued,
  ChatSenderSide side = ChatSenderSide.driver,
}) => ChatMessage(
  id: id,
  clientId: id,
  kind: ChatMessageKind.text,
  side: side,
  status: status,
  createdAt: createdAt,
  text: 'body-$id',
);
