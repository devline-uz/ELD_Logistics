//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoDriver
///
/// Properties:
/// * [activatedOn] 
/// * [address1] 
/// * [address2] 
/// * [appVersion] 
/// * [branchId] 
/// * [branchName] 
/// * [city] 
/// * [createdAt] 
/// * [defaultUnitId] 
/// * [defaultUnitNumber] 
/// * [email] 
/// * [firstName] 
/// * [fleetManagerId] 
/// * [fleetManagerName] 
/// * [homeTerminal] 
/// * [id] 
/// * [lastLoginAt] 
/// * [lastName] 
/// * [licenseNoMasked] 
/// * [licenseRegion] 
/// * [notes] 
/// * [phone] 
/// * [state] 
/// * [status] 
/// * [updatedAt] 
/// * [userId] 
/// * [userStatus] 
/// * [username] 
/// * [zip] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoDriver implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoDriver, GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder> {
  @BuiltValueField(wireName: r'activated_on')
  DateTime? get activatedOn;

  @BuiltValueField(wireName: r'address1')
  String? get address1;

  @BuiltValueField(wireName: r'address2')
  String? get address2;

  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'branch_name')
  String? get branchName;

  @BuiltValueField(wireName: r'city')
  String? get city;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'default_unit_id')
  String? get defaultUnitId;

  @BuiltValueField(wireName: r'default_unit_number')
  String? get defaultUnitNumber;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'first_name')
  String? get firstName;

  @BuiltValueField(wireName: r'fleet_manager_id')
  String? get fleetManagerId;

  @BuiltValueField(wireName: r'fleet_manager_name')
  String? get fleetManagerName;

  @BuiltValueField(wireName: r'home_terminal')
  String? get homeTerminal;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'last_login_at')
  DateTime? get lastLoginAt;

  @BuiltValueField(wireName: r'last_name')
  String? get lastName;

  @BuiltValueField(wireName: r'license_no_masked')
  String? get licenseNoMasked;

  @BuiltValueField(wireName: r'license_region')
  String? get licenseRegion;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'state')
  String? get state;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum? get status;
  // enum statusEnum {  invited,  active,  inactive,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'user_id')
  String? get userId;

  @BuiltValueField(wireName: r'user_status')
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum? get userStatus;
  // enum userStatusEnum {  invited,  active,  inactive,  };

  @BuiltValueField(wireName: r'username')
  String? get username;

  @BuiltValueField(wireName: r'zip')
  String? get zip;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriver._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoDriver([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriver;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriver> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriver> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoDriver, _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriver];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriver';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.activatedOn != null) {
      yield r'activated_on';
      yield serializers.serialize(
        object.activatedOn,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.address1 != null) {
      yield r'address1';
      yield serializers.serialize(
        object.address1,
        specifiedType: const FullType(String),
      );
    }
    if (object.address2 != null) {
      yield r'address2';
      yield serializers.serialize(
        object.address2,
        specifiedType: const FullType(String),
      );
    }
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.branchName != null) {
      yield r'branch_name';
      yield serializers.serialize(
        object.branchName,
        specifiedType: const FullType(String),
      );
    }
    if (object.city != null) {
      yield r'city';
      yield serializers.serialize(
        object.city,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.defaultUnitId != null) {
      yield r'default_unit_id';
      yield serializers.serialize(
        object.defaultUnitId,
        specifiedType: const FullType(String),
      );
    }
    if (object.defaultUnitNumber != null) {
      yield r'default_unit_number';
      yield serializers.serialize(
        object.defaultUnitNumber,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.firstName != null) {
      yield r'first_name';
      yield serializers.serialize(
        object.firstName,
        specifiedType: const FullType(String),
      );
    }
    if (object.fleetManagerId != null) {
      yield r'fleet_manager_id';
      yield serializers.serialize(
        object.fleetManagerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.fleetManagerName != null) {
      yield r'fleet_manager_name';
      yield serializers.serialize(
        object.fleetManagerName,
        specifiedType: const FullType(String),
      );
    }
    if (object.homeTerminal != null) {
      yield r'home_terminal';
      yield serializers.serialize(
        object.homeTerminal,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.lastLoginAt != null) {
      yield r'last_login_at';
      yield serializers.serialize(
        object.lastLoginAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.lastName != null) {
      yield r'last_name';
      yield serializers.serialize(
        object.lastName,
        specifiedType: const FullType(String),
      );
    }
    if (object.licenseNoMasked != null) {
      yield r'license_no_masked';
      yield serializers.serialize(
        object.licenseNoMasked,
        specifiedType: const FullType(String),
      );
    }
    if (object.licenseRegion != null) {
      yield r'license_region';
      yield serializers.serialize(
        object.licenseRegion,
        specifiedType: const FullType(String),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
    if (object.state != null) {
      yield r'state';
      yield serializers.serialize(
        object.state,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.userId != null) {
      yield r'user_id';
      yield serializers.serialize(
        object.userId,
        specifiedType: const FullType(String),
      );
    }
    if (object.userStatus != null) {
      yield r'user_status';
      yield serializers.serialize(
        object.userStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum),
      );
    }
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
    if (object.zip != null) {
      yield r'zip';
      yield serializers.serialize(
        object.zip,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'activated_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.activatedOn = valueDes;
          break;
        case r'address1':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address1 = valueDes;
          break;
        case r'address2':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address2 = valueDes;
          break;
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'branch_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchName = valueDes;
          break;
        case r'city':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.city = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'default_unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultUnitId = valueDes;
          break;
        case r'default_unit_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultUnitNumber = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'first_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.firstName = valueDes;
          break;
        case r'fleet_manager_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fleetManagerId = valueDes;
          break;
        case r'fleet_manager_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fleetManagerName = valueDes;
          break;
        case r'home_terminal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.homeTerminal = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'last_login_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastLoginAt = valueDes;
          break;
        case r'last_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastName = valueDes;
          break;
        case r'license_no_masked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licenseNoMasked = valueDes;
          break;
        case r'license_region':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licenseRegion = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.state = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userId = valueDes;
          break;
        case r'user_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum?;
          if (valueDes == null) continue;
          result.userStatus = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.username = valueDes;
          break;
        case r'zip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.zip = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriver deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'invited')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum invited = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum_invited;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum active = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverStatusEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'invited')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum invited = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum_invited;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum active = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDriversDtoDriverUserStatusEnumValueOf(name);
}

