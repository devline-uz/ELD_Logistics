// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_app_config_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfig? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoAppConfigEnvelope',
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
