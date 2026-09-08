/// `AppTextField` — yagona kirish maydoni (tz-mobile §11.0.4).
///
/// Radius 12, 1 px `stroke`, fokusda `primary` (2 px), xatoda `error` +
/// ostida `body16` xabar. Barcha matn parametr sifatida keladi.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    super.key,
  });

  final TextEditingController? controller;

  /// Maydon ustidagi sarlavha (lokalizatsiyalangan).
  final String? label;

  /// Ichki placeholder (lokalizatsiyalangan).
  final String? hint;

  /// `null` bo'lmasa — xato holati.
  final String? errorText;

  /// Xato yo'q paytdagi izoh.
  final String? helperText;

  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color borderColor = _hasError ? c.error : c.stroke;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: Radii.inputRadius,
      borderSide: BorderSide(color: color, width: width),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(label!, style: context.text.body14.copyWith(color: c.textSecondary)),
          const SizedBox(height: Spacing.s5),
        ],
        TextField(
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          style: context.text.body13.copyWith(color: enabled ? c.textPrimary : c.textDisabled),
          cursorColor: c.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.text.body13.copyWith(color: c.textDisabled),
            filled: true,
            fillColor: enabled ? c.surface : c.surfaceAlt,
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.s15,
              vertical: Spacing.s15,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: Spacing.s20, color: c.textSecondary),
            suffixIcon: suffix,
            border: border(borderColor, Strokes.thin),
            enabledBorder: border(borderColor, Strokes.thin),
            disabledBorder: border(c.stroke, Strokes.thin),
            focusedBorder: border(_hasError ? c.error : c.primary, Strokes.emphasis),
            errorBorder: border(c.error, Strokes.thin),
            focusedErrorBorder: border(c.error, Strokes.emphasis),
          ),
        ),
        if (_hasError || (helperText != null && helperText!.isNotEmpty)) ...<Widget>[
          const SizedBox(height: Spacing.s5),
          Text(
            _hasError ? errorText! : helperText!,
            style: context.text.body16.copyWith(color: _hasError ? c.error : c.textSecondary),
          ),
        ],
      ],
    );
  }
}
