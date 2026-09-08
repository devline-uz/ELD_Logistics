/// `M-55 Sync conflicts` — rad etilgan/almashtirilgan elementlar (M30, §5.6).
///
/// TODO(M1): `core/ui` tayyor bo'lgach `AppScaffold` / `AppEmptyState` /
/// `AppListTile` va dizayn tokenlariga ko'chiriladi.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_core/sync_core.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/outbox_dao.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/sync/conflict_messages.dart';
import '../../../../core/time/time_providers.dart';
import '../../../../core/ui/formats.dart';

class SyncConflictsScreen extends ConsumerStatefulWidget {
  const SyncConflictsScreen({super.key});

  @override
  ConsumerState<SyncConflictsScreen> createState() => _SyncConflictsScreenState();
}

class _SyncConflictsScreenState extends ConsumerState<SyncConflictsScreen> {
  @override
  void initState() {
    super.initState();
    // M30: ekran ochilishi bilan qizil nuqta o'chadi.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      final OutboxDao dao = ref.read(outboxDaoProvider);
      unawaited(dao.markConflictsSeen(ref.read(timeSourceProvider).now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<OutboxItemRow>> conflicts = ref.watch(syncConflictsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncConflictsTitle)),
      body: conflicts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => Center(child: Text(l10n.errUnknown)),
        data: (List<OutboxItemRow> rows) => rows.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l10n.syncConflictsEmpty, textAlign: TextAlign.center),
                ),
              )
            : ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) => _ConflictTile(row: rows[index]),
              ),
      ),
    );
  }
}

class _ConflictTile extends ConsumerWidget {
  const _ConflictTile({required this.row});

  final OutboxItemRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final RejectReason reason = RejectReason.fromWire(row.rejectReason);
    final OutboxKind kind = OutboxKind.fromWire(row.kind);
    final String? action = conflictActionLabel(l10n, reason);
    final bool informational = reason == RejectReason.superseded;

    return ListTile(
      isThreeLine: true,
      leading: Icon(
        informational ? Icons.info_outline : Icons.error_outline,
        color: informational ? theme.colorScheme.primary : theme.colorScheme.error,
      ),
      title: Text(
        l10n.syncConflictItemTitle(
          outboxKindLabel(l10n, kind),
          AppFormats.listHeaderOf(row.createdAt),
        ),
      ),
      subtitle: Text(conflictMessage(l10n, reason)),
      trailing: action == null
          ? null
          : TextButton(
              onPressed: reason == RejectReason.timeInFuture ? () => _resend(ref) : null,
              child: Text(action),
            ),
    );
  }

  void _resend(WidgetRef ref) {
    unawaited(
      ref.read(outboxDaoProvider).requeue(id: row.id, now: ref.read(timeSourceProvider).now()),
    );
  }
}
