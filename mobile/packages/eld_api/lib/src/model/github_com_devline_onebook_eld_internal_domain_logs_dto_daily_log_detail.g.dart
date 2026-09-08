// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_daily_log_detail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_uncertified =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
        ._('uncertified');
const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_certified =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
        ._('certified');
const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_needsRecertify =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
        ._('needsRecertify');
const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'uncertified':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_uncertified;
    case 'certified':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_certified;
    case 'needsRecertify':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_needsRecertify;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_uncertified,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_certified,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_needsRecertify,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum> {
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
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum?
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
  final BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent>?
      events;
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoLogForm? form;
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
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>?
      violations;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail._(
      {this.certificationStatus,
      this.coDriverName,
      this.distanceM,
      this.driverId,
      this.driverName,
      this.events,
      this.form,
      this.id,
      this.logDate,
      this.ready,
      this.signedAt,
      this.timezone,
      this.totals,
      this.unitIds,
      this.updatedAt,
      this.violations})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail &&
        certificationStatus == other.certificationStatus &&
        coDriverName == other.coDriverName &&
        distanceM == other.distanceM &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        events == other.events &&
        form == other.form &&
        id == other.id &&
        logDate == other.logDate &&
        ready == other.ready &&
        signedAt == other.signedAt &&
        timezone == other.timezone &&
        totals == other.totals &&
        unitIds == other.unitIds &&
        updatedAt == other.updatedAt &&
        violations == other.violations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, certificationStatus.hashCode);
    _$hash = $jc(_$hash, coDriverName.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, form.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, logDate.hashCode);
    _$hash = $jc(_$hash, ready.hashCode);
    _$hash = $jc(_$hash, signedAt.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, totals.hashCode);
    _$hash = $jc(_$hash, unitIds.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, violations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail')
          ..add('certificationStatus', certificationStatus)
          ..add('coDriverName', coDriverName)
          ..add('distanceM', distanceM)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('events', events)
          ..add('form', form)
          ..add('id', id)
          ..add('logDate', logDate)
          ..add('ready', ready)
          ..add('signedAt', signedAt)
          ..add('timezone', timezone)
          ..add('totals', totals)
          ..add('unitIds', unitIds)
          ..add('updatedAt', updatedAt)
          ..add('violations', violations))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail,
            GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail? _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum?
      _certificationStatus;
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum?
      get certificationStatus => _$this._certificationStatus;
  set certificationStatus(
          GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailCertificationStatusEnum?
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

  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent>? _events;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent>
      get events => _$this._events ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent>();
  set events(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEvent>?
              events) =>
      _$this._events = events;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder? _form;
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder get form =>
      _$this._form ??=
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder();
  set form(
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogFormBuilder?
              form) =>
      _$this._form = form;

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

  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>?
      _violations;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>
      get violations => _$this._violations ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>();
  set violations(
          ListBuilder<GithubComDevlineOnebookEldInternalDomainLogsDtoViolation>?
              violations) =>
      _$this._violations = violations;

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _certificationStatus = $v.certificationStatus;
      _coDriverName = $v.coDriverName;
      _distanceM = $v.distanceM;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _events = $v.events?.toBuilder();
      _form = $v.form?.toBuilder();
      _id = $v.id;
      _logDate = $v.logDate;
      _ready = $v.ready;
      _signedAt = $v.signedAt;
      _timezone = $v.timezone;
      _totals = $v.totals?.toBuilder();
      _unitIds = $v.unitIds?.toBuilder();
      _updatedAt = $v.updatedAt;
      _violations = $v.violations?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetailBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail _build() {
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail._(
            certificationStatus: certificationStatus,
            coDriverName: coDriverName,
            distanceM: distanceM,
            driverId: driverId,
            driverName: driverName,
            events: _events?.build(),
            form: _form?.build(),
            id: id,
            logDate: logDate,
            ready: ready,
            signedAt: signedAt,
            timezone: timezone,
            totals: _totals?.build(),
            unitIds: _unitIds?.build(),
            updatedAt: updatedAt,
            violations: _violations?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'events';
        _events?.build();
        _$failedField = 'form';
        _form?.build();

        _$failedField = 'totals';
        _totals?.build();
        _$failedField = 'unitIds';
        _unitIds?.build();

        _$failedField = 'violations';
        _violations?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoDailyLogDetail',
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
