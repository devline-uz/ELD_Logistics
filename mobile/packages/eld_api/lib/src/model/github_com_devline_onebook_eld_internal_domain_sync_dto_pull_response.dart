//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_unidentified_event.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_chat_message.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_defect_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_duty_status_event.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_hos_policy.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_log_edit_request.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_sync_dto_daily_log_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_pull_response.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse
///
/// Properties:
/// * [chat] 
/// * [dailyLogs] 
/// * [defectTypes] 
/// * [events] - Events are the server's canonical copies of changed duty status events (rule 2: the server wins, the device rebuilds its local log).
/// * [hosPolicy] 
/// * [logEditRequests] 
/// * [nextSince] - NextSince is the cursor to send on the next pull. It is the newest `updated_at` actually returned, so a truncated page is resumed exactly.
/// * [quickNotes] 
/// * [serverTime] 
/// * [truncated] - Truncated is true when a list hit its ceiling: pull again immediately with next_since.
/// * [unidentifiedEvents] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse, GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder> {
  @BuiltValueField(wireName: r'chat')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage>? get chat;

  @BuiltValueField(wireName: r'daily_logs')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary>? get dailyLogs;

  @BuiltValueField(wireName: r'defect_types')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType>? get defectTypes;

  /// Events are the server's canonical copies of changed duty status events (rule 2: the server wins, the device rebuilds its local log).
  @BuiltValueField(wireName: r'events')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent>? get events;

  @BuiltValueField(wireName: r'hos_policy')
  GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy? get hosPolicy;

  @BuiltValueField(wireName: r'log_edit_requests')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest>? get logEditRequests;

  /// NextSince is the cursor to send on the next pull. It is the newest `updated_at` actually returned, so a truncated page is resumed exactly.
  @BuiltValueField(wireName: r'next_since')
  DateTime? get nextSince;

  @BuiltValueField(wireName: r'quick_notes')
  BuiltList<String>? get quickNotes;

  @BuiltValueField(wireName: r'server_time')
  DateTime? get serverTime;

  /// Truncated is true when a list hit its ceiling: pull again immediately with next_since.
  @BuiltValueField(wireName: r'truncated')
  bool? get truncated;

  @BuiltValueField(wireName: r'unidentified_events')
  BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent>? get unidentifiedEvents;

  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse, _$GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.chat != null) {
      yield r'chat';
      yield serializers.serialize(
        object.chat,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage)]),
      );
    }
    if (object.dailyLogs != null) {
      yield r'daily_logs';
      yield serializers.serialize(
        object.dailyLogs,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary)]),
      );
    }
    if (object.defectTypes != null) {
      yield r'defect_types';
      yield serializers.serialize(
        object.defectTypes,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType)]),
      );
    }
    if (object.events != null) {
      yield r'events';
      yield serializers.serialize(
        object.events,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent)]),
      );
    }
    if (object.hosPolicy != null) {
      yield r'hos_policy';
      yield serializers.serialize(
        object.hosPolicy,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy),
      );
    }
    if (object.logEditRequests != null) {
      yield r'log_edit_requests';
      yield serializers.serialize(
        object.logEditRequests,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest)]),
      );
    }
    if (object.nextSince != null) {
      yield r'next_since';
      yield serializers.serialize(
        object.nextSince,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.quickNotes != null) {
      yield r'quick_notes';
      yield serializers.serialize(
        object.quickNotes,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.serverTime != null) {
      yield r'server_time';
      yield serializers.serialize(
        object.serverTime,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.truncated != null) {
      yield r'truncated';
      yield serializers.serialize(
        object.truncated,
        specifiedType: const FullType(bool),
      );
    }
    if (object.unidentifiedEvents != null) {
      yield r'unidentified_events';
      yield serializers.serialize(
        object.unidentifiedEvents,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'chat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoChatMessage>?;
          if (valueDes == null) continue;
          result.chat.replace(valueDes);
          break;
        case r'daily_logs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDailyLogSummary>?;
          if (valueDes == null) continue;
          result.dailyLogs.replace(valueDes);
          break;
        case r'defect_types':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDefectType>?;
          if (valueDes == null) continue;
          result.defectTypes.replace(valueDes);
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoDutyStatusEvent>?;
          if (valueDes == null) continue;
          result.events.replace(valueDes);
          break;
        case r'hos_policy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoHosPolicy?;
          if (valueDes == null) continue;
          result.hosPolicy.replace(valueDes);
          break;
        case r'log_edit_requests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest>?;
          if (valueDes == null) continue;
          result.logEditRequests.replace(valueDes);
          break;
        case r'next_since':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.nextSince = valueDes;
          break;
        case r'quick_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.quickNotes.replace(valueDes);
          break;
        case r'server_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.serverTime = valueDes;
          break;
        case r'truncated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.truncated = valueDes;
          break;
        case r'unidentified_events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainSyncDtoUnidentifiedEvent>?;
          if (valueDes == null) continue;
          result.unidentifiedEvents.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoPullResponseBuilder();
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


