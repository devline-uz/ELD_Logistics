//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_files_dto_import_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_files_dto_import_result_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope, GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult? get data;

  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope, _$GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult),
          ) as GithubComDevlineOnebookEldInternalDomainFilesDtoImportResult?;
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
  GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFilesDtoImportResultEnvelopeBuilder();
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


