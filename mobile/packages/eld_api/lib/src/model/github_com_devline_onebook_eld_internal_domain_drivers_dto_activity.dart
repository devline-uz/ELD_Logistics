//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_activity.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoActivity
///
/// Properties:
/// * [action] 
/// * [actorId] 
/// * [field] 
/// * [id] 
/// * [newValue] 
/// * [occurredAt] 
/// * [oldValue] 
/// * [source_] 
/// * [userAgent] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoActivity implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoActivity, GithubComDevlineOnebookEldInternalDomainDriversDtoActivityBuilder> {
  @BuiltValueField(wireName: r'action')
  GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum? get action;
  // enum actionEnum {  create,  update,  soft_delete,  login,  logout,  failed_login,  export,  activate,  deactivate,  password_reset,  session_active,  session_paused,  session_revoked,  };

  @BuiltValueField(wireName: r'actor_id')
  String? get actorId;

  @BuiltValueField(wireName: r'field')
  String? get field;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'new_value')
  String? get newValue;

  @BuiltValueField(wireName: r'occurred_at')
  DateTime? get occurredAt;

  @BuiltValueField(wireName: r'old_value')
  String? get oldValue;

  @BuiltValueField(wireName: r'source')
  GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum? get source_;
  // enum source_Enum {  drivers,  users,  sessions,  audit,  };

  @BuiltValueField(wireName: r'user_agent')
  String? get userAgent;

  GithubComDevlineOnebookEldInternalDomainDriversDtoActivity._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoActivity([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoActivityBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivity;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoActivityBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoActivity> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoActivity> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoActivity, _$GithubComDevlineOnebookEldInternalDomainDriversDtoActivity];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoActivity';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoActivity object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum),
      );
    }
    if (object.actorId != null) {
      yield r'actor_id';
      yield serializers.serialize(
        object.actorId,
        specifiedType: const FullType(String),
      );
    }
    if (object.field != null) {
      yield r'field';
      yield serializers.serialize(
        object.field,
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
    if (object.newValue != null) {
      yield r'new_value';
      yield serializers.serialize(
        object.newValue,
        specifiedType: const FullType(String),
      );
    }
    if (object.occurredAt != null) {
      yield r'occurred_at';
      yield serializers.serialize(
        object.occurredAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.oldValue != null) {
      yield r'old_value';
      yield serializers.serialize(
        object.oldValue,
        specifiedType: const FullType(String),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum),
      );
    }
    if (object.userAgent != null) {
      yield r'user_agent';
      yield serializers.serialize(
        object.userAgent,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoActivity object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoActivityBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum?;
          if (valueDes == null) continue;
          result.action = valueDes;
          break;
        case r'actor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorId = valueDes;
          break;
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.field = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'new_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.newValue = valueDes;
          break;
        case r'occurred_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.occurredAt = valueDes;
          break;
        case r'old_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.oldValue = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'user_agent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userAgent = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoActivity deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoActivityBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'create')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum create = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_create;
  @BuiltValueEnumConst(wireName: r'update')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum update = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_update;
  @BuiltValueEnumConst(wireName: r'soft_delete')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum softDelete = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_softDelete;
  @BuiltValueEnumConst(wireName: r'login')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum login = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_login;
  @BuiltValueEnumConst(wireName: r'logout')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum logout = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_logout;
  @BuiltValueEnumConst(wireName: r'failed_login')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum failedLogin = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_failedLogin;
  @BuiltValueEnumConst(wireName: r'export')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum export_ = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_export_;
  @BuiltValueEnumConst(wireName: r'activate')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum activate = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_activate;
  @BuiltValueEnumConst(wireName: r'deactivate')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum deactivate = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_deactivate;
  @BuiltValueEnumConst(wireName: r'password_reset')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum passwordReset = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_passwordReset;
  @BuiltValueEnumConst(wireName: r'session_active')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum sessionActive = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_sessionActive;
  @BuiltValueEnumConst(wireName: r'session_paused')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum sessionPaused = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_sessionPaused;
  @BuiltValueEnumConst(wireName: r'session_revoked')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum sessionRevoked = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_sessionRevoked;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum> get values => _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDriversDtoActivityActionEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'drivers')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum drivers = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnum_drivers;
  @BuiltValueEnumConst(wireName: r'users')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum users = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnum_users;
  @BuiltValueEnumConst(wireName: r'sessions')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum sessions = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnum_sessions;
  @BuiltValueEnumConst(wireName: r'audit')
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum audit = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnum_audit;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum> get serializer => _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum> get values => _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDriversDtoActivitySource_Enum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDriversDtoActivitySourceEnumValueOf(name);
}

