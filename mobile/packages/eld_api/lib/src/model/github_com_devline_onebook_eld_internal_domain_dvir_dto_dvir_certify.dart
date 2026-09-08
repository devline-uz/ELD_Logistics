//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_certify.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify
///
/// Properties:
/// * [signatureKey] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify implements Built<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify, GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertifyBuilder> {
  @BuiltValueField(wireName: r'signature_key')
  String get signatureKey;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify._();

  factory GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify([void updates(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertifyBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertifyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify> get serializer => _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertifySerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertifySerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify, _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'signature_key';
    yield serializers.serialize(
      object.signatureKey,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertifyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'signature_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.signatureKey = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertify deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDvirDtoDvirCertifyBuilder();
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


