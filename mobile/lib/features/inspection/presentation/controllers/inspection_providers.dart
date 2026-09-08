/// Inspection moduli DI simlari (M3: Riverpod, `get_it` yo'q).
///
/// `presentation` faqat domen interfeyslarini ko'radi (M5); testlar
/// repozitoriy provayderini override qiladi, `Dio` ga tegmaydi.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/session/session_profile.dart';
import '../../../../core/time/time_providers.dart';
import '../../../auth/data/auth_providers.dart';
import '../../data/inspection_api.dart';
import '../../data/inspection_pin_verifier.dart';
import '../../data/inspection_repository_impl.dart';
import '../../domain/inspection_repository.dart';

/// Auth interceptorlari ulangan `Dio` (bootstrap'da yagona klient).
final Provider<Dio> inspectionDioProvider = Provider<Dio>((Ref ref) => ref.watch(authDioProvider));

final Provider<InspectionApi> inspectionApiProvider = Provider<InspectionApi>(
  (Ref ref) => DioInspectionApi(ref.watch(inspectionDioProvider)),
);

final Provider<InspectionRepository> inspectionRepositoryProvider = Provider<InspectionRepository>(
  (Ref ref) => ApiInspectionRepository(
    api: ref.watch(inspectionApiProvider),
    logs: ref.watch(logsDaoProvider),
    events: ref.watch(dutyEventsDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    time: ref.watch(timeSourceProvider),
  ),
);

/// `M-39`: chiqish PIN'i (oflayn hash).
final Provider<InspectionPinVerifier> inspectionPinVerifierProvider =
    Provider<InspectionPinVerifier>(
      (Ref ref) => LocalInspectionPinVerifier(
        vault: ref.watch(secureVaultProvider),
        time: ref.watch(timeSourceProvider),
        // Blok holati shifrlangan lokal bazada: ilovani qayta ishga tushirish
        // urinishlar hisobini tiklamaydi (§17.3).
        store: ref.watch(kvStoreProvider),
      ),
    );
