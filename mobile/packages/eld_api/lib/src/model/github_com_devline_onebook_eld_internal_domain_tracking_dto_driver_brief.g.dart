// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_driver_brief.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief {
  @override
  final String? firstName;
  @override
  final String? id;
  @override
  final String? lastName;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief._(
      {this.firstName, this.id, this.lastName})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief &&
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
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief')
          ..add('firstName', firstName)
          ..add('id', id)
          ..add('lastName', lastName))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder
      get _$this {
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
      GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBriefBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainTrackingDtoDriverBrief._(
          firstName: firstName,
          id: id,
          lastName: lastName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
