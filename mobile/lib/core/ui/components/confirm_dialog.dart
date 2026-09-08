/// `ConfirmDialog` — tasdiqlash modali (tz-mobile §11.0.5).
///
/// Sarlavha (`Are you absolutely sure?`) + savol + `Cancel` / `Confirm`.
/// Destruktiv amalda `Confirm` rangi `error`. Barcha matn parametr sifatida.
library;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';
import 'app_button.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    this.destructive = false,
    this.onCancel,
    this.onConfirm,
    super.key,
  });

  /// Lokalizatsiya qilingan sarlavha.
  final String title;

  /// Lokalizatsiya qilingan savol matni.
  final String message;

  final String cancelLabel;
  final String confirmLabel;

  /// `true` — `Confirm` rangi `error`.
  final bool destructive;

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Dialog(
      backgroundColor: c.surface,
      surfaceTintColor: c.transparent,
      shape: const RoundedRectangleBorder(borderRadius: Radii.modalRadius),
      insetPadding: const EdgeInsets.all(Spacing.s25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                title,
                style: context.text.body8.copyWith(color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.s10),
              Text(
                message,
                style: context.text.body13.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.s25),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton.secondary(
                      label: cancelLabel,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: Spacing.s10),
                  Expanded(
                    child: AppButton.primary(
                      label: confirmLabel,
                      destructive: destructive,
                      onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
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

/// Tasdiqlash modalini ko'rsatadi; `true` — foydalanuvchi tasdiqladi.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierColor: context.colors.scrim,
    builder: (BuildContext context) => ConfirmDialog(
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}
