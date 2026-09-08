// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_company_dto_branch_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate
    extends GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate {
  @override
  final String? address;
  @override
  final String? name;
  @override
  final String? timezone;

  factory _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate._(
      {this.address, this.name, this.timezone})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate &&
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
            r'GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate')
          ..add('address', address)
          ..add('name', name)
          ..add('timezone', timezone))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate,
            GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate? _$v;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder
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
      GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainCompanyDtoBranchUpdate._(
          address: address,
          name: name,
          timezone: timezone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
