/// `M-18 Permissions` kontrolleri (tz-mobile §10.2, M69, M70).
///
/// Holat manbai — `core/eld` dagi [EldPermissionSnapshot] oqimi; bu kontroller
/// faqat **amallar**ni (so'rash, sozlamalarni ochish) va «so'rov ketmoqda»
/// bayrog'ini boshqaradi. Telefon va planshet (T-22) bitta kontrollerni
/// ulashadi (M7).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/eld/eld_permissions.dart';
import '../../../../core/eld/eld_providers.dart';

/// Ekran holati: qaysi ruxsat so'ralayapti va oqim ishlayaptimi.
class PermissionsUiState {
  const PermissionsUiState({this.pending, this.runningFlow = false});

  /// Hozir so'ralayotgan bitta ruxsat (`null` — hech biri).
  final EldPermission? pending;

  /// §10.2 ketma-ketligi (`Allow all permissions`) ishlayaptimi.
  final bool runningFlow;

  bool get busy => pending != null || runningFlow;

  PermissionsUiState copyWith({
    EldPermission? pending,
    bool? runningFlow,
    bool clearPending = false,
  }) => PermissionsUiState(
    pending: clearPending ? null : (pending ?? this.pending),
    runningFlow: runningFlow ?? this.runningFlow,
  );
}

class PermissionsController extends Notifier<PermissionsUiState> {
  @override
  PermissionsUiState build() => const PermissionsUiState();

  EldPermissionService get _service => ref.read(eldPermissionServiceProvider);

  /// Bitta qatorni bosish: rad etilgan bo'lsa qayta so'raydi, «don't ask
  /// again» bo'lsa tizim sozlamalarini ochadi (M69).
  Future<void> requestOrOpenSettings(EldPermission permission, EldPermissionStatus status) async {
    if (status.isAllowed) {
      return;
    }
    if (status.needsSettings) {
      await _service.openAppSettings();
      return;
    }
    state = state.copyWith(pending: permission);
    try {
      await _service.request(permission);
    } finally {
      state = state.copyWith(clearPending: true);
    }
  }

  /// §10.2 [MUST] ketma-ketligi: notifications → bluetooth → location →
  /// location always → battery. Rad etilsa ham keyingisiga o'tiladi.
  Future<void> runOnboardingFlow() async {
    if (state.runningFlow) {
      return;
    }
    state = state.copyWith(runningFlow: true);
    try {
      await _service.requestOnboardingFlow();
    } finally {
      state = state.copyWith(runningFlow: false);
    }
  }

  Future<void> openLocationSettings() => _service.openLocationSettings();

  Future<void> openBluetoothSettings() => _service.openBluetoothSettings();

  Future<void> refresh() => _service.refresh();
}

final NotifierProvider<PermissionsController, PermissionsUiState> permissionsControllerProvider =
    NotifierProvider<PermissionsController, PermissionsUiState>(PermissionsController.new);
