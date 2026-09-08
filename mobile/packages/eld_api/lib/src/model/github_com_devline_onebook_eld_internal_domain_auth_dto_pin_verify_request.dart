//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_pin_verify_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest
///
/// Properties:
/// * [action] - Action selects what the verified PIN unlocks.
/// * [pin] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder> {
  /// Action selects what the verified PIN unlocks.
  @BuiltValueField(wireName: r'action')
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum? get action;
  // enum actionEnum {  switch_driver,  return_to_truck,  };

  @BuiltValueField(wireName: r'pin')
  String get pin;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum),
      );
    }
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum?;
          if (valueDes == null) continue;
          result.action = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestBuilder();
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


/// Action selects what the verified PIN unlocks.
class GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'switch_driver')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum switchDriver = _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_switchDriver;
  @BuiltValueEnumConst(wireName: r'return_to_truck')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum returnToTruck = _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_returnToTruck;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifyRequestActionEnumValueOf(name);
}

