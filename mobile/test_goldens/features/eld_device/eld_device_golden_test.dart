@Timeout(Duration(seconds: 60))
/// `eld_device` va `diagnostics` golden'lari — light/dark × phone/tablet
/// (tz-mobile C.3 DoD).
///
/// Ekran emas, **holatga bog'liq bo'lmagan ko'rinishlar** olinadi: ELD banneri
/// (M68/M77) va tarmoq o'lchagichi (M-47). Ular Riverpod konteynerisiz
/// chiziladi, shuning uchun golden barqaror.
library;

import 'package:eld_mobile/core/eld/eld_codes.dart';
import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/eld_session.dart';
import 'package:eld_mobile/features/diagnostics/presentation/widgets/network_gauge.dart';
import 'package:eld_mobile/features/eld_device/presentation/widgets/eld_status_banner.dart';
import 'package:eld_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../golden_harness.dart';

final DateTime _t0 = DateTime.utc(2026, 9, 7, 12);

/// `context.l10n` ishlashi uchun minimal lokalizatsiya qobig'i.
Widget _localized(Widget child) => Localizations(
  locale: const Locale('en'),
  delegates: const <LocalizationsDelegate<Object?>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  child: child,
);

EldSessionState _withFault(EldFaultCode code, EldFaultKind kind) => EldSessionState(
  connection: EldConnectionState.connected,
  faults: <EldFaultCode, EldFault>{code: EldFault(code: code, kind: kind, detectedAt: _t0)},
);

void main() {
  goldenMatrix(
    'eld_banner_not_connected',
    builder: () => _localized(const EldStatusBannerView(session: EldSessionState())),
  );

  goldenMatrix(
    'eld_banner_connecting',
    builder: () => _localized(
      const EldStatusBannerView(
        session: EldSessionState(connection: EldConnectionState.connecting),
      ),
    ),
  );

  // M77: doimiy qizil banner, dismiss tugmasi yo'q.
  goldenMatrix(
    'eld_banner_malfunction',
    builder: () => _localized(
      EldStatusBannerView(session: _withFault(EldFaultCode.power, EldFaultKind.malfunction)),
    ),
  );

  goldenMatrix(
    'eld_banner_diagnostic',
    builder: () => _localized(
      EldStatusBannerView(session: _withFault(EldFaultCode.timing, EldFaultKind.diagnostic)),
    ),
  );

  goldenMatrix(
    'network_gauge_measured',
    builder: () => _localized(const Center(child: NetworkGauge(value: 14))),
  );

  goldenMatrix(
    'network_gauge_idle',
    builder: () => _localized(const Center(child: NetworkGauge(value: null))),
  );
}
