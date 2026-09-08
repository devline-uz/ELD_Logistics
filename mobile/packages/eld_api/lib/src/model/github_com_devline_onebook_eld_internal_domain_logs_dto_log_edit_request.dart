//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_change.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest
///
/// Properties:
/// * [changes] 
/// * [createdAt] 
/// * [dailyLogId] 
/// * [driverId] 
/// * [driverName] 
/// * [driverNote] - DriverNote carries the rejection reason once the driver answered.
/// * [id] 
/// * [logDate] 
/// * [requestedBy] 
/// * [resolvedAt] 
/// * [source_] - Source separates an admin proposal from an unidentified driving assignment awaiting the same driver approval (§10.4).
/// * [status] 
/// * [timezone] 
/// * [unidentifiedEventId] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest, GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder> {
  @BuiltValueField(wireName: r'changes')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>? get changes;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'daily_log_id')
  String? get dailyLogId;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  /// DriverNote carries the rejection reason once the driver answered.
  @BuiltValueField(wireName: r'driver_note')
  String? get driverNote;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'log_date')
  Date? get logDate;

  @BuiltValueField(wireName: r'requested_by')
  String? get requestedBy;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  /// Source separates an admin proposal from an unidentified driving assignment awaiting the same driver approval (§10.4).
  @BuiltValueField(wireName: r'source')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum? get source_;
  // enum source_Enum {  admin_edit,  unidentified_assign,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum? get status;
  // enum statusEnum {  pending,  approved,  rejected,  };

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'unidentified_event_id')
  String? get unidentifiedEventId;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.changes != null) {
      yield r'changes';
      yield serializers.serialize(
        object.changes,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange)]),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.dailyLogId != null) {
      yield r'daily_log_id';
      yield serializers.serialize(
        object.dailyLogId,
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
    if (object.driverNote != null) {
      yield r'driver_note';
      yield serializers.serialize(
        object.driverNote,
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
    if (object.logDate != null) {
      yield r'log_date';
      yield serializers.serialize(
        object.logDate,
        specifiedType: const FullType(Date),
      );
    }
    if (object.requestedBy != null) {
      yield r'requested_by';
      yield serializers.serialize(
        object.requestedBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.resolvedAt != null) {
      yield r'resolved_at';
      yield serializers.serialize(
        object.resolvedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.unidentifiedEventId != null) {
      yield r'unidentified_event_id';
      yield serializers.serialize(
        object.unidentifiedEventId,
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
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>?;
          if (valueDes == null) continue;
          result.changes.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'daily_log_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.dailyLogId = valueDes;
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
        case r'driver_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverNote = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'log_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.logDate = valueDes;
          break;
        case r'requested_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.requestedBy = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'unidentified_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unidentifiedEventId = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestBuilder();
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


/// Source separates an admin proposal from an unidentified driving assignment awaiting the same driver approval (§10.4).
class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'admin_edit')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum adminEdit = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSourceEnum_adminEdit;
  @BuiltValueEnumConst(wireName: r'unidentified_assign')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum unidentifiedAssign = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSourceEnum_unidentifiedAssign;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSource_Enum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestSourceEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum pending = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum approved = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum rejected = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestStatusEnumValueOf(name);
}

