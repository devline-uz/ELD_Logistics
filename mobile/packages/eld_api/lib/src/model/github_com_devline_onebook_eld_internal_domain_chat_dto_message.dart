//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_message.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoMessage
///
/// Properties:
/// * [deliveredAt] 
/// * [driverId] 
/// * [fileKey] 
/// * [id] 
/// * [kind] 
/// * [lat] 
/// * [lng] 
/// * [readAt] 
/// * [senderId] 
/// * [senderSide] 
/// * [sentAt] 
/// * [status] 
/// * [text] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoMessage implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoMessage, GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder> {
  @BuiltValueField(wireName: r'delivered_at')
  DateTime? get deliveredAt;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'file_key')
  String? get fileKey;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'kind')
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum? get kind;
  // enum kindEnum {  text,  image,  file,  location,  };

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'read_at')
  DateTime? get readAt;

  @BuiltValueField(wireName: r'sender_id')
  String? get senderId;

  @BuiltValueField(wireName: r'sender_side')
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum? get senderSide;
  // enum senderSideEnum {  driver,  office,  };

  @BuiltValueField(wireName: r'sent_at')
  DateTime? get sentAt;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum? get status;
  // enum statusEnum {  sent,  delivered,  read,  };

  @BuiltValueField(wireName: r'text')
  String? get text;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessage._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoMessage([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoMessage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessage> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessage> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoMessage, _$GithubComDevlineOnebookEldInternalDomainChatDtoMessage];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoMessage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.deliveredAt != null) {
      yield r'delivered_at';
      yield serializers.serialize(
        object.deliveredAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.fileKey != null) {
      yield r'file_key';
      yield serializers.serialize(
        object.fileKey,
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
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum),
      );
    }
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType(num),
      );
    }
    if (object.readAt != null) {
      yield r'read_at';
      yield serializers.serialize(
        object.readAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.senderId != null) {
      yield r'sender_id';
      yield serializers.serialize(
        object.senderId,
        specifiedType: const FullType(String),
      );
    }
    if (object.senderSide != null) {
      yield r'sender_side';
      yield serializers.serialize(
        object.senderSide,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum),
      );
    }
    if (object.sentAt != null) {
      yield r'sent_at';
      yield serializers.serialize(
        object.sentAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum),
      );
    }
    if (object.text != null) {
      yield r'text';
      yield serializers.serialize(
        object.text,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delivered_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deliveredAt = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'file_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fileKey = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lng = valueDes;
          break;
        case r'read_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        case r'sender_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.senderId = valueDes;
          break;
        case r'sender_side':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum?;
          if (valueDes == null) continue;
          result.senderSide = valueDes;
          break;
        case r'sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.sentAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.text = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoMessage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoMessageBuilder();
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


class GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'text')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum text = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum_text;
  @BuiltValueEnumConst(wireName: r'image')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum image = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum_image;
  @BuiltValueEnumConst(wireName: r'file')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum file = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum_file;
  @BuiltValueEnumConst(wireName: r'location')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum location = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum_location;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum> get values => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnumValues;
  static GithubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageKindEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'driver')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum driver = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum_driver;
  @BuiltValueEnumConst(wireName: r'office')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum office = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum_office;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum> get values => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnumValues;
  static GithubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageSenderSideEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'sent')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum sent = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum_sent;
  @BuiltValueEnumConst(wireName: r'delivered')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum delivered = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum_delivered;
  @BuiltValueEnumConst(wireName: r'read')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum read = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum_read;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageStatusEnumValueOf(name);
}

