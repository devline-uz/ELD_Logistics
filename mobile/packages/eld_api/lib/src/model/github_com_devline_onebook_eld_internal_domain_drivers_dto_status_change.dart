//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_status_change.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange
///
/// Properties:
/// * [reason] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange, GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder> {
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange, _$GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoStatusChangeBuilder();
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


