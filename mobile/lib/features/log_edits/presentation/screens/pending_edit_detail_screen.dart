/// `M-27 Pending edit detail` 🎨 (tz-mobile 1697–1730, §13.3).
///
/// `Approve` M133/M134 bo'yicha bloklanadi — qoida `domain/log_edit_policy`
/// da, bu ekran faqat natijani ko'rsatadi.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/log_edit_models.dart';
import '../../domain/log_edit_policy.dart';
import '../controllers/log_edits_controllers.dart';

class PendingEditDetailScreen extends ConsumerWidget {
  const PendingEditDetailScreen({required this.requestId, super.key});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<LogEditRequestView?> request = ref.watch(pendingEditProvider(requestId));
    final LogEditDetailState state = ref.watch(logEditDetailControllerProvider);

    ref.listen<LogEditDetailState>(logEditDetailControllerProvider, (
      LogEditDetailState? _,
      LogEditDetailState next,
    ) {
      if (next.done) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.editsQueued)));
        unawaited(Navigator.of(context).maybePop());
      }
    });

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
      phone: (BuildContext c) =>
          _Body(requestId: requestId, request: request, state: state, twoColumn: false),
      tablet: (BuildContext c) =>
          _Body(requestId: requestId, request: request, state: state, twoColumn: true),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.requestId,
    required this.request,
    required this.state,
    required this.twoColumn,
  });

  final String requestId;
  final AsyncValue<LogEditRequestView?> request;
  final LogEditDetailState state;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return asyncView<LogEditRequestView?>(
      request,
      loading: const LoadingSkeleton(itemCount: 3),
      error: (Object _) => ErrorState(
        message: l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(pendingEditProvider(requestId)),
      ),
      data: (LogEditRequestView? value) => value == null
          ? EmptyState(
              title: l10n.editsEmptyTitle,
              message: l10n.editsResolvedElsewhere,
              icon: Icons.edit_note,
            )
          : _Detail(
              request: value,
              state: state,
              twoColumn: twoColumn,
              controller: ref.read(logEditDetailControllerProvider.notifier),
            ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.request,
    required this.state,
    required this.controller,
    required this.twoColumn,
  });

  final LogEditRequestView request;
  final LogEditDetailState state;
  final LogEditDetailController controller;
  final bool twoColumn;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final LogEditBlock? block = blockOfRequest(request);

    final List<Widget> body = <Widget>[
      Text(
        l10n.editsDetailTitle(request.logDate),
        style: context.text.body8.copyWith(color: c.textPrimary),
      ),
      const SizedBox(height: Spacing.s15),
      for (final LogEditChange change in request.changes)
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.s10),
          child: _ChangeCard(change: change),
        ),
      if (block != null) ...<Widget>[
        BannerStrip(
          message: block == LogEditBlock.drivingImmutable
              ? l10n.editsBlockedDriving
              : l10n.editsBlockedImmutable,
          tone: BannerTone.warning,
        ),
        const SizedBox(height: Spacing.s10),
      ],
      if (state.showReasonField) ...<Widget>[
        AppTextField(
          label: l10n.editsRejectReasonLabel,
          hint: l10n.editsRejectReasonHint,
          maxLines: 3,
          minLines: 2,
          maxLength: kRejectReasonMaxLength,
          onChanged: controller.setReason,
          errorText: state.reasonIssue == null ? null : l10n.editsRejectReasonRequired,
        ),
        const SizedBox(height: Spacing.s10),
      ],
      if (state.error != null)
        Text(
          localizedApiError(l10n, state.error!),
          style: context.text.body16.copyWith(color: c.error),
        ),
    ];

    Future<void> approve() async {
      final bool confirmed = await showConfirmDialog(
        context: context,
        title: l10n.editsApproveConfirmTitle,
        message: l10n.editsApproveConfirmMessage,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.editsApprove,
      );
      if (confirmed) {
        await controller.approve(request.id);
      }
    }

    final Widget actions = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
      child: Row(
        children: <Widget>[
          Expanded(
            child: AppButton.secondary(
              label: l10n.editsReject,
              destructive: true,
              expand: true,
              busy: state.submitting && state.showReasonField,
              onPressed: state.showReasonField
                  ? () => controller.reject(request.id)
                  : controller.startReject,
            ),
          ),
          const SizedBox(width: Spacing.s10),
          Expanded(
            child: AppButton.primary(
              label: l10n.editsApprove,
              expand: true,
              busy: state.submitting && !state.showReasonField,
              onPressed: block == null && !state.submitting ? approve : null,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              vertical: Spacing.s20,
              horizontal: twoColumn ? Spacing.s20 : 0,
            ),
            children: body,
          ),
        ),
        actions,
      ],
    );
  }
}

class _ChangeCard extends StatelessWidget {
  const _ChangeCard({required this.change});

  final LogEditChange change;

  String _summary(String? status, String special, DateTime from, DateTime to) {
    final String s = status ?? kEmptyValue;
    final String suffix = special == 'none' ? '' : ' ($special)';
    return '$s$suffix ${AppFormats.eventTimeOf(from)} – ${AppFormats.eventTimeOf(to)}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.editsCurrent(
              _summary(change.currentStatus, change.currentSpecial, change.from, change.to),
            ),
            style: context.text.body16.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Spacing.s5),
          Text(
            l10n.editsProposed(
              _summary(change.proposedStatus, change.proposedSpecial, change.from, change.to),
            ),
            style: context.text.body14.copyWith(color: c.textPrimary),
          ),
          if (change.note != null) ...<Widget>[
            const SizedBox(height: Spacing.s10),
            Text(
              '${l10n.editsNote}: ${change.note}',
              style: context.text.body16.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
