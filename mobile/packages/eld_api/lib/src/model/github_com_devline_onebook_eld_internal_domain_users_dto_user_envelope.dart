//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_users_dto_user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_user_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope, GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainUsersDtoUser? get data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope, _$GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoUser),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoUser),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoUser?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoUserEnvelopeBuilder();
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


