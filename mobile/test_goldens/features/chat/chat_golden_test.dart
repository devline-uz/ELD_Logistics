@Timeout(Duration(seconds: 60))
/// `M-42 Chat` goldenlari — light/dark × phone/tablet.
///
/// Figma: `1118-114` (light) / `2665-34989` (dark). M118 bo'yicha dizayndagi
/// demo xabarlar olib tashlangan — bu yerda neytral test ma'lumoti.
library;

import 'package:eld_mobile/features/chat/domain/chat_message.dart';
import 'package:eld_mobile/features/chat/presentation/chat_providers.dart';
import 'package:eld_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/chat/chat_test_harness.dart';
import '../golden_screen_host.dart';

final DateTime _t0 = DateTime.utc(2026, 9, 7, 12);

ChatMessage _m(
  String id,
  Duration ago, {
  ChatSenderSide side = ChatSenderSide.driver,
  ChatMessageStatus status = ChatMessageStatus.read,
  String? text,
}) => ChatMessage(
  id: id,
  clientId: id,
  kind: ChatMessageKind.text,
  side: side,
  status: status,
  createdAt: _t0.subtract(ago),
  text: text ?? 'Message $id',
);

List<Override> _overrides({List<ChatMessage> messages = const <ChatMessage>[]}) {
  final FakeChatRepository repository = FakeChatRepository()..emit(messages);
  return <Override>[chatRepositoryProvider.overrideWithValue(repository)];
}

void main() {
  screenGoldenMatrix(
    'chat_thread',
    builder: () => const ChatScreen(),
    overrides: () => _overrides(
      messages: <ChatMessage>[
        _m('a', const Duration(hours: 3), side: ChatSenderSide.office),
        _m('b', const Duration(hours: 2)),
        _m('c', const Duration(minutes: 30), status: ChatMessageStatus.queued),
      ],
    ),
  );

  screenGoldenMatrix('chat_empty', builder: () => const ChatScreen(), overrides: _overrides);
}
