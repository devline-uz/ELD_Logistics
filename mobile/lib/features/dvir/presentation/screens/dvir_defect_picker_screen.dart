/// `M-33 Defect picker` — Figma `1169:1467` (tz-mobile 1367–1378).
///
/// Katalog serverdan (M105); `Engine` dublikati va `Refresh` bandi
/// **ko'rsatilmaydi** (#B-12), `Accident Photo` alohida blok.
/// Har nuqsonga izoh + ≤5 foto; kritik nuqsonda M106 ogohlantirishi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/dvir_models.dart';
import '../controllers/defect_picker_controller.dart';
import '../controllers/dvir_form_controller.dart';
import '../widgets/defect_tile.dart';
import '../widgets/dvir_widgets.dart';

class DvirDefectPickerScreen extends ConsumerStatefulWidget {
  const DvirDefectPickerScreen({required this.category, super.key});

  final DefectCategory category;

  @override
  ConsumerState<DvirDefectPickerScreen> createState() => _DvirDefectPickerScreenState();
}

class _DvirDefectPickerScreenState extends ConsumerState<DvirDefectPickerScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran ochilishida oldingi tanlov tiklanadi (qaytib kirishda yo'qolmaydi).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DvirFormState form = ref.read(dvirFormControllerProvider);
      unawaitedOpen(
        ref
            .read(defectPickerControllerProvider.notifier)
            .open(
              category: widget.category,
              initial: widget.category == DefectCategory.truck
                  ? form.draft.truckDefects
                  : form.draft.trailerDefects,
              accidentPhotoPaths: form.draft.accidentPhotoPaths,
            ),
      );
    });
  }

  /// `unawaited` o'rniga — `dart:async` importisiz o'qishga qulay.
  void unawaitedOpen(Future<void> future) {
    future.ignore();
  }

  void _save() {
    final DefectPickerState picker = ref.read(defectPickerControllerProvider);
    final DvirFormController form = ref.read(dvirFormControllerProvider.notifier)
      ..applyDefects(widget.category, picker.result);
    form.setAccidentPhotos(picker.accidentPhotoPaths);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DefectPickerState state = ref.watch(defectPickerControllerProvider);
    final DefectPickerController controller = ref.read(defectPickerControllerProvider.notifier);

    final String title = widget.category == DefectCategory.truck
        ? l10n.dvirTruckDefectsTitle
        : l10n.dvirTrailerDefectsTitle;

    return AdaptiveScaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: title,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.dvirClose,
          icon: const Icon(Icons.close),
        ),
      ),
      phone: (BuildContext c) => _Body(state: state, controller: controller, onSave: _save),
      tablet: (BuildContext c) => _Body(state: state, controller: controller, onSave: _save),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller, required this.onSave});

  final DefectPickerState state;
  final DefectPickerController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 6),
      );
    }
    if (state.error != null) {
      return ErrorState(
        message: localizedApiError(l10n, state.error!),
        retryLabel: l10n.commonRetry,
        onRetry: () => controller.reload(forceRefresh: true).ignore(),
      );
    }
    if (state.catalog.isEmpty) {
      return EmptyState(title: l10n.dvirCatalogEmpty, message: l10n.dvirCatalogEmptyHint);
    }

    final List<DefectType> visible = state.visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: Spacing.s15),
        AppTextField(
          hint: l10n.dvirDefectSearchHint,
          prefixIcon: Icons.search,
          onChanged: controller.search,
        ),
        if (state.criticalPrompt != null) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          BannerStrip(
            message: l10n.dvirCriticalWarning,
            tone: BannerTone.violation,
            actionLabel: l10n.dvirCriticalDismiss,
            onAction: controller.dismissCriticalPrompt,
          ),
        ],
        const SizedBox(height: Spacing.s10),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(title: l10n.dvirDefectsEmpty, message: l10n.dvirCatalogEmptyHint)
              : ListView.separated(
                  itemCount: visible.length + (state.accidentPhotoAvailable ? 1 : 0),
                  separatorBuilder: (BuildContext _, int _) => const SizedBox(height: Spacing.s5),
                  itemBuilder: (BuildContext c, int index) {
                    if (index == visible.length) {
                      return AccidentPhotoBlock(state: state, controller: controller);
                    }
                    final DefectType type = visible[index];
                    return DefectTile(
                      type: type,
                      defect: state.selected[type.id],
                      controller: controller,
                    );
                  },
                ),
        ),
        DvirActionBar(
          actionLabel: l10n.dvirSave,
          onAction: onSave,
          onCancel: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
