//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_notifications_dto_notification.g.dart';

/// GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification
///
/// Properties:
/// * [alertType] 
/// * [body] 
/// * [channels] 
/// * [createdAt] 
/// * [entityId] 
/// * [entityType] 
/// * [id] 
/// * [read] 
/// * [readAt] 
/// * [sentAt] 
/// * [title] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification implements Built<GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification, GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationBuilder> {
  @BuiltValueField(wireName: r'alert_type')
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum? get alertType;
  // enum alertTypeEnum {  hos_warning,  hos_violation,  route_assigned,  route_completed,  dvir_defects,  dvir_critical,  log_edit_request,  log_edit_resolved,  uncertified_log,  unidentified_driving,  eld_disconnected,  eld_malfunction,  maintenance_upcoming,  maintenance_overdue,  chat_message,  subscription_expiring,  };

  @BuiltValueField(wireName: r'body')
  String? get body;

  @BuiltValueField(wireName: r'channels')
  BuiltList<String>? get channels;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'entity_id')
  String? get entityId;

  @BuiltValueField(wireName: r'entity_type')
  String? get entityType;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'read')
  bool? get read;

  @BuiltValueField(wireName: r'read_at')
  DateTime? get readAt;

  @BuiltValueField(wireName: r'sent_at')
  DateTime? get sentAt;

  @BuiltValueField(wireName: r'title')
  String? get title;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification._();

  factory GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification([void updates(GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification> get serializer => _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification, _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.alertType != null) {
      yield r'alert_type';
      yield serializers.serialize(
        object.alertType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum),
      );
    }
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType(String),
      );
    }
    if (object.channels != null) {
      yield r'channels';
      yield serializers.serialize(
        object.channels,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.entityId != null) {
      yield r'entity_id';
      yield serializers.serialize(
        object.entityId,
        specifiedType: const FullType(String),
      );
    }
    if (object.entityType != null) {
      yield r'entity_type';
      yield serializers.serialize(
        object.entityType,
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
    if (object.read != null) {
      yield r'read';
      yield serializers.serialize(
        object.read,
        specifiedType: const FullType(bool),
      );
    }
    if (object.readAt != null) {
      yield r'read_at';
      yield serializers.serialize(
        object.readAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.sentAt != null) {
      yield r'sent_at';
      yield serializers.serialize(
        object.sentAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'alert_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum?;
          if (valueDes == null) continue;
          result.alertType = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.body = valueDes;
          break;
        case r'channels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.channels.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.entityId = valueDes;
          break;
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.entityType = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'read':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.read = valueDes;
          break;
        case r'read_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        case r'sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.sentAt = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotification deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationBuilder();
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


class GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'hos_warning')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum hosWarning = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_hosWarning;
  @BuiltValueEnumConst(wireName: r'hos_violation')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum hosViolation = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_hosViolation;
  @BuiltValueEnumConst(wireName: r'route_assigned')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum routeAssigned = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_routeAssigned;
  @BuiltValueEnumConst(wireName: r'route_completed')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum routeCompleted = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_routeCompleted;
  @BuiltValueEnumConst(wireName: r'dvir_defects')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum dvirDefects = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_dvirDefects;
  @BuiltValueEnumConst(wireName: r'dvir_critical')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum dvirCritical = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_dvirCritical;
  @BuiltValueEnumConst(wireName: r'log_edit_request')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum logEditRequest = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_logEditRequest;
  @BuiltValueEnumConst(wireName: r'log_edit_resolved')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum logEditResolved = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_logEditResolved;
  @BuiltValueEnumConst(wireName: r'uncertified_log')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum uncertifiedLog = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_uncertifiedLog;
  @BuiltValueEnumConst(wireName: r'unidentified_driving')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum unidentifiedDriving = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_unidentifiedDriving;
  @BuiltValueEnumConst(wireName: r'eld_disconnected')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum eldDisconnected = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_eldDisconnected;
  @BuiltValueEnumConst(wireName: r'eld_malfunction')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum eldMalfunction = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_eldMalfunction;
  @BuiltValueEnumConst(wireName: r'maintenance_upcoming')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum maintenanceUpcoming = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_maintenanceUpcoming;
  @BuiltValueEnumConst(wireName: r'maintenance_overdue')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum maintenanceOverdue = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_maintenanceOverdue;
  @BuiltValueEnumConst(wireName: r'chat_message')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum chatMessage = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_chatMessage;
  @BuiltValueEnumConst(wireName: r'subscription_expiring')
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum subscriptionExpiring = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_subscriptionExpiring;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainNotificationsDtoNotificationAlertTypeEnumValueOf(name);
}

