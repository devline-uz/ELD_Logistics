/// `M-28 Unidentified driving claim` 🎨 (tz-mobile 1296–1316, M100).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/unidentified_models.dart';
import '../controllers/unidentified_controller.dart';

class UnidentifiedScreen extends ConsumerWidget {
  const UnidentifiedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<UnidentifiedBlock>> blocks = ref.watch(unidentifiedBlocksProvider);
    final UnidentifiedState state = ref.watch(unidentifiedControllerProvider);

    return AdaptiveScaffold(
      maxContentWidth: ContentWidth.wide,
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.unidentifiedTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.commonCancel,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      banners: <Widget>[
        if (state.alreadyAssigned)
          BannerStrip(
            message: l10n.unidentifiedAlreadyAssigned,
            tone: BannerTone.warning,
            dismissLabel: l10n.commonOk,
            onDismiss: ref.read(unidentifiedControllerProvider.notifier).acknowledge,
          ),
        if (blocks.value != null && blocks.value!.isNotEmpty)
          BannerStrip(
            message: l10n.unidentifiedBanner(blocks.value!.length),
            tone: BannerTone.info,
          ),
      ],
      phone: (BuildContext c) => UnidentifiedBody(blocks: blocks, state: state, twoColumn: false),
      tablet: (BuildContext c) => UnidentifiedBody(blocks: blocks, state: state, twoColumn: true),
    );
  }
}

class UnidentifiedBody extends ConsumerWidget {
  const UnidentifiedBody({
    required this.blocks,
    required this.state,
    required this.twoColumn,
    super.key,
  });

  final AsyncValue<List<UnidentifiedBlock>> blocks;
  final UnidentifiedState state;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return asyncView<List<UnidentifiedBlock>>(
      blocks,
      loading: const LoadingSkeleton(itemCount: 3),
      error: (Object _) => ErrorState(
        message: l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(unidentifiedBlocksProvider),
      ),
      data: (List<UnidentifiedBlock> list) => list.isEmpty
          ? EmptyState(
              title: l10n.unidentifiedEmptyTitle,
              message: l10n.unidentifiedEmptyMessage,
              icon: Icons.help_outline,
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: twoColumn ? 2 : 1,
                mainAxisSpacing: Spacing.s10,
                crossAxisSpacing: Spacing.s20,
                // `Pending sync` badge bilan eng baland karta 274 px (D-28
                // dan keyin qator balandligi aniq: `round(fs x 1.26)`);
                // 320 — o'sha balandlik + kichik zaxira (core `KeyValueRow`
                // ga o'tgandan keyin qayta o'lchandi).
                mainAxisExtent: 320,
              ),
              itemCount: list.length,
              itemBuilder: (BuildContext _, int index) =>
                  _BlockCard(block: list[index], state: state),
            ),
    );
  }
}

class _BlockCard extends ConsumerWidget {
  const _BlockCard({required this.block, required this.state});

  final UnidentifiedBlock block;
  final UnidentifiedState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final UnidentifiedController controller = ref.read(unidentifiedControllerProvider.notifier);
    final bool busy = state.busyId == block.id;

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
          KeyValueRow(
            label: l10n.unidentifiedStart,
            value: AppFormats.fullDateTime(block.start),
            dense: true,
          ),
          KeyValueRow(
            label: l10n.unidentifiedEnd,
            value: AppFormats.fullDateTime(block.end),
            dense: true,
          ),
          KeyValueRow(
            label: l10n.unidentifiedDuration,
            value: AppFormats.durationHms(block.duration),
            dense: true,
          ),
          KeyValueRow(
            label: l10n.unidentifiedDistance,
            value: l10n.unidentifiedDistanceMiles(block.distanceMiles.toStringAsFixed(2)),
            dense: true,
          ),
          KeyValueRow(
            label: l10n.unidentifiedUnit,
            value: AppFormats.orNa(block.unitId),
            dense: true,
          ),
          if (block.pendingSync) ...<Widget>[
            const SizedBox(height: Spacing.s5),
            StatusBadge(
              label: l10n.unidentifiedPendingSync,
              tone: StatusTone.neutral,
              icon: Icons.schedule,
              dense: true,
            ),
          ],
          if (state.error != null) ...<Widget>[
            const SizedBox(height: Spacing.s5),
            Text(
              localizedApiError(l10n, state.error!),
              style: context.text.body16.copyWith(color: c.error),
            ),
          ],
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.unidentifiedDismiss,
                  expand: true,
                  onPressed: busy ? null : () => controller.dismiss(block.id),
                ),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: AppButton.primary(
                  label: l10n.unidentifiedClaim,
                  expand: true,
                  busy: busy,
                  onPressed: busy || block.pendingSync ? null : () => controller.claim(block.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
