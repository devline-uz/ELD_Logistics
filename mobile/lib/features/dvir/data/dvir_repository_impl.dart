/// DVIR domen kontraktlarining `data` implementatsiyasi (M5).
///
/// Onlayn — `/dvir-reports`, `/defect-types`, `/trailers`; oflayn — Drift
/// keshi va outbox (`OutboxKind.dvir` / `OutboxKind.certify`).
library;

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:sync_core/sync_core.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/daos/duty_events_dao.dart';
import '../../../core/db/daos/dvir_dao.dart';
import '../../../core/db/daos/ref_dao.dart';
import '../../../core/db/daos/settings_dao.dart';
import '../../../core/error/api_error.dart';
import '../../../core/sync/outbox_repository.dart';
import '../../../core/time/time_source.dart';
import '../domain/defect_catalog.dart';
import '../domain/dvir_models.dart';
import '../domain/dvir_repository.dart';
import 'dvir_api.dart';
import 'dvir_json.dart';

/// Katalog keshi kaliti (`kv_settings`). `ref_defect_types` jadvalida
/// `is_critical`/`sort_order` ustunlari yo'q, shuning uchun M106 uchun muhim
/// bo'lgan to'liq katalog JSON sifatida KV da saqlanadi.
const String kDefectCatalogCacheKey = 'dvir.defect_types.v1';

/// `GET /dvir-reports/pending-certification` keshi (M-36 oflayn ko'rsatiladi).
const String kPendingCertificationCacheKey = 'dvir.pending_certification.v1';

/// M105: katalog serverdan, oflayn — kesh, u ham bo'lmasa dizayn fallback'i.
class ApiDefectCatalogRepository implements DefectCatalogRepository {
  ApiDefectCatalogRepository({required this._api, required this._settings, required this._time});

  final DvirApi _api;
  final SettingsDao _settings;
  final TimeSource _time;

  List<DefectType>? _memo;

  @override
  Future<List<DefectType>> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _memo != null) {
      return _memo!;
    }
    try {
      final List<DefectType> fresh = await _api.defectTypes();
      if (fresh.isNotEmpty) {
        await _settings.put(
          key: kDefectCatalogCacheKey,
          value: jsonEncode(<Map<String, Object?>>[
            for (final DefectType t in fresh) defectTypeToCache(t),
          ]),
          now: _time.now(),
        );
        return _memo = fresh;
      }
    } on ApiError {
      // Oflayn yoki server xatosi — keshga tushamiz.
    }

    final List<DefectType> cached = defectTypesFromCache(
      await _settings.get(kDefectCatalogCacheKey),
    );
    if (cached.isNotEmpty) {
      return _memo = cached;
    }
    return _memo = buildFallbackCatalog();
  }
}

/// Trailer raqamlari: `GET /trailers`, oflayn — `ref_trailers` keshi.
class ApiTrailerRepository implements TrailerRepository {
  ApiTrailerRepository({required this._api, required this._ref});

  final DvirApi _api;
  final RefDao _ref;

  @override
  Future<List<TrailerRef>> search(String query) async {
    try {
      return await _api.trailers(query);
    } on ApiError {
      final List<RefTrailerRow> rows = await _ref.watchTrailers().first;
      final String q = query.trim().toLowerCase();
      return <TrailerRef>[
        for (final RefTrailerRow row in rows)
          if (q.isEmpty || row.number.toLowerCase().contains(q))
            TrailerRef(id: row.id, number: row.number),
      ];
    }
  }
}

/// `/dvir-reports` — yaratish, o'qish, sertifikatsiya.
class ApiDvirRepository implements DvirRepository {
  ApiDvirRepository({
    required this._api,
    required this._dao,
    required this._events,
    required this._settings,
    required this._outbox,
    required this._time,
  });

  final DvirApi _api;
  final DvirDao _dao;
  final DutyEventsDao _events;
  final SettingsDao _settings;
  final OutboxRepository _outbox;
  final TimeSource _time;

  /// Kontekst lokal duty-event'lardan olinadi: ular ELD/GPS dan to'ladi va
  /// oflayn ham mavjud (tarmoqqa bog'liq emas).
  @override
  Future<DvirContext> currentContext() async {
    final List<DutyEventRow> recent = await _events.watchRecent(limit: 1).first;
    final DutyEventRow? last = recent.isEmpty ? null : recent.first;
    return DvirContext(
      unitId: last?.unitId ?? '',
      unitNumber: null,
      locationText: last?.locationText,
      odometerMeters: last?.odometerM,
      capturedAt: _time.now(),
    );
  }

