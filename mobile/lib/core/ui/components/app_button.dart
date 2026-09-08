/// `AppButton` — primary / secondary / text (tz-mobile §11.0.4).
///
/// Balandlik: telefon 48, planshet 56, haydash rejimida ≥64 (M8).
/// Radius 12 (`Radii.button`). Matn **parametr** sifatida keladi.
library;

import 'package:flutter/material.dart';

import '../adaptive_scaffold.dart';
import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

enum AppButtonVariant { primary, secondary, text, neutral }

class AppButton extends StatelessWidget {
  const AppButton._({
    required this.label,
    required this.variant,
    this.onPressed,
    this.icon,
    this.busy = false,
    this.expand = true,
    this.destructive = false,
    this.drivingMode = false,
    super.key,
  });

  /// To'ldirilgan brend tugmasi.
  const factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy,
    bool expand,
    bool destructive,
    bool drivingMode,
    Key? key,
  }) = _PrimaryButton;

  /// Chegarali, `surface` fonli tugma.
  const factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy,
    bool expand,
    bool destructive,
    bool drivingMode,
    Key? key,
  }) = _SecondaryButton;

  /// Neytral («inverse») to'q tugma — M-47 `Check Network` (Figma `1122:319`).
  ///
  /// Fon `colors.neutralStrong`, matn `colors.onNeutralStrong` (#B-63).
  const factory AppButton.neutral({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy,
    bool expand,
    bool drivingMode,
    Key? key,
  }) = _NeutralButton;

  /// Fonsiz tugma; teginish maydoni baribir ≥48×48.
  const factory AppButton.text({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool busy,
    bool expand,
    bool destructive,
    bool drivingMode,
    Key? key,
  }) = _TextButton;

  /// Lokalizatsiya qilingan matn.
  final String label;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// `true` — inline spinner, `onPressed` bloklanadi.
  final bool busy;

  /// `true` — ota kengligini to'liq egallaydi.
  final bool expand;

  /// Destruktiv amal (`Delete`, `Reject`) — rang `error`.
  final bool destructive;

  /// Haydash rejimi — balandlik ≥64 dp.
  final bool drivingMode;

  bool get _enabled => onPressed != null && !busy;

  @override
  Widget build(BuildContext context) {
    final AppColorsResolved r = _resolve(context);
    final double height = touchTarget(context, driving: drivingMode);

    final Widget content = busy
        ? SizedBox(
            height: Spacing.s20,
            width: Spacing.s20,
            child: CircularProgressIndicator(strokeWidth: Strokes.emphasis, color: r.foreground),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: Spacing.s20, color: r.foreground),
                const SizedBox(width: Spacing.s10),
              ],
              Flexible(
                child: Text(
                  label,
                  style: context.text.body12.copyWith(color: r.foreground),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: Material(
        color: r.background,
        borderRadius: Radii.buttonRadius,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: Radii.buttonRadius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: Radii.buttonRadius,
              border: r.border == null
                  ? null
                  : Border.fromBorderSide(BorderSide(color: r.border!, width: Strokes.thin)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height, minWidth: height),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.s20),
                child: Center(widthFactor: expand ? null : 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppColorsResolved _resolve(BuildContext context) {
    final AppColors c = context.colors;
    final Color accent = destructive ? c.error : c.primary;
    if (!_enabled && !busy) {
      return switch (variant) {
        AppButtonVariant.primary => AppColorsResolved(
          background: c.surfaceAlt,
          foreground: c.textDisabled,
        ),
        AppButtonVariant.secondary => AppColorsResolved(
          background: c.surface,
          foreground: c.textDisabled,
          border: c.stroke,
        ),
        AppButtonVariant.text => AppColorsResolved(
          background: c.transparent,
          foreground: c.textDisabled,
        ),
        AppButtonVariant.neutral => AppColorsResolved(
          background: c.surfaceAlt,
          foreground: c.textDisabled,
        ),
      };
    }
    return switch (variant) {
      AppButtonVariant.primary => AppColorsResolved(background: accent, foreground: c.onPrimary),
      AppButtonVariant.secondary => AppColorsResolved(
        background: c.surface,
        foreground: destructive ? c.error : c.textPrimary,
        border: c.stroke,
      ),
      AppButtonVariant.text => AppColorsResolved(background: c.transparent, foreground: accent),
      AppButtonVariant.neutral => AppColorsResolved(
        background: destructive ? accent : c.neutralStrong,
        foreground: destructive ? c.onPrimary : c.onNeutralStrong,
      ),
    };
  }
}

/// Variant uchun hisoblangan ranglar.
@immutable
class AppColorsResolved {
  const AppColorsResolved({required this.background, required this.foreground, this.border});

  final Color background;
  final Color foreground;
  final Color? border;
}

class _PrimaryButton extends AppButton {
  const _PrimaryButton({
    required super.label,
    super.onPressed,
    super.icon,
    super.busy = false,
    super.expand = true,
    super.destructive = false,
    super.drivingMode = false,
    super.key,
  }) : super._(variant: AppButtonVariant.primary);
}

class _SecondaryButton extends AppButton {
  const _SecondaryButton({
    required super.label,
    super.onPressed,
    super.icon,
    super.busy = false,
    super.expand = true,
    super.destructive = false,
    super.drivingMode = false,
    super.key,
  }) : super._(variant: AppButtonVariant.secondary);
}

class _TextButton extends AppButton {
  const _TextButton({
    required super.label,
    super.onPressed,
    super.icon,
    super.busy = false,
    super.expand = false,
    super.destructive = false,
    super.drivingMode = false,
    super.key,
  }) : super._(variant: AppButtonVariant.text);
}

class _NeutralButton extends AppButton {
  const _NeutralButton({
    required super.label,
    super.onPressed,
    super.icon,
    super.busy = false,
    super.expand = true,
    super.drivingMode = false,
    super.key,
  }) : super._(variant: AppButtonVariant.neutral);
}
