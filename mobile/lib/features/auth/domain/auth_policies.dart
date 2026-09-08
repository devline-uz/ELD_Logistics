/// Auth biznes qoidalari — **sof funksiyalar**, widget/provayder ichida emas
/// (tz-mobile §4.3, §4.5, §17.3 · flutter-conventions qatlam qoidasi 3).
///
/// Bu fayl `DateTime.now()` ni ishlatmaydi: har qaror `now` parametrini oladi
/// (`TimeSource` dan) — testlar deterministik bo'lishi uchun.
library;

/// M-02 login formasining maydon xatolari.
enum LoginFieldIssue { usernameRequired, passwordTooShort }

/// §4.3: username trim qilinadi (lowercase QILINMAYDI — server hal qiladi),
/// parol ≥8 belgi.
abstract final class LoginFormPolicy {
  const LoginFormPolicy._();

  static const int minPasswordLength = 8;

  static String normalizeUsername(String raw) => raw.trim();

  static LoginFieldIssue? validateUsername(String raw) =>
      normalizeUsername(raw).isEmpty ? LoginFieldIssue.usernameRequired : null;

  static LoginFieldIssue? validatePassword(String raw) =>
      raw.length < minPasswordLength ? LoginFieldIssue.passwordTooShort : null;

  /// Tugma faqat ikkala maydon to'ldirilganda yoqiladi (M-02 «bo'sh» holati).
  static bool canSubmit({required String username, required String password}) =>
      validateUsername(username) == null && validatePassword(password) == null;
}

/// §4.5 PIN format qoidalari (mijoz tomonida ham tekshiriladi).
enum PinFormatIssue { length, repeated, sequence }

abstract final class PinPolicy {
  const PinPolicy._();

  /// **Aynan** 6 raqam.
  static const int length = 6;

  static PinFormatIssue? validate(String pin) {
    if (pin.length != length || !_allDigits(pin)) {
      return PinFormatIssue.length;
    }
    if (_allSame(pin)) {
      return PinFormatIssue.repeated;
    }
    if (_isRun(pin)) {
      return PinFormatIssue.sequence;
    }
    return null;
  }

  static bool isValid(String pin) => validate(pin) == null;

  static bool _allDigits(String value) {
    for (int i = 0; i < value.length; i++) {
      final int code = value.codeUnitAt(i);
      if (code < 0x30 || code > 0x39) {
        return false;
      }
    }
    return true;
  }

  static bool _allSame(String value) {
    for (int i = 1; i < value.length; i++) {
      if (value.codeUnitAt(i) != value.codeUnitAt(0)) {
        return false;
      }
    }
    return true;
  }

  /// `123456` va `654321` kabi ketma-ketliklar.
  static bool _isRun(String value) {
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < value.length; i++) {
      final int diff = value.codeUnitAt(i) - value.codeUnitAt(i - 1);
      if (diff != 1) {
        ascending = false;
      }
      if (diff != -1) {
        descending = false;
      }
    }
    return ascending || descending;
  }
}

/// PIN urinishlari holati — secure storage'da saqlanadi (ilovani o'chirib
/// yoqish bilan tiklanmaydi).
class PinLockoutState {
  const PinLockoutState({this.failedAttempts = 0, this.lockedUntil});

  final int failedAttempts;
  final DateTime? lockedUntil;

  bool isLocked(DateTime now) => lockedUntil != null && lockedUntil!.isAfter(now);

  Duration remaining(DateTime now) => isLocked(now) ? lockedUntil!.difference(now) : Duration.zero;

  @override
  String toString() => 'PinLockoutState($failedAttempts, until: $lockedUntil)';
}

/// §4.5: 5 noto'g'ri urinish → 60 s, keyingisi 5 daq (eksponensial).
abstract final class PinLockoutPolicy {
  const PinLockoutPolicy._();

  /// Blok boshlanadigan urinishlar soni.
  static const int attemptsBeforeLock = 5;

  static const Duration firstLock = Duration(seconds: 60);
  static const Duration secondLock = Duration(minutes: 5);
  static const Duration maxLock = Duration(minutes: 60);

  /// Noto'g'ri urinishdan keyingi yangi holat.
  static PinLockoutState onFailure(PinLockoutState current, DateTime now) {
    final int attempts = current.failedAttempts + 1;
    if (attempts < attemptsBeforeLock) {
      return PinLockoutState(failedAttempts: attempts, lockedUntil: current.lockedUntil);
    }
    // 5, 10, 15 … urinishda blok muddati eksponensial oshadi.
    final int lockIndex = (attempts ~/ attemptsBeforeLock) - 1;
    return PinLockoutState(failedAttempts: attempts, lockedUntil: now.add(lockFor(lockIndex)));
  }

  /// Blok muddati: 0 → 60 s, 1 → 5 daq, keyin ×2, `maxLock` gacha.
  static Duration lockFor(int lockIndex) {
    if (lockIndex <= 0) {
      return firstLock;
    }
    final int seconds = secondLock.inSeconds * (1 << (lockIndex - 1));
    return seconds >= maxLock.inSeconds ? maxLock : Duration(seconds: seconds);
  }

  /// Muvaffaqiyatli tekshiruvdan keyin hisoblagich tozalanadi.
  static const PinLockoutState cleared = PinLockoutState();

  /// M156: server `PIN_LOCKED` qaytarsa uning muddati **ustun**.
  static PinLockoutState fromServerLock(PinLockoutState current, DateTime lockedUntil) =>
      PinLockoutState(failedAttempts: current.failedAttempts, lockedUntil: lockedUntil);

