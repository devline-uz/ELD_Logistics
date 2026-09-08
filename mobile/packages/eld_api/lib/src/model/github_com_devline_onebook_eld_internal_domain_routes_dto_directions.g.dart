// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_routes_dto_directions.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nominatim =
    const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
        ._('nominatim');
const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_photon =
    const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
        ._('photon');
const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_google =
    const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
        ._('google');
const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nop =
    const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
        ._('nop');
const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumValueOf(
        String name) {
  switch (name) {
    case 'nominatim':
      return _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nominatim;
    case 'photon':
      return _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_photon;
    case 'google':
      return _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_google;
    case 'nop':
      return _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nop;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum>
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum>(const <GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum>[
  _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nominatim,
  _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_photon,
  _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_google,
  _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_nop,
  _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum>
    _$githubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'nominatim': 'nominatim',
    'photon': 'photon',
    'google': 'google',
    'nop': 'nop',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'nominatim': 'nominatim',
    'photon': 'photon',
    'google': 'google',
    'nop': 'nop',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections
    extends GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections {
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint? destination;
  @override
  final int? distanceM;
  @override
  final int? durationS;
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint? origin;
  @override
  final String? polyline;
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum?
      provider;
  @override
  final String? routeId;

  factory _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections._(
      {this.destination,
      this.distanceM,
      this.durationS,
      this.origin,
      this.polyline,
      this.provider,
      this.routeId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections &&
        destination == other.destination &&
        distanceM == other.distanceM &&
        durationS == other.durationS &&
        origin == other.origin &&
        polyline == other.polyline &&
        provider == other.provider &&
        routeId == other.routeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, durationS.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, polyline.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections')
          ..add('destination', destination)
          ..add('distanceM', distanceM)
          ..add('durationS', durationS)
          ..add('origin', origin)
          ..add('polyline', polyline)
          ..add('provider', provider)
          ..add('routeId', routeId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections,
            GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections? _$v;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder?
      _destination;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder
      get destination => _$this._destination ??=
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder();
  set destination(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder?
              destination) =>
      _$this._destination = destination;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  int? _durationS;
  int? get durationS => _$this._durationS;
  set durationS(int? durationS) => _$this._durationS = durationS;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder? _origin;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder get origin =>
      _$this._origin ??=
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder();
  set origin(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder?
              origin) =>
      _$this._origin = origin;

  String? _polyline;
  String? get polyline => _$this._polyline;
  set polyline(String? polyline) => _$this._polyline = polyline;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum?
      _provider;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum?
      get provider => _$this._provider;
  set provider(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsProviderEnum?
              provider) =>
      _$this._provider = provider;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder() {
    GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _destination = $v.destination?.toBuilder();
      _distanceM = $v.distanceM;
      _durationS = $v.durationS;
      _origin = $v.origin?.toBuilder();
      _polyline = $v.polyline;
      _provider = $v.provider;
      _routeId = $v.routeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections _build() {
    _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections._(
            destination: _destination?.build(),
            distanceM: distanceM,
            durationS: durationS,
            origin: _origin?.build(),
            polyline: polyline,
            provider: provider,
            routeId: routeId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'destination';
        _destination?.build();

        _$failedField = 'origin';
        _origin?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
