/// `flutter_secure_storage` platforma kanalining xotiradagi dublyori.
///
/// Keychain/Keystore ga umuman tegilmaydi: barcha kalit-qiymat oddiy
/// `Map` da yashaydi va test tugagach kanal tozalanadi.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// `flutter_secure_storage` 11.x kanali.
const MethodChannel kSecureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

/// Yozish rad etiladigan kalitlar (fail-closed stsenariylari uchun).
final Set<String> _failingKeys = <String>{};

/// Kanalni o'rnatadi va «disk» sifatida ishlatiladigan xaritani qaytaradi.
Map<String, String> installMockSecureStorage([Map<String, String>? initial]) {
  final Map<String, String> values = <String, String>{...?initial};
  _failingKeys.clear();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    kSecureStorageChannel,
    (MethodCall call) async {
      final Map<Object?, Object?> args =
          (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
      final String key = args['key'] as String? ?? '';
      switch (call.method) {
        case 'read':
          return values[key];
        case 'write':
          if (_failingKeys.contains(key)) {
            throw PlatformException(code: 'Storage', message: 'write failed (test)');
          }
          values[key] = args['value'] as String? ?? '';
          return null;
        case 'delete':
          values.remove(key);
          return null;
        case 'readAll':
          return Map<String, String>.from(values);
        case 'deleteAll':
          values.clear();
          return null;
        case 'containsKey':
          return values.containsKey(key);
      }
      return null;
    },
  );
  addTearDown(() {
    _failingKeys.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      kSecureStorageChannel,
      null,
    );
  });
  return values;
}

/// Berilgan kalitga yozishni `PlatformException` bilan rad etadi.
void failMockSecureStorageWrites(String key) => _failingKeys.add(key);
