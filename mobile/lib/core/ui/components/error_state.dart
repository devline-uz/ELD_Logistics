/// `ErrorState` — barcha yuklash xatolari uchun yagona widget (tz-mobile §11.0.5).
///
/// Ikonka + xabar + `Retry`. Dizaynda umumiy xato ekrani yo'q — bu komponent
/// M1 da kiritildi. Oflayn holat uchun `BannerStrip.offline` ishlatiladi.
library;

import 'package:flutter/material.dart';

import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    required this.retryLabel,
    this.title,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.details,
    super.key,
  });

  /// `core/error` mappingidan kelgan lokalizatsiyalangan xabar.
  final String message;

  /// `Retry` tugmasi matni (lokalizatsiyalangan).
  final String retryLabel;

  /// Ixtiyoriy sarlavha.
  final String? title;

  final VoidCallback? onRetry;
  final IconData icon;

  /// Diagnostika uchun qo'shimcha satr (`request_id` va h.k.).
  final String? details;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: c.error),
            const SizedBox(height: Spacing.s20),
            if (title != null) ...<Widget>[
              Text(
                title!,
                style: context.text.body8.copyWith(color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.s10),
            ],
            Text(
              message,
              style: context.text.body13.copyWith(color: c.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...<Widget>[
              const SizedBox(height: Spacing.s5),
              Text(
                details!,
                style: context.text.body16.copyWith(color: c.textDisabled),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: Spacing.s25),
              AppButton.primary(label: retryLabel, onPressed: onRetry, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
