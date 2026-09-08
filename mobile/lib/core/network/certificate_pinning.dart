/// **S-H6 / M153** — sertifikat (SPKI) pinning.
///
/// `Env.enableCertPinning` bayrog'i ilgari **hech qayerda ishlatilmagan** edi:
/// konfiguratsiya himoya bor deb ko'rsatar, aslida pinning yo'q edi. Endi
/// bayroq shu modulga ulanadi va yolg'on gapirmaydi.
///
/// Pin qiymatlari kompilyatsiya vaqtida beriladi:
/// ```
/// --dart-define=CERT_SPKI_PINS=<base64-sha256-spki>,<zaxira-pin>
/// ```
/// **Ikkita pin majburiy** (asosiy + zaxira) — rotatsiya paytida ilova
/// o'lmasligi uchun (M153).
///
/// Fail-closed: pinning yoqilgan bo'lsa-yu ro'yxat bo'sh/buzuq bo'lsa —
/// [StateError] bilan **darhol** to'xtaydi, jimgina pinningsiz ishlamaydi.
///
/// Pin — leaf sertifikat `SubjectPublicKeyInfo` (DER) ning SHA-256 hashi,
/// base64 da. Aynan `openssl x509 -pubkey | openssl pkey -pubin -outform der |
/// openssl dgst -sha256 -binary | base64` bilan bir xil qiymat.
library;

import 'dart:convert';
import 'dart:io' show X509Certificate;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/env.dart';

/// Pinning konfiguratsiyasi va tekshiruvi.
abstract final class CertificatePinning {
  const CertificatePinning._();

  /// Vergul bilan ajratilgan base64 SPKI pinlar (`--dart-define`).
  static const String rawPins = String.fromEnvironment('CERT_SPKI_PINS');

  /// M153: rotatsiya uchun kamida ikkita pin bo'lishi shart.
  static const int minPins = 2;

  /// Konfiguratsiyadagi pinlar ro'yxati (bo'sh bo'lishi mumkin).
  static Set<String> get pins => parsePins(rawPins);

  /// Pinning yoqilganmi (`ENABLE_CERT_PINNING`).
  static bool get enabled => Env.enableCertPinning;

  /// Pinlar berilmaganda ko'rsatiladigan aniq sabab (#B-131).
  ///
  /// Repoda soxta pin **saqlanmaydi**: noto'g'ri pin ilovani o'ldiradi
  /// (M153), shuning uchun prod build'ning ataylab to'xtashi to'g'ri
  /// xatti-harakat. Qiymatni olish yo'li — `RELEASE.md` §3.1.
  static const String emptyPinsMessage =
      'CERT_SPKI_PINS to\'ldirilmagan — prod build sertifikat pinningsiz '
      'chiqarilmaydi (M153). Pinlarni olish: RELEASE.md §3.1';

  /// Pin qo'llanadigan host — API bazasidan olinadi (`eldapi.stackyard.uz`).
  static String get apiHost => Uri.tryParse(Env.apiBaseUrl)?.host ?? '';

  /// `"pin1, pin2"` → `{pin1, pin2}`. Formati buzuq element **tashlab
  /// yuborilmaydi**, [validate] uni xato deb topadi.
  static Set<String> parsePins(String raw) =>
      raw.split(',').map((String p) => p.trim()).where((String p) => p.isNotEmpty).toSet();

  /// Base64 da 32 baytli hash bo'lishi shart.
  static bool isWellFormedPin(String pin) {
    try {
      return base64Decode(pin).length == 32;
    } on FormatException {
      return false;
    }
  }

  /// Konfiguratsiya muammolari ro'yxati (bo'sh = hammasi joyida).
  ///
  /// `main.dart`/`Env.validate()` dan ham chaqirilishi mumkin.
  static List<String> validate({bool? pinningEnabled, Set<String>? configuredPins, String? host}) {
    final bool on = pinningEnabled ?? enabled;
    final Set<String> list = configuredPins ?? pins;
    final String pinnedHost = host ?? apiHost;
    final List<String> problems = <String>[];

    if (Env.current == AppFlavor.prod && !on) {
      problems.add('prod build sertifikat pinningsiz yig\'ilmoqda (M153)');
    }
    if (!on) {
      return problems;
    }
    if (list.isEmpty) {
      // #B-131: eng ko'p uchraydigan holat — pinlar umuman berilmagan.
      // Xato matni aynan shu sababni aytadi (soxta pin yozib qo'yish emas,
      // haqiqiy SPKI qiymatini sertifikatdan olish kerak — `RELEASE.md` §3.1).
      problems.add(emptyPinsMessage);
    } else if (list.length < minPins) {
      problems.add(
        'ENABLE_CERT_PINNING=true, lekin CERT_SPKI_PINS da '
        '${list.length} ta pin bor — kamida $minPins (asosiy + zaxira) kerak (M153)',
      );
    }
    for (final String pin in list) {
      if (!isWellFormedPin(pin)) {
        problems.add('CERT_SPKI_PINS da noto\'g\'ri pin (base64 SHA-256 emas)');
        break;
      }
    }
    if (pinnedHost.isEmpty) {
      problems.add('pinning uchun API_BASE_URL host aniqlanmadi');
    }
    return problems;
  }

