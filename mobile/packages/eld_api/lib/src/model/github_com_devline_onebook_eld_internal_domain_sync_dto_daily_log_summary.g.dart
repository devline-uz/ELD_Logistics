// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_daily_log_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_uncertified =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
        ._('uncertified');
const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_certified =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
        ._('certified');
const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_needsRecertify =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
        ._('needsRecertify');
const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'uncertified':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_uncertified;
    case 'certified':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_certified;
    case 'needsRecertify':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_needsRecertify;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_uncertified,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_certified,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_needsRecertify,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'uncertified': 'uncertified',
    'certified': 'certified',
    'needsRecertify': 'needs_recertify',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'uncertified': 'uncertified',
    'certified': 'certified',
    'needs_recertify': 'needsRecertify',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary {
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum?
      certificationStatus;
  @override
  final int? distanceM;
  @override
  final String? id;
  @override
  final Date? logDate;
  @override
  final DateTime? signedAt;
  @override
  final String? timezone;
  @override
  final GithubComDevlineOnebookEldInternalDomainDutyDtoDayTotals? totals;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary._(
      {this.certificationStatus,
      this.distanceM,
      this.id,
      this.logDate,
      this.signedAt,
      this.timezone,
      this.totals,
      this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary &&
        certificationStatus == other.certificationStatus &&
        distanceM == other.distanceM &&
        id == other.id &&
        logDate == other.logDate &&
        signedAt == other.signedAt &&
        timezone == other.timezone &&
        totals == other.totals &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, certificationStatus.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, logDate.hashCode);
    _$hash = $jc(_$hash, signedAt.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, totals.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary')
          ..add('certificationStatus', certificationStatus)
          ..add('distanceM', distanceM)
          ..add('id', id)
          ..add('logDate', logDate)
          ..add('signedAt', signedAt)
          ..add('timezone', timezone)
          ..add('totals', totals)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary,
            GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary? _$v;

  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum?
      _certificationStatus;
  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum?
      get certificationStatus => _$this._certificationStatus;
  set certificationStatus(
          GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryCertificationStatusEnum?
              certificationStatus) =>
      _$this._certificationStatus = certificationStatus;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  Date? _logDate;
  Date? get logDate => _$this._logDate;
  set logDate(Date? logDate) => _$this._logDate = logDate;

  DateTime? _signedAt;
  DateTime? get signedAt => _$this._signedAt;
  set signedAt(DateTime? signedAt) => _$this._signedAt = signedAt;

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

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _certificationStatus = $v.certificationStatus;
      _distanceM = $v.distanceM;
      _id = $v.id;
      _logDate = $v.logDate;
      _signedAt = $v.signedAt;
      _timezone = $v.timezone;
      _totals = $v.totals?.toBuilder();
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummaryBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary _build() {
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary._(
            certificationStatus: certificationStatus,
            distanceM: distanceM,
            id: id,
            logDate: logDate,
            signedAt: signedAt,
            timezone: timezone,
            totals: _totals?.build(),
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'totals';
        _totals?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary',
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
