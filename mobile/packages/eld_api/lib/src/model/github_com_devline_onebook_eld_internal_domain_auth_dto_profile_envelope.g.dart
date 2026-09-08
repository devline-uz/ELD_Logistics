// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_profile_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoProfile? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoProfileBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoProfileEnvelope',
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
