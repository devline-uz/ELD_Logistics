//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_shipping_document.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_shipping_document_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope, GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainFleetDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope, _$GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocument>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoShippingDocumentListEnvelopeBuilder();
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


