/// `M-14 Location inaccurate` (Figma `1102:2021` / `T-06`).
///
/// GPS aniqligi 150 m dan yomon bo'lganda `M-12` dan chaqiriladi.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

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

    return Dialog(
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: Radii.modalRadius),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: l10n.commonCancel,
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
              ),
            ),
            Center(
              child: CircleAvatar(
                backgroundColor: c.warning,
                radius: Spacing.s20,
                child: Icon(Icons.info_outline, color: c.onPrimary),
              ),
            ),
            const SizedBox(height: Spacing.s15),
            Text(
              l10n.locationInaccurateMessage,
              textAlign: TextAlign.center,
              style: context.text.body11.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Spacing.s15),
            Container(
              padding: const EdgeInsets.all(Spacing.s10),
              decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: Radii.inputRadius),
              child: Row(
                children: <Widget>[
                  Icon(Icons.info_outline, size: Spacing.s20, color: c.textSecondary),
                  const SizedBox(width: Spacing.s5),
                  Expanded(
                    child: Text(
                      l10n.locationInaccurateHint,
                      style: context.text.body14.copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
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
                    label: l10n.locationUpdateNow,
                    onPressed: () => Navigator.of(context).pop(true),
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
