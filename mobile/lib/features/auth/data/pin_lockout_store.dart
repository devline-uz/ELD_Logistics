/// PIN urinishlari va blok muddatini **secure storage** da saqlaydi (§4.5):
/// ilovani o'chirib yoqish bilan blok tiklanmaydi.
///
/// Kalitlar `core/security/VaultKeys` dan olinadi — `SecureVault` bu ikki kalit
/// uchun hozircha metod ochmagan (TODO(core): `SecureVault` ga `readPinLockout`/
/// `writePinLockout` qo'shilsa, bu klass o'sha metodlarga o'tadi).
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/security/secure_vault.dart';
import '../domain/auth_policies.dart';

class PinLockoutStore {
  PinLockoutStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          );

  final FlutterSecureStorage _storage;

  Future<PinLockoutState> read() async {
    final String? attempts = await _storage.read(key: VaultKeys.pinFailedAttempts);
    final String? until = await _storage.read(key: VaultKeys.pinLockUntil);
    return PinLockoutState(
      failedAttempts: int.tryParse(attempts ?? '') ?? 0,
      lockedUntil: until == null ? null : DateTime.tryParse(until)?.toUtc(),
    );
  }

  Future<void> write(PinLockoutState state) async {
    await _storage.write(key: VaultKeys.pinFailedAttempts, value: '${state.failedAttempts}');
    final DateTime? until = state.lockedUntil;
    if (until == null) {
      await _storage.delete(key: VaultKeys.pinLockUntil);
    } else {
      await _storage.write(key: VaultKeys.pinLockUntil, value: until.toUtc().toIso8601String());
    }
  }

  Future<void> clear() => write(PinLockoutPolicy.cleared);
}
