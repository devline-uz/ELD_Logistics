/// DVIR moduli DI simlari (M3: Riverpod, `get_it` yo'q).
///
/// `presentation` faqat **domen interfeyslarini** ko'radi (M5); shu fayl
/// `data` implementatsiyasini ularga bog'laydi. Testlar repozitoriy
/// provayderlarini override qiladi, `Dio` ga tegmaydi.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/time/time_providers.dart';
import '../../data/dvir_api.dart';
import '../../data/dvir_file_repository.dart';
import '../../data/dvir_repository_impl.dart';
import '../../domain/dvir_repository.dart';

/// Ilova `Dio` klienti. `main.dart` bootstrap'ida override qilinadi.
///
/// TODO(core): `core/network` da umumiy `dioProvider` paydo bo'lgach shunga
/// ko'chiriladi (hozir `core/` boshqa agent qo'lida).
final Provider<Dio> dvirDioProvider = Provider<Dio>(
  (Ref ref) => throw UnimplementedError('dvirDioProvider bootstrap da override qilinadi'),
);

final Provider<DvirApi> dvirApiProvider = Provider<DvirApi>(
  (Ref ref) => DioDvirApi(ref.watch(dvirDioProvider)),
);

/// M105: nuqson katalogi (server → kesh → fallback).
final Provider<DefectCatalogRepository> defectCatalogRepositoryProvider =
    Provider<DefectCatalogRepository>(
      (Ref ref) => ApiDefectCatalogRepository(
        api: ref.watch(dvirApiProvider),
        settings: ref.watch(settingsDaoProvider),
        time: ref.watch(timeSourceProvider),
      ),
    );

final Provider<TrailerRepository> trailerRepositoryProvider = Provider<TrailerRepository>(
  (Ref ref) =>
      ApiTrailerRepository(api: ref.watch(dvirApiProvider), ref: ref.watch(refDaoProvider)),
);

final Provider<DvirRepository> dvirRepositoryProvider = Provider<DvirRepository>(
  (Ref ref) => ApiDvirRepository(
    api: ref.watch(dvirApiProvider),
    dao: ref.watch(dvirDaoProvider),
    events: ref.watch(dutyEventsDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    outbox: ref.watch(outboxRepositoryProvider),
    time: ref.watch(timeSourceProvider),
  ),
);

final Provider<DvirFileRepository> dvirFileRepositoryProvider = Provider<DvirFileRepository>(
  (Ref ref) =>
      DriftDvirFileRepository(dao: ref.watch(dvirDaoProvider), time: ref.watch(timeSourceProvider)),
);
