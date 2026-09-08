//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auditlog_dto_table_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope, GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<String>? get data;

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope, _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
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
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuditlogDtoTableListEnvelopeBuilder();
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


