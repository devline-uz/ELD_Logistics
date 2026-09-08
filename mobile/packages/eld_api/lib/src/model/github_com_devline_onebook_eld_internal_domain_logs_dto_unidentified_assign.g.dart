// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_assign.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign {
  @override
  final String driverId;
  @override
  final String note;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign._(
      {required this.driverId, required this.note})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign &&
        driverId == other.driverId &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign')
          ..add('driverId', driverId)
          ..add('note', note))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign,
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign._(
          driverId: BuiltValueNullFieldError.checkNotNull(
              driverId,
              r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign',
              'driverId'),
          note: BuiltValueNullFieldError.checkNotNull(
              note,
              r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign',
              'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
