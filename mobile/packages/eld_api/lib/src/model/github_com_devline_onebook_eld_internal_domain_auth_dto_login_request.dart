//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auth_dto_login_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest
///
/// Properties:
/// * [appVersion] 
/// * [companyId] - CompanyID disambiguates a username that exists in several tenants. It is a pre-authentication hint only: the effective tenant always comes from the resolved user row, never from this field.
/// * [deviceId] 
/// * [deviceType] - DeviceType decides which of the three concurrent session slots is used.
/// * [password] 
/// * [totpCode] - TOTPCode is required once two factor authentication is enabled.
/// * [username] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest implements Built<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest, GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder> {
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  /// CompanyID disambiguates a username that exists in several tenants. It is a pre-authentication hint only: the effective tenant always comes from the resolved user row, never from this field.
  @BuiltValueField(wireName: r'company_id')
  String? get companyId;

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  /// DeviceType decides which of the three concurrent session slots is used.
  @BuiltValueField(wireName: r'device_type')
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum get deviceType;
  // enum deviceTypeEnum {  web,  phone,  tablet,  };

  @BuiltValueField(wireName: r'password')
  String get password;

  /// TOTPCode is required once two factor authentication is enabled.
  @BuiltValueField(wireName: r'totp_code')
  String? get totpCode;

  @BuiltValueField(wireName: r'username')
  String get username;

  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest._();

  factory GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest([void updates(GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest, _$GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.companyId != null) {
      yield r'company_id';
      yield serializers.serialize(
        object.companyId,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceId != null) {
      yield r'device_id';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType(String),
      );
    }
    yield r'device_type';
    yield serializers.serialize(
      object.deviceType,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    if (object.totpCode != null) {
      yield r'totp_code';
      yield serializers.serialize(
        object.totpCode,
        specifiedType: const FullType(String),
      );
    }
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'company_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.companyId = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        case r'device_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum;
          result.deviceType = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'totp_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.totpCode = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestBuilder();
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


/// DeviceType decides which of the three concurrent session slots is used.
class GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'web')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum web = _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_web;
  @BuiltValueEnumConst(wireName: r'phone')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum phone = _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'tablet')
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum tablet = _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_tablet;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuthDtoLoginRequestDeviceTypeEnumValueOf(name);
}

