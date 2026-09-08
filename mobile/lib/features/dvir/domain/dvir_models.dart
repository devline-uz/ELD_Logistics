/// DVIR domen modellari (tz-mobile §11.6, M102–M107).
///
/// Bu qatlam `eld_api` / Drift / Flutter dan **mustaqil** — sof Dart. Data
/// qatlami server JSON'ini shu modellarga o'giradi (M5).
library;

/// Tekshiruv turi — `DvirReport.type` (`swagger.json`).
enum DvirType {
  preTrip('pre_trip'),
  postTrip('post_trip');

  const DvirType(this.wire);

  final String wire;

  static DvirType fromWire(String? wire) =>
      wire == postTrip.wire ? DvirType.postTrip : DvirType.preTrip;
}

/// Nuqson kategoriyasi — `DefectType.category`.
enum DefectCategory {
  truck('truck'),
  trailer('trailer');

  const DefectCategory(this.wire);

  final String wire;

  static DefectCategory fromWire(String? wire) =>
      wire == trailer.wire ? DefectCategory.trailer : DefectCategory.truck;
}

/// Backend holati — `DvirReport.status`. UI da faqat `M-35` da ko'rsatiladi (M103).
enum DvirStatus {
  draft('draft'),
  submittedNoDefects('submitted_no_defects'),
  submittedDefectsFound('submitted_defects_found'),
  repaired('repaired'),
  certified('certified'),
  closedNoCertification('closed_no_certification');

  const DvirStatus(this.wire);

  final String wire;

  static DvirStatus fromWire(String? wire) => DvirStatus.values.firstWhere(
    (DvirStatus s) => s.wire == wire,
    orElse: () => DvirStatus.draft,
  );
}

/// Serverdan keladigan hosila maydon — badge **faqat shundan** olinadi (M103).
enum DvirKind {
  noDefects('no_defects'),
  defectsNotFixed('defects_not_fixed'),
  defectsFixed('defects_fixed'),
  defectsUncertified('defects_uncertified');

  const DvirKind(this.wire);

  final String wire;

  static DvirKind? fromWire(String? wire) {
    for (final DvirKind k in DvirKind.values) {
      if (k.wire == wire) {
        return k;
      }
    }
    return null;
  }
}

