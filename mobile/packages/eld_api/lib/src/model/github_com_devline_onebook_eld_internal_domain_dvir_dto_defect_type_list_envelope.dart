//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_defect_type_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope, GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainDvirDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDvirDtoDefectType>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDvirDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainDvirDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDefectTypeListEnvelopeBuilder();
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


