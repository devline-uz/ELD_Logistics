/// `M-54 Sync status` (🎨 dizaynda yo'q, §21.6) — oxirgi push/pull, navbat,
/// xato, kursor, `Retry now` (M28).
///
/// Figma yo'q, lekin `core/ui` dizayn tizimi majburiy: `AdaptiveScaffold` +
/// `AppBarPrimary` + `SettingsCard`/`SettingsRow` — boshqa 🎨 ekranlar bilan
/// bir xil naqsh (masalan `M-46 Diagnosis of device`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_core/sync_core.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/outbox_dao.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/sync/conflict_messages.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/sync/sync_scheduler.dart';
import '../../../../core/ui/ui.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    appBar: AppBarPrimary(title: context.l10n.syncStatusTitle, leading: const AppBackButton()),
    backgroundColor: context.colors.bg,
    phone: (BuildContext context) => const SyncStatusBody(),
    tablet: (BuildContext context) => const SyncStatusBody(),
  );
}

/// `T-35` planshet modali ham shu tanani ishlatadi (M7).
class SyncStatusBody extends ConsumerWidget {
  const SyncStatusBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<SyncCursorRow?> cursor = ref.watch(syncCursorProvider);
    final AsyncValue<OutboxQueueStats> stats = ref.watch(outboxStatsProvider);

    if (cursor.isLoading || stats.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: SkeletonBox(width: double.infinity, height: 320),
      );
    }
    if (cursor.hasError || stats.hasError) {
      return ErrorState(
        message: l10n.syncErrorLoading,
        retryLabel: l10n.commonRetry,
        onRetry: () {
          ref.invalidate(syncCursorProvider);
          ref.invalidate(outboxStatsProvider);
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: <Widget>[
        _CursorCard(row: cursor.value),
        const SizedBox(height: Spacing.cardGap),
        _QueueCard(stats: stats.value!),
        const SizedBox(height: Spacing.cardGap),
        AppButton.primary(
          label: l10n.syncRetryNow,
          icon: Icons.sync,
          onPressed: () => ref.read(syncSchedulerProvider).request(SyncTrigger.manual),
        ),
      ],
    );
  }
}

class _CursorCard extends StatelessWidget {
  const _CursorCard({required this.row});

  final SyncCursorRow? row;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SettingsCard(
      children: <Widget>[
        SettingsRow(
          label: l10n.syncLastPush,
          showChevron: false,
          trailing: _ValueText(_fmt(context, row?.lastPushAt)),
        ),
        SettingsRow(
          label: l10n.syncLastPull,
          showChevron: false,
          trailing: _ValueText(_fmt(context, row?.lastPullAt)),
        ),
        if (row?.lastError != null)
          SettingsRow(
            label: l10n.syncLastError,
            showChevron: false,
            // Label ("Last error") Expanded ichida qisqa — `SettingsRow`
            // avtomatik joy beradi, badge qo'shimcha cheklovsiz sig'adi.
            trailing: StatusBadge(label: row!.lastError!, tone: StatusTone.error, dense: true),
          ),
        SettingsRow(
          label: l10n.syncCursor,
          showChevron: false,
          trailing: _ValueText(row?.nextSince ?? l10n.syncNever),
        ),
      ],
    );
  }

  String _fmt(BuildContext context, DateTime? value) =>
      value == null ? context.l10n.syncNever : AppFormats.fullDateTime(value);
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.stats});

  final OutboxQueueStats stats;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<MapEntry<OutboxKind, int>> entries = stats.pendingByKind.entries.toList()
      ..sort(
        (MapEntry<OutboxKind, int> a, MapEntry<OutboxKind, int> b) =>
            a.key.index.compareTo(b.key.index),
      );

    return SettingsCard(
      children: <Widget>[
        Text(
          l10n.syncQueue,
          style: context.text.body11.copyWith(color: context.colors.textPrimary),
        ),
        if (entries.isEmpty)
          Text(
            l10n.syncQueueEmpty,
            style: context.text.body15.copyWith(color: context.colors.textSecondary),
          )
        else
          for (final MapEntry<OutboxKind, int> e in entries)
            SettingsRow(
              label: outboxKindLabel(l10n, e.key),
              showChevron: false,
              trailing: _ValueText('${e.value}'),
            ),
        if (stats.rejected > 0)
          SettingsRow(
            label: l10n.syncStateConflict(stats.rejected),
            showChevron: false,
            trailing: StatusBadge(
              label: l10n.syncConflictsCount(stats.rejected),
              tone: StatusTone.error,
              dense: true,
            ),
          ),
      ],
    );
  }
}

/// Qiymat uzun bo'lishi mumkin (kursor tokeni, sana) — kengligi cheklanadi,
/// aks holda `SettingsRow` ning `Row` i chetdan chiqib ketadi (eld_connect
/// `_Field` bilan bir xil naqsh).
class _ValueText extends StatelessWidget {
  const _ValueText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 160),
    child: Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: context.text.body15.copyWith(color: context.colors.textSecondary),
    ),
  );
}
