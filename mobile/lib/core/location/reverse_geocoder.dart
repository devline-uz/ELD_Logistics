/// Reverse geocoding + kesh (tz-mobile §11.3, `tz.md` Q9).
///
/// Format: **`"12 km NE of Lahore"`**. Kesh — tarmoq/batareya uchun majburiy
/// (risk R6): koordinata ~1 km katakka yaxlitlanadi va natija qayta
/// ishlatiladi.
library;

import 'dart:collection';
import 'dart:math' as math;

import 'location_models.dart';

/// Reverse geocoding shartnomasi.
abstract class ReverseGeocoder {
  /// [lat]/[lng] uchun joy nomi; topilmasa `null`.
  Future<GeocodedPlace?> lookup({required double lat, required double lng});
}

/// Kesh kaliti uchun katak o'lchami (daraja). 0.01° ≈ 1.1 km.
const double kGeocodeGridDeg = 0.01;

/// Keshdagi maksimal yozuv soni (LRU).
const int kGeocodeCacheSize = 256;

/// Kesh yozuvining amal qilish muddati.
const Duration kGeocodeCacheTtl = Duration(days: 7);

/// Delegatni LRU kesh bilan o'raydi.
class CachedReverseGeocoder implements ReverseGeocoder {
  CachedReverseGeocoder({
    required this._delegate,
    required this._now,
    this.maxEntries = kGeocodeCacheSize,
    this.ttl = kGeocodeCacheTtl,
  });

  final ReverseGeocoder _delegate;
  final DateTime Function() _now;
  final int maxEntries;
  final Duration ttl;

  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap<String, _CacheEntry>();

  /// Delegatga necha marta murojaat qilingani (kesh samaradorligi testi).
  int delegateCalls = 0;

  int get cacheSize => _cache.length;

  @override
  Future<GeocodedPlace?> lookup({required double lat, required double lng}) async {
    final String key = cacheKey(lat, lng);
    final DateTime now = _now();
    final _CacheEntry? hit = _cache.remove(key);
    if (hit != null && now.difference(hit.at) < ttl) {
      _cache[key] = hit; // LRU: eng oxirgi ishlatilgan — oxiriga.
      return hit.place;
    }

    delegateCalls++;
    final GeocodedPlace? place = await _delegate.lookup(lat: lat, lng: lng);
    if (place != null) {
      _cache[key] = _CacheEntry(place: place, at: now);
      while (_cache.length > maxEntries) {
        _cache.remove(_cache.keys.first);
      }
    }
    return place;
  }

  void clear() => _cache.clear();

  /// Koordinatani katakka yaxlitlaydi (kesh kaliti).
  static String cacheKey(double lat, double lng) {
    final int y = (lat / kGeocodeGridDeg).round();
    final int x = (lng / kGeocodeGridDeg).round();
    return '$y:$x';
  }
}

class _CacheEntry {
  const _CacheEntry({required this.place, required this.at});

  final GeocodedPlace place;
  final DateTime at;
}

/// Shahar yozuvi — oflayn/mok geocoder uchun.
class GeoCity {
  const GeoCity({
    required this.name,
    required this.lat,
    required this.lng,
    this.state,
    this.country,
  });

  final String name;
  final double lat;
  final double lng;
  final String? state;
  final String? country;
}

/// Eng yaqin shaharga nisbatan `"<n> km <rumb> of <shahar>"` yig'adi.
///
/// Tarmoq talab qilmaydi — oflayn rejimda ham ishlaydi (§5).
class NearestCityGeocoder implements ReverseGeocoder {
  const NearestCityGeocoder(this.cities);

  final List<GeoCity> cities;

  @override
  Future<GeocodedPlace?> lookup({required double lat, required double lng}) async {
    if (cities.isEmpty) {
      return null;
    }
    GeoCity nearest = cities.first;
    double bestKm = double.infinity;
    for (final GeoCity city in cities) {
      final double km = haversineKm(lat, lng, city.lat, city.lng);
      if (km < bestKm) {
        bestKm = km;
        nearest = city;
      }
    }
    return formatPlace(lat: lat, lng: lng, city: nearest, distanceKm: bestKm);
  }
}

/// `"12 km NE of Lahore"` formatini yig'adi.
///
/// Masofa 1 km dan kichik bo'lsa shahar nomi yolg'iz qaytariladi.
GeocodedPlace formatPlace({
  required double lat,
  required double lng,
  required GeoCity city,
  required double distanceKm,
}) {
  final int rounded = distanceKm.round();
  if (rounded < 1) {
    return GeocodedPlace(
      label: city.name,
      city: city.name,
      state: city.state,
      country: city.country,
      distanceKm: distanceKm,
    );
  }
  final String bearing = compassBearing(bearingDeg(city.lat, city.lng, lat, lng));
  return GeocodedPlace(
    label: '$rounded km $bearing of ${city.name}',
    city: city.name,
    state: city.state,
    country: city.country,
    distanceKm: distanceKm,
    bearing: bearing,
  );
}

const double _earthRadiusKm = 6371.0088;

/// Ikki nuqta orasidagi masofa (km).
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  final double dLat = _rad(lat2 - lat1);
  final double dLng = _rad(lng2 - lng1);
  final double a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return 2 * _earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
}

/// `from` dan `to` ga yo'nalish (daraja, 0 = shimol).
double bearingDeg(double lat1, double lng1, double lat2, double lng2) {
  final double dLng = _rad(lng2 - lng1);
  final double y = math.sin(dLng) * math.cos(_rad(lat2));
  final double x =
      math.cos(_rad(lat1)) * math.sin(_rad(lat2)) -
      math.sin(_rad(lat1)) * math.cos(_rad(lat2)) * math.cos(dLng);
  final double deg = math.atan2(y, x) * 180 / math.pi;
  return (deg % 360 + 360) % 360;
}

double _rad(double deg) => deg * math.pi / 180;
