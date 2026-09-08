//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:eld_api/src/model/github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_diagnostics.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_fleet_dto_unit_diagnostics_envelope.g.dart';

/// GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope implements Built<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope, GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder> {
  @BuiltValueField(wireName: r'data')
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics? get data;

  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope._();

  factory GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope([void updates(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope> get serializer => _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope, _$GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics),
          ) as GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnostics?;
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
  GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainFleetDtoUnitDiagnosticsEnvelopeBuilder();
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


