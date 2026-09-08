//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_notification_setting.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_notification_settings_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope, GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting>? get data;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSetting>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoNotificationSettingsEnvelopeBuilder();
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


