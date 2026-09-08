//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_support_dto_ticket.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSupportDtoTicket
///
/// Properties:
/// * [attachments] - Attachments are storage file keys, at most three (Q77).
/// * [contactOn] - ContactOn is the channel the reporter wants an answer on (Q78).
/// * [createdAt] 
/// * [createdBy] - CreatedBy is the user that filed the ticket.
/// * [creatorName] 
/// * [description] 
/// * [driverId] - DriverID is set when the ticket was filed from the driver app.
/// * [driverName] 
/// * [id] 
/// * [messageCount] 
/// * [resolvedAt] 
/// * [status] 
/// * [subject] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSupportDtoTicket implements Built<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket, GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder> {
  /// Attachments are storage file keys, at most three (Q77).
  @BuiltValueField(wireName: r'attachments')
  BuiltList<String>? get attachments;

  /// ContactOn is the channel the reporter wants an answer on (Q78).
  @BuiltValueField(wireName: r'contact_on')
  String? get contactOn;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  /// CreatedBy is the user that filed the ticket.
  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'creator_name')
  String? get creatorName;

  @BuiltValueField(wireName: r'description')
  String? get description;

  /// DriverID is set when the ticket was filed from the driver app.
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'message_count')
  int? get messageCount;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum? get status;
  // enum statusEnum {  new,  in_progress,  resolved,  closed,  };

  @BuiltValueField(wireName: r'subject')
  String? get subject;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainSupportDtoTicket._();

  factory GithubComDevlineOnebookEldInternalDomainSupportDtoTicket([void updates(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket> get serializer => _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicketSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicket> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSupportDtoTicket, _$GithubComDevlineOnebookEldInternalDomainSupportDtoTicket];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSupportDtoTicket';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicket object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.attachments != null) {
      yield r'attachments';
      yield serializers.serialize(
        object.attachments,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.contactOn != null) {
      yield r'contact_on';
      yield serializers.serialize(
        object.contactOn,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.creatorName != null) {
      yield r'creator_name';
      yield serializers.serialize(
        object.creatorName,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.messageCount != null) {
      yield r'message_count';
      yield serializers.serialize(
        object.messageCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.resolvedAt != null) {
      yield r'resolved_at';
      yield serializers.serialize(
        object.resolvedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum),
      );
    }
    if (object.subject != null) {
      yield r'subject';
      yield serializers.serialize(
        object.subject,
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
    GithubComDevlineOnebookEldInternalDomainSupportDtoTicket object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'attachments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.attachments.replace(valueDes);
          break;
        case r'contact_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.contactOn = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'creator_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.creatorName = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'message_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.messageCount = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'subject':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subject = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainSupportDtoTicket deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSupportDtoTicketBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'new')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum new_ = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_new_;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum inProgress = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum resolved = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_resolved;
  @BuiltValueEnumConst(wireName: r'closed')
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum closed = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_closed;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSupportDtoTicketStatusEnumValueOf(name);
}

