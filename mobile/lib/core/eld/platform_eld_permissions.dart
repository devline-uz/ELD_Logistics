/// `PlatformEldPermissionService` — `MethodChannel('eld/permissions')`.
///
/// Native tomon: `android/app/src/main/kotlin/.../EldPermissionsPlugin.kt` va
/// `ios/Runner/EldPermissionsPlugin.swift`. `permission_handler` paketi
/// ishlatilmaydi — `pubspec.yaml` muzlatilgan, ruxsat mantig'i esa §10.2 ga
/// qat'iy bog'langan (Android 12+ BLE, `neverForLocation` yo'qligi, alohida
/// `ACCESS_BACKGROUND_LOCATION` qadami).
library;

import 'dart:async';

import 'package:flutter/services.dart';

import 'eld_permissions.dart';

/// Native kanal nomlari (§10.7 uslubi bilan bir xil).
const MethodChannel kEldPermissionsChannel = MethodChannel('eld/permissions');

class PlatformEldPermissionService implements EldPermissionService {
  PlatformEldPermissionService({MethodChannel? channel})
    : _channel = channel ?? kEldPermissionsChannel;

  final MethodChannel _channel;

  final StreamController<EldPermissionSnapshot> _changes =
      StreamController<EldPermissionSnapshot>.broadcast();

  EldPermissionSnapshot _last = const EldPermissionSnapshot();

  @override
  Stream<EldPermissionSnapshot> get changes => _changes.stream;

  @override
  Future<EldPermissionSnapshot> snapshot() async {
    final Map<Object?, Object?>? raw = await _channel.invokeMethod<Map<Object?, Object?>>(
      'snapshot',
    );
    return _parse(raw);
  }

  @override
  Future<EldPermissionStatus> request(EldPermission permission) async {
    final String? raw = await _channel.invokeMethod<String>('request', <String, Object?>{
      'permission': permission.wire,
    });
    final EldPermissionStatus status = EldPermissionStatus.fromWire(raw ?? '');
    await refresh();
    return status;
  }

  @override
  Future<EldPermissionSnapshot> requestOnboardingFlow() async {
    for (final EldPermission permission in EldPermission.requestOrder) {
      final EldPermissionSnapshot current = _last;
      if (current.statusOf(permission).isAllowed) {
        continue;
      }
      // Rad etilsa ham keyingi qadamga o'tiladi (M69 — ilova bloklanmaydi).
      await request(permission);
    }
    return refresh();
  }

  @override
  Future<void> openAppSettings() => _channel.invokeMethod<void>('openAppSettings');

  @override
  Future<void> openLocationSettings() => _channel.invokeMethod<void>('openLocationSettings');

  @override
  Future<void> openBluetoothSettings() => _channel.invokeMethod<void>('openBluetoothSettings');

  @override
  Future<EldPermissionSnapshot> refresh() async {
    final EldPermissionSnapshot next = await snapshot();
    _last = next;
    if (!_changes.isClosed) {
      _changes.add(next);
    }
    return next;
  }

  @override
  Future<void> dispose() => _changes.close();

  EldPermissionSnapshot _parse(Map<Object?, Object?>? raw) {
    if (raw == null) {
      return const EldPermissionSnapshot();
    }
    final Map<EldPermission, EldPermissionStatus> statuses = <EldPermission, EldPermissionStatus>{};
    final Object? permissions = raw['permissions'];
    if (permissions is Map<Object?, Object?>) {
      for (final MapEntry<Object?, Object?> e in permissions.entries) {
        final EldPermission? key = EldPermission.fromWire('${e.key}');
        if (key != null) {
          statuses[key] = EldPermissionStatus.fromWire('${e.value}');
        }
      }
    }
    return EldPermissionSnapshot(
      statuses: statuses,
      bluetoothOn: raw['bluetooth_on'] == true,
      locationServicesOn: raw['location_services_on'] == true,
    );
  }
}
