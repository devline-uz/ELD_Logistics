/// `RequestOptions.extra` uchun tipli kalitlar.
library;

import 'package:dio/dio.dart';

import '../security/secure_vault.dart';

abstract final class RequestExtra {
  const RequestExtra._();

  /// So'rov qaysi haydovchi slotidan yuborilmoqda.
  static const String slot = 'eld.slot';

  /// `true` bo'lsa `Authorization` qo'shilmaydi (login, refresh, app/config).
  static const String anonymous = 'eld.anonymous';

  /// 401 dan keyin bir marta takrorlangani belgisi (cheksiz siklni oldini oladi).
  static const String retriedAfterRefresh = 'eld.retried_after_refresh';

  /// Idempotent so'rov — `Idempotency-Key` qo'shiladi va retry ruxsat etiladi.
  static const String idempotent = 'eld.idempotent';

  /// Oldindan berilgan `Idempotency-Key` (outbox yozuvining `client_id` si).
  static const String idempotencyKey = 'eld.idempotency_key';

  /// Retry urinishlari hisoblagichi.
  static const String retryCount = 'eld.retry_count';
}

extension RequestOptionsX on RequestOptions {
  DriverSlot get slot => extra[RequestExtra.slot] is DriverSlot
      ? extra[RequestExtra.slot] as DriverSlot
      : DriverSlot.primary;

  bool get isAnonymous => extra[RequestExtra.anonymous] == true;

  bool get retriedAfterRefresh => extra[RequestExtra.retriedAfterRefresh] == true;

  /// GET/HEAD har doim idempotent; POST uchun aniq belgilanadi.
  bool get isIdempotent {
    if (extra[RequestExtra.idempotent] == true) {
      return true;
    }
    final String verb = method.toUpperCase();
    return verb == 'GET' || verb == 'HEAD';
  }

  String? get presetIdempotencyKey => extra[RequestExtra.idempotencyKey] is String
      ? extra[RequestExtra.idempotencyKey] as String
      : null;

  int get retryCount =>
      extra[RequestExtra.retryCount] is int ? extra[RequestExtra.retryCount] as int : 0;
}
