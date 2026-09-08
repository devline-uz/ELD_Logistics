/// Joylashuv provayderlari (§11.3, R6).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../eld/eld_providers.dart';
import '../time/time_providers.dart';
import 'location_models.dart';
import 'location_service.dart';
import 'mock_location_service.dart';
import 'platform_location_service.dart';
import 'platform_reverse_geocoder.dart';
import 'reverse_geocoder.dart';

/// GPS xizmati — ilova hayoti davomida yashaydi.
final Provider<LocationService> locationServiceProvider = Provider<LocationService>((Ref ref) {
  final DateTime Function() now = ref.watch(timeSourceProvider).now;
  final LocationService service = mockEldEnabled
      ? MockLocationService(now: now)
      : PlatformLocationService(now: now);
  ref.onDispose(service.dispose);
  return service;
});

/// Oxirgi fiksatsiya oqimi.
final StreamProvider<LocationFix> locationFixProvider = StreamProvider<LocationFix>(
  (Ref ref) => ref.watch(locationServiceProvider).fixes,
);

/// Reverse geocoder — keshli (R6: tarmoq va batareya).
final Provider<ReverseGeocoder> reverseGeocoderProvider = Provider<ReverseGeocoder>((Ref ref) {
  final ReverseGeocoder delegate = mockEldEnabled
      ? MockReverseGeocoder()
      : const PlatformReverseGeocoder();
  return CachedReverseGeocoder(delegate: delegate, now: ref.watch(timeSourceProvider).now);
});

/// Joriy joy nomi (`"12 km NE of Lahore"`).
final FutureProvider<GeocodedPlace?> currentPlaceProvider = FutureProvider<GeocodedPlace?>((
  Ref ref,
) async {
  final LocationFix? fix = ref.watch(locationFixProvider).value;
  if (fix == null) {
    return null;
  }
  return ref.watch(reverseGeocoderProvider).lookup(lat: fix.lat, lng: fix.lng);
});
