/// `PlatformLocationService` — `MethodChannel('eld/location')` +
/// `EventChannel('eld/location/stream')`.
///
/// Native tomon: Android `FusedLocationProviderClient` (foreground service
/// ichida), iOS `CLLocationManager` (`allowsBackgroundLocationUpdates = true`,
/// `pausesLocationUpdatesAutomatically = false`, §10.4).
library;

import 'dart:async';

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

  @override
  Future<void> start(LocationProfile profile) async {
    rememberProfile(profile);
    if (!profile.isActive) {
      await stop();
      return;
    }
    await _channel.invokeMethod<void>('start', <String, Object?>{
      'interval_ms': profile.interval.inMilliseconds,
      'distance_filter_m': profile.distanceFilterM,
      // M73: haydash rejimida fon yangilanishi hech qachon to'xtatilmaydi.
      'background': true,
    });
    _sub ??= _stream.receiveBroadcastStream().listen(_onEvent);
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    rememberProfile(LocationProfile.off);
    await _channel.invokeMethod<void>('stop');
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
