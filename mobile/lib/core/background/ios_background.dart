/// iOS fon rejimi sozlamasi (tz-mobile §10.4, M74, risk R5).
///
/// `Info.plist`:
/// * `UIBackgroundModes` = `bluetooth-central`, `location`;
/// * `NSBluetoothAlwaysUsageDescription`, `NSLocation*UsageDescription`.
///
/// Dart tomonda faqat bitta ish qoladi — `flutter_blue_plus` ga
/// `CBCentralManagerOptionRestoreIdentifierKey` bilan ishga tushishni aytish
/// (`setOptions(restoreState: true)`). Buni **birinchi BLE chaqiruvidan oldin**
/// bajarish shart, aks holda `CBCentralManager` restore identifier'siz
/// yaratiladi.
///
/// `background fetch` ga tayanilmaydi (M167) — uyg'otish manbai
/// BLE restoration + Significant Location Change.
library;

import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../eld/eld_gatt_profile.dart';
import 'state_restoration.dart';

/// iOS BLE fon rejimini sozlaydi va tiklanishni aniqlaydi.
class IosBackgroundBootstrap {
  IosBackgroundBootstrap({required this._coordinator, this.profile = EldGattProfile.provisional});

  final StateRestorationCoordinator _coordinator;
  final EldGattProfile profile;

  /// `main()` da, `runApp` dan **oldin** chaqiriladi.
  Future<void> configure() async {
    if (!Platform.isIOS) {
      return;
    }
    // M74: state restoration — tizim ilovani BLE hodisasida qayta uyg'otadi.
    await FlutterBluePlus.setOptions(restoreState: true, showPowerAlert: false);
  }

  /// Ilova ishga tushganda tizim allaqachon ELD ga ulangan bo'lsa — bu
  /// **restoration** demakdir (sovuq start emas).
  Future<RestoreReason> detect() async {
    if (!Platform.isIOS) {
      return RestoreReason.coldStart;
    }
    final List<BluetoothDevice> devices = await FlutterBluePlus.systemDevices(<Guid>[
      Guid(profile.serviceUuid),
    ]);
    final RestoreReason reason = devices.isEmpty
        ? RestoreReason.coldStart
        : RestoreReason.iosBleRestore;
    await _coordinator.notify(reason);
    return reason;
  }
}
