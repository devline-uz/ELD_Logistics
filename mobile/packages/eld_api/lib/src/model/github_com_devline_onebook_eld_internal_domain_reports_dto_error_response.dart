//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_httpx_dto_error_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_reports_dto_error_response.g.dart';

/// GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse
///
/// Properties:
/// * [error] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse implements Built<GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse, GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponseBuilder> {
  @BuiltValueField(wireName: r'error')
  GithubComDevlineOnebookEldInternalHttpxDtoErrorBody? get error;

  GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse._();

  factory GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse([void updates(GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponseBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse> get serializer => _$GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponseSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponseSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse, _$GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse object, {
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
    GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponseBuilder result,
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
  GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainReportsDtoErrorResponseBuilder();
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


