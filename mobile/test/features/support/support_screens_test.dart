@Timeout(Duration(seconds: 60))
/// **M-49 / M-50 / M-51** widget testlari.
///
/// M-50: 4 holat (yuklanish · bo'sh · xato · to'la) + M115 holat matnlari.
/// M-49: `Subject` majburiy, oflayn navbat, muvaffaqiyatda orqaga qaytish.
/// M-51: tiket sarlavhasi + xabarlar, javob yuborish, bo'sh tasma.
library;

import 'dart:async';

import 'package:eld_mobile/core/error/api_error_messages.dart';
import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/profile/domain/submit_outcome.dart';
import 'package:eld_mobile/features/support/domain/support_ticket.dart';
import 'package:eld_mobile/features/support/presentation/screens/support_form_screen.dart';
import 'package:eld_mobile/features/support/presentation/screens/support_list_screen.dart';
import 'package:eld_mobile/features/support/presentation/screens/ticket_thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/m11_test_harness.dart';

class _GatedSupportRepository extends FakeSupportRepository {
  _GatedSupportRepository(this.gate);

  final Completer<void> gate;

  @override
  Future<List<SupportTicket>> list() async {
    await gate.future;
    return super.list();
  }
}

void main() {
  group('M-50 Support & Helpdesk', () {
    testWidgets('yuklanish: LoadingSkeleton', (WidgetTester tester) async {
      final Completer<void> gate = Completer<void>();
      await pumpM11Screen(
        tester,
        const SupportListScreen(),
        overrides: m11Overrides(support: _GatedSupportRepository(gate)),
      );
      expect(find.byType(LoadingSkeleton), findsOneWidget);
      gate.complete();
      await settle(tester);
      expect(find.byType(LoadingSkeleton), findsNothing);
    });

    testWidgets('bo\'sh holat: dizayn matnlari + Add Ticket', (WidgetTester tester) async {
      await pumpM11Screen(tester, const SupportListScreen(), overrides: m11Overrides());

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text(l10n.supportEmptyTitle), findsOneWidget);
      expect(find.text(l10n.supportEmptyMessage), findsOneWidget);
      expect(appButton(l10n.supportAddTicket), findsOneWidget);
    });

    testWidgets('xato holati: ErrorState + Retry', (WidgetTester tester) async {
      final FakeSupportRepository repo = FakeSupportRepository()..listError = kOfflineError;
      await pumpM11Screen(
        tester,
        const SupportListScreen(),
        overrides: m11Overrides(support: repo),
      );

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text(localizedApiError(l10n, kOfflineError)), findsOneWidget);

      repo
        ..listError = null
        ..tickets = <SupportTicket>[buildTestTicket()];
      await tester.tap(find.text(l10n.commonRetry));
      await settle(tester);
      expect(find.byType(ErrorState), findsNothing);
      expect(find.text(l10n.supportTicketNumber('122546')), findsOneWidget);
    });

    testWidgets('to\'la holat: M115 holat matnlari va sana formati', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const SupportListScreen(),
        overrides: m11Overrides(
          support: FakeSupportRepository(
            tickets: <SupportTicket>[
              buildTestTicket(status: TicketStatus.newly),
              buildTestTicket(id: 'tkt-2', status: TicketStatus.inProgress, subject: 'BLE drops'),
              buildTestTicket(id: 'tkt-3', status: TicketStatus.resolved, subject: 'Sign fails'),
            ],
          ),
        ),
      );

      expect(find.text(l10n.supportStatusNew), findsOneWidget);
      expect(find.text(l10n.supportStatusInProgress), findsOneWidget);
      expect(find.text(l10n.supportStatusResolved), findsOneWidget);
      // M115: defisli `In-Progress` rad etilgan.
      expect(find.textContaining('In-Progress'), findsNothing);
      // M91: `MMM d, yyyy · hh:mm a` (Figma dagi `12/02/2024 11:05 am` rad etiladi).
      expect(find.text('May 28, 2025 · 02:24 PM'), findsNWidgets(3));
      // Figma: `Contact On: …` kursiv qatori.
      expect(find.text(l10n.supportContactOnValue(l10n.supportChannelEmail)), findsNWidgets(3));
    });
  });

  group('M-49 Add Ticket', () {
    testWidgets('boshlang\'ich holat: Contact On chiplari + maydonlar', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(tester, const SupportFormScreen(), overrides: m11Overrides());

      // Figma `1179:7028`: radio tugmalar + `Subject` / `Ticket description`
      // + `Cancel` / `Confirm`.
      expect(find.text(l10n.supportChannelEmail), findsOneWidget);
      expect(find.text(l10n.supportChannelPhone), findsOneWidget);
      expect(find.text(l10n.supportSubject), findsOneWidget);
      expect(find.text(l10n.supportDescription), findsOneWidget);
      expect(appButton(l10n.supportConfirm), findsOneWidget);
      expect(appButton(l10n.commonCancel), findsOneWidget);
    });

    testWidgets('Subject bo\'sh bo\'lsa validatsiya xatosi, so\'rov ketmaydi', (
      WidgetTester tester,
    ) async {
      final FakeSupportRepository repo = FakeSupportRepository();
      await pumpM11Screen(
        tester,
        const SupportFormScreen(),
        overrides: m11Overrides(support: repo),
      );

      await tester.tap(find.text(l10n.supportConfirm));
      await settle(tester);
      expect(find.text(l10n.supportSubjectRequired), findsOneWidget);
      expect(repo.created, isEmpty);
    });

    testWidgets('to\'ldirilgan forma `POST /support-tickets` ga ketadi', (
      WidgetTester tester,
    ) async {
      final FakeSupportRepository repo = FakeSupportRepository();
      await pumpM11Screen(
        tester,
        const SupportFormScreen(),
        overrides: m11Overrides(support: repo),
      );

      await tester.tap(find.text(l10n.supportChannelPhone));
      await settle(tester);
      await tester.enterText(find.byType(TextField).first, 'Grid stale');
      await tester.enterText(find.byType(TextField).last, 'Steps to reproduce');
      await settle(tester);
      await tester.tap(find.text(l10n.supportConfirm));
      await settle(tester);

      expect(repo.created, hasLength(1));
      expect(repo.created.single.subject, 'Grid stale');
      expect(repo.created.single.description, 'Steps to reproduce');
      expect(repo.created.single.contactOn, ContactChannel.phone);
      // M164: `company_id` tanaga qo'yilmaydi.
      expect(repo.created.single.toPayload().containsKey('company_id'), isFalse);
    });

    testWidgets('oflayn: navbatga qo\'yildi xabari', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const SupportFormScreen(),
        overrides: m11Overrides(
          support: FakeSupportRepository(createOutcome: SubmitOutcome.queued),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Offline ticket');
      await settle(tester);
      await tester.tap(find.text(l10n.supportConfirm));
      await settle(tester);
      expect(find.text(l10n.supportQueued), findsOneWidget);
    });

    testWidgets('server xatosi forma ichida ko\'rsatiladi', (WidgetTester tester) async {
      final FakeSupportRepository repo = FakeSupportRepository()..createError = kServerError;
      await pumpM11Screen(
        tester,
        const SupportFormScreen(),
        overrides: m11Overrides(support: repo),
      );

      await tester.enterText(find.byType(TextField).first, 'Broken');
      await settle(tester);
      await tester.tap(find.text(l10n.supportConfirm));
      await settle(tester);
      expect(find.text(localizedApiError(l10n, kServerError)), findsOneWidget);
    });
  });

  group('M-51 Ticket thread', () {
    testWidgets('yuklanish → to\'la: sarlavha, holat badge va xabarlar', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const TicketThreadScreen(ticketId: 'tkt-122546'),
        overrides: m11Overrides(
          support: FakeSupportRepository(
            tickets: <SupportTicket>[buildTestTicket(status: TicketStatus.inProgress)],
            messages: <SupportMessage>[
              SupportMessage(
                id: 'm1',
                text: 'We are looking into it.',
                senderName: 'Support',
                createdAt: DateTime.utc(2025, 5, 28, 15),
              ),
            ],
          ),
        ),
      );

      // Figma `1158:462`: raqam app bar'da ham, kartada ham ko'rinadi.
      expect(find.text(l10n.supportTicketHeading('122546')), findsNWidgets(2));
      expect(find.text(l10n.supportStatusInProgress), findsOneWidget);
      expect(find.text('We are looking into it.'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('bo\'sh tasma: `No messages` holati', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const TicketThreadScreen(ticketId: 'tkt-1'),
        overrides: m11Overrides(support: FakeSupportRepository()),
      );
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text(l10n.supportNoMessagesTitle), findsOneWidget);
    });

    testWidgets('xato holati: ErrorState + Retry', (WidgetTester tester) async {
      final FakeSupportRepository repo = FakeSupportRepository()..threadError = kOfflineError;
      await pumpM11Screen(
        tester,
        const TicketThreadScreen(ticketId: 'tkt-1'),
        overrides: m11Overrides(support: repo),
      );

      expect(find.byType(ErrorState), findsOneWidget);
      repo.threadError = null;
      await tester.tap(find.text(l10n.commonRetry));
      await settle(tester);
      expect(find.byType(ErrorState), findsNothing);
    });

    testWidgets('javob yuboriladi va maydon tozalanadi', (WidgetTester tester) async {
      final FakeSupportRepository repo = FakeSupportRepository();
      await pumpM11Screen(
        tester,
        const TicketThreadScreen(ticketId: 'tkt-1'),
        overrides: m11Overrides(support: repo),
      );

      await tester.enterText(find.byType(TextField), 'Any update?');
      await settle(tester);
      await tester.tap(find.text(l10n.supportSend));
      await settle(tester);

      expect(repo.calls, contains('reply:tkt-1:Any update?'));
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, isEmpty);
    });

    testWidgets('oflayn javob: navbat xabari', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const TicketThreadScreen(ticketId: 'tkt-1'),
        overrides: m11Overrides(support: FakeSupportRepository(replyOutcome: SubmitOutcome.queued)),
      );

      await tester.enterText(find.byType(TextField), 'Ping');
      await settle(tester);
      await tester.tap(find.text(l10n.supportSend));
      await settle(tester);
      expect(find.text(l10n.supportQueued), findsOneWidget);
    });

    testWidgets('haydovchi holatni o\'zgartira olmaydi (M115)', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const TicketThreadScreen(ticketId: 'tkt-1'),
        overrides: m11Overrides(
          support: FakeSupportRepository(
            tickets: <SupportTicket>[buildTestTicket(status: TicketStatus.resolved)],
          ),
        ),
      );
      final StatusBadge badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(badge.label, l10n.supportStatusResolved);
      // Badge — bosilmaydigan element (`InkWell`/`GestureDetector` ichida emas).
      expect(
        find.ancestor(of: find.byType(StatusBadge), matching: find.byType(InkWell)),
        findsNothing,
      );
    });
  });
}
