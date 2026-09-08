//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_history_entry.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_company_dto_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_history_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope, GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryEntry>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainCompanyDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoHistoryListEnvelopeBuilder();
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


