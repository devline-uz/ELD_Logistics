/// DVIR moduli uchun umumiy vizual bloklar (Figma `1089:4441`, `1090:4687`).
///
/// **Dark tema Figma da chizilmagan** — bu yerdagi barcha rang `core/ui`
/// tokenlaridan olinadi, shuning uchun dark variant avtomatik hosil bo'ladi.
/// TODO(dizayner): DVIR ekranlarining dark maketlari kerak (MAP.md: juftlik yo'q).
library;

import 'package:flutter/material.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_messages.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/dvir_badge.dart';
import '../../domain/dvir_models.dart';

/// `AsyncValue.error` dagi ixtiyoriy obyektni foydalanuvchi matniga o'giradi.
/// Backend xabari hech qachon to'g'ridan-to'g'ri ko'rsatilmaydi.
String localizedError(AppLocalizations l10n, Object error) =>
    error is ApiError ? localizedApiError(l10n, error) : l10n.errUnknown;

/// Figma: `#F5F5F5` fon, `#E5E7EB` 1 px chegara, `r8` — `surfaceMuted` tokeni.
class DvirCard extends StatelessWidget {
  const DvirCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: padding ?? const EdgeInsets.all(Spacing.s20),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: child,
    );
  }
}

/// Label (tepada) + qutili qiymat/maydon (Figma `Categories` bloki).
class DvirLabeledField extends StatelessWidget {
  const DvirLabeledField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(label, style: context.text.body14.copyWith(color: context.colors.textPrimary)),
      const SizedBox(height: Spacing.s10),
      child,
    ],
  );
}

/// O'zgarmas qiymat qutisi (`Unit Number`) yoki bosiladigan qutі (`Add Defects`).
class DvirValueBox extends StatelessWidget {
  const DvirValueBox({
    required this.text,
    this.placeholder = false,
    this.trailing,
    this.onTap,
    super.key,
  });

  /// Lokalizatsiya qilingan matn yoki qiymat.
  final String text;

  /// `true` — placeholder ko'rinishi (`textSecondary`).
  final bool placeholder;

  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Widget box = Container(
      constraints: BoxConstraints(minHeight: touchTarget(context)),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s10),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: Radii.inputRadius,
        border: Border.all(color: c.stroke, width: Strokes.thin),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              text,
              style: context.text.body13.copyWith(
                color: placeholder ? c.textSecondary : c.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) {
      return box;
    }
    return InkWell(borderRadius: Radii.inputRadius, onTap: onTap, child: box);
  }
}

/// `Driver Information` qatori: chapda kulrang label, o'ngda qiymat.
class DvirInfoRow extends StatelessWidget {
  const DvirInfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(label, style: context.text.body14.copyWith(color: c.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: context.text.body14.copyWith(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// `Pre-trip` / `Post-trip` toggle (🎨, `tz.md` §7.1 — Figma da yo'q).
class DvirTypeToggle extends StatelessWidget {
  const DvirTypeToggle({required this.value, required this.onChanged, super.key});

  final DvirType value;
  final ValueChanged<DvirType> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.s10,
    runSpacing: Spacing.s10,
    children: <Widget>[
      AppChip(
        label: context.l10n.dvirTypePreTrip,
        selected: value == DvirType.preTrip,
        onTap: () => onChanged(DvirType.preTrip),
      ),
      AppChip(
        label: context.l10n.dvirTypePostTrip,
        selected: value == DvirType.postTrip,
        onTap: () => onChanged(DvirType.postTrip),
      ),
    ],
  );
}

/// M102/M103: badge **faqat** `kind` dan hosil bo'ladi.
class DvirBadgeView extends StatelessWidget {
  const DvirBadgeView({required this.badge, super.key});

  final DvirBadge badge;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String label = switch (badge.label) {
      DvirBadgeLabel.draft => l10n.dvirKindDraft,
      DvirBadgeLabel.noDefects => l10n.dvirKindNoDefects,
      DvirBadgeLabel.defectsNotFixed => l10n.dvirKindDefectsNotFixed,
      DvirBadgeLabel.defectsFixed => l10n.dvirKindDefectsFixed,
    };
    final StatusTone tone = switch (badge.tone) {
      DvirBadgeTone.success => StatusTone.success,
      DvirBadgeTone.warning => StatusTone.warning,
      DvirBadgeTone.error => StatusTone.error,
      DvirBadgeTone.neutral => StatusTone.neutral,
    };
    final String? suffix = switch (badge.suffix) {
      DvirBadgeSuffix.awaitingCertification => l10n.dvirKindAwaitingCertification,
      DvirBadgeSuffix.closed => l10n.dvirKindClosed,
      null => null,
    };

    return Wrap(
      spacing: Spacing.s5,
      runSpacing: Spacing.s5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        StatusBadge(label: label, tone: tone),
        if (suffix != null) StatusBadge(label: suffix, tone: StatusTone.neutral, dense: true),
      ],
    );
  }
}

/// Ekran pastidagi `Cancel` / `<amal>` juftligi (Figma: 167×39, gap 10).
class DvirActionBar extends StatelessWidget {
  const DvirActionBar({
    required this.actionLabel,
    required this.onAction,
    required this.onCancel,
    this.busy = false,
    super.key,
  });

  final String actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onCancel;
  final bool busy;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Spacing.s15),
    child: Row(
      children: <Widget>[
        Expanded(
          child: AppButton.secondary(label: context.l10n.commonCancel, onPressed: onCancel),
        ),
        const SizedBox(width: Spacing.s10),
        Expanded(
          child: AppButton.primary(label: actionLabel, onPressed: onAction, busy: busy),
        ),
      ],
    ),
  );
}
