// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_unidentified_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_pending =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
        ._('pending');
const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_assigned =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
        ._('assigned');
const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_annotated =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
        ._('annotated');
const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'pending':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_pending;
    case 'assigned':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_assigned;
    case 'annotated':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_annotated;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_pending,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_assigned,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_annotated,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'assigned': 'assigned',
    'annotated': 'annotated',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'assigned': 'assigned',
    'annotated': 'annotated',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent {
  @override
  final int? distanceM;
  @override
  final DateTime? endAt;
  @override
  final String? id;
  @override
  final DateTime? startAt;
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum?
      status;
  @override
  final String? unitId;
  @override
  final String? unitNumber;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent._(
      {this.distanceM,
      this.endAt,
      this.id,
      this.startAt,
      this.status,
      this.unitId,
      this.unitNumber,
      this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent &&
        distanceM == other.distanceM &&
        endAt == other.endAt &&
        id == other.id &&
        startAt == other.startAt &&
        status == other.status &&
        unitId == other.unitId &&
        unitNumber == other.unitNumber &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent')
          ..add('distanceM', distanceM)
          ..add('endAt', endAt)
          ..add('id', id)
          ..add('startAt', startAt)
          ..add('status', status)
          ..add('unitId', unitId)
          ..add('unitNumber', unitNumber)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent,
            GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent? _$v;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum?
      _status;
  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventStatusEnum?
              status) =>
      _$this._status = status;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _distanceM = $v.distanceM;
      _endAt = $v.endAt;
      _id = $v.id;
      _startAt = $v.startAt;
      _status = $v.status;
      _unitId = $v.unitId;
      _unitNumber = $v.unitNumber;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEventBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent._(
          distanceM: distanceM,
          endAt: endAt,
          id: id,
          startAt: startAt,
          status: status,
          unitId: unitId,
          unitNumber: unitNumber,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
