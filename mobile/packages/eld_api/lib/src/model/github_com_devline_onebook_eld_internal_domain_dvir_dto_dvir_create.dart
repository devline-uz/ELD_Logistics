//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate
///
/// Properties:
/// * [defects] - Defects is empty for a clean inspection (`submitted_no_defects`).
/// * [driverSignatureKey] - DriverSignatureKey is the storage key of the driver signature image.
/// * [notes] - Notes is the free text remark of the inspection.
/// * [trailerIds] - TrailerIDs are the trailers inspected together with the unit.
/// * [type] - Type is the pre/post trip toggle of the mobile form.
/// * [unitId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate, GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder> {
  /// Defects is empty for a clean inspection (`submitted_no_defects`).
  @BuiltValueField(wireName: r'defects')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput>? get defects;

  /// DriverSignatureKey is the storage key of the driver signature image.
  @BuiltValueField(wireName: r'driver_signature_key')
  String get driverSignatureKey;

  /// Notes is the free text remark of the inspection.
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// TrailerIDs are the trailers inspected together with the unit.
  @BuiltValueField(wireName: r'trailer_ids')
  BuiltList<String>? get trailerIds;

  /// Type is the pre/post trip toggle of the mobile form.
  @BuiltValueField(wireName: r'type')
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum get type;
  // enum typeEnum {  pre_trip,  post_trip,  };

  @BuiltValueField(wireName: r'unit_id')
  String get unitId;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.defects != null) {
      yield r'defects';
      yield serializers.serialize(
        object.defects,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput)]),
      );
    }
    yield r'driver_signature_key';
    yield serializers.serialize(
      object.driverSignatureKey,
      specifiedType: const FullType(String),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.trailerIds != null) {
      yield r'trailer_ids';
      yield serializers.serialize(
        object.trailerIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum),
    );
    yield r'unit_id';
    yield serializers.serialize(
      object.unitId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'defects':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectInput>?;
          if (valueDes == null) continue;
          result.defects.replace(valueDes);
          break;
        case r'driver_signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverSignatureKey = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'trailer_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.trailerIds.replace(valueDes);
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum;
          result.type = valueDes;
          break;
        case r'unit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateBuilder();
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


/// Type is the pre/post trip toggle of the mobile form.
class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pre_trip')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum preTrip = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_preTrip;
  @BuiltValueEnumConst(wireName: r'post_trip')
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum postTrip = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_postTrip;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum> get values => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainDvirDtoDvirCreateTypeEnumValueOf(name);
}

