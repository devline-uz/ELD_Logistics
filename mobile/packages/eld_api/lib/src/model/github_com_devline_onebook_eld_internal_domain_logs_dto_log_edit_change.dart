//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_change.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange
///
/// Properties:
/// * [from] 
/// * [note] 
/// * [special] 
/// * [status] 
/// * [to] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange, GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeBuilder> {
  @BuiltValueField(wireName: r'from')
  DateTime get from;

  @BuiltValueField(wireName: r'note')
  String get note;

  @BuiltValueField(wireName: r'special')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum? get special;
  // enum specialEnum {  none,  pc,  ym,  };

  @BuiltValueField(wireName: r'status')
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum get status;
  // enum statusEnum {  OFF,  SB,  DR,  ON,  };

  @BuiltValueField(wireName: r'to')
  DateTime get to;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange object, {
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
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeBuilder result,
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
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum?;
          if (valueDes == null) continue;
          result.special = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum;
          result.status = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.to = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeBuilder();
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


class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'none')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum none = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum_none;
  @BuiltValueEnumConst(wireName: r'pc')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum pc = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum_pc;
  @BuiltValueEnumConst(wireName: r'ym')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum ym = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum_ym;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeSpecialEnumValueOf(name);
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OFF')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum OFF = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum_OFF;
  @BuiltValueEnumConst(wireName: r'SB')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum SB = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum_SB;
  @BuiltValueEnumConst(wireName: r'DR')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum DR = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum_DR;
  @BuiltValueEnumConst(wireName: r'ON')
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum ON = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum_ON;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum> get values => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnumValues;
  static GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainLogsDtoLogEditChangeStatusEnumValueOf(name);
}

