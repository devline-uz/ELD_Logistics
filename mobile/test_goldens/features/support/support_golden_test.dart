@Timeout(Duration(seconds: 60))
/// **M-49 / M-50 / M-51** goldenlari — light/dark × phone/tablet.
///
/// M-50 ikki kadrda: bo'sh holat (`No Ticket Added Yet`) va to'la ro'yxat.
library;

import 'package:eld_mobile/features/support/domain/support_ticket.dart';
import 'package:eld_mobile/features/support/presentation/screens/support_form_screen.dart';
import 'package:eld_mobile/features/support/presentation/screens/support_list_screen.dart';
import 'package:eld_mobile/features/support/presentation/screens/ticket_thread_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/features/profile/m11_test_harness.dart';
import '../golden_screen_host.dart';

List<SupportTicket> _tickets() => <SupportTicket>[
  buildTestTicket(),
  buildTestTicket(id: 'tkt-2', status: TicketStatus.inProgress, subject: 'BLE drops on cold start'),
  buildTestTicket(id: 'tkt-3', status: TicketStatus.resolved, subject: 'Signature not saved'),
];

void main() {
  screenGoldenMatrix(
    'support_list_empty',
    builder: () => const SupportListScreen(),
    overrides: m11Overrides,
  );

  screenGoldenMatrix(
    'support_list',
    builder: () => const SupportListScreen(),
    overrides: () => m11Overrides(support: FakeSupportRepository(tickets: _tickets())),
  );

  screenGoldenMatrix(
    'support_form',
    builder: () => const SupportFormScreen(),
    overrides: m11Overrides,
  );

  screenGoldenMatrix(
    'support_thread',
    builder: () => const TicketThreadScreen(ticketId: 'tkt-122546'),
    overrides: () => m11Overrides(
      support: FakeSupportRepository(
        tickets: _tickets(),
        messages: <SupportMessage>[
          SupportMessage(
            id: 'm1',
            text: 'Thanks for the report, we are on it.',
            senderName: 'Support',
            createdAt: DateTime.utc(2025, 5, 28, 15, 2),
          ),
        ],
      ),
    ),
  );
}
