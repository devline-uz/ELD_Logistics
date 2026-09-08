// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_truck =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum._(
        'truck');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_trailer =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum._(
        'trailer');
const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_unknownDefaultOpenApi =
    const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum._(
        'unknownDefaultOpenApi');

GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumValueOf(
        String name) {
  switch (name) {
    case 'truck':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_truck;
    case 'trailer':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_trailer;
    case 'unknownDefaultOpenApi':
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumValues =
    BuiltSet<
        GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum>(const <GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum>[
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_truck,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_trailer,
  _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_unknownDefaultOpenApi,
]);

Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum>
    _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumSerializer =
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumSerializer();

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumSerializer
    implements
        PrimitiveSerializer<
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum> {
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
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum
  ];
  @override
  final String wireName =
      'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum';

  @override
  Object serialize(
          Serializers serializers,
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDefect {
  @override
  final GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum?
      category;
  @override
  final String? defectTypeId;
  @override
  final bool? isCritical;
  @override
  final String? name;
  @override
  final String? note;
  @override
  final BuiltList<String>? photoKeys;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect._(
      {this.category,
      this.defectTypeId,
      this.isCritical,
      this.name,
      this.note,
      this.photoKeys})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefect rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder toBuilder() =>
      GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDvirDtoDefect &&
        category == other.category &&
        defectTypeId == other.defectTypeId &&
        isCritical == other.isCritical &&
        name == other.name &&
        note == other.note &&
        photoKeys == other.photoKeys;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, defectTypeId.hashCode);
    _$hash = $jc(_$hash, isCritical.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, photoKeys.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefect')
          ..add('category', category)
          ..add('defectTypeId', defectTypeId)
          ..add('isCritical', isCritical)
          ..add('name', name)
          ..add('note', note)
          ..add('photoKeys', photoKeys))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDefect,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect? _$v;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum? _category;
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum?
      get category => _$this._category;
  set category(
          GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum?
              category) =>
      _$this._category = category;

  String? _defectTypeId;
  String? get defectTypeId => _$this._defectTypeId;
  set defectTypeId(String? defectTypeId) => _$this._defectTypeId = defectTypeId;

  bool? _isCritical;
  bool? get isCritical => _$this._isCritical;
  set isCritical(bool? isCritical) => _$this._isCritical = isCritical;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<String>? _photoKeys;
  ListBuilder<String> get photoKeys =>
      _$this._photoKeys ??= ListBuilder<String>();
  set photoKeys(ListBuilder<String>? photoKeys) =>
      _$this._photoKeys = photoKeys;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefect._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _defectTypeId = $v.defectTypeId;
      _isCritical = $v.isCritical;
      _name = $v.name;
      _note = $v.note;
      _photoKeys = $v.photoKeys?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GithubComDevlineOnebookEldInternalDomainDvirDtoDefect other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefect build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect _build() {
    _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect._(
            category: category,
            defectTypeId: defectTypeId,
            isCritical: isCritical,
            name: name,
            note: note,
            photoKeys: _photoKeys?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photoKeys';
        _photoKeys?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefect',
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
