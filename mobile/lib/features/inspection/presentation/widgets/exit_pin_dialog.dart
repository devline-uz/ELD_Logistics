/// `M-39 Exit inspection` 🎨 (tz-mobile 1427–1443, §17.4).
///
/// Kiosk rejimidan chiqishning yagona yo'li: 6 xonali PIN. Tekshiruv oflayn
/// hash bilan (M16) — kiosk odatda tarmoqsiz ishlaydi.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../controllers/inspection_controller.dart';

/// Dialogni ochadi; `true` — PIN to'g'ri, kiosk rejimi yopiladi.
Future<bool> showExitPinDialog(BuildContext context) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: context.colors.scrim,
    builder: (BuildContext dialogContext) => const ExitPinDialog(),
  );
  return result ?? false;
}

class ExitPinDialog extends ConsumerWidget {
  const ExitPinDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final InspectionExitPinState state = ref.watch(inspectionExitPinControllerProvider);
    final InspectionExitPinController controller = ref.read(
      inspectionExitPinControllerProvider.notifier,
    );

    Future<void> submit() async {
      final bool ok = await controller.submit();
      if (ok && context.mounted) {
        Navigator.of(context).pop(true);
      }
    }

    final String? errorText = state.locked
        ? l10n.inspectionPinLocked
        : (state.invalid ? l10n.inspectionExitPinInvalid : null);

    return Dialog(
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: Radii.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.inspectionExitTitle,
              style: context.text.body11.copyWith(color: context.colors.textPrimary),
            ),
            const SizedBox(height: Spacing.s10),
            Text(
              l10n.inspectionExitMessage,
              style: context.text.body14.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: Spacing.s15),
            AppTextField(
              label: l10n.inspectionExitPinLabel,
              hint: l10n.inspectionExitPinHint,
              obscureText: true,
              autofocus: true,
              enabled: !state.locked,
              maxLength: InspectionExitPinState.pinLength,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              errorText: errorText,
              onChanged: controller.setPin,
              onSubmitted: (String _) => submit().ignore(),
            ),
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
                    label: l10n.inspectionExitConfirm,
                    busy: state.checking,
                    onPressed: state.canSubmit ? () => submit().ignore() : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
