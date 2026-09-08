//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_assign.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign
///
/// Properties:
/// * [driverId] 
/// * [note] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign, GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder> {
  @BuiltValueField(wireName: r'driver_id')
  String get driverId;

  @BuiltValueField(wireName: r'note')
  String get note;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign, _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driver_id';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
    );
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssign deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAssignBuilder();
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


