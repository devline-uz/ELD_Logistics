/// `AppCheckbox` — Figma checkbox (PARITY #B-19).
///
/// Tanlanmagan: `textPrimary` 1.5 px kontur, `r2`, 20×20.
/// Tanlangan: `neutralStrong` to'ldirish + `onNeutralStrong` belgi.
/// Yorliq **parametr** sifatida keladi.
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

/// Quti o'lchami — Figma 20.
const double kCheckboxSize = 20;

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({required this.value, required this.onChanged, this.label, super.key});

  final bool value;

  /// `null` — o'chirilgan holat.
  final ValueChanged<bool>? onChanged;

  /// Lokalizatsiya qilingan yorliq (`null` — faqat quti).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = onChanged != null;

    final Widget box = Container(
      width: kCheckboxSize,
      height: kCheckboxSize,
      decoration: BoxDecoration(
        color: value ? c.neutralStrong : c.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(Radii.xs)),
        border: Border.all(
          color: enabled ? c.textPrimary : c.textDisabled,
          width: Strokes.emphasis - 0.5,
        ),
      ),
      child: value
          ? Icon(Icons.check, size: Spacing.s15, color: c.onNeutralStrong)
          : const SizedBox.shrink(),
    );

    return Semantics(
      checked: value,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: TouchTarget.phone),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              box,
              if (label != null) ...<Widget>[
                const SizedBox(width: Spacing.s10),
                Flexible(
                  child: Text(
                    label!,
                    style: context.text.body13.copyWith(
                      color: enabled ? c.textPrimary : c.textDisabled,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
