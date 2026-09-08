//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_files_dto_presign_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_files_dto_presign_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope, GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse? get data;

  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope, _$GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse),
          ) as GithubComDevlineOnebookEldInternalDomainFilesDtoPresignResponse?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFilesDtoPresignEnvelopeBuilder();
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


