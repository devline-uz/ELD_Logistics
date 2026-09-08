//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_meta.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoMeta
///
/// Properties:
/// * [page] 
/// * [perPage] 
/// * [total] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoMeta implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoMeta, GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder> {
  @BuiltValueField(wireName: r'page')
  int? get page;

  @BuiltValueField(wireName: r'per_page')
  int? get perPage;

  @BuiltValueField(wireName: r'total')
  int? get total;

  GithubComDevlineOnebookEldInternalDomainDvirDtoMeta._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoMeta([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoMeta> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoMetaSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoMetaSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoMeta> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoMeta, _$GithubComDevlineOnebookEldInternalDomainDvirDtoMeta];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoMeta object, {
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
    GithubComDevlineOnebookEldInternalDomainDvirDtoMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder result,
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
  GithubComDevlineOnebookEldInternalDomainDvirDtoMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoMetaBuilder();
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