  /// Noto'g'ri konfiguratsiyada **build/ishga tushishni to'xtatadi**.
  static void assertConfigured() {
    final List<String> problems = validate();
    if (problems.isNotEmpty) {
      throw StateError(
        'Sertifikat pinning konfiguratsiyasi noto\'g\'ri:\n'
        ' - ${problems.join('\n - ')}',
      );
    }
  }

  /// Dio ga pinning adapterini o'rnatadi.
  ///
  /// Pinning o'chirilgan bo'lsa adapter tegilmaydi (dev/stage). Yoqilgan
  /// bo'lsa avval [assertConfigured] ishlaydi — bo'sh ro'yxat bilan jimgina
  /// davom etilmaydi.
  static void install(Dio dio, {Set<String>? overridePins, String? host}) {
    if (!enabled) {
      // Prod'da bayroq o'chiq bo'lsa ham xato beriladi (fail-closed).
      assertConfigured();
      return;
    }
    assertConfigured();
    final Set<String> expected = overridePins ?? pins;
    final String pinnedHost = host ?? apiHost;
    dio.httpClientAdapter = IOHttpClientAdapter(
      validateCertificate: (X509Certificate? certificate, String requestHost, int port) =>
          verifyCertificate(certificate, requestHost, expected: expected, pinnedHost: pinnedHost),
    );
  }

  /// Bitta ulanishni tekshiradi. `false` → `DioExceptionType.badCertificate`
  /// → `ApiError(CLIENT_TLS_PINNING)` → `M-55` ekrani.
  static bool verifyCertificate(
    X509Certificate? certificate,
    String requestHost, {
    required Set<String> expected,
    required String pinnedHost,
  }) {
    // Boshqa hostlar (masalan object storage presign) pinlanmaydi — ular
    // uchun standart CA validatsiyasi allaqachon o'tgan.
    if (requestHost != pinnedHost) {
      return true;
    }
    if (certificate == null) {
      return false;
    }
    final String? pin = spkiPin(certificate.der);
    return pin != null && expected.contains(pin);
  }

  /// Leaf sertifikat DER dan SPKI pinini hisoblaydi (`null` — DER buzuq).
  static String? spkiPin(List<int> der) {
    final List<int>? spki = _extractSpki(der);
    if (spki == null) {
      return null;
    }
    return base64Encode(sha256.convert(spki).bytes);
  }

  /// `Certificate → tbsCertificate → subjectPublicKeyInfo` (DER, sarlavhasi
  /// bilan). Minimal ASN.1 yurgichi: X.509 tuzilmasi qat'iy belgilangan.
  static List<int>? _extractSpki(List<int> der) {
    final _Asn1? certificate = _Asn1.parse(der, 0);
    if (certificate == null) {
      return null;
    }
    final _Asn1? tbs = _Asn1.parse(der, certificate.contentStart);
    if (tbs == null) {
      return null;
    }
    int offset = tbs.contentStart;
    // Ixtiyoriy `[0] EXPLICIT version`.
    _Asn1? node = _Asn1.parse(der, offset);
    if (node == null) {
      return null;
    }
    if (node.tag == 0xA0) {
      offset = node.end;
    }
    // serialNumber, signature, issuer, validity, subject — 5 ta element.
    for (int i = 0; i < 5; i++) {
      node = _Asn1.parse(der, offset);
      if (node == null) {
        return null;
      }
      offset = node.end;
    }
    final _Asn1? spki = _Asn1.parse(der, offset);
    if (spki == null || spki.end > der.length) {
      return null;
    }
    return der.sublist(offset, spki.end);
  }
}

/// Bitta ASN.1 TLV tugunining chegaralari.
class _Asn1 {
  const _Asn1({required this.tag, required this.contentStart, required this.end});

  final int tag;
  final int contentStart;
  final int end;

  static _Asn1? parse(List<int> bytes, int start) {
    if (start + 1 >= bytes.length) {
      return null;
    }
    final int tag = bytes[start];
    int index = start + 1;
    final int first = bytes[index++];
    int length;
    if (first < 0x80) {
      length = first;
    } else {
      final int count = first & 0x7f;
      // Uzunlik 4 baytdan oshmaydi (sertifikat hajmi cheklangan).
      if (count == 0 || count > 4 || index + count > bytes.length) {
        return null;
      }
      length = 0;
      for (int i = 0; i < count; i++) {
        length = (length << 8) | bytes[index++];
      }
    }
    final int end = index + length;
    if (end > bytes.length) {
      return null;
    }
    return _Asn1(tag: tag, contentStart: index, end: end);
  }
}
