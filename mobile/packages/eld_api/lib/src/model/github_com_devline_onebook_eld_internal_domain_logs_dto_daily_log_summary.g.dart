// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_uncertified =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
        ._('uncertified');
const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_certified =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
        ._('certified');
const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_needsRecertify =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
        ._('needsRecertify');
const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'uncertified':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_uncertified;
    case 'certified':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_certified;
    case 'needsRecertify':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_needsRecertify;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_uncertified,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_certified,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_needsRecertify,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum> {
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
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum?
      certificationStatus;
  @override
  final String? coDriverName;
  @override
  final int? distanceM;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final String? id;
  @override
  final Date? logDate;
  @override
  final bool? ready;
  @override
  final DateTime? signedAt;
  @override
  final String? timezone;
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotals? totals;
  @override
  final BuiltList<String>? unitIds;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary._(
      {this.certificationStatus,
      this.coDriverName,
      this.distanceM,
      this.driverId,
      this.driverName,
      this.id,
      this.logDate,
      this.ready,
      this.signedAt,
      this.timezone,
      this.totals,
      this.unitIds,
      this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary &&
        certificationStatus == other.certificationStatus &&
        coDriverName == other.coDriverName &&
        distanceM == other.distanceM &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        id == other.id &&
        logDate == other.logDate &&
        ready == other.ready &&
        signedAt == other.signedAt &&
        timezone == other.timezone &&
        totals == other.totals &&
        unitIds == other.unitIds &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, certificationStatus.hashCode);
    _$hash = $jc(_$hash, coDriverName.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, logDate.hashCode);
    _$hash = $jc(_$hash, ready.hashCode);
    _$hash = $jc(_$hash, signedAt.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, totals.hashCode);
    _$hash = $jc(_$hash, unitIds.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary')
          ..add('certificationStatus', certificationStatus)
          ..add('coDriverName', coDriverName)
          ..add('distanceM', distanceM)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('id', id)
          ..add('logDate', logDate)
          ..add('ready', ready)
          ..add('signedAt', signedAt)
          ..add('timezone', timezone)
          ..add('totals', totals)
          ..add('unitIds', unitIds)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary,
            GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary? _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum?
      _certificationStatus;
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum?
      get certificationStatus => _$this._certificationStatus;
  set certificationStatus(
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryCertificationStatusEnum?
              certificationStatus) =>
      _$this._certificationStatus = certificationStatus;

  String? _coDriverName;
  String? get coDriverName => _$this._coDriverName;
  set coDriverName(String? coDriverName) => _$this._coDriverName = coDriverName;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  Date? _logDate;
  Date? get logDate => _$this._logDate;
  set logDate(Date? logDate) => _$this._logDate = logDate;

  bool? _ready;
  bool? get ready => _$this._ready;
  set ready(bool? ready) => _$this._ready = ready;

  DateTime? _signedAt;
  DateTime? get signedAt => _$this._signedAt;
  set signedAt(DateTime? signedAt) => _$this._signedAt = signedAt;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotalsBuilder? _totals;
  GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotalsBuilder get totals =>
      _$this._totals ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotalsBuilder();
  set totals(
          GithubComDevlineOnebookEldInternalDomainLogsDtoDayTotalsBuilder?
              totals) =>
      _$this._totals = totals;

  ListBuilder<String>? _unitIds;
  ListBuilder<String> get unitIds => _$this._unitIds ??= ListBuilder<String>();
  set unitIds(ListBuilder<String>? unitIds) => _$this._unitIds = unitIds;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _certificationStatus = $v.certificationStatus;
      _coDriverName = $v.coDriverName;
      _distanceM = $v.distanceM;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _id = $v.id;
      _logDate = $v.logDate;
      _ready = $v.ready;
      _signedAt = $v.signedAt;
      _timezone = $v.timezone;
      _totals = $v.totals?.toBuilder();
      _unitIds = $v.unitIds?.toBuilder();
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummaryBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary._(
            certificationStatus: certificationStatus,
            coDriverName: coDriverName,
            distanceM: distanceM,
            driverId: driverId,
            driverName: driverName,
            id: id,
            logDate: logDate,
            ready: ready,
            signedAt: signedAt,
            timezone: timezone,
            totals: _totals?.build(),
            unitIds: _unitIds?.build(),
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'totals';
        _totals?.build();
        _$failedField = 'unitIds';
        _unitIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogSummary',
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
