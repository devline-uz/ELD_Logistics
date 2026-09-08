//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_element_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult
///
/// Properties:
/// * [clientEventId] - ClientEventID echoes the element's idempotency key.
/// * [field] - Field names the offending field of an invalid_payload rejection.
/// * [reason] - Reason explains a rejection, and annotates an accepted event that the server changed or that lost conflict rule 1.
/// * [result] 
/// * [supersededBy] - SupersededBy is the client_event_id that won conflict rule 1. The losing event is still stored, flagged, and shown to the driver as a warning.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult, GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultBuilder> {
  /// ClientEventID echoes the element's idempotency key.
  @BuiltValueField(wireName: r'client_event_id')
  String? get clientEventId;

  /// Field names the offending field of an invalid_payload rejection.
  @BuiltValueField(wireName: r'field')
  String? get field;

  /// Reason explains a rejection, and annotates an accepted event that the server changed or that lost conflict rule 1.
  @BuiltValueField(wireName: r'reason')
  GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum? get reason;
  // enum reasonEnum {  time_in_future,  time_out_of_range,  log_locked,  invalid_payload,  superseded,  pc_not_allowed,  ym_not_allowed,  sleeper_berth_unavailable,  drive_not_manual,  auto_drive,  yard_move_ended,  };

  @BuiltValueField(wireName: r'result')
  GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum? get result;
  // enum resultEnum {  accepted,  duplicate,  rejected,  };

  /// SupersededBy is the client_event_id that won conflict rule 1. The losing event is still stored, flagged, and shown to the driver as a warning.
  @BuiltValueField(wireName: r'superseded_by')
  String? get supersededBy;

  GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult, _$GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clientEventId != null) {
      yield r'client_event_id';
      yield serializers.serialize(
        object.clientEventId,
        specifiedType: const FullType(String),
      );
    }
    if (object.field != null) {
      yield r'field';
      yield serializers.serialize(
        object.field,
        specifiedType: const FullType(String),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum),
      );
    }
    if (object.result != null) {
      yield r'result';
      yield serializers.serialize(
        object.result,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum),
      );
    }
    if (object.supersededBy != null) {
      yield r'superseded_by';
      yield serializers.serialize(
        object.supersededBy,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientEventId = valueDes;
          break;
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.field = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum?;
          if (valueDes == null) continue;
          result.result = valueDes;
          break;
        case r'superseded_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.supersededBy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoElementResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultBuilder();
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


/// Reason explains a rejection, and annotates an accepted event that the server changed or that lost conflict rule 1.
class GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'time_in_future')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum timeInFuture = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_timeInFuture;
  @BuiltValueEnumConst(wireName: r'time_out_of_range')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum timeOutOfRange = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_timeOutOfRange;
  @BuiltValueEnumConst(wireName: r'log_locked')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum logLocked = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_logLocked;
  @BuiltValueEnumConst(wireName: r'invalid_payload')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum invalidPayload = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_invalidPayload;
  @BuiltValueEnumConst(wireName: r'superseded')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum superseded = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_superseded;
  @BuiltValueEnumConst(wireName: r'pc_not_allowed')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum pcNotAllowed = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_pcNotAllowed;
  @BuiltValueEnumConst(wireName: r'ym_not_allowed')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum ymNotAllowed = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_ymNotAllowed;
  @BuiltValueEnumConst(wireName: r'sleeper_berth_unavailable')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum sleeperBerthUnavailable = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_sleeperBerthUnavailable;
  @BuiltValueEnumConst(wireName: r'drive_not_manual')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum driveNotManual = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_driveNotManual;
  @BuiltValueEnumConst(wireName: r'auto_drive')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum autoDrive = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_autoDrive;
  @BuiltValueEnumConst(wireName: r'yard_move_ended')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum yardMoveEnded = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_yardMoveEnded;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultReasonEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'accepted')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum accepted = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum_accepted;
  @BuiltValueEnumConst(wireName: r'duplicate')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum duplicate = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum_duplicate;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum rejected = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum_rejected;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoElementResultResultEnumValueOf(name);
}

