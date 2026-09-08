//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_input.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput
///
/// Properties:
/// * [defectTypeId] 
/// * [note] 
/// * [photoKeys] - PhotoKeys are object storage keys produced by POST /files/presign (kind `dvir_photo`). At most five per defect (Q27.1).
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput, GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder> {
  @BuiltValueField(wireName: r'defect_type_id')
  String get defectTypeId;

  @BuiltValueField(wireName: r'note')
  String? get note;

  /// PhotoKeys are object storage keys produced by POST /files/presign (kind `dvir_photo`). At most five per defect (Q27.1).
  @BuiltValueField(wireName: r'photo_keys')
  BuiltList<String>? get photoKeys;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'defect_type_id';
    yield serializers.serialize(
      object.defectTypeId,
      specifiedType: const FullType(String),
    );
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
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'defect_type_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.defectTypeId = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInputBuilder();
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


