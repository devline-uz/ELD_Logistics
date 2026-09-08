//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_routes_dto_route_not_completed.g.dart';

/// GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted
///
/// Properties:
/// * [note] - Note explains the closure; it is required for `other`.
/// * [reason] - Reason is one of the fixed closure reasons.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted implements Built<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted, GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedBuilder> {
  /// Note explains the closure; it is required for `other`.
  @BuiltValueField(wireName: r'note')
  String? get note;

  /// Reason is one of the fixed closure reasons.
  @BuiltValueField(wireName: r'reason')
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum get reason;
  // enum reasonEnum {  breakdown,  cancelled,  load_rejected,  road_closed,  driver_change,  other,  };

  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted._();

  factory GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted([void updates(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted> get serializer => _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted, _$GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum),
          ) as GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompleted deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedBuilder();
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


/// Reason is one of the fixed closure reasons.
class GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'breakdown')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum breakdown = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_breakdown;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum cancelled = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'load_rejected')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum loadRejected = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_loadRejected;
  @BuiltValueEnumConst(wireName: r'road_closed')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum roadClosed = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_roadClosed;
  @BuiltValueEnumConst(wireName: r'driver_change')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum driverChange = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_driverChange;
  @BuiltValueEnumConst(wireName: r'other')
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum other = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum unknownDefaultOpenApi = _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum_unknownDefaultOpenApi;

  static Serializer<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum> get serializer => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnumSerializer;

  const GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum._(String name): super(name);

  static BuiltSet<GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum> get values => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnumValues;
  static GithubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnum valueOf(String name) => _$githubComDevlineOnebookEldInternalDomainRoutesDtoRouteNotCompletedReasonEnumValueOf(name);
}

