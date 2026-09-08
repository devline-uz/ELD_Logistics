//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_pull_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_pull_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope, GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse? get data;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope, _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse?;
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoPullEnvelopeBuilder();
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


