//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_httpx_dto_error_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_error_response.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse
///
/// Properties:
/// * [error] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse, GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponseBuilder> {
  @BuiltValueField(wireName: r'error')
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? get error;

  GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponseBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponseSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponseSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse, _$GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalHttpxDtoErrorBody),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalHttpxDtoErrorBody),
          ) as GithubComDevlineOnebookEldInternalHttpxDtoErrorBody?;
          if (valueDes == null) continue;
          result.error.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoErrorResponseBuilder();
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


