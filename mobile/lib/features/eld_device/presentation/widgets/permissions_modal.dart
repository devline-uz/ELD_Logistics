/// `T-22 Permissions` — planshet modali (tz-mobile 1556; sarlavha qatori M122).
///
/// **A3:** `M-18` ekrani bilan bir xil `PermissionsBody` va bir xil
/// `permissionsControllerProvider` — mantiq takrorlanmaydi.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../screens/permissions_screen.dart';

const double _kModalBodyHeight = 460;

/// Telefonda `AppBottomSheet`, planshetda `TabletModal`.
Future<void> showPermissionsModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => AdaptiveView(
    phone: (BuildContext c) => AppBottomSheet(
      title: c.l10n.permissionsTitle,
      child: modalPane(const PermissionsBody(), _kModalBodyHeight),
    ),
    tablet: (BuildContext c) => TabletModal(
      title: c.l10n.permissionsTitle,
      cancelLabel: c.l10n.commonCancel,
      width: 640,
      child: modalPane(const PermissionsBody(), _kModalBodyHeight),
    ),
  ),
);
