//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_cancel_input.g.dart';

/// GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput
///
/// Properties:
/// * [cancelledReason] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput implements Built<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput, GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder> {
  @BuiltValueField(wireName: r'cancelled_reason')
  String get cancelledReason;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput._();

  factory GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput([void updates(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput> get serializer => _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput, _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cancelled_reason';
    yield serializers.serialize(
      object.cancelledReason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cancelled_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cancelledReason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCancelInputBuilder();
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


