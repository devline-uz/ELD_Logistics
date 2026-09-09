/// `M-14 Location inaccurate` (Figma `1102:2021` / `T-06`).
///
/// GPS aniqligi 150 m dan yomon bo'lganda `M-12` dan chaqiriladi.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import 'duty_form_widgets.dart';

/// `true` — foydalanuvchi `Update Now` ni bosdi.
Future<bool> showLocationInaccurateDialog(BuildContext context) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierColor: context.colors.scrim,
    builder: (BuildContext c) => const LocationInaccurateDialog(),
  );
  return result ?? false;
}

class LocationInaccurateDialog extends StatelessWidget {
  const LocationInaccurateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    // Figma `1102:2021`: dialog ekranning ~86% kengligini egallaydi va
    // yuqori-o'rta qismida joylashadi (aniq markazda emas).
    final double dialogWidth = MediaQuery.sizeOf(context).width * 0.86;

    return Dialog(
      backgroundColor: c.surface,
      alignment: const Alignment(0, -0.35),
      insetPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: Radii.modalRadius),
      child: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.s25,
            Spacing.s25,
            Spacing.s25,
            Spacing.s25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: l10n.commonCancel,
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Icon(Icons.close, size: Spacing.s15, color: c.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: Spacing.s10),
              Center(
                child: CircleAvatar(
                  backgroundColor: c.warning,
                  radius: Spacing.s20,
                  // Figma: bitta halqa + `i`; `Icons.info_outline` ikkinchi
                  // konturli doira chizib "ring" effekti berardi.
                  child: Text('i', style: context.text.body11.copyWith(color: c.onPrimary)),
                ),
              ),
              const SizedBox(height: Spacing.s20),
              Text(
                l10n.locationInaccurateMessage,
                textAlign: TextAlign.center,
                style: context.text.body11.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Spacing.s20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.s10,
                  vertical: Spacing.s10,
                ),
                decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: Radii.inputRadius),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info_outline, size: Spacing.s15, color: c.textSecondary),
                    const SizedBox(width: Spacing.s5),
                    Expanded(
                      child: Text(
                        l10n.locationInaccurateHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.body16.copyWith(color: c.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.s30),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DutyOutlineButton(
                      label: l10n.commonCancel,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: Spacing.s10),
                  Expanded(
                    child: AppButton.primary(
                      label: l10n.locationUpdateNow,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
