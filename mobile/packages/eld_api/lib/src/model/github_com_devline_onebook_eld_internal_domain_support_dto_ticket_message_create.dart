//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_message_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate
///
/// Properties:
/// * [attachments] 
/// * [text] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate, GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder> {
  @BuiltValueField(wireName: r'attachments')
  BuiltList<String> get attachments;

  @BuiltValueField(wireName: r'text')
  String get text;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate, _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'attachments';
    yield serializers.serialize(
      object.attachments,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'text';
    yield serializers.serialize(
      object.text,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder result,
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
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoTicketMessageCreateBuilder();
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


