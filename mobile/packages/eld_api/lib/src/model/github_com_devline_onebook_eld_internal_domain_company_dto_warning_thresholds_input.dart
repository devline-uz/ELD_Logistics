//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'github_com_devline_onebook_eld_internal_domain_company_dto_warning_thresholds_input.g.dart';

/// GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput
///
/// Properties:
/// * [break_] 
/// * [cycle] 
/// * [drive] 
/// * [shift] 
@BuiltValue()
abstract class GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput implements Built<GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput, GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInputBuilder> {
  @BuiltValueField(wireName: r'break')
  int? get break_;

  @BuiltValueField(wireName: r'cycle')
  int? get cycle;

  @BuiltValueField(wireName: r'drive')
  int? get drive;

  @BuiltValueField(wireName: r'shift')
  int? get shift;

  GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput._();

  factory GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput([void updates(GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInputBuilder b)]) = _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput> get serializer => _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInputSerializer();
}

class _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInputSerializer implements PrimitiveSerializer<GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput> {
  @override
  final Iterable<Type> types = const [GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput, _$GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput];

  @override
  final String wireName = r'GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput object, {
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
    GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInputBuilder result,
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
  GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GithubComDevlineOnebookEldInternalDomainCompanyDtoWarningThresholdsInputBuilder();
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


