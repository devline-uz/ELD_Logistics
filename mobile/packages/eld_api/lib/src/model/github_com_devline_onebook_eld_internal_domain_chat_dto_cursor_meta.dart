//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_chat_dto_cursor_meta.g.dart';

/// GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta
///
/// Properties:
/// * [hasMore] - HasMore reports whether older messages exist.
/// * [nextBefore] - NextBefore is the cursor to pass as ?before for the next (older) page.
/// * [perPage] - PerPage is the requested page size.
/// * [unread] - Unread is the number of unread messages the caller has in this thread.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta implements Built<GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta, GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder> {
  /// HasMore reports whether older messages exist.
  @BuiltValueField(wireName: r'has_more')
  bool? get hasMore;

  /// NextBefore is the cursor to pass as ?before for the next (older) page.
  @BuiltValueField(wireName: r'next_before')
  DateTime? get nextBefore;

  /// PerPage is the requested page size.
  @BuiltValueField(wireName: r'per_page')
  int? get perPage;

  /// Unread is the number of unread messages the caller has in this thread.
  @BuiltValueField(wireName: r'unread')
  int? get unread;

  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta._();

  factory GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta([void updates(GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta> get serializer => _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta, _$GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.hasMore != null) {
      yield r'has_more';
      yield serializers.serialize(
        object.hasMore,
        specifiedType: const FullType(bool),
      );
    }
    if (object.nextBefore != null) {
      yield r'next_before';
      yield serializers.serialize(
        object.nextBefore,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.perPage != null) {
      yield r'per_page';
      yield serializers.serialize(
        object.perPage,
        specifiedType: const FullType(int),
      );
    }
    if (object.unread != null) {
      yield r'unread';
      yield serializers.serialize(
        object.unread,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.hasMore = valueDes;
          break;
        case r'next_before':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.nextBefore = valueDes;
          break;
        case r'per_page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.perPage = valueDes;
          break;
        case r'unread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.unread = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainChatDtoCursorMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainChatDtoCursorMetaBuilder();
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


