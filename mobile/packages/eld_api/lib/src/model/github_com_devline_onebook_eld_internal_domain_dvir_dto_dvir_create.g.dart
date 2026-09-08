// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_preTrip =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum._(
        'preTrip');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_postTrip =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum._(
        'postTrip');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'preTrip':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_preTrip;
    case 'postTrip':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_postTrip;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum>(const <GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum>[
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_preTrip,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_postTrip,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'preTrip': 'pre_trip',
    'postTrip': 'post_trip',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pre_trip': 'preTrip',
    'post_trip': 'postTrip',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate {
  @override
  final BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput>?
      defects;
  @override
  final String driverSignatureKey;
  @override
  final String? notes;
  @override
  final BuiltList<String>? trailerIds;
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum type;
  @override
  final String unitId;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate._(
      {this.defects,
      required this.driverSignatureKey,
      this.notes,
      this.trailerIds,
      required this.type,
      required this.unitId})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate &&
        defects == other.defects &&
        driverSignatureKey == other.driverSignatureKey &&
        notes == other.notes &&
        trailerIds == other.trailerIds &&
        type == other.type &&
        unitId == other.unitId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, defects.hashCode);
    _$hash = $jc(_$hash, driverSignatureKey.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, trailerIds.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, unitId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate')
          ..add('defects', defects)
          ..add('driverSignatureKey', driverSignatureKey)
          ..add('notes', notes)
          ..add('trailerIds', trailerIds)
          ..add('type', type)
          ..add('unitId', unitId))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate? _$v;

  ListBuilder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput>?
      _defects;
  ListBuilder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput>
      get defects => _$this._defects ??= ListBuilder<
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput>();
  set defects(
          ListBuilder<
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput>?
              defects) =>
      _$this._defects = defects;

  String? _driverSignatureKey;
  String? get driverSignatureKey => _$this._driverSignatureKey;
  set driverSignatureKey(String? driverSignatureKey) =>
      _$this._driverSignatureKey = driverSignatureKey;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ListBuilder<String>? _trailerIds;
  ListBuilder<String> get trailerIds =>
      _$this._trailerIds ??= ListBuilder<String>();
  set trailerIds(ListBuilder<String>? trailerIds) =>
      _$this._trailerIds = trailerIds;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum? _type;
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum? get type =>
      _$this._type;
  set type(
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum?
              type) =>
      _$this._type = type;

  String? _unitId;
  String? get unitId => _$this._unitId;
  set unitId(String? unitId) => _$this._unitId = unitId;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _defects = $v.defects?.toBuilder();
      _driverSignatureKey = $v.driverSignatureKey;
      _notes = $v.notes;
      _trailerIds = $v.trailerIds?.toBuilder();
      _type = $v.type;
      _unitId = $v.unitId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate _build() {
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate._(
            defects: _defects?.build(),
            driverSignatureKey: BuiltValueNullFieldError.checkNotNull(
                driverSignatureKey,
                r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate',
                'driverSignatureKey'),
            notes: notes,
            trailerIds: _trailerIds?.build(),
            type: BuiltValueNullFieldError.checkNotNull(
                type,
                r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate',
                'type'),
            unitId: BuiltValueNullFieldError.checkNotNull(
                unitId,
                r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate',
                'unitId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'defects';
        _defects?.build();

        _$failedField = 'trailerIds';
        _trailerIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
