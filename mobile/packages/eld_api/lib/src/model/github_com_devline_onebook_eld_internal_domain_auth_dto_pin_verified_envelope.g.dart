// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_pin_verified_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedEnvelope',
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
