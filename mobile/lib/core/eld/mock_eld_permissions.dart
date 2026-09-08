/// `MockEldPermissionService` — ekranlar va testlar uchun (M80, M163).
///
/// Prodda ishlatilmaydi: `eldPermissionServiceProvider` uni faqat
/// `Env.mockEldEnabled` bo'lganda tanlaydi.
library;

import 'dart:async';

import 'eld_permissions.dart';

class MockEldPermissionService implements EldPermissionService {
  MockEldPermissionService({
    Map<EldPermission, EldPermissionStatus>? initial,
    bool bluetoothOn = true,
    bool locationServicesOn = true,
    this.grantOnRequest = true,
  }) : _snapshot = EldPermissionSnapshot(
         statuses:
             initial ??
             <EldPermission, EldPermissionStatus>{
               for (final EldPermission p in EldPermission.values) p: EldPermissionStatus.unknown,
             },
         bluetoothOn: bluetoothOn,
         locationServicesOn: locationServicesOn,
       );

  /// `false` — har so'rov `denied` qaytaradi (rad etilgan oqimni sinash).
  final bool grantOnRequest;

  /// «Don't ask again» ni taqlid qilish: bu to'plamdagilar `permanentlyDenied`.
  final Set<EldPermission> permanentlyDenied = <EldPermission>{};

  /// So'rov tartibi — §10.2 ketma-ketligini tekshirish uchun.
  final List<EldPermission> requestLog = <EldPermission>[];

  /// Sozlamalar ekrani necha marta ochilgani.
  int openSettingsCalls = 0;
  int openLocationSettingsCalls = 0;
  int openBluetoothSettingsCalls = 0;

  final StreamController<EldPermissionSnapshot> _changes =
      StreamController<EldPermissionSnapshot>.broadcast();

  EldPermissionSnapshot _snapshot;

  @override
  Stream<EldPermissionSnapshot> get changes => _changes.stream;

  @override
  Future<EldPermissionSnapshot> snapshot() async => _snapshot;

  @override
  Future<EldPermissionStatus> request(EldPermission permission) async {
    requestLog.add(permission);
    final EldPermissionStatus next;
    if (permanentlyDenied.contains(permission)) {
      next = EldPermissionStatus.permanentlyDenied;
    } else if (grantOnRequest) {
      next = EldPermissionStatus.granted;
    } else {
      next = EldPermissionStatus.denied;
    }
    _apply(permission, next);
    return next;
  }

  @override
  Future<EldPermissionSnapshot> requestOnboardingFlow() async {
    for (final EldPermission p in EldPermission.requestOrder) {
      if (_snapshot.statusOf(p).isAllowed) {
        continue;
      }
      await request(p);
    }
    return _snapshot;
  }

  @override
  Future<void> openAppSettings() async => openSettingsCalls++;

  @override
  Future<void> openLocationSettings() async => openLocationSettingsCalls++;

  @override
  Future<void> openBluetoothSettings() async => openBluetoothSettingsCalls++;

  @override
  Future<EldPermissionSnapshot> refresh() async {
    _emit(_snapshot);
    return _snapshot;
  }

  @override
  Future<void> dispose() => _changes.close();

  // --- Skript API si -------------------------------------------------------

  /// Holatni to'g'ridan-to'g'ri o'rnatadi (test stsenariysi).
  void set(EldPermission permission, EldPermissionStatus status) => _apply(permission, status);

  /// Tizim xizmatlarini yoqadi/o'chiradi.
  void setServices({bool? bluetoothOn, bool? locationServicesOn}) =>
      _emit(_snapshot.copyWith(bluetoothOn: bluetoothOn, locationServicesOn: locationServicesOn));

  void _apply(EldPermission permission, EldPermissionStatus status) {
    final Map<EldPermission, EldPermissionStatus> next = Map<EldPermission, EldPermissionStatus>.of(
      _snapshot.statuses,
    )..[permission] = status;
    _emit(_snapshot.copyWith(statuses: next));
  }

  void _emit(EldPermissionSnapshot next) {
    _snapshot = next;
    if (!_changes.isClosed) {
      _changes.add(next);
    }
  }
}
