// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_email.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail {
  @override
  final String? comment;
  @override
  final Date? date;
  @override
  final String? driverId;
  @override
  final String email;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail._(
      {this.comment, this.date, this.driverId, required this.email})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail &&
        comment == other.comment &&
        date == other.date &&
        driverId == other.driverId &&
        email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail')
          ..add('comment', comment)
          ..add('date', date)
          ..add('driverId', driverId)
          ..add('email', email))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail,
            GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail? _$v;

  String? _comment;
  String? get comment => _$this._comment;
  set comment(String? comment) => _$this._comment = comment;

  Date? _date;
  Date? get date => _$this._date;
  set date(Date? date) => _$this._date = date;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _comment = $v.comment;
      _date = $v.date;
      _driverId = $v.driverId;
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmailBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail._(
          comment: comment,
          date: date,
          driverId: driverId,
          email: BuiltValueNullFieldError.checkNotNull(
              email,
              r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionEmail',
              'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
