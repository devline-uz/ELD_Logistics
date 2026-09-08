//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auditlog_dto_entry.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_auditlog_dto_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_auditlog_dto_entry_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope, GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope, _$GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainAuditlogDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntry>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainAuditlogDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainAuditlogDtoMeta?;
          if (valueDes == null) continue;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainAuditlogDtoEntryListEnvelopeBuilder();
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


