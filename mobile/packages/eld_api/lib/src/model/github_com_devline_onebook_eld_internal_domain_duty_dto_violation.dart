//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_duty_dto_violation.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDutyDtoViolation
///
/// Properties:
/// * [at] 
/// * [severity] 
/// * [type] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDutyDtoViolation implements Built<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation, GithubComDevlineOnebookEldInternalDomainDutyDtoViolationBuilder> {
  @BuiltValueField(wireName: r'at')
  DateTime? get at;

  @BuiltValueField(wireName: r'severity')
  GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum? get severity;
  // enum severityEnum {  warning,  violation,  };

  @BuiltValueField(wireName: r'type')
  GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum? get type;
  // enum typeEnum {  drive_limit,  shift_limit,  break_required,  cycle_limit,  form_manner_trailer,  form_manner_doc,  };

  GithubComDevlineOnebookEldInternalDomainDutyDtoViolation._();

  factory GithubComDevlineOnebookEldInternalDomainDutyDtoViolation([void updates(GithubComDevlineOnebookEldInternalDomainDutyDtoViolationBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDutyDtoViolation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDutyDtoViolationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation> get serializer => _$GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDutyDtoViolation> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDutyDtoViolation, _$GithubComDevlineOnebookEldInternalDomainDutyDtoViolation];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDutyDtoViolation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoViolation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.at != null) {
      yield r'at';
      yield serializers.serialize(
        object.at,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.severity != null) {
      yield r'severity';
      yield serializers.serialize(
        object.severity,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDutyDtoViolation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDutyDtoViolationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.at = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum?;
          if (valueDes == null) continue;
          result.severity = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum?;
          if (valueDes == null) continue;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDutyDtoViolation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDutyDtoViolationBuilder();
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


class GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'warning')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum warning = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum_warning;
  @BuiltValueEnumConst(wireName: r'violation')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum violation = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum_violation;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum> get values => _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationSeverityEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'drive_limit')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum driveLimit = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum_driveLimit;
  @BuiltValueEnumConst(wireName: r'shift_limit')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum shiftLimit = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum_shiftLimit;
  @BuiltValueEnumConst(wireName: r'break_required')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum breakRequired = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum_breakRequired;
  @BuiltValueEnumConst(wireName: r'cycle_limit')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum cycleLimit = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum_cycleLimit;
  @BuiltValueEnumConst(wireName: r'form_manner_trailer')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum formMannerTrailer = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum_formMannerTrailer;
  @BuiltValueEnumConst(wireName: r'form_manner_doc')
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum formMannerDoc = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum_formMannerDoc;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDutyDtoViolationTypeEnumValueOf(name);
}

