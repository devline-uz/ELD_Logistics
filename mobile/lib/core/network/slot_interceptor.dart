/// So'rovga faol haydovchi slotini muhrlaydi (**M9**, tz-mobile §3.3).
///
/// Kabinada ikkita sessiya bo'lgani uchun har so'rov qaysi token to'plamidan
/// yuborilishini bilishi shart. Chaqiruvchi aniq slot bermagan bo'lsa
/// (`RequestExtra.slot`), **faol** slot qo'yiladi — `DR` va boshqa domen
/// yozuvlari faqat faol haydovchiga tegishli (`tz.md` Q45.1).
///
/// Interceptor `AuthInterceptor` dan **oldin** turishi shart: u
/// `options.slot` ni o'qib `Authorization` ni tanlaydi.
library;

import 'package:dio/dio.dart';

import '../security/active_slot.dart';
import '../security/secure_vault.dart';
import 'request_options_x.dart';

class SlotInterceptor extends Interceptor {
  const SlotInterceptor(this._holder);

  final ActiveSlotHolder _holder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra[RequestExtra.slot] is! DriverSlot) {
      options.extra[RequestExtra.slot] = _holder.value;
    }
    handler.next(options);
  }
}
