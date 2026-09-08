//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auditlog_dto_entry.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry
///
/// Properties:
/// * [action] 
/// * [editedBy] - EditedBy is the acting user, null for system jobs.
/// * [editedByName] 
/// * [field] 
/// * [id] 
/// * [ip] 
/// * [masked] - Masked reports that at least one of the two values was redacted.
/// * [newValue] - NewValue is the masked value after the change, null on delete.
/// * [oldValue] - OldValue is the masked value before the change, null on insert. The stored shape is whatever the audited column held (a string, a number, a JSON object); swag cannot type an `any`, so the schema renders it as a free form string.
/// * [reason] 
/// * [recordId] - RecordID is the audited row, null for account wide events such as login.
/// * [table] - TableName is the audited table, e.g. `units` or `support_tickets`.
/// * [ts] 
/// * [userAgent] 
/// * [username] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry implements Built<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry, GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryBuilder> {
  @BuiltValueField(wireName: r'action')
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum? get action;
  // enum actionEnum {  insert,  create,  update,  soft_delete,  delete,  restore,  login,  logout,  failed_login,  export,  permission_change,  log_edit_request,  hos_policy_change,  token_reuse,  cross_tenant_attempt,  certify,  assign,  approve,  reject,  license_reveal,  };

  /// EditedBy is the acting user, null for system jobs.
  @BuiltValueField(wireName: r'edited_by')
  String? get editedBy;

  @BuiltValueField(wireName: r'edited_by_name')
  String? get editedByName;

  @BuiltValueField(wireName: r'field')
  String? get field;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'ip')
  String? get ip;

  /// Masked reports that at least one of the two values was redacted.
  @BuiltValueField(wireName: r'masked')
  bool? get masked;

  /// NewValue is the masked value after the change, null on delete.
  @BuiltValueField(wireName: r'new_value')
  String? get newValue;

  /// OldValue is the masked value before the change, null on insert. The stored shape is whatever the audited column held (a string, a number, a JSON object); swag cannot type an `any`, so the schema renders it as a free form string.
  @BuiltValueField(wireName: r'old_value')
  String? get oldValue;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  /// RecordID is the audited row, null for account wide events such as login.
  @BuiltValueField(wireName: r'record_id')
  String? get recordId;

  /// TableName is the audited table, e.g. `units` or `support_tickets`.
  @BuiltValueField(wireName: r'table')
  String? get table;

  @BuiltValueField(wireName: r'ts')
  DateTime? get ts;

  @BuiltValueField(wireName: r'user_agent')
  String? get userAgent;

  @BuiltValueField(wireName: r'username')
  String? get username;

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry._();

  factory GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry([void updates(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntrySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntrySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry, _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum),
      );
    }
    if (object.editedBy != null) {
      yield r'edited_by';
      yield serializers.serialize(
        object.editedBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.editedByName != null) {
      yield r'edited_by_name';
      yield serializers.serialize(
        object.editedByName,
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
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.ip != null) {
      yield r'ip';
      yield serializers.serialize(
        object.ip,
        specifiedType: const FullType(String),
      );
    }
    if (object.masked != null) {
      yield r'masked';
      yield serializers.serialize(
        object.masked,
        specifiedType: const FullType(bool),
      );
    }
    if (object.newValue != null) {
      yield r'new_value';
      yield serializers.serialize(
        object.newValue,
        specifiedType: const FullType(String),
      );
    }
    if (object.oldValue != null) {
      yield r'old_value';
      yield serializers.serialize(
        object.oldValue,
        specifiedType: const FullType(String),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
    if (object.recordId != null) {
      yield r'record_id';
      yield serializers.serialize(
        object.recordId,
        specifiedType: const FullType(String),
      );
    }
    if (object.table != null) {
      yield r'table';
      yield serializers.serialize(
        object.table,
        specifiedType: const FullType(String),
      );
    }
    if (object.ts != null) {
      yield r'ts';
      yield serializers.serialize(
        object.ts,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.userAgent != null) {
      yield r'user_agent';
      yield serializers.serialize(
        object.userAgent,
        specifiedType: const FullType(String),
      );
    }
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum),
          ) as GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum?;
          if (valueDes == null) continue;
          result.action = valueDes;
          break;
        case r'edited_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.editedBy = valueDes;
          break;
        case r'edited_by_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.editedByName = valueDes;
          break;
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.field = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'ip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ip = valueDes;
          break;
        case r'masked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.masked = valueDes;
          break;
        case r'new_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.newValue = valueDes;
          break;
        case r'old_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.oldValue = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'record_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.recordId = valueDes;
          break;
        case r'table':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.table = valueDes;
          break;
        case r'ts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.ts = valueDes;
          break;
        case r'user_agent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userAgent = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.username = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryBuilder();
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


class GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'insert')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum insert = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_insert;
  @BuiltValueEnumConst(wireName: r'create')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum create = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_create;
  @BuiltValueEnumConst(wireName: r'update')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum update = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_update;
  @BuiltValueEnumConst(wireName: r'soft_delete')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum softDelete = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_softDelete;
  @BuiltValueEnumConst(wireName: r'delete')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum delete = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_delete;
  @BuiltValueEnumConst(wireName: r'restore')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum restore = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_restore;
  @BuiltValueEnumConst(wireName: r'login')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum login = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_login;
  @BuiltValueEnumConst(wireName: r'logout')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum logout = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_logout;
  @BuiltValueEnumConst(wireName: r'failed_login')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum failedLogin = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_failedLogin;
  @BuiltValueEnumConst(wireName: r'export')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum export_ = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_export_;
  @BuiltValueEnumConst(wireName: r'permission_change')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum permissionChange = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_permissionChange;
  @BuiltValueEnumConst(wireName: r'log_edit_request')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum logEditRequest = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_logEditRequest;
  @BuiltValueEnumConst(wireName: r'hos_policy_change')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum hosPolicyChange = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_hosPolicyChange;
  @BuiltValueEnumConst(wireName: r'token_reuse')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum tokenReuse = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_tokenReuse;
  @BuiltValueEnumConst(wireName: r'cross_tenant_attempt')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum crossTenantAttempt = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_crossTenantAttempt;
  @BuiltValueEnumConst(wireName: r'certify')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum certify = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_certify;
  @BuiltValueEnumConst(wireName: r'assign')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum assign = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_assign;
  @BuiltValueEnumConst(wireName: r'approve')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum approve = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_approve;
  @BuiltValueEnumConst(wireName: r'reject')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum reject = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_reject;
  @BuiltValueEnumConst(wireName: r'license_reveal')
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum licenseReveal = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_licenseReveal;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum> get values => _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnumValues;
  static GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainAuditlogDtoEntryActionEnumValueOf(name);
}