  @override
  Future<DvirSubmitResult> submit(DvirDraft draft) async {
    final Map<String, Object?> body = dvirCreateBody(draft);
    try {
      final DvirReport report = await _api.create(body, idempotencyKey: draft.clientId);
      await _cacheReport(report);
      await _dao.setDraftState(clientId: draft.clientId, state: 'sent', now: _time.now());
      return DvirSubmitResult(queued: false, report: report);
    } on ApiError catch (error) {
      if (!error.isOffline && !error.isRetryable) {
        rethrow;
      }
      await _outbox.enqueue(
        kind: OutboxKind.dvir,
        clientId: draft.clientId,
        payload: body,
        writeBusinessRow: (String clientId, int _) => _dao.upsertDraft(_draftRow(draft, clientId)),
      );
      return const DvirSubmitResult(queued: true);
    }
  }

  @override
  Future<DvirReport?> byId(String id) async {
    try {
      final DvirReport? report = await _api.byId(id);
      if (report != null) {
        await _cacheReport(report);
      }
      return report;
    } on ApiError catch (error) {
      if (!error.isOffline && !error.isRetryable) {
        rethrow;
      }
      return _localReport(id);
    }
  }

  @override
  Future<List<DvirReport>> pendingCertification({String? unitId}) async {
    try {
      final List<DvirReport> list = await _api.pendingCertification(unitId: unitId);
      await _settings.put(
        key: kPendingCertificationCacheKey,
        value: jsonEncode(<Map<String, Object?>>[
          for (final DvirReport r in list) dvirReportToCache(r),
        ]),
        now: _time.now(),
      );
      return list;
    } on ApiError catch (error) {
      if (!error.isOffline && !error.isRetryable) {
        rethrow;
      }
      final List<DvirReport> cached = dvirReportsFromCache(
        await _settings.get(kPendingCertificationCacheKey),
      );
      return unitId == null
          ? cached
          : <DvirReport>[
              for (final DvirReport r in cached)
                if (r.unitId == unitId) r,
            ];
    }
  }

  @override
  Future<DvirSubmitResult> certify({required String reportId, required String signatureKey}) async {
    try {
      final DvirReport report = await _api.certify(
        id: reportId,
        signatureKey: signatureKey,
        idempotencyKey: 'certify:$reportId',
      );
      await _cacheReport(report);
      return DvirSubmitResult(queued: false, report: report);
    } on ApiError catch (error) {
      if (!error.isOffline && !error.isRetryable) {
        rethrow;
      }
      await _outbox.enqueue(
        kind: OutboxKind.certify,
        clientId: 'dvir-certify:$reportId',
        payload: <String, Object?>{
          'target': 'dvir_report',
          'dvir_report_id': reportId,
          'signature_key': signatureKey,
        },
      );
      return const DvirSubmitResult(queued: true);
    }
  }

  @override
  Future<String> downloadPdf(String id) async {
    final List<int> bytes = await _api.pdf(id);
    return _pdfSink(id, bytes);
  }

  /// PDF ni diskka yozish — platformaga bog'liq, `PdfSink` orqali almashtiriladi.
  Future<String> Function(String id, List<int> bytes) _pdfSink = _unsupportedPdfSink;

  /// Bootstrap (yoki test) PDF yozuvchisini ulaydi.
  // ignore: use_setters_to_change_properties
  void bindPdfSink(Future<String> Function(String id, List<int> bytes) sink) => _pdfSink = sink;

  static Future<String> _unsupportedPdfSink(String id, List<int> bytes) async =>
      throw const ApiError(code: 'FEATURE_DISABLED', message: 'pdf sink is not bound');

  DvirDraftsCompanion _draftRow(DvirDraft draft, String clientId) {
    final DateTime now = _time.now();
    return DvirDraftsCompanion.insert(
      clientId: clientId,
      unitId: draft.unitId,
      type: draft.type.wire,
      defects: Value<Map<String, dynamic>>(<String, dynamic>{
        'defects': dvirCreateBody(draft)['defects'],
      }),
      trailerIds: Value<List<String>>(draft.trailerIds),
      notes: Value<String?>(draft.notes),
      driverSignatureKey: Value<String?>(draft.signatureKey),
      localPhotoPaths: Value<List<String>>(<String>[
        for (final DvirDefect d in draft.allDefects) ...d.photoPaths,
        ...draft.accidentPhotoPaths,
        if (draft.signaturePath != null) draft.signaturePath!,
      ]),
      state: const Value<String>('queued'),
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _cacheReport(DvirReport report) => _dao.upsertReport(
    DvirReportsCompanion.insert(
      id: report.id,
      status: report.status.wire,
      kind: report.kind?.wire ?? '',
      type: report.type.wire,
      unitId: report.unitId,
      createdAt: report.createdAt,
      hasCriticalDefect: Value<bool>(report.hasCriticalDefect),
      outOfService: Value<bool>(report.outOfService),
      payload: Value<Map<String, dynamic>>(dvirReportToCache(report)),
    ),
  );

  Future<DvirReport?> _localReport(String id) async {
    final List<DvirReportRow> rows = await _dao.watchReports(limit: 200).first;
    for (final DvirReportRow row in rows) {
      if (row.id == id) {
        return dvirReportFromJson(Map<String, dynamic>.from(row.payload));
      }
    }
    return null;
  }
}
