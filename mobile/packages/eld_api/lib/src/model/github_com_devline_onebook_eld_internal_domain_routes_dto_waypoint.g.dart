// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_routes_dto_waypoint.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint
    extends GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint {
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String? text;

  factory _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint._(
      {this.lat, this.lng, this.text})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint &&
        lat == other.lat &&
        lng == other.lng &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint')
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('text', text))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint,
            GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder() {
    GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypoint._(
          lat: lat,
          lng: lng,
          text: text,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
