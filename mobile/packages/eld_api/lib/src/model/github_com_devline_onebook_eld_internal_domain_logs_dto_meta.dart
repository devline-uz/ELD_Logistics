//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_meta.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoMeta
///
/// Properties:
/// * [page] 
/// * [perPage] 
/// * [total] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoMeta implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoMeta, GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder> {
  @BuiltValueField(wireName: r'page')
  int? get page;

  @BuiltValueField(wireName: r'per_page')
  int? get perPage;

  @BuiltValueField(wireName: r'total')
  int? get total;

  GithubComDevlineOnebookEldInternalDomainLogsDtoMeta._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoMeta([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoMeta> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoMetaSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoMetaSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoMeta> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoMeta, _$GithubComDevlineOnebookEldInternalDomainLogsDtoMeta];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.page != null) {
      yield r'page';
      yield serializers.serialize(
        object.page,
        specifiedType: const FullType(int),
      );
    }
    if (object.perPage != null) {
      yield r'per_page';
      yield serializers.serialize(
        object.perPage,
        specifiedType: const FullType(int),
      );
    }
    if (object.total != null) {
      yield r'total';
      yield serializers.serialize(
        object.total,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.page = valueDes;
          break;
        case r'per_page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.perPage = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoMetaBuilder();
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


