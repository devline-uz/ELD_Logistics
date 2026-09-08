/// `M-44 Profile` domen modeli.
///
/// `data` qatlami `GET /me` javobini shu tipga o'giradi — API modeli
/// `presentation` ga chiqmaydi (M5).
library;

import 'package:flutter/foundation.dart';

@immutable
class DriverProfile {
  const DriverProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.permissions,
    this.username,
    this.unitNumber,
    this.phone,
    this.licenseNumber,
    this.licenseState,
    this.pinSet = false,
  });

  final String id;
  final String firstName;
  final String lastName;

  /// Backend maskalangan qiymat qaytarishi mumkin (`j***e@example.com`).
  final String email;
  final String? username;

  /// Quyidagi to'rt maydon `GET /me` da **yo'q** (kontrakt bo'shlig'i, hisobotga
  /// qara) — mavjud bo'lmasa UI `N/A` ko'rsatadi.
  final String? unitNumber;
  final String? phone;
  final String? licenseNumber;
  final String? licenseState;

  final bool pinSet;

  /// RBAC ro'yxati — ekran bandlarini yashirish uchun.
  final List<String> permissions;

  String get fullName {
    final String name = <String>[firstName, lastName].where((String p) => p.isNotEmpty).join(' ');
    return name.isEmpty ? (username ?? '') : name;
  }

  /// Avatar bosh harflari (Figma: `AK`). Ism bo'sh bo'lsa `?`.
  String get initials {
    final List<String> parts = <String>[
      firstName,
      lastName,
    ].where((String p) => p.trim().isNotEmpty).toList(growable: false);
    if (parts.isEmpty) {
      final String source = username ?? email;
      return source.isEmpty ? '?' : source.characters(1);
    }
    return parts.map((String p) => p.characters(1)).join();
  }

  bool has(String permission) => permissions.contains(permission);

  @override
  bool operator ==(Object other) =>
      other is DriverProfile &&
      other.id == id &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.email == email &&
      other.username == username &&
      other.unitNumber == unitNumber &&
      other.phone == phone &&
      other.licenseNumber == licenseNumber &&
      other.licenseState == licenseState &&
      other.pinSet == pinSet &&
      listEquals(other.permissions, permissions);

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    email,
    username,
    unitNumber,
    phone,
    licenseNumber,
    licenseState,
    pinSet,
    Object.hashAll(permissions),
  );
}

extension on String {
  /// Birinchi [n] belgini katta harfda qaytaradi (emoji/diakritikaga xavfsiz emas,
  /// ism uchun yetarli).
  String characters(int n) => trim().isEmpty ? '?' : trim().substring(0, n).toUpperCase();
}
