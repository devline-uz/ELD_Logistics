//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType
///
/// Properties:
/// * [category] 
/// * [createdAt] 
/// * [id] 
/// * [isActive] 
/// * [isCritical] 
/// * [isSystem] - IsSystem marks a default catalogue row (company_id IS NULL); it is readable by every tenant but only editable as a company copy.
/// * [name] 
/// * [sortOrder] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType, GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder> {
  @BuiltValueField(wireName: r'category')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum? get category;
  // enum categoryEnum {  truck,  trailer,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'is_active')
  bool? get isActive;

  @BuiltValueField(wireName: r'is_critical')
  bool? get isCritical;

  /// IsSystem marks a default catalogue row (company_id IS NULL); it is readable by every tenant but only editable as a company copy.
  @BuiltValueField(wireName: r'is_system')
  bool? get isSystem;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
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
    if (object.isSystem != null) {
      yield r'is_system';
      yield serializers.serialize(
        object.isSystem,
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
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
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
        case r'is_system':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isSystem = valueDes;
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'truck')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum truck = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_truck;
  @BuiltValueEnumConst(wireName: r'trailer')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum trailer = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_trailer;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeCategoryEnumValueOf(name);
}

