/// `M-32` `Trailers` maydoni uchun tanlov modali (`GET /trailers` keshi).
///
/// Telefonda `AppBottomSheet`, planshetda `TabletModal` — `showAdaptiveModal`
/// profil bo'yicha o'zi tanlaydi (M7).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../../../core/device/device_profile.dart';
import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/dvir_repository.dart';
import '../controllers/dvir_form_controller.dart';
import '../controllers/dvir_providers.dart';
import 'dvir_widgets.dart';

/// Trailer qidiruvi (`query` bo'yicha).
final FutureProviderFamily<List<TrailerRef>, String> trailerSearchProvider =
    FutureProvider.family<List<TrailerRef>, String>(
      (Ref ref, String query) => ref.watch(trailerRepositoryProvider).search(query),
    );

Future<void> showTrailerPicker({
  required BuildContext context,
  required DvirFormController controller,
}) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => _TrailerPickerBody(controller: controller),
);

class _TrailerPickerBody extends ConsumerStatefulWidget {
  const _TrailerPickerBody({required this.controller});

  final DvirFormController controller;

  @override
  ConsumerState<_TrailerPickerBody> createState() => _TrailerPickerBodyState();
}

class _TrailerPickerBodyState extends ConsumerState<_TrailerPickerBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DvirFormState state = ref.watch(dvirFormControllerProvider);
    final AsyncValue<List<TrailerRef>> trailers = ref.watch(trailerSearchProvider(_query));

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          hint: l10n.dvirTrailersHint,
          prefixIcon: Icons.search,
          onChanged: (String value) => setState(() => _query = value),
        ),
        const SizedBox(height: Spacing.s15),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          // `AsyncValue.when` ishlatilmaydi: Riverpod 3 avtomatik retry
          // `AsyncLoading(retrying: true)` beradi va `when` uni loading deb
          // ko'rsatadi — `ErrorState` hech qachon chiqmaydi (`asyncView`).
          child: asyncView<List<TrailerRef>>(
            trailers,
            loading: const LoadingSkeleton(itemCount: 3, animate: false),
            error: (Object error) => ErrorState(
              message: localizedError(l10n, error),
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(trailerSearchProvider(_query)),
            ),
            data: (List<TrailerRef> list) => list.isEmpty
                ? EmptyState(title: l10n.dvirTrailersLabel, message: l10n.dvirTrailersHint)
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: Spacing.s10,
                      runSpacing: Spacing.s10,
                      children: <Widget>[
                        for (final TrailerRef trailer in list)
                          AppChip(
                            label: trailer.number,
                            selected: state.draft.trailerIds.contains(trailer.id),
                            onTap: () =>
                                widget.controller.toggleTrailer(trailer.id, number: trailer.number),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );

    return DeviceProfile.of(context).isTablet
        ? TabletModal(
            title: l10n.dvirTrailersLabel,
            cancelLabel: l10n.commonCancel,
            onCancel: () => Navigator.of(context).pop(),
            actionLabel: l10n.dvirSave,
            onAction: () => Navigator.of(context).pop(),
            child: body,
          )
        : AppBottomSheet(title: l10n.dvirTrailersLabel, child: body);
  }
}
