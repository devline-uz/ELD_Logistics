/// `M-13 Quick notes` (Figma `1170:2313`) — telefonda `AppBottomSheet`,
/// planshetda `TabletModal` (`T-05`).
///
/// **M55:** ro'yxat `sync/pull → quick_notes[]` dan keladi; birinchi
/// pull'gacha M54 dagi 10 bandli fallback ishlatiladi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../data/duty_status_providers.dart';
import '../../domain/duty_status_models.dart';

/// M54 kanonik fallback to'plami (10 band).
List<QuickNoteOption> fallbackQuickNotes(AppLocalizations l10n) => <QuickNoteOption>[
  QuickNoteOption(id: 'pti', label: l10n.quickNotePti),
  QuickNoteOption(id: 'hook', label: l10n.quickNoteHook),
  QuickNoteOption(id: 'pickup', label: l10n.quickNotePickup),
  QuickNoteOption(id: 'drop_off', label: l10n.quickNoteDropOff),
  QuickNoteOption(id: 'delivery', label: l10n.quickNoteDelivery),
  QuickNoteOption(id: 'inspection', label: l10n.quickNoteInspection),
  QuickNoteOption(id: 'check_in', label: l10n.quickNoteCheckIn),
  QuickNoteOption(id: 'fueling', label: l10n.quickNoteFueling),
  QuickNoteOption(id: 'check_out', label: l10n.quickNoteCheckOut),
  QuickNoteOption(id: 'other', label: l10n.quickNoteOther),
];

/// Tanlangan matnlarni qaytaradi (bekor qilinsa `null`).
Future<List<String>?> showQuickNotesSheet(BuildContext context) {
  if (DeviceProfile.of(context).isTablet) {
    return showDialog<List<String>>(
      context: context,
      barrierColor: context.colors.scrim,
      builder: (BuildContext c) => const Center(child: QuickNotesPicker(asModal: true)),
    );
  }
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.transparent,
    barrierColor: context.colors.scrim,
    builder: (BuildContext c) => const QuickNotesPicker(),
  );
}

class QuickNotesPicker extends ConsumerStatefulWidget {
  const QuickNotesPicker({this.asModal = false, super.key});

  /// `true` — planshet modali (`TabletModal`).
  final bool asModal;

  @override
  ConsumerState<QuickNotesPicker> createState() => _QuickNotesPickerState();
}

class _QuickNotesPickerState extends ConsumerState<QuickNotesPicker> {
  final Set<String> _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;
    final List<QuickNoteOption> server =
        ref.watch(quickNotesProvider).value ?? const <QuickNoteOption>[];
    final List<QuickNoteOption> options = server.isEmpty ? fallbackQuickNotes(l10n) : server;

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Flexible(
          // `CheckboxListTile` eng yaqin `Material` ni talab qiladi — modal
          // foni `DecoratedBox` bo'lgani uchun shaffof qatlam qo'shamiz.
          child: Material(
            type: MaterialType.transparency,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                for (final QuickNoteOption option in options)
                  CheckboxListTile(
                    value: _selected.contains(option.label),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option.label,
                      style: context.text.body13.copyWith(color: c.textPrimary),
                    ),
                    onChanged: (bool? checked) => setState(() {
                      if (checked ?? false) {
                        _selected.add(option.label);
                      } else {
                        _selected.remove(option.label);
                      }
                    }),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.s10),
        Container(
          padding: const EdgeInsets.all(Spacing.s10),
          decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: Radii.inputRadius),
          child: Row(
            children: <Widget>[
              Icon(Icons.info_outline, size: Spacing.s20, color: c.textSecondary),
              const SizedBox(width: Spacing.s5),
              Expanded(
                child: Text(
                  l10n.quickNotesLimitHint,
                  style: context.text.body14.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
        if (!widget.asModal) ...<Widget>[
          const SizedBox(height: Spacing.s15),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: AppButton.primary(
                  label: l10n.quickNotesAdd,
                  onPressed: _selected.isEmpty ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    if (widget.asModal) {
      return TabletModal(
        title: l10n.quickNotesTitle,
        cancelLabel: l10n.commonCancel,
        onCancel: () => Navigator.of(context).pop(),
        actionLabel: l10n.quickNotesAdd,
        actionEnabled: _selected.isNotEmpty,
        onAction: _submit,
        child: body,
      );
    }
    return AppBottomSheet(title: l10n.quickNotesTitle, child: body);
  }

  void _submit() => Navigator.of(context).pop(_selected.toList(growable: false));
}
