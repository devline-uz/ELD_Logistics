//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_dvir_push.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush
///
/// Properties:
/// * [clientId] - ClientID is the device generated idempotency key of the report.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush, GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPushBuilder> {
  /// ClientID is the device generated idempotency key of the report.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPushBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPushBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPushSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPushSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush, _$GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPushBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPush deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoDvirPushBuilder();
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


