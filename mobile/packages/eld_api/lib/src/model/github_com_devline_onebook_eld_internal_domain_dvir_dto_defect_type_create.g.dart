// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_truck =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
        ._('truck');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_trailer =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
        ._('trailer');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
        ._('unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumValueOf(
        String name) {
  switch (name) {
    case 'truck':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_truck;
    case 'trailer':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_trailer;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum>(const <GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum>[
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_truck,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_trailer,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_unknownDefaultOpenApi,
]);

Serializer<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum> {
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
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate {
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum
      category;
  @override
  final bool? isActive;
  @override
  final bool? isCritical;
  @override
  final String name;
  @override
  final int? sortOrder;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate._(
      {required this.category,
      this.isActive,
      this.isCritical,
      required this.name,
      this.sortOrder})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate &&
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
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate')
          ..add('category', category)
          ..add('isActive', isActive)
          ..add('isCritical', isCritical)
          ..add('name', name)
          ..add('sortOrder', sortOrder))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate? _$v;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum?
      _category;
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum?
      get category => _$this._category;
  set category(
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum?
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

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder
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
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate._(
          category: BuiltValueNullFieldError.checkNotNull(
              category,
              r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate',
              'category'),
          isActive: isActive,
          isCritical: isCritical,
          name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate',
              'name'),
          sortOrder: sortOrder,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
