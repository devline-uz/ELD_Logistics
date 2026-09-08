/// `EldTransport` — ELD qurilmasi bilan aloqaning **yagona** abstraksiyasi
/// (tz-mobile §10.7, M79/M80, risk R2).
///
/// **Qat'iy:** UI, servis va domen qatlami hech qachon `flutter_blue_plus` yoki
/// vendor SDK tipini ko'rmaydi. Implementatsiyalar:
/// * [MockEldTransport] — birinchi yozilgan, barcha ekranlar u bilan ishlaydi;
/// * `BleEldTransport` (`flutter_blue_plus`);
/// * `VendorEldTransport` (`MethodChannel('eld/device')`) — model tanlangach.
library;

import 'eld_codes.dart';
import 'eld_models.dart';

/// ELD qurilmasi bilan aloqa shartnomasi.
abstract class EldTransport {
  /// Ulanish holati oqimi (banner shu yerdan chiziladi).
  Stream<EldConnectionState> get state;

  /// Oxirgi holat (oqimga obuna bo'lmasdan o'qish uchun).
  EldConnectionState get currentState;

  /// Telemetriya kadrlari: tezlik, koordinata, odometr, motor soati.
  Stream<EldTelemetryFrame> get telemetry;

  /// `P/E/T/L/R/S/O` kodlari (§10.6).
  Stream<EldFault> get diagnostics;

  /// Skan (§10.3): filtr — xizmat UUID + nom prefiksi, timeout 20 s.
  ///
  /// Oqim har yangi natijada **to'liq** ro'yxatni beradi va timeout tugagach
  /// yopiladi.
  Stream<List<EldDeviceRef>> scan({Duration timeout = kEldScanTimeout});

  /// Ulanadi va handshake qaytaradi.
  ///
  /// [macOrId] `null` bo'lsa transport oxirgi ma'lum qurilmaga ulanadi;
  /// u ham bo'lmasa [EldTransportFailure.notFound] tashlanadi.
  Future<EldHandshake> connect({String? macOrId});

  /// **M72:** qurilma oflayn yozgan eventlarni o'qiydi.
  ///
  /// Takroriy chaqiruv **ayni o'sha** eventlarni qaytarishi mumkin — dublikat
  /// bo'lmasligi `eldClientEventId` deterministikligi bilan ta'minlanadi.
  Future<List<EldBufferedEvent>> readBuffer();

  /// Outbox'ga muvaffaqiyatli yozilgan eventlarni qurilma buferidan tozalaydi.
  ///
  /// Vendor qo'llab-quvvatlamasa — hech narsa qilmaydi (dedup baribir ishlaydi).
  Future<void> acknowledgeBuffer(List<EldBufferedEvent> events);

  Future<void> disconnect();

  /// Oqimlarni yopadi. Provayder `ref.onDispose` da chaqiradi.
  Future<void> dispose();
}

/// Skan timeout'i (tz-mobile §10.3).
const Duration kEldScanTimeout = Duration(seconds: 20);

/// Ulanish timeout'i (skill §2).
const Duration kEldConnectTimeout = Duration(seconds: 20);

/// Uzilish → `Disconnected` banneri (§10.3).
const Duration kEldDisconnectGrace = Duration(seconds: 30);

/// Qayta ulanish qadamlari: `2 s → 5 s → 15 s → 60 s`, keyin 60 s da qoladi.
const List<Duration> kEldReconnectSteps = <Duration>[
  Duration(seconds: 2),
  Duration(seconds: 5),
  Duration(seconds: 15),
  Duration(seconds: 60),
];

/// Cheksiz qayta ulanish hisoblagichi (jitter yo'q — TZ aniq qiymat beradi).
class EldReconnectBackoff {
  EldReconnectBackoff({this.steps = kEldReconnectSteps});

  final List<Duration> steps;
  int _attempt = 0;

  int get attempt => _attempt;

  /// Navbatdagi kutish; oxirgi qadamdan keyin **maksimumda qoladi**.
  Duration next() {
    final Duration delay = _attempt >= steps.length ? steps.last : steps[_attempt];
    if (_attempt < steps.length) {
      _attempt++;
    }
    return delay;
  }

  void reset() => _attempt = 0;
}
