// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_totp_setup_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetup? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoTOTPSetupEnvelope',
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
