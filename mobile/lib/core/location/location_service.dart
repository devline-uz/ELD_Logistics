/// `LocationService` — telefon GPS abstraksiyasi (tz-mobile §11.3, R6).
///
/// **Qat'iy:** platforma tipi (CoreLocation / FusedLocationProvider) UI ga
/// chiqmaydi. Implementatsiyalar: [MockLocationService] (birinchi, ekranlar u
/// bilan ishlaydi) va `PlatformLocationService`
/// (`MethodChannel('eld/location')` + `EventChannel('eld/location/stream')`).
library;

import 'dart:async';

import 'location_models.dart';

abstract class LocationService {
  /// Oxirgi fiksatsiya (`null` — hali yo'q yoki ruxsat berilmagan).
  LocationFix? get lastFix;

  /// Fiksatsiyalar oqimi.
  Stream<LocationFix> get fixes;

  /// Kuzatishni boshlaydi/yangilaydi. Chastota [profile] bilan adaptiv (R6).
  Future<void> start(LocationProfile profile);

  /// Profilni almashtiradi (haydash boshlandi/tugadi).
  Future<void> setProfile(LocationProfile profile);

  Future<void> stop();

  /// Bir martalik fix (status eventi uchun). Kutish [timeout] bilan cheklangan.
  Future<LocationFix?> currentFix({Duration timeout = const Duration(seconds: 10)});

  Future<void> dispose();
}

/// [LocationService] uchun umumiy oqim/keshni saqlaydigan asos.
abstract base class BaseLocationService implements LocationService {
  BaseLocationService({required this._now});

  final DateTime Function() _now;

  final StreamController<LocationFix> controller = StreamController<LocationFix>.broadcast();

  LocationFix? _last;
  LocationProfile _profile = LocationProfile.off;

  LocationProfile get profile => _profile;

  /// Joriy vaqt (`TimeSource.now`).
  DateTime nowUtc() => _now();

  @override
  LocationFix? get lastFix => _last;

  @override
  Stream<LocationFix> get fixes => controller.stream;

  @override
  Future<void> setProfile(LocationProfile profile) => start(profile);

  /// [start] implementatsiyasi profil o'rnatishda chaqiradi.
  void rememberProfile(LocationProfile profile) => _profile = profile;

  /// Yangi fiksatsiyani keshlab oqimga chiqaradi.
  void publish(LocationFix fix) {
    _last = fix;
    if (!controller.isClosed) {
      controller.add(fix);
    }
  }

  /// Oxirgi fiksatsiya [kLocationFreshness] ichida keldimi (M-46 `GPS coordinates`).
  bool isFresh(DateTime now) {
    final LocationFix? fix = _last;
    return fix != null && now.difference(fix.at) <= kLocationFreshness;
  }

  @override
  Future<LocationFix?> currentFix({Duration timeout = const Duration(seconds: 10)}) async {
    if (isFresh(nowUtc())) {
      return _last;
    }
    try {
      return await fixes.first.timeout(timeout);
    } on TimeoutException {
      return _last;
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await controller.close();
  }
}
