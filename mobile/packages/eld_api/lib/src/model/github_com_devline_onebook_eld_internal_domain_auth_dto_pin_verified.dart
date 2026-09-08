//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_pin_verified.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified
///
/// Properties:
/// * [action] 
/// * [sessionResumed] - SessionResumed reports that a paused session was reactivated.
/// * [verified] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified, GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder> {
  @BuiltValueField(wireName: r'action')
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum? get action;
  // enum actionEnum {  switch_driver,  return_to_truck,  };

  /// SessionResumed reports that a paused session was reactivated.
  @BuiltValueField(wireName: r'session_resumed')
  bool? get sessionResumed;

  @BuiltValueField(wireName: r'verified')
  bool? get verified;

  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified, _$GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum),
      );
    }
    if (object.sessionResumed != null) {
      yield r'session_resumed';
      yield serializers.serialize(
        object.sessionResumed,
        specifiedType: const FullType(bool),
      );
    }
    if (object.verified != null) {
      yield r'verified';
      yield serializers.serialize(
        object.verified,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum?;
          if (valueDes == null) continue;
          result.action = valueDes;
          break;
        case r'session_resumed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.sessionResumed = valueDes;
          break;
        case r'verified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.verified = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerified deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedBuilder();
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


class GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'switch_driver')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum switchDriver = _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_switchDriver;
  @BuiltValueEnumConst(wireName: r'return_to_truck')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum returnToTruck = _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_returnToTruck;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuthDtoPINVerifiedActionEnumValueOf(name);
}

