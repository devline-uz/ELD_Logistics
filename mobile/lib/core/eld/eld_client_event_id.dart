/// **M72:** ELD buferidan o'qilgan event uchun **deterministik**
/// `client_event_id`.
///
/// Bufer bir necha marta o'qilishi mumkin (qayta ulanish, ilova qayta ishga
/// tushishi, iOS state restoration). Har o'qishda **ayni o'sha** ID chiqishi
/// shart — aks holda server `duplicate` o'rniga ikkinchi eventni yozadi.
///
/// Algoritm (skill `flutter-ble` §4):
/// ```
/// name   = "<device_id>|<eld_seq>|<ts_iso8601_utc>"
/// digest = sha256(namespace_bytes || utf8(name))
/// uuid   = digest[0..15] with version 5 + RFC 4122 variant
/// ```
/// **Chetlashish (CR nomzodi):** TZ «UUID v5» deydi, lekin `sync_core`
/// `validateEventDraft` `client_event_id` ni **v4 shaklida** talab qiladi
/// (`isUuidV4`, M19) va server kontrakti ham shu shaklni kutadi. Shuning uchun
/// xesh natijasi **v4 versiya nibble'i bilan** formatlanadi: qiymat baribir
/// deterministik (xesh), faqat versiya bayti v4 ko'rinishida. ID kriptografik
/// dalil emas — u faqat idempotentlik kaliti.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'eld_models.dart';

/// ONEBOOK ELD bufer eventlari uchun barqaror namespace (UUID v4, qo'lda tanlangan).
///
/// **Hech qachon o'zgartirilmaydi** — o'zgarsa barcha ID lar siljiydi va
/// dublikatlar paydo bo'ladi.
const String kEldBufferNamespace = '6f9619ff-8b86-d011-b42d-00c04fc964ff';

/// Buferdagi event uchun barqaror `client_event_id`.
///
/// Vendor barqaror ID bersa ([EldBufferedEvent.vendorEventId]) — u ham
/// namespace bilan xeshlanadi, shunda format bir xil bo'ladi.
String eldClientEventId({required String deviceId, required EldBufferedEvent event}) {
  final String seed = event.vendorEventId ?? '${event.eldSeq}';
  final String name =
      '$deviceId|$seed|${event.recordedAt.toUtc().toIso8601String()}|${event.type.wire}';
  return eldDeterministicUuid(name);
}

/// [name] dan deterministik UUID (namespace — [kEldBufferNamespace]).
///
/// Natija `isUuidV4` tekshiruvidan o'tadi, lekin **tasodifiy emas**: bir xil
/// kirish har doim bir xil ID beradi.
String eldDeterministicUuid(String name) {
  final List<int> bytes = <int>[..._uuidToBytes(kEldBufferNamespace), ...utf8.encode(name)];
  final List<int> digest = sha256.convert(bytes).bytes;
  final List<int> uuid = List<int>.of(digest.sublist(0, 16));
  uuid[6] = (uuid[6] & 0x0f) | 0x40; // versiya nibble'i — v4 shakli (M19)
  uuid[8] = (uuid[8] & 0x3f) | 0x80; // RFC 4122 variant
  return _formatUuid(uuid);
}

List<int> _uuidToBytes(String uuid) {
  final String hex = uuid.replaceAll('-', '');
  if (hex.length != 32) {
    throw ArgumentError.value(uuid, 'uuid', 'must be a 36-char UUID');
  }
  return List<int>.generate(
    16,
    (int i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    growable: false,
  );
}

String _formatUuid(List<int> bytes) {
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) {
      out.write('-');
    }
    out.write(bytes[i].toRadixString(16).padLeft(2, '0'));
  }
  return out.toString();
}
