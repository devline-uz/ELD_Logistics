/// `M-44 Profile` kontrolleri — telefon va planshet **bitta** kontrollerni
/// ulashadi (M7). Biznes qoidasi yo'q: faqat repozitoriy chaqiruvi va holat.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile_repository_impl.dart';
import '../../domain/driver_profile.dart';
import '../../domain/profile_repository.dart';

class ProfileController extends AsyncNotifier<DriverProfile> {
  @override
  Future<DriverProfile> build() => ref.watch(profileRepositoryProvider).load();

  /// Pull-to-refresh va `ErrorState.Retry`.
  Future<void> refresh() async {
    state = const AsyncValue<DriverProfile>.loading();
    state = await AsyncValue.guard<DriverProfile>(() => ref.read(profileRepositoryProvider).load());
  }

  /// `Logout` — sessiyani yopadi. Xatoni chaqiruvchi ushlaydi
  /// (`ApiError` → `localizedApiError`).
  Future<void> logout() async {
    final ProfileRepository repo = ref.read(profileRepositoryProvider);
    await repo.logout();
  }
}

final AsyncNotifierProvider<ProfileController, DriverProfile> profileControllerProvider =
    AsyncNotifierProvider<ProfileController, DriverProfile>(ProfileController.new);
