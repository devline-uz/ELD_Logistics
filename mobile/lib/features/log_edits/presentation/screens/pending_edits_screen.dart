/// `M-26 Pending edits` 🎨 (tz-mobile 1692–1696, §13.2).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/log_edit_models.dart';
import '../../log_edits_routes.dart';
import '../controllers/log_edits_controllers.dart';

class PendingEditsScreen extends ConsumerWidget {
  const PendingEditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<LogEditRequestView>> items = ref.watch(pendingEditsProvider);

    return AdaptiveScaffold(
      maxContentWidth: ContentWidth.wide,
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.editsTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.commonCancel,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      phone: (BuildContext c) => PendingEditsBody(items: items, twoColumn: false),
      tablet: (BuildContext c) => PendingEditsBody(items: items, twoColumn: true),
    );
  }
}

class PendingEditsBody extends ConsumerWidget {
  const PendingEditsBody({required this.items, required this.twoColumn, super.key});

  final AsyncValue<List<LogEditRequestView>> items;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return asyncView<List<LogEditRequestView>>(
      items,
      loading: const LoadingSkeleton(itemCount: 4),
      error: (Object _) => ErrorState(
        message: l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(pendingEditsProvider),
      ),
      data: (List<LogEditRequestView> list) => list.isEmpty
          ? EmptyState(
              title: l10n.editsEmptyTitle,
              message: l10n.editsEmptyMessage,
              icon: Icons.edit_note,
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: twoColumn ? 2 : 1,
                mainAxisSpacing: Spacing.s10,
                crossAxisSpacing: Spacing.s20,
                mainAxisExtent: 148,
              ),
              itemCount: list.length,
              itemBuilder: (BuildContext _, int index) => _RequestTile(request: list[index]),
            ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final LogEditRequestView request;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Material(
      color: c.surface,
      borderRadius: Radii.cardRadius,
      child: InkWell(
        onTap: () => context.push(LogEditsRoute.detailFor(request.id)),
        borderRadius: Radii.cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: Radii.cardRadius,
            border: Border.all(color: c.stroke, width: Strokes.thin),
          ),
          padding: const EdgeInsets.all(Spacing.s15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${l10n.editsLogDate}: ${request.logDate}',
                      style: context.text.body11.copyWith(color: c.textPrimary),
                    ),
                  ),
                  StatusBadge(
                    label: request.source == LogEditSource.unidentifiedAssign
                        ? l10n.editsSourceUnidentified
                        : l10n.editsSourceAdmin,
                    tone: StatusTone.neutral,
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.s5),
              Text(
                '${l10n.editsRequestedBy}: ${AppFormats.orNa(request.requestedBy)}',
                style: context.text.body16.copyWith(color: c.textSecondary),
              ),
              Text(
                '${l10n.editsCreatedAt}: ${AppFormats.fullDateTime(request.createdAt)}',
                style: context.text.body16.copyWith(color: c.textSecondary),
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  Text(
                    l10n.editsChangeCount(request.changeCount),
                    style: context.text.body14.copyWith(color: c.textPrimary),
                  ),
                  const Spacer(),
                  if (request.pendingSync)
                    StatusBadge(
                      label: l10n.editsPendingSync,
                      tone: StatusTone.neutral,
                      icon: Icons.schedule,
                      dense: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
