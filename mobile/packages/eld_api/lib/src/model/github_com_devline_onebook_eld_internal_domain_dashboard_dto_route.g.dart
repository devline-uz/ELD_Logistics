// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dashboard_dto_route.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_planned =
    const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum._(
        'planned');
const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_inProgress =
    const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum._(
        'inProgress');
const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_completed =
    const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum._(
        'completed');
const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_notCompleted =
    const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum._(
        'notCompleted');
const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_cancelled =
    const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum._(
        'cancelled');
const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'planned':
      return _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_planned;
    case 'inProgress':
      return _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_inProgress;
    case 'completed':
      return _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_completed;
    case 'notCompleted':
      return _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_notCompleted;
    case 'cancelled':
      return _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_cancelled;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_planned,
  _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_inProgress,
  _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_completed,
  _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_notCompleted,
  _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_cancelled,
  _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'planned': 'planned',
    'inProgress': 'in_progress',
    'completed': 'completed',
    'notCompleted': 'not_completed',
    'cancelled': 'cancelled',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'planned': 'planned',
    'in_progress': 'inProgress',
    'completed': 'completed',
    'not_completed': 'notCompleted',
    'cancelled': 'cancelled',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute
    extends GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute {
  @override
  final DateTime? completedAt;
  @override
  final DateTime? createdAt;
  @override
  final String? destination;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final String? id;
  @override
  final String? origin;
  @override
  final int? sequence;
  @override
  final DateTime? startedAt;
  @override
  final GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum?
      status;
  @override
  final String? unitId;
  @override
  final String? unitNumber;

  factory _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute._(
      {this.completedAt,
      this.createdAt,
      this.destination,
      this.driverId,
      this.driverName,
      this.id,
      this.origin,
      this.sequence,
      this.startedAt,
      this.status,
      this.unitId,
      this.unitNumber})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute &&
        completedAt == other.completedAt &&
        createdAt == other.createdAt &&
        destination == other.destination &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        id == other.id &&
        origin == other.origin &&
        sequence == other.sequence &&
        startedAt == other.startedAt &&
        status == other.status &&
        unitId == other.unitId &&
        unitNumber == other.unitNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute')
          ..add('completedAt', completedAt)
          ..add('createdAt', createdAt)
          ..add('destination', destination)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('id', id)
          ..add('origin', origin)
          ..add('sequence', sequence)
          ..add('startedAt', startedAt)
          ..add('status', status)
          ..add('unitId', unitId)
          ..add('unitNumber', unitNumber))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute,
            GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute? _$v;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _destination;
  String? get destination => _$this._destination;
  set destination(String? destination) => _$this._destination = destination;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _origin;
  String? get origin => _$this._origin;
  set origin(String? origin) => _$this._origin = origin;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum? _status;
  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteStatusEnum?
              status) =>
      _$this._status = status;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder() {
    GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _completedAt = $v.completedAt;
      _createdAt = $v.createdAt;
      _destination = $v.destination;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _id = $v.id;
      _origin = $v.origin;
      _sequence = $v.sequence;
      _startedAt = $v.startedAt;
      _status = $v.status;
      _unitId = $v.unitId;
      _unitNumber = $v.unitNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDashboardDtoRouteBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDashboardDtoRoute._(
          completedAt: completedAt,
          createdAt: createdAt,
          destination: destination,
          driverId: driverId,
          driverName: driverName,
          id: id,
          origin: origin,
          sequence: sequence,
          startedAt: startedAt,
          status: status,
          unitId: unitId,
          unitNumber: unitNumber,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
