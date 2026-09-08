//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_users_dto_invitation_sent.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_users_dto_invitation_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope, GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent? get data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope, _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent),
          ) as GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent?;
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
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder();
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


