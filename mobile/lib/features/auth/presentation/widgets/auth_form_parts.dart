/// Auth formalarining takrorlanuvchi bo'laklari (M-05…M-08).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

/// Sarlavha + tavsif bloki.
class AuthHeading extends StatelessWidget {
  const AuthHeading({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(title, style: context.text.h4.copyWith(color: context.colors.textPrimary)),
      const SizedBox(height: Spacing.s10),
      Text(description, style: context.text.body15.copyWith(color: context.colors.textSecondary)),
    ],
  );
}

/// Parol maydonidagi ko'z ikonkasi.
class ObscureToggle extends StatelessWidget {
  const ObscureToggle({required this.obscured, required this.onPressed, super.key});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    iconSize: Spacing.s20,
    tooltip: obscured ? context.l10n.authShowPassword : context.l10n.authHidePassword,
    icon: Icon(
      obscured ? Icons.visibility_off : Icons.visibility,
      color: context.colors.textSecondary,
    ),
  );
}
