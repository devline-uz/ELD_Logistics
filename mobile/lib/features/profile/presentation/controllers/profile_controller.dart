/// `M-44 Profile` kontrolleri — telefon va planshet **bitta** kontrollerni
/// ulashadi (M7). Biznes qoidasi yo'q: faqat repozitoriy chaqiruvi va holat.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_terminator.dart';
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

  /// `Logout` — **idempotent va best-effort** (#B-1).
  ///
  /// Server chaqiruvi qanday tugasa ham (204, `401 TOKEN_REVOKED`, tarmoq
  /// yo'q) lokal sessiya, token vault va lokal ko'zgu **baribir** tozalanadi
  /// va qo'riqchi `/login` ga o'tkazadi. Istisno tashlamaydi — shuning uchun
  /// tugmani ikki marta bosish ham xavfsiz.
  Future<void> logout() async {
    final ProfileRepository repo = ref.read(profileRepositoryProvider);
    await ref.read(sessionTerminatorProvider).signOut(serverLogout: repo.logout);
  }
}

final AsyncNotifierProvider<ProfileController, DriverProfile> profileControllerProvider =
    AsyncNotifierProvider<ProfileController, DriverProfile>(ProfileController.new);
