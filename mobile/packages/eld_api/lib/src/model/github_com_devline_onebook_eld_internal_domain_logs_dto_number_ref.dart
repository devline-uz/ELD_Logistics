//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_number_ref.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef
///
/// Properties:
/// * [id] 
/// * [number] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef, GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'number')
  String? get number;

  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef, _$GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.number != null) {
      yield r'number';
      yield serializers.serialize(
        object.number,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder result,
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
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.number = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoNumberRefBuilder();
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


