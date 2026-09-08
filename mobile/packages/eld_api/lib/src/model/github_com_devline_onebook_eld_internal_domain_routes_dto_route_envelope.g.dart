// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope
    extends GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainRoutesDtoRoute? data;

  factory _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope,
            GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteEnvelope',
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
