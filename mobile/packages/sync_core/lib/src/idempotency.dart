/// UUID v4 formatting for `client_event_id` (M19) and `Idempotency-Key` (M33).
library;

/// Formats 16 random [bytes] as a canonical lower-case UUID v4.
///
/// The caller supplies the entropy (`Random.secure()` in the app, a fixed list
/// in tests) so this package stays pure and deterministic.
String formatUuidV4(List<int> bytes) {
  if (bytes.length != 16) {
    throw ArgumentError.value(bytes.length, 'bytes.length', 'must be exactly 16');
  }
  final List<int> b = List<int>.of(bytes);
  for (int i = 0; i < 16; i++) {
    if (b[i] < 0 || b[i] > 255) {
      throw ArgumentError.value(b[i], 'bytes[$i]', 'must be a byte (0..255)');
    }
  }
  b[6] = (b[6] & 0x0f) | 0x40; // version 4
  b[8] = (b[8] & 0x3f) | 0x80; // RFC 4122 variant

  final StringBuffer out = StringBuffer();
  for (int i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) {
      out.write('-');
    }
    out.write(b[i].toRadixString(16).padLeft(2, '0'));
  }
  return out.toString();
}
