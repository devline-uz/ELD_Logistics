//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_unidentified_annotate.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate
///
/// Properties:
/// * [annotation] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate, GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotateBuilder> {
  @BuiltValueField(wireName: r'annotation')
  String get annotation;

  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotateBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotateSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotateSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate, _$GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'annotation';
    yield serializers.serialize(
      object.annotation,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'annotation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.annotation = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoUnidentifiedAnnotateBuilder();
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


