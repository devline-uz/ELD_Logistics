//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_notification_setting_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate
///
/// Properties:
/// * [alertType] 
/// * [channels] 
/// * [enabled] 
/// * [recipientRoles] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate, GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateBuilder> {
  @BuiltValueField(wireName: r'alert_type')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum get alertType;
  // enum alertTypeEnum {  hos_warning,  hos_violation,  route_assigned,  route_completed,  dvir_defects,  dvir_critical,  log_edit_request,  log_edit_resolved,  uncertified_log,  unidentified_driving,  eld_disconnected,  eld_malfunction,  maintenance_upcoming,  maintenance_overdue,  chat_message,  subscription_expiring,  };

  @BuiltValueField(wireName: r'channels')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum>? get channels;
  // enum channelsEnum {  push,  email,  sms,  telegram,  };

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'recipient_roles')
  BuiltList<String>? get recipientRoles;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'alert_type';
    yield serializers.serialize(
      object.alertType,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum),
    );
    if (object.channels != null) {
      yield r'channels';
      yield serializers.serialize(
        object.channels,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum)]),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.recipientRoles != null) {
      yield r'recipient_roles';
      yield serializers.serialize(
        object.recipientRoles,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'alert_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum;
          result.alertType = valueDes;
          break;
        case r'channels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum>?;
          if (valueDes == null) continue;
          result.channels.replace(valueDes);
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.enabled = valueDes;
          break;
        case r'recipient_roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.recipientRoles.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'hos_warning')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum hosWarning = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_hosWarning;
  @BuiltValueEnumConst(wireName: r'hos_violation')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum hosViolation = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_hosViolation;
  @BuiltValueEnumConst(wireName: r'route_assigned')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum routeAssigned = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_routeAssigned;
  @BuiltValueEnumConst(wireName: r'route_completed')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum routeCompleted = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_routeCompleted;
  @BuiltValueEnumConst(wireName: r'dvir_defects')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum dvirDefects = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_dvirDefects;
  @BuiltValueEnumConst(wireName: r'dvir_critical')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum dvirCritical = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_dvirCritical;
  @BuiltValueEnumConst(wireName: r'log_edit_request')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum logEditRequest = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_logEditRequest;
  @BuiltValueEnumConst(wireName: r'log_edit_resolved')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum logEditResolved = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_logEditResolved;
  @BuiltValueEnumConst(wireName: r'uncertified_log')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum uncertifiedLog = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_uncertifiedLog;
  @BuiltValueEnumConst(wireName: r'unidentified_driving')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum unidentifiedDriving = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_unidentifiedDriving;
  @BuiltValueEnumConst(wireName: r'eld_disconnected')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum eldDisconnected = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_eldDisconnected;
  @BuiltValueEnumConst(wireName: r'eld_malfunction')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum eldMalfunction = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_eldMalfunction;
  @BuiltValueEnumConst(wireName: r'maintenance_upcoming')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum maintenanceUpcoming = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_maintenanceUpcoming;
  @BuiltValueEnumConst(wireName: r'maintenance_overdue')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum maintenanceOverdue = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_maintenanceOverdue;
  @BuiltValueEnumConst(wireName: r'chat_message')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum chatMessage = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_chatMessage;
  @BuiltValueEnumConst(wireName: r'subscription_expiring')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum subscriptionExpiring = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_subscriptionExpiring;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateAlertTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'push')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum push = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum_push;
  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum email = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum sms = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum_sms;
  @BuiltValueEnumConst(wireName: r'telegram')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum telegram = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum_telegram;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdateChannelsEnumValueOf(name);
}

