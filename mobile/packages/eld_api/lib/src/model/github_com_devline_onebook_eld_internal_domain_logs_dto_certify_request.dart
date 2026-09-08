//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_certify_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest
///
/// Properties:
/// * [deviceId] 
/// * [signatureId] 
/// * [signatureKey] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest, GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder> {
  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  @BuiltValueField(wireName: r'signature_id')
  String? get signatureId;

  @BuiltValueField(wireName: r'signature_key')
  String? get signatureKey;

  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest, _$GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.deviceId != null) {
      yield r'device_id';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.signatureId != null) {
      yield r'signature_id';
      yield serializers.serialize(
        object.signatureId,
        specifiedType: const FullType(String),
      );
    }
    if (object.signatureKey != null) {
      yield r'signature_key';
      yield serializers.serialize(
        object.signatureKey,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        case r'signature_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.signatureId = valueDes;
          break;
        case r'signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.signatureKey = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoCertifyRequestBuilder();
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


