/// `PlatformLocationService` — `MethodChannel('eld/location')` +
/// `EventChannel('eld/location/stream')`.
///
/// Native tomon: Android `FusedLocationProviderClient` (foreground service
/// ichida), iOS `CLLocationManager` (`allowsBackgroundLocationUpdates = true`,
/// `pausesLocationUpdatesAutomatically = false`, §10.4).
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'location_models.dart';
import 'location_service.dart';

const MethodChannel kLocationChannel = MethodChannel('eld/location');
const EventChannel kLocationStreamChannel = EventChannel('eld/location/stream');

final class PlatformLocationService extends BaseLocationService {
  PlatformLocationService({required super.now, MethodChannel? channel, EventChannel? stream})
    : _channel = channel ?? kLocationChannel,
      _stream = stream ?? kLocationStreamChannel;

  final MethodChannel _channel;
  final EventChannel _stream;

  StreamSubscription<Object?>? _sub;

  /// Platforma kanali ro'yxatdan o'tmaganmi (#B-2).
  ///
  /// iOS/Android build'ida `eld/location` implementatsiyasi bo'lmasa yoki test
  /// muhitida ishlansa `MissingPluginException` keladi. Bunda xizmat **jimgina
  /// degrade** bo'ladi: GPS yo'q, lekin logout/login oqimi yiqilmaydi.
  bool get unsupported => _unsupported;
  bool _unsupported = false;

  @override
  Future<void> start(LocationProfile profile) async {
    rememberProfile(profile);
    if (!profile.isActive) {
      await stop();
      return;
    }
    final bool ok = await _invoke('start', <String, Object?>{
      'interval_ms': profile.interval.inMilliseconds,
      'distance_filter_m': profile.distanceFilterM,
      // M73: haydash rejimida fon yangilanishi hech qachon to'xtatilmaydi.
      'background': true,
    });
    if (!ok) {
      return;
    }
    _sub ??= _stream.receiveBroadcastStream().listen(_onEvent, onError: _onStreamError);
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    rememberProfile(LocationProfile.off);
    await _invoke('stop');
  }

  /// Kanal chaqiruvi — hech qachon istisno tashlamaydi.
  ///
  /// `true` — platforma bajardi; `false` — kanal yo'q yoki platforma xato
  /// qaytardi (log'ga PII yozilmaydi, faqat metod nomi).
  Future<bool> _invoke(String method, [Object? arguments]) async {
    if (_unsupported) {
      return false;
    }
    try {
      await _channel.invokeMethod<void>(method, arguments);
      return true;
    } on MissingPluginException catch (_) {
      _unsupported = true;
      developer.log(
        'location channel unavailable, degrading: $method',
        name: 'eld.location',
        level: 900,
      );
      return false;
    } on PlatformException catch (error) {
      developer.log(
        'location channel error on $method: ${error.code}',
        name: 'eld.location',
        level: 900,
      );
      return false;
    } on Object catch (_) {
      // Kanal umuman mavjud bo'lmagan muhit (binding yo'q, desktop) —
      // chiqish/kirish oqimi GPS sababli hech qachon yiqilmasligi kerak.
      return false;
    }
  }

  void _onStreamError(Object error) {
    if (error is MissingPluginException) {
      _unsupported = true;
    }
    developer.log('location stream error', name: 'eld.location', level: 900);
  }

  void _onEvent(Object? event) {
    if (event is! Map<Object?, Object?>) {
      return;
    }
    final double? lat = _double(event['lat']);
    final double? lng = _double(event['lng']);
    if (lat == null || lng == null) {
      return;
    }
    publish(
      LocationFix(
        at: _time(event['ts']) ?? nowUtc(),
        lat: lat,
        lng: lng,
        accuracyM: _double(event['accuracy_m']) ?? kLocationAccuracyLimitM,
        speedKmh: _double(event['speed_kmh']),
        headingDeg: _double(event['heading_deg']),
        altitudeM: _double(event['altitude_m']),
      ),
    );
  }

  static double? _double(Object? value) => switch (value) {
    final num n => n.toDouble(),
    _ => null,
  };

  static DateTime? _time(Object? value) => switch (value) {
    final int ms => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
    _ => null,
  };
}
