@Timeout(Duration(seconds: 60))
/// `M-42 Chat` widget testi: yuklanish · bo'sh · xato · to'la,
/// M140 (haydash rejimida kiritish bloklanadi) va M138 navbat banneri.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/chat/domain/chat_message.dart';
import 'package:eld_mobile/features/chat/presentation/chat_providers.dart';
import 'package:eld_mobile/features/chat/presentation/controllers/chat_controller.dart';
import 'package:eld_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:eld_mobile/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_harness.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  late FakeChatRepository repository;

  setUp(() => repository = FakeChatRepository());

  tearDown(() => repository.dispose());

  Future<void> pump(WidgetTester tester) async {
    // M-42 telefon profili (393×852) — `DeviceProfile.phone`.
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[chatRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChatScreen(),
        ),
      ),
    );
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('yuklanish: skeleton', (WidgetTester tester) async {
    repository.hold = true;
    await pump(tester);

    expect(find.byType(LoadingSkeleton), findsOneWidget);
    repository.release();
    await unmount(tester);
  });

  testWidgets('bo\'sh holat: M118 matnlari, demo xabarlar yo\'q', (WidgetTester tester) async {
    await pump(tester);

    expect(find.text('No messages yet'), findsOneWidget);
    expect(find.text('Messages from your dispatcher will appear here.'), findsOneWidget);
    expect(find.textContaining('flora app'), findsNothing);
    await unmount(tester);
  });

  testWidgets('xato holati: ErrorState + Retry', (WidgetTester tester) async {
    repository.failLoad = true;
    await pump(tester);

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('to\'la holat: pufakchalar va sana ajratgichi', (WidgetTester tester) async {
    repository.emit(<ChatMessage>[
      _m('m1', t0.subtract(const Duration(hours: 2)), side: ChatSenderSide.office),
      _m('m2', t0.subtract(const Duration(hours: 1))),
    ]);
    await pump(tester);

    // ignore: avoid_print
    expect(find.text('body-m1'), findsOneWidget);
    expect(find.text('body-m2'), findsOneWidget);
    expect(find.text('Mon, Sep 7'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('M140: DR da kiritish qatori o\'chirilgan', (WidgetTester tester) async {
    repository.setDriving(isDriving: true);
    await pump(tester);

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
    expect(find.text('Messaging is disabled while driving.'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('M140: DR emas — kiritish faol', (WidgetTester tester) async {
    await pump(tester);

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isTrue);
    await unmount(tester);
  });

  testWidgets('#B-26: pufakcha r16 + «dum» r4, maks eni 75 %', (WidgetTester tester) async {
    repository.emit(<ChatMessage>[_m('mine', t0), _m('theirs', t0, side: ChatSenderSide.office)]);
    await pump(tester);

    final Finder bubbles = find.descendant(
      of: find.byType(ChatBubble),
      matching: find.byType(DecoratedBox),
    );
    final BoxDecoration mine =
        tester.widget<DecoratedBox>(bubbles.first).decoration as BoxDecoration;
    expect(mine.borderRadius, chatBubbleRadius(mine: true));
    expect(mine.borderRadius, isNot(isA<StadiumBorder>()));

    // Maks eni: ro'yxat kengligining 75 % idan oshmaydi.
    final double listWidth = tester.getSize(find.byType(ChatBubble).first).width;
    for (final Element element in find.byType(ChatBubble).evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).width, lessThanOrEqualTo(listWidth));
    }
    await unmount(tester);
  });

  testWidgets('#B-26: navbatdagi xabarda soat emas, ✓ ko\'rsatiladi', (WidgetTester tester) async {
    repository.emit(<ChatMessage>[_m('q', t0, status: ChatMessageStatus.queued)]);
    await pump(tester);

    expect(find.byIcon(Icons.schedule), findsNothing);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('#B-26: app bar da `<` bor, amal guruhi yo\'q', (WidgetTester tester) async {
    await pump(tester);

    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(AppBarAction), findsNothing);
    await unmount(tester);
  });

  testWidgets('#B-26: typing indikator pufakchasi', (WidgetTester tester) async {
    repository.emit(<ChatMessage>[_m('m1', t0)]);
    await pump(tester);
    expect(find.byType(ChatTypingBubble), findsNothing);

    final BuildContext context = tester.element(find.byType(ChatScreen));
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(chatControllerProvider.notifier).setPeerTyping(value: true);
    await tester.pump();
    expect(find.byType(ChatTypingBubble), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('M138: navbatdagi xabarlar banneri', (WidgetTester tester) async {
    repository.setQueued(2);
    repository.emit(<ChatMessage>[_m('m1', t0)]);
    await pump(tester);

    expect(find.byType(BannerStrip), findsOneWidget);
    await unmount(tester);
  });
}

ChatMessage _m(
  String id,
  DateTime createdAt, {
  ChatSenderSide side = ChatSenderSide.driver,
  ChatMessageStatus status = ChatMessageStatus.sent,
}) => ChatMessage(
  id: id,
  clientId: id,
  kind: ChatMessageKind.text,
  side: side,
  status: status,
  createdAt: createdAt,
  text: 'body-$id',
);
