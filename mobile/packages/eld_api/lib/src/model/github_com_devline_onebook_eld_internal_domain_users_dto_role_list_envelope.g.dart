// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_role_list_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainUsersDtoRole>? data;
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoMeta? meta;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope._(
      {this.data, this.meta})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope,
            GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoRole>? _data;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoRole> get data =>
      _$this._data ??=
          ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoRole>();
  set data(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoRole>?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder? _meta;
  GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder get meta =>
      _$this._meta ??=
          GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder();
  set meta(GithubComDevlineOnebookEldInternalDomainUsersDtoMetaBuilder? meta) =>
      _$this._meta = meta;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope._(
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleListEnvelope',
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
