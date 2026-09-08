//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_uncertified_log.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog
///
/// Properties:
/// * [certificationStatus] 
/// * [dailyLogId] 
/// * [daysOverdue] - DaysOverdue counts calendar days past the 8 day certification window.
/// * [driverId] 
/// * [driverName] 
/// * [logDate] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog, GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder> {
  @BuiltValueField(wireName: r'certification_status')
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum? get certificationStatus;
  // enum certificationStatusEnum {  uncertified,  needs_recertify,  };

  @BuiltValueField(wireName: r'daily_log_id')
  String? get dailyLogId;

  /// DaysOverdue counts calendar days past the 8 day certification window.
  @BuiltValueField(wireName: r'days_overdue')
  int? get daysOverdue;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'log_date')
  Date? get logDate;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog, _$GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.certificationStatus != null) {
      yield r'certification_status';
      yield serializers.serialize(
        object.certificationStatus,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum),
      );
    }
    if (object.dailyLogId != null) {
      yield r'daily_log_id';
      yield serializers.serialize(
        object.dailyLogId,
        specifiedType: const FullType(String),
      );
    }
    if (object.daysOverdue != null) {
      yield r'days_overdue';
      yield serializers.serialize(
        object.daysOverdue,
        specifiedType: const FullType(int),
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
    if (object.logDate != null) {
      yield r'log_date';
      yield serializers.serialize(
        object.logDate,
        specifiedType: const FullType(Date),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'certification_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum?;
          if (valueDes == null) continue;
          result.certificationStatus = valueDes;
          break;
        case r'daily_log_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.dailyLogId = valueDes;
          break;
        case r'days_overdue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.daysOverdue = valueDes;
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
        case r'log_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.logDate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLog deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogBuilder();
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


class GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'uncertified')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum uncertified = _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_uncertified;
  @BuiltValueEnumConst(wireName: r'needs_recertify')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum needsRecertify = _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_needsRecertify;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoUncertifiedLogCertificationStatusEnumValueOf(name);
}

