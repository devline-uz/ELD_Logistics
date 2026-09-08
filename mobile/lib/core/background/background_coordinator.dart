/// Fon rejimi koordinatori (tz-mobile §10.4, M73, risk R6).
///
/// Bitta joyda uch narsani bog'laydi:
/// 1. **haydash bayrog'i** — M73 uchun (`stop` rad etiladi);
/// 2. **GPS chastotasi** — [LocationProfile] adaptiv almashadi;
/// 3. **doimiy bildirishnoma** matni (matn presentation qatlamidan keladi —
///    `core` da hard-coded matn taqiq).
library;

import 'dart:async';

import '../eld/motion_detector.dart';
import '../location/location_models.dart';
import '../location/location_service.dart';
import 'background_service.dart';

class BackgroundCoordinator {
  BackgroundCoordinator({required this._service, required this._location});

  final BackgroundService _service;
  final LocationService _location;

  StreamSubscription<MotionEvent>? _motionSub;
  bool _driving = false;
  BackgroundNotification? _notification;

  /// Haydash rejimi (M73 himoyasi shu bayroqqa tayanadi).
  bool get driving => _driving;

  LocationProfile get locationProfile => _driving
      ? LocationProfile.driving
      : (_notification == null ? LocationProfile.idle : LocationProfile.stationary);

  /// Auto-DR oqimiga obuna bo'ladi: harakat → `driving`, to'xtash → `stationary`.
  void attachMotion(Stream<MotionEvent> events) {
    _motionSub ??= events.listen((MotionEvent event) {
      switch (event.type) {
        case MotionEventType.movingConfirmed:
          unawaited(setDriving(true));
        case MotionEventType.stopped:
        case MotionEventType.idlePromptDue:
        case MotionEventType.idleNoAnswer:
          break; // M59: to'xtaganda ham status DR da qoladi — xizmat davom etadi.
      }
    });
  }

  /// Xizmatni ishga tushiradi/yangilaydi.
  Future<bool> start(BackgroundNotification notification) async {
    _notification = notification;
    final bool ok = await _service.start(notification);
    await _location.start(locationProfile);
    return ok;
  }

  /// Bildirishnoma matnini yangilaydi (status yoki `Driving Time Left`).
  Future<void> updateNotification(BackgroundNotification notification) async {
    if (_notification == notification) {
      return;
    }
    _notification = notification;
    await _service.update(notification);
  }

  /// Haydash bayrog'ini o'rnatadi va GPS chastotasini moslaydi (R6).
  Future<void> setDriving(bool value) async {
    if (_driving == value) {
      return;
    }
    _driving = value;
    await _location.setProfile(locationProfile);
  }

  /// **M73:** haydash rejimida to'xtatilmaydi.
  Future<bool> stop() async {
    final bool stopped = await _service.stop(driving: _driving);
    if (stopped) {
      _notification = null;
      await _location.stop();
    }
    return stopped;
  }

  Future<void> dispose() async {
    await _motionSub?.cancel();
    _motionSub = null;
  }
}
