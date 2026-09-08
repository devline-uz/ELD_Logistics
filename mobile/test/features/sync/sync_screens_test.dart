@Timeout(Duration(seconds: 60))
/// `M-54 Sync status` va `M-55 Sync conflicts` widget testlari (M28, M30).
library;

import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/outbox_dao.dart';
import 'package:eld_mobile/core/db/db_providers.dart';
import 'package:eld_mobile/core/time/time_providers.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/sync/presentation/screens/sync_conflicts_screen.dart';
import 'package:eld_mobile/features/sync/presentation/screens/sync_status_screen.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_core/sync_core.dart';

import '../../core/helpers/test_clock.dart';

void main() {
  final DateTime t0 = DateTime.utc(2026, 9, 7, 12);
  late AppDatabase db;
  late TimeSource time;

  setUp(() {
    db = AppDatabase.memory();
    time = buildTestTimeSource(t0).time..syncFromServer(t0);
  });

  tearDown(() async {
    await db.close();
    await time.dispose();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          timeSourceProvider.overrideWithValue(time),
        ],
        child: MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );
    // `pumpAndSettle` ishlatilmaydi: yuklanish holatidagi `CircularProgressIndicator`
    // cheksiz animatsiya beradi va test osilib qoladi.
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// Drift `watch()` oqimini bekor qilishda 0 ms taymer qoladi; daraxtni test
  /// tanasi ichida yechib, taymerni ishlatib yuboramiz.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  /// Drift `watch()` oqimi 0 ms taymer bilan uyg'onadi; `testWidgets` ning
  /// `fakeAsync` zonasida bunday taymer faqat `pump()` da ishlaydi, shuning
  /// uchun `await stream.first` test tanasida abadiy osilib qoladi (CI hang).
  /// Real async zonada o'qiymiz.
  Future<OutboxQueueStats> stats(WidgetTester tester) async =>
      (await tester.runAsync<OutboxQueueStats>(() => db.outboxDao.watchStats().first))!;

  Future<int> addConflict({
    required String clientId,
    required String reason,
    OutboxKind kind = OutboxKind.event,
    String? supersededBy,
  }) async {
    final int id = await db
        .into(db.outboxItems)
        .insert(
          OutboxItemsCompanion.insert(
            kind: kind.wire,
            payload: '{}',
            clientId: clientId,
            deviceSeq: 1,
            createdAt: t0,
            nextAttemptAt: t0,
            updatedAt: t0,
          ),
        );
    await db.outboxDao.applyOutcome(
      id: id,
      outcome: resolvePushResult(
        result: PushResultKind.rejected,
        reason: reason,
        supersededBy: supersededBy,
      ),
      now: t0,
    );
    return id;
  }

  group('M-54 Sync status', () {
    testWidgets('bo\'sh navbatda diagnostika va Retry now ko\'rinadi', (WidgetTester tester) async {
      await pump(tester, const SyncStatusScreen());

      expect(find.text('Sync status'), findsOneWidget);
      expect(find.text('Last upload'), findsOneWidget);
      expect(find.text('Last download'), findsOneWidget);
      expect(find.text('Cursor'), findsOneWidget);
      expect(find.text('Never'), findsNWidgets(3));
      expect(find.text('Nothing waiting to sync.'), findsOneWidget);
      expect(find.text('Retry now'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('navbat turlari bo\'yicha ko\'rsatiladi (M28)', (WidgetTester tester) async {
      for (int i = 0; i < 3; i++) {
        await db
            .into(db.outboxItems)
            .insert(
              OutboxItemsCompanion.insert(
                kind: i == 0 ? OutboxKind.event.wire : OutboxKind.chat.wire,
                payload: '{}',
                clientId: 'c$i',
                deviceSeq: i + 1,
                createdAt: t0,
                nextAttemptAt: t0,
                updatedAt: t0,
              ),
            );
      }
      await pump(tester, const SyncStatusScreen());

      expect(find.text('Duty events'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('oxirgi xato kodi va kursor ko\'rsatiladi', (WidgetTester tester) async {
      await db.settingsDao.setNextSince('2026-09-07T11:00:00Z');
      await db.settingsDao.markPush(t0);
      await db.settingsDao.markError(code: 'RATE_LIMITED', at: t0);

      await pump(tester, const SyncStatusScreen());
      expect(find.text('Last error'), findsOneWidget);
      expect(find.text('RATE_LIMITED'), findsOneWidget);
      expect(find.text('2026-09-07T11:00:00Z'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('M-55 Sync conflicts', () {
    testWidgets('bo\'sh holat matni', (WidgetTester tester) async {
      await pump(tester, const SyncConflictsScreen());
      expect(find.text('Sync conflicts'), findsOneWidget);
      expect(find.text('No conflicts. Everything you recorded was accepted.'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('§5.6 sabab matni va amali ko\'rsatiladi', (WidgetTester tester) async {
      await addConflict(clientId: 'a', reason: 'log_locked');
      await addConflict(clientId: 'b', reason: 'time_in_future');
      // M29: `superseded` — xato emas, `acked` + `superseded_by`, lekin M-55 da ko'rinadi.
      await addConflict(clientId: 'c', reason: 'superseded', supersededBy: 'srv-9');

      await pump(tester, const SyncConflictsScreen());

      expect(
        find.text('That day is already certified. Ask your fleet manager for a log edit.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'This entry was recorded ahead of server time and was not accepted. '
          'Check your device clock.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Another device recorded a status at the same time. The other entry was kept.'),
        findsOneWidget,
      );
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.text('Send again'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('ekran ochilganda reject_seen true bo\'ladi (M30)', (WidgetTester tester) async {
      await addConflict(clientId: 'a', reason: 'log_locked');
      expect((await stats(tester)).unseenRejected, 1);

      await pump(tester, const SyncConflictsScreen());
      expect((await stats(tester)).unseenRejected, 0);
      await unmount(tester);
    });

    testWidgets('«Send again» elementni navbatga qaytaradi', (WidgetTester tester) async {
      final int id = await addConflict(clientId: 'a', reason: 'time_in_future');
      await pump(tester, const SyncConflictsScreen());

      await tester.tap(find.text('Send again'));
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      final OutboxItemRow row = await (db.select(
        db.outboxItems,
      )..where(($OutboxItemsTable t) => t.id.equals(id))).getSingle();
      expect(row.state, OutboxState.pending.wire);
      expect(row.rejectReason, isNull);
      await unmount(tester);
    });
  });
}
