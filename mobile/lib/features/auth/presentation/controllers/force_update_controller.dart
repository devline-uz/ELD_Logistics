/// `M-57 Force update` kontrolleri (§4.2 qadam 2, §11.10).
///
/// Bloklovchi ekran: `Back` yo'q, yagona amal — do'konni ochish.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_providers.dart';
import '../../domain/auth_models.dart';
import '../../domain/store_launcher.dart';

final Provider<StoreLauncher> storeLauncherProvider = Provider<StoreLauncher>(
  (Ref ref) => const SystemStoreLauncher(),
);

class ForceUpdateState {
  const ForceUpdateState({
    required this.currentVersion,
    this.requiredVersion,
    this.opening = false,
    this.storeUnavailable = false,
  });

  final String currentVersion;

  /// `app/config.latest_version` yoki `min_supported_version`.
  final String? requiredVersion;

  final bool opening;

  /// Do'kon ochilmadi — `authUpdateStoreUnavailable`.
  final bool storeUnavailable;

  ForceUpdateState copyWith({bool? opening, bool? storeUnavailable}) => ForceUpdateState(
    currentVersion: currentVersion,
    requiredVersion: requiredVersion,
    opening: opening ?? this.opening,
    storeUnavailable: storeUnavailable ?? this.storeUnavailable,
  );
}

class ForceUpdateController extends Notifier<ForceUpdateState> {
  @override
  ForceUpdateState build() {
    final AppConfig? config = ref.watch(authRepositoryProvider).cachedConfig;
    return ForceUpdateState(
      currentVersion: ref.watch(resolvedAppVersionProvider).version,
      requiredVersion: config?.latestVersion ?? config?.minSupportedVersion,
    );
  }

  Future<void> openStore() async {
    if (state.opening) {
      return;
    }
    state = state.copyWith(opening: true, storeUnavailable: false);
    final bool opened = await ref.read(storeLauncherProvider).openStore();
    state = state.copyWith(opening: false, storeUnavailable: !opened);
  }
}

final NotifierProvider<ForceUpdateController, ForceUpdateState> forceUpdateControllerProvider =
    NotifierProvider<ForceUpdateController, ForceUpdateState>(ForceUpdateController.new);
