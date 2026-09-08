/// `M-35 DVIR details` (tz-mobile 1405–1421).
///
/// **M107:** faqat o'qish — haydovchi DVIR ni tahrirlay/o'chira olmaydi.
/// **M103:** badge faqat serverdagi `kind` maydonidan (`dvirBadgeOf`).
/// PDF — faqat onlayn (`GET /dvir-reports/{id}/pdf`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/dvir_badge.dart';
import '../../domain/dvir_models.dart';
import '../controllers/dvir_details_controller.dart';
import '../screens/dvir_add_screen.dart' show formatOdometer;
import '../widgets/dvir_widgets.dart';

class DvirDetailsScreen extends ConsumerWidget {
  const DvirDetailsScreen({required this.reportId, super.key});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<DvirReport?> report = ref.watch(dvirReportProvider(reportId));
    final DvirPdfState pdf = ref.watch(dvirPdfControllerProvider);

    return AdaptiveScaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBarPrimary(
        title: l10n.dvirDetailsTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.dvirBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      banners: <Widget>[
        if (pdf.error != null)
          BannerStrip(message: l10n.dvirDetailsPdfOffline, tone: BannerTone.warning),
      ],
      phone: (BuildContext c) => _Body(report: report, pdf: pdf, id: reportId, twoColumn: false),
      tablet: (BuildContext c) => _Body(report: report, pdf: pdf, id: reportId, twoColumn: true),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.report, required this.pdf, required this.id, required this.twoColumn});

  final AsyncValue<DvirReport?> report;
  final DvirPdfState pdf;
  final String id;
  final bool twoColumn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    // `AsyncValue.when` ishlatilmaydi: Riverpod 3 xatodan keyin avtomatik
    // qayta urinadi va holat `AsyncError(isLoading: true)` bo'lib qoladi —
    // `when` bunda yuklanishni ko'rsatib, `ErrorState` ni yashiradi.
    if (report.hasError) {
      return ErrorState(
        message: localizedError(l10n, report.error!),
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(dvirReportProvider(id)),
      );
    }
    if (!report.hasValue) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.s20),
        child: LoadingSkeleton(itemCount: 4),
      );
    }

    final DvirReport? value = report.value;
    if (value == null) {
      return EmptyState(
        title: l10n.dvirDetailsNotFound,
        message: l10n.dvirDetailsImmutable,
        icon: Icons.description_outlined,
      );
    }
    final Widget head = _HeaderCard(report: value);
    final Widget defects = _DefectsCard(report: value);
    final Widget footer = _FooterCard(report: value, pdf: pdf, id: id);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s20),
      children: twoColumn
          ? <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        head,
                        const SizedBox(height: Spacing.s20),
                        footer,
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.s20),
                  Expanded(child: defects),
                ],
              ),
            ]
          : <Widget>[
              head,
              const SizedBox(height: Spacing.s20),
              defects,
              const SizedBox(height: Spacing.s20),
              footer,
            ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.report});

  final DvirReport report;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DvirBadgeView(
              badge: dvirBadgeOf(
                kind: report.kind,
                status: report.status,
                isLocalDraft: report.isLocalDraft,
              ),
            ),
          ),
          const SizedBox(height: Spacing.s15),
          DvirInfoRow(
            label: l10n.dvirDriverInfoTime,
            value: AppFormats.fullDateTime(report.createdAt),
          ),
          DvirInfoRow(
            label: l10n.dvirDriverInfoLocation,
            value: AppFormats.orNa(report.locationText),
          ),
          DvirInfoRow(
            label: l10n.dvirDriverInfoOdometer,
            value: formatOdometer(context, report.odometerMeters),
          ),
          DvirInfoRow(
            label: l10n.dvirTypeLabel,
            value: report.type == DvirType.preTrip ? l10n.dvirTypePreTrip : l10n.dvirTypePostTrip,
          ),
          DvirInfoRow(label: l10n.dvirUnitNumberLabel, value: AppFormats.orNa(report.unitNumber)),
          DvirInfoRow(
            label: l10n.dvirTrailersLabel,
            value: report.trailerIds.isEmpty ? kEmptyValue : report.trailerIds.join(', '),
          ),
          DvirInfoRow(label: l10n.dvirNotesLabel, value: AppFormats.orNa(report.notes)),
        ],
      ),
    );
  }
}

class _DefectsCard extends StatelessWidget {
  const _DefectsCard({required this.report});

  final DvirReport report;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    if (report.defects.isEmpty) {
      return DvirCard(
        child: Text(
          l10n.dvirDetailsNoDefects,
          style: context.text.body14.copyWith(color: context.colors.textSecondary),
        ),
      );
    }
    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _DefectSection(title: l10n.dvirTruckDefectsTitle, defects: report.truckDefects),
          _DefectSection(title: l10n.dvirTrailerDefectsTitle, defects: report.trailerDefects),
        ],
      ),
    );
  }
}

class _DefectSection extends StatelessWidget {
  const _DefectSection({required this.title, required this.defects});

  final String title;
  final List<DvirReportDefect> defects;

  @override
  Widget build(BuildContext context) {
    if (defects.isEmpty) {
      return const SizedBox.shrink();
    }
    final AppColors c = context.colors;
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: context.text.body14.copyWith(color: c.textPrimary)),
          const SizedBox(height: Spacing.s5),
          for (final DvirReportDefect defect in defects)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          defect.name,
                          style: context.text.body13.copyWith(color: c.textPrimary),
                        ),
                      ),
                      if (defect.isCritical)
                        StatusBadge(
                          label: l10n.dvirCriticalBadge,
                          tone: StatusTone.error,
                          dense: true,
                        ),
                    ],
                  ),
                  if (defect.note != null && defect.note!.trim().isNotEmpty)
                    Text(defect.note!, style: context.text.body16.copyWith(color: c.textSecondary)),
                  if (defect.photoKeys.isNotEmpty)
                    Text(
                      l10n.dvirDefectPhotoCount(defect.photoKeys.length, DvirDefect.maxPhotos),
                      style: context.text.body16.copyWith(color: c.textSecondary),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Imzolar, invoice, PDF va M107 eslatmasi.
class _FooterCard extends ConsumerWidget {
  const _FooterCard({required this.report, required this.pdf, required this.id});

  final DvirReport report;
  final DvirPdfState pdf;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DvirInfoRow(
            label: l10n.dvirDriverSignature,
            value: report.driverSignatureKey == null ? kEmptyValue : l10n.dvirSignatureSaved,
          ),
          if (report.mechanicSignatureKey != null)
            DvirInfoRow(label: l10n.dvirDetailsMechanicSignature, value: l10n.dvirSignatureSaved),
          if (report.mechanicNote != null)
            DvirInfoRow(
              label: l10n.dvirDetailsMechanicNote,
              value: AppFormats.orNa(report.mechanicNote),
            ),
          if (report.invoiceKey != null)
            DvirInfoRow(label: l10n.dvirDetailsInvoice, value: AppFormats.orNa(report.invoiceKey)),
          const SizedBox(height: Spacing.s15),
          AppButton.secondary(
            label: l10n.dvirDetailsDownloadPdf,
            icon: Icons.download_outlined,
            busy: pdf.busy,
            onPressed: report.isLocalDraft
                ? null
                : () => ref.read(dvirPdfControllerProvider.notifier).download(id).ignore(),
          ),
          const SizedBox(height: Spacing.s10),
          Text(
            l10n.dvirDetailsImmutable,
            style: context.text.body16.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
