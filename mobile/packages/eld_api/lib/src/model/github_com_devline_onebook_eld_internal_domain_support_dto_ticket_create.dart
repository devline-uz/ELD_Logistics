//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate
///
/// Properties:
/// * [attachments] - Attachments are storage file keys returned by POST /files/presign, max three. A key of another company is rejected (422).
/// * [contactOn] - ContactOn is the answer channel the reporter picked (Q78).
/// * [description] 
/// * [subject] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate, GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder> {
  /// Attachments are storage file keys returned by POST /files/presign, max three. A key of another company is rejected (422).
  @BuiltValueField(wireName: r'attachments')
  BuiltList<String> get attachments;

  /// ContactOn is the answer channel the reporter picked (Q78).
  @BuiltValueField(wireName: r'contact_on')
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum? get contactOn;
  // enum contactOnEnum {  email,  phone,  sms,  in_app,  };

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'subject')
  String get subject;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate, _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'attachments';
    yield serializers.serialize(
      object.attachments,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.contactOn != null) {
      yield r'contact_on';
      yield serializers.serialize(
        object.contactOn,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'subject';
    yield serializers.serialize(
      object.subject,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'attachments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.attachments.replace(valueDes);
          break;
        case r'contact_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum?;
          if (valueDes == null) continue;
          result.contactOn = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'subject':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subject = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateBuilder();
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


/// ContactOn is the answer channel the reporter picked (Q78).
class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum email = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_email;
  @BuiltValueEnumConst(wireName: r'phone')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum phone = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_phone;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum sms = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_sms;
  @BuiltValueEnumConst(wireName: r'in_app')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum inApp = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_inApp;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum> get values => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketCreateContactOnEnumValueOf(name);
}

