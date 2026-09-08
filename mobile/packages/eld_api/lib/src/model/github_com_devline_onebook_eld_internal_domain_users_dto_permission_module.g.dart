// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_permission_module.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule {
  @override
  final String? label;
  @override
  final String? module;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainUsersDtoPermission>?
      permissions;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule._(
      {this.label, this.module, this.permissions})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule &&
        label == other.label &&
        module == other.module &&
        permissions == other.permissions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, module.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule')
          ..add('label', label)
          ..add('module', module)
          ..add('permissions', permissions))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule,
            GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule? _$v;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _module;
  String? get module => _$this._module;
  set module(String? module) => _$this._module = module;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoPermission>?
      _permissions;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainUsersDtoPermission>
      get permissions => _$this._permissions ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainUsersDtoPermission>();
  set permissions(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainUsersDtoPermission>?
              permissions) =>
      _$this._permissions = permissions;

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _label = $v.label;
      _module = $v.module;
      _permissions = $v.permissions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModuleBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule._(
            label: label,
            module: module,
            permissions: _permissions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        _permissions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoPermissionModule',
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
