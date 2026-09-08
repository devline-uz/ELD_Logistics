//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDefect
///
/// Properties:
/// * [category] 
/// * [defectTypeId] 
/// * [isCritical] 
/// * [name] 
/// * [note] 
/// * [photoKeys] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDefect implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDefect, GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder> {
  @BuiltValueField(wireName: r'category')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum? get category;
  // enum categoryEnum {  truck,  trailer,  };

  @BuiltValueField(wireName: r'defect_type_id')
  String? get defectTypeId;

  @BuiltValueField(wireName: r'is_critical')
  bool? get isCritical;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'photo_keys')
  BuiltList<String>? get photoKeys;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefect._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDefect([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefect> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefect> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDefect, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefect];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefect';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefect object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum),
      );
    }
    if (object.defectTypeId != null) {
      yield r'defect_type_id';
      yield serializers.serialize(
        object.defectTypeId,
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
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.photoKeys != null) {
      yield r'photo_keys';
      yield serializers.serialize(
        object.photoKeys,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefect object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'defect_type_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defectTypeId = valueDes;
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
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'photo_keys':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.photoKeys.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefect deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDefectBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'truck')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum truck = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_truck;
  @BuiltValueEnumConst(wireName: r'trailer')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum trailer = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_trailer;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDefectCategoryEnumValueOf(name);
}

