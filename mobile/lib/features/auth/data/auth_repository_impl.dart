/// `AuthRepository` implementatsiyasi — tarmoq + `SecureVault` + lokal PIN.
///
/// Barcha vaqt `TimeSource` dan (§7): bu yerda `DateTime.now()` yo'q.
library;

import '../../../core/device/app_version.dart';
import '../../../core/error/api_error.dart';
import '../../../core/error/api_error_code.dart';
import '../../../core/network/refresh_coordinator.dart';
import '../../../core/security/pin_hasher.dart';
import '../../../core/security/secure_vault.dart';
import '../../../core/time/time_source.dart';
import '../domain/auth_models.dart';
import '../domain/auth_policies.dart';
import '../domain/auth_repository.dart';
import '../domain/driver_session.dart';
import '../domain/session_state.dart';
import 'auth_api.dart';
import 'pin_lockout_store.dart';
import 'session_store.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._api,
    required this._vault,
    required PinLockoutStore lockoutStore,
    required SessionStore sessionStore,
    required TimeSource timeSource,
    required this._appVersion,
    required this._deviceKind,
    this._slot = DriverSlot.primary,
  }) : _lockout = lockoutStore,
       _sessions = sessionStore,
       _time = timeSource;

  final AuthApi _api;
  final SecureVault _vault;
  final PinLockoutStore _lockout;

  /// **S-C1** — sessiya slotlarining **doimiy** holati (`SecureVault`).
  /// `paused` bayrog'i shu yerda yashaydi; RAM da ushlab turilmaydi.
  final SessionStore _sessions;

  final TimeSource _time;
  final AppVersion _appVersion;
  final DeviceKind _deviceKind;
  final DriverSlot _slot;

  AppConfig? _config;
  DriverProfile? _profile;

  @override
  AppConfig? get cachedConfig => _config;

  @override
  DriverProfile? get cachedProfile => _profile;

  // --- Bootstrap (§4.2) ------------------------------------------------------

  @override
  Future<BootstrapResult> bootstrap() async {
    bool offline = false;

    // 1. Public config. Muvaffaqiyatsizlik ilovani BLOKLAMAYDI (M13).
    try {
      final AppConfig config = await _api.appConfig();
      _config = config;
      final DateTime? serverTime = config.serverTime;
      if (serverTime != null) {
        _time.syncFromServer(serverTime);
      }
    } on ApiError catch (error) {
      if (!error.isOffline) {
        rethrow;
      }
      offline = true;
    }

    // 2. Versiya darvozasi — bloklovchi M-57.
    final AppConfig? config = _config;
    if (config != null) {
      final UpdateRequirement requirement = VersionGate.decide(
        currentVersion: _appVersion.version,
        forceUpdate: config.forceUpdate,
        minSupportedVersion: config.minSupportedVersion,
        compare: AppVersion.compareSemver,
      );
      if (requirement == UpdateRequirement.forced) {
        return BootstrapResult(
          destination: BootstrapDestination.forceUpdate,
          config: config,
          offline: offline,
        );
      }
    }

    // 3. Refresh token bormi?
    final String? refreshToken = await _vault.readRefreshToken(_slot);
    if (refreshToken == null || refreshToken.isEmpty) {
      return BootstrapResult(
        destination: BootstrapDestination.login,
        config: config,
        offline: offline,
      );
    }

    // **S-C1 (M18 / §4.8):** pauza holati diskda (`SecureVault`) — ilovani
    // o'ldirib qayta ochish PIN qulfini chetlab o'tolmaydi.
    final SessionSlotState slotState = (await _sessions.read()).of(_slot);
    if (slotState.isPaused) {
      final String? name = slotState.driverName.isNotEmpty
          ? slotState.driverName
          : _profile?.fullName;
      return BootstrapResult(
        destination: BootstrapDestination.paused,
        config: config,
        offline: offline,
        pausedDriverName: name,
      );
    }

    // 4. Oflayn bo'lsa refresh qilinmaydi — ilova to'liq oflayn ochiladi (M13).
    if (offline) {
      return BootstrapResult(destination: BootstrapDestination.home, config: config, offline: true);
    }

    try {
      final AuthTokens tokens = await _api.refresh(
        refreshToken: refreshToken,
        appVersion: _appVersion.header,
        slot: _slot,
      );
      await _persist(tokens);
      _profile = await _api.me(slot: _slot);
      return BootstrapResult(destination: BootstrapDestination.home, config: config);
    } on ApiError catch (error) {
      if (error.isOffline) {
        // Tarmoq refresh paytida uzildi — baribir oflayn kiriladi (M13).
        return BootstrapResult(
          destination: BootstrapDestination.home,
          config: config,
          offline: true,
        );
      }
      if (error.terminatesSession || error.code == ApiErrorCode.unauthorized) {
        await _vault.clearSession(_slot);
        return BootstrapResult(destination: BootstrapDestination.login, config: config);
      }
      rethrow;
    }
  }

  // --- Login / logout --------------------------------------------------------

  @override
  Future<LoginOutcome> login({
    required String username,
    required String password,
    String? totpCode,
  }) async {
    final String deviceId = await _vault.deviceId();
    final LoginOutcome outcome = await _api.login(
      username: LoginFormPolicy.normalizeUsername(username),
      password: password,
      deviceType: _deviceKind,
      appVersion: _appVersion.header,
      deviceId: deviceId,
      totpCode: totpCode,
    );
    await _persist(outcome.tokens);
    _profile = outcome.profile;
    await _writeSlotStatus(
      SessionStatus.active,
      driverId: outcome.profile?.id,
      driverName: outcome.profile?.fullName,
    );
    return outcome;
  }

  @override
  Future<void> logout({required bool pause}) async {
    final String? refreshToken = await _vault.readRefreshToken(_slot);
    try {
      await _api.logout(pause: pause, refreshToken: refreshToken, slot: _slot);
    } on ApiError catch (error) {
      // M18: tarmoq yo'q bo'lsa lokal holat DARHOL o'zgaradi; so'rov keyin
      // outbox orqali yuboriladi (outbox `core/sync` da).
      if (!error.isOffline) {
        rethrow;
      }
    }

    if (pause) {
      // Leave Truck: refresh token TIRIK qoladi, faqat access token o'chadi.
      _vault.setAccessToken(_slot, null);
      try {
        await _writeSlotStatus(SessionStatus.paused);
      } on Object catch (_) {
        // Pauzani **eslab qola olmadik** → keyingi ishga tushishda PIN
        // qulfini kafolatlab bo'lmaydi. Fail-closed: refresh token o'chadi,
        // haydovchi to'liq login qiladi (S-C1).
        await _vault.clearSession(_slot);
      }
    } else {
      _profile = null;
      // Outbox tegilmaydi (M17) — faqat sessiya tozalanadi.
      await _vault.clearSession(_slot);
      final DualSessionState remaining = await _writeSlotStatus(SessionStatus.empty);
      if (remaining.isSignedOut) {
        // S-M4: qurilmada haydovchi qolmadi — PIN hash, lockout va sessiya
        // holati ham o'chadi. Ikkinchi slot tirik bo'lsa PIN saqlanadi
        // (co-driver oflayn `Return to truck` qila olishi kerak).
        await _vault.clearAllSecrets();
        await _lockout.clear();
      }
    }
  }

  // --- PIN (§4.5, M16, M156) -------------------------------------------------

  @override
  Future<PinLockoutState> pinLockout() => _lockout.read();

  @override
  Future<PinVerification> verifyPin({required String pin, required PinAction action}) async {
    final DateTime now = _time.now();

    // Lokal blok — server so'rovi ham yuborilmaydi.
    final PinLockoutState state = await _lockout.read();
    if (state.isLocked(now)) {
      throw ApiError(
        code: ApiErrorCode.pinLocked,
        message: 'pin locked locally',
        retryAfter: state.remaining(now),
      );
    }

    try {
      final PinVerification verification = await _api.verifyPin(
        pin: pin,
        action: action,
        slot: _slot,
      );
      if (verification.verified) {
        await _lockout.clear();
        if (verification.sessionResumed || action == PinAction.returnToTruck) {
          await _writeSlotStatus(SessionStatus.active);
        }
        // Oflayn tekshiruv uchun lokal hash yangilanadi (M16).
        await _storePinLocally(pin);
      }
      return verification;
    } on ApiError catch (error) {
      if (error.isOffline) {
        return _verifyPinOffline(pin: pin, action: action, now: now);
      }
      if (error.code == ApiErrorCode.pinLocked) {
        // M156: server muddati ustun.
        await _lockout.write(
          PinLockoutPolicy.fromServerLock(
            state,
            now.add(error.retryAfter ?? PinLockoutPolicy.firstLock),
          ),
        );
        rethrow;
      }
      if (error.code == ApiErrorCode.pinInvalid) {
        await _lockout.write(PinLockoutPolicy.onFailure(state, now));
      }
      rethrow;
    }
  }

  /// M16: tarmoq yo'q — lokal `PBKDF2` hash bilan tekshiriladi.
  Future<PinVerification> _verifyPinOffline({
    required String pin,
    required PinAction action,
    required DateTime now,
  }) async {
    final ({String hash, String salt})? stored = await _vault.readPin();
    if (stored == null) {
      throw const ApiError(code: ApiErrorCode.pinNotSet, message: 'no local pin hash');
    }
    final bool ok = PinHasher.verify(pin: pin, salt: stored.salt, expectedHash: stored.hash);
    if (!ok) {
      await _lockout.write(PinLockoutPolicy.onFailure(await _lockout.read(), now));
      throw const ApiError(code: ApiErrorCode.pinInvalid, message: 'offline pin mismatch');
    }
    await _lockout.clear();
    if (action == PinAction.returnToTruck) {
      await _writeSlotStatus(SessionStatus.active);
    }
    return PinVerification(verified: true, action: action, sessionResumed: true, offline: true);
  }

  Future<void> _storePinLocally(String pin) async {
    final String salt = _vault.newPinSalt();
    await _vault.writePin(
      hash: PinHasher.hash(pin: pin, salt: salt),
      salt: salt,
    );
  }

  // --- M-58 Sessions ---------------------------------------------------------

  @override
  Future<List<DriverSession>> sessions() => _api.sessions(slot: _slot);

  @override
  Future<void> revokeSession(String id) => _api.revokeSession(id, slot: _slot);

  // --- Parol tiklash / taklif ------------------------------------------------

  @override
  Future<void> requestPasswordReset({required String login}) =>
      _api.requestPasswordReset(login: LoginFormPolicy.normalizeUsername(login));

  @override
  Future<void> resetPassword({required String token, required String password}) =>
      _api.resetPassword(token: token, password: password);

  @override
  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String pin,
  }) async {
    await _api.acceptInvitation(token: token, password: password, pin: pin);
    // Taklif qabul qilinishi bilan lokal PIN hash yoziladi (oflayn PIN uchun).
    await _storePinLocally(pin);
  }

  // --- 2FA -------------------------------------------------------------------

  @override
  Future<TotpSetup> startTotpSetup() => _api.startTotpSetup(slot: _slot);

  @override
  Future<TotpVerification> verifyTotp({String? code, String? recoveryCode}) async {
    final TotpVerification verification = await _api.verifyTotp(
      code: code,
      recoveryCode: recoveryCode,
      slot: _slot,
    );
    final AuthTokens? tokens = verification.tokens;
    if (tokens != null) {
      await _persist(tokens);
    }
    return verification;
  }

  // --- Profil ----------------------------------------------------------------

  @override
  Future<DriverProfile> me() async {
    final DriverProfile profile = await _api.me(slot: _slot);
    _profile = profile;
    return profile;
  }

  // --- Ichki -----------------------------------------------------------------

  /// Slotning doimiy holatini yangilaydi va yangi to'liq holatni qaytaradi.
  ///
  /// `SessionManager` ham shu hujjatga yozadi — ikkalasi **bitta** manba
  /// (`auth.session_slots`) bilan ishlaydi, parallel ikkinchi bayroq yo'q.
  Future<DualSessionState> _writeSlotStatus(
    SessionStatus status, {
    String? driverId,
    String? driverName,
  }) async {
    final DualSessionState current = await _sessions.read();
    final SessionSlotState next = status.isEmpty
        ? SessionSlotState.vacant(_slot)
        : current.of(_slot).copyWith(status: status, driverId: driverId, driverName: driverName);
    final DualSessionState updated = current.withSlot(next);
    await _sessions.write(updated);
    return updated;
  }

  /// Rotatsiya: yangi refresh token eskisining o'rniga yoziladi (§4.7).
  Future<void> _persist(AuthTokens raw) async {
    final AuthTokens tokens = raw.resolveExpiry(_time.now());
    await _vault.writeRefreshToken(_slot, tokens.refreshToken);
    _vault.setAccessToken(_slot, tokens.accessToken, expiresAt: tokens.expiresAt);
  }
}

/// `core/network/RefreshCoordinator` uchun implementatsiya (§4.7).
///
/// Mutex koordinatorning o'zida; bu yerda faqat bitta HTTP chaqiruv.
class AuthTokenRefreshClient implements TokenRefreshClient {
  const AuthTokenRefreshClient({
    required this._api,
    required this._appVersion,
    required TimeSource timeSource,
  }) : _time = timeSource;

  final AuthApi _api;
  final AppVersion _appVersion;
  final TimeSource _time;

  @override
  Future<RefreshOutcome> refresh({required DriverSlot slot, required String refreshToken}) async {
    try {
      final AuthTokens tokens = (await _api.refresh(
        refreshToken: refreshToken,
        appVersion: _appVersion.header,
        slot: slot,
      )).resolveExpiry(_time.now());
      return RefreshSucceeded(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.expiresAt,
      );
    } on ApiError catch (error) {
      if (error.isOffline) {
        return RefreshDeferred(error);
      }
      return RefreshRejected(error);
    }
  }
}
