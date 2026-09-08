// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_duty_dto_recap_day.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay
    extends GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay {
  @override
  final int? availableMin;
  @override
  final Date? date;
  @override
  final int? gainedNextMin;
  @override
  final int? onDutyMin;

  factory _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay._(
      {this.availableMin, this.date, this.gainedNextMin, this.onDutyMin})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay &&
        availableMin == other.availableMin &&
        date == other.date &&
        gainedNextMin == other.gainedNextMin &&
        onDutyMin == other.onDutyMin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, availableMin.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, gainedNextMin.hashCode);
    _$hash = $jc(_$hash, onDutyMin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay')
          ..add('availableMin', availableMin)
          ..add('date', date)
          ..add('gainedNextMin', gainedNextMin)
          ..add('onDutyMin', onDutyMin))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay,
            GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay? _$v;

  int? _availableMin;
  int? get availableMin => _$this._availableMin;
  set availableMin(int? availableMin) => _$this._availableMin = availableMin;

  Date? _date;
  Date? get date => _$this._date;
  set date(Date? date) => _$this._date = date;

  int? _gainedNextMin;
  int? get gainedNextMin => _$this._gainedNextMin;
  set gainedNextMin(int? gainedNextMin) =>
      _$this._gainedNextMin = gainedNextMin;

  int? _onDutyMin;
  int? get onDutyMin => _$this._onDutyMin;
  set onDutyMin(int? onDutyMin) => _$this._onDutyMin = onDutyMin;

  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder() {
    GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _availableMin = $v.availableMin;
      _date = $v.date;
      _gainedNextMin = $v.gainedNextMin;
      _onDutyMin = $v.onDutyMin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDayBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay._(
          availableMin: availableMin,
          date: date,
          gainedNextMin: gainedNextMin,
          onDutyMin: onDutyMin,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
