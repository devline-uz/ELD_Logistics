//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate
///
/// Properties:
/// * [category] 
/// * [isActive] 
/// * [isCritical] 
/// * [name] 
/// * [sortOrder] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate, GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder> {
  @BuiltValueField(wireName: r'category')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum get category;
  // enum categoryEnum {  truck,  trailer,  };

  @BuiltValueField(wireName: r'is_active')
  bool? get isActive;

  @BuiltValueField(wireName: r'is_critical')
  bool? get isCritical;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum),
    );
    if (object.isActive != null) {
      yield r'is_active';
      yield serializers.serialize(
        object.isActive,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isCritical != null) {
      yield r'is_critical';
      yield serializers.serialize(
        object.isCritical,
        specifiedType: const FullType(bool),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.sortOrder != null) {
      yield r'sort_order';
      yield serializers.serialize(
        object.sortOrder,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum;
          result.category = valueDes;
          break;
        case r'is_active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isActive = valueDes;
          break;
        case r'is_critical':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isCritical = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sortOrder = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'truck')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum truck = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_truck;
  @BuiltValueEnumConst(wireName: r'trailer')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum trailer = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_trailer;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCreateCategoryEnumValueOf(name);
}

