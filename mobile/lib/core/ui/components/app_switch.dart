/// `AppSwitch` — iOS uslubidagi switch (PARITY #B-18).
///
/// Figma: trek **51×31 r16**, yoqilgan `#22C55E`, o'chirilgan `strokeStrong`;
/// thumb — **to'liq oq 27 dp doira**, `shadow`. Material 3 ning kichik/kulrang
/// thumb'i Figma bilan mos kelmagani uchun maxsus chiziladi.
library;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';

/// Trek o'lchami — Figma 51×31.
const double kSwitchTrackWidth = 51;
const double kSwitchTrackHeight = 31;
const Size kSwitchTrackSize = Size(kSwitchTrackWidth, kSwitchTrackHeight);

/// Thumb diametri — Figma 27.
const double kSwitchThumbSize = 27;

class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.onChanged, this.semanticLabel, super.key});

  final bool value;

  /// `null` — o'chirilgan holat (trek yarim shaffof).
  final ValueChanged<bool>? onChanged;

  /// Lokalizatsiya qilingan `semanticsLabel`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = onChanged != null;
    final Color track = value ? c.switchTrackOn : c.strokeStrong;
    const double inset = (kSwitchTrackHeight - kSwitchThumbSize) / 2;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: kSwitchTrackWidth,
            height: kSwitchTrackHeight,
            padding: const EdgeInsets.all(inset),
            decoration: BoxDecoration(
              color: track,
              borderRadius: const BorderRadius.all(Radius.circular(kSwitchTrackHeight / 2)),
            ),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: kSwitchThumbSize,
              height: kSwitchThumbSize,
              decoration: BoxDecoration(
                color: AppPalette.white,
                shape: BoxShape.circle,
                boxShadow: context.shadows.card,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
