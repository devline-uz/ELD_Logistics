// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_branch_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate {
  @override
  final String? address;
  @override
  final String name;
  @override
  final String? timezone;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate._(
      {this.address, required this.name, this.timezone})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate &&
        address == other.address &&
        name == other.name &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate')
          ..add('address', address)
          ..add('name', name)
          ..add('timezone', timezone))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate? _$v;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address;
      _name = $v.name;
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate._(
          address: address,
          name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchCreate',
              'name'),
          timezone: timezone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
