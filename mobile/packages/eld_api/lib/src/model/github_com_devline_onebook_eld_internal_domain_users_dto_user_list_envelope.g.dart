// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_user_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainUsersDtoUser>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope,
            GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoUser>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoUser> get data =>
      _$this._data ??=
          ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoUser>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoUser>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope._(
            data: _data?.build(),
            meta: _meta?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
        _$failedField = 'meta';
        _meta?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserListEnvelope',
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
