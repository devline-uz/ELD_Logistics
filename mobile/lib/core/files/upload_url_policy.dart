/// Presign javobidagi `upload_url` validatsiyasi (S-H2, §16 · M149).
///
/// `POST /files/presign` javobi **ishonchsiz kirish** deb qaraladi: buzilgan
/// backend, MITM yoki noto'g'ri konfiguratsiya qilingan storage imzo PNG va
/// DVIR fotolarini (PII) ixtiyoriy hostga jo'natib yuborishi mumkin. Yuklash
/// interceptorlarsiz `Dio` bilan ketgani uchun (presigned URL o'z imzosiga ega)
/// bu yagona himoya chegarasi.
///
/// Qoidalar:
///  * `scheme` **faqat** `https` (M154 bilan bir mantiq — cleartext taqiq);
///  * host oq ro'yxatda: `stackyard.uz` va uning subdomenlari + `Env.apiBaseUrl`
///    hosti (dev/stage muhitida boshqa domen bo'lishi mumkin);
///  * `userInfo` (`https://user:pass@host`) taqiq — host'ni yashirish usuli;
///  * port faqat standart (443);
///  * rad etilganda **jimgina o'tkazib yuborilmaydi** — [UntrustedUploadUrlException].
///
/// Xato matnida **to'liq URL yo'q** (M149: imzo parametrlari sir) — faqat
/// `scheme` va `host`.
library;

import '../config/env.dart';
import '../error/api_error.dart';
import '../error/api_error_code.dart';

/// Oq ro'yxatdagi domen — o'zi va barcha subdomenlari.
const Set<String> kDefaultUploadHostSuffixes = <String>{'stackyard.uz'};

/// `upload_url` uchun ruxsat etilgan manzillar to'plami.
class UploadUrlPolicy {
  const UploadUrlPolicy({
    this.hosts = const <String>{},
    this.hostSuffixes = kDefaultUploadHostSuffixes,
  });

  /// Aynan mos kelishi kerak bo'lgan hostlar (masalan dev storage).
  final Set<String> hosts;

  /// Domen va uning subdomenlari (`storage.stackyard.uz`).
  final Set<String> hostSuffixes;

  /// Ishlab chiqarish siyosati: standart domen + joriy muhit API hosti.
  ///
  /// `Env.apiBaseUrl` testlarda bo'sh bo'ladi — u holda faqat suffiks ro'yxati
  /// qoladi (fail-closed: bo'sh muhit hech qanday hostni qo'shmaydi).
  static UploadUrlPolicy standard() {
    final String? apiHost = Uri.tryParse(Env.apiBaseUrl)?.host;
    return UploadUrlPolicy(
      hosts: apiHost == null || apiHost.isEmpty ? const <String>{} : <String>{apiHost},
    );
  }

  bool allowsHost(String host) {
    final String value = host.toLowerCase();
    if (value.isEmpty) {
      return false;
    }
    if (hosts.any((String h) => h.toLowerCase() == value)) {
      return true;
    }
    return hostSuffixes.any((String suffix) {
      final String s = suffix.toLowerCase();
      return value == s || value.endsWith('.$s');
    });
  }
}

/// `upload_url` oq ro'yxatdan o'tmadi — fayl **yuborilmaydi**.
///
/// [ApiError] dan meros oladi: shu tufayli `sync_side_channel` uni `400
/// BAD_REQUEST` sifatida tutadi va outbox elementi **`rejected`** bo'ladi
/// (sabab bilan). Jimgina `null` qaytarish yoki push siklini yiqitish —
/// ikkalasi ham yaramaydi.
class UntrustedUploadUrlException extends ApiError {
  const UntrustedUploadUrlException({required this.reason, this.scheme = '', this.host = ''})
    : super(
        code: ApiErrorCode.badRequest,
        message: 'upload_url rejected by allowlist',
        statusCode: 400,
      );

  /// Mashina o'qiy oladigan sabab: `malformed` · `scheme` · `host` · `userinfo` · `port`.
  final String reason;
  final String scheme;
  final String host;

  /// M149: to'liq URL (imzo parametrlari bilan) **hech qachon** chiqmaydi.
  @override
  String toString() => 'UntrustedUploadUrlException($reason, $scheme://$host)';
}

/// Tekshirilgan `Uri` qaytaradi yoki [UntrustedUploadUrlException] otadi.
Uri validateUploadUrl(String raw, {UploadUrlPolicy? policy}) {
  final UploadUrlPolicy rules = policy ?? UploadUrlPolicy.standard();
  final Uri? uri = Uri.tryParse(raw.trim());
  if (uri == null || !uri.hasScheme || !uri.hasAuthority || uri.host.isEmpty) {
    throw const UntrustedUploadUrlException(reason: 'malformed');
  }
  if (uri.scheme.toLowerCase() != 'https') {
    throw UntrustedUploadUrlException(reason: 'scheme', scheme: uri.scheme, host: uri.host);
  }
  if (uri.userInfo.isNotEmpty) {
    throw UntrustedUploadUrlException(reason: 'userinfo', scheme: uri.scheme, host: uri.host);
  }
  if (uri.hasPort && uri.port != 443) {
    throw UntrustedUploadUrlException(reason: 'port', scheme: uri.scheme, host: uri.host);
  }
  if (!rules.allowsHost(uri.host)) {
    throw UntrustedUploadUrlException(reason: 'host', scheme: uri.scheme, host: uri.host);
  }
  return uri;
}
