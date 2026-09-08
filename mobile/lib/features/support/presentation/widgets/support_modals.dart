/// `T-28 Add Ticket` — planshet modali (tz-mobile 1562; sarlavha qatori M122).
///
/// **A3:** `M-49` ekrani bilan bir xil `SupportFormPane` va
/// `ticketFormControllerProvider`; validatsiya domenda
/// (`TicketDraft.validate`) — bu yerda faqat qobiq.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../screens/support_form_screen.dart';

const double _kModalBodyHeight = 480;

/// Telefonda `AppBottomSheet`, planshetda `TabletModal`.
Future<void> showAddTicketModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => AdaptiveView(
    phone: (BuildContext p) => AppBottomSheet(
      title: p.l10n.supportAddTicket,
      child: modalPane(SupportFormPane(onDone: () => Navigator.of(p).pop()), _kModalBodyHeight),
    ),
    tablet: (BuildContext t) => TabletModal(
      title: t.l10n.supportAddTicket,
      cancelLabel: t.l10n.commonCancel,
      width: 640,
      child: modalPane(SupportFormPane(onDone: () => Navigator.of(t).pop()), _kModalBodyHeight),
    ),
  ),
);
