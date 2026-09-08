//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_chat_dto_message.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_thread.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoThread
///
/// Properties:
/// * [driverId] 
/// * [driverName] 
/// * [driverStatus] 
/// * [lastMessage] 
/// * [unreadCount] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoThread implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoThread, GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder> {
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'driver_status')
  GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum? get driverStatus;
  // enum driverStatusEnum {  active,  inactive,  };

  @BuiltValueField(wireName: r'last_message')
  GithubComDevlineOnebookEldInternalDomainChatDtoMessage? get lastMessage;

  @BuiltValueField(wireName: r'unread_count')
  int? get unreadCount;

  GithubComDevlineOnebookEldInternalDomainChatDtoThread._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoThread([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoThread;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoThread> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoThreadSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoThread> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoThread, _$GithubComDevlineOnebookEldInternalDomainChatDtoThread];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoThread';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoThread object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverStatus != null) {
      yield r'driver_status';
      yield serializers.serialize(
        object.driverStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum),
      );
    }
    if (object.lastMessage != null) {
      yield r'last_message';
      yield serializers.serialize(
        object.lastMessage,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessage),
      );
    }
    if (object.unreadCount != null) {
      yield r'unread_count';
      yield serializers.serialize(
        object.unreadCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoThread object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder result,
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
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'driver_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum?;
          if (valueDes == null) continue;
          result.driverStatus = valueDes;
          break;
        case r'last_message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoMessage),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoMessage?;
          if (valueDes == null) continue;
          result.lastMessage.replace(valueDes);
          break;
        case r'unread_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.unreadCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoThread deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoThreadBuilder();
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


class GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum active = _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'inactive')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum inactive = _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_inactive;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainChatDtoThreadDriverStatusEnumValueOf(name);
}

