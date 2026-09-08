// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_transfer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer {
  @override
  final String? comment;
  @override
  final Date? date;
  @override
  final String? driverId;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer._(
      {this.comment, this.date, this.driverId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer &&
        comment == other.comment &&
        date == other.date &&
        driverId == other.driverId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer')
          ..add('comment', comment)
          ..add('date', date)
          ..add('driverId', driverId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer,
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer? _$v;

  String? _comment;
  String? get comment => _$this._comment;
  set comment(String? comment) => _$this._comment = comment;

  Date? _date;
  Date? get date => _$this._date;
  set date(Date? date) => _$this._date = date;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _comment = $v.comment;
      _date = $v.date;
      _driverId = $v.driverId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransfer._(
          comment: comment,
          date: date,
          driverId: driverId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
