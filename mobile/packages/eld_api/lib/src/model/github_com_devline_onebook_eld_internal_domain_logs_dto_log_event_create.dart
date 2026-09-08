//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_event_create.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate
///
/// Properties:
/// * [from] 
/// * [note] 
/// * [special] 
/// * [status] 
/// * [to] 
/// * [unitId] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate, GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateBuilder> {
  @BuiltValueField(wireName: r'from')
  DateTime get from;

  @BuiltValueField(wireName: r'note')
  String get note;

  @BuiltValueField(wireName: r'special')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum? get special;
  // enum specialEnum {  none,  pc,  ym,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum get status;
  // enum statusEnum {  OFF,  SB,  DR,  ON,  };

  @BuiltValueField(wireName: r'to')
  DateTime get to;

  @BuiltValueField(wireName: r'unit_id')
  String? get unitId;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'from';
    yield serializers.serialize(
      object.from,
      specifiedType: const FullType(DateTime),
    );
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
    if (object.special != null) {
      yield r'special';
      yield serializers.serialize(
        object.special,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(DateTime),
    );
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
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.from = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'special':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum?;
          if (valueDes == null) continue;
          result.special = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum;
          result.status = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.to = valueDes;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateBuilder();
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


class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum none = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum_none;
  @BuiltValueEnumConst(wireName: r'pc')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum pc = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum_pc;
  @BuiltValueEnumConst(wireName: r'ym')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum ym = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum_ym;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateSpecialEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum OFF = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum SB = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum DR = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum ON = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEventCreateStatusEnumValueOf(name);
}

