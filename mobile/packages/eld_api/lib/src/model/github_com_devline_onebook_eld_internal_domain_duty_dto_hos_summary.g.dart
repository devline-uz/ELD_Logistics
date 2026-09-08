// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_duty_dto_hos_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary
    extends GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary {
  @override
  final GithubComDevlineOnebookEldInternalDomainDutyDtoCounters? counters;
  @override
  final Date? date;
  @override
  final String? driverId;
  @override
  final DateTime? evaluatedAt;
  @override
  final String? policyVersionId;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay>?
      recap;
  @override
  final String? timezone;
  @override
  final GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals? totals;
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation>?
      violations;

  factory _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary._(
      {this.counters,
      this.date,
      this.driverId,
      this.evaluatedAt,
      this.policyVersionId,
      this.recap,
      this.timezone,
      this.totals,
      this.violations})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary &&
        counters == other.counters &&
        date == other.date &&
        driverId == other.driverId &&
        evaluatedAt == other.evaluatedAt &&
        policyVersionId == other.policyVersionId &&
        recap == other.recap &&
        timezone == other.timezone &&
        totals == other.totals &&
        violations == other.violations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, counters.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, evaluatedAt.hashCode);
    _$hash = $jc(_$hash, policyVersionId.hashCode);
    _$hash = $jc(_$hash, recap.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, totals.hashCode);
    _$hash = $jc(_$hash, violations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary')
          ..add('counters', counters)
          ..add('date', date)
          ..add('driverId', driverId)
          ..add('evaluatedAt', evaluatedAt)
          ..add('policyVersionId', policyVersionId)
          ..add('recap', recap)
          ..add('timezone', timezone)
          ..add('totals', totals)
          ..add('violations', violations))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary,
            GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary? _$v;

  GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder? _counters;
  GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder get counters =>
      _$this._counters ??=
          GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder();
  set counters(
          GithubComDevlineOnebookEldInternalDomainDutyDtoCountersBuilder?
              counters) =>
      _$this._counters = counters;

  Date? _date;
  Date? get date => _$this._date;
  set date(Date? date) => _$this._date = date;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  DateTime? _evaluatedAt;
  DateTime? get evaluatedAt => _$this._evaluatedAt;
  set evaluatedAt(DateTime? evaluatedAt) => _$this._evaluatedAt = evaluatedAt;

  String? _policyVersionId;
  String? get policyVersionId => _$this._policyVersionId;
  set policyVersionId(String? policyVersionId) =>
      _$this._policyVersionId = policyVersionId;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay>? _recap;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay>
      get recap => _$this._recap ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay>();
  set recap(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoRecapDay>?
              recap) =>
      _$this._recap = recap;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder? _totals;
  GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder get totals =>
      _$this._totals ??=
          GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder();
  set totals(
          GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotalsBuilder?
              totals) =>
      _$this._totals = totals;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation>?
      _violations;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation>
      get violations => _$this._violations ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDutyDtoViolation>();
  set violations(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation>?
              violations) =>
      _$this._violations = violations;

  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder() {
    GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _counters = $v.counters?.toBuilder();
      _date = $v.date;
      _driverId = $v.driverId;
      _evaluatedAt = $v.evaluatedAt;
      _policyVersionId = $v.policyVersionId;
      _recap = $v.recap?.toBuilder();
      _timezone = $v.timezone;
      _totals = $v.totals?.toBuilder();
      _violations = $v.violations?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummaryBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary _build() {
    _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary._(
            counters: _counters?.build(),
            date: date,
            driverId: driverId,
            evaluatedAt: evaluatedAt,
            policyVersionId: policyVersionId,
            recap: _recap?.build(),
            timezone: timezone,
            totals: _totals?.build(),
            violations: _violations?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'counters';
        _counters?.build();

        _$failedField = 'recap';
        _recap?.build();

        _$failedField = 'totals';
        _totals?.build();
        _$failedField = 'violations';
        _violations?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDutyDtoHosSummary',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
