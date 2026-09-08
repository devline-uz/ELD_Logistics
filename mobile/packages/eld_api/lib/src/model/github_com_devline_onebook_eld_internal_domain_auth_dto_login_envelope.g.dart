// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_login_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResult? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope._({this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoLoginResultBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginEnvelope',
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
