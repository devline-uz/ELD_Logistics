// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_tracking_dto_unidentified_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_pending =
    const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
        ._('pending');
const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_assigned =
    const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
        ._('assigned');
const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_annotated =
    const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
        ._('annotated');
const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
    _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'pending':
      return _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_pending;
    case 'assigned':
      return _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_assigned;
    case 'annotated':
      return _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_annotated;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum>(const <GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum>[
  _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_pending,
  _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_assigned,
  _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_annotated,
  _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum>
    _$githubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum> {
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
    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent
    extends GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent {
  @override
  final String? annotation;
  @override
  final String? assignedDriverId;
  @override
  final DateTime? createdAt;
  @override
  final int? distanceM;
  @override
  final DateTime? endAt;
  @override
  final String? id;
  @override
  final int? pendingDays;
  @override
  final DateTime? resolvedAt;
  @override
  final DateTime? startAt;
  @override
  final GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum?
      status;
  @override
  final String? trackKey;
  @override
  final String? unitId;
  @override
  final String? unitNumber;

  factory _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent._(
      {this.annotation,
      this.assignedDriverId,
      this.createdAt,
      this.distanceM,
      this.endAt,
      this.id,
      this.pendingDays,
      this.resolvedAt,
      this.startAt,
      this.status,
      this.trackKey,
      this.unitId,
      this.unitNumber})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent &&
        annotation == other.annotation &&
        assignedDriverId == other.assignedDriverId &&
        createdAt == other.createdAt &&
        distanceM == other.distanceM &&
        endAt == other.endAt &&
        id == other.id &&
        pendingDays == other.pendingDays &&
        resolvedAt == other.resolvedAt &&
        startAt == other.startAt &&
        status == other.status &&
        trackKey == other.trackKey &&
        unitId == other.unitId &&
        unitNumber == other.unitNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, annotation.hashCode);
    _$hash = $jc(_$hash, assignedDriverId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, pendingDays.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, trackKey.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jc(_$hash, unitNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent')
          ..add('annotation', annotation)
          ..add('assignedDriverId', assignedDriverId)
          ..add('createdAt', createdAt)
          ..add('distanceM', distanceM)
          ..add('endAt', endAt)
          ..add('id', id)
          ..add('pendingDays', pendingDays)
          ..add('resolvedAt', resolvedAt)
          ..add('startAt', startAt)
          ..add('status', status)
          ..add('trackKey', trackKey)
          ..add('unitId', unitId)
          ..add('unitNumber', unitNumber))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent,
            GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent? _$v;

  String? _annotation;
  String? get annotation => _$this._annotation;
  set annotation(String? annotation) => _$this._annotation = annotation;

  String? _assignedDriverId;
  String? get assignedDriverId => _$this._assignedDriverId;
  set assignedDriverId(String? assignedDriverId) =>
      _$this._assignedDriverId = assignedDriverId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  int? _distanceM;
  int? get distanceM => _$this._distanceM;
  set distanceM(int? distanceM) => _$this._distanceM = distanceM;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _pendingDays;
  int? get pendingDays => _$this._pendingDays;
  set pendingDays(int? pendingDays) => _$this._pendingDays = pendingDays;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum?
      _status;
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum?
      get status => _$this._status;
  set status(
          GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventStatusEnum?
              status) =>
      _$this._status = status;

  String? _trackKey;
  String? get trackKey => _$this._trackKey;
  set trackKey(String? trackKey) => _$this._trackKey = trackKey;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  String? _unitNumber;
  String? get unitNumber => _$this._unitNumber;
  set unitNumber(String? unitNumber) => _$this._unitNumber = unitNumber;

  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder() {
    GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _annotation = $v.annotation;
      _assignedDriverId = $v.assignedDriverId;
      _createdAt = $v.createdAt;
      _distanceM = $v.distanceM;
      _endAt = $v.endAt;
      _id = $v.id;
      _pendingDays = $v.pendingDays;
      _resolvedAt = $v.resolvedAt;
      _startAt = $v.startAt;
      _status = $v.status;
      _trackKey = $v.trackKey;
      _unitId = $v.unitId;
      _unitNumber = $v.unitNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEventBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainTrackingDtoUnidentifiedEvent
            ._(
          annotation: annotation,
          assignedDriverId: assignedDriverId,
          createdAt: createdAt,
          distanceM: distanceM,
          endAt: endAt,
          id: id,
          pendingDays: pendingDays,
          resolvedAt: resolvedAt,
          startAt: startAt,
          status: status,
          trackKey: trackKey,
          unitId: unitId,
          unitNumber: unitNumber,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
