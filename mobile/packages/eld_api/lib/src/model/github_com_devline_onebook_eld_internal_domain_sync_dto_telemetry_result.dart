//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_sync_dto_telemetry_result.g.dart';

/// GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult
///
/// Properties:
/// * [accepted] 
/// * [distanceM] - DistanceM is the distance the accepted samples added to the unit.
/// * [duplicate] 
/// * [rejected] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult implements Built<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult, GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder> {
  @BuiltValueField(wireName: r'accepted')
  int? get accepted;

  /// DistanceM is the distance the accepted samples added to the unit.
  @BuiltValueField(wireName: r'distance_m')
  int? get distanceM;

  @BuiltValueField(wireName: r'duplicate')
  int? get duplicate;

  @BuiltValueField(wireName: r'rejected')
  int? get rejected;

  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult._();

  factory GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult([void updates(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult> get serializer => _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult, _$GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.accepted != null) {
      yield r'accepted';
      yield serializers.serialize(
        object.accepted,
        specifiedType: const FullType(int),
      );
    }
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType(int),
      );
    }
    if (object.duplicate != null) {
      yield r'duplicate';
      yield serializers.serialize(
        object.duplicate,
        specifiedType: const FullType(int),
      );
    }
    if (object.rejected != null) {
      yield r'rejected';
      yield serializers.serialize(
        object.rejected,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accepted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.accepted = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'duplicate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.duplicate = valueDes;
          break;
        case r'rejected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.rejected = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainSyncDtoTelemetryResultBuilder();
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


