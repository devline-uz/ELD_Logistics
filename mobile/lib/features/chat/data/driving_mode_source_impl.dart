/// [DrivingModeSource] ning vaqtinchalik implementatsiyasi (M140/M141).
///
/// TODO(M-12): `features/duty_status` tayyor bo'lgach shu sinf o'rniga joriy
/// duty status oqimini o'qiydigan manba qo'yiladi — port o'zgarmaydi.
library;

import 'dart:async';

import '../domain/chat_ports.dart';

class InMemoryDrivingModeSource implements DrivingModeSource {
  InMemoryDrivingModeSource({this._isDriving = false});

  bool _isDriving;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  bool get isDriving => _isDriving;

  @override
  Stream<bool> watch() async* {
    yield _isDriving;
    yield* _controller.stream;
  }

  @override
  void forceDriving() => set(isDriving: true);

  /// Duty status o'zgarganda chaqiriladi.
  void set({required bool isDriving}) {
    if (_isDriving == isDriving) {
      return;
    }
    _isDriving = isDriving;
    if (!_controller.isClosed) {
      _controller.add(isDriving);
    }
  }

  Future<void> dispose() => _controller.close();
}
