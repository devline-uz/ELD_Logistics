//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate
///
/// Properties:
/// * [category] 
/// * [isActive] 
/// * [isCritical] 
/// * [name] 
/// * [sortOrder] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate, GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder> {
  @BuiltValueField(wireName: r'category')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum? get category;
  // enum categoryEnum {  truck,  trailer,  };

  @BuiltValueField(wireName: r'is_active')
  bool? get isActive;

  @BuiltValueField(wireName: r'is_critical')
  bool? get isCritical;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum),
      );
    }
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
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
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
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'truck')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum truck = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_truck;
  @BuiltValueEnumConst(wireName: r'trailer')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum trailer = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_trailer;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeUpdateCategoryEnumValueOf(name);
}

