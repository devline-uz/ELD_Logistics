/// `M-12 Change duty status` (`/duty/change`, Figma `1083:10550`).
///
/// Bitta `DutyStatusController` (M7) + ikkita ko'rinish: telefonda vertikal
/// forma, planshetda (`T-04`) ikki ustun.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../data/duty_status_providers.dart';
import '../../domain/duty_status_models.dart';
import '../../domain/duty_status_rules.dart';
import '../../domain/hos_snapshot.dart';
import '../controllers/duty_status_controller.dart';
import '../widgets/duty_form_widgets.dart';
import '../widgets/hos_indicator_row.dart';
import '../widgets/location_inaccurate_dialog.dart';
import '../widgets/quick_notes_sheet.dart';

class ChangeDutyStatusScreen extends ConsumerWidget {
  const ChangeDutyStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final DutyFormState state = ref.watch(dutyStatusControllerProvider);
    final DutyStatusController controller = ref.read(dutyStatusControllerProvider.notifier);
    final HosSnapshot snapshot =
        ref.watch(hosSnapshotProvider).value ??
        HosSnapshot.empty(state.context.since ?? DateTime.utc(2000));
    final Map<String, String> trailerNumbers = <String, String>{
      for (final TrailerOption option
          in ref.watch(trailersProvider).value ?? const <TrailerOption>[])
        option.id: option.number,
    };

    return AdaptiveScaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.dutyChangeTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.commonCancel,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      banners: <Widget>[
        // M66: ELD ulanmagan — event `manual_no_eld` bo'lib yoziladi.
        if (!state.eldConnected)
          BannerStrip(message: l10n.dutyManualNoEld, tone: BannerTone.warning),
      ],
      phone: (BuildContext c) => _Body(
        state: state,
        controller: controller,
        snapshot: snapshot,
        trailerNumbers: trailerNumbers,
        twoColumn: false,
      ),
      tablet: (BuildContext c) => _Body(
        state: state,
        controller: controller,
        snapshot: snapshot,
        trailerNumbers: trailerNumbers,
        twoColumn: true,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.controller,
    required this.snapshot,
    required this.trailerNumbers,
    required this.twoColumn,
  });

  final DutyFormState state;
  final DutyStatusController controller;
  final HosSnapshot snapshot;
  final Map<String, String> trailerNumbers;
  final bool twoColumn;

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 3),
      );
    }

    final Widget indicators = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
      child: HosIndicatorRow(snapshot: snapshot),
    );
    final Widget form = _FormCard(
      state: state,
      controller: controller,
      trailerNumbers: trailerNumbers,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.s20),
      children: twoColumn ? <Widget>[indicators, form] : <Widget>[indicators, form],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.state, required this.controller, required this.trailerNumbers});

  final DutyFormState state;
  final DutyStatusController controller;
  final Map<String, String> trailerNumbers;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final DutySpecial? special = state.availableSpecial;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DutyStatusSelector(
            selected: state.draft.status,
            sleeperAvailable: state.context.sleeperAvailable,
            onSelected: controller.selectStatus,
          ),
          if (special != null) ...<Widget>[
            const SizedBox(height: Spacing.s10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    special == DutySpecial.personalConveyance
                        ? l10n.dutyPersonalConveyance
                        : l10n.dutyYardMove,
                    style: context.text.body13.copyWith(color: c.textPrimary),
                  ),
                ),
                Switch.adaptive(
                  value: state.draft.special == special,
                  onChanged: (bool value) => controller.toggleSpecial(enabled: value),
                ),
              ],
            ),
            if (state.draft.special != DutySpecial.none)
              AppTextField(
                label: l10n.dutyReasonLabel,
                hint: l10n.dutyReasonHint,
                maxLength: kMaxDutyNotesLength,
                onChanged: controller.setReason,
                errorText: state.issues.contains(DutyIssue.reasonRequired)
                    ? l10n.dutyReasonRequired
                    : null,
              ),
          ],
          const SizedBox(height: Spacing.s15),
          AppTextField(
            label: l10n.dutyLocationLabel,
            hint: l10n.dutyLocationHint,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: state.draft.locationText,
                selection: TextSelection.collapsed(offset: state.draft.locationText.length),
              ),
            ),
            onChanged: controller.setLocationText,
            suffix: state.locationBusy
                ? const SizedBox(
                    width: Spacing.s20,
                    height: Spacing.s20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : state.locationInaccurate
                ? IconButton(
                    tooltip: l10n.dutyLocationInaccurate,
                    icon: Icon(Icons.warning_amber_outlined, color: c.warning),
                    onPressed: () => _confirmLocation(context),
                  )
                : null,
          ),
          if (state.locationError)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.s5),
              child: Text(
                l10n.locationUpdateFailed,
                style: context.text.body16.copyWith(color: c.error),
              ),
            ),
          const SizedBox(height: Spacing.s15),
          AppTextField(
            label: l10n.dutyNotesLabel,
            hint: l10n.dutyNotesHint,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: state.draft.notes,
                selection: TextSelection.collapsed(offset: state.draft.notes.length),
              ),
            ),
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(kMaxDutyNotesLength),
            ],
            helperText: l10n.dutyNotesCounter(state.draft.notes.length, kMaxDutyNotesLength),
            errorText: state.issues.contains(DutyIssue.notesTooLong) ? l10n.dutyNotesTooLong : null,
            onChanged: controller.setNotes,
            suffix: IconButton(
              tooltip: l10n.dutyAddQuickNote,
              icon: const Icon(Icons.add),
              onPressed: () => _pickQuickNotes(context),
            ),
          ),
          if (state.notesTruncated)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.s5),
              child: Text(
                l10n.quickNotesTruncated,
                style: context.text.body16.copyWith(color: c.warningDark),
              ),
            ),
          const SizedBox(height: Spacing.s15),
          DutyChipField(
            label: l10n.dutyTrailerLabel,
            values: <String>[
              for (final String id in state.draft.trailerIds) trailerNumbers[id] ?? id,
            ],
            onRemove: (String value) => controller.toggleTrailer(
              trailerNumbers.entries
                      .where((MapEntry<String, String> e) => e.value == value)
                      .map((MapEntry<String, String> e) => e.key)
                      .firstOrNull ??
                  value,
            ),
          ),
          const SizedBox(height: Spacing.s15),
          DutyChipField(
            label: l10n.dutyDocumentLabel,
            values: state.draft.shippingDocIds,
            onRemove: controller.toggleShippingDoc,
          ),
          if (state.error != null) ...<Widget>[
            const SizedBox(height: Spacing.s10),
            Text(
              localizedApiError(l10n, state.error!),
              style: context.text.body16.copyWith(color: c.error),
            ),
          ],
          const SizedBox(height: Spacing.s20),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: AppButton.primary(
                  label: l10n.dutySave,
                  busy: state.saving,
                  onPressed: state.canSave ? () => _save(context) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickQuickNotes(BuildContext context) async {
    final List<String>? picked = await showQuickNotesSheet(context);
    if (picked != null) {
      controller.addQuickNotes(picked);
    }
  }

  Future<void> _confirmLocation(BuildContext context) async {
    final bool update = await showLocationInaccurateDialog(context);
    if (update) {
      await controller.refreshLocation();
    }
  }

  Future<void> _save(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    final DutySubmitOutcome outcome = await controller.save();
    if (outcome == DutySubmitOutcome.none) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          outcome == DutySubmitOutcome.queuedOffline ? l10n.dutyQueuedOffline : l10n.dutySaved,
        ),
      ),
    );
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}
