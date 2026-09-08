/// `M-40 Send via email` (tz-mobile 1444–1446).
///
/// Telefonda `AppBottomSheet`, planshetda `TabletModal` (`T-18`) — bitta
/// `InspectionEmailController` (M7).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/inspection_send_controller.dart';

/// Modalni ochadi; `true` — xat yuborildi.
Future<bool> showSendEmailSheet(BuildContext context) async {
  final bool? result = await showAdaptiveModal<bool>(
    context: context,
    builder: (BuildContext modalContext) => const SendEmailSheet(),
  );
  return result ?? false;
}

class SendEmailSheet extends ConsumerWidget {
  const SendEmailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final InspectionEmailState state = ref.watch(inspectionEmailControllerProvider);
    final InspectionEmailController controller = ref.read(
      inspectionEmailControllerProvider.notifier,
    );

    Future<void> send() async {
      final bool ok = await controller.send();
      if (!ok || !context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.inspectionEmailSent(state.email))));
      Navigator.of(context).pop(true);
    }

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.inspectionEmailModalHint,
          style: context.text.body14.copyWith(color: context.colors.textSecondary),
        ),
        if (state.error != null) ...<Widget>[
          const SizedBox(height: Spacing.s10),
          BannerStrip(message: localizedApiError(l10n, state.error!), tone: BannerTone.violation),
        ],
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
        title: l10n.inspectionEmailModalTitle,
        cancelLabel: l10n.commonCancel,
        onCancel: () => Navigator.of(context).pop(false),
        actionLabel: l10n.inspectionEmailSend,
        actionEnabled: state.canSend,
        onAction: state.canSend ? () => send().ignore() : null,
        child: body,
      );
    }

    return AppBottomSheet(
      title: l10n.inspectionEmailModalTitle,
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
                  label: l10n.inspectionEmailSend,
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
