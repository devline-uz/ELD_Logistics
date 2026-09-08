// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_assignment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_primary =
    const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
        ._('primary');
const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_co =
    const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
        ._('co');
const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumValueOf(
        String name) {
  switch (name) {
    case 'primary':
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_primary;
    case 'co':
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_co;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum>
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum>(const <GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum>[
  _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_primary,
  _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_co,
  _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum>
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'primary': 'primary',
    'co': 'co',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'primary': 'primary',
    'co': 'co',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment {
  @override
  final DateTime? assignedAt;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final String? id;
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum?
      role;
  @override
  final DateTime? unassignedAt;
  @override
  final String? unitId;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment._(
      {this.assignedAt,
      this.driverId,
      this.driverName,
      this.id,
      this.role,
      this.unassignedAt,
      this.unitId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment &&
        assignedAt == other.assignedAt &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        id == other.id &&
        role == other.role &&
        unassignedAt == other.unassignedAt &&
        unitId == other.unitId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assignedAt.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, unassignedAt.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment')
          ..add('assignedAt', assignedAt)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('id', id)
          ..add('role', role)
          ..add('unassignedAt', unassignedAt)
          ..add('unitId', unitId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment,
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment? _$v;

  DateTime? _assignedAt;
  DateTime? get assignedAt => _$this._assignedAt;
  set assignedAt(DateTime? assignedAt) => _$this._assignedAt = assignedAt;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum? _role;
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum?
      get role => _$this._role;
  set role(
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentRoleEnum?
              role) =>
      _$this._role = role;

  DateTime? _unassignedAt;
  DateTime? get unassignedAt => _$this._unassignedAt;
  set unassignedAt(DateTime? unassignedAt) =>
      _$this._unassignedAt = unassignedAt;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _assignedAt = $v.assignedAt;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _id = $v.id;
      _role = $v.role;
      _unassignedAt = $v.unassignedAt;
      _unitId = $v.unitId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignmentBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignment._(
          assignedAt: assignedAt,
          driverId: driverId,
          driverName: driverName,
          id: id,
          role: role,
          unassignedAt: unassignedAt,
          unitId: unitId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
