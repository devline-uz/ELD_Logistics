//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_httpx_dto_field_error.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_httpx_dto_error_body.g.dart';

/// GithubComDevlineOnebookEldInternalHttpxDtoErrorBody
///
/// Properties:
/// * [code] 
/// * [details] 
/// * [message] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalHttpxDtoErrorBody implements Built<GithubComDevlineOnebookEldInternalHttpxDtoErrorBody, GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder> {
  @BuiltValueField(wireName: r'code')
  String? get code;

  @BuiltValueField(wireName: r'details')
  BuiltList<GithubComDevlineOnebookEldInternalHttpxDtoFieldError>? get details;

  @BuiltValueField(wireName: r'message')
  String? get message;

  GithubComDevlineOnebookEldInternalHttpxDtoErrorBody._();

  factory GithubComDevlineOnebookEldInternalHttpxDtoErrorBody([void updates(GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder b)]) = _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalHttpxDtoErrorBody> get serializer => _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBodySerializer();
}

class _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBodySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalHttpxDtoErrorBody> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalHttpxDtoErrorBody, _$GithubComDevlineOnebookEldInternalHttpxDtoErrorBody];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalHttpxDtoErrorBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalHttpxDtoErrorBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalHttpxDtoFieldError)]),
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
    GithubComDevlineOnebookEldInternalHttpxDtoErrorBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalHttpxDtoFieldError)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalHttpxDtoFieldError>?;
          if (valueDes == null) continue;
          result.details.replace(valueDes);
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
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalHttpxDtoErrorBodyBuilder();
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


