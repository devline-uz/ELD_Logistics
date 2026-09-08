/// `T-11 Certify (Last 8 days)` · `T-12 Sign` · `T-13 Not Ready` — planshet
/// modallari (tz-mobile 1545–1547, 1599–1602; sarlavha qatori M122).
///
/// **A3:** modallar `M-29`/`M-30` ekranlari bilan bir xil kontroller va
/// provayderlarni ishlatadi (`certifyWindowProvider`,
/// `certifySignControllerProvider`) — biznes mantiq takrorlanmaydi.
/// `T-13 Not Ready` alohida modal emas: `CertifyDaysBody` ichidagi holat
/// (M125 — serverning `ready` maydoni).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/certify_models.dart';
import '../controllers/certify_providers.dart';
import '../screens/certify_screen.dart';
import '../screens/certify_sign_screen.dart';

const double _kListHeight = 480;
const double _kSignHeight = 520;

/// `T-11` — oxirgi 8 kun ro'yxati (M124).
Future<void> showCertifyDaysModal(BuildContext context) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => Consumer(
    builder: (BuildContext c, WidgetRef ref, Widget? _) {
      final AsyncValue<List<CertifyDay>> days = ref.watch(certifyWindowProvider);
      return AdaptiveView(
        phone: (BuildContext p) => AppBottomSheet(
          title: p.l10n.certifyTitle,
          child: modalPane(CertifyDaysBody(days: days, twoColumn: false), _kListHeight),
        ),
        tablet: (BuildContext t) => TabletModal(
          title: t.l10n.certifyTitle,
          cancelLabel: t.l10n.commonCancel,
          width: 720,
          child: modalPane(CertifyDaysBody(days: days, twoColumn: true), _kListHeight),
        ),
      );
    },
  ),
);

/// `T-12` — imzo modali. [date] `M-29` dan tanlangan kun.
Future<void> showCertifySignModal(BuildContext context, DateTime date) => showAdaptiveModal<void>(
  context: context,
  builder: (BuildContext modalContext) => AdaptiveView(
    phone: (BuildContext p) => AppBottomSheet(
      title: p.l10n.certifySignTitle,
      child: modalPane(CertifySignPane(date: date, twoColumn: false), _kSignHeight),
    ),
    tablet: (BuildContext t) => TabletModal(
      title: t.l10n.certifySignTitle,
      cancelLabel: t.l10n.commonCancel,
      width: 720,
      child: modalPane(CertifySignPane(date: date), _kSignHeight),
    ),
  ),
);
