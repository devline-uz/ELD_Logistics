/// Joriy sessiyaning **domenga tayyor** kesimi (#B-24).
///
/// `logs`, `certify`, `log_edits`, `unidentified` va `inspection` modullari
/// haydovchi/unit/Home Terminal ma'lumotini shu yagona manbadan oladi —
/// ilgari bu `features/logs/.../logs_providers.dart#LogsSession` da edi va
/// qatlam qoidasini (M5) buzardi: uchta modul begona modulning
/// `presentation` papkasiga bog'langan edi.
///
/// [SessionProfile] — `kv_settings` ustidagi xom ko'rinish; [SessionContext]
/// esa undan olingan, `null` bo'lmaydigan `homeTerminalTz` bilan to'ldirilgan
/// kesim. Maydonlar takrorlanmaydi: yagona konvertatsiya
/// [SessionContext.fromProfile] da.
///
/// Nom `features/auth/domain/DriverSession` (M-58 «my devices» qatori) bilan
/// chalkashmasligi uchun `SessionContext` deb atalgan — bu ikki tamoman
/// boshqa tushuncha.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../time/day_boundary.dart';
import 'session_profile.dart';

class SessionContext {
  const SessionContext({
    required this.driverId,
    this.driverName,
    this.unitId,
    this.unitNumber,
    this.homeTerminal,
    this.homeTerminalTz = kFallbackTimeZone,
  });

  /// [SessionProfile] dan kesim; bo'sh TZ — `UTC` (kun chegarasi hech qachon
  /// qurilma zonasiga tushmasin, M42).
  factory SessionContext.fromProfile(SessionProfile profile) => SessionContext(
    driverId: profile.driverId,
    driverName: profile.driverName,
    unitId: profile.unitId,
    unitNumber: profile.unitNumber,
    homeTerminal: profile.homeTerminalAddress,
    homeTerminalTz: (profile.homeTerminalTz?.isNotEmpty ?? false)
        ? profile.homeTerminalTz!
        : kFallbackTimeZone,
  );

  final String driverId;
  final String? driverName;
  final String? unitId;
  final String? unitNumber;

  /// Kanonik `Home Terminal` manzili (M97).
  final String? homeTerminal;

  /// IANA zona nomi — **kun chegarasi faqat shundan** hisoblanadi (M42).
  final String homeTerminalTz;

  @override
  bool operator ==(Object other) =>
      other is SessionContext &&
      other.driverId == driverId &&
      other.driverName == driverName &&
      other.unitId == unitId &&
      other.unitNumber == unitNumber &&
      other.homeTerminal == homeTerminal &&
      other.homeTerminalTz == homeTerminalTz;

  @override
  int get hashCode =>
      Object.hash(driverId, driverName, unitId, unitNumber, homeTerminal, homeTerminalTz);

  /// PII logga chiqmaydi (M159).
  @override
  String toString() => 'SessionContext($driverId)';
}

/// Sessiya kesimi — `kv_settings` dan avtomatik hosil bo'ladi (bootstrap
/// override qilmaydi; testlar `overrideWithValue` bilan almashtiradi).
final Provider<SessionContext> sessionContextProvider = Provider<SessionContext>(
  (Ref ref) => SessionContext.fromProfile(ref.watch(sessionProfileProvider)),
);

/// Home Terminal IANA zonasi — kun chegarasi kerak bo'lgan har joyda (M42).
final Provider<String> homeTerminalTzProvider = Provider<String>(
  (Ref ref) => ref.watch(sessionContextProvider).homeTerminalTz,
);
