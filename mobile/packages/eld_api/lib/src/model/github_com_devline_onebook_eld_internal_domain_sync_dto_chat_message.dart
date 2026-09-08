//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_chat_message.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage
///
/// Properties:
/// * [deliveredAt] 
/// * [fileKey] 
/// * [id] 
/// * [kind] 
/// * [lat] 
/// * [lng] 
/// * [readAt] 
/// * [senderId] 
/// * [sentAt] 
/// * [text] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage, GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder> {
  @BuiltValueField(wireName: r'delivered_at')
  DateTime? get deliveredAt;

  @BuiltValueField(wireName: r'file_key')
  String? get fileKey;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'kind')
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum? get kind;
  // enum kindEnum {  text,  image,  file,  location,  };

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'read_at')
  DateTime? get readAt;

  @BuiltValueField(wireName: r'sender_id')
  String? get senderId;

  @BuiltValueField(wireName: r'sent_at')
  DateTime? get sentAt;

  @BuiltValueField(wireName: r'text')
  String? get text;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage, _$GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.deliveredAt != null) {
      yield r'delivered_at';
      yield serializers.serialize(
        object.deliveredAt,
        specifiedType: const FullType(DateTime),
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum),
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
    if (object.sentAt != null) {
      yield r'sent_at';
      yield serializers.serialize(
        object.sentAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.text != null) {
      yield r'text';
      yield serializers.serialize(
        object.text,
        specifiedType: const FullType(String),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder result,
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum?;
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
        case r'sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.sentAt = valueDes;
          break;
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.text = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'text')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum text = _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_text;
  @BuiltValueEnumConst(wireName: r'image')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum image = _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_image;
  @BuiltValueEnumConst(wireName: r'file')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum file = _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_file;
  @BuiltValueEnumConst(wireName: r'location')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum location = _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_location;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoChatMessageKindEnumValueOf(name);
}

