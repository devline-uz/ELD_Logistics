/// `MockLocationService` — ekranlar va testlar uchun (M80, M163).
library;

import 'dart:async';

import 'location_models.dart';
import 'location_service.dart';

final class MockLocationService extends BaseLocationService {
  MockLocationService({
    required super.now,
    this.lat = 41.311081,
    this.lng = 69.240562,
    this.accuracyM = 8,
    this.permissionDenied = false,
  });

  double lat;
  double lng;
  double accuracyM;

  /// `true` — [start] hech narsa qilmaydi, fix kelmaydi (rad etilgan oqim).
  bool permissionDenied;

  /// Profil o'zgarishlari tarixi — adaptiv chastota testlari uchun.
  final List<LocationProfile> profileLog = <LocationProfile>[];

  bool started = false;

  @override
  Future<void> start(LocationProfile profile) async {
    rememberProfile(profile);
    profileLog.add(profile);
    started = profile.isActive && !permissionDenied;
  }

  @override
  Future<void> stop() async {
    started = false;
    rememberProfile(LocationProfile.off);
  }

  // --- Skript API si -------------------------------------------------------

  /// Bitta fiksatsiya chiqaradi.
  LocationFix emit({double? lat, double? lng, double? accuracyM, DateTime? at}) {
    final LocationFix fix = LocationFix(
      at: at ?? nowUtc(),
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
    );
    publish(fix);
    return fix;
  }

  /// Aniqligi chegaradan yuqori fiksatsiya (⚠️ oqimini sinash).
  LocationFix emitInaccurate({double accuracyM = kLocationAccuracyLimitM + 50}) =>
      emit(accuracyM: accuracyM);
}
