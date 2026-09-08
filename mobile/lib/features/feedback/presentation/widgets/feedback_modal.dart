/// `T-24 Feedback` — planshet modali (tz-mobile 1558; sarlavha qatori M122).
///
/// **A3:** `M-48` ekrani bilan bir xil `FeedbackPane` (matn kontrolleri va
/// `feedbackControllerProvider` shu panelda) — mantiq takrorlanmaydi.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../screens/feedback_screen.dart';

const double _kModalBodyHeight = 420;

/// Telefonda `AppBottomSheet`, planshetda `TabletModal`.
Future<void> showFeedbackModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => AdaptiveView(
    phone: (BuildContext p) => AppBottomSheet(
      title: p.l10n.feedbackTitle,
      child: modalPane(
        FeedbackPane(tablet: false, onDone: () => Navigator.of(p).pop()),
        _kModalBodyHeight,
      ),
    ),
    tablet: (BuildContext t) => TabletModal(
      title: t.l10n.feedbackTitle,
      cancelLabel: t.l10n.commonCancel,
      width: 640,
      child: modalPane(
        FeedbackPane(tablet: true, onDone: () => Navigator.of(t).pop()),
        _kModalBodyHeight,
      ),
    ),
  ),
);
