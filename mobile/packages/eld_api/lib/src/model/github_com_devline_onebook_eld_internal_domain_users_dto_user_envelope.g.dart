// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_user_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoUser? data;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope._({this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope,
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder();
  set data(GithubComDevlineOnebookEldInternalDomainUsersDtoUserBuilder? data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope',
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
