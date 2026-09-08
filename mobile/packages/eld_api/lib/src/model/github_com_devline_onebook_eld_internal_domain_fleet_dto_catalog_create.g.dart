// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_catalog_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate {
  @override
  final String? notes;
  @override
  final String number;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate._(
      {this.notes, required this.number})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate &&
        notes == other.notes &&
        number == other.number;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate')
          ..add('notes', notes)
          ..add('number', number))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate,
            GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate? _$v;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _notes = $v.notes;
      _number = $v.number;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate._(
          notes: notes,
          number: BuiltValueNullFieldError.checkNotNull(
              number,
              r'GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogCreate',
              'number'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
