//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_httpx_dto_error_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_error_response.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse
///
/// Properties:
/// * [error] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder> {
  @BuiltValueField(wireName: r'error')
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? get error;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse object, {
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
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder result,
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
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoErrorResponseBuilder();
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


