/// `M-33 Defect picker` qatorlari — Figma `1169:1467`.
///
/// Bitta nuqson: belgilash katagi + tanlanganda izoh maydoni va ≤5 foto
/// (`tz.md` Q27.1). `Accident Photo` — nuqson emas, alohida blok (M105).
library;

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../data/dvir_file_repository.dart';
import '../../domain/dvir_models.dart';
import '../controllers/defect_picker_controller.dart';
import 'dvir_widgets.dart';

/// Foto biriktirish natijasini foydalanuvchiga ko'rsatish (matn `l10n` dan).
void _showPhotoIssue(BuildContext context, DefectPhotoIssue? issue) {
  if (issue == null) {
    return;
  }
  final AppLocalizations l10n = context.l10n;
  final String message = switch (issue) {
    DefectPhotoIssue.unavailable => l10n.dvirPhotoUnavailable,
    DefectPhotoIssue.limit => l10n.dvirDefectPhotoLimit(DvirDefect.maxPhotos),
    DefectPhotoIssue.tooLarge => l10n.dvirPhotoTooLarge(kMaxPhotoBytes ~/ (1024 * 1024)),
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Katalogdagi bitta nuqson bandi.
class DefectTile extends StatelessWidget {
  const DefectTile({required this.type, required this.controller, this.defect, super.key});

  final DefectType type;

  /// Tanlangan bo'lsa — izoh va fotolar bilan; aks holda `null`.
  final DvirDefect? defect;

  final DefectPickerController controller;

  bool get _selected => defect != null;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppLocalizations l10n = context.l10n;

    return DvirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: touchTarget(context)),
            child: InkWell(
              onTap: () => controller.toggle(type),
              borderRadius: Radii.cardRadius,
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _selected,
                    onChanged: (bool? _) => controller.toggle(type),
                    activeColor: c.primary,
                    checkColor: c.onPrimary,
                    side: BorderSide(color: c.stroke, width: Strokes.thin),
                  ),
                  Expanded(
                    child: Text(
                      type.name,
                      style: context.text.body15.copyWith(color: c.textPrimary),
                    ),
                  ),
                  if (type.isCritical) ...<Widget>[
                    const SizedBox(width: Spacing.s10),
                    StatusBadge(label: l10n.dvirCriticalBadge, tone: StatusTone.error, dense: true),
                  ],
                ],
              ),
            ),
          ),
          if (_selected) ...<Widget>[
            const SizedBox(height: Spacing.s10),
            AppTextField(
              hint: l10n.dvirDefectNoteHint,
              minLines: 2,
              maxLines: 3,
              onChanged: (String value) => controller.setNote(type.id, value),
            ),
            const SizedBox(height: Spacing.s10),
            DefectPhotoStrip(
              paths: defect!.photoPaths,
              countLabel: l10n.dvirDefectPhotoCount(
                defect!.photoPaths.length,
                DvirDefect.maxPhotos,
              ),
              addLabel: l10n.dvirDefectAddPhoto,
              canAdd: defect!.canAddPhoto,
              onAdd: () async {
                final DefectPhotoIssue? issue = await controller.addPhoto(type.id);
                if (context.mounted) {
                  _showPhotoIssue(context, issue);
                }
              },
              onRemove: (String path) => controller.removePhoto(type.id, path),
            ),
          ],
        ],
      ),
    );
  }
}

/// **M105:** `Accident Photo` katalog bandi nuqson sifatida ko'rsatilmaydi —
/// alohida blok, hisobotning `accident_photo_paths` maydoniga tushadi.
class AccidentPhotoBlock extends StatelessWidget {
  const AccidentPhotoBlock({required this.state, required this.controller, super.key});

  final DefectPickerState state;
  final DefectPickerController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppColors c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.s10),
      child: DvirCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.dvirAccidentPhotoTitle,
              style: context.text.body14.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Spacing.s5),
            Text(
              l10n.dvirAccidentPhotoHint,
              style: context.text.body17.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Spacing.s10),
            DefectPhotoStrip(
              paths: state.accidentPhotoPaths,
              countLabel: l10n.dvirDefectPhotoCount(
                state.accidentPhotoPaths.length,
                DvirDefect.maxPhotos,
              ),
              addLabel: l10n.dvirAccidentPhotoAdd,
              canAdd: state.accidentPhotoPaths.length < DvirDefect.maxPhotos,
              onAdd: () async {
                final DefectPhotoIssue? issue = await controller.addAccidentPhoto();
                if (context.mounted) {
                  _showPhotoIssue(context, issue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Foto qatori: eskizlar + «Add photo» tugmasi.
///
/// [onRemove] berilmasa eskizni o'chirish tugmasi ko'rsatilmaydi
/// (accident foto — hisobotga bir marta biriktiriladi).
class DefectPhotoStrip extends StatelessWidget {
  const DefectPhotoStrip({
    required this.paths,
    required this.countLabel,
    required this.addLabel,
    required this.canAdd,
    required this.onAdd,
    this.onRemove,
    super.key,
  });

  final List<String> paths;
  final String countLabel;
  final String addLabel;
  final bool canAdd;
  final VoidCallback onAdd;
  final ValueChanged<String>? onRemove;

  /// Figma dagi eskiz o'lchami.
  static const double _thumb = 60;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (paths.isNotEmpty) ...<Widget>[
          SizedBox(
            height: _thumb,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: paths.length,
              separatorBuilder: (BuildContext _, int _) => const SizedBox(width: Spacing.s5),
              itemBuilder: (BuildContext context, int index) =>
                  _Thumb(path: paths[index], onRemove: onRemove),
            ),
          ),
          const SizedBox(height: Spacing.s5),
        ],
        // `Wrap`: tor ekranda va `textScaler` 1.3 da tugma bilan hisoblagich
        // ikki qatorga tushadi (M85), `Row` esa overflow beradi.
        Wrap(
          spacing: Spacing.s10,
          runSpacing: Spacing.s5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            AppButton.secondary(
              label: addLabel,
              icon: Icons.photo_camera_outlined,
              expand: false,
              onPressed: canAdd ? onAdd : null,
            ),
            Text(countLabel, style: context.text.body17.copyWith(color: c.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, this.onRemove});

  final String path;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppLocalizations l10n = context.l10n;

    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(Radii.sm)),
          child: Image.file(
            File(path),
            width: DefectPhotoStrip._thumb,
            height: DefectPhotoStrip._thumb,
            fit: BoxFit.cover,
            // Fayl hali navbatda/o'chirilgan bo'lsa — ekran yiqilmaydi.
            errorBuilder: (BuildContext context, Object _, StackTrace? _) => Container(
              width: DefectPhotoStrip._thumb,
              height: DefectPhotoStrip._thumb,
              color: c.surfaceAlt,
              child: Icon(Icons.broken_image_outlined, size: 20, color: c.textSecondary),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: Semantics(
              button: true,
              label: l10n.dvirPhotoRemove,
              child: InkWell(
                onTap: () => onRemove!(path),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: c.scrim, shape: BoxShape.circle),
                  child: Icon(Icons.close, size: 14, color: c.onPrimary),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
