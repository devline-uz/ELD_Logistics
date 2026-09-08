/// Duty status domen interfeyslari (M5: `presentation` faqat shularni ko'radi).
library;

import 'package:hos_engine/hos_engine.dart';
import 'package:sync_core/sync_core.dart';

import 'duty_status_models.dart';

/// Duty eventlar ustidagi yagona kirish nuqtasi.
abstract class DutyStatusRepository {
  /// Joriy status, policy va haydovchi konteksti (Drift'dan, oflayn ishlaydi).
  Stream<DutyStatusContext> watchContext();

  /// Bir martalik o'qish (kontroller ishga tushganda).
  Future<DutyStatusContext> context();

  /// HOS hisoblash uchun oxirgi eventlar (sikl oynasini qoplaydi).
  Future<List<HosEvent>> hosEvents({required DateTime now});

  /// Kun oralig'idagi eventlar (log grid, M-09).
  Future<List<HosEvent>> dayEvents({required DateTime dayStartUtc, required DateTime dayEndUtc});

  /// **M24:** duty event + outbox yozuvi bitta tranzaksiyada.
  Future<DutyChangeResult> changeStatus({
    required DutyStatusDraft draft,
    required EventOrigin origin,
    DateTime? at,
    double? speedKmh,
    int? odometerM,
    double? engineHours,
  });

  /// **M53:** statusni o'zgartirmasdan trailer/hujjat/izohni yangilash.
  Future<DutyChangeResult> updateDocuments({
    required List<String> trailerIds,
    required List<String> shippingDocIds,
    String? notes,
  });

  /// **M63:** haydash rejimida har 60 daqiqada `intermediate` eventi.
  Future<DutyChangeResult> recordIntermediate({
    double? lat,
    double? lng,
    int? odometerM,
    double? engineHours,
    double? speedKmh,
  });
}

/// Kataloglar (`sync/pull` keshi) — quick notes, trailerlar, hujjatlar.
abstract class DutyCatalogRepository {
  /// **M55:** server ro'yxati ustun; birinchi pull'gacha fallback ishlatiladi.
  Stream<List<QuickNoteOption>> watchQuickNotes();

  Stream<List<TrailerOption>> watchTrailers();

  /// Oxirgi ishlatilgan shipping document raqamlari (lokal kesh).
  Future<List<String>> recentShippingDocs();

  /// Qo'lda kiritilgan hujjat raqamini keshga qo'shadi.
  Future<void> rememberShippingDoc(String number);
}
