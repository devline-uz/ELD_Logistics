/// Ikki slotli sessiya holatining doimiy saqlagichi (`SecureVault` ustida).
///
/// JSON `flutter_secure_storage` da yotadi (M9): Keychain
/// `first_unlock_this_device` / Android Keystore. Ochiq prefs ishlatilmaydi,
/// chunki bu yerda `driver_name` (PII) va `session_id` bor.
library;

import 'dart:convert';

import '../../../core/security/secure_vault.dart';
import '../domain/session_state.dart';

class SessionStore {
  const SessionStore(this._vault);

  final SecureVault _vault;

  /// Diskdagi holat. Buzilgan JSON — chiqib ketilmaydi, bo'sh holat qaytadi.
  Future<DualSessionState> read() async {
    final String? raw = await _vault.readSessionSlots();
    if (raw == null || raw.isEmpty) {
      return const DualSessionState.signedOut();
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        return const DualSessionState.signedOut();
      }
      return DualSessionState.fromJson(decoded);
    } on FormatException {
      return const DualSessionState.signedOut();
    }
  }

  Future<void> write(DualSessionState state) async {
    if (state.isSignedOut) {
      await _vault.deleteSessionSlots();
      return;
    }
    await _vault.writeSessionSlots(jsonEncode(state.toJson()));
  }
}
