/// `M-54 Sync status` — oxirgi push/pull, navbat, xato, kursor, `Retry now` (M28).
///
/// TODO(M1): `core/ui` dizayn tizimi tayyor bo'lgach `AppScaffold`, `AppCard`,
/// `AppListTile` va tokenlarga ko'chiriladi. Hozircha Material primitivlari va
/// `Theme.of(context)` ranglari ishlatiladi (hard-coded rang taqiq).
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

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<OutboxQueueStats> stats = ref.watch(outboxStatsProvider);
    final AsyncValue<SyncCursorRow?> cursor = ref.watch(syncCursorProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncStatusTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          _CursorSection(cursor: cursor),
          const Divider(height: 1),
          _QueueSection(stats: stats),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () => ref.read(syncSchedulerProvider).request(SyncTrigger.manual),
              icon: const Icon(Icons.sync),
              label: Text(l10n.syncRetryNow),
            ),
          ),
        ],
      ),
    );
  }
}

class _CursorSection extends StatelessWidget {
  const _CursorSection({required this.cursor});

  final AsyncValue<SyncCursorRow?> cursor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return cursor.when(
      loading: () => const _LoadingTile(),
      error: (Object error, StackTrace _) => _ErrorTile(error: error),
      data: (SyncCursorRow? row) => Column(
        children: <Widget>[
          _ValueTile(label: l10n.syncLastPush, value: _fmt(context, row?.lastPushAt)),
          _ValueTile(label: l10n.syncLastPull, value: _fmt(context, row?.lastPullAt)),
          if (row?.lastError != null)
            _ValueTile(label: l10n.syncLastError, value: row!.lastError!, emphasise: true),
          _ValueTile(label: l10n.syncCursor, value: row?.nextSince ?? l10n.syncNever),
        ],
      ),
    );
  }

  String _fmt(BuildContext context, DateTime? value) =>
      value == null ? context.l10n.syncNever : value.toIso8601String();
}

class _QueueSection extends StatelessWidget {
  const _QueueSection({required this.stats});

  final AsyncValue<OutboxQueueStats> stats;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return stats.when(
      loading: () => const _LoadingTile(),
      error: (Object error, StackTrace _) => _ErrorTile(error: error),
      data: (OutboxQueueStats data) {
        final List<MapEntry<OutboxKind, int>> entries = data.pendingByKind.entries.toList()
          ..sort(
            (MapEntry<OutboxKind, int> a, MapEntry<OutboxKind, int> b) =>
                a.key.index.compareTo(b.key.index),
          );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(l10n.syncQueue, style: Theme.of(context).textTheme.titleSmall),
            ),
            if (entries.isEmpty)
              _ValueTile(label: l10n.syncQueueEmpty, value: '')
            else
              ...entries.map(
                (MapEntry<OutboxKind, int> e) =>
                    _ValueTile(label: outboxKindLabel(l10n, e.key), value: '${e.value}'),
              ),
            if (data.rejected > 0)
              _ValueTile(
                label: l10n.syncStateConflict(data.rejected),
                value: l10n.syncConflictsCount(data.rejected),
                emphasise: true,
              ),
          ],
        );
      },
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.label, required this.value, this.emphasise = false});

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      dense: true,
      title: Text(label, style: emphasise ? TextStyle(color: theme.colorScheme.error) : null),
      trailing: value.isEmpty ? null : Text(value, style: theme.textTheme.bodySmall),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
    title: Text(context.l10n.errUnknown),
  );
}
