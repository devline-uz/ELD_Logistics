//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_notification_setting_update.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_notification_settings_update.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate
///
/// Properties:
/// * [settings] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate, GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder> {
  @BuiltValueField(wireName: r'settings')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate> get settings;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'settings';
    yield serializers.serialize(
      object.settings,
      specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingUpdate>;
          result.settings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsUpdateBuilder();
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


