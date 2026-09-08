//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate
///
/// Properties:
/// * [address1] 
/// * [address2] 
/// * [branchId] 
/// * [city] 
/// * [coDriverId] - CoDriverID is optional (Q18.1) and creates a symmetric driver_pairs row.
/// * [defaultUnitId] 
/// * [email] 
/// * [firstName] 
/// * [fleetManagerId] 
/// * [homeTerminal] 
/// * [lastName] 
/// * [licenseNo] 
/// * [licenseRegion] 
/// * [notes] 
/// * [phone] 
/// * [state] 
/// * [username] 
/// * [zip] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate, GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreateBuilder> {
  @BuiltValueField(wireName: r'address1')
  String? get address1;

  @BuiltValueField(wireName: r'address2')
  String? get address2;

  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'city')
  String? get city;

  /// CoDriverID is optional (Q18.1) and creates a symmetric driver_pairs row.
  @BuiltValueField(wireName: r'co_driver_id')
  String? get coDriverId;

  @BuiltValueField(wireName: r'default_unit_id')
  String? get defaultUnitId;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'first_name')
  String get firstName;

  @BuiltValueField(wireName: r'fleet_manager_id')
  String? get fleetManagerId;

  @BuiltValueField(wireName: r'home_terminal')
  String? get homeTerminal;

  @BuiltValueField(wireName: r'last_name')
  String get lastName;

  @BuiltValueField(wireName: r'license_no')
  String get licenseNo;

  @BuiltValueField(wireName: r'license_region')
  String? get licenseRegion;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'state')
  String? get state;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'zip')
  String? get zip;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate, _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
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
    if (object.coDriverId != null) {
      yield r'co_driver_id';
      yield serializers.serialize(
        object.coDriverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.defaultUnitId != null) {
      yield r'default_unit_id';
      yield serializers.serialize(
        object.defaultUnitId,
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
    yield r'first_name';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    if (object.fleetManagerId != null) {
      yield r'fleet_manager_id';
      yield serializers.serialize(
        object.fleetManagerId,
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
    yield r'last_name';
    yield serializers.serialize(
      object.lastName,
      specifiedType: const FullType(String),
    );
    yield r'license_no';
    yield serializers.serialize(
      object.licenseNo,
      specifiedType: const FullType(String),
    );
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
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
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
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'city':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.city = valueDes;
          break;
        case r'co_driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.coDriverId = valueDes;
          break;
        case r'default_unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultUnitId = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
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
        case r'home_terminal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.homeTerminal = valueDes;
          break;
        case r'last_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastName = valueDes;
          break;
        case r'license_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.licenseNo = valueDes;
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoDriverCreateBuilder();
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


