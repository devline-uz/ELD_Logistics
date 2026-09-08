// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_role_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoRole? data;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope._({this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope,
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder();
  set data(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleBuilder? data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope',
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
