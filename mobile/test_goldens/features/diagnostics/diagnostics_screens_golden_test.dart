@Timeout(Duration(seconds: 60))
/// **M-46 Diagnosis of device** va **M-47 Check network** — *ekran*
/// darajasidagi goldenlar: light/dark × phone/tablet (tz-mobile C.3 DoD, M176).
///
/// Holatlar **eng ma'nolisi** tanlangan (bo'sh/loading emas):
/// * M-46 — aktiv nosozliklar bor holat (`P` malfunction + `T` diagnostic),
///   uch qatorning har xil tonlari (`Not working` / `Working` / `Fair`);
/// * M-47 — o'lchov natijasi ko'rsatilgan holat (14.00 mbps, 180 ms).
///
/// Determinizm: `deviceDiagnosticsProvider` va `eldActiveFaultsProvider`
/// qiymat bilan override qilinadi (DB, GPS, sync scheduler ishtirok etmaydi),
/// tarmoq o'lchovi esa `Dio` ga chiqmaydigan soxta zond bilan bajariladi.
library;

import 'package:eld_mobile/core/eld/eld_codes.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/features/diagnostics/data/network_probe.dart';
import 'package:eld_mobile/features/diagnostics/domain/diagnostics_models.dart';
import 'package:eld_mobile/features/diagnostics/presentation/controllers/diagnostics_controller.dart';
import 'package:eld_mobile/features/diagnostics/presentation/screens/check_network_screen.dart';
import 'package:eld_mobile/features/diagnostics/presentation/screens/diagnosis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../golden_screen_host.dart';

/// `TimeSource` o'rniga qotirilgan vaqt — `DateTime.now()` ishlatilmaydi.
final DateTime _t0 = DateTime.utc(2026, 9, 7, 12);

/// Tarmoqqa chiqmaydigan o'lchov (M75: tashqi speedtest yo'q).
class _FixedProbe implements NetworkProbe {
  const _FixedProbe(this.result);

  final NetworkMeasurement result;

  @override
  Future<NetworkMeasurement> measure() async => result;
}

/// `Check Network` tugmasini bosib o'lchov natijasini golden'ga chiqaradi.
/// Sarlavhadagi bir xil matndan ajratish uchun `ListView` ichidan qidiriladi.
Future<void> _runMeasurement(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(ListView), matching: find.text('Check Network')),
  );
  await tester.pumpAndSettle();
}

void main() {
  screenGoldenMatrix(
    'diagnosis_with_faults',
    builder: () => const DiagnosisScreen(),
    overrides: () => <Override>[
      deviceDiagnosticsProvider.overrideWithValue(
        const DeviceDiagnostics(
          eldCoordinates: DiagnosticState.notWorking,
          gpsCoordinates: DiagnosticState.working,
          network: NetworkQuality.fair,
        ),
      ),
      // M77: haydovchi qaysi kod yonganini ko'rishi shart.
      eldActiveFaultsProvider.overrideWithValue(<EldFault>[
        EldFault(code: EldFaultCode.power, kind: EldFaultKind.malfunction, detectedAt: _t0),
        EldFault(code: EldFaultCode.timing, kind: EldFaultKind.diagnostic, detectedAt: _t0),
      ]),
    ],
  );

  screenGoldenMatrix(
    'check_network_measured',
    builder: () => const CheckNetworkScreen(),
    overrides: () => <Override>[
      networkProbeProvider.overrideWithValue(
        const _FixedProbe(NetworkMeasurement(mbps: 14, roundTrip: Duration(milliseconds: 180))),
      ),
    ],
    pumpBeforeTest: _runMeasurement,
  );
}
