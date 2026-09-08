//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_meta.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta
///
/// Properties:
/// * [page] 
/// * [perPage] 
/// * [total] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta, GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder> {
  @BuiltValueField(wireName: r'page')
  int? get page;

  @BuiltValueField(wireName: r'per_page')
  int? get perPage;

  @BuiltValueField(wireName: r'total')
  int? get total;

  GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta object, {
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
    GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder result,
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
  GithubComDevlineOnebookEldInternalDomainRoutesDtoMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoMetaBuilder();
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


