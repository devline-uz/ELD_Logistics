/// `EmptyState` — bo'sh ro'yxat holati (tz-mobile §11.0.5).
///
/// Illyustratsiya (yoki ikonka) + sarlavha + tavsif + ixtiyoriy amal.
/// Barcha matn **parametr**: dizayn matnlari `app_en.arb` da saqlanadi
/// (`No DVIR Found`, `No Notifications Yet`, `No Ticket Added Yet`).
library;

import 'package:flutter/material.dart';

import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.illustration,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Lokalizatsiya qilingan sarlavha.
  final String title;

  /// Lokalizatsiya qilingan tavsif.
  final String message;

  final IconData icon;

  /// `assets/images` dagi illyustratsiya; berilsa [icon] o'rniga chiziladi.
  final Widget? illustration;

  /// Lokalizatsiya qilingan amal matni.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            illustration ?? Icon(icon, size: 64, color: c.textDisabled),
            const SizedBox(height: Spacing.s20),
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
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: Spacing.s25),
              AppButton.primary(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
