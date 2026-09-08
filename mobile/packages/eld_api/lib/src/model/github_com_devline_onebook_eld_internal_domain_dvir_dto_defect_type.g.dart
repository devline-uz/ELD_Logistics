// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_truck =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
        ._('truck');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_trailer =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
        ._('trailer');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumValueOf(
        String name) {
  switch (name) {
    case 'truck':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_truck;
    case 'trailer':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_trailer;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum>(const <GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum>[
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_truck,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_trailer,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'truck': 'truck',
    'trailer': 'trailer',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'truck': 'truck',
    'trailer': 'trailer',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
      deserialize(
              Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType {
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum?
      category;
  @override
  final DateTime? createdAt;
  @override
  final String? id;
  @override
  final bool? isActive;
  @override
  final bool? isCritical;
  @override
  final bool? isSystem;
  @override
  final String? name;
  @override
  final int? sortOrder;
  @override
  final DateTime? updatedAt;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType._(
      {this.category,
      this.createdAt,
      this.id,
      this.isActive,
      this.isCritical,
      this.isSystem,
      this.name,
      this.sortOrder,
      this.updatedAt})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType &&
        category == other.category &&
        createdAt == other.createdAt &&
        id == other.id &&
        isActive == other.isActive &&
        isCritical == other.isCritical &&
        isSystem == other.isSystem &&
        name == other.name &&
        sortOrder == other.sortOrder &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, isCritical.hashCode);
    _$hash = $jc(_$hash, isSystem.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType')
          ..add('category', category)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('isActive', isActive)
          ..add('isCritical', isCritical)
          ..add('isSystem', isSystem)
          ..add('name', name)
          ..add('sortOrder', sortOrder)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType? _$v;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum?
      _category;
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum?
      get category => _$this._category;
  set category(
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum?
              category) =>
      _$this._category = category;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  bool? _isCritical;
  bool? get isCritical => _$this._isCritical;
  set isCritical(bool? isCritical) => _$this._isCritical = isCritical;

  bool? _isSystem;
  bool? get isSystem => _$this._isSystem;
  set isSystem(bool? isSystem) => _$this._isSystem = isSystem;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _isActive = $v.isActive;
      _isCritical = $v.isCritical;
      _isSystem = $v.isSystem;
      _name = $v.name;
      _sortOrder = $v.sortOrder;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType._(
          category: category,
          createdAt: createdAt,
          id: id,
          isActive: isActive,
          isCritical: isCritical,
          isSystem: isSystem,
          name: name,
          sortOrder: sortOrder,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
