/// `M-37 Inspection Report` — uch mustaqil amal (tz-mobile 1417–1426).
///
/// **M108:** 3-band matni planshet varianti kanonik («to the DOT officer»).
/// `Send via email` va `Send the file` — **yozuv amallari**, faqat onlayn;
/// oflayn bo'lsa ular o'chadi va `Begin Inspection` taklif qilinadi.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/inspection_controller.dart';
import '../inspection_routes.dart';
import '../widgets/inspection_widgets.dart';
import '../widgets/send_email_sheet.dart';
import '../widgets/send_file_sheet.dart';

class InspectionReportScreen extends ConsumerWidget {
  const InspectionReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final InspectionActionsState state = ref.watch(inspectionActionsControllerProvider);
    final InspectionActionsController controller = ref.read(
      inspectionActionsControllerProvider.notifier,
    );

    Future<void> begin() async {
      final bool ok = await controller.begin();
      if (ok && context.mounted) {
        unawaited(context.push<void>(InspectionRoute.kiosk));
      }
    }

    return AdaptiveScaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.inspectionTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.commonCancel,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      banners: <Widget>[
        if (state.startError != null)
          BannerStrip(
            message: localizedApiError(l10n, state.startError!),
            tone: BannerTone.violation,
            actionLabel: l10n.inspectionRetry,
            onAction: () => begin().ignore(),
          ),
      ],
      phone: (BuildContext c) => _Body(state: state, onBegin: begin, twoColumn: false),
      tablet: (BuildContext c) => _Body(state: state, onBegin: begin, twoColumn: true),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onBegin, required this.twoColumn});

  final InspectionActionsState state;
  final Future<void> Function() onBegin;
  final bool twoColumn;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final Widget review = InspectionActionCard(
      title: l10n.inspectionReviewTitle,
      body: l10n.inspectionReviewBody,
      actionLabel: l10n.inspectionBeginAction,
      busy: state.starting,
      onAction: state.starting ? null : () => onBegin().ignore(),
    );
    final Widget email = InspectionActionCard(
      title: l10n.inspectionEmailTitle,
      body: l10n.inspectionEmailBody,
      actionLabel: l10n.inspectionEmailAction,
      hint: l10n.inspectionOnlineRequired,
      onAction: () => showSendEmailSheet(context).ignore(),
    );
    final Widget file = InspectionActionCard(
      title: l10n.inspectionFileTitle,
      body: l10n.inspectionFileBody,
      actionLabel: l10n.inspectionFileAction,
      hint: l10n.inspectionOnlineRequired,
      onAction: () => showSendFileSheet(context).ignore(),
    );

    if (twoColumn) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: review),
              const SizedBox(width: Spacing.s20),
              Expanded(child: email),
              const SizedBox(width: Spacing.s20),
              Expanded(child: file),
            ],
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: <Widget>[
        review,
        const SizedBox(height: Spacing.s20),
        email,
        const SizedBox(height: Spacing.s20),
        file,
      ],
    );
  }
}
