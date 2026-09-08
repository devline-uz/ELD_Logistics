@Timeout(Duration(seconds: 60))
/// **S-H6 / M153** — SPKI pinning.
///
/// Etalon qiymat `openssl` bilan hisoblangan:
/// `openssl x509 -pubkey -noout | openssl pkey -pubin -outform der |
///  openssl dgst -sha256 -binary | base64`.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eld_mobile/core/network/certificate_pinning.dart';
import 'package:flutter_test/flutter_test.dart';

/// `X509Certificate` ning testdagi dublyori — faqat `der` kerak.
class _FakeCertificate implements X509Certificate {
  _FakeCertificate(List<int> der) : der = Uint8List.fromList(der);

  @override
  final Uint8List der;

  @override
  Uint8List get sha1 => Uint8List(0);

  @override
  String get pem => '';

  @override
  String get subject => 'CN=eldapi.stackyard.uz';

  @override
  String get issuer => 'CN=eldapi.stackyard.uz';

  @override
  DateTime get startValidity => DateTime.utc(2026);

  @override
  DateTime get endValidity => DateTime.utc(2027);
}

/// Test uchun o'zi imzolagan sertifikat (CN=eldapi.stackyard.uz), DER→base64.
const String _certificateB64 =
    'MIIDHTCCAgWgAwIBAgIUGHn/aZztWN6pzXxm0G7cY0OyVzowDQYJKoZIhvcNAQELBQAwHjEcMBoG'
    'A1UEAwwTZWxkYXBpLnN0YWNreWFyZC51ejAeFw0yNjA5MDgwMDAyMzlaFw0yNjA5MTEwMDAyMzla'
    'MB4xHDAaBgNVBAMME2VsZGFwaS5zdGFja3lhcmQudXowggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw'
    'ggEKAoIBAQDYXgsxXWWD1I1kSD+Bl1aGwUYOFMBLXXKIhuo3dYT1XlZ57Flv/qACGvVjQrLJCvTw'
    'U6kIabnMWH0SFRCWhcyOcYvYM0BdzAfwKr+GcPHV79UojiD2uQZ/Z5XsdCWhEe2DxXnFx8890lL2'
    'fuUpxNHmMvbmPldd+bnm/NU6Ok4XPF2aiwsuYVeLYkos3HUdrDjUuSj2rRJoe+IEkjzHYwQAf/1C'
    'DtLKk4qCZXOqBi7I7bL3edYHBzGgeikP8TYwQUOUIgckCb5oarcgzUN8mEmBOywnNzR2heA/6Ano'
    'gRHrpMPAAwWdUSn26zoua//pEBDZwPDRpD1lj/THr0OeqBhlAgMBAAGjUzBRMB0GA1UdDgQWBBSn'
    'oByCiMk7TJeBx79isUDVz9yxwzAfBgNVHSMEGDAWgBSnoByCiMk7TJeBx79isUDVz9yxwzAPBgNV'
    'HRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAZe8pPXAYY1OHDpVrho3UMPk5kNCdIbmuS'
    'NEtD0SmPWdkNZsdu28kn9R+nXTDGppucDSvNAQH2TzneX9z/804O7kq+eGbyXDqu4qa7NBCp10pA'
    '+fpjJtQHaDikZbOzU57hb9muv+e7EbOIBD1xwupJAvkpOAsCNwpAQePsDxPxJHEG5graBYB/Pb+v'
    'Yacw4artSixumro5L3vh0Wd9FS6OOvu8DJiofq5g7FAEMYGH5hehmxmO2aAHkuSF0Tnphm2QVxH2'
    'hEFM14BcGSYTp4DrqmWhUc5pj0ghz7CJRQGjGqVjYsOmsaST+18rCWyp6pEba40S3+kfTQ7a//9J'
    'NSzM';

/// `openssl` hisoblagan etalon pin.
const String _expectedPin = 'BVz13mtMEk8LcpLRsAGcZL+20TZCEwJlZhezEylrwPA=';

/// Zaxira pin (rotatsiya uchun) — boshqa kalitning hashi.
const String _backupPin = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';

