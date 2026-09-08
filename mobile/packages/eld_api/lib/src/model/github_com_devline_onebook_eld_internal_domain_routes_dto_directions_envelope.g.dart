// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_routes_dto_directions_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope
    extends GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoDirections? data;

  factory _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope,
            GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoDirectionsEnvelope',
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
