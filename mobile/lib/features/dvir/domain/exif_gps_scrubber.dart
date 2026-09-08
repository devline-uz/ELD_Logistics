/// EXIF GPS tozalash (tz-mobile M147) — **sof Dart**, `dart:typed_data` dan boshqa
/// bog'liqlik yo'q, shuning uchun `Isolate` da ham, testda ham ishlaydi.
///
/// Qoida: «GPS **olib tashlanadi** (PII), yo'nalish (Orientation) saqlanadi».
///
/// Amalga oshirish: mavjud `APP1` (Exif) va `APP1` (XMP) segmentlari **butunlay**
/// tashlab yuboriladi — shunda GPS IFD baytlari faylda umuman qolmaydi (faqat
/// ko'rsatkichni nolga chiqarish yetarli emas: qiymatlar baytlarda qolib ketadi).
/// Tashlashdan oldin `Orientation` (tag `0x0112`) o'qib olinadi va faqat shu
/// bitta yozuvdan iborat minimal EXIF bloki qayta yoziladi.
library;

import 'dart:typed_data';

/// JPEG marker'lari.
const int _kMarkerPrefix = 0xFF;
const int _kSoi = 0xD8;
const int _kSos = 0xDA;
const int _kApp1 = 0xE1;
const int _kExifTagOrientation = 0x0112;

const List<int> _kExifHeader = <int>[0x45, 0x78, 0x69, 0x66, 0x00, 0x00]; // "Exif\0\0"
const List<int> _kXmpHeader = <int>[0x68, 0x74, 0x74, 0x70, 0x3A]; // "http:"

/// EXIF tahlili natijasi.
class ExifScrubResult {
  const ExifScrubResult({required this.bytes, required this.hadGps, required this.orientation});

  /// Tozalangan fayl baytlari.
  final Uint8List bytes;

  /// Kirish faylida GPS IFD bo'lganmi (audit/telemetriya uchun).
  final bool hadGps;

  /// Saqlangan yo'nalish (1…8), topilmasa `null`.
  final int? orientation;
}

/// [bytes] JPEG bo'lsa — EXIF/XMP ni tozalaydi va `Orientation` ni saqlaydi.
/// JPEG bo'lmasa baytlar o'zgarishsiz qaytadi.
ExifScrubResult stripExifGps(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != _kMarkerPrefix || bytes[1] != _kSoi) {
    return ExifScrubResult(bytes: bytes, hadGps: false, orientation: null);
  }

  final BytesBuilder out = BytesBuilder(copy: false)..add(<int>[_kMarkerPrefix, _kSoi]);
  int i = 2;
  int? orientation;
  bool hadGps = false;
  bool exifWritten = false;

  while (i + 3 < bytes.length) {
    if (bytes[i] != _kMarkerPrefix) {
      // Marker tuzilmasi buzilgan — qolganini o'zgarishsiz ko'chiramiz.
      break;
    }
    final int marker = bytes[i + 1];
    if (marker == _kSos) {
      break;
    }
    final int segmentLength = (bytes[i + 2] << 8) | bytes[i + 3];
    final int payloadStart = i + 4;
    final int segmentEnd = i + 2 + segmentLength;
    if (segmentLength < 2 || segmentEnd > bytes.length) {
      break;
    }

    final bool isExif = marker == _kApp1 && _startsWith(bytes, payloadStart, _kExifHeader);
    final bool isXmp = marker == _kApp1 && _startsWith(bytes, payloadStart, _kXmpHeader);

    if (isExif) {
      final _ExifSummary summary = _readExif(bytes, payloadStart + _kExifHeader.length, segmentEnd);
      orientation ??= summary.orientation;
      hadGps = hadGps || summary.hasGps;
      if (!exifWritten) {
        out.add(_buildMinimalExif(orientation ?? 1));
        exifWritten = true;
      }
    } else if (isXmp) {
      // XMP da ham GPS bo'lishi mumkin — butunlay tashlanadi.
    } else {
      out.add(Uint8List.sublistView(bytes, i, segmentEnd));
    }

    i = segmentEnd;
  }

  // Qolgan qism (SOS + siqilgan ma'lumot) o'zgarishsiz.
  if (i < bytes.length) {
    out.add(Uint8List.sublistView(bytes, i));
  }

  return ExifScrubResult(bytes: out.toBytes(), hadGps: hadGps, orientation: orientation);
}

