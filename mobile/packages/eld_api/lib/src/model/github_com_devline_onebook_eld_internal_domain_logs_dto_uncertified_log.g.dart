// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_uncertified_log.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_uncertified =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
        ._('uncertified');
const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_needsRecertify =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
        ._('needsRecertify');
const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'uncertified':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_uncertified;
    case 'needsRecertify':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_needsRecertify;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_uncertified,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_needsRecertify,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'uncertified': 'uncertified',
    'needsRecertify': 'needs_recertify',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'uncertified': 'uncertified',
    'needs_recertify': 'needsRecertify',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog {
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum?
      certificationStatus;
  @override
  final String? dailyLogId;
  @override
  final int? daysOverdue;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final Date? logDate;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog._(
      {this.certificationStatus,
      this.dailyLogId,
      this.daysOverdue,
      this.driverId,
      this.driverName,
      this.logDate})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog &&
        certificationStatus == other.certificationStatus &&
        dailyLogId == other.dailyLogId &&
        daysOverdue == other.daysOverdue &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        logDate == other.logDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, certificationStatus.hashCode);
    _$hash = $jc(_$hash, dailyLogId.hashCode);
    _$hash = $jc(_$hash, daysOverdue.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, logDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog')
          ..add('certificationStatus', certificationStatus)
          ..add('dailyLogId', dailyLogId)
          ..add('daysOverdue', daysOverdue)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('logDate', logDate))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog,
            GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog? _$v;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum?
      _certificationStatus;
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum?
      get certificationStatus => _$this._certificationStatus;
  set certificationStatus(
          GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum?
              certificationStatus) =>
      _$this._certificationStatus = certificationStatus;

  String? _dailyLogId;
  String? get dailyLogId => _$this._dailyLogId;
  set dailyLogId(String? dailyLogId) => _$this._dailyLogId = dailyLogId;

  int? _daysOverdue;
  int? get daysOverdue => _$this._daysOverdue;
  set daysOverdue(int? daysOverdue) => _$this._daysOverdue = daysOverdue;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  Date? _logDate;
  Date? get logDate => _$this._logDate;
  set logDate(Date? logDate) => _$this._logDate = logDate;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _certificationStatus = $v.certificationStatus;
      _dailyLogId = $v.dailyLogId;
      _daysOverdue = $v.daysOverdue;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _logDate = $v.logDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog._(
          certificationStatus: certificationStatus,
          dailyLogId: dailyLogId,
          daysOverdue: daysOverdue,
          driverId: driverId,
          driverName: driverName,
          logDate: logDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
