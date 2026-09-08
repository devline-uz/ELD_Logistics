// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_violation_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails {
  @override
  final int? daysUncertified;
  @override
  final int? limitMin;
  @override
  final String? note;
  @override
  final int? remainingMin;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails._(
      {this.daysUncertified, this.limitMin, this.note, this.remainingMin})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails &&
        daysUncertified == other.daysUncertified &&
        limitMin == other.limitMin &&
        note == other.note &&
        remainingMin == other.remainingMin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, daysUncertified.hashCode);
    _$hash = $jc(_$hash, limitMin.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, remainingMin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails')
          ..add('daysUncertified', daysUncertified)
          ..add('limitMin', limitMin)
          ..add('note', note)
          ..add('remainingMin', remainingMin))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails,
            GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails? _$v;

  int? _daysUncertified;
  int? get daysUncertified => _$this._daysUncertified;
  set daysUncertified(int? daysUncertified) =>
      _$this._daysUncertified = daysUncertified;

  int? _limitMin;
  int? get limitMin => _$this._limitMin;
  set limitMin(int? limitMin) => _$this._limitMin = limitMin;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  int? _remainingMin;
  int? get remainingMin => _$this._remainingMin;
  set remainingMin(int? remainingMin) => _$this._remainingMin = remainingMin;

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _daysUncertified = $v.daysUncertified;
      _limitMin = $v.limitMin;
      _note = $v.note;
      _remainingMin = $v.remainingMin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails._(
          daysUncertified: daysUncertified,
          limitMin: limitMin,
          note: note,
          remainingMin: remainingMin,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
