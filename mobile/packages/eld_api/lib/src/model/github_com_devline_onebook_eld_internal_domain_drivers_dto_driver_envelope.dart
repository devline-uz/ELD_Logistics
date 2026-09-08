//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_drivers_dto_driver.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope, GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriver? get data;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope, _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoDriver),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoDriver),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoDriver?;
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
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder();
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


