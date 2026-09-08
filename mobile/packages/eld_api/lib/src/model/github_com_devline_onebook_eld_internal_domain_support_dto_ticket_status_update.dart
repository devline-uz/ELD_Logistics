//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket_status_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate, GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder> {
  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum get status;
  // enum statusEnum {  new,  in_progress,  resolved,  };

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate, _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'new')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum new_ = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_new_;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum inProgress = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum resolved = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_resolved;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusUpdateStatusEnumValueOf(name);
}

