/// `M-41 Send the file` (tz-mobile 1447–1457).
///
/// `Type` — `Web service` / `Email`; `Email Address` faqat `Email` tanlanganda.
/// Natija: `InspectionTransferResult {format, file_key, size_bytes}` —
/// `fmcsa_eld_output` yoki `csv_pdf_zip`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/inspection_models.dart';
import '../controllers/inspection_send_controller.dart';

/// Modalni ochadi; `true` — fayl yuborildi.
Future<bool> showSendFileSheet(BuildContext context) async {
  final bool? result = await showAdaptiveModal<bool>(
    context: context,
    builder: (BuildContext modalContext) => const SendFileSheet(),
  );
  return result ?? false;
}

/// `format` → lokalizatsiya qilingan nom.
String transferFormatLabel(AppLocalizations l10n, InspectionOutputFormat format) =>
    switch (format) {
      InspectionOutputFormat.fmcsaEldOutput => l10n.inspectionFormatFmcsa,
      InspectionOutputFormat.csvPdfZip => l10n.inspectionFormatCsvPdfZip,
    };

/// Bayt hajmini qisqa ko'rinishga o'giradi (KB/MB, `en_US` guruhlash).
String transferSizeLabel(int? bytes) {
  if (bytes == null) {
    return kEmptyValue;
  }
  if (bytes < 1024) {
    return AppFormats.count(bytes);
  }
  final int kilobytes = (bytes / 1024).round();
  return kilobytes < 1024
      ? AppFormats.count(kilobytes)
      : AppFormats.count((kilobytes / 1024).round());
}

class SendFileSheet extends ConsumerWidget {
  const SendFileSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final InspectionTransferState state = ref.watch(inspectionTransferControllerProvider);
    final InspectionTransferController controller = ref.read(
      inspectionTransferControllerProvider.notifier,
    );

    Future<void> send() async {
      final bool ok = await controller.send();
      if (!ok || !context.mounted) {
        return;
      }
      final InspectionTransferState now = ref.read(inspectionTransferControllerProvider);
      final String message = now.result == null
          ? l10n.inspectionEmailSent(now.email)
          : l10n.inspectionFileSent(
              transferFormatLabel(l10n, now.result!.format),
              transferSizeLabel(now.result!.sizeBytes),
            );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop(true);
    }

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.inspectionFileModalHint,
          style: context.text.body14.copyWith(color: context.colors.textSecondary),
        ),
        if (state.error != null) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          BannerStrip(message: localizedApiError(l10n, state.error!), tone: BannerTone.violation),
        ],
        const SizedBox(height: Spacing.s15),
        Text(
          l10n.inspectionTransferType,
          style: context.text.body14.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: Spacing.s10),
        Row(
          children: <Widget>[
            AppChip(
              label: l10n.inspectionTransferWebService,
              selected: state.type == InspectionTransferType.webService,
              onTap: () => controller.setType(InspectionTransferType.webService),
            ),
            const SizedBox(width: Spacing.s10),
            AppChip(
              label: l10n.inspectionTransferEmail,
              selected: state.type == InspectionTransferType.email,
              onTap: () => controller.setType(InspectionTransferType.email),
            ),
          ],
        ),
        if (state.needsEmail) ...<Widget>[
          const SizedBox(height: Spacing.s15),
          AppTextField(
            label: l10n.inspectionEmailAddress,
            hint: l10n.inspectionEmailPlaceholder,
            keyboardType: TextInputType.emailAddress,
            errorText: state.showValidation && !state.isEmailValid
                ? l10n.inspectionEmailInvalid
                : null,
            onChanged: controller.setEmail,
          ),
        ],
        const SizedBox(height: Spacing.s15),
        AppTextField(
          label: l10n.inspectionCommentLabel,
          hint: l10n.inspectionCommentHint,
          maxLines: 3,
          minLines: 2,
          onChanged: controller.setComment,
        ),
      ],
    );

    if (DeviceProfile.of(context).isTablet) {
      return TabletModal(
        title: l10n.inspectionFileModalTitle,
        cancelLabel: l10n.commonCancel,
        onCancel: () => Navigator.of(context).pop(false),
        actionLabel: l10n.inspectionFileSend,
        actionEnabled: state.canSend,
        onAction: state.canSend ? () => send().ignore() : null,
        child: body,
      );
    }

    return AppBottomSheet(
      title: l10n.inspectionFileModalTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          body,
          const SizedBox(height: Spacing.s20),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: AppButton.primary(
                  label: l10n.inspectionFileSend,
                  busy: state.sending,
                  onPressed: state.canSend ? () => send().ignore() : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
