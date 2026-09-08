// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_driver_brief.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief {
  @override
  final String? firstName;
  @override
  final String? id;
  @override
  final String? lastName;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief._(
      {this.firstName, this.id, this.lastName})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief &&
        firstName == other.firstName &&
        id == other.id &&
        lastName == other.lastName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief')
          ..add('firstName', firstName)
          ..add('id', id)
          ..add('lastName', lastName))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _id = $v.id;
      _lastName = $v.lastName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBriefBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDvirDtoDriverBrief._(
          firstName: firstName,
          id: id,
          lastName: lastName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
