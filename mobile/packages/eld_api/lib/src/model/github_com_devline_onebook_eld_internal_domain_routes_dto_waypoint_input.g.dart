// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_routes_dto_waypoint_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput
    extends GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput {
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String text;

  factory _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput._(
      {this.lat, this.lng, required this.text})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput &&
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
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput')
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('text', text))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput,
            GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder() {
    GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder
      get _$this {
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
      GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInputBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput._(
          lat: lat,
          lng: lng,
          text: BuiltValueNullFieldError.checkNotNull(
              text,
              r'GithubComDevlineOnebookEldInternalDomainRoutesDtoWaypointInput',
              'text'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
