//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_notifications_dto_read_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult
///
/// Properties:
/// * [unread] 
/// * [updated] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult implements Built<GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult, GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder> {
  @BuiltValueField(wireName: r'unread')
  int? get unread;

  @BuiltValueField(wireName: r'updated')
  int? get updated;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult._();

  factory GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult([void updates(GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult, _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.unread != null) {
      yield r'unread';
      yield serializers.serialize(
        object.unread,
        specifiedType: const FullType(int),
      );
    }
    if (object.updated != null) {
      yield r'updated';
      yield serializers.serialize(
        object.updated,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'unread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.unread = valueDes;
          break;
        case r'updated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.updated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder();
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


