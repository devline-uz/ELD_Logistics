//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_httpx_dto_field_error.g.dart';

/// GithubComDevlineOnebookEldInternalHttpxDtoFieldError
///
/// Properties:
/// * [field] 
/// * [message] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalHttpxDtoFieldError implements Built<GithubComDevlineOnebookEldInternalHttpxDtoFieldError, GithubComDevlineOnebookEldInternalHttpxDtoFieldErrorBuilder> {
  @BuiltValueField(wireName: r'field')
  String? get field;

  @BuiltValueField(wireName: r'message')
  String? get message;

  GithubComDevlineOnebookEldInternalHttpxDtoFieldError._();

  factory GithubComDevlineOnebookEldInternalHttpxDtoFieldError([void updates(GithubComDevlineOnebookEldInternalHttpxDtoFieldErrorBuilder b)]) = _$GithubComDevlineOnebookEldInternalHttpxDtoFieldError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalHttpxDtoFieldErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalHttpxDtoFieldError> get serializer => _$GithubComDevlineOnebookEldInternalHttpxDtoFieldErrorSerializer();
}

class _$GithubComDevlineOnebookEldInternalHttpxDtoFieldErrorSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalHttpxDtoFieldError> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalHttpxDtoFieldError, _$GithubComDevlineOnebookEldInternalHttpxDtoFieldError];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalHttpxDtoFieldError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalHttpxDtoFieldError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.field != null) {
      yield r'field';
      yield serializers.serialize(
        object.field,
        specifiedType: const FullType(String),
      );
    }
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalHttpxDtoFieldError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalHttpxDtoFieldErrorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.field = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalHttpxDtoFieldError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalHttpxDtoFieldErrorBuilder();
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


