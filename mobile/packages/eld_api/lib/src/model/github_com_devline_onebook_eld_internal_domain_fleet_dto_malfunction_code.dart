//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_malfunction_code.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode
///
/// Properties:
/// * [code] 
/// * [description] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode, GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeBuilder> {
  @BuiltValueField(wireName: r'code')
  GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum? get code;
  // enum codeEnum {  P,  E,  T,  L,  R,  S,  O,  };

  @BuiltValueField(wireName: r'description')
  String? get description;

  GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode, _$GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCode deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeBuilder();
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


class GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'P')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum P = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_P;
  @BuiltValueEnumConst(wireName: r'E')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum E = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_E;
  @BuiltValueEnumConst(wireName: r'T')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum T = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_T;
  @BuiltValueEnumConst(wireName: r'L')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum L = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_L;
  @BuiltValueEnumConst(wireName: r'R')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum R = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_R;
  @BuiltValueEnumConst(wireName: r'S')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum S = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_S;
  @BuiltValueEnumConst(wireName: r'O')
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum O = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_O;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum> get values => _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnumValues;
  static GithubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainFleetDtoMalfunctionCodeCodeEnumValueOf(name);
}

