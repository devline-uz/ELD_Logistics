/// `M-21 Select shipping document` (modal) · `T-08 Select Shipping Document`.
///
/// Figma: `1517:53372` (planshet). `Switch co-driver` dan keyin ochiladi:
/// haydovchi trip'dagi har hujjat kimga tegishli ekanini belgilaydi (§3.3).
///
/// 4 holat: `yuklanish` · `bo'sh` (hujjat yo'q) · `to'la` · `xato`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/shipping_document_controller.dart';

/// Modalni profilga mos ko'rinishda ochadi.
Future<void> showShippingDocumentModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext ctx) => const ShippingDocumentModal(),
);

class ShippingDocumentModal extends ConsumerWidget {
  const ShippingDocumentModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ShippingDocumentState state = ref.watch(shippingDocumentControllerProvider);
    final ShippingDocumentController controller = ref.read(
      shippingDocumentControllerProvider.notifier,
    );

    ref.listen<ShippingDocumentState>(shippingDocumentControllerProvider, (
      ShippingDocumentState? previous,
      ShippingDocumentState next,
    ) {
      if (next.saved && previous?.saved != true) {
        Navigator.of(context).pop();
      }
    });

    final Widget body = ShippingDocumentBody(state: state, onOwnerChanged: controller.setOwner);

    return AdaptiveView(
      phone: (BuildContext c) => AppBottomSheet(
        title: l10n.authShippingDocTitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            body,
            const SizedBox(height: Spacing.s20),
            AppButton.primary(
              label: l10n.authShippingDocConfirm,
              busy: state.saving,
              onPressed: state.isEmpty ? null : controller.submit,
            ),
          ],
        ),
      ),
      tablet: (BuildContext c) => TabletModal(
        title: l10n.authShippingDocTitle,
        cancelLabel: l10n.commonCancel,
        actionLabel: l10n.authShippingDocConfirm,
        actionEnabled: !state.isEmpty && !state.saving,
        onAction: controller.submit,
        child: body,
      ),
    );
  }
}

/// Modal tanasi — test va goldenlarda to'g'ridan-to'g'ri ishlatiladi.
class ShippingDocumentBody extends StatelessWidget {
  const ShippingDocumentBody({required this.state, required this.onOwnerChanged, super.key});

  final ShippingDocumentState state;
  final void Function(String doc, ShippingDocOwner owner) onOwnerChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    if (state.loading) {
      return const LoadingSkeleton(itemCount: 3);
    }
    if (state.isEmpty) {
      return EmptyState(
        title: l10n.authShippingDocEmptyTitle,
        message: l10n.authShippingDocEmptyMessage,
        icon: Icons.description_outlined,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.authShippingDocSubtitle,
          style: context.text.body15.copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: Spacing.s15),
        for (final String doc in state.documents)
          _DocRow(
            document: doc,
            owner: state.ownerOf(doc),
            onChanged: (ShippingDocOwner owner) => onOwnerChanged(doc, owner),
          ),
        if (state.error != null) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          Text(
            localizedApiError(l10n, state.error!),
            style: context.text.body16.copyWith(color: context.colors.error),
          ),
        ],
      ],
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.document, required this.owner, required this.onChanged});

  final String document;
  final ShippingDocOwner owner;
  final ValueChanged<ShippingDocOwner> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              document,
              style: context.text.body11.copyWith(color: context.colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppChip(
            label: l10n.authShippingDocOwnerMyself,
            selected: owner == ShippingDocOwner.myself,
            onTap: () => onChanged(ShippingDocOwner.myself),
          ),
          const SizedBox(width: Spacing.s5),
          AppChip(
            label: l10n.authShippingDocOwnerCoDriver,
            selected: owner == ShippingDocOwner.coDriver,
            onTap: () => onChanged(ShippingDocOwner.coDriver),
          ),
        ],
      ),
    );
  }
}
