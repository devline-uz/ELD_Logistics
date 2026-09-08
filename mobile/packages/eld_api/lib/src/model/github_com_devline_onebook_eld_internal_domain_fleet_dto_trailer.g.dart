// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_trailer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer {
  @override
  final DateTime? createdAt;
  @override
  final String? id;
  @override
  final String? notes;
  @override
  final String? number;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer._(
      {this.createdAt, this.id, this.notes, this.number, this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer &&
        createdAt == other.createdAt &&
        id == other.id &&
        notes == other.notes &&
        number == other.number &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer')
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('notes', notes)
          ..add('number', number)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer,
            GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _id = $v.id;
      _notes = $v.notes;
      _number = $v.number;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoTrailerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainFleetDtoTrailer._(
          createdAt: createdAt,
          id: id,
          notes: notes,
          number: number,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
