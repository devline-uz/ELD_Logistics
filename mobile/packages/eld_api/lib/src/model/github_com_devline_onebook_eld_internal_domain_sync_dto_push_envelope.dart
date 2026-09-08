//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_push_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_push_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope, GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse? get data;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope, _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse?;
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoPushEnvelopeBuilder();
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


