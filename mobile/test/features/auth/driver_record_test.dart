/// `#B-BUG1` regressiyasi — Home doimo «No unit assigned» ko'rsatardi.
///
/// Sabab: `driver_id`/`unit_id`/`unit_number` `kv_settings` ga **hech qachon**
/// yozilmasdi (faqat o'qilardi). `GET /drivers` yozuvi endi login'dan keyin
/// o'qiladi va shu kalitlarga tushadi.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eld_mobile/core/db/app_database.dart';
import 'package:eld_mobile/core/db/daos/settings_dao.dart';
import 'package:eld_mobile/core/sync/outbox_repository.dart';
import 'package:eld_mobile/core/time/time_source.dart';
import 'package:eld_mobile/features/auth/data/auth_api.dart';
import 'package:eld_mobile/features/auth/domain/auth_models.dart';
import 'package:eld_mobile/features/duty_status/data/duty_status_repository_impl.dart';
import 'package:eld_mobile/features/duty_status/domain/duty_status_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/test_clock.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final Object body;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _driverRow({
  required String id,
  required String userId,
  String? unitId,
  String? unitNumber,
}) => <String, Object?>{
  'id': id,
  'user_id': userId,
  'first_name': 'Ali',
  'last_name': 'Valiyev',
  'email': 'a***i@example.com',
  'phone': '+998901234567',
  'license_no_masked': '****4321',
  'license_region': 'TX',
  'home_terminal': 'Dallas, TX',
  'default_unit_id': unitId,
  'default_unit_number': unitNumber,
};

void main() {
  group('AuthApi.driverRecord', () {
    test('`user_id` bo\'yicha to\'g\'ri qatorni tanlaydi va unitni beradi', () async {
      final _FakeAdapter adapter = _FakeAdapter(<String, Object?>{
        'data': <Object?>[
          _driverRow(id: 'drv-other', userId: 'user-other', unitNumber: 'X-1'),
          _driverRow(id: 'drv-1', userId: 'user-1', unitId: 'unit-1', unitNumber: '104'),
        ],
      });
      final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = adapter;

      final DriverRecord? record = await AuthApi(
        dio,
      ).driverRecord(userId: 'user-1', username: 'driver1');

      expect(record, isNotNull);
      expect(record!.driverId, 'drv-1');
      expect(record.unitId, 'unit-1');
      expect(record.unitNumber, '104');
      expect(record.licenseMasked, '****4321');
      expect(record.hasUnit, isTrue);
      // `search` PII ni toraytiradi, `per_page` esa 10/25/50 dan bo'lishi shart.
      expect(adapter.requests.single.queryParameters['search'], 'driver1');
      expect(adapter.requests.single.queryParameters['per_page'], 10);
    });

    test('mos `user_id` yo\'q va ro\'yxat ko\'p qatorli bo\'lsa — `null`', () async {
      final _FakeAdapter adapter = _FakeAdapter(<String, Object?>{
        'data': <Object?>[_driverRow(id: 'a', userId: 'x'), _driverRow(id: 'b', userId: 'y')],
      });
      final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = adapter;

      expect(await AuthApi(dio).driverRecord(userId: 'user-1'), isNull);
    });
  });

  group('kv_settings → DriverContext', () {
    late AppDatabase db;
    late TimeSource time;

    final DateTime t0 = DateTime.utc(2026, 9, 7, 12);

    setUp(() {
      db = AppDatabase.memory();
      time = buildTestTimeSource(t0).time;
      time.syncFromServer(t0);
    });

    tearDown(() => db.close());

    Future<DriverContext> driver() async {
      final DriftDutyStatusRepository repo = DriftDutyStatusRepository(
        events: db.dutyEventsDao,
        logs: db.logsDao,
        settings: db.settingsDao,
        outbox: OutboxRepository(db: db, time: time),
        time: time,
      );
      return (await repo.context()).driver;
    }

    test('kalitlar bo\'sh — `hasUnit` false («No unit assigned»)', () async {
      expect((await driver()).hasUnit, isFalse);
    });

    test('login yozgan kalitlardan keyin `hasUnit` true', () async {
      for (final MapEntry<String, String> entry in <String, String>{
        KvKeys.driverId: 'drv-1',
        KvKeys.driverName: 'Ali Valiyev',
        KvKeys.unitId: 'unit-1',
        KvKeys.unitNumber: '104',
        KvKeys.vehicleLabel: '104',
      }.entries) {
        await db.settingsDao.put(key: entry.key, value: entry.value, now: t0);
      }

      final DriverContext context = await driver();
      expect(context.hasUnit, isTrue);
      expect(context.unitId, 'unit-1');
      expect(context.unitNumber, '104');
      expect(context.driverId, 'drv-1');
    });
  });
}
