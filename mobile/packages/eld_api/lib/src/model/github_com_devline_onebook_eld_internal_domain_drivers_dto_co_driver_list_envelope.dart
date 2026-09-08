//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_drivers_dto_co_driver.dart';
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_drivers_dto_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_co_driver_list_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope, GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver>? get data;

  @BuiltValueField(wireName: r'meta')
  GithubComDevlineOnebookEldInternalDomainDriversDtoMeta? get meta;

  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope, _$GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver)]),
          ) as BuiltList<GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriver>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoMeta),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoMeta?;
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
  GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoCoDriverListEnvelopeBuilder();
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


