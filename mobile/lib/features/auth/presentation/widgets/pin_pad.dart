/// `M-04` PIN nuqtalari va katta raqamli klaviatura (planshetda ham).
///
/// Teginish maydoni M8 bo'yicha: telefon ≥48, planshet ≥56 (`touchTarget`).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/auth_policies.dart';

/// Kiritilgan raqamlar soni — nuqtalar bilan ko'rsatiladi (raqam ko'rinmaydi).
class PinDots extends StatelessWidget {
  const PinDots({required this.entered, this.hasError = false, super.key});

  final int entered;
  final bool hasError;

  static const double _dotSize = Spacing.s15;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Semantics(
      label: context.l10n.authPinEntryProgress(entered, PinPolicy.length),
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < PinPolicy.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.s10),
                child: Container(
                  height: _dotSize,
                  width: _dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < entered
                        ? (hasError ? colors.error : colors.primary)
                        : colors.transparent,
                    border: Border.all(
                      color: hasError ? colors.error : colors.stroke,
                      width: Strokes.thin,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 3×4 raqamli klaviatura: `1…9`, bo'sh, `0`, backspace.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final double size = touchTarget(context) + Spacing.s15;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final List<String> row in const <List<String>>[
          <String>['1', '2', '3'],
          <String>['4', '5', '6'],
          <String>['7', '8', '9'],
          <String>['', '0', '<'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (final String key in row)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.s10),
                    child: SizedBox(
                      height: size,
                      width: size,
                      child: switch (key) {
                        '' => const SizedBox.shrink(),
                        '<' => _PinKey(
                          onPressed: enabled ? onBackspace : null,
                          semanticsLabel: context.l10n.authPinBackspace,
                          child: Icon(
                            Icons.backspace_outlined,
                            size: Spacing.s25,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        _ => _PinKey(
                          onPressed: enabled ? () => onDigit(key) : null,
                          semanticsLabel: key,
                          child: Text(
                            key,
                            style: context.text.h4.copyWith(color: context.colors.textPrimary),
                          ),
                        ),
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.child, required this.semanticsLabel, this.onPressed});

  final Widget child;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: semanticsLabel,
    child: ExcludeSemantics(
      child: Material(
        color: context.colors.surfaceMuted,
        borderRadius: Radii.pillRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    ),
  );
}
