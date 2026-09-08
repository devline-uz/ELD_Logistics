// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_assign_driver.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_primary =
    const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
        ._('primary');
const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_co =
    const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
        ._('co');
const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumValueOf(
        String name) {
  switch (name) {
    case 'primary':
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_primary;
    case 'co':
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_co;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum>
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum>(const <GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum>[
  _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_primary,
  _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_co,
  _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum>
    _$githubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum> {
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
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver
    extends GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver {
  @override
  final String driverId;
  @override
  final GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum
      role;

  factory _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver._(
      {required this.driverId, required this.role})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver &&
        driverId == other.driverId &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver')
          ..add('driverId', driverId)
          ..add('role', role))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver,
            GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum?
      _role;
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum?
      get role => _$this._role;
  set role(
          GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverRoleEnum?
              role) =>
      _$this._role = role;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder() {
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriverBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver._(
          driverId: BuiltValueNullFieldError.checkNotNull(
              driverId,
              r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver',
              'driverId'),
          role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitAssignDriver',
              'role'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
