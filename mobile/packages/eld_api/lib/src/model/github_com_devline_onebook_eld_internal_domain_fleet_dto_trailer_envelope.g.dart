// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_trailer_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer? data;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope,
            GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerEnvelope',
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
