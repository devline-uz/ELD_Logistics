// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_catalog_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate {
  @override
  final String? notes;
  @override
  final String? number;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate._(
      {this.notes, this.number})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate &&
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
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate')
          ..add('notes', notes)
          ..add('number', number))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate,
            GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate? _$v;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder
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
      GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainFleetDtoCatalogUpdate._(
          notes: notes,
          number: number,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
