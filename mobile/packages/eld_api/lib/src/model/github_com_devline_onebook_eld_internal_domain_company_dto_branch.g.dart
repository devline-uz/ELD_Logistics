// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_branch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch {
  @override
  final String? address;
  @override
  final DateTime? createdAt;
  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? timezone;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch._(
      {this.address,
      this.createdAt,
      this.id,
      this.name,
      this.timezone,
      this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch &&
        address == other.address &&
        createdAt == other.createdAt &&
        id == other.id &&
        name == other.name &&
        timezone == other.timezone &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch')
          ..add('address', address)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('name', name)
          ..add('timezone', timezone)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch? _$v;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _name = $v.name;
      _timezone = $v.timezone;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranch._(
          address: address,
          createdAt: createdAt,
          id: id,
          name: name,
          timezone: timezone,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
