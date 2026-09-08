// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_record.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
    _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_completed =
    const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
        ._('completed');
const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
    _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_cancelled =
    const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
        ._('cancelled');
const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
    _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
    _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'completed':
      return _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_completed;
    case 'cancelled':
      return _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_cancelled;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_completed,
  _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_cancelled,
  _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'completed': 'completed',
    'cancelled': 'cancelled',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'completed': 'completed',
    'cancelled': 'cancelled',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord {
  @override
  final String? cancelledReason;
  @override
  final num? cost;
  @override
  final DateTime? createdAt;
  @override
  final String? currency;
  @override
  final num? engineHours;
  @override
  final String? id;
  @override
  final String? invoiceKey;
  @override
  final String? invoiceNo;
  @override
  final String? notes;
  @override
  final int? odometerM;
  @override
  final DateTime? performedAt;
  @override
  final String? scheduleUnitId;
  @override
  final GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum?
      status;
  @override
  final String? unitId;
  @override
  final String? unitNumber;
  @override
  final String? vendor;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord._(
      {this.cancelledReason,
      this.cost,
      this.createdAt,
      this.currency,
      this.engineHours,
      this.id,
      this.invoiceKey,
      this.invoiceNo,
      this.notes,
      this.odometerM,
      this.performedAt,
      this.scheduleUnitId,
      this.status,
      this.unitId,
      this.unitNumber,
      this.vendor})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord &&
        cancelledReason == other.cancelledReason &&
        cost == other.cost &&
        createdAt == other.createdAt &&
        currency == other.currency &&
        engineHours == other.engineHours &&
        id == other.id &&
        invoiceKey == other.invoiceKey &&
        invoiceNo == other.invoiceNo &&
        notes == other.notes &&
        odometerM == other.odometerM &&
        performedAt == other.performedAt &&
        scheduleUnitId == other.scheduleUnitId &&
        status == other.status &&
        unitId == other.unitId &&
        unitNumber == other.unitNumber &&
        vendor == other.vendor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cancelledReason.hashCode);
    _$hash = $jc(_$hash, cost.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, engineHours.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, invoiceKey.hashCode);
    _$hash = $jc(_$hash, invoiceNo.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, odometerM.hashCode);
    _$hash = $jc(_$hash, performedAt.hashCode);
    _$hash = $jc(_$hash, scheduleUnitId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jc(_$hash, vendor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord')
          ..add('cancelledReason', cancelledReason)
          ..add('cost', cost)
          ..add('createdAt', createdAt)
          ..add('currency', currency)
          ..add('engineHours', engineHours)
          ..add('id', id)
          ..add('invoiceKey', invoiceKey)
          ..add('invoiceNo', invoiceNo)
          ..add('notes', notes)
          ..add('odometerM', odometerM)
          ..add('performedAt', performedAt)
          ..add('scheduleUnitId', scheduleUnitId)
          ..add('status', status)
          ..add('unitId', unitId)
          ..add('unitNumber', unitNumber)
          ..add('vendor', vendor))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord? _$v;

  String? _cancelledReason;
  String? get cancelledReason => _$this._cancelledReason;
  set cancelledReason(String? cancelledReason) =>
      _$this._cancelledReason = cancelledReason;

  num? _cost;
  num? get cost => _$this._cost;
  set cost(num? cost) => _$this._cost = cost;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  num? _engineHours;
  num? get engineHours => _$this._engineHours;
  set engineHours(num? engineHours) => _$this._engineHours = engineHours;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _invoiceKey;
  String? get invoiceKey => _$this._invoiceKey;
  set invoiceKey(String? invoiceKey) => _$this._invoiceKey = invoiceKey;

  String? _invoiceNo;
  String? get invoiceNo => _$this._invoiceNo;
  set invoiceNo(String? invoiceNo) => _$this._invoiceNo = invoiceNo;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  int? _odometerM;
  int? get odometerM => _$this._odometerM;
  set odometerM(int? odometerM) => _$this._odometerM = odometerM;

  DateTime? _performedAt;
  DateTime? get performedAt => _$this._performedAt;
  set performedAt(DateTime? performedAt) => _$this._performedAt = performedAt;

  String? _scheduleUnitId;
  String? get scheduleUnitId => _$this._scheduleUnitId;
  set scheduleUnitId(String? scheduleUnitId) =>
      _$this._scheduleUnitId = scheduleUnitId;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum?
      _status;
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordStatusEnum?
              status) =>
      _$this._status = status;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  String? _vendor;
  String? get vendor => _$this._vendor;
  set vendor(String? vendor) => _$this._vendor = vendor;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _cancelledReason = $v.cancelledReason;
      _cost = $v.cost;
      _createdAt = $v.createdAt;
      _currency = $v.currency;
      _engineHours = $v.engineHours;
      _id = $v.id;
      _invoiceKey = $v.invoiceKey;
      _invoiceNo = $v.invoiceNo;
      _notes = $v.notes;
      _odometerM = $v.odometerM;
      _performedAt = $v.performedAt;
      _scheduleUnitId = $v.scheduleUnitId;
      _status = $v.status;
      _unitId = $v.unitId;
      _unitNumber = $v.unitNumber;
      _vendor = $v.vendor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecordBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoRecord._(
          cancelledReason: cancelledReason,
          cost: cost,
          createdAt: createdAt,
          currency: currency,
          engineHours: engineHours,
          id: id,
          invoiceKey: invoiceKey,
          invoiceNo: invoiceNo,
          notes: notes,
          odometerM: odometerM,
          performedAt: performedAt,
          scheduleUnitId: scheduleUnitId,
          status: status,
          unitId: unitId,
          unitNumber: unitNumber,
          vendor: vendor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
