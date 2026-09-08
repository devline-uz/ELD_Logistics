//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_notification_setting.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting
///
/// Properties:
/// * [alertType] 
/// * [channels] 
/// * [enabled] 
/// * [recipientRoles] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting, GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingBuilder> {
  @BuiltValueField(wireName: r'alert_type')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum? get alertType;
  // enum alertTypeEnum {  hos_warning,  hos_violation,  route_assigned,  route_completed,  dvir_defects,  dvir_critical,  log_edit_request,  log_edit_resolved,  uncertified_log,  unidentified_driving,  eld_disconnected,  eld_malfunction,  maintenance_upcoming,  maintenance_overdue,  chat_message,  subscription_expiring,  };

  @BuiltValueField(wireName: r'channels')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum>? get channels;
  // enum channelsEnum {  push,  email,  sms,  telegram,  };

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'recipient_roles')
  BuiltList<String>? get recipientRoles;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.alertType != null) {
      yield r'alert_type';
      yield serializers.serialize(
        object.alertType,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum),
      );
    }
    if (object.channels != null) {
      yield r'channels';
      yield serializers.serialize(
        object.channels,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum)]),
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
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'alert_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum?;
          if (valueDes == null) continue;
          result.alertType = valueDes;
          break;
        case r'channels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum>?;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingBuilder();
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


class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'hos_warning')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum hosWarning = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_hosWarning;
  @BuiltValueEnumConst(wireName: r'hos_violation')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum hosViolation = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_hosViolation;
  @BuiltValueEnumConst(wireName: r'route_assigned')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum routeAssigned = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_routeAssigned;
  @BuiltValueEnumConst(wireName: r'route_completed')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum routeCompleted = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_routeCompleted;
  @BuiltValueEnumConst(wireName: r'dvir_defects')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum dvirDefects = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_dvirDefects;
  @BuiltValueEnumConst(wireName: r'dvir_critical')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum dvirCritical = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_dvirCritical;
  @BuiltValueEnumConst(wireName: r'log_edit_request')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum logEditRequest = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_logEditRequest;
  @BuiltValueEnumConst(wireName: r'log_edit_resolved')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum logEditResolved = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_logEditResolved;
  @BuiltValueEnumConst(wireName: r'uncertified_log')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum uncertifiedLog = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_uncertifiedLog;
  @BuiltValueEnumConst(wireName: r'unidentified_driving')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum unidentifiedDriving = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_unidentifiedDriving;
  @BuiltValueEnumConst(wireName: r'eld_disconnected')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum eldDisconnected = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_eldDisconnected;
  @BuiltValueEnumConst(wireName: r'eld_malfunction')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum eldMalfunction = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_eldMalfunction;
  @BuiltValueEnumConst(wireName: r'maintenance_upcoming')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum maintenanceUpcoming = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_maintenanceUpcoming;
  @BuiltValueEnumConst(wireName: r'maintenance_overdue')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum maintenanceOverdue = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_maintenanceOverdue;
  @BuiltValueEnumConst(wireName: r'chat_message')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum chatMessage = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_chatMessage;
  @BuiltValueEnumConst(wireName: r'subscription_expiring')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum subscriptionExpiring = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_subscriptionExpiring;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingAlertTypeEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'push')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum push = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum_push;
  @BuiltValueEnumConst(wireName: r'email')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum email = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum sms = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum_sms;
  @BuiltValueEnumConst(wireName: r'telegram')
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum telegram = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum_telegram;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum> get values => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnumValues;
  static GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingChannelsEnumValueOf(name);
}

