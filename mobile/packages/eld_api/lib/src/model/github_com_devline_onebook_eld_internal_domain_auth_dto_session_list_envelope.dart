//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_meta.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auth_dto_session.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_session_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope, GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainAuthDtoSession>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainAuthDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope, _$GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoSession)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoSession)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainAuthDtoSession>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoMeta?;
          if (valueDes == null) continue;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoSessionListEnvelopeBuilder();
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


