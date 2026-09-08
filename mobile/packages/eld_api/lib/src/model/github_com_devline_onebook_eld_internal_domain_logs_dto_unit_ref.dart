//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_unit_ref.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef
///
/// Properties:
/// * [id] 
/// * [licensePlate] 
/// * [unitNumber] 
/// * [vin] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef, GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'license_plate')
  String? get licensePlate;

  @BuiltValueField(wireName: r'unit_number')
  String? get unitNumber;

  @BuiltValueField(wireName: r'vin')
  String? get vin;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef, _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.licensePlate != null) {
      yield r'license_plate';
      yield serializers.serialize(
        object.licensePlate,
        specifiedType: const FullType(String),
      );
    }
    if (object.unitNumber != null) {
      yield r'unit_number';
      yield serializers.serialize(
        object.unitNumber,
        specifiedType: const FullType(String),
      );
    }
    if (object.vin != null) {
      yield r'vin';
      yield serializers.serialize(
        object.vin,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'license_plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licensePlate = valueDes;
          break;
        case r'unit_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitNumber = valueDes;
          break;
        case r'vin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoUnitRefBuilder();
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


