//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_transfer_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_inspection_transfer_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope, GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult? get data;

  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope, _$GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult),
          ) as GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferResult?;
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
  GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoInspectionTransferEnvelopeBuilder();
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


