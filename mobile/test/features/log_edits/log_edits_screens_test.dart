@Timeout(Duration(seconds: 60))
/// `M-26 Pending edits` va `M-27 Pending edit detail` widget testlari
/// (M132–M135) + `log_edit_policy` domen testlari.
library;

import 'package:eld_mobile/features/log_edits/domain/log_edit_models.dart';
import 'package:eld_mobile/features/log_edits/domain/log_edit_policy.dart';
import 'package:eld_mobile/features/log_edits/presentation/screens/pending_edit_detail_screen.dart';
import 'package:eld_mobile/features/log_edits/presentation/screens/pending_edits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../logs/m7_test_harness.dart';

LogEditChange _change({
  String proposedStatus = 'ON',
  String proposedSpecial = 'none',
  String? currentStatus = 'OFF',
  String eventType = 'status_change',
  String? currentOrigin = 'driver',
}) => LogEditChange(
  from: DateTime(2026, 9, 7, 13),
  to: DateTime(2026, 9, 7, 15),
  proposedStatus: proposedStatus,
  proposedSpecial: proposedSpecial,
  currentStatus: currentStatus,
  eventType: eventType,
  currentOrigin: currentOrigin,
  note: 'Wrong status recorded',
);

LogEditRequestView _request({List<LogEditChange>? changes}) => LogEditRequestView(
  id: 'req-1',
  logDate: '2026-09-07',
  createdAt: DateTime(2026, 9, 7, 9),
  source: LogEditSource.adminEdit,
  requestedBy: 'Dispatch',
  changes: changes ?? <LogEditChange>[_change()],
);

void main() {
  group('log_edit_policy (M133/M134)', () {
    test('avtomatik DR o\'zgarishi bloklanadi', () {
      final LogEditRequestView request = _request(
        changes: <LogEditChange>[_change(currentStatus: 'DR', currentOrigin: 'auto')],
      );
      expect(blockOfRequest(request), LogEditBlock.drivingImmutable);
    });

    test('DR → PC istisnosi ruxsat etiladi', () {
      final LogEditRequestView request = _request(
        changes: <LogEditChange>[
          _change(currentStatus: 'DR', currentOrigin: 'auto', proposedSpecial: 'pc'),
        ],
      );
      expect(blockOfRequest(request), isNull);
    });

    test('immutable event turi bloklanadi', () {
      final LogEditRequestView request = _request(
        changes: <LogEditChange>[_change(eventType: 'malfunction')],
      );
      expect(blockOfRequest(request), LogEditBlock.eventImmutable);
    });

    test('reject sababi majburiy va ≤200 belgi', () {
      expect(validateRejectReason('   '), RejectReasonIssue.empty);
      expect(validateRejectReason('a' * 201), RejectReasonIssue.tooLong);
      expect(validateRejectReason('Not mine'), isNull);
    });
  });

  group('M-26 Pending edits', () {
    testWidgets('bo\'sh holat', (WidgetTester tester) async {
      await pumpM7(tester, const PendingEditsScreen());
      expect(find.text('No pending edits'), findsOneWidget);
    });

    testWidgets('yuklanish holati', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const PendingEditsScreen(),
        edits: FakeLogEditsRepository(loading: true),
      );
      expect(find.text('No pending edits'), findsNothing);
    });

    testWidgets('to\'la holat: sana, so\'rovchi, o\'zgarishlar soni', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const PendingEditsScreen(),
        edits: FakeLogEditsRepository(items: <LogEditRequestView>[_request()]),
      );
      expect(find.textContaining('2026-09-07'), findsOneWidget);
      expect(find.textContaining('Dispatch'), findsOneWidget);
      expect(find.text('1 change'), findsOneWidget);
      expect(find.text('Admin edit'), findsOneWidget);
    });
  });

  group('M-27 Pending edit detail', () {
    testWidgets('joriy va taklif qilingan qiymat yonma-yon', (WidgetTester tester) async {
      await pumpM7(
        tester,
        const PendingEditDetailScreen(requestId: 'req-1'),
        edits: FakeLogEditsRepository(items: <LogEditRequestView>[_request()]),
      );
      expect(find.textContaining('Proposed change to your log for 2026-09-07'), findsOneWidget);
      expect(find.textContaining('Current: OFF'), findsOneWidget);
      expect(find.textContaining('Proposed: ON'), findsOneWidget);
      expect(find.textContaining('Wrong status recorded'), findsOneWidget);
    });

    testWidgets('M133: DR bloklanganda Approve o\'chirilgan va izoh ko\'rinadi', (
      WidgetTester tester,
    ) async {
      await pumpM7(
        tester,
        const PendingEditDetailScreen(requestId: 'req-1'),
        edits: FakeLogEditsRepository(
          items: <LogEditRequestView>[
            _request(
              changes: <LogEditChange>[_change(currentStatus: 'DR', currentOrigin: 'auto')],
            ),
          ],
        ),
      );
      expect(
        find.textContaining('Automatically recorded driving time cannot be changed'),
        findsOneWidget,
      );
    });

    testWidgets('Reject: sabab maydoni ochiladi, bo\'sh sabab rad etiladi', (
      WidgetTester tester,
    ) async {
      final FakeLogEditsRepository repo = FakeLogEditsRepository(
        items: <LogEditRequestView>[_request()],
      );
      await pumpM7(tester, const PendingEditDetailScreen(requestId: 'req-1'), edits: repo);

      await tester.tap(find.widgetWithText(InkWell, 'Reject').first);
      await tester.pump();
      expect(find.text('Reason'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Reject').first);
      await tester.pump();
      expect(find.text('A reason is required.'), findsOneWidget);
      expect(repo.rejected, isEmpty);
    });

    testWidgets('so\'rov topilmasa: allaqachon hal qilingan xabari', (WidgetTester tester) async {
      await pumpM7(tester, const PendingEditDetailScreen(requestId: 'missing'));
      expect(find.text('This request was already resolved.'), findsOneWidget);
    });
  });
}
