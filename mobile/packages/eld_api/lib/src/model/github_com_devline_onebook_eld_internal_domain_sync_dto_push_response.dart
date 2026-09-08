//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_element_result.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_telemetry_result.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_clock_verdict.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_push_response.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse
///
/// Properties:
/// * [chat] 
/// * [clock] 
/// * [dvir] 
/// * [events] 
/// * [serverTime] 
/// * [telemetry] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse, GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder> {
  @BuiltValueField(wireName: r'chat')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>? get chat;

  @BuiltValueField(wireName: r'clock')
  GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict? get clock;

  @BuiltValueField(wireName: r'dvir')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>? get dvir;

  @BuiltValueField(wireName: r'events')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>? get events;

  @BuiltValueField(wireName: r'server_time')
  DateTime? get serverTime;

  @BuiltValueField(wireName: r'telemetry')
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult? get telemetry;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse, _$GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.chat != null) {
      yield r'chat';
      yield serializers.serialize(
        object.chat,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult)]),
      );
    }
    if (object.clock != null) {
      yield r'clock';
      yield serializers.serialize(
        object.clock,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict),
      );
    }
    if (object.dvir != null) {
      yield r'dvir';
      yield serializers.serialize(
        object.dvir,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult)]),
      );
    }
    if (object.events != null) {
      yield r'events';
      yield serializers.serialize(
        object.events,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult)]),
      );
    }
    if (object.serverTime != null) {
      yield r'server_time';
      yield serializers.serialize(
        object.serverTime,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.telemetry != null) {
      yield r'telemetry';
      yield serializers.serialize(
        object.telemetry,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'chat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?;
          if (valueDes == null) continue;
          result.chat.replace(valueDes);
          break;
        case r'clock':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoClockVerdict?;
          if (valueDes == null) continue;
          result.clock.replace(valueDes);
          break;
        case r'dvir':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?;
          if (valueDes == null) continue;
          result.dvir.replace(valueDes);
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult>?;
          if (valueDes == null) continue;
          result.events.replace(valueDes);
          break;
        case r'server_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.serverTime = valueDes;
          break;
        case r'telemetry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult?;
          if (valueDes == null) continue;
          result.telemetry.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoPushResponseBuilder();
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


