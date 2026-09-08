/// `PlatformReverseGeocoder` — `MethodChannel('eld/geocoder')`.
///
/// Native tomon: Android `android.location.Geocoder`, iOS `CLGeocoder`.
/// Ikkalasi ham shahar nomi va shahar markazining koordinatasini qaytaradi;
/// masofa/rumb Dart tomonida hisoblanadi (bir xil formula → bir xil natija).
///
/// Xato yoki tarmoq yo'q bo'lsa `null` qaytadi — chaqiruvchi
/// [NearestCityGeocoder] ga tushadi.
library;

import 'package:flutter/services.dart';

import 'location_models.dart';
import 'reverse_geocoder.dart';

const MethodChannel kGeocoderChannel = MethodChannel('eld/geocoder');

class PlatformReverseGeocoder implements ReverseGeocoder {
  const PlatformReverseGeocoder({MethodChannel? channel}) : _channel = channel ?? kGeocoderChannel;

  final MethodChannel _channel;

  @override
  Future<GeocodedPlace?> lookup({required double lat, required double lng}) async {
    final Map<Object?, Object?>? raw;
    try {
      raw = await _channel.invokeMethod<Map<Object?, Object?>>('reverse', <String, Object?>{
        'lat': lat,
        'lng': lng,
      });
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
    if (raw == null) {
      return null;
    }
    final Object? name = raw['city'];
    if (name is! String || name.isEmpty) {
      return null;
    }
    final double? cityLat = _double(raw['city_lat']);
    final double? cityLng = _double(raw['city_lng']);
    final GeoCity city = GeoCity(
      name: name,
      lat: cityLat ?? lat,
      lng: cityLng ?? lng,
      state: raw['state'] as String?,
      country: raw['country'] as String?,
    );
    final double distanceKm = cityLat == null || cityLng == null
        ? 0
        : haversineKm(lat, lng, cityLat, cityLng);
    return formatPlace(lat: lat, lng: lng, city: city, distanceKm: distanceKm);
  }

  static double? _double(Object? value) => switch (value) {
    final num n => n.toDouble(),
    _ => null,
  };
}

/// Testlar va mock rejim uchun — har doim bir xil joyni qaytaradi.
class MockReverseGeocoder implements ReverseGeocoder {
  MockReverseGeocoder({
    this.city = const GeoCity(name: 'Tashkent', lat: 41.311081, lng: 69.240562, country: 'UZ'),
  });

  final GeoCity city;

  int calls = 0;

  @override
  Future<GeocodedPlace?> lookup({required double lat, required double lng}) async {
    calls++;
    return formatPlace(
      lat: lat,
      lng: lng,
      city: city,
      distanceKm: haversineKm(lat, lng, city.lat, city.lng),
    );
  }
}
