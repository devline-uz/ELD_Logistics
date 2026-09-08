/// M11 modullari (`profile`, `settings`, `support`, `feedback`, `legal`) uchun
/// yagona HTTP kirish nuqtasi.
///
/// `auth` moduli sozlangan yagona `Dio` ni (`authDioProvider`) beradi: unda
/// auth/refresh, retry, `Idempotency-Key` va logging interceptorlari bor.
/// Feature ichida `Dio()` yaratish taqiq — aks holda interceptorlar chetlab
/// o'tilgan bo'lardi. Testlarda `ProviderScope.overrides` bilan almashtiriladi.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_providers.dart';

final Provider<Dio> eldDioProvider = Provider<Dio>((Ref ref) => ref.watch(authDioProvider));
