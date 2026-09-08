//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_license.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_license_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope, GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense? get data;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope, _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense),
          ) as GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense?;
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
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder();
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


