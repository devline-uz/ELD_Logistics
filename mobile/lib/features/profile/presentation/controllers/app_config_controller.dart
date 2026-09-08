/// `GET /app/config` kontrolleri — `M-45 App updates`, `M-52/M-53` placeholder
/// (`support_email`) va `M-44 User Manual` havolasi shu yerdan oziqlanadi.
///
/// Telefon va planshet **bitta** kontrollerni ulashadi (M7).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile_repository_impl.dart';
import '../../domain/app_config_info.dart';

class AppConfigController extends AsyncNotifier<AppConfigInfo> {
  @override
  Future<AppConfigInfo> build() => ref.watch(appConfigRepositoryProvider).load();

  Future<void> refresh() async {
    state = const AsyncValue<AppConfigInfo>.loading();
    state = await AsyncValue.guard<AppConfigInfo>(
      () => ref.read(appConfigRepositoryProvider).load(),
    );
  }
}

final AsyncNotifierProvider<AppConfigController, AppConfigInfo> appConfigControllerProvider =
    AsyncNotifierProvider<AppConfigController, AppConfigInfo>(AppConfigController.new);
