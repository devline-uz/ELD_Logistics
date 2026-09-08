// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_reset_password_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult?
      data;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope,
            GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordEnvelope',
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
