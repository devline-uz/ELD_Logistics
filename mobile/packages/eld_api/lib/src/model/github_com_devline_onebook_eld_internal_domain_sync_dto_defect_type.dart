//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_defect_type.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType
///
/// Properties:
/// * [category] 
/// * [id] 
/// * [isCritical] 
/// * [name] 
/// * [sortOrder] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType, GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder> {
  @BuiltValueField(wireName: r'category')
  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum? get category;
  // enum categoryEnum {  truck,  trailer,  };

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'is_critical')
  bool? get isCritical;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType, _$GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
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
    GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'truck')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum truck = _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_truck;
  @BuiltValueEnumConst(wireName: r'trailer')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum trailer = _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_trailer;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoDefectTypeCategoryEnumValueOf(name);
}

