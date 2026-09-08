// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_sync_dto_defect_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_truck =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
        ._('truck');
const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_trailer =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
        ._('trailer');
const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumValueOf(
        String name) {
  switch (name) {
    case 'truck':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_truck;
    case 'trailer':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_trailer;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum>(const <GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum>[
  _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_truck,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_trailer,
  _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum> {
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
    GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
      deserialize(
              Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType
    extends GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType {
  @override
  final GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum?
      category;
  @override
  final String? id;
  @override
  final bool? isCritical;
  @override
  final String? name;
  @override
  final int? sortOrder;

  factory _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType._(
      {this.category, this.id, this.isCritical, this.name, this.sortOrder})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType &&
        category == other.category &&
        id == other.id &&
        isCritical == other.isCritical &&
        name == other.name &&
        sortOrder == other.sortOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isCritical.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType')
          ..add('category', category)
          ..add('id', id)
          ..add('isCritical', isCritical)
          ..add('name', name)
          ..add('sortOrder', sortOrder))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType,
            GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType? _$v;

  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum?
      _category;
  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum?
      get category => _$this._category;
  set category(
          GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum?
              category) =>
      _$this._category = category;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isCritical;
  bool? get isCritical => _$this._isCritical;
  set isCritical(bool? isCritical) => _$this._isCritical = isCritical;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder() {
    GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _id = $v.id;
      _isCritical = $v.isCritical;
      _name = $v.name;
      _sortOrder = $v.sortOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType._(
          category: category,
          id: id,
          isCritical: isCritical,
          name: name,
          sortOrder: sortOrder,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
