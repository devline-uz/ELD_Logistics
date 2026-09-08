//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_warning_thresholds.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds
///
/// Properties:
/// * [break_] 
/// * [cycle] 
/// * [drive] 
/// * [shift] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds, GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsBuilder> {
  @BuiltValueField(wireName: r'break')
  int? get break_;

  @BuiltValueField(wireName: r'cycle')
  int? get cycle;

  @BuiltValueField(wireName: r'drive')
  int? get drive;

  @BuiltValueField(wireName: r'shift')
  int? get shift;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.break_ != null) {
      yield r'break';
      yield serializers.serialize(
        object.break_,
        specifiedType: const FullType(int),
      );
    }
    if (object.cycle != null) {
      yield r'cycle';
      yield serializers.serialize(
        object.cycle,
        specifiedType: const FullType(int),
      );
    }
    if (object.drive != null) {
      yield r'drive';
      yield serializers.serialize(
        object.drive,
        specifiedType: const FullType(int),
      );
    }
    if (object.shift != null) {
      yield r'shift';
      yield serializers.serialize(
        object.shift,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'break':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.break_ = valueDes;
          break;
        case r'cycle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.cycle = valueDes;
          break;
        case r'drive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.drive = valueDes;
          break;
        case r'shift':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.shift = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholds deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsBuilder();
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


