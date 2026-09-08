/// `M-11 Edit documents` (Figma `2230:20627` / `T-03`).
///
/// **M53:** saqlanganda **status o'zgarmaydi** — faqat `trailer_ids` /
/// `shipping_doc_ids` / `notes` yangilanadi. Dizayndagi «Please change your
/// status to update trailer and document.» matni olib tashlangan (#B-30).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../../duty_status/data/duty_status_providers.dart';
import '../../../duty_status/domain/duty_status_models.dart';
import '../../../duty_status/presentation/widgets/duty_form_widgets.dart';
import '../../domain/home_models.dart';

/// Natija: saqlangan bo'lsa `true`.
Future<bool?> showEditDocumentsSheet(BuildContext context, TripDetails trip) {
  if (DeviceProfile.of(context).isTablet) {
    return showDialog<bool>(
      context: context,
      barrierColor: context.colors.scrim,
      builder: (BuildContext c) => Center(child: EditDocumentsForm(trip: trip, asModal: true)),
    );
  }
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.transparent,
    barrierColor: context.colors.scrim,
    builder: (BuildContext c) => EditDocumentsForm(trip: trip),
  );
}

class EditDocumentsForm extends ConsumerStatefulWidget {
  const EditDocumentsForm({required this.trip, this.asModal = false, super.key});

  final TripDetails trip;
  final bool asModal;

  @override
  ConsumerState<EditDocumentsForm> createState() => _EditDocumentsFormState();
}

class _EditDocumentsFormState extends ConsumerState<EditDocumentsForm> {
  late List<String> _trailers = <String>[...widget.trip.trailers];
  late final List<String> _docs = <String>[...widget.trip.shippingDocs];
  late final TextEditingController _note = TextEditingController(text: widget.trip.notes);
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<TrailerOption> catalog =
        ref.watch(trailersProvider).value ?? const <TrailerOption>[];

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DutyChipField(
          label: l10n.documentsTrailerNumber,
          values: _trailers,
          addLabel: l10n.documentsAddTrailer,
          onAdd: catalog.isEmpty ? null : () => _addTrailer(catalog),
          onRemove: (String value) => setState(() => _trailers.remove(value)),
        ),
        const SizedBox(height: Spacing.s15),
        DutyChipField(
          label: l10n.documentsShippingDocument,
          values: _docs,
          onRemove: (String value) => setState(() => _docs.remove(value)),
        ),
        const SizedBox(height: Spacing.s15),
        AppTextField(
          label: l10n.documentsNote,
          hint: l10n.documentsNoteHint,
          controller: _note,
          maxLines: 3,
          minLines: 2,
        ),
        if (!widget.asModal) ...<Widget>[
          const SizedBox(height: Spacing.s20),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: Spacing.s10),
              Expanded(
                child: AppButton.primary(label: l10n.dutySave, busy: _saving, onPressed: _save),
              ),
            ],
          ),
        ],
      ],
    );

    if (widget.asModal) {
      return TabletModal(
        title: l10n.documentsTitle,
        cancelLabel: l10n.commonCancel,
        onCancel: () => Navigator.of(context).pop(false),
        actionLabel: l10n.dutySave,
        onAction: _save,
        child: body,
      );
    }
    return AppBottomSheet(title: l10n.documentsTitle, child: body);
  }

  Future<void> _addTrailer(List<TrailerOption> catalog) async {
    final TrailerOption? picked = await showModalBottomSheet<TrailerOption>(
      context: context,
      backgroundColor: context.colors.transparent,
      builder: (BuildContext c) => AppBottomSheet(
        title: context.l10n.documentsTrailerNumber,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final TrailerOption option in catalog)
              ListTile(title: Text(option.number), onTap: () => Navigator.of(c).pop(option)),
          ],
        ),
      ),
    );
    if (picked != null && !_trailers.contains(picked.number)) {
      setState(() => _trailers = <String>[..._trailers, picked.number]);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final NavigatorState navigator = Navigator.of(context);
    await ref
        .read(dutyStatusRepositoryProvider)
        .updateDocuments(trailerIds: _trailers, shippingDocIds: _docs, notes: _note.text);
    if (mounted) {
      setState(() => _saving = false);
    }
    navigator.pop(true);
  }
}
