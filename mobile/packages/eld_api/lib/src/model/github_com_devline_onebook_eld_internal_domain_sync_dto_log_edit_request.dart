//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_change.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_log_edit_request.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest
///
/// Properties:
/// * [changes] - Changes are the proposed duty status intervals; `note` is always set.
/// * [createdAt] 
/// * [dailyLogId] 
/// * [id] 
/// * [logDate] - LogDate is the home terminal calendar day the proposal touches (Q10.2).
/// * [source_] 
/// * [status] 
/// * [timezone] 
/// * [updatedAt] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest, GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestBuilder> {
  /// Changes are the proposed duty status intervals; `note` is always set.
  @BuiltValueField(wireName: r'changes')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange>? get changes;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'daily_log_id')
  String? get dailyLogId;

  @BuiltValueField(wireName: r'id')
  String? get id;

  /// LogDate is the home terminal calendar day the proposal touches (Q10.2).
  @BuiltValueField(wireName: r'log_date')
  Date? get logDate;

  @BuiltValueField(wireName: r'source')
  GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum? get source_;
  // enum source_Enum {  admin_edit,  unidentified_assign,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum? get status;
  // enum statusEnum {  pending,  approved,  rejected,  };

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest, _$GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest object, {
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
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
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
    GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestBuilder result,
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
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum?;
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
  GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestBuilder();
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


class GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'admin_edit')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum adminEdit = _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSourceEnum_adminEdit;
  @BuiltValueEnumConst(wireName: r'unidentified_assign')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum unidentifiedAssign = _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSourceEnum_unidentifiedAssign;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSourceEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSourceEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSourceEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSource_Enum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestSourceEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum pending = _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum approved = _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum rejected = _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainSyncDtoLogEditRequestStatusEnumValueOf(name);
}

