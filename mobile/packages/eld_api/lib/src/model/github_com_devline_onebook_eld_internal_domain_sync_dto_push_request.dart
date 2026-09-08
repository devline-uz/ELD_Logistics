//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_clock.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_dvir_push.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_chat_push.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_telemetry_point.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_event_push.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_push_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest
///
/// Properties:
/// * [appVersion] 
/// * [chat] 
/// * [clock] 
/// * [deviceId] - DeviceID identifies the uploading phone; it namespaces the per device rate limit and is echoed into the audit trail.
/// * [dvir] 
/// * [events] 
/// * [telemetry] 
/// * [unitId] - UnitID is the unit the telemetry belongs to; required when `telemetry` is not empty.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest, GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder> {
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'chat')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush>? get chat;

  @BuiltValueField(wireName: r'clock')
  GithubComDevlineOnebookEldInternalDomainSyncDtoClock? get clock;

  /// DeviceID identifies the uploading phone; it namespaces the per device rate limit and is echoed into the audit trail.
  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  @BuiltValueField(wireName: r'dvir')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush>? get dvir;

  @BuiltValueField(wireName: r'events')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush>? get events;

  @BuiltValueField(wireName: r'telemetry')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint>? get telemetry;

  /// UnitID is the unit the telemetry belongs to; required when `telemetry` is not empty.
  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest, _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.chat != null) {
      yield r'chat';
      yield serializers.serialize(
        object.chat,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush)]),
      );
    }
    if (object.clock != null) {
      yield r'clock';
      yield serializers.serialize(
        object.clock,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoClock),
      );
    }
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    if (object.dvir != null) {
      yield r'dvir';
      yield serializers.serialize(
        object.dvir,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush)]),
      );
    }
    if (object.events != null) {
      yield r'events';
      yield serializers.serialize(
        object.events,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush)]),
      );
    }
    if (object.telemetry != null) {
      yield r'telemetry';
      yield serializers.serialize(
        object.telemetry,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint)]),
      );
    }
    if (object.unitId != null) {
      yield r'unit_id';
      yield serializers.serialize(
        object.unitId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'chat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoChatPush>?;
          if (valueDes == null) continue;
          result.chat.replace(valueDes);
          break;
        case r'clock':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoClock),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoClock?;
          if (valueDes == null) continue;
          result.clock.replace(valueDes);
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'dvir':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush>?;
          if (valueDes == null) continue;
          result.dvir.replace(valueDes);
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoEventPush>?;
          if (valueDes == null) continue;
          result.events.replace(valueDes);
          break;
        case r'telemetry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryPoint>?;
          if (valueDes == null) continue;
          result.telemetry.replace(valueDes);
          break;
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoPushRequestBuilder();
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


