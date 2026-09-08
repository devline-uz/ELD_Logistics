/// ELD domen enumlari → lokalizatsiya qilingan matn.
///
/// Bir joyda turadi, chunki bir xil yorliqlar M-17, M-18, M-19, M-46 va
/// Home banneri tomonidan ishlatiladi (nusxa ko'chirilmaydi).
library;

import '../../../core/eld/eld_codes.dart';
import '../../../core/eld/eld_models.dart';
import '../../../core/eld/eld_permissions.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Banner matni (M68 kanonik matnlari, M77 malfunction shakli).
///
/// [code] faqat [EldConnectionState.malfunction] uchun kerak.
String eldConnectionLabel(AppLocalizations l10n, EldConnectionState state, {String? code}) =>
    switch (state) {
      EldConnectionState.connected => l10n.eldBannerConnected,
      EldConnectionState.connecting => l10n.eldBannerConnecting,
      EldConnectionState.notConnected => l10n.eldBannerNotConnected,
      EldConnectionState.diagnostic => l10n.eldBannerDiagnostic,
      // M77: matn qat'iy, kod qavs ichida.
      EldConnectionState.malfunction => l10n.eldBannerMalfunction(
        code ?? EldFaultCode.other.letter,
      ),
    };

/// `P/E/T/L/R/S/O` → o'qiladigan nom.
String eldFaultLabel(AppLocalizations l10n, EldFaultCode code) => switch (code) {
  EldFaultCode.power => l10n.eldFaultPower,
  EldFaultCode.engineSync => l10n.eldFaultEngineSync,
  EldFaultCode.timing => l10n.eldFaultTiming,
  EldFaultCode.positioning => l10n.eldFaultPositioning,
  EldFaultCode.dataRecording => l10n.eldFaultDataRecording,
  EldFaultCode.dataTransfer => l10n.eldFaultDataTransfer,
  EldFaultCode.other => l10n.eldFaultOther,
};

/// Kodga biriktirilgan maslahat (tz-mobile §10.6). `null` — maslahat yo'q.
String? eldFaultHint(AppLocalizations l10n, EldFault fault) => switch (fault.code) {
  EldFaultCode.dataRecording => l10n.eldFaultHintDataRecording,
  EldFaultCode.dataTransfer => l10n.eldFaultHintDataTransfer(int.tryParse(fault.detail ?? '') ?? 8),
  EldFaultCode.timing => l10n.eldFaultHintTiming,
  EldFaultCode.positioning => l10n.eldFaultHintPositioning,
  EldFaultCode.power || EldFaultCode.engineSync || EldFaultCode.other => null,
};

/// Transport xatosi → foydalanuvchi xabari.
String eldFailureLabel(AppLocalizations l10n, EldTransportFailure failure) => switch (failure) {
  EldTransportFailure.bluetoothOff => l10n.eldErrBluetoothOff,
  EldTransportFailure.permissionDenied => l10n.eldErrPermissionDenied,
  EldTransportFailure.notFound => l10n.eldErrNotFound,
  EldTransportFailure.connectTimeout => l10n.eldErrConnectTimeout,
  EldTransportFailure.handshakeFailed => l10n.eldErrHandshakeFailed,
  EldTransportFailure.disconnected => l10n.eldErrDisconnected,
  EldTransportFailure.unsupported => l10n.eldErrUnsupported,
};

/// M-18 jadvalidagi qator nomi.
String eldPermissionLabel(AppLocalizations l10n, EldPermission permission) => switch (permission) {
  EldPermission.locationWhenInUse => l10n.permissionLocation,
  EldPermission.locationAlways => l10n.permissionLocationAlways,
  EldPermission.bluetooth => l10n.permissionBluetooth,
  EldPermission.notifications => l10n.permissionNotifications,
  EldPermission.batteryOptimization => l10n.permissionBatteryOptimization,
};

/// `Allowed` / `Not allowed` (M-18).
String eldPermissionStatusLabel(AppLocalizations l10n, EldPermissionStatus status) =>
    status.isAllowed ? l10n.permissionAllowed : l10n.permissionNotAllowed;
