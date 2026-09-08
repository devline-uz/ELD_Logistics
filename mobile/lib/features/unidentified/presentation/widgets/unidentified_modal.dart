/// `T-33 Unidentified claim` — planshet modali (tz-mobile 1567; 🎨 Figma yo'q).
///
/// **A3:** `M-28` ekrani bilan bir xil `unidentifiedBlocksProvider` va
/// `unidentifiedControllerProvider`; claim/reject qarori domen qatlamida
/// qoladi. Sarlavha qatori M122.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/unidentified_models.dart';
import '../controllers/unidentified_controller.dart';
import '../screens/unidentified_screen.dart';

const double _kModalBodyHeight = 480;

/// Telefonda `AppBottomSheet`, planshetda `TabletModal`.
Future<void> showUnidentifiedClaimModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => Consumer(
    builder: (BuildContext c, WidgetRef ref, Widget? _) {
      final AsyncValue<List<UnidentifiedBlock>> blocks = ref.watch(unidentifiedBlocksProvider);
      final UnidentifiedState state = ref.watch(unidentifiedControllerProvider);
      return AdaptiveView(
        phone: (BuildContext p) => AppBottomSheet(
          title: p.l10n.unidentifiedTitle,
          child: modalPane(
            UnidentifiedBody(blocks: blocks, state: state, twoColumn: false),
            _kModalBodyHeight,
          ),
        ),
        tablet: (BuildContext t) => TabletModal(
          title: t.l10n.unidentifiedTitle,
          cancelLabel: t.l10n.commonCancel,
          width: 760,
          child: modalPane(
            UnidentifiedBody(blocks: blocks, state: state, twoColumn: true),
            _kModalBodyHeight,
          ),
        ),
      );
    },
  ),
);
