//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_companies_dto_meta.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta
///
/// Properties:
/// * [page] 
/// * [perPage] 
/// * [total] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta implements Built<GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta, GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder> {
  @BuiltValueField(wireName: r'page')
  int? get page;

  @BuiltValueField(wireName: r'per_page')
  int? get perPage;

  @BuiltValueField(wireName: r'total')
  int? get total;

  GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta._();

  factory GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta([void updates(GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta, _$GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta object, {
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
    GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder result,
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
  GithubComDevlineOnebookEldInternalDomainCompaniesDtoMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompaniesDtoMetaBuilder();
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


