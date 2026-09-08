/// Unidentified driving domen modellari (tz-mobile §11.5, M-28, M100).
library;

/// Server holati.
enum UnidentifiedStatus {
  pending('pending'),
  claimed('claimed'),
  assigned('assigned'),
  annotated('annotated');

  const UnidentifiedStatus(this.wire);

  final String wire;

  static UnidentifiedStatus fromWire(String? wire) {
    for (final UnidentifiedStatus value in UnidentifiedStatus.values) {
      if (value.wire == wire) {
        return value;
      }
    }
    return UnidentifiedStatus.pending;
  }
}

/// Bitta aniqlanmagan haydash bloki.
class UnidentifiedBlock {
  const UnidentifiedBlock({
    required this.id,
    required this.unitId,
    required this.start,
    required this.status,
    this.end,
    this.distanceM = 0,
    this.pendingSync = false,
  });

  final String id;
  final String unitId;
  final DateTime start;
  final DateTime? end;
  final int distanceM;
  final UnidentifiedStatus status;

  /// Claim outbox'da turibdi (`kind=claim`, oflayn).
  final bool pendingSync;

  Duration? get duration => end?.difference(start);

  /// Metrdan milga (`distance_m` — §5.1).
  double get distanceMiles => distanceM / 1609.344;
}

/// Claim natijasi.
enum ClaimOutcome {
  /// Outbox'ga qo'yildi (onlayn ham, oflayn ham).
  queued,

  /// `409 ALREADY_ASSIGNED` — blok boshqa haydovchiga biriktirilgan.
  alreadyAssigned,
}

/// Domen kontrakti (M5).
abstract interface class UnidentifiedRepository {
  /// `status=pending` va lokal yashirilmagan bloklar.
  Stream<List<UnidentifiedBlock>> watchClaimable();

  /// `POST /unidentified-events/{id}/claim` — outbox orqali (`kind=claim`).
  Future<ClaimOutcome> claim(String id);

  /// `Not mine` — faqat lokal (`dismissed_local=true`), serverga hech narsa
  /// yuborilmaydi (admin hal qiladi).
  Future<void> dismiss(String id);
}
