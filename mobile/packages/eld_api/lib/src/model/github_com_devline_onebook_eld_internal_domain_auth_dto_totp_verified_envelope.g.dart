// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_verified_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerified? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPVerifiedEnvelope',
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
