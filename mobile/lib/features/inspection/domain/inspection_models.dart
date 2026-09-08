/// Inspection domen modellari (tz-mobile §11.7, M-37…M-41).
///
/// Sof Dart: `flutter`, `dio` va Drift'dan mustaqil (M5). `data` qatlami
/// server JSON'ini yoki lokal Drift qatorlarini shu modellarga o'giradi.
library;

import 'package:hos_engine/hos_engine.dart';

/// `POST /inspection/begin` → `InspectionSession`.
///
/// `expires_at` — inspektorning o'qish oynasi; muddat tugasa kiosk rejimi
/// avtomatik yopiladi (M-38).
class InspectionSession {
  const InspectionSession({
    required this.token,
    required this.expiresAt,
    this.driverId,
    this.driverName,
  });

  /// Faqat o'qish uchun cheklangan token. **Hech qachon** UI da ko'rsatilmaydi
  /// va log'ga chiqmaydi (M152).
  final String token;

  final DateTime expiresAt;
  final String? driverId;
  final String? driverName;

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);
}

/// Log Form shapkasi (`LogForm` DTO) — kiosk ekranining tepasi.
class InspectionLogForm {
  const InspectionLogForm({
    this.driverName,
    this.coDriverName,
    this.carrierName,
    this.homeTerminalAddress,
    this.unitNumbers = const <String>[],
    this.trailerNumbers = const <String>[],
    this.shippingDocs = const <String>[],
    this.distanceMeters,
  });

  final String? driverName;
  final String? coDriverName;
  final String? carrierName;
  final String? homeTerminalAddress;
  final List<String> unitNumbers;
  final List<String> trailerNumbers;
  final List<String> shippingDocs;
  final int? distanceMeters;
}

/// Bitta duty event (kiosk jadvali qatori).
class InspectionEvent {
  const InspectionEvent({
    required this.at,
    required this.status,
    this.locationText,
    this.odometerMeters,
    this.note,
  });

  final DateTime at;

  /// `OFF` / `SB` / `DR` / `ON` — `hos_engine` enum'i (yagona manba).
  final DutyStatus status;

  final String? locationText;
  final int? odometerMeters;
  final String? note;
}

/// Sertifikatsiya holati (Q19 uch holat).
enum InspectionCertification {
  uncertified('uncertified'),
  certified('certified'),
  needsRecertify('needs_recertify');

  const InspectionCertification(this.wire);

  final String wire;

  static InspectionCertification fromWire(String? wire) =>
      InspectionCertification.values.firstWhere(
        (InspectionCertification v) => v.wire == wire,
        orElse: () => InspectionCertification.uncertified,
      );
}

/// Bitta kun (`DailyLogDetail`).
class InspectionDay {
  const InspectionDay({
    required this.date,
    required this.timezone,
    this.certification = InspectionCertification.uncertified,
    this.distanceMeters = 0,
    this.form = const InspectionLogForm(),
    this.events = const <InspectionEvent>[],
    this.signedAt,
  });

  /// Home Terminal kalendar kuni (soat/minut qismi ishlatilmaydi).
  final DateTime date;

  final String timezone;
  final InspectionCertification certification;
  final int distanceMeters;
  final InspectionLogForm form;

  /// Vaqt bo'yicha o'sish tartibida.
  final List<InspectionEvent> events;

  final DateTime? signedAt;

  /// `yyyy-MM-dd` — kunlarni solishtirish uchun kalit.
  String get key =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// `GET /inspection/logs` natijasi: 7 kun + bugun.
class InspectionReport {
  const InspectionReport({
    required this.from,
    required this.to,
    required this.days,
    this.driverId,
    this.driverName,
    this.carrierName,
    this.homeTerminalAddress,
    this.timezone,
    this.regulationProfile,
    this.generatedAt,
    this.source = InspectionSource.server,
    this.lastSyncedAt,
  });

  final DateTime from;
  final DateTime to;

  /// Eskidan yangiga tartiblangan kunlar (odatda 8 ta).
  final List<InspectionDay> days;

  final String? driverId;
  final String? driverName;
  final String? carrierName;
  final String? homeTerminalAddress;
  final String? timezone;
  final String? regulationProfile;
  final DateTime? generatedAt;

  /// Ma'lumot serverdan keldimi yoki lokal 14 kunlik buferdan.
  final InspectionSource source;

  /// Oflayn nusxa uchun — oxirgi muvaffaqiyatli sync vaqti.
  final DateTime? lastSyncedAt;

  bool get isOffline => source == InspectionSource.local;

  InspectionDay? dayFor(DateTime date) {
    final String key =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    for (final InspectionDay day in days) {
      if (day.key == key) {
        return day;
      }
    }
    return null;
  }
}

/// Ma'lumot manbai (M-38: onlayn server, oflayn — Drift 14 kunlik bufer).
enum InspectionSource { server, local }

/// `M-41` `Type` tanlovi. **Faqat UI** — `POST /inspection/transfer` tanasi
/// `swagger.json` da bu maydonni **qabul qilmaydi** (M2: kontrakt ustun),
/// shuning uchun `email` tanlansa `POST /inspection/email` chaqiriladi.
enum InspectionTransferType { webService, email }

/// `InspectionTransferResult` (`format` — regulation profiliga bog'liq).
class InspectionTransferResult {
  const InspectionTransferResult({
    required this.format,
    this.fileKey,
    this.regulationProfile,
    this.sizeBytes,
    this.generatedAt,
  });

  final InspectionOutputFormat format;
  final String? fileKey;
  final String? regulationProfile;
  final int? sizeBytes;
  final DateTime? generatedAt;
}

/// `InspectionTransferResult.format` enum'i.
enum InspectionOutputFormat {
  csvPdfZip('csv_pdf_zip'),
  fmcsaEldOutput('fmcsa_eld_output');

  const InspectionOutputFormat(this.wire);

  final String wire;

  static InspectionOutputFormat fromWire(String? wire) =>
      wire == fmcsaEldOutput.wire ? fmcsaEldOutput : csvPdfZip;
}

/// `POST /inspection/email` so'rovi (`InspectionEmail` DTO).
class InspectionEmailRequest {
  const InspectionEmailRequest({required this.email, this.date, this.driverId, this.comment});

  final String email;

  /// Oyna langari (`yyyy-MM-dd`); `null` — bugungi kun.
  final DateTime? date;

  final String? driverId;
  final String? comment;

  /// `M-40` `Send Logs` faqat email to'g'ri bo'lsa faollashadi.
  static final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]{2,}$');

  static bool isValidEmail(String value) => emailPattern.hasMatch(value.trim());
}
