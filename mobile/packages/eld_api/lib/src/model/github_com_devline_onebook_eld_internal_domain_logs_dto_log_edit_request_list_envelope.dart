//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_request_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope, GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainLogsDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope, _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequest>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRequestListEnvelopeBuilder();
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


