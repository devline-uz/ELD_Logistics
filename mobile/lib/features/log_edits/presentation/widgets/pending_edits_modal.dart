/// `T-32 Pending edits` — planshet modali (tz-mobile 1566; 🎨 Figma yo'q,
/// §21.6 va dizayn tizimi tokenlaridan quriladi; sarlavha qatori M122).
///
/// **A3:** `M-26` ekrani bilan bir xil `pendingEditsProvider` va
/// `PendingEditsBody` — mantiq takrorlanmaydi. Approve/Reject qarori
/// `log_edit_policy.dart` da qoladi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/log_edit_models.dart';
import '../controllers/log_edits_controllers.dart';
import '../screens/pending_edits_screen.dart';

const double _kModalBodyHeight = 480;

/// Telefonda `AppBottomSheet`, planshetda `TabletModal`.
Future<void> showPendingEditsModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => Consumer(
    builder: (BuildContext c, WidgetRef ref, Widget? _) {
      final AsyncValue<List<LogEditRequestView>> items = ref.watch(pendingEditsProvider);
      return AdaptiveView(
        phone: (BuildContext p) => AppBottomSheet(
          title: p.l10n.editsTitle,
          child: modalPane(PendingEditsBody(items: items, twoColumn: false), _kModalBodyHeight),
        ),
        tablet: (BuildContext t) => TabletModal(
          title: t.l10n.editsTitle,
          cancelLabel: t.l10n.commonCancel,
          width: 760,
          child: modalPane(PendingEditsBody(items: items, twoColumn: true), _kModalBodyHeight),
        ),
      );
    },
  ),
);
