//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_feedback_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate
///
/// Properties:
/// * [appRating] 
/// * [text] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate, GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder> {
  @BuiltValueField(wireName: r'app_rating')
  int? get appRating;

  @BuiltValueField(wireName: r'text')
  String? get text;

  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate, _$GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appRating != null) {
      yield r'app_rating';
      yield serializers.serialize(
        object.appRating,
        specifiedType: const FullType(int),
      );
    }
    if (object.text != null) {
      yield r'text';
      yield serializers.serialize(
        object.text,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app_rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.appRating = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.text = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoFeedbackCreateBuilder();
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