bool _startsWith(Uint8List bytes, int offset, List<int> prefix) {
  if (offset + prefix.length > bytes.length) {
    return false;
  }
  for (int k = 0; k < prefix.length; k++) {
    if (bytes[offset + k] != prefix[k]) {
      return false;
    }
  }
  return true;
}

class _ExifSummary {
  const _ExifSummary({this.orientation, this.hasGps = false});

  final int? orientation;
  final bool hasGps;
}

/// IFD0 dan `Orientation` va GPS ko'rsatkichi (`0x8825`) borligini o'qiydi.
_ExifSummary _readExif(Uint8List bytes, int tiffStart, int limit) {
  if (tiffStart + 8 > limit) {
    return const _ExifSummary();
  }
  final bool little = bytes[tiffStart] == 0x49 && bytes[tiffStart + 1] == 0x49;
  final bool big = bytes[tiffStart] == 0x4D && bytes[tiffStart + 1] == 0x4D;
  if (!little && !big) {
    return const _ExifSummary();
  }

  int u16(int at) => little ? bytes[at] | (bytes[at + 1] << 8) : (bytes[at] << 8) | bytes[at + 1];
  int u32(int at) => little
      ? bytes[at] | (bytes[at + 1] << 8) | (bytes[at + 2] << 16) | (bytes[at + 3] << 24)
      : (bytes[at] << 24) | (bytes[at + 1] << 16) | (bytes[at + 2] << 8) | bytes[at + 3];

  final int ifd0 = tiffStart + u32(tiffStart + 4);
  if (ifd0 + 2 > limit) {
    return const _ExifSummary();
  }
  final int count = u16(ifd0);
  int? orientation;
  bool hasGps = false;

  for (int e = 0; e < count; e++) {
    final int entry = ifd0 + 2 + e * 12;
    if (entry + 12 > limit) {
      break;
    }
    final int tag = u16(entry);
    if (tag == _kExifTagOrientation) {
      final int value = u16(entry + 8);
      if (value >= 1 && value <= 8) {
        orientation = value;
      }
    } else if (tag == 0x8825) {
      hasGps = true;
    }
  }
  return _ExifSummary(orientation: orientation, hasGps: hasGps);
}

/// Faqat `Orientation` dan iborat minimal `APP1` EXIF segmenti (34 bayt).
Uint8List _buildMinimalExif(int orientation) {
  final ByteData tiff = ByteData(26);
  // "II", 42, IFD0 offset = 8.
  tiff
    ..setUint8(0, 0x49)
    ..setUint8(1, 0x49)
    ..setUint16(2, 42, Endian.little)
    ..setUint32(4, 8, Endian.little)
    // IFD0: 1 ta yozuv.
    ..setUint16(8, 1, Endian.little)
    ..setUint16(10, _kExifTagOrientation, Endian.little)
    ..setUint16(12, 3, Endian.little) // SHORT
    ..setUint32(14, 1, Endian.little)
    ..setUint16(18, orientation, Endian.little)
    ..setUint16(20, 0, Endian.little)
    ..setUint32(22, 0, Endian.little); // keyingi IFD yo'q

  final int payload = _kExifHeader.length + tiff.lengthInBytes;
  final BytesBuilder builder = BytesBuilder(copy: false)
    ..add(<int>[_kMarkerPrefix, _kApp1, ((payload + 2) >> 8) & 0xFF, (payload + 2) & 0xFF])
    ..add(_kExifHeader)
    ..add(tiff.buffer.asUint8List());
  return builder.toBytes();
}
