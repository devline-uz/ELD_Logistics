/// `M-16 Idle prompt` (Figma `2181:17282` / `T-26`).
///
/// Ekran ustida qatlam sifatida chiziladi — `M-15` dan chiqmasdan javob
/// beriladi. Modal ekran o'chiq bo'lsa lokal bildirishnoma chiqadi (M62).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

class IdlePromptOverlay extends StatelessWidget {
  const IdlePromptOverlay({required this.onStillDriving, required this.onNotDriving, super.key});

  /// `Yes, driving` — M61 kanonik yozilishi.
  final VoidCallback onStillDriving;

  /// `No` — status `ON` bo'ladi, event vaqti so'rov chiqqan payt (M60).
  final VoidCallback onNotDriving;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Stack(
      children: <Widget>[
        ModalBarrier(color: c.scrim, dismissible: false),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.s20),
            child: Material(
              color: c.surface,
              borderRadius: Radii.modalRadius,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.s20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: CircleAvatar(
                        backgroundColor: c.warning,
                        radius: Spacing.s20,
                        child: Icon(Icons.info_outline, color: c.onPrimary),
                      ),
                    ),
                    const SizedBox(height: Spacing.s15),
                    Text(
                      l10n.idlePromptMessage,
                      textAlign: TextAlign.center,
                      style: context.text.body11.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: Spacing.s20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AppButton.secondary(
                            label: l10n.idlePromptNo,
                            drivingMode: true,
                            onPressed: onNotDriving,
                          ),
                        ),
                        const SizedBox(width: Spacing.s10),
                        Expanded(
                          child: AppButton.primary(
                            label: l10n.idlePromptYes,
                            drivingMode: true,
                            onPressed: onStillDriving,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
