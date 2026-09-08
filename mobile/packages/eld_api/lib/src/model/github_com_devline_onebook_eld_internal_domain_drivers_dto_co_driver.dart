//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_co_driver.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver
///
/// Properties:
/// * [driverId] 
/// * [firstName] 
/// * [lastName] 
/// * [pairId] 
/// * [pairedAt] 
/// * [status] 
/// * [username] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver, GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder> {
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'first_name')
  String? get firstName;

  @BuiltValueField(wireName: r'last_name')
  String? get lastName;

  @BuiltValueField(wireName: r'pair_id')
  String? get pairId;

  @BuiltValueField(wireName: r'paired_at')
  DateTime? get pairedAt;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum? get status;
  // enum statusEnum {  invited,  active,  inactive,  };

  @BuiltValueField(wireName: r'username')
  String? get username;

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver, _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
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
    if (object.lastName != null) {
      yield r'last_name';
      yield serializers.serialize(
        object.lastName,
        specifiedType: const FullType(String),
      );
    }
    if (object.pairId != null) {
      yield r'pair_id';
      yield serializers.serialize(
        object.pairId,
        specifiedType: const FullType(String),
      );
    }
    if (object.pairedAt != null) {
      yield r'paired_at';
      yield serializers.serialize(
        object.pairedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum),
      );
    }
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'first_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.firstName = valueDes;
          break;
        case r'last_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastName = valueDes;
          break;
        case r'pair_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pairId = valueDes;
          break;
        case r'paired_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.pairedAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'invited')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum invited = _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_invited;
  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum active = _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDriversDtoCoDriverStatusEnumValueOf(name);
}

