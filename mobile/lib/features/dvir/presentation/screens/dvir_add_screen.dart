/// `M-32 Add DVIR` — Figma `1089:4441` (tz-mobile 1355–1366).
///
/// Bitta `DvirFormController` (M7) + ikkita `View`. Telefonda vertikal forma,
/// planshetda ikki ustun (forma / `Driver Information`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/dvir_models.dart';
import '../controllers/dvir_form_controller.dart';
import '../dvir_routes.dart';
import '../widgets/dvir_widgets.dart';
import '../widgets/trailer_picker_sheet.dart';

class DvirAddScreen extends ConsumerWidget {
  const DvirAddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final DvirFormState state = ref.watch(dvirFormControllerProvider);
    final DvirFormController controller = ref.read(dvirFormControllerProvider.notifier);

    return AdaptiveScaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.dvirAddTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.dvirBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      banners: <Widget>[
        if (!state.loading && state.loadError == null && state.draft.unitId.isEmpty)
          BannerStrip(message: l10n.dvirNoUnit, tone: BannerTone.warning),
      ],
      phone: (BuildContext c) => _Body(state: state, controller: controller, twoColumn: false),
      tablet: (BuildContext c) => _Body(state: state, controller: controller, twoColumn: true),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller, required this.twoColumn});

  final DvirFormState state;
  final DvirFormController controller;
  final bool twoColumn;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 3),
      );
    }
    if (state.loadError != null) {
      return ErrorState(
        message: localizedApiError(l10n, state.loadError!),
        retryLabel: l10n.commonRetry,
        onRetry: controller.load,
      );
    }

    final Widget form = _FormCard(state: state, controller: controller);
    final Widget info = _DriverInfoCard(state: state);
    final Widget notes = DvirLabeledField(
      label: l10n.dvirNotesLabel,
      child: AppTextField(
        hint: l10n.dvirNotesHint,
        maxLines: 3,
        minLines: 2,
        onChanged: controller.setNotes,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
            children: twoColumn
                ? <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: form),
                        const SizedBox(width: Spacing.s20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              info,
                              const SizedBox(height: Spacing.s20),
                              notes,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                : <Widget>[
                    form,
                    const SizedBox(height: Spacing.s20),
                    info,
                    const SizedBox(height: Spacing.s20),
                    notes,
                  ],
          ),
        ),
        DvirActionBar(
          actionLabel: l10n.dvirNext,
          onAction: state.canProceed ? () => context.push(DvirRoute.review) : null,
          onCancel: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.state, required this.controller});

  final DvirFormState state;
  final DvirFormController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DvirDraft draft = state.draft;

    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DvirLabeledField(
            label: l10n.dvirTypeLabel,
            child: DvirTypeToggle(value: draft.type, onChanged: controller.setType),
          ),
          const SizedBox(height: Spacing.s20),
          DvirLabeledField(
            label: l10n.dvirUnitNumberLabel,
            child: DvirValueBox(
              text: AppFormats.orNa(draft.unitNumber ?? state.context?.unitNumber),
              placeholder: draft.unitId.isEmpty,
            ),
          ),
          const SizedBox(height: Spacing.s20),
          DvirLabeledField(
            label: l10n.dvirTrailersLabel,
            child: DvirValueBox(
              text: draft.trailerIds.isEmpty
                  ? l10n.dvirTrailersHint
                  : state.trailerLabels.join(', '),
              placeholder: draft.trailerIds.isEmpty,
              trailing: const Icon(Icons.add, size: 20),
              onTap: () => showTrailerPicker(context: context, controller: controller),
            ),
          ),
          const SizedBox(height: Spacing.s20),
          _DefectsField(
            label: l10n.dvirTruckDefectsLabel,
            count: draft.truckDefects.length,
            category: DefectCategory.truck,
          ),
          const SizedBox(height: Spacing.s20),
          _DefectsField(
            label: l10n.dvirTrailerDefectsLabel,
            count: draft.trailerDefects.length,
            category: DefectCategory.trailer,
          ),
          if (state.showCriticalWarning) ...<Widget>[
            const SizedBox(height: Spacing.s20),
            BannerStrip(message: l10n.dvirCriticalWarning, tone: BannerTone.violation),
          ],
        ],
      ),
    );
  }
}

class _DefectsField extends StatelessWidget {
  const _DefectsField({required this.label, required this.count, required this.category});

  final String label;
  final int count;
  final DefectCategory category;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return DvirLabeledField(
      label: label,
      child: DvirValueBox(
        text: count == 0 ? l10n.dvirAddDefectsHint : l10n.dvirDefectsSelected(count),
        placeholder: count == 0,
        trailing: const Icon(Icons.add, size: 20),
        onTap: () => context.push(DvirRoute.defectsFor(category)),
      ),
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  const _DriverInfoCard({required this.state});

  final DvirFormState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DvirContext? ctx = state.context;
    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DvirInfoRow(
            label: l10n.dvirDriverInfoTime,
            value: AppFormats.fullDateTime(ctx?.capturedAt),
          ),
          DvirInfoRow(
            label: l10n.dvirDriverInfoLocation,
            value: AppFormats.orNa(ctx?.locationText),
          ),
          DvirInfoRow(
            label: l10n.dvirDriverInfoOdometer,
            value: formatOdometer(context, ctx?.odometerMeters),
          ),
        ],
      ),
    );
  }
}

/// `odometer_m` (metr) → mil (US). Bo'sh bo'lsa `N/A` (#B-10).
String formatOdometer(BuildContext context, int? meters) => meters == null
    ? kEmptyValue
    : context.l10n.dvirOdometerMiles(AppFormats.count((meters / 1609.344).round()));
