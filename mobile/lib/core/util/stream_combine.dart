/// Bir nechta Drift `watch()` oqimini birlashtirish (`rxdart` pubspec'da yo'q).
///
/// Har manba kamida bitta qiymat bergandan keyin natija chiqadi; keyingi
/// har qanday o'zgarishda yangilanadi. Obuna bekor qilinganda barcha ichki
/// obunalar yopiladi (test'da osilib qolgan taymer bo'lmasligi uchun).
library;

import 'dart:async';

Stream<R> combineLatest2<A, B, R>(Stream<A> a, Stream<B> b, R Function(A a, B b) combine) =>
    _combine<R>(<Stream<Object?>>[
      a,
      b,
    ], (List<Object?> values) => combine(values[0] as A, values[1] as B));

Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  R Function(A a, B b, C c) combine,
) => _combine<R>(<Stream<Object?>>[
  a,
  b,
  c,
], (List<Object?> values) => combine(values[0] as A, values[1] as B, values[2] as C));

Stream<R> combineLatest4<A, B, C, D, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  Stream<D> d,
  R Function(A a, B b, C c, D d) combine,
) => _combine<R>(
  <Stream<Object?>>[a, b, c, d],
  (List<Object?> values) => combine(values[0] as A, values[1] as B, values[2] as C, values[3] as D),
);

Stream<R> _combine<R>(List<Stream<Object?>> sources, R Function(List<Object?> values) combine) {
  final List<Object?> latest = List<Object?>.filled(sources.length, null);
  final List<bool> seen = List<bool>.filled(sources.length, false);
  final List<StreamSubscription<Object?>> subs = <StreamSubscription<Object?>>[];
  late final StreamController<R> controller;

  void start() {
    for (int i = 0; i < sources.length; i++) {
      final int index = i;
      subs.add(
        sources[index].listen((Object? value) {
          latest[index] = value;
          seen[index] = true;
          if (!seen.contains(false)) {
            controller.add(combine(List<Object?>.of(latest)));
          }
        }, onError: controller.addError),
      );
    }
  }

  Future<void> stop() async {
    for (final StreamSubscription<Object?> sub in subs) {
      await sub.cancel();
    }
    subs.clear();
    await controller.close();
  }

  controller = StreamController<R>(onListen: start, onCancel: stop);
  return controller.stream;
}
