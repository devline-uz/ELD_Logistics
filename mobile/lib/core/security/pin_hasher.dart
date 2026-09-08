/// Lokal PIN hash (M155, tz-mobile §17.3).
///
/// * `PBKDF2-HMAC-SHA256`, **100 000** iteratsiya (Argon2id uchun sof Dart
///   implementatsiyasi yo'q — TZ ruxsat bergan muqobil);
/// * qurilmaga xos **32-baytli** tasodifiy salt (`SecureVault.newPinSalt()`,
///   `Random.secure()`);
/// * solishtirish **doimiy vaqtda** — `==` taqiq;
/// * PIN ochiq matnda hech qayerda saqlanmaydi va logga chiqmaydi (M159).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

abstract final class PinHasher {
  const PinHasher._();

  /// M155: ≥100 000 iteratsiya.
  static const int iterations = 100000;

  /// SHA-256 chiqishi bilan bir xil — 32 bayt.
  static const int keyLength = 32;

  /// PIN + salt (base64) → base64 hash.
  static String hash({required String pin, required String salt}) {
    final Uint8List key = _pbkdf2(
      password: utf8.encode(pin),
      salt: base64Decode(salt),
      iterations: iterations,
      keyLength: keyLength,
    );
    return base64Encode(key);
  }

  /// Doimiy vaqtda solishtirish (timing attack'ga qarshi).
  static bool verify({required String pin, required String salt, required String expectedHash}) =>
      constantTimeEquals(hash(pin: pin, salt: salt), expectedHash);

  /// Ikki base64 qatorni doimiy vaqtda solishtiradi.
  static bool constantTimeEquals(String a, String b) {
    final List<int> left = utf8.encode(a);
    final List<int> right = utf8.encode(b);
    // Uzunliklar farqi ham natijaga qo'shiladi, lekin erta `return` yo'q.
    int diff = left.length ^ right.length;
    final int max = left.length > right.length ? left.length : right.length;
    for (int i = 0; i < max; i++) {
      final int l = i < left.length ? left[i] : 0;
      final int r = i < right.length ? right[i] : 0;
      diff |= l ^ r;
    }
    return diff == 0;
  }

  /// RFC 8018 PBKDF2 (HMAC-SHA256).
  static Uint8List _pbkdf2({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int keyLength,
  }) {
    final Hmac hmac = Hmac(sha256, password);
    const int blockSize = 32; // SHA-256
    final int blocks = (keyLength + blockSize - 1) ~/ blockSize;
    final Uint8List output = Uint8List(blocks * blockSize);

    for (int block = 1; block <= blocks; block++) {
      final Uint8List blockIndex = Uint8List(4)
        ..[0] = (block >> 24) & 0xff
        ..[1] = (block >> 16) & 0xff
        ..[2] = (block >> 8) & 0xff
        ..[3] = block & 0xff;

      List<int> u = hmac.convert(<int>[...salt, ...blockIndex]).bytes;
      final Uint8List accumulator = Uint8List.fromList(u);
      for (int i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (int j = 0; j < blockSize; j++) {
          accumulator[j] ^= u[j];
        }
      }
      output.setRange((block - 1) * blockSize, block * blockSize, accumulator);
    }
    return Uint8List.sublistView(output, 0, keyLength);
  }
}
