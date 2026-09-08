@Timeout(Duration(seconds: 60))
/// `T-27 Contact Support (jadval)` · `T-28 Add Ticket (modal)` —
/// planshet ko'rinishlari (tz-mobile 1561–1562).
///
/// **A3:** planshet jadvali va modal telefon ekranlari bilan bir xil
/// `supportRepositoryProvider` / `ticketFormControllerProvider` dan
/// oziqlanadi — farq faqat `presentation` qatlamida.
library;

import 'package:eld_mobile/core/ui/ui.dart';
import 'package:eld_mobile/features/support/domain/support_ticket.dart';
import 'package:eld_mobile/features/support/presentation/screens/support_form_screen.dart';
import 'package:eld_mobile/features/support/presentation/screens/support_list_screen.dart';
import 'package:eld_mobile/features/support/presentation/widgets/support_modals.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/m11_test_harness.dart';
import '../shared/modal_host.dart';

List<SupportTicket> _tickets() => <SupportTicket>[
  buildTestTicket(),
  buildTestTicket(id: 'tkt-2', status: TicketStatus.inProgress, subject: 'BLE drops'),
];

void main() {
  group('T-27 Contact Support jadvali', () {
    testWidgets('planshetda ustun sarlavhalari bilan jadval', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const SupportListScreen(),
        overrides: m11Overrides(support: FakeSupportRepository(tickets: _tickets())),
        surface: kTabletSurface,
      );

      final SupportListBody body = tester.widget<SupportListBody>(find.byType(SupportListBody));
      expect(body.asTable, isTrue);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Ticket'), findsOneWidget);
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Created'), findsOneWidget);
    });

    testWidgets('telefonda kartalar ro\'yxati (jadval emas)', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const SupportListScreen(),
        overrides: m11Overrides(support: FakeSupportRepository(tickets: _tickets())),
        surface: kPhoneSurface,
      );

      expect(tester.widget<SupportListBody>(find.byType(SupportListBody)).asTable, isFalse);
      expect(find.text('Status'), findsNothing);
    });

    testWidgets('bo\'sh holat planshetda ham `No Ticket Added Yet`', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const SupportListScreen(),
        overrides: m11Overrides(),
        surface: kTabletSurface,
      );

      expect(find.byType(EmptyState), findsOneWidget);
    });
  });

  group('T-28 Add Ticket modali', () {
    testWidgets('planshetda TabletModal, sarlavha qatorida Cancel (M122)', (
      WidgetTester tester,
    ) async {
      await pumpM11Screen(
        tester,
        const ModalHost(open: showAddTicketModal),
        overrides: m11Overrides(),
        surface: kTabletSurface,
      );
      await openModal(tester);

      expect(find.byType(TabletModal), findsOneWidget);
      expect(tester.widget<TabletModal>(find.byType(TabletModal)).cancelLabel, isNotNull);
      expect(find.byType(SupportFormPane), findsOneWidget);
    });

    testWidgets('telefonda AppBottomSheet — bir xil forma paneli', (WidgetTester tester) async {
      await pumpM11Screen(
        tester,
        const ModalHost(open: showAddTicketModal),
        overrides: m11Overrides(),
        surface: kPhoneSurface,
      );
      await openModal(tester);

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.byType(TabletModal), findsNothing);
      expect(find.byType(SupportFormPane), findsOneWidget);
    });
  });
}
