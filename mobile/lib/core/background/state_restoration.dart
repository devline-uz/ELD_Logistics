/// iOS BLE state restoration (tz-mobile §10.4, M74) va Android FGS qayta
/// ishga tushishi — **yagona** tiklanish nuqtasi.
///
/// ```
/// iOS   : CBCentralManagerOptionRestoreIdentifierKey → tizim ilovani BLE
///         hodisasida uyg'otadi → onRestored()
/// Android: FGS `allowAutoRestart` → EldTaskMessage.restarted → onRestored()
/// ```
/// **M74 [MUST]:** `onRestored` ichida ilova **darhol** sync scheduler'ni
/// ishga tushiradi va oxirgi holatni Drift'dan tiklaydi.
library;

import 'dart:async';

/// Tiklanish sababi.
enum RestoreReason {
  /// iOS: `CBCentralManager` state restoration.
  iosBleRestore,

  /// Android: foreground service qayta ishga tushdi.
  androidServiceRestart,

  /// Ilova odatiy tarzda ishga tushdi (sovuq start).
  coldStart,
}

/// Tiklanish koordinatori.
///
/// Sinf platformadan mustaqil: platforma signali [notify] orqali beriladi,
/// shuning uchun to'liq unit test qilinadi.
class StateRestorationCoordinator {
  StateRestorationCoordinator({required this._onRestored});

  final Future<void> Function(RestoreReason) _onRestored;

  final StreamController<RestoreReason> _events = StreamController<RestoreReason>.broadcast();

  /// Qayta ishlangan sabablar — takroriy signal ikkinchi marta ishlatilmaydi.
  final Set<RestoreReason> _handled = <RestoreReason>{};

  Stream<RestoreReason> get events => _events.stream;

  /// Qayta ishlangan tiklanishlar soni (test).
  int get handledCount => _handled.length;

  bool handled(RestoreReason reason) => _handled.contains(reason);

  /// Platforma signali. Bir xil sabab ikkinchi marta ishlov bermaydi —
  /// sync scheduler ikki marta ishga tushmaydi.
  Future<void> notify(RestoreReason reason) async {
    if (!_handled.add(reason)) {
      return;
    }
    if (!_events.isClosed) {
      _events.add(reason);
    }
    // M74: kechiktirmasdan — `unawaited` emas, kutiladi.
    await _onRestored(reason);
  }

  /// Yangi sessiya (logout/login) — hisob tozalanadi.
  void reset() => _handled.clear();

  Future<void> dispose() => _events.close();
}
