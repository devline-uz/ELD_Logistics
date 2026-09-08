import 'package:sync_core/sync_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('planRetention', () {
    test('derives every cut-off from the §5.2 table', () {
      final RetentionPlan plan = planRetention(now: t0);
      expect(plan.ackedEventsBefore, t0.subtract(const Duration(days: 30)));
      expect(plan.sentTelemetryBefore, t0.subtract(const Duration(hours: 48)));
      expect(plan.telemetryFloor, t0.subtract(const Duration(days: 14)));
      expect(plan.dailyLogsBefore, t0.subtract(const Duration(days: 30)));
      expect(plan.dvirReportsBefore, t0.subtract(const Duration(days: 30)));
      expect(plan.chatBefore, t0.subtract(const Duration(days: 30)));
      expect(plan.chatMaxMessages, 500);
      expect(plan.uploadedFilesBefore, t0.subtract(const Duration(days: 7)));
      expect(plan.conflictsBefore, t0.subtract(const Duration(days: 7)));
      expect(plan.notificationsBefore, t0.subtract(const Duration(days: 30)));
    });

    test('normalises a local `now` to UTC', () {
      final RetentionPlan plan = planRetention(now: t0.toLocal());
      expect(plan.ackedEventsBefore.isUtc, isTrue);
      expect(plan.ackedEventsBefore, t0.subtract(const Duration(days: 30)));
    });

    test('honours a custom policy', () {
      final RetentionPlan plan = planRetention(
        now: t0,
        policy: const RetentionPolicy(ackedEventAge: Duration(days: 60), chatMaxMessages: 100),
      );
      expect(plan.ackedEventsBefore, t0.subtract(const Duration(days: 60)));
      expect(plan.chatMaxMessages, 100);
    });
  });

  group('StorageBudget', () {
    const StorageBudget budget = StorageBudget();

    test('uses the 90 MB soft limit and 100 MB hard limit', () {
      expect(budget.softLimitBytes, 90 * 1024 * 1024);
      expect(budget.maxBytes, 100 * 1024 * 1024);
      expect(budget.isOverSoftLimit(80 * 1024 * 1024), isFalse);
      expect(budget.isOverSoftLimit(95 * 1024 * 1024), isTrue);
      expect(budget.isOverBudget(95 * 1024 * 1024), isFalse);
      expect(budget.isOverBudget(101 * 1024 * 1024), isTrue);
    });
  });

  group('evaluateBudget', () {
    test('does nothing below the soft limit', () {
      final BudgetVerdict verdict = evaluateBudget(
        usedBytes: 10 * 1024 * 1024,
        telemetryRows: 9999,
      );
      expect(verdict.overSoftLimit, isFalse);
      expect(verdict.overBudget, isFalse);
      expect(verdict.requiresTrim, isFalse);
      expect(verdict.telemetryRowsToDrop, 0);
    });

    test('drops the oldest 10% of telemetry above the soft limit', () {
      final BudgetVerdict verdict = evaluateBudget(
        usedBytes: 95 * 1024 * 1024,
        telemetryRows: 5000,
      );
      expect(verdict.overSoftLimit, isTrue);
      expect(verdict.overBudget, isFalse);
      expect(verdict.telemetryRowsToDrop, 500);
      expect(verdict.requiresTrim, isTrue);
    });

    test('drops at least one row when telemetry is tiny', () {
      final BudgetVerdict verdict = evaluateBudget(usedBytes: 95 * 1024 * 1024, telemetryRows: 3);
      expect(verdict.telemetryRowsToDrop, 1);
    });

    test('never trims events when there is no telemetry left (M23)', () {
      final BudgetVerdict verdict = evaluateBudget(usedBytes: 120 * 1024 * 1024, telemetryRows: 0);
      expect(verdict.overBudget, isTrue);
      expect(verdict.telemetryRowsToDrop, 0);
      expect(verdict.requiresTrim, isFalse);
    });

    test('honours a custom budget', () {
      final BudgetVerdict verdict = evaluateBudget(
        usedBytes: 100,
        telemetryRows: 50,
        budget: const StorageBudget(maxBytes: 90, softLimitBytes: 50, trimFraction: 0.5),
      );
      expect(verdict.overBudget, isTrue);
      expect(verdict.telemetryRowsToDrop, 25);
    });
  });
}
