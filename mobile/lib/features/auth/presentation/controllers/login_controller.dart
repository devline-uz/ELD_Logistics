/// `M-02 Login` va `M-03 Leave truck` kontrolleri (tz-mobile §4.3, §4.6).
///
/// Telefon va planshet **bitta** shu kontrollerni ulashadi (M7). Biznes
/// qoidalari bu yerda emas — `domain/auth_policies.dart` da (`LoginFormPolicy`).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_error.dart';
import '../../../../core/error/api_error_code.dart';
import '../../../../core/router/auth_state.dart';
import '../../../../core/security/secure_vault.dart';
import '../../data/auth_providers.dart';
import '../../data/session_manager.dart';
import '../../domain/auth_models.dart';
import '../../domain/auth_policies.dart';
import '../../domain/auth_repository.dart';
import '../../domain/session_state.dart';
import 'form_status.dart';

/// Ekranning ikki ko'rinishi: oddiy kirish va pauzadan qaytish.
enum LoginMode {
  /// `M-02` — `/login`.
  signIn,

  /// `M-03` — `/paused`; qo'shimcha `Return to truck` tugmasi bor.
  leaveTruck,
}

/// M-02/M-03 ning to'liq ko'rinish holati.
class LoginState {
  const LoginState({
    this.username = '',
    this.password = '',
    this.obscurePassword = true,
    this.showFieldErrors = false,
    this.status = const FormStatus(),
    this.offline = false,
    this.replacedSession = false,
    this.requiresTotpSetup = false,
  });

  final String username;
  final String password;
  final bool obscurePassword;

  /// Maydon xatolari faqat birinchi yuborishdan keyin ko'rsatiladi.
  final bool showFieldErrors;

  final FormStatus status;

  /// M14: oxirgi urinish tarmoq xatosi bilan tugadi — banner va o'chirilgan
  /// tugma. `connectivity_plus` yo'q, shuning uchun signal xatodan olinadi.
  final bool offline;

  /// §4.6 `replaced_session` — muvaffaqiyatli kirishdan keyingi banner.
  final bool replacedSession;

  /// `true` — `M-08` ga majburiy o'tish.
  final bool requiresTotpSetup;

  /// M-02 «bo'sh» holati: tugma o'chirilgan.
  bool get canSubmit =>
      !offline &&
      !status.isSubmitting &&
      LoginFormPolicy.canSubmit(username: username, password: password);

  LoginFieldIssue? get usernameIssue =>
      showFieldErrors ? LoginFormPolicy.validateUsername(username) : null;

  LoginFieldIssue? get passwordIssue =>
      showFieldErrors ? LoginFormPolicy.validatePassword(password) : null;

  LoginState copyWith({
    String? username,
    String? password,
    bool? obscurePassword,
    bool? showFieldErrors,
    FormStatus? status,
    bool? offline,
    bool? replacedSession,
    bool? requiresTotpSetup,
  }) => LoginState(
    username: username ?? this.username,
    password: password ?? this.password,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    showFieldErrors: showFieldErrors ?? this.showFieldErrors,
    status: status ?? this.status,
    offline: offline ?? this.offline,
    replacedSession: replacedSession ?? this.replacedSession,
    requiresTotpSetup: requiresTotpSetup ?? this.requiresTotpSetup,
  );
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setUsername(String value) =>
      state = state.copyWith(username: value, status: const FormStatus(), offline: false);

  void setPassword(String value) =>
      state = state.copyWith(password: value, status: const FormStatus(), offline: false);

  void toggleObscure() => state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// `Login` tugmasi. Muvaffaqiyatda `authStatusProvider` yangilanadi va
  /// [LoginState.status] `success` bo'ladi — navigatsiyani ekran bajaradi.
  Future<void> submit() async {
    if (!LoginFormPolicy.canSubmit(username: state.username, password: state.password)) {
      state = state.copyWith(showFieldErrors: true);
      return;
    }
    state = state.copyWith(
      showFieldErrors: true,
      status: const FormStatus.submitting(),
      offline: false,
    );
    final DriverSlot slot = targetSlot;
    try {
      final LoginOutcome outcome = await _repositoryFor(slot).login(
        username: LoginFormPolicy.normalizeUsername(state.username),
        password: state.password,
      );
      state = state.copyWith(
        password: '',
        status: const FormStatus.success(),
        replacedSession: outcome.replacedSession,
        requiresTotpSetup: outcome.requiresTotpSetup,
      );
      // **M9:** haydovchi o'z slotiga yoziladi; ikkinchi login co-driver
      // slotiga tushadi va birinchi sessiyani **almashtirmaydi**.
      await ref
          .read(sessionManagerProvider.notifier)
          .signIn(
            slot: slot,
            driverId: outcome.profile?.id ?? '',
            driverName: outcome.profile?.fullName ?? '',
            sessionId: outcome.sessionId,
          );
      if (!outcome.requiresTotpSetup) {
        ref.read(authStatusProvider.notifier).set(AuthStatus.authenticated);
      }
    } on ApiError catch (error) {
      state = state.copyWith(status: FormStatus.failure(error), offline: _isOffline(error.code));
    }
  }

  /// Login qaysi slotga tushadi (**M9**): birinchi bo'sh slot, ikkalasi ham
  /// band bo'lsa — faol slot qayta kiradi.
  DriverSlot get targetSlot {
    final DualSessionState session = ref.read(sessionManagerProvider);
    if (session.primary.isEmpty) {
      return DriverSlot.primary;
    }
    if (session.coDriver.isEmpty) {
      return DriverSlot.coDriver;
    }
    return session.activeSlot;
  }

  /// Asosiy slotda `authRepositoryProvider` qaytariladi — testlar shu
  /// provayderni override qiladi va oqim o'zgarmasligi kerak.
  AuthRepository _repositoryFor(DriverSlot slot) => slot == DriverSlot.primary
      ? ref.read(authRepositoryProvider)
      : ref.read(slotAuthRepositoryProvider(slot));

  static bool _isOffline(String code) =>
      code == ApiErrorCode.clientNetwork ||
      code == ApiErrorCode.clientTimeout ||
      code == ApiErrorCode.serviceUnavailable;
}

final NotifierProvider<LoginController, LoginState> loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);

/// `M-03` sarlavhasi uchun pauza qilingan haydovchi ismi (oflayn ham ishlaydi).
///
/// Manba ustuvorligi: ikki sessiya menejeri (u `SecureVault` dan tiklanadi va
/// ilova qayta ishga tushganda ham to'g'ri ismni biladi) → profil keshi.
final Provider<String?> pausedDriverNameProvider = Provider<String?>((Ref ref) {
  final DualSessionState session = ref.watch(sessionManagerProvider);
  final String name = session.active.driverName;
  if (name.isNotEmpty) {
    return name;
  }
  return ref.watch(authRepositoryProvider).cachedProfile?.fullName;
});
