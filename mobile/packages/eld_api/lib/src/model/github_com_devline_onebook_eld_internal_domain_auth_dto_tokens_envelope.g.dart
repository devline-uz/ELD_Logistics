// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_tokens_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoTokens? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope._({this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoTokensBuilder? data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTokensEnvelope',
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
