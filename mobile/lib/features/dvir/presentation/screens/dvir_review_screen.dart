/// `M-34 DVIR review + Driver signature` — Figma `1089:4441` oqimining
/// uchinchi qadami (tz-mobile 1379–1396).
///
/// Bitta `DvirFormController` (M7) — telefon va planshet (T-30) ulashadi.
/// **M104:** dizayndagi `Selected defects needs to be fixed` / `… fixed`
/// tanlovi **olib tashlangan** — `repaired` holatini faqat mexanik qo'yadi.
///
/// Dark tema Figma da chizilmagan: barcha rang `core/ui` tokenlaridan.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/dvir_models.dart';
import '../controllers/dvir_form_controller.dart';
import '../widgets/dvir_widgets.dart';

class DvirReviewScreen extends ConsumerWidget {
  const DvirReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final DvirFormState state = ref.watch(dvirFormControllerProvider);
    final DvirFormController controller = ref.read(dvirFormControllerProvider.notifier);

    ref.listen<DvirFormState>(dvirFormControllerProvider, (DvirFormState? was, DvirFormState now) {
      if (was?.outcome == now.outcome || now.outcome == DvirSubmitOutcome.none) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            now.outcome == DvirSubmitOutcome.queued
                ? l10n.dvirSubmittedQueued
                : l10n.dvirSubmittedOnline,
          ),
        ),
      );
      controller.reset();
      Navigator.of(context).popUntil((Route<Object?> route) => route.isFirst);
    });

    return AdaptiveScaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.dvirReviewTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.dvirBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      banners: <Widget>[
        if (state.submitError != null)
          BannerStrip(
            message: localizedApiError(l10n, state.submitError!),
            tone: BannerTone.violation,
          ),
        if (state.showCriticalWarning)
          BannerStrip(message: l10n.dvirCriticalWarning, tone: BannerTone.violation),
      ],
      phone: (BuildContext c) =>
          _ReviewBody(state: state, controller: controller, twoColumn: false),
      tablet: (BuildContext c) =>
          _ReviewBody(state: state, controller: controller, twoColumn: true),
    );
  }
}

class _ReviewBody extends StatelessWidget {
  const _ReviewBody({required this.state, required this.controller, required this.twoColumn});

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

    final Widget summary = _SummaryCard(state: state);
    final Widget signature = _SignatureCard(state: state, controller: controller);

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
                        Expanded(child: summary),
                        const SizedBox(width: Spacing.s20),
                        Expanded(child: signature),
                      ],
                    ),
                  ]
                : <Widget>[summary, const SizedBox(height: Spacing.s20), signature],
          ),
        ),
        DvirActionBar(
          actionLabel: state.submitting ? l10n.dvirSubmitting : l10n.dvirConfirm,
          busy: state.submitting,
          onAction: state.canConfirm ? controller.submit : null,
          onCancel: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

/// Tanlangan nuqsonlar xulosasi (truck + trailer), izoh va trailerlar.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final DvirFormState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DvirDraft draft = state.draft;

    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DvirInfoRow(
            label: l10n.dvirTypeLabel,
            value: draft.type == DvirType.preTrip ? l10n.dvirTypePreTrip : l10n.dvirTypePostTrip,
          ),
          DvirInfoRow(label: l10n.dvirUnitNumberLabel, value: AppFormats.orNa(draft.unitNumber)),
          DvirInfoRow(
            label: l10n.dvirTrailersLabel,
            value: draft.trailerIds.isEmpty ? kEmptyValue : state.trailerLabels.join(', '),
          ),
          DvirInfoRow(label: l10n.dvirNotesLabel, value: AppFormats.orNa(draft.notes)),
          const SizedBox(height: Spacing.s15),
          if (!draft.hasDefects)
            Text(
              l10n.dvirReviewDefectsEmpty,
              style: context.text.body14.copyWith(color: context.colors.textSecondary),
            )
          else ...<Widget>[
            _DefectGroup(title: l10n.dvirTruckDefectsTitle, defects: draft.truckDefects),
            _DefectGroup(title: l10n.dvirTrailerDefectsTitle, defects: draft.trailerDefects),
          ],
        ],
      ),
    );
  }
}

class _DefectGroup extends StatelessWidget {
  const _DefectGroup({required this.title, required this.defects});

  final String title;
  final List<DvirDefect> defects;

  @override
  Widget build(BuildContext context) {
    if (defects.isEmpty) {
      return const SizedBox.shrink();
    }
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: context.text.body14.copyWith(color: c.textPrimary)),
          const SizedBox(height: Spacing.s5),
          for (final DvirDefect defect in defects)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.circle, size: 6, color: c.textSecondary),
                  const SizedBox(width: Spacing.s10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          defect.type.name,
                          style: context.text.body13.copyWith(color: c.textPrimary),
                        ),
                        if (defect.note != null && defect.note!.trim().isNotEmpty)
                          Text(
                            defect.note!,
                            style: context.text.body16.copyWith(color: c.textSecondary),
                          ),
                        if (defect.photoCount > 0)
                          Text(
                            context.l10n.dvirDefectPhotoCount(
                              defect.photoCount,
                              DvirDefect.maxPhotos,
                            ),
                            style: context.text.body16.copyWith(color: c.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  if (defect.type.isCritical)
                    StatusBadge(
                      label: context.l10n.dvirCriticalBadge,
                      tone: StatusTone.error,
                      dense: true,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// `Driver Signature` — imzo chizilgach `files_queue` ga qo'yiladi.
class _SignatureCard extends StatelessWidget {
  const _SignatureCard({required this.state, required this.controller});

  final DvirFormState state;
  final DvirFormController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool signed = state.draft.isSignable;

    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.dvirDriverSignature,
            style: context.text.body14.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: Spacing.s10),
          SignaturePad(
            clearLabel: l10n.dvirSignatureClear,
            saveLabel: l10n.dvirSignatureSave,
            hint: l10n.dvirSignatureHint,
            onSaved: (Uint8List bytes) => controller.saveSignature(bytes).ignore(),
          ),
          const SizedBox(height: Spacing.s10),
          Text(
            signed ? l10n.dvirSignatureSaved : l10n.dvirSignatureRequired,
            style: context.text.body16.copyWith(
              color: signed ? context.colors.success : context.colors.error,
            ),
          ),
        ],
      ),
    );
  }
}
