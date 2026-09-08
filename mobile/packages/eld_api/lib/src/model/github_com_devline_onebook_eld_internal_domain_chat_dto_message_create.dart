//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_message_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate
///
/// Properties:
/// * [fileKey] - FileKey is the storage key returned by POST /files/presign; required for image and file messages.
/// * [kind] 
/// * [lat] - Lat and Lng are required for a location message.
/// * [lng] 
/// * [text] - Text is required for a text message and optional as a caption otherwise.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate, GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder> {
  /// FileKey is the storage key returned by POST /files/presign; required for image and file messages.
  @BuiltValueField(wireName: r'file_key')
  String? get fileKey;

  @BuiltValueField(wireName: r'kind')
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum get kind;
  // enum kindEnum {  text,  image,  file,  location,  };

  /// Lat and Lng are required for a location message.
  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  /// Text is required for a text message and optional as a caption otherwise.
  @BuiltValueField(wireName: r'text')
  String? get text;

  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate, _$GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.fileKey != null) {
      yield r'file_key';
      yield serializers.serialize(
        object.fileKey,
        specifiedType: const FullType(String),
      );
    }
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum),
    );
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
    GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'file_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fileKey = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum),
          ) as GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum;
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
  GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'text')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum text = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_text;
  @BuiltValueEnumConst(wireName: r'image')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum image = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_image;
  @BuiltValueEnumConst(wireName: r'file')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum file = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_file;
  @BuiltValueEnumConst(wireName: r'location')
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum location = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_location;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum> get values => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumValues;
  static GithubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainChatDtoMessageCreateKindEnumValueOf(name);
}