  /// Qolgan urinishlar (blokgacha).
  static int attemptsLeft(PinLockoutState state) {
    final int used = state.failedAttempts % attemptsBeforeLock;
    return attemptsBeforeLock - used;
  }
}

/// Parol kuchi indikatori (M-05 / M-07).
enum PasswordStrength { weak, fair, strong }

abstract final class PasswordPolicy {
  const PasswordPolicy._();

  static const int minLength = 8;

  static bool isAcceptable(String password) => password.length >= minLength;

  static PasswordStrength strength(String password) {
    if (password.length < minLength) {
      return PasswordStrength.weak;
    }
    int classes = 0;
    if (password.contains(RegExp('[a-z]'))) {
      classes++;
    }
    if (password.contains(RegExp('[A-Z]'))) {
      classes++;
    }
    if (password.contains(RegExp('[0-9]'))) {
      classes++;
    }
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      classes++;
    }
    if (password.length >= 12 && classes >= 3) {
      return PasswordStrength.strong;
    }
    if (classes >= 2) {
      return PasswordStrength.fair;
    }
    return PasswordStrength.weak;
  }
}

/// Parol + tasdiq juftligining xatosi (M-05 / M-07).
enum PasswordPairIssue {
  /// `PasswordPolicy.isAcceptable` bajarilmadi.
  tooShort,

  /// Tasdiq maydoni mos kelmadi.
  mismatch,
}

abstract final class PasswordPairPolicy {
  const PasswordPairPolicy._();

  static PasswordPairIssue? validate({required String password, required String confirm}) {
    if (!PasswordPolicy.isAcceptable(password)) {
      return PasswordPairIssue.tooShort;
    }
    return password == confirm ? null : PasswordPairIssue.mismatch;
  }
}

/// PIN + tasdiq juftligi (M-05).
enum PinPairIssue { format, mismatch }

abstract final class PinPairPolicy {
  const PinPairPolicy._();

  static PinPairIssue? validate({required String pin, required String confirm}) {
    if (!PinPolicy.isValid(pin)) {
      return PinPairIssue.format;
    }
    return pin == confirm ? null : PinPairIssue.mismatch;
  }
}

/// M-05 `Accept invitation` formasining yuborish sharti.
abstract final class InvitationFormPolicy {
  const InvitationFormPolicy._();

  static bool canSubmit({
    required String token,
    required String password,
    required String passwordConfirm,
    required String pin,
    required String pinConfirm,
    required bool consentGiven,
  }) =>
      token.isNotEmpty &&
      consentGiven &&
      PasswordPairPolicy.validate(password: password, confirm: passwordConfirm) == null &&
      PinPairPolicy.validate(pin: pin, confirm: pinConfirm) == null;
}

/// M-07 `Reset password` formasining yuborish sharti.
abstract final class ResetPasswordFormPolicy {
  const ResetPasswordFormPolicy._();

  static bool canSubmit({
    required String token,
    required String password,
    required String passwordConfirm,
  }) =>
      token.isNotEmpty &&
      PasswordPairPolicy.validate(password: password, confirm: passwordConfirm) == null;
}

/// M-06 `Forgot password` — bitta maydon, `LoginFormPolicy` bilan bir xil qoida.
abstract final class ForgotPasswordFormPolicy {
  const ForgotPasswordFormPolicy._();

  static String normalize(String raw) => LoginFormPolicy.normalizeUsername(raw);

  static bool canSubmit(String raw) => normalize(raw).isNotEmpty;
}

/// M-08 TOTP kodi — aynan 6 raqam (RFC 6238 `digits`).
abstract final class TotpCodePolicy {
  const TotpCodePolicy._();

  static const int length = 6;

  static bool isValid(String code) => code.length == length && RegExp(r'^\d{6}$').hasMatch(code);

  /// Zaxira kod — bo'sh bo'lmasligi yetarli (format serverda tekshiriladi).
  static bool isValidRecoveryCode(String code) => code.trim().isNotEmpty;
}

/// M-57: ilova versiyasi bo'yicha qaror (§4.2 qadam 2).
enum UpdateRequirement {
  /// Ishlash mumkin.
  none,

  /// Bloklovchi `M-57` ekrani.
  forced,
}

abstract final class VersionGate {
  const VersionGate._();

  /// [compare] — `AppVersion.compareSemver` (core'dagi implementatsiya).
  static UpdateRequirement decide({
    required String currentVersion,
    required bool forceUpdate,
    required String? minSupportedVersion,
    required int Function(String a, String b) compare,
  }) {
    if (forceUpdate) {
      return UpdateRequirement.forced;
    }
    final String? minimum = minSupportedVersion;
    if (minimum == null || minimum.isEmpty) {
      return UpdateRequirement.none;
    }
    return compare(currentVersion, minimum) < 0 ? UpdateRequirement.forced : UpdateRequirement.none;
  }
}

/// PII maskalash (M159) — ekranda ham, logda ham bir xil qoida.
abstract final class PiiMask {
  const PiiMask._();

  /// `john.doe@example.com` → `j***e@example.com`.
  static String email(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    final int at = value.indexOf('@');
    if (at <= 0) {
      return '***';
    }
    final String local = value.substring(0, at);
    if (local.length <= 2) {
      return '***${value.substring(at)}';
    }
    return '${local[0]}***${local[local.length - 1]}${value.substring(at)}';
  }
}
