// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_permission.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermission
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoPermission {
  @override
  final String? description;
  @override
  final String? key;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermission(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermission._(
      {this.description, this.key})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermission rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoPermission &&
        description == other.description &&
        key == other.key;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoPermission')
          ..add('description', description)
          ..add('key', key))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainUsersDtoPermission,
            GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermission? _$v;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoPermission._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _description = $v.description;
      _key = $v.key;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainUsersDtoPermission other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermission;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermission build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermission _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermission._(
          description: description,
          key: key,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