void main() {
  final List<int> der = base64Decode(_certificateB64);

  group('SPKI hisoblash', () {
    test('leaf sertifikatdan openssl bilan bir xil pin chiqadi', () {
      expect(CertificatePinning.spkiPin(der), _expectedPin);
    });

    test('buzuq DER null qaytaradi (jimgina "mos keldi" demaydi)', () {
      expect(CertificatePinning.spkiPin(<int>[0x30, 0x03, 0x02, 0x01, 0x00]), isNull);
      expect(CertificatePinning.spkiPin(der.sublist(0, 40)), isNull);
      expect(CertificatePinning.spkiPin(const <int>[]), isNull);
    });
  });

  group('pin ro\'yxati', () {
    test('vergul bilan ajratilgan ro\'yxat o\'qiladi', () {
      expect(CertificatePinning.parsePins(' $_expectedPin , $_backupPin '), <String>{
        _expectedPin,
        _backupPin,
      });
      expect(CertificatePinning.parsePins(''), isEmpty);
    });

    test('faqat 32 baytli base64 pin qabul qilinadi', () {
      expect(CertificatePinning.isWellFormedPin(_expectedPin), isTrue);
      expect(CertificatePinning.isWellFormedPin('qisqa'), isFalse);
      expect(CertificatePinning.isWellFormedPin('!!!not-base64!!!'), isFalse);
    });
  });

  group('konfiguratsiya fail-closed', () {
    test('bo\'sh ro\'yxatda pinning yoqilgan bo\'lsa xato beriladi', () {
      final List<String> problems = CertificatePinning.validate(
        pinningEnabled: true,
        configuredPins: const <String>{},
      );
      expect(problems, isNotEmpty);
      expect(problems.first, contains('CERT_SPKI_PINS'));
      // #B-131: sabab aniq aytilishi kerak — repoda soxta pin saqlanmaydi,
      // prod build ataylab to'xtaydi (`RELEASE.md` §3.1).
      expect(problems, contains(CertificatePinning.emptyPinsMessage));
      expect(CertificatePinning.emptyPinsMessage, contains('to\'ldirilmagan'));
    });

    test('bo\'sh ro\'yxat xatosi `Env.validate()` orqali ham chiqadi (#B-131)', () {
      // `Env.validate()` shu ro'yxatni o'z muammolariga qo'shadi, shuning
      // uchun bir joyda tekshirilgan konfiguratsiya butun ilova uchun amal
      // qiladi. Runtime `--dart-define` larsiz `enabled == false` bo'lgani
      // uchun bu yerda aniq parametrlar beriladi.
      expect(
        CertificatePinning.validate(pinningEnabled: true, configuredPins: const <String>{}),
        contains(CertificatePinning.emptyPinsMessage),
      );
    });

    test('bitta pin yetarli emas — zaxira majburiy (M153)', () {
      expect(
        CertificatePinning.validate(pinningEnabled: true, configuredPins: <String>{_expectedPin}),
        isNotEmpty,
      );
    });

    test('noto\'g\'ri formatdagi pin aniqlanadi', () {
      expect(
        CertificatePinning.validate(
          pinningEnabled: true,
          configuredPins: <String>{_expectedPin, 'yaroqsiz'},
        ),
        isNotEmpty,
      );
    });

    test('ikkita to\'g\'ri pin bilan muammo yo\'q', () {
      expect(
        CertificatePinning.validate(
          pinningEnabled: true,
          configuredPins: <String>{_expectedPin, _backupPin},
          host: 'eldapi.stackyard.uz',
        ),
        isEmpty,
      );
    });

    test('host aniqlanmasa pinning konfiguratsiyasi noto\'g\'ri', () {
      expect(
        CertificatePinning.validate(
          pinningEnabled: true,
          configuredPins: <String>{_expectedPin, _backupPin},
          host: '',
        ),
        isNotEmpty,
      );
    });

    test('dev muhitida pinning o\'chiq bo\'lishi muammo emas', () {
      expect(
        CertificatePinning.validate(pinningEnabled: false, configuredPins: const <String>{}),
        isEmpty,
      );
    });
  });

  group('ulanish tekshiruvi', () {
    test('pinlangan hostda mos pin o\'tadi, notanish pin bloklanadi', () {
      expect(
        CertificatePinning.verifyCertificate(
          _FakeCertificate(der),
          'eldapi.stackyard.uz',
          expected: <String>{_expectedPin, _backupPin},
          pinnedHost: 'eldapi.stackyard.uz',
        ),
        isTrue,
      );
      expect(
        CertificatePinning.verifyCertificate(
          _FakeCertificate(der),
          'eldapi.stackyard.uz',
          expected: <String>{_backupPin},
          pinnedHost: 'eldapi.stackyard.uz',
        ),
        isFalse,
      );
    });

    test('sertifikat berilmasa ulanish rad etiladi', () {
      expect(
        CertificatePinning.verifyCertificate(
          null,
          'eldapi.stackyard.uz',
          expected: <String>{_expectedPin},
          pinnedHost: 'eldapi.stackyard.uz',
        ),
        isFalse,
      );
    });

    test('boshqa host (masalan presign storage) pinlanmaydi', () {
      expect(
        CertificatePinning.verifyCertificate(
          _FakeCertificate(der),
          'files.example.com',
          expected: <String>{_backupPin},
          pinnedHost: 'eldapi.stackyard.uz',
        ),
        isTrue,
      );
    });
  });
}
