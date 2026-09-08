// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_pending =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
        ._('pending');
const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_proposed =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
        ._('proposed');
const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_assigned =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
        ._('assigned');
const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_annotated =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
        ._('annotated');
const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'pending':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_pending;
    case 'proposed':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_proposed;
    case 'assigned':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_assigned;
    case 'annotated':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_annotated;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_pending,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_proposed,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_assigned,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_annotated,
  _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'proposed': 'proposed',
    'assigned': 'assigned',
    'annotated': 'annotated',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'proposed': 'proposed',
    'assigned': 'assigned',
    'annotated': 'annotated',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent {
  @override
  final String? annotation;
  @override
  final String? assignedDriverId;
  @override
  final String? assignedDriverName;
  @override
  final DateTime? createdAt;
  @override
  final int? distanceM;
  @override
  final String? editRequestId;
  @override
  final DateTime? endAt;
  @override
  final String? id;
  @override
  final DateTime? startAt;
  @override
  final GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum?
      status;
  @override
  final String? unitId;
  @override
  final String? unitNumber;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent._(
      {this.annotation,
      this.assignedDriverId,
      this.assignedDriverName,
      this.createdAt,
      this.distanceM,
      this.editRequestId,
      this.endAt,
      this.id,
      this.startAt,
      this.status,
      this.unitId,
      this.unitNumber})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent &&
        annotation == other.annotation &&
        assignedDriverId == other.assignedDriverId &&
        assignedDriverName == other.assignedDriverName &&
        createdAt == other.createdAt &&
        distanceM == other.distanceM &&
        editRequestId == other.editRequestId &&
        endAt == other.endAt &&
        id == other.id &&
        startAt == other.startAt &&
        status == other.status &&
        unitId == other.unitId &&
        unitNumber == other.unitNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, annotation.hashCode);
    _$hash = $jc(_$hash, assignedDriverId.hashCode);
    _$hash = $jc(_$hash, assignedDriverName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, editRequestId.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent')
          ..add('annotation', annotation)
          ..add('assignedDriverId', assignedDriverId)
          ..add('assignedDriverName', assignedDriverName)
          ..add('createdAt', createdAt)
          ..add('distanceM', distanceM)
          ..add('editRequestId', editRequestId)
          ..add('endAt', endAt)
          ..add('id', id)
          ..add('startAt', startAt)
          ..add('status', status)
          ..add('unitId', unitId)
          ..add('unitNumber', unitNumber))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent,
            GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent? _$v;

  String? _annotation;
  String? get annotation => _$this._annotation;
  set annotation(String? annotation) => _$this._annotation = annotation;

  String? _assignedDriverId;
  String? get assignedDriverId => _$this._assignedDriverId;
  set assignedDriverId(String? assignedDriverId) =>
      _$this._assignedDriverId = assignedDriverId;

  String? _assignedDriverName;
  String? get assignedDriverName => _$this._assignedDriverName;
  set assignedDriverName(String? assignedDriverName) =>
      _$this._assignedDriverName = assignedDriverName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  String? _editRequestId;
  String? get editRequestId => _$this._editRequestId;
  set editRequestId(String? editRequestId) =>
      _$this._editRequestId = editRequestId;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum?
      _status;
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventStatusEnum?
              status) =>
      _$this._status = status;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _annotation = $v.annotation;
      _assignedDriverId = $v.assignedDriverId;
      _assignedDriverName = $v.assignedDriverName;
      _createdAt = $v.createdAt;
      _distanceM = $v.distanceM;
      _editRequestId = $v.editRequestId;
      _endAt = $v.endAt;
      _id = $v.id;
      _startAt = $v.startAt;
      _status = $v.status;
      _unitId = $v.unitId;
      _unitNumber = $v.unitNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEventBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedEvent._(
          annotation: annotation,
          assignedDriverId: assignedDriverId,
          assignedDriverName: assignedDriverName,
          createdAt: createdAt,
          distanceM: distanceM,
          editRequestId: editRequestId,
          endAt: endAt,
          id: id,
          startAt: startAt,
          status: status,
          unitId: unitId,
          unitNumber: unitNumber,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
