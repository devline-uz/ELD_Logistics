/// `M-01 Splash` kontrolleri — bootstrap (§4.2).
///
/// Telefon va planshet **bitta** kontrollerni ulashadi (M7).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_providers.dart';
import '../../domain/auth_repository.dart';

/// §19: splash 3 s dan uzoq ko'rinsa progress ko'rsatiladi.
const Duration kSplashProgressThreshold = Duration(seconds: 3);

class SplashController extends AsyncNotifier<BootstrapResult> {
  @override
  Future<BootstrapResult> build() => ref.watch(authRepositoryProvider).bootstrap();

  /// `ErrorState` dagi `Retry`.
  void retry() {
    state = const AsyncValue<BootstrapResult>.loading();
    ref.invalidateSelf();
  }
}

final AsyncNotifierProvider<SplashController, BootstrapResult> splashControllerProvider =
    AsyncNotifierProvider<SplashController, BootstrapResult>(SplashController.new);
