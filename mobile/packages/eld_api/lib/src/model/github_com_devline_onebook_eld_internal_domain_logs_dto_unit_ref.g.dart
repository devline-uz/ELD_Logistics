// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_unit_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef {
  @override
  final String? id;
  @override
  final String? licensePlate;
  @override
  final String? unitNumber;
  @override
  final String? vin;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef._(
      {this.id, this.licensePlate, this.unitNumber, this.vin})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef &&
        id == other.id &&
        licensePlate == other.licensePlate &&
        unitNumber == other.unitNumber &&
        vin == other.vin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, licensePlate.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jc(_$hash, vin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef')
          ..add('id', id)
          ..add('licensePlate', licensePlate)
          ..add('unitNumber', unitNumber)
          ..add('vin', vin))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef,
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _licensePlate;
  String? get licensePlate => _$this._licensePlate;
  set licensePlate(String? licensePlate) => _$this._licensePlate = licensePlate;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  String? _vin;
  String? get vin => _$this._vin;
  set vin(String? vin) => _$this._vin = vin;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _licensePlate = $v.licensePlate;
      _unitNumber = $v.unitNumber;
      _vin = $v.vin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef._(
          id: id,
          licensePlate: licensePlate,
          unitNumber: unitNumber,
          vin: vin,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
