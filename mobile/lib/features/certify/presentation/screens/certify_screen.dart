/// `M-29 Certify (Last 8 days)` — Figma `1102:397`; `M-31 Not Ready` shu
/// ekrandagi holat (tz-mobile 1610–1636).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../certify_routes.dart';
import '../../domain/certify_models.dart';
import '../controllers/certify_list_controller.dart';
import '../controllers/certify_providers.dart';
import '../widgets/certify_widgets.dart';

class CertifyScreen extends ConsumerWidget {
  const CertifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<List<CertifyDay>> days = ref.watch(certifyWindowProvider);

    return AdaptiveScaffold(
      maxContentWidth: ContentWidth.wide,
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.certifyTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.commonCancel,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      phone: (BuildContext c) => CertifyDaysBody(days: days, twoColumn: false),
      tablet: (BuildContext c) => CertifyDaysBody(days: days, twoColumn: true),
    );
  }
}

class CertifyDaysBody extends ConsumerWidget {
  const CertifyDaysBody({required this.days, required this.twoColumn, super.key});

  final AsyncValue<List<CertifyDay>> days;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return asyncView<List<CertifyDay>>(
      days,
      loading: const LoadingSkeleton(itemCount: 5),
      error: (Object _) => ErrorState(
        message: l10n.errUnknown,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(certifyWindowProvider),
      ),
      data: (List<CertifyDay> list) => _List(days: list, twoColumn: twoColumn),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.days, required this.twoColumn});

  final List<CertifyDay> days;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final CertifyListController controller = ref.read(certifyListControllerProvider.notifier);
    // Tanlov o'zgarganda qayta chizilishi uchun kuzatiladi.
    ref.watch(certifyListControllerProvider);

    if (days.every((CertifyDay d) => !d.selectable) && days.isNotEmpty) {
      return Column(
        children: <Widget>[
          Expanded(
            child: EmptyState(title: l10n.certifyEmptyTitle, message: l10n.certifyEmptyMessage),
          ),
        ],
      );
    }

    final CertifyAction action = controller.actionFor(days);
    final int selectedCount = ref.watch(certifyListControllerProvider).selected.length;
    final String actionLabel = switch (action) {
      CertifyAction.today => l10n.certifyToday,
      CertifyAction.selected => l10n.certifySelected(selectedCount),
      CertifyAction.all || CertifyAction.none => l10n.certifyAll,
    };

    void openSign() {
      final List<DateTime> dates = controller.datesFor(days);
      if (dates.isEmpty) {
        return;
      }
      context.push(CertifyRoute.signFor(dates.last));
    }

    final Widget list = ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
      itemCount: days.length,
      separatorBuilder: (BuildContext _, int _) => const SizedBox(height: Spacing.s5),
      itemBuilder: (BuildContext _, int index) {
        final CertifyDay day = days[index];
        return CertifyDayTile(
          day: day,
          selected: controller.isSelected(day),
          onToggle: () => controller.toggle(day),
        );
      },
    );

    final Widget actions = Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AppButton.text(
                label: selectedCount == 0 ? l10n.certifySelectAll : l10n.certifyUnselectAll,
                onPressed: () =>
                    selectedCount == 0 ? controller.selectAll(days) : controller.clear(),
              ),
            ],
          ),
          const SizedBox(height: Spacing.s5),
          AppButton.primary(
            label: actionLabel,
            onPressed: action == CertifyAction.none ? null : openSign,
            expand: true,
          ),
        ],
      ),
    );

    if (twoColumn) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(flex: 2, child: list),
          const SizedBox(width: Spacing.s20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.s20),
              child: actions,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: list),
        actions,
      ],
    );
  }
}
