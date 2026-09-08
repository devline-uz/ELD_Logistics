/// `M-55 Sync conflicts` (🎨 dizaynda yo'q, §21.6) — rad etilgan/almashtirilgan
/// elementlar (M30, §5.6).
///
/// Figma yo'q, lekin `core/ui` dizayn tizimi majburiy: `AdaptiveScaffold` +
/// `AppBarPrimary` + `SettingsCard`/`SettingsRow` — `M-54 Sync status` bilan
/// bir xil naqsh.
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
import '../../../../core/ui/ui.dart';

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
  Widget build(BuildContext context) => AdaptiveScaffold(
    // #B-64: planshetda tana cheklovsiz cho'zilmaydi.
    maxContentWidth: ContentWidth.single,
    appBar: AppBarPrimary(title: context.l10n.syncConflictsTitle, leading: const AppBackButton()),
    backgroundColor: context.colors.bg,
    phone: (BuildContext context) => const _ConflictsBody(),
    tablet: (BuildContext context) => const _ConflictsBody(),
  );
}

/// `T-35` planshet modali ham shu tanani ishlatadi (M7).
class _ConflictsBody extends ConsumerWidget {
  const _ConflictsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<OutboxItemRow>> conflicts = ref.watch(syncConflictsProvider);

    return asyncView<List<OutboxItemRow>>(
      conflicts,
      loading: const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(),
      ),
      error: (Object error) => ErrorState(
        message: l10n.syncErrorLoading,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(syncConflictsProvider),
      ),
      data: (List<OutboxItemRow> rows) => rows.isEmpty
          ? EmptyState(
              title: l10n.syncConflictsEmptyTitle,
              message: l10n.syncConflictsEmpty,
              icon: Icons.task_alt,
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
              itemCount: rows.length,
              separatorBuilder: (BuildContext context, int _) =>
                  Divider(height: Strokes.thin, color: context.colors.stroke),
              itemBuilder: (BuildContext context, int index) => _ConflictTile(row: rows[index]),
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
    final AppColors c = context.colors;
    final RejectReason reason = RejectReason.fromWire(row.rejectReason);
    final OutboxKind kind = OutboxKind.fromWire(row.kind);
    final String? action = conflictActionLabel(l10n, reason);
    final bool informational = reason == RejectReason.superseded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            informational ? Icons.info_outline : Icons.error_outline,
            color: informational ? c.textSecondary : c.error,
          ),
          const SizedBox(width: Spacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.syncConflictItemTitle(
                    outboxKindLabel(l10n, kind),
                    AppFormats.listHeaderOf(row.createdAt),
                  ),
                  style: context.text.body11.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: Spacing.s5),
                Text(
                  conflictMessage(l10n, reason),
                  style: context.text.body15.copyWith(color: c.textSecondary),
                ),
                if (action != null) ...<Widget>[
                  const SizedBox(height: Spacing.s10),
                  AppButton.text(
                    label: action,
                    onPressed: reason == RejectReason.timeInFuture ? () => _resend(ref) : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resend(WidgetRef ref) {
    unawaited(
      ref.read(outboxDaoProvider).requeue(id: row.id, now: ref.read(timeSourceProvider).now()),
    );
  }
}
