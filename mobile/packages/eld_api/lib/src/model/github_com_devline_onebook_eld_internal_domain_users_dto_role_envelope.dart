//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_users_dto_role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_role_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope, GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainUsersDtoRole? get data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope, _$GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoRole),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoRole),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoRole?;
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
  GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoRoleEnvelopeBuilder();
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


