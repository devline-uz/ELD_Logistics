/// Joylashuv qiymat obyektlari va aniqlik siyosati (tz-mobile §11.3, #7).
library;

/// GPS fiksatsiyasi.
class LocationFix {
  const LocationFix({
    required this.at,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    this.speedKmh,
    this.headingDeg,
    this.altitudeM,
    this.fromEld = false,
  });

  /// UTC (`TimeSource`).
  final DateTime at;
  final double lat;
  final double lng;

  /// Gorizontal aniqlik, metr.
  final double accuracyM;

  final double? speedKmh;
  final double? headingDeg;
  final double? altitudeM;

  /// `true` — koordinata ELD dan keldi (telefon GPS emas).
  final bool fromEld;

  /// **>150 m** → «location might be inaccurate» (tz-mobile §21 #7, `tz.md` Q9).
  bool get isInaccurate => accuracyM > kLocationAccuracyLimitM;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationFix &&
          other.at == at &&
          other.lat == lat &&
          other.lng == lng &&
          other.accuracyM == accuracyM &&
          other.fromEld == fromEld;

  @override
  int get hashCode => Object.hash(at, lat, lng, accuracyM, fromEld);

  @override
  String toString() => 'LocationFix($lat, $lng, ±${accuracyM.toStringAsFixed(0)}m, eld=$fromEld)';
}

/// Aniqlik chegarasi — undan katta qiymatda UI ⚠️ ikonka ko'rsatadi va
/// `M-12 Location error` dialogini taklif qiladi.
const double kLocationAccuracyLimitM = 150;

/// «Yangi» fiksatsiya oynasi — undan eskisi `Not working` hisoblanadi (M-46).
const Duration kLocationFreshness = Duration(seconds: 60);

/// GPS chastotasi profillari — batareya uchun adaptiv (risk R6).
enum LocationProfile {
  /// Haydash: eng aniq, tez-tez.
  driving(interval: Duration(seconds: 15), distanceFilterM: 50),

  /// To'xtagan/On Duty: kamroq.
  stationary(interval: Duration(minutes: 5), distanceFilterM: 250),

  /// Off Duty / Sleeper: minimal (faqat status eventi uchun so'raladi).
  idle(interval: Duration(minutes: 15), distanceFilterM: 1000),

  /// Butunlay o'chirilgan (ruxsat yo'q yoki ilova to'xtatilgan).
  off(interval: Duration.zero, distanceFilterM: 0);

  const LocationProfile({required this.interval, required this.distanceFilterM});

  final Duration interval;
  final double distanceFilterM;

  bool get isActive => this != off;
}

/// Reverse geocoding natijasi — `"12 km NE of Lahore"` (tz.md Q9).
class GeocodedPlace {
  const GeocodedPlace({
    required this.label,
    this.city,
    this.state,
    this.country,
    this.distanceKm,
    this.bearing,
  });

  /// Ko'rsatiladigan matn (allaqachon formatlangan).
  final String label;

  final String? city;
  final String? state;
  final String? country;
  final double? distanceKm;

  /// `N`, `NE`, `E`, … — 8 rumb.
  final String? bearing;

  @override
  String toString() => label;
}

/// 8 rumb yo'nalishi (formatlash uchun).
String compassBearing(double degrees) {
  const List<String> points = <String>['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final double normalized = (degrees % 360 + 360) % 360;
  return points[((normalized + 22.5) ~/ 45) % 8];
}
