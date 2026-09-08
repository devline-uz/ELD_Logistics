// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_schedule_unit_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput {
  @override
  final num? lastServiceValue;
  @override
  final String unitId;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput._(
      {this.lastServiceValue, required this.unitId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput &&
        lastServiceValue == other.lastServiceValue &&
        unitId == other.unitId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lastServiceValue.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput')
          ..add('lastServiceValue', lastServiceValue)
          ..add('unitId', unitId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput?
      _$v;

  num? _lastServiceValue;
  num? get lastServiceValue => _$this._lastServiceValue;
  set lastServiceValue(num? lastServiceValue) =>
      _$this._lastServiceValue = lastServiceValue;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _lastServiceValue = $v.lastServiceValue;
      _unitId = $v.unitId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInputBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput
            ._(
          lastServiceValue: lastServiceValue,
          unitId: BuiltValueNullFieldError.checkNotNull(
              unitId,
              r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoScheduleUnitInput',
              'unitId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
