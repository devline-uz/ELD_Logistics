/// `AsyncValue` ni UI ga xavfsiz o'giruvchi yordamchi.
///
/// **Nega `AsyncValue.when` ishlatilmaydi:** Riverpod 3 da xatodan keyin
/// avtomatik retry `AsyncError(isLoading: true)` holatini beradi va `when`
/// uni **loading** deb ko'rsatadi — natijada `ErrorState` hech qachon
/// ko'rinmaydi. Bu yerda holat qo'lda tekshiriladi:
/// xato bor va qiymat yo'q → `error`, qiymat bor → `data`, aks holda `loading`.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget asyncView<T>(
  AsyncValue<T> value, {
  required Widget Function(T data) data,
  required Widget Function(Object error) error,
  required Widget loading,
}) {
  if (value.hasValue) {
    return data(value.value as T);
  }
  if (value.hasError) {
    return error(value.error!);
  }
  return loading;
}
