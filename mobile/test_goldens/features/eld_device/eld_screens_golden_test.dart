@Timeout(Duration(seconds: 60))
/// **M-18 Permissions** va **M-19 ELD connect** — *ekran* darajasidagi
/// goldenlar: light/dark × phone/tablet (tz-mobile C.3 DoD, M176).
///
/// Bu fayl `eld_device_golden_test.dart` ni to'ldiradi — u yerda faqat
/// banner ko'rinishi olingan edi, ekranning o'zi emas.
///
/// Holatlar **eng ma'nolisi** tanlangan (bo'sh/loading emas):
/// * M-19 — skandan keyin topilgan qurilmalar ro'yxati (zaif signal yorlig'i
///   bilan) + `ELD · Not connected` banneri;
/// * M-18 — ruxsatlar berilmagan holat: `Not allowed` / `Open settings`
///   badge'lari, M69 tushuntirishi va `Allow all permissions` tugmasi.
///
/// Provayderlar to'liq override qilinadi: DB, BLE transporti va real vaqt
/// ishtirok etmaydi — golden deterministik.
library;

import 'package:eld_mobile/core/eld/eld_models.dart';
import 'package:eld_mobile/core/eld/eld_permissions.dart';
import 'package:eld_mobile/core/eld/eld_providers.dart';
import 'package:eld_mobile/core/eld/eld_session.dart';
import 'package:eld_mobile/features/eld_device/presentation/controllers/eld_connect_controller.dart';
import 'package:eld_mobile/features/eld_device/presentation/screens/eld_connect_screen.dart';
import 'package:eld_mobile/features/eld_device/presentation/screens/permissions_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../golden_screen_host.dart';

/// Skan tugagan holatni qotirib beruvchi kontroller — `scan()` chaqirilmaydi,
/// shuning uchun taymer/animatsiya golden'ga tushmaydi.
class _StaticEldConnectController extends EldConnectController {
  _StaticEldConnectController(this.initial);

  final EldConnectUiState initial;

  @override
  EldConnectUiState build() => initial;
}

/// Mock transport bergan ikki qurilma (ikkinchisi −93 dBm → `Weak signal`).
const EldConnectUiState _scanned = EldConnectUiState(
  devices: <EldDeviceRef>[
    EldDeviceRef(id: 'AA:BB:CC:10:21', name: 'ONEBOOK-ELD-1021', rssi: -58),
    EldDeviceRef(id: 'AA:BB:CC:20:44', name: 'ONEBOOK-ELD-2044', rssi: -93),
  ],
);

/// M69: aralash holat — bitta berilgan, bittasi «don't ask again».
const EldPermissionSnapshot _denied = EldPermissionSnapshot(
  statuses: <EldPermission, EldPermissionStatus>{
    EldPermission.locationWhenInUse: EldPermissionStatus.granted,
    EldPermission.locationAlways: EldPermissionStatus.denied,
    EldPermission.bluetooth: EldPermissionStatus.permanentlyDenied,
    EldPermission.notifications: EldPermissionStatus.denied,
  },
  bluetoothOn: true,
);

void main() {
  screenGoldenMatrix(
    'eld_connect_devices',
    builder: () => const EldConnectScreen(),
    overrides: () => <Override>[
      eldConnectControllerProvider.overrideWith(() => _StaticEldConnectController(_scanned)),
      eldSessionProvider.overrideWith(
        (Ref ref) => Stream<EldSessionState>.value(const EldSessionState()),
      ),
    ],
  );

  screenGoldenMatrix(
    'permissions_denied',
    builder: () => const PermissionsScreen(),
    overrides: () => <Override>[
      eldPermissionSnapshotProvider.overrideWith(
        (Ref ref) => Stream<EldPermissionSnapshot>.value(_denied),
      ),
    ],
  );
}
