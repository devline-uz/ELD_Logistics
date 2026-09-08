//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_reset_password_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult
///
/// Properties:
/// * [channel] 
/// * [driverId] 
/// * [expiresAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult, GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder> {
  @BuiltValueField(wireName: r'channel')
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum? get channel;
  // enum channelEnum {  email,  sms,  };

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'expires_at')
  DateTime? get expiresAt;

  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult, _$GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.channel != null) {
      yield r'channel';
      yield serializers.serialize(
        object.channel,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresAt != null) {
      yield r'expires_at';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum?;
          if (valueDes == null) continue;
          result.channel = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum email = _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum sms = _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_sms;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum> get values => _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDriversDtoResetPasswordResultChannelEnumValueOf(name);
}

