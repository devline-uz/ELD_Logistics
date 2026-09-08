/// `M-46 Diagnosis of device` va `M-47 Check network` domen modellari
/// (tz-mobile §10.5, M75, M76).
library;

/// Ko'rsatkich holati — dizayndagi `Working` / `Not working` badge.
enum DiagnosticState { working, notWorking }

/// `Network quality` darajalari (§10.5 jadvali).
enum NetworkQuality {
  good,
  fair,
  poor,
  offline;

  /// Oxirgi muvaffaqiyatli sync kechikishidan darajani hisoblaydi.
  ///
  /// Chegaralar `sync_scheduler` backoff'i bilan mos: 2 daqiqagacha `Good`,
  /// 15 daqiqagacha `Fair`, undan keyin `Poor`; tarmoq yo'q bo'lsa `Offline`.
  static NetworkQuality fromSyncLag(Duration? lag, {required bool online}) {
    if (!online) {
      return NetworkQuality.offline;
    }
    if (lag == null) {
      return NetworkQuality.poor;
    }
    if (lag <= kNetworkGoodLag) {
      return NetworkQuality.good;
    }
    if (lag <= kNetworkFairLag) {
      return NetworkQuality.fair;
    }
    return NetworkQuality.poor;
  }
}

/// `Good` chegarasi.
const Duration kNetworkGoodLag = Duration(minutes: 2);

/// `Fair` chegarasi.
const Duration kNetworkFairLag = Duration(minutes: 15);

/// M-46 ekranining to'liq kesimi.
class DeviceDiagnostics {
  const DeviceDiagnostics({
    required this.eldCoordinates,
    required this.gpsCoordinates,
    required this.network,
  });

  /// ELD dan oxirgi **60 s** ichida lat/lng keldimi (§10.5).
  final DiagnosticState eldCoordinates;

  /// Telefon GPS fiksatsiyasi bormi.
  final DiagnosticState gpsCoordinates;

  final NetworkQuality network;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceDiagnostics &&
          other.eldCoordinates == eldCoordinates &&
          other.gpsCoordinates == gpsCoordinates &&
          other.network == network;

  @override
  int get hashCode => Object.hash(eldCoordinates, gpsCoordinates, network);

  @override
  String toString() =>
      'DeviceDiagnostics(eld: ${eldCoordinates.name}, gps: ${gpsCoordinates.name}, '
      'net: ${network.name})';
}

/// M-47 o'lchov natijasi.
///
/// **M75 [MUST]** o'lchov tashqi speedtest xizmatlari bilan emas, faqat
/// backend so'rovi bilan bajariladi. **❓M76:** `v1` da test fayli endpoint'i
/// yo'q, shuning uchun MVP da `GET /app/config` javob vaqti asosidagi
/// **taxminiy** qiymat ishlatiladi va UI da `approx.` yorlig'i turadi.
class NetworkMeasurement {
  const NetworkMeasurement({required this.mbps, required this.roundTrip, this.approximate = true});

  /// Shkala `0…100` mbps (dizayndagi yarim doira o'lchagich).
  final double mbps;

  final Duration roundTrip;

  /// `true` — M76 taxminiy o'lchovi.
  final bool approximate;

  /// O'lchagich uchun `0…1` ulush; shkala **logarifmik** (dizayn belgilari:
  /// `0 · 1 · 5 · 10 · 20 · 30 · 40 · 50 · 75 · 100`).
  double get fraction => gaugeFraction(mbps);

  @override
  String toString() => 'NetworkMeasurement(${mbps.toStringAsFixed(2)} mbps, $roundTrip)';
}

/// Dizayndagi shkala belgilari (chapdan o'ngga, `0` pastki chapda).
const List<double> kNetworkGaugeTicks = <double>[0, 1, 5, 10, 20, 30, 40, 50, 75, 100];

/// [mbps] → yoy ulushi `0…1`.
///
/// Belgilar orasidagi masofa dizaynda **teng** — shuning uchun qiymat
/// [kNetworkGaugeTicks] bo'yicha chiziqli interpolatsiya qilinadi.
double gaugeFraction(double mbps) {
  final double v = mbps.clamp(0, kNetworkGaugeTicks.last).toDouble();
  final int last = kNetworkGaugeTicks.length - 1;
  for (int i = 0; i < last; i++) {
    final double lo = kNetworkGaugeTicks[i];
    final double hi = kNetworkGaugeTicks[i + 1];
    if (v <= hi) {
      final double within = hi == lo ? 0 : (v - lo) / (hi - lo);
      return (i + within) / last;
    }
  }
  return 1;
}
