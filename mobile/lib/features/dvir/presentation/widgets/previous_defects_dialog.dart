/// `M-36 Previous defects certification` 🎨 (tz-mobile 1387–1404, `tz.md` §7.2).
///
/// Pre-trip DVIR boshlanishida ochiladi. Telefonda `AppBottomSheet`,
/// planshetda `TabletModal` — `showAdaptiveModal` profil bo'yicha tanlaydi (M7).
///
/// Oflayn: modal baribir ko'rsatiladi, sertifikatsiya outbox'ga tushadi va
/// yangi DVIR **bloklanmaydi** (`Later` bilan yopiladi).
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/dvir_models.dart';
import '../controllers/previous_defects_controller.dart';

/// Kutayotgan hisobot bo'lsa modalni ochadi va natijani snackbar bilan bildiradi.
///
/// Qaytadi: `true` — kamida bitta hisobot sertifikatlandi/navbatga qo'yildi.
Future<bool> showPreviousDefectsDialog(BuildContext context) async {
  final bool? result = await showAdaptiveModal<bool>(
    context: context,
    builder: (BuildContext modalContext) => const PreviousDefectsDialog(),
  );
  return result ?? false;
}

class PreviousDefectsDialog extends ConsumerWidget {
  const PreviousDefectsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final PreviousDefectsState state = ref.watch(previousDefectsControllerProvider);
    final PreviousDefectsController controller = ref.read(
      previousDefectsControllerProvider.notifier,
    );

    ref.listen<PreviousDefectsState>(previousDefectsControllerProvider, (
      PreviousDefectsState? was,
      PreviousDefectsState now,
    ) {
      if (was?.outcome == now.outcome || now.outcome == PreviousDefectsOutcome.none) {
        return;
      }
      final String message = switch (now.outcome) {
        PreviousDefectsOutcome.queued => l10n.dvirCertifyQueued,
        PreviousDefectsOutcome.alreadyCertified => l10n.dvirCertifyAlready,
        PreviousDefectsOutcome.certified => l10n.dvirCertifyDone,
        PreviousDefectsOutcome.none => l10n.dvirCertifyDone,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      if (now.reports.isEmpty) {
        Navigator.of(context).pop(true);
      }
    });

    final Widget body = _DialogBody(state: state, controller: controller);

    return DeviceProfile.of(context).isTablet
        ? TabletModal(
            title: l10n.dvirCertifyTitle,
            cancelLabel: l10n.dvirCertifyLater,
            onCancel: () => Navigator.of(context).pop(false),
            actionLabel: l10n.dvirCertifyConfirm,
            actionEnabled: state.canConfirm,
            onAction: state.canConfirm ? () => controller.certify().ignore() : null,
            child: body,
          )
        : AppBottomSheet(title: l10n.dvirCertifyTitle, child: body);
  }
}

class _DialogBody extends StatelessWidget {
  const _DialogBody({required this.state, required this.controller});

  final PreviousDefectsState state;
  final PreviousDefectsController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    if (state.loading) {
      // Modal balandligi cheklanmagan — skeleton uchun aniq balandlik kerak.
      return const SizedBox(height: 160, child: LoadingSkeleton(itemCount: 2, animate: false));
    }

    final DvirReport? report = state.current;
    if (report == null) {
      return SizedBox(
        height: 220,
        child: EmptyState(
          title: l10n.dvirCertifyTitle,
          message: l10n.dvirDetailsNoDefects,
          icon: Icons.verified_outlined,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (state.submitError != null) ...<Widget>[
          BannerStrip(
            message: localizedApiError(l10n, state.submitError!),
            tone: BannerTone.violation,
          ),
          const SizedBox(height: Spacing.s10),
        ],
        Text(
          l10n.dvirCertifyMessage(
            AppFormats.orNa(report.unitNumber ?? report.unitId),
            AppFormats.fullDateTime(report.repairedAt ?? report.createdAt),
          ),
          style: context.text.body14.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: Spacing.s15),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final DvirReportDefect defect in report.defects)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
                    child: Text(
                      defect.name,
                      style: context.text.body13.copyWith(color: c.textPrimary),
                    ),
                  ),
                if (report.mechanicNote != null)
                  Text(
                    report.mechanicNote!,
                    style: context.text.body16.copyWith(color: c.textSecondary),
                  ),
                if (report.invoiceKey != null)
                  Text(
                    l10n.dvirDetailsInvoice,
                    style: context.text.body16.copyWith(color: c.textSecondary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.s15),
        Text(l10n.dvirDriverSignature, style: context.text.body14.copyWith(color: c.textPrimary)),
        const SizedBox(height: Spacing.s10),
        SignaturePad(
          clearLabel: l10n.dvirSignatureClear,
          saveLabel: l10n.dvirSignatureSave,
          hint: l10n.dvirSignatureHint,
          onSaved: (Uint8List bytes) => controller.saveSignature(bytes).ignore(),
        ),
        if (!DeviceProfile.of(context).isTablet) ...<Widget>[
          const SizedBox(height: Spacing.s15),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.dvirCertifyLater,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: AppButton.primary(
                  label: l10n.dvirCertifyConfirm,
                  busy: state.submitting,
                  onPressed: state.canConfirm ? () => controller.certify().ignore() : null,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