/// Serverdagi nuqson katalogi bandi (`GET /defect-types`, M105).
class DefectType {
  const DefectType({
    required this.id,
    required this.name,
    required this.category,
    this.isCritical = false,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final DefectCategory category;

  /// `true` bo'lsa tanlashda M106 ogohlantirishi ko'rsatiladi.
  final bool isCritical;

  final int sortOrder;

  @override
  bool operator ==(Object other) => other is DefectType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Tanlangan nuqson: katalog bandi + izoh + fotolar (`DefectInput`).
class DvirDefect {
  const DvirDefect({
    required this.type,
    this.note,
    this.photoPaths = const <String>[],
    this.photoKeys = const <String>[],
  });

  final DefectType type;

  /// Ixtiyoriy izoh (`DefectInput.note`).
  final String? note;

  /// Lokal fayl yo'llari (`files_queue` ga navbatga qo'yilgan, §16 M149).
  final List<String> photoPaths;

  /// Yuklangandan keyin object storage kalitlari (`DefectInput.photo_keys`).
  final List<String> photoKeys;

  /// `tz.md` Q27.1 — har nuqsonga ≤5 foto.
  static const int maxPhotos = 5;

  bool get canAddPhoto => photoPaths.length + photoKeys.length < maxPhotos;

  int get photoCount => photoPaths.length + photoKeys.length;

  DvirDefect copyWith({String? note, List<String>? photoPaths, List<String>? photoKeys}) =>
      DvirDefect(
        type: type,
        note: note ?? this.note,
        photoPaths: photoPaths ?? this.photoPaths,
        photoKeys: photoKeys ?? this.photoKeys,
      );
}

/// Haydovchi tomonidan to'ldirilayotgan DVIR (lokal qoralama).
class DvirDraft {
  const DvirDraft({
    required this.clientId,
    required this.unitId,
    required this.type,
    this.unitNumber,
    this.trailerIds = const <String>[],
    this.truckDefects = const <DvirDefect>[],
    this.trailerDefects = const <DvirDefect>[],
    this.notes,
    this.signatureKey,
    this.signaturePath,
    this.accidentPhotoPaths = const <String>[],
  });

  final String clientId;
  final String unitId;
  final String? unitNumber;
  final DvirType type;
  final List<String> trailerIds;
  final List<DvirDefect> truckDefects;
  final List<DvirDefect> trailerDefects;
  final String? notes;

  /// Yuklangan imzo kaliti (`DvirCreate.driver_signature_key`).
  final String? signatureKey;

  /// Imzo hali yuklanmagan bo'lsa — lokal PNG yo'li (`files_queue`).
  final String? signaturePath;

  /// M105: `Accident Photo` nuqson emas — alohida foto bandi.
  final List<String> accidentPhotoPaths;

  List<DvirDefect> get allDefects => <DvirDefect>[...truckDefects, ...trailerDefects];

  bool get hasDefects => allDefects.isNotEmpty;

  /// M106: tanlanganlar orasida kritik nuqson bormi.
  bool get hasCriticalDefect => allDefects.any((DvirDefect d) => d.type.isCritical);

  /// M-34 `Confirm` faqat imzo bo'lsa faollashadi.
  bool get isSignable => signatureKey != null || signaturePath != null;

  DvirDraft copyWith({
    String? unitId,
    String? unitNumber,
    DvirType? type,
    List<String>? trailerIds,
    List<DvirDefect>? truckDefects,
    List<DvirDefect>? trailerDefects,
    String? notes,
    String? signatureKey,
    String? signaturePath,
    List<String>? accidentPhotoPaths,
  }) => DvirDraft(
    clientId: clientId,
    unitId: unitId ?? this.unitId,
    unitNumber: unitNumber ?? this.unitNumber,
    type: type ?? this.type,
    trailerIds: trailerIds ?? this.trailerIds,
    truckDefects: truckDefects ?? this.truckDefects,
    trailerDefects: trailerDefects ?? this.trailerDefects,
    notes: notes ?? this.notes,
    signatureKey: signatureKey ?? this.signatureKey,
    signaturePath: signaturePath ?? this.signaturePath,
    accidentPhotoPaths: accidentPhotoPaths ?? this.accidentPhotoPaths,
  );
}

/// Haydovchining joriy konteksti — `M-32` `Driver Information` bloki.
class DvirContext {
  const DvirContext({
    required this.unitId,
    this.unitNumber,
    this.locationText,
    this.odometerMeters,
    this.capturedAt,
  });

  final String unitId;
  final String? unitNumber;
  final String? locationText;
  final int? odometerMeters;
  final DateTime? capturedAt;
}

/// Serverdagi DVIR hisoboti (`GET /dvir-reports/{id}`).
class DvirReport {
  const DvirReport({
    required this.id,
    required this.status,
    required this.type,
    required this.unitId,
    required this.createdAt,
    this.kind,
    this.unitNumber,
    this.locationText,
    this.odometerMeters,
    this.trailerIds = const <String>[],
    this.defects = const <DvirReportDefect>[],
    this.notes,
    this.driverSignatureKey,
    this.mechanicSignatureKey,
    this.mechanicNote,
    this.invoiceKey,
    this.hasCriticalDefect = false,
    this.outOfService = false,
    this.repairedAt,
    this.certifiedAt,
    this.isLocalDraft = false,
  });

  final String id;
  final DvirStatus status;

  /// `null` — lokal qoralama (server hali `kind` bermagan).
  final DvirKind? kind;

  final DvirType type;
  final String unitId;
  final String? unitNumber;
  final DateTime createdAt;
  final String? locationText;
  final int? odometerMeters;
  final List<String> trailerIds;
  final List<DvirReportDefect> defects;
  final String? notes;
  final String? driverSignatureKey;
  final String? mechanicSignatureKey;
  final String? mechanicNote;
  final String? invoiceKey;
  final bool hasCriticalDefect;
  final bool outOfService;
  final DateTime? repairedAt;
  final DateTime? certifiedAt;

  /// Lokal (hali yuborilmagan) qoralama — `Draft` badge (M102).
  final bool isLocalDraft;

  List<DvirReportDefect> get truckDefects =>
      defects.where((DvirReportDefect d) => d.category == DefectCategory.truck).toList();

  List<DvirReportDefect> get trailerDefects =>
      defects.where((DvirReportDefect d) => d.category == DefectCategory.trailer).toList();
}

/// Hisobotdagi nuqson (`Defect` DTO).
class DvirReportDefect {
  const DvirReportDefect({
    required this.name,
    required this.category,
    this.defectTypeId,
    this.note,
    this.photoKeys = const <String>[],
    this.isCritical = false,
  });

  final String name;
  final DefectCategory category;
  final String? defectTypeId;
  final String? note;
  final List<String> photoKeys;
  final bool isCritical;
}
