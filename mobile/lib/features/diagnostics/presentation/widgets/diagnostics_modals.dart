/// `T-21 Check Network` · `T-23 Diagnosis of Device` — planshet modallari
/// (tz-mobile 1555, 1557; sarlavha qatori M122).
///
/// **A3 (mantiq dublikati yo'q):** modal telefon ekrani bilan **aynan bir xil**
/// tanani (`CheckNetworkBody`, `DiagnosisBody`) va shu provayderlarni
/// ishlatadi — bu yerda faqat qobiq (varaq/modal) tanlanadi.
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../screens/check_network_screen.dart';
import '../screens/diagnosis_screen.dart';

const double _kModalBodyHeight = 420;

/// `T-21` — telefonda `AppBottomSheet`, planshetda `TabletModal`.
Future<void> showCheckNetworkModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => AdaptiveView(
    phone: (BuildContext c) => AppBottomSheet(
      title: c.l10n.checkNetworkTitle,
      child: modalPane(const CheckNetworkBody(), _kModalBodyHeight),
    ),
    tablet: (BuildContext c) => TabletModal(
      title: c.l10n.checkNetworkTitle,
      cancelLabel: c.l10n.commonCancel,
      width: 640,
      child: modalPane(const CheckNetworkBody(), _kModalBodyHeight),
    ),
  ),
);

/// `T-23` — telefonda `AppBottomSheet`, planshetda `TabletModal`.
Future<void> showDiagnosisModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => AdaptiveView(
    phone: (BuildContext c) => AppBottomSheet(
      title: c.l10n.diagnosisTitle,
      child: modalPane(const DiagnosisBody(), _kModalBodyHeight),
    ),
    tablet: (BuildContext c) => TabletModal(
      title: c.l10n.diagnosisTitle,
      cancelLabel: c.l10n.commonCancel,
      width: 640,
      child: modalPane(const DiagnosisBody(), _kModalBodyHeight),
    ),
  ),
);
