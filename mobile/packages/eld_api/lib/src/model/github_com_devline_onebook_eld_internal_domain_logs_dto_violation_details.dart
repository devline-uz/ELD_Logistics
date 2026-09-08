//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_logs_dto_violation_details.g.dart';

/// GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails
///
/// Properties:
/// * [daysUncertified] - DaysUncertified counts the uncertified days behind an `uncertified_log`.
/// * [limitMin] - LimitMin is the policy limit that was measured against, in minutes.
/// * [note] - Note is the human readable explanation.
/// * [remainingMin] - RemainingMin is what was left when a warning was raised.
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails implements Built<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails, GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder> {
  /// DaysUncertified counts the uncertified days behind an `uncertified_log`.
  @BuiltValueField(wireName: r'days_uncertified')
  int? get daysUncertified;

  /// LimitMin is the policy limit that was measured against, in minutes.
  @BuiltValueField(wireName: r'limit_min')
  int? get limitMin;

  /// Note is the human readable explanation.
  @BuiltValueField(wireName: r'note')
  String? get note;

  /// RemainingMin is what was left when a warning was raised.
  @BuiltValueField(wireName: r'remaining_min')
  int? get remainingMin;

  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails._();

  factory GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails([void updates(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails> get serializer => _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails, _$GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.daysUncertified != null) {
      yield r'days_uncertified';
      yield serializers.serialize(
        object.daysUncertified,
        specifiedType: const FullType(int),
      );
    }
    if (object.limitMin != null) {
      yield r'limit_min';
      yield serializers.serialize(
        object.limitMin,
        specifiedType: const FullType(int),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.remainingMin != null) {
      yield r'remaining_min';
      yield serializers.serialize(
        object.remainingMin,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'days_uncertified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.daysUncertified = valueDes;
          break;
        case r'limit_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.limitMin = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'remaining_min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.remainingMin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetails deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainLogsDtoViolationDetailsBuilder();
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


