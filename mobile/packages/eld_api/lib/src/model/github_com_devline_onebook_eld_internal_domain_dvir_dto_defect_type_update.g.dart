// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_truck =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
        ._('truck');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_trailer =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
        ._('trailer');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumValueOf(
        String name) {
  switch (name) {
    case 'truck':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_truck;
    case 'trailer':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_trailer;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum>(const <GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum>[
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_truck,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_trailer,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum> {
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
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate {
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum?
      category;
  @override
  final bool? isActive;
  @override
  final bool? isCritical;
  @override
  final String? name;
  @override
  final int? sortOrder;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate._(
      {this.category,
      this.isActive,
      this.isCritical,
      this.name,
      this.sortOrder})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate &&
        category == other.category &&
        isActive == other.isActive &&
        isCritical == other.isCritical &&
        name == other.name &&
        sortOrder == other.sortOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, isCritical.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate')
          ..add('category', category)
          ..add('isActive', isActive)
          ..add('isCritical', isCritical)
          ..add('name', name)
          ..add('sortOrder', sortOrder))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate? _$v;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum?
      _category;
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum?
      get category => _$this._category;
  set category(
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum?
              category) =>
      _$this._category = category;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  bool? _isCritical;
  bool? get isCritical => _$this._isCritical;
  set isCritical(bool? isCritical) => _$this._isCritical = isCritical;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _isActive = $v.isActive;
      _isCritical = $v.isCritical;
      _name = $v.name;
      _sortOrder = $v.sortOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate._(
          category: category,
          isActive: isActive,
          isCritical: isCritical,
          name: name,
          sortOrder: sortOrder,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
